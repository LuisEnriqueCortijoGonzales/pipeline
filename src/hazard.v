module hazardUnit (
    clk,  // Señal de reloj
    reset,  // Señal de reinicio
    Match_1E_M, // Coincidencia entre el registro de destino en la etapa E y el registro fuente en la etapa M
    Match_1E_W, // Coincidencia entre el registro de destino en la etapa E y el registro fuente en la etapa W
    Match_2E_M, // Coincidencia entre el segundo registro de destino en la etapa E y el registro fuente en la etapa M
    Match_2E_W, // Coincidencia entre el segundo registro de destino en la etapa E y el registro fuente en la etapa W
    Match_3E_M, // Coincidencia entre el tercer registro de destino en la etapa E y el registro fuente en la etapa M
    Match_3E_W, // Coincidencia entre el tercer registro de destino en la etapa E y el registro fuente en la etapa W
    Match_12D_E, // Coincidencia entre los registros fuente en la etapa D y el registro de destino en la etapa E
    RegWriteM,  // Señal de escritura de registro en la etapa M
    RegWriteW,  // Señal de escritura de registro en la etapa W
    BranchTakenE,  // Indica si se toma una rama en la etapa E
    MemtoRegE,  // Indica si la instrucción en la etapa E es una carga desde memoria
    PCWrPendingF,  // Indica si hay una escritura pendiente en el contador de programa
    PCSrcW,  // Indica la fuente del contador de programa en la etapa W
    ForwardAE,  // Señal de reenvío para el primer operando en la etapa E
    ForwardBE,  // Señal de reenvío para el segundo operando en la etapa E
    ForwardCE,  // Señal de reenvío para el tercer operando en la etapa E (used in multiply operations)
    StallF,  // Señal para detener la etapa F
    StallD,  // Señal para detener la etapa D
    FlushD,  // Señal para limpiar la etapa D
    FlushE  // Señal para limpiar la etapa E
);

  input wire clk;
  input wire reset;

  input wire Match_1E_M;
  input wire Match_1E_W;
  input wire Match_2E_M;
  input wire Match_2E_W;
  input wire Match_3E_M;
  input wire Match_3E_W;
  input wire Match_12D_E;

  input wire RegWriteM;
  input wire RegWriteW;
  input wire BranchTakenE;
  input wire MemtoRegE;
  input wire PCWrPendingF;
  input wire PCSrcW;

  output reg [1:0] ForwardAE;
  output reg [1:0] ForwardBE;
  output reg [1:0] ForwardCE;

  wire ldrStallD;  // Señal interna para detectar un stall debido a una carga

  output wire StallF;
  output wire StallD;
  output wire FlushD;
  output wire FlushE;

  // El Hazard Unit detecta y maneja riesgos en un procesador pipelined.
  // Los riesgos de datos ocurren cuando una instrucción necesita un resultado
  // que aún no ha sido escrito en el archivo de registros.
  // Los riesgos de control ocurren cuando no se ha decidido qué instrucción
  // buscar a continuación.

  // Reenvío: Soluciona algunos riesgos de datos reenviando resultados
  // desde las etapas de Memoria o Escritura a la instrucción dependiente.


  reg temp;  // Variable local para el control
  always @(*) begin

    // Reenvío para el primer operando en la etapa E
    if (Match_1E_M & RegWriteM) ForwardAE = 2'b10;  // Desde la etapa M
    else if (Match_1E_W & RegWriteW) ForwardAE = 2'b01;  // Desde la etapa W
    else ForwardAE = 2'b00;  // Desde el archivo de registros

    // Reenvío para el segundo operando en la etapa E
    if (Match_2E_M & RegWriteM) ForwardBE = 2'b10;  // Desde la etapa M
    else if (Match_2E_W & RegWriteW) ForwardBE = 2'b01;  // Desde la etapa W
    else ForwardBE = 2'b00;  // Desde el archivo de registros

    // Reenvío para el tercer operando en la etapa E (usado en operaciones de multiplicación)
    if (Match_3E_M & RegWriteM) ForwardCE = 2'b10;  // Desde la etapa M
    else if (Match_3E_W & RegWriteW) ForwardCE = 2'b01;  // Desde la etapa W
    else ForwardCE = 2'b00;  // Desde el archivo de registros


  end

  // Stall: Detiene el pipeline cuando el reenvío no es suficiente,
  // especialmente para instrucciones de carga que tienen latencia.
  assign ldrStallD = Match_12D_E & MemtoRegE;

  // Detener la etapa D si hay un stall debido a una carga
  assign StallD = ldrStallD;

  // Detener la etapa F si hay un stall o una escritura pendiente en el PC
  assign StallF = ldrStallD | PCWrPendingF;

  // Limpiar la etapa E si hay un stall o se toma una rama
  assign FlushE = ldrStallD | BranchTakenE;

  // Limpiar la etapa D si hay una escritura pendiente en el PC o se toma una rama
  assign FlushD = (PCWrPendingF | PCSrcW) | BranchTakenE;

  // Inicializa el registro interno
  initial temp = 0;
endmodule
