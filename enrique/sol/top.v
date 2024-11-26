module top (
    clk,
    reset,
    WriteDataM,
    DataAdrM,
    MemWriteM
);
  input wire clk;
  input wire reset;
  output wire [31:0] WriteDataM;
  output wire [31:0] DataAdrM;
  output wire MemWriteM;
  wire [31:0] PCF;
  wire [31:0] InstrF;
  wire [31:0] ReadDataM;
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
  imem imem (
      .a (PCF),
      .rd(InstrF)
  );
  dmem dmem (
      .clk(clk),
      .we (MemWriteM),
      .a  (DataAdrM),
      .wd (WriteDataM),
      .rd (ReadDataM)
  );
endmodule