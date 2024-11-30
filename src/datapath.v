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
    input wire [1:0] RegWriteW,
    output wire [31:0] PCF,
    input wire [31:0] InstrF,
    output wire [31:0] InstrD,
    output wire [(DATA_WIDTH*2)-1:0] ALUOutM,
    output wire [31:0] WriteDataM,
    input wire [31:0] ReadDataM,
    input wire is_memory_strE,
    input wire is_memory_postE,
    input wire is_memory_strW,
    input wire is_memory_postW,
    output wire [ALU_FLAGS_WIDTH-1:0] ALUFlagsE,
    input wire [ALU_FLAGS_WIDTH-1:0] FlagsE,
    input wire predict_taken,
    //variables del manejo de hazards

    output wire Match_1E_M, // Indica si hay coincidencia entre el registro de escritura en la etapa M y el primer registro fuente en la etapa E
    output wire Match_1E_W, // Indica si hay coincidencia entre el registro de escritura en la etapa W y el primer registro fuente en la etapa E

    output wire Match_2E_M, // Indica si hay coincidencia entre el registro de escritura en la etapa M y el segundo registro fuente en la etapa E
    output wire Match_2E_W, // Indica si hay coincidencia entre el registro de escritura en la etapa W y el segundo registro fuente en la etapa E

    output wire Match_3E_M, // Indica si hay coincidencia entre el registro de escritura en la etapa M y el tercer registro fuente en la etapa E
    output wire Match_3E_W, // Indica si hay coincidencia entre el registro de escritura en la etapa W y el tercer registro fuente en la etapa E

    output wire Match_4E_M, // Indica si hay coincidencia entre el registro de escritura en la etapa M y el tercer registro fuente en la etapa E
    output wire Match_4E_W, // Indica si hay coincidencia entre el registro de escritura en la etapa W y el tercer registro fuente en la etapa E

    output wire Match_12D_E, // Indica si hay coincidencia entre los registros de escritura en la etapa E y los registros fuente en la etapa D

    input wire [1:0] ForwardAE,  // Controla el bypassing para el primer operando de la ALU
    input wire [1:0] ForwardBE,  // Controla el bypassing para el segundo operando de la ALU
    input wire [1:0] ForwardCE,  // Controla el bypassing para el tercer operando de la ALU
    input wire [1:0] ForwardDE,  // Controla el bypassing para el cuarto operando de la ALU

    input wire StallF,  // Señal para detener la etapa F del pipeline
    input wire StallD,  // Señal para detener la etapa D del pipeline
    input wire FlushD   // Señal para limpiar la etapa D del pipeline
);
  localparam ALU_FLAGS_WIDTH = 5;
  parameter ALUCONTROL_WIDTH = 6;
  parameter DATA_WIDTH = 32;

  //fin de las variables del manejo de hazards

  wire [31:0] PCPlus4F;
  wire [31:0] PCnext1F;
  wire [31:0] PCnextF;
  wire [31:0] ExtImmD;

  wire [31:0] rd1D;
  wire [31:0] rd2D;
  wire [31:0] rd3D;
  wire [31:0] rd4D;

  wire [31:0] PCPlus8D;
  wire [31:0] PCPlus8E;
  wire [31:0] PCPlus8M;
  wire [31:0] PCPlus8W;

  wire [31:0] rd1E;
  wire [31:0] rd2E;
  wire [31:0] rd3E;
  wire [31:0] rd4E;

  wire [31:0] ExtImmE;

  wire [31:0] SrcAE;
  wire [31:0] SrcBE;
  wire [31:0] SrcCE;
  wire [31:0] SrcDE;

  wire [31:0] WriteDataE;

  wire [(DATA_WIDTH*2)-1:0] ALUResultE;

  wire [31:0] ReadDataW;
  wire [(DATA_WIDTH*2)-1:0] ALUOutW;
  wire [(DATA_WIDTH*2)-1:0] ResultW;

  wire [3:0] RA1D;
  wire [3:0] RA2D;
  wire [3:0] RA3D;
  wire [3:0] RA4D;

  wire [3:0] RA1E;
  wire [3:0] RA2E;
  wire [3:0] RA3E;
  wire [3:0] RA4E;

  // RA1 will be written after a pre-index memory op
  wire [3:0] RA1M;
  wire [3:0] RA1W;

  wire [7:0] WA3E;
  wire [7:0] WA3M;
  wire [7:0] WA3W;

  wire Match_1D_E;
  wire Match_2D_E;
  wire Match_3D_E;
  wire Match_4D_E;

  assign RA3D = InstrD[15:12];  // Passed to alu as RdLo for multiplications
  assign RA4D = InstrD[11:8];  // Passed to alu as RdHi/Ra for multiplications

  // Este multiplexor selecciona la dirección del primer registro fuente
  // para la etapa de decodificación, permitiendo elegir entre un valor
  // de la instrucción o un valor literal.
  mux2 #(
      .WIDTH(4)
  ) ra1_mux (
      .d0(InstrD[19:16]),  // Selección de bits de la instrucción
      .d1(4'b1111),        // 15
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
      .WIDTH(DATA_WIDTH)
  ) pc_next_mux (
      .d0(PCPlus4F),
      .d1(ResultW[DATA_WIDTH-1:0]),
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
      .d1(ALUResultE[31:0]),
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

  wire [1:0] RegSrcE;
  wire [1:0] RegSrcM;
  wire [1:0] RegSrcW;

  // Pass RegSrc to WriteBack stage
  registro_flanco_positivo #(
      .WIDTH(2)
  ) RegSrcMux_DE (
      .clk  (clk),      // Reloj del sistema
      .reset(reset),    // Señal de reinicio
      .d    (RegSrcD),  // Dato de entrada
      .q    (RegSrcE)   // Dato de salida
  );
  registro_flanco_positivo #(
      .WIDTH(2)
  ) RegSrcMux_EM (
      .clk  (clk),      // Reloj del sistema
      .reset(reset),    // Señal de reinicio
      .d    (RegSrcE),  // Dato de entrada
      .q    (RegSrcM)   // Dato de salida
  );
  registro_flanco_positivo #(
      .WIDTH(2)
  ) RegSrcMux_MW (
      .clk  (clk),      // Reloj del sistema
      .reset(reset),    // Señal de reinicio
      .d    (RegSrcM),  // Dato de entrada
      .q    (RegSrcW)   // Dato de salida
  );



  // BL Muxes

  wire [31:0] WD3_IN;
  mux2 #(
      .WIDTH(32)
  ) WD3_BL_MUX (
      .d0(ResultW[DATA_WIDTH-1:0]),
      .d1(PCPlus8W - 32'd4),
      .s (RegSrcW[0]),
      .y (WD3_IN)
  );

  wire [3:0] WA3_IN;
  mux2 #(
      .WIDTH(4)
  ) WA3W_BL_MUX (
      .d0(WA3W[3:0]),
      .d1(4'b1110),  // PC14
      .s(RegSrcW[0]),
      .y(WA3_IN)
  );


  regfile Registros (  //el registro de registros para ver los xregistros
      .clk(clk),  // Reloj del sistema
      .we3(RegWriteW),  // Señal de escritura
      .ra1(RA1D),  // Dirección del primer registro a leer
      .ra2(RA2D),  // Dirección del segundo registro a leer
      .ra3(RA3D),  // Dirección del tercer registro (LMUL)
      .ra4(RA4D),  // Dirección del cuarto registro (LMUL)

      .wa3(WA3_IN),  // Dirección del registro a escribir
      .wa3_2(WA3W[7:4]),  // Dirección del segundo registro a escribir (LMUL)
      .wd3(WD3_IN),  // Dato a escribir
      .wd3_2(ResultW[(DATA_WIDTH*2)-1:DATA_WIDTH]),  // Dato a escribir (LMUL)

      .r15(PCPlus8D),  // Valor del registro 15 (PC + 8)
      .rd1(rd1D),  // Salida del primer registro leído
      .rd2(rd2D),  // Salida del segundo registro leído
      .rd3(rd3D),  // Salida del 3er registro
      .rd4(rd4D)  // Salida del 4to registro
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

  registro_flanco_positivo #(
      .WIDTH(32)
  ) PC8_DE_reg (
      .clk  (clk),       // Reloj del sistema
      .reset(reset),     // Señal de reinicio
      .d    (PCPlus8D),  // Dato de entrada
      .q    (PCPlus8E)   // Dato de salida
  );
  registro_flanco_positivo #(
      .WIDTH(32)
  ) PC8_EM_reg (
      .clk  (clk),       // Reloj del sistema
      .reset(reset),     // Señal de reinicio
      .d    (PCPlus8E),  // Dato de entrada
      .q    (PCPlus8M)   // Dato de salida
  );
  registro_flanco_positivo #(
      .WIDTH(32)
  ) PC8_MW_reg (
      .clk  (clk),       // Reloj del sistema
      .reset(reset),     // Señal de reinicio
      .d    (PCPlus8M),  // Dato de entrada
      .q    (PCPlus8W)   // Dato de salida
  );


  registro_flanco_positivo #(
      .WIDTH(32)
  ) rd3_reg (
      .clk  (clk),    // Reloj del sistema
      .reset(reset),  // Señal de reinicio
      .d    (rd3D),   // Dato de entrada
      .q    (rd3E)    // Dato de salida
  );
  registro_flanco_positivo #(
      .WIDTH(32)
  ) rd4_reg (
      .clk  (clk),    // Reloj del sistema
      .reset(reset),  // Señal de reinicio
      .d    (rd4D),   // Dato de entrada
      .q    (rd4E)    // Dato de salida
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


  wire [7:0] pre_wa3e;
  // Este registro almacena la dirección del registro de destino en la etapa de decodificación
  // y la transfiere a la etapa de ejecución para determinar dónde escribir el resultado.
  registro_flanco_positivo #(
      .WIDTH(8)
  ) wa3e_reg (
      .clk  (clk),                            // Reloj del sistema
      .reset(reset),                          // Señal de reinicio
      .d    ({InstrD[11:8], InstrD[15:12]}),  // Dato de entrada
      .q    (pre_wa3e)                        // Dato de salida
  );
  assign WA3E = is_memory_strE ? {4'd0, RA1E} : is_memory_postE ? {RA1E, pre_wa3e[3:0]} : pre_wa3e;


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

  // Este registro almacena la dirección del tercer registro fuente en la etapa de decodificación
  // y la transfiere a la etapa de ejecución para el acceso a los datos.
  registro_flanco_positivo #(
      .WIDTH(4)
  ) ra3_reg (
      .clk  (clk),    // Reloj del sistema
      .reset(reset),  // Señal de reinicio
      .d    (RA3D),   // Dato de entrada
      .q    (RA3E)    // Dato de salida
  );
  // Este registro almacena la dirección del tercer registro fuente en la etapa de decodificación
  // y la transfiere a la etapa de ejecución para el acceso a los datos.
  registro_flanco_positivo #(
      .WIDTH(4)
  ) ra4_reg (
      .clk  (clk),    // Reloj del sistema
      .reset(reset),  // Señal de reinicio
      .d    (RA4D),   // Dato de entrada
      .q    (RA4E)    // Dato de salida
  );




  // Passes RA1 to the WriteBack stage
  registro_flanco_positivo #(
      .WIDTH(4)
  ) ra1_reg_EM (
      .clk  (clk),    // Reloj del sistema
      .reset(reset),  // Señal de reinicio
      .d    (RA1E),   // Dato de entrada
      .q    (RA1M)    // Dato de salida
  );
  registro_flanco_positivo #(
      .WIDTH(4)
  ) ra1_reg_MW (
      .clk  (clk),    // Reloj del sistema
      .reset(reset),  // Señal de reinicio
      .d    (RA1M),   // Dato de entrada
      .q    (RA1W)    // Dato de salida
  );


  // Forwarding/Bypassing: Utiliza multiplexores para redirigir los resultados
  // de la ALU y datos de escritura directamente a las instrucciones que los
  // requieren, evitando riesgos de datos en el pipeline.
  mux3 #(
      .WIDTH(32)
  ) by_pass1_mux (
      .d0(rd1E),
      .d1(ResultW[DATA_WIDTH-1:0]),
      .d2(ALUOutM[DATA_WIDTH-1:0]),
      .s (ForwardAE),
      .y (SrcAE)
  );

  wire [6:0] shift_bits;
  registro_flanco_positivo #(
      .WIDTH(7)
  ) shifter_reg_DE (
      .clk  (clk),           // Reloj del sistema
      .reset(reset),         // Señal de reinicio
      .d    (InstrD[11:5]),  // Dato de entrada
      .q    (shift_bits)     // Dato de salida
  );
  wire [DATA_WIDTH-1:0] rd2E_preshift;


  mux3 #(
      .WIDTH(32)
  ) by_pass2_mux (
      .d0(rd2E),
      .d1(ResultW[DATA_WIDTH-1:0]),
      .d2(ALUOutM[DATA_WIDTH-1:0]),
      .s (ForwardBE),
      .y (rd2E_preshift)
  );
  shifter rd2_shifter (
      .register_data (rd2E_preshift),
      .shifting_data (shift_bits),
      .shifted_result(WriteDataE)
  );

  mux3 #(
      .WIDTH(32)
  ) by_pass3_mux (
      .d0(rd3E),
      .d1(ResultW[DATA_WIDTH-1:0]),
      .d2(ALUOutM[DATA_WIDTH-1:0]),
      .s (ForwardCE),
      .y (SrcCE)
  );

  mux3 #(
      .WIDTH(32)
  ) by_pass4_mux (
      .d0(rd4E),
      .d1(ResultW[DATA_WIDTH-1:0]),
      .d2(ALUOutM[DATA_WIDTH-1:0]),
      .s (ForwardDE),
      .y (SrcDE)
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

  mux2 #(
      .WIDTH(32)
  ) mux_predictor (
      .d0(PCnext1F),
      .d1(ALUResultE[31:0]),
      .s (predict_taken),
      .y (PCnextF)
  );

  wire [(DATA_WIDTH*2)-1:0] ALUResultE_1;
  // ALU: Unidad Aritmética y Lógica que realiza operaciones aritméticas y lógicas
  alu ALU (
      .a(SrcAE),
      .b(SrcBE),
      .RdLo(SrcCE),
      .RdHi_Ra(SrcDE),
      .ALUControl(ALUControlE),
      .CarryIn(FlagsE[1]),
      .CBZRn(WriteDataE),
      .Result(ALUResultE_1),
      .ALUFlags(ALUFlagsE)
  );

  // if postindex, pass srcae
  assign ALUResultE = is_memory_postE ? {ALUResultE_1[DATA_WIDTH-1:0], SrcAE} : ALUResultE_1;


  // Este registro almacena el resultado de la ALU en la etapa de ejecución
  // y lo transfiere a la etapa de memoria para operaciones posteriores.
  registro_flanco_positivo #(
      .WIDTH(64)
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
      .WIDTH(8)
  ) wa3m_reg (
      .clk(clk),
      .reset(reset),
      .d(WA3E),
      .q(WA3M)
  );
  // Este registro almacena el resultado de la ALU desde la etapa de memoria
  // y lo transfiere a la etapa de escritura para su uso final.
  registro_flanco_positivo #(
      .WIDTH(64)
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
      .WIDTH(8)
  ) wa3w_reg (
      .clk(clk),
      .reset(reset),
      .d(WA3M),
      .q(WA3W)
  );

  assign ResultW = ~MemtoRegW ? ALUOutW : (is_memory_postW ? ( is_memory_strW? {32'dx, ALUOutW[(DATA_WIDTH*2)-1:DATA_WIDTH]} : {ALUOutW[(DATA_WIDTH*2)-1:DATA_WIDTH], ReadDataW}) : {ALUOutW[DATA_WIDTH-1:0], ReadDataW});


  // ALUSRC 1

  // Este comparador verifica si el registro de destino en la etapa de memoria
  // coincide con el primer registro fuente en la etapa de ejecución, para detectar
  // riesgos de datos.
  comparador_igualdad_doble #(
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
      .a(WA3_IN),
      .b(RA1E),
      .y(Match_1E_W)
  );

  // Este comparador verifica si el registro de destino en la etapa de ejecución
  // coincide con el primer registro fuente en la etapa de decodificación, para detectar
  // riesgos de datos.
  comparador_igualdad_doble #(
      .WIDTH(4)
  ) m4a (
      .a(WA3E),
      .b(RA1D),
      .y(Match_1D_E)
  );

  // ALUSRC 2

  // Este comparador verifica si el registro de destino en la etapa de memoria
  // coincide con el segundo registro fuente en la etapa de ejecución, para detectar
  // riesgos de datos.
  comparador_igualdad_doble #(
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
      .a(WA3_IN),
      .b(RA2E),
      .y(Match_2E_W)
  );

  // Este comparador verifica si el registro de destino en la etapa de ejecución
  // coincide con el segundo registro fuente en la etapa de decodificación, para detectar
  // riesgos de datos.
  comparador_igualdad_doble #(
      .WIDTH(4)
  ) m4b (
      .a(WA3E),
      .b(RA2D),
      .y(Match_2D_E)
  );

  // ALUSRC 3

  // Este comparador verifica si el registro de destino en la etapa de memoria
  // coincide con el primer registro fuente en la etapa de ejecución, para detectar
  // riesgos de datos.
  comparador_igualdad_doble #(
      .WIDTH(4)
  ) src3_comparator_MEM (
      .a(WA3M),
      .b(RA3E),
      .y(Match_3E_M)
  );
  // Este comparador verifica si el registro de destino en la etapa de escritura
  // coincide con el primer registro fuente en la etapa de ejecución, para detectar
  // riesgos de datos.
  comparador_igualdad #(
      .WIDTH(4)
  ) src3_comparator_WR (
      .a(WA3_IN),
      .b(RA3E),
      .y(Match_3E_W)
  );

  // Este comparador verifica si el registro de destino en la etapa de ejecución
  // coincide con el primer registro fuente en la etapa de decodificación, para detectar
  // riesgos de datos.
  comparador_igualdad_doble #(
      .WIDTH(4)
  ) src3_comparator_EX (
      .a(WA3E),
      .b(RA3D),
      .y(Match_3D_E)
  );

  // ALUSRC 4

  // Este comparador verifica si el registro de destino en la etapa de memoria
  // coincide con el primer registro fuente en la etapa de ejecución, para detectar
  // riesgos de datos.
  comparador_igualdad_doble #(
      .WIDTH(4)
  ) src4_comparator_MEM (
      .a(WA3M),
      .b(RA4E),
      .y(Match_4E_M)
  );
  // Este comparador verifica si el registro de destino en la etapa de escritura
  // coincide con el primer registro fuente en la etapa de ejecución, para detectar
  // riesgos de datos.
  comparador_igualdad #(
      .WIDTH(4)
  ) src4_comparator_WR (
      .a(WA3_IN),
      .b(RA4E),
      .y(Match_4E_W)
  );

  // Este comparador verifica si el registro de destino en la etapa de ejecución
  // coincide con el primer registro fuente en la etapa de decodificación, para detectar
  // riesgos de datos.
  comparador_igualdad_doble #(
      .WIDTH(4)
  ) src4_comparator_EX (
      .a(WA3E),
      .b(RA4D),
      .y(Match_4D_E)
  );


  // Esta asignación lógica combina las coincidencias de los registros fuente
  // en la etapa de decodificación con el registro de destino en la etapa de ejecución.
  assign Match_12D_E = Match_1D_E | Match_2D_E | Match_3D_E | Match_4D_E;

endmodule
