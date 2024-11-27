module controller (
    input wire clk,
    input wire reset,
    input wire [31:12] InstrD,
    input wire [3:0] ALUFlagsE,
    output wire [1:0] RegSrcD,
    output wire [1:0] ImmSrcD,
    output wire ALUSrcE,
    output wire BranchTakenE,
    output wire [ALUCONTROL_WIDTH-1:0] ALUControlE,
    output wire MemWriteM,
    output wire MemtoRegW,
    output wire PCSrcW,
    output wire RegWriteW,
    output wire RegWriteM,
    output wire MemtoRegE,
    output wire PCWrPendingF,
    input wire FlushE
);
  parameter ALUCONTROL_WIDTH = 5;

  reg [9:0] controlsD;
  wire CondExE;
  wire ALUOpD;
  reg [ALUCONTROL_WIDTH-1:0] ALUControlD;
  wire ALUSrcD;
  wire MemtoRegD;
  wire MemtoRegM;
  wire RegWriteD;
  wire RegWriteE;
  wire RegWriteGatedE;
  wire MemWriteD;
  wire MemWriteE;
  wire MemWriteGatedE;
  wire BranchD;
  wire BranchE;
  reg [1:0] FlagWriteD;
  wire [1:0] FlagWriteE;
  wire PCSrcD;
  wire PCSrcE;
  wire PCSrcM;
  wire [3:0] FlagsE;
  wire [3:0] FlagsNextE;
  wire [3:0] CondE;

  always @(*) begin
    casex (InstrD[27:26])
      2'b00:   if (InstrD[25]) controlsD = 10'b0000101001;
 else controlsD = 10'b0000001001;
      2'b01:   if (InstrD[20]) controlsD = 10'b0001111000;
 else controlsD = 10'b1001110100;
      2'b10:   controlsD = 10'b0110100010;
      default: controlsD = 10'bxxxxxxxxxx;
    endcase
  end
  assign {RegSrcD, ImmSrcD, ALUSrcD, MemtoRegD, RegWriteD, MemWriteD, BranchD, ALUOpD} = controlsD;
  always @(*) begin
    if (ALUOpD) begin
      case (InstrD[24:21])
        4'b0100: ALUControlD = 5'b00000;
        4'b0010: ALUControlD = 5'b01000;
        4'b0000: ALUControlD = 5'b10000;
        4'b1100: ALUControlD = 5'b11000;
        default: ALUControlD = 5'bxxxxx;
      endcase
      FlagWriteD[1] = InstrD[20];
      FlagWriteD[0] = InstrD[20] & ((ALUControlD == 5'b0000) | (ALUControlD == 5'b0100));
    end else begin
      ALUControlD = 5'b00000;
      FlagWriteD  = 4'b0000;
    end
  end
  assign PCSrcD = ((InstrD[15:12] == 4'b1111) & RegWriteD) | BranchD;

  registro_flanco_positivo_habilitacion_limpieza #(
      .WIDTH(7)
  ) flushedregsE (
      .clk(clk),
      .reset(reset),
      .en(1'b1),
      .clear(FlushE),
      .d({FlagWriteD, BranchD, MemWriteD, RegWriteD, PCSrcD, MemtoRegD}),
      .q({FlagWriteE, BranchE, MemWriteE, RegWriteE, PCSrcE, MemtoRegE})
  );
  registro_flanco_positivo #(
      .WIDTH(ALUCONTROL_WIDTH + 1)
  ) regsE (
      .clk(clk),
      .reset(reset),
      .d({ALUSrcD, ALUControlD}),
      .q({ALUSrcE, ALUControlE})
  );
  registro_flanco_positivo #(
      .WIDTH(4)
  ) condregE (
      .clk(clk),
      .reset(reset),
      .d(InstrD[31:28]),
      .q(CondE)
  );
  registro_flanco_positivo #(
      .WIDTH(4)
  ) flagsreg (
      .clk(clk),
      .reset(reset),
      .d(FlagsNextE),
      .q(FlagsE)
  );
  conditional Cond (
      .Cond(CondE),
      .Flags(FlagsE),
      .ALUFlags(ALUFlagsE),
      .FlagsWrite(FlagWriteE),
      .CondEx(CondExE),
      .FlagsNext(FlagsNextE)
  );
  // Branch Predictor: Determina si una rama debe tomarse basándose en la
  // condición evaluada en la etapa de ejecución, mejorando la precisión de
  // predicción y reduciendo el número de instrucciones incorrectas en el pipeline.
  assign BranchTakenE   = BranchE & CondExE;
  assign RegWriteGatedE = RegWriteE & CondExE;
  assign MemWriteGatedE = MemWriteE & CondExE;
  wire PCSrcGatedE;
  assign PCSrcGatedE = PCSrcE & CondExE;
  registro_flanco_positivo #(
      .WIDTH(4)
  ) regs_M (
      .clk(clk),
      .reset(reset),
      .d({MemWriteGatedE, MemtoRegE, RegWriteGatedE, PCSrcGatedE}),
      .q({MemWriteM, MemtoRegM, RegWriteM, PCSrcM})
  );
  registro_flanco_positivo #(
      .WIDTH(3)
  ) regs_W (
      .clk(clk),
      .reset(reset),
      .d({MemtoRegM, RegWriteM, PCSrcM}),
      .q({MemtoRegW, RegWriteW, PCSrcW})
  );
  assign PCWrPendingF = (PCSrcD | PCSrcE) | PCSrcM;
endmodule
