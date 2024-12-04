module top (
    input wire clk,
    input wire reset,
    output wire [6:0] seg,
    output wire [3:0] an
);
  parameter DATA_WIDTH = 32;

  localparam MEMFILE = "memfile.mem.dat";
  localparam USE_HARDCODED = 1;

  wire [(DATA_WIDTH*2)-1:0] DataAdrM;
  wire [31:0] WriteDataM;
  wire MemWriteM;

  // El módulo 'top' es el punto de entrada principal del procesador pipelined.
  // Recibe señales de reloj (clk) y de reinicio (reset) y produce señales de salida
  // relacionadas con la memoria de datos.
  // Cables intermedios que conectan la memoria de instrucciones y la memoria de datos

  wire [31:0] PCF;  // Contador de programa (Program Counter)
  wire [31:0] InstrF;  // Instrucción actual
  wire [31:0] ReadDataM;  // Datos leídos de la memoria


  wire [31:0] R0;
  wire [31:0] R1;

  // Instancia del divisor de reloj
wire slow_clk1;
  clock_divider1 clk_div1 (
      .reset  (reset),
      .clk_in (clk),
      .clk_out(slow_clk1)
  );
  wire slow_clk;
  clock_divider clk_div (
      .reset  (reset),
      .clk_in (clk),
      .clk_out(slow_clk)
  );

  // Instancia del módulo 'arm', que representa el núcleo del procesador.
  // Este módulo maneja la ejecución de instrucciones y la interacción con la memoria.

  arm arm (
      .clk(slow_clk),
      .reset(reset),
      .PCF(PCF),
      .InstrF(InstrF),
      .MemWriteM(MemWriteM),
      .ALUOutM(DataAdrM),
      .WriteDataM(WriteDataM),
      .ReadDataM(ReadDataM),
      .R0(R0),
      .R1(R1)
  );

  // Memoria de instrucciones: almacena las instrucciones que el procesador ejecutará.

  // 'PCF' es la dirección de la instrucción actual, y 'InstrF' es la instrucción leída.

  InstructionMemory #(
      .MEMFILE(MEMFILE),
      .USE_HARDCODED(USE_HARDCODED)
  ) InstrMem (
      .address(PCF),
      .instruction(InstrF)
  );

  // Memoria de datos: almacena los datos que el procesador lee y escribe.
  // 'DataAdrM' es la dirección de memoria, 'WriteDataM' son los datos a escribir,
  // y 'ReadDataM' son los datos leídos de la memoria.

  DataMemory #(
      .MEMFILE(MEMFILE),
      .USE_HARDCODED(USE_HARDCODED)
  ) DataMem (
      .clk(slow_clk),
      .we(MemWriteM),
      .address(DataAdrM[DATA_WIDTH-1:0]),
      .write_data(WriteDataM),
      .read_data(ReadDataM)
  );

  display_controller display (
      .clk(slow_clk1),  // Usa el reloj original para el multiplexado rápido
      .R0(R0),  // Conecta R0
      .R1(R1),  // Conecta R1
      .seg(seg),
      .an(an)
  );



endmodule