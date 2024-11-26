module arm (
    clk,
    reset,
    PCF,
    InstrF,
    MemWriteM,
    ALUOutM,
    WriteDataM,
    ReadDataM
);
  input wire clk;
  input wire reset;
  output wire [31:0] PCF;
  input wire [31:0] InstrF;
  output wire MemWriteM;
  output wire [31:0] ALUOutM;
  output wire [31:0] WriteDataM;
  input wire [31:0] ReadDataM;
  wire [1:0] RegSrcD;
  wire [1:0] ImmSrcD;
  wire [1:0] ALUControlE;
  wire ALUSrcE;
  wire BranchTakenE;
  wire MemtoRegW;
  wire PCSrcW;
  wire RegWriteW;
  wire [3:0] ALUFlagsE;
  wire [31:0] InstrD;
  wire RegWriteM;
  wire MemtoRegE;
  wire PCWrPendingF;
  wire [1:0] ForwardAE;
  wire [1:0] ForwardBE;
  wire StallF;
  wire StallD;
  wire FlushD;
  wire FlushE;
  wire Match_1E_M;
  wire Match_1E_W;
  wire Match_2E_M;
  wire Match_2E_W;
  wire Match_12D_E;
  controller c (
      .clk(clk),
      .reset(reset),
      .InstrD(InstrD[31:12]),
      .ALUFlagsE(ALUFlagsE),
      .RegSrcD(RegSrcD),
      .ImmSrcD(ImmSrcD),
      .ALUSrcE(ALUSrcE),
      .BranchTakenE(BranchTakenE),
      .ALUControlE(ALUControlE),
      .MemWriteM(MemWriteM),
      .MemtoRegW(MemtoRegW),
      .PCSrcW(PCSrcW),
      .RegWriteW(RegWriteW),
      .RegWriteM(RegWriteM),
      .MemtoRegE(MemtoRegE),
      .PCWrPendingF(PCWrPendingF),
      .FlushE(FlushE)
  );
  datapath dp (
      .clk(clk),
      .reset(reset),
      .RegSrcD(RegSrcD),
      .ImmSrcD(ImmSrcD),
      .ALUSrcE(ALUSrcE),
      .BranchTakenE(BranchTakenE),
      .ALUControlE(ALUControlE),
      .MemtoRegW(MemtoRegW),
      .PCSrcW(PCSrcW),
      .RegWriteW(RegWriteW),
      .PCF(PCF),
      .InstrF(InstrF),
      .InstrD(InstrD),
      .ALUOutM(ALUOutM),
      .WriteDataM(WriteDataM),
      .ReadDataM(ReadDataM),
      .ALUFlagsE(ALUFlagsE),
      .Match_1E_M(Match_1E_M),
      .Match_1E_W(Match_1E_W),
      .Match_2E_M(Match_2E_M),
      .Match_2E_W(Match_2E_W),
      .Match_12D_E(Match_12D_E),
      .ForwardAE(ForwardAE),
      .ForwardBE(ForwardBE),
      .StallF(StallF),
      .StallD(StallD),
      .FlushD(FlushD)
  );
  hazard h (
      .clk(clk),
      .reset(reset),
      .Match_1E_M(Match_1E_M),
      .Match_1E_W(Match_1E_W),
      .Match_2E_M(Match_2E_M),
      .Match_2E_W(Match_2E_W),
      .Match_12D_E(Match_12D_E),
      .RegWriteM(RegWriteM),
      .RegWriteW(RegWriteW),
      .BranchTakenE(BranchTakenE),
      .MemtoRegE(MemtoRegE),
      .PCWrPendingF(PCWrPendingF),
      .PCSrcW(PCSrcW),
      .ForwardAE(ForwardAE),
      .ForwardBE(ForwardBE),
      .StallF(StallF),
      .StallD(StallD),
      .FlushD(FlushD),
      .FlushE(FlushE)
  );
endmodule