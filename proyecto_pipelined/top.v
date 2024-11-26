module top (
    input wire clk,
    input wire reset,
    output wire [31:0] WriteDataM,
    output wire [31:0] DataAdrM,
    output wire MemWriteM
);

  // El módulo 'top' es el punto de entrada principal del procesador pipelined.
  // Recibe señales de reloj (clk) y de reinicio (reset) y produce señales de salida
  // relacionadas con la memoria de datos.
  // Cables intermedios que conectan la memoria de instrucciones y la memoria de datos

  wire [31:0] PCF;  // Contador de programa (Program Counter)
  wire [31:0] InstrF;  // Instrucción actual
  wire [31:0] ReadDataM;  // Datos leídos de la memoria

  // Instancia del módulo 'arm', que representa el núcleo del procesador.
  // Este módulo maneja la ejecución de instrucciones y la interacción con la memoria.

  arm arm (
      .clk(clk),
      .reset(reset),
      .PCF(PCF),
      .InstrF(InstrF),
      .MemWriteM(MemWriteM),
      .ALUOutM(DataAdrM),
      .WriteDataM(WriteDataM),
      .ReadDataM(ReadDataM)
  );

  // Memoria de instrucciones: almacena las instrucciones que el procesador ejecutará.

  // 'PCF' es la dirección de la instrucción actual, y 'InstrF' es la instrucción leída.

  InstructionMemory InstrMem (
      .address(PCF),
      .instruction(InstrF)
  );

  // Memoria de datos: almacena los datos que el procesador lee y escribe.
  // 'DataAdrM' es la dirección de memoria, 'WriteDataM' son los datos a escribir,
  // y 'ReadDataM' son los datos leídos de la memoria.

  DataMemory DataMem (
      .clk(clk),
      .we(MemWriteM),
      .address(DataAdrM),
      .write_data(WriteDataM),
      .read_data(ReadDataM)
  );
endmodule