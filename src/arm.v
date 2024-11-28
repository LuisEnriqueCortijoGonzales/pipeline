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
  localparam ALUCONTROL_WIDTH = 5;
  localparam ALU_FLAGS_WIDTH = 5;
  parameter DATA_WIDTH = 32;

  wire [1:0] RegSrcD;
  wire [1:0] ImmSrcD;
  wire [ALUCONTROL_WIDTH-1:0] ALUControlE;
  wire ALUSrcE;
  wire BranchTakenE;
  wire MemtoRegW;
  wire PCSrcW;
  wire RegWriteW;
  wire [ALU_FLAGS_WIDTH-1:0] ALUFlagsE;
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
  wire branch;
  wire taken;
  wire predict_taken;

  wire CarryE;

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
      .CarryE(CarryE),
      .MemWriteM(MemWriteM),
      .MemtoRegW(MemtoRegW),
      .PCSrcW(PCSrcW),
      .RegWriteW(RegWriteW),
      .RegWriteM(RegWriteM),
      .MemtoRegE(MemtoRegE),
      .PCWrPendingF(PCWrPendingF),
      .FlushE(FlushE)
  );


  datapath Data_path (
      .clk(clk),
      .reset(reset),
      .RegSrcD(RegSrcD),
      .ImmSrcD(ImmSrcD),
      .ALUSrcE(ALUSrcE),
      .BranchTakenE(BranchTakenE),
      .ALUControlE(ALUControlE),
      .CarryE(CarryE),
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

  branch_predictor bp (
        .clk(clk),
        .reset(reset),
        .branch(branch),
        .taken(taken),
        .predict_taken(predict_taken)
    );
    assign PCSrcW = predict_taken;

endmodule