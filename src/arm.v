module arm (
    input wire clk,
    input wire reset,
    output wire [31:0] PCF,
    input wire [31:0] InstrF,
    output wire MemWriteM,
    output wire [(DATA_WIDTH*2)-1:0] ALUOutM,
    output wire [31:0] WriteDataM,
    input wire [31:0] ReadDataM
);
  localparam ALUCONTROL_WIDTH = 6;
  localparam ALU_FLAGS_WIDTH = 5;
  parameter DATA_WIDTH = 32;

  wire [1:0] RegSrcD;
  wire [1:0] ImmSrcD;
  wire [ALUCONTROL_WIDTH-1:0] ALUControlE;
  wire ALUSrcE;
  wire BranchTakenE;
  wire MemtoRegW;
  wire PCSrcW;
  wire [1:0] RegWriteW;
  wire [ALU_FLAGS_WIDTH-1:0] ALUFlagsE;
  wire [31:0] InstrD;
  wire [1:0] RegWriteM;
  wire MemtoRegE;
  wire PCWrPendingF;
  wire [1:0] ForwardAE;
  wire [1:0] ForwardBE;
  wire [1:0] ForwardCE;
  wire [1:0] ForwardDE;
  wire StallF;
  wire StallD;
  wire FlushD;
  wire FlushE;
  wire Match_1E_M;
  wire Match_1E_W;
  wire Match_2E_M;
  wire Match_2E_W;
  wire Match_3E_M;
  wire Match_3E_W;
  wire Match_4E_M;
  wire Match_4E_W;
  wire Match_12D_E;
  wire branch;
  wire taken;
  wire predict_taken;


  wire [ALU_FLAGS_WIDTH-1:0] FlagsE;

  controller Control_unit (
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
      .FlushE(FlushE),
      .FlagsE(FlagsE)


  );


  datapath Data_path (
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
      .FlagsE(FlagsE),
      .Match_1E_M(Match_1E_M),
      .Match_1E_W(Match_1E_W),
      .Match_2E_M(Match_2E_M),
      .Match_2E_W(Match_2E_W),
      .Match_3E_M(Match_3E_M),
      .Match_3E_W(Match_3E_W),
      .Match_4E_M(Match_4E_M),
      .Match_4E_W(Match_4E_W),
      .Match_12D_E(Match_12D_E),
      .ForwardAE(ForwardAE),
      .ForwardBE(ForwardBE),
      .ForwardCE(ForwardCE),
      .ForwardDE(ForwardDE),
      .StallF(StallF),
      .StallD(StallD),
      .FlushD(FlushD),
      .predict_taken(predict_taken)
  );


  // Unidad de Hazard: Detecta dependencias de datos y genera señales de control
  // para evitar conflictos en el pipeline. Maneja riesgos de datos y controla
  // el forwarding y el stalling de instrucciones.
  hazardUnit Hazard_unit (
      .clk(clk),
      .reset(reset),
      .Match_1E_M(Match_1E_M),
      .Match_1E_W(Match_1E_W),
      .Match_2E_M(Match_2E_M),
      .Match_2E_W(Match_2E_W),
      .Match_3E_M(Match_3E_M),
      .Match_3E_W(Match_3E_W),
      .Match_4E_M(Match_4E_M),
      .Match_4E_W(Match_4E_W),
      .Match_12D_E(Match_12D_E),
      .RegWriteM(RegWriteM),
      .RegWriteW(RegWriteW),
      .BranchTakenE(BranchTakenE),
      .MemtoRegE(MemtoRegE),
      .PCWrPendingF(PCWrPendingF),
      .PCSrcW(PCSrcW),
      .ForwardAE(ForwardAE),
      .ForwardBE(ForwardBE),
      .ForwardCE(ForwardCE),
      .ForwardDE(ForwardDE),
      .StallF(StallF),
      .StallD(StallD),
      .FlushD(FlushD),
      .FlushE(FlushE)
  );

  branch_predictor bp (
      .clk(clk),
      .reset(reset),
      .branch(branch),
      .taken(taken),
      .predict_taken(predict_taken)
  );

  // i fucking hate u
  // assign PCSrcW = predict_taken;

endmodule
