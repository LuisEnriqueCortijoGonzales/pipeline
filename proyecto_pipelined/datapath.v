module datapath (
    input wire clk,
    input wire reset,
    input wire [1:0] RegSrcD,
    input wire [1:0] ImmSrcD,
    input wire ALUSrcE,
    input wire BranchTakenE,
    input wire [ALUCONTROL_WIDTH-1:0] ALUControlE,
    input wire MemtoRegW,
    input wire PCSrcW,
    input wire RegWriteW,
    output wire [31:0] PCF,
    input wire [31:0] InstrF,
    output wire [31:0] InstrD,
    output wire [31:0] ALUOutM,
    output wire [31:0] WriteDataM,
    input wire [31:0] ReadDataM,
    output wire [3:0] ALUFlagsE,

    //variables del manejo de hazards

    output wire Match_1E_M, // Indica si hay coincidencia entre el registro de escritura en la etapa M y el primer registro fuente en la etapa E
    output wire Match_1E_W, // Indica si hay coincidencia entre el registro de escritura en la etapa W y el primer registro fuente en la etapa E
    output wire Match_2E_M, // Indica si hay coincidencia entre el registro de escritura en la etapa M y el segundo registro fuente en la etapa E
    output wire Match_2E_W, // Indica si hay coincidencia entre el registro de escritura en la etapa W y el segundo registro fuente en la etapa E
    output wire Match_12D_E, // Indica si hay coincidencia entre los registros de escritura en la etapa E y los registros fuente en la etapa D
    input wire [1:0] ForwardAE,  // Controla el bypassing para el primer operando de la ALU
    input wire [1:0] ForwardBE,  // Controla el bypassing para el segundo operando de la ALU
    input wire StallF,  // Señal para detener la etapa F del pipeline
    input wire StallD,  // Señal para detener la etapa D del pipeline
    input wire FlushD  // Señal para limpiar la etapa D del pipeline
);
  parameter ALUCONTROL_WIDTH = 5;

  //fin de las variables del manejo de hazards

  wire [31:0] PCPlus4F;
  wire [31:0] PCnext1F;
  wire [31:0] PCnextF;
  wire [31:0] ExtImmD;
  wire [31:0] rd1D;
  wire [31:0] rd2D;
  wire [31:0] PCPlus8D;
  wire [31:0] rd1E;
  wire [31:0] rd2E;
  wire [31:0] ExtImmE;
  wire [31:0] SrcAE;
  wire [31:0] SrcBE;
  wire [31:0] WriteDataE;
  wire [31:0] ALUResultE;
  wire [31:0] ReadDataW;
  wire [31:0] ALUOutW;
  wire [31:0] ResultW;
  wire [3:0] RA1D;
  wire [3:0] RA2D;
  wire [3:0] RA1E;
  wire [3:0] RA2E;
  wire [3:0] WA3E;
  wire [3:0] WA3M;
  wire [3:0] WA3W;
  wire Match_1D_E;
  wire Match_2D_E;

  // Este multiplexor selecciona la dirección del primer registro fuente
  // para la etapa de decodificación, permitiendo elegir entre un valor
  // de la instrucción o un valor literal.
  mux2 #(
      .WIDTH(4)
  ) ra1_mux (
      .d0(InstrD[19:16]),  // Selección de bits de la instrucción
      .d1(4'b1111),        // Valor alternativo (literal)
      .s (RegSrcD[0]),     // Señal de selección
      .y (RA1D)            // Salida del mux
  );
  // Este multiplexor selecciona la dirección del segundo registro fuente
  // para la etapa de decodificación, permitiendo elegir entre dos
  // diferentes partes de la instrucción.
  mux2 #(
      .WIDTH(4)
  ) ra2_mux (
      .d0(InstrD[3:0]),    // Selección de bits de la instrucción
      .d1(InstrD[15:12]),  // Alternativa de selección
      .s (RegSrcD[1]),     // Señal de selección
      .y (RA2D)            // Salida del mux
  );
  // Este multiplexor selecciona la siguiente dirección del contador de programa (PC),
  // permitiendo elegir entre la dirección secuencial (PC + 4) o el resultado de una
  // operación previa, como un salto o una llamada a subrutina.
  mux2 #(
      .WIDTH(32)
  ) pc_next_mux (
      .d0(PCPlus4F),
      .d1(ResultW),
      .s (PCSrcW),
      .y (PCnext1F)
  );
  // Este multiplexor decide si el pipeline debe seguir con la siguiente instrucción
  // secuencial o si debe tomar una rama, utilizando el resultado de la ALU para
  // calcular la nueva dirección del PC en caso de que se tome la rama.
  mux2 #(
      .WIDTH(32)
  ) branch_mux (
      .d0(PCnext1F),
      .d1(ALUResultE),
      .s (BranchTakenE),
      .y (PCnextF)
  );
  // Stall: Controla el estancamiento de instrucciones en el pipeline para
  // resolver dependencias de datos o control, insertando burbujas cuando sea
  // necesario.
  registro_flanco_positivo_habilitacion #(
      .WIDTH(32)
  ) pc_reg_Stalls (
      .clk(clk),
      .reset(reset),
      .en(~StallF),
      .d(PCnextF),
      .q(PCF)
  );
  //un adder de toda la vida
  adder #(
      .WIDTH(32)
  ) pc_add (
      .a(PCF),
      .b(32'h00000004),
      .y(PCPlus4F)
  );
  assign PCPlus8D = PCPlus4F;
  // Flush: Limpia las instrucciones en el pipeline en respuesta a cambios de
  // control, como saltos o predicciones de ramas incorrectas, para mantener
  // la coherencia del flujo de instrucciones.
  registro_flanco_positivo_habilitacion_limpieza #(
      .WIDTH(32)
  ) instr_reg (
      .clk  (clk),      // Reloj del sistema
      .reset(reset),    // Señal de reinicio
      .en   (~StallD),  // Habilitación del registro, se activa cuando no hay estancamiento
      .clear(FlushD),   // Limpia el registro si hay un cambio de control
      .d    (InstrF),   // Dato de entrada, la instrucción actual
      .q    (InstrD)    // Dato de salida, la instrucción almacenada
  );
  regfile Registros (  //el registro de registros para ver los registros
      .clk(clk),        // Reloj del sistema
      .we3(RegWriteW),  // Señal de escritura
      .ra1(RA1D),       // Dirección del primer registro a leer
      .ra2(RA2D),       // Dirección del segundo registro a leer
      .wa3(WA3W),       // Dirección del registro a escribir
      .wd3(ResultW),    // Dato a escribir
      .r15(PCPlus8D),   // Valor del registro 15 (PC + 8)
      .rd1(rd1D),       // Salida del primer registro leído
      .rd2(rd2D)        // Salida del segundo registro leído
  );
  extend extender (
      .Instr (InstrD[23:0]),  // Parte de la instrucción a extender
      .ImmSrc(ImmSrcD),       // Control de la extensión
      .ExtImm(ExtImmD)        // Salida del valor extendido
  );
  // Este registro almacena el valor del primer operando leído de los registros
  // en la etapa de decodificación y lo transfiere a la etapa de ejecución.
  registro_flanco_positivo #(
      .WIDTH(32)
  ) rd1_reg (
      .clk  (clk),    // Reloj del sistema
      .reset(reset),  // Señal de reinicio
      .d    (rd1D),   // Dato de entrada
      .q    (rd1E)    // Dato de salida
  );
  // Este registro almacena el valor del segundo operando leído de los registros
  // en la etapa de decodificación y lo transfiere a la etapa de ejecución.
  registro_flanco_positivo #(
      .WIDTH(32)
  ) rd2_reg (
      .clk  (clk),    // Reloj del sistema
      .reset(reset),  // Señal de reinicio
      .d    (rd2D),   // Dato de entrada
      .q    (rd2E)    // Dato de salida
  );
  // Este registro almacena el valor inmediato extendido en la etapa de decodificación
  // y lo transfiere a la etapa de ejecución para su uso en operaciones aritméticas.
  registro_flanco_positivo #(
      .WIDTH(32)
  ) imm_reg (
      .clk  (clk),      // Reloj del sistema
      .reset(reset),    // Señal de reinicio
      .d    (ExtImmD),  // Dato de entrada
      .q    (ExtImmE)   // Dato de salida
  );
  // Este registro almacena la dirección del registro de destino en la etapa de decodificación
  // y la transfiere a la etapa de ejecución para determinar dónde escribir el resultado.
  registro_flanco_positivo #(
      .WIDTH(4)
  ) wa3e_reg (
      .clk  (clk),            // Reloj del sistema
      .reset(reset),          // Señal de reinicio
      .d    (InstrD[15:12]),  // Dato de entrada
      .q    (WA3E)            // Dato de salida
  );
  // Este registro almacena la dirección del primer registro fuente en la etapa de decodificación
  // y la transfiere a la etapa de ejecución para el acceso a los datos.
  registro_flanco_positivo #(
      .WIDTH(4)
  ) ra1_reg (
      .clk  (clk),    // Reloj del sistema
      .reset(reset),  // Señal de reinicio
      .d    (RA1D),   // Dato de entrada
      .q    (RA1E)    // Dato de salida
  );
  // Este registro almacena la dirección del segundo registro fuente en la etapa de decodificación
  // y la transfiere a la etapa de ejecución para el acceso a los datos.
  registro_flanco_positivo #(
      .WIDTH(4)
  ) ra2_reg (
      .clk  (clk),    // Reloj del sistema
      .reset(reset),  // Señal de reinicio
      .d    (RA2D),   // Dato de entrada
      .q    (RA2E)    // Dato de salida
  );
  // Forwarding/Bypassing: Utiliza multiplexores para redirigir los resultados
  // de la ALU y datos de escritura directamente a las instrucciones que los
  // requieren, evitando riesgos de datos en el pipeline.

  mux3 #(
      .WIDTH(32)
  ) by_pass1_mux (
      .d0(rd1E),
      .d1(ResultW),
      .d2(ALUOutM),
      .s (ForwardAE),
      .y (SrcAE)
  );
  mux3 #(
      .WIDTH(32)
  ) by_pass2_mux (
      .d0(rd2E),
      .d1(ResultW),
      .d2(ALUOutM),
      .s (ForwardBE),
      .y (WriteDataE)
  );
  //fin del forwarding/bypassing
  // Este multiplexor selecciona el segundo operando para la ALU en la etapa de ejecución,
  // permitiendo elegir entre los datos a escribir o un valor inmediato extendido.
  mux2 #(
      .WIDTH(32)
  ) srcb_mux (
      .d0(WriteDataE),
      .d1(ExtImmE),
      .s (ALUSrcE),
      .y (SrcBE)
  );
  // ALU: Unidad Aritmética y Lógica que realiza operaciones aritméticas y lógicas
  alu ALU (
      .a(SrcAE),
      .b(SrcBE),
      .ALUControl(ALUControlE),
      .Result(ALUResultE),
      .Flags(ALUFlagsE)
  );
  // Este registro almacena el resultado de la ALU en la etapa de ejecución
  // y lo transfiere a la etapa de memoria para operaciones posteriores.
  registro_flanco_positivo #(
      .WIDTH(32)
  ) alu_res_reg (
      .clk(clk),
      .reset(reset),
      .d(ALUResultE),
      .q(ALUOutM)
  );
  // Este registro almacena los datos a escribir en memoria desde la etapa de ejecución
  // y los transfiere a la etapa de memoria.
  registro_flanco_positivo #(
      .WIDTH(32)
  ) wd_reg (
      .clk(clk),
      .reset(reset),
      .d(WriteDataE),
      .q(WriteDataM)
  );
  // Este registro almacena la dirección del registro de destino desde la etapa de ejecución
  // y la transfiere a la etapa de memoria para determinar dónde escribir el resultado.
  registro_flanco_positivo #(
      .WIDTH(4)
  ) wa3m_reg (
      .clk(clk),
      .reset(reset),
      .d(WA3E),
      .q(WA3M)
  );
  // Este registro almacena el resultado de la ALU desde la etapa de memoria
  // y lo transfiere a la etapa de escritura para su uso final.
  registro_flanco_positivo #(
      .WIDTH(32)
  ) alu_out_reg (
      .clk(clk),
      .reset(reset),
      .d(ALUOutM),
      .q(ALUOutW)
  );
  // Este registro almacena los datos leídos de memoria en la etapa de memoria
  // y los transfiere a la etapa de escritura.
  registro_flanco_positivo #(
      .WIDTH(32)
  ) rd_reg (
      .clk(clk),
      .reset(reset),
      .d(ReadDataM),
      .q(ReadDataW)
  );
  // Este registro almacena la dirección del registro de destino desde la etapa de memoria
  // y la transfiere a la etapa de escritura para determinar dónde escribir el resultado final.
  registro_flanco_positivo #(
      .WIDTH(4)
  ) wa3w_reg (
      .clk(clk),
      .reset(reset),
      .d(WA3M),
      .q(WA3W)
  );
  // Este multiplexor selecciona el valor que se escribirá de vuelta en los registros,
  // permitiendo elegir entre el resultado de la ALU o los datos leídos de memoria.
  mux2 #(
      .WIDTH(32)
  ) res_mux (
      .d0(ALUOutW),
      .d1(ReadDataW),
      .s (MemtoRegW),
      .y (ResultW)
  );
  // Este comparador verifica si el registro de destino en la etapa de memoria
  // coincide con el primer registro fuente en la etapa de ejecución, para detectar
  // riesgos de datos.
  comparador_igualdad #(
      .WIDTH(4)
  ) m0 (
      .a(WA3M),
      .b(RA1E),
      .y(Match_1E_M)
  );
  // Este comparador verifica si el registro de destino en la etapa de escritura
  // coincide con el primer registro fuente en la etapa de ejecución, para detectar
  // riesgos de datos.
  comparador_igualdad #(
      .WIDTH(4)
  ) m1 (
      .a(WA3W),
      .b(RA1E),
      .y(Match_1E_W)
  );
  // Este comparador verifica si el registro de destino en la etapa de memoria
  // coincide con el segundo registro fuente en la etapa de ejecución, para detectar
  // riesgos de datos.
  comparador_igualdad #(
      .WIDTH(4)
  ) m2 (
      .a(WA3M),
      .b(RA2E),
      .y(Match_2E_M)
  );
  // Este comparador verifica si el registro de destino en la etapa de escritura
  // coincide con el segundo registro fuente en la etapa de ejecución, para detectar
  // riesgos de datos.
  comparador_igualdad #(
      .WIDTH(4)
  ) m3 (
      .a(WA3W),
      .b(RA2E),
      .y(Match_2E_W)
  );
  // Este comparador verifica si el registro de destino en la etapa de ejecución
  // coincide con el primer registro fuente en la etapa de decodificación, para detectar
  // riesgos de datos.
  comparador_igualdad #(
      .WIDTH(4)
  ) m4a (
      .a(WA3E),
      .b(RA1D),
      .y(Match_1D_E)
  );
  // Este comparador verifica si el registro de destino en la etapa de ejecución
  // coincide con el segundo registro fuente en la etapa de decodificación, para detectar
  // riesgos de datos.
  comparador_igualdad #(
      .WIDTH(4)
  ) m4b (
      .a(WA3E),
      .b(RA2D),
      .y(Match_2D_E)
  );
  // Esta asignación lógica combina las coincidencias de los registros fuente
  // en la etapa de decodificación con el registro de destino en la etapa de ejecución.
  assign Match_12D_E = Match_1D_E | Match_2D_E;
endmodule
