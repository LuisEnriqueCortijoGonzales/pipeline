module hazardUnit (
    input wire clk,
    input wire reset,

    // Coincidencias entre los registros de destino de la etapa E y los registro fuente en la etapa M/W

    input wire Match_1E_M,
    input wire Match_1E_W,
    input wire Match_2E_M,
    input wire Match_2E_W,
    input wire Match_3E_M,
    input wire Match_3E_W,
    input wire Match_4E_M,
    input wire Match_4E_W,

    // Coincidencia entre cualquiera de los registros fuente en la etapa D y el registro de destino en la etapa E
    input wire Match_12D_E,


    // Señales de escritura de registro
    input wire [1:0] RegWriteM,
    input wire [1:0] RegWriteW,

    // Indica si se toma una rama en la etapa E
    input wire BranchTakenE,

    // Indica si la instrucción en la etapa E es una carga desde memoria
    input wire MemtoRegE,

    // Indica si hay una escritura pendiente en el contador de programa
    input wire PCWrPendingF,

    // Señal de reenvío para los operandos en la etapa E, para saber si se reenvía desde M o W.
    output reg [1:0] ForwardAE,
    output reg [1:0] ForwardBE,
    output reg [1:0] ForwardCE,
    output reg [1:0] ForwardDE,

    // Detencion de ejecucion
    output wire StallF,
    output wire StallD,

    // Limpieza de etapas
    output wire FlushD,
    output wire FlushE,

    input wire WrongPredictionE

);




  wire ldrStallD;  // Señal interna para detectar un stall debido a una carga


  // El Hazard Unit detecta y maneja riesgos en un procesador pipelined.
  // Los riesgos de datos ocurren cuando una instrucción necesita un resultado
  // que aún no ha sido escrito en el archivo de registros.
  // Los riesgos de control ocurren cuando no se ha decidido qué instrucción
  // buscar a continuación.

  // Reenvío: Soluciona algunos riesgos de datos reenviando resultados
  // desde las etapas de Memoria o Escritura a la instrucción dependiente.


  reg  temp;  // Variable local para el control
  always @(*) begin

    // Reenvío para el primer operando en la etapa E
    if (Match_1E_M & RegWriteM[0]) ForwardAE = 2'b10;  // Desde la etapa M
    else if (Match_1E_W & RegWriteW[0]) ForwardAE = 2'b01;  // Desde la etapa W
    else ForwardAE = 2'b00;  // Desde el archivo de registros

    // Reenvío para el segundo operando en la etapa E
    if (Match_2E_M & RegWriteM[0]) ForwardBE = 2'b10;  // Desde la etapa M
    else if (Match_2E_W & RegWriteW[0]) ForwardBE = 2'b01;  // Desde la etapa W
    else ForwardBE = 2'b00;  // Desde el archivo de registros

    // Reenvío para el tercer operando en la etapa E (usado en operaciones de multiplicación)
    if (Match_3E_M & RegWriteM[0]) ForwardCE = 2'b10;  // Desde la etapa M
    else if (Match_3E_W & RegWriteW[0]) ForwardCE = 2'b01;  // Desde la etapa W
    else ForwardCE = 2'b00;  // Desde el archivo de registros

    // Reenvío para el cuarto operando en la etapa E (usado en operaciones de multiplicación)
    if (Match_4E_M & RegWriteM[0]) ForwardDE = 2'b10;  // Desde la etapa M
    else if (Match_4E_W & RegWriteW[0]) ForwardDE = 2'b01;  // Desde la etapa W
    else ForwardDE = 2'b00;  // Desde el archivo de registros


  end

  // Stall: Detiene el pipeline cuando el reenvío no es suficiente,
  // especialmente para instrucciones de carga que tienen latencia.
  assign ldrStallD = Match_12D_E & MemtoRegE;

  // Detener la etapa D si hay un stall debido a una carga
  assign StallD = ldrStallD;

  // Detener la etapa F si hay un stall o una escritura pendiente en el PC
  // TODO: possible wrong value propagation
  assign StallF = ldrStallD;

  // Limpiar la etapa E si hay un stall o se toma una rama
  assign FlushE = ldrStallD | WrongPredictionE;

  // Limpiar la etapa D si hay una escritura pendiente en el PC o se toma una rama
  // TODO: possible wrong value propagation
  assign FlushD = WrongPredictionE;

  // Inicializa el registro interno
  initial temp = 0;
endmodule
