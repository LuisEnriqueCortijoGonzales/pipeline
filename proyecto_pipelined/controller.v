module controller (input wire clk, input wire reset, input wire [31:12] InstrD, input wire [3:0] ALUFlagsE, output wire [1:0] RegSrcD,
output wire [1:0] ImmSrcD, output wire ALUSrcE, output wire BranchTakenE, output wire [1:0] ALUControlE, output wire MemWriteM, output wire MemtoRegW,
output wire PCSrcW, output wire RegWriteW, output wire RegWriteM, output wire MemtoRegE, output wire PCWrPendingF, input wire FlushE);

  reg _sv2v_0;
  reg [9:0] controlsD;
  wire CondExE;
  wire ALUOpD;
  reg [1:0] ALUControlD;
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
    if (_sv2v_0);
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
    if (_sv2v_0);
    if (ALUOpD) begin
      case (InstrD[24:21])
        4'b0100: ALUControlD = 2'b00;
        4'b0010: ALUControlD = 2'b01;
        4'b0000: ALUControlD = 2'b10;
        4'b1100: ALUControlD = 2'b11;
        default: ALUControlD = 2'bxx;
      endcase
      FlagWriteD[1] = InstrD[20];
      FlagWriteD[0] = InstrD[20] & ((ALUControlD == 2'b00) | (ALUControlD == 2'b01));
    end else begin
      ALUControlD = 2'b00;
      FlagWriteD  = 2'b00;
    end
  end
  assign PCSrcD = ((InstrD[15:12] == 4'b1111) & RegWriteD) | BranchD;
  floprc #(
      .WIDTH(7)
  ) flushedregsE (
      .clk(clk),
      .reset(reset),
      .clear(FlushE),
      .d({FlagWriteD, BranchD, MemWriteD, RegWriteD, PCSrcD, MemtoRegD}),
      .q({FlagWriteE, BranchE, MemWriteE, RegWriteE, PCSrcE, MemtoRegE})
  );
  flopr #(
      .WIDTH(3)
  ) regsE (
      .clk(clk),
      .reset(reset),
      .d({ALUSrcD, ALUControlD}),
      .q({ALUSrcE, ALUControlE})
  );
  flopr #(
      .WIDTH(4)
  ) condregE (
      .clk(clk),
      .reset(reset),
      .d(InstrD[31:28]),
      .q(CondE)
  );
  flopr #(
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
  assign BranchTakenE   = BranchE & CondExE;
  assign RegWriteGatedE = RegWriteE & CondExE;
  assign MemWriteGatedE = MemWriteE & CondExE;
  wire PCSrcGatedE;
  assign PCSrcGatedE = PCSrcE & CondExE;
  flopr #(
      .WIDTH(4)
  ) regsM (
      .clk(clk),
      .reset(reset),
      .d({MemWriteGatedE, MemtoRegE, RegWriteGatedE, PCSrcGatedE}),
      .q({MemWriteM, MemtoRegM, RegWriteM, PCSrcM})
  );
  flopr #(
      .WIDTH(3)
  ) regsW (
      .clk(clk),
      .reset(reset),
      .d({MemtoRegM, RegWriteM, PCSrcM}),
      .q({MemtoRegW, RegWriteW, PCSrcW})
  );
  assign PCWrPendingF = (PCSrcD | PCSrcE) | PCSrcM;
  initial _sv2v_0 = 0;
endmodule