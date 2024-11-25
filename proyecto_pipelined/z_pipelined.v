module top (input wire clk, input wire reset, output wire [31:0] WriteDataM, 
output wire [31:0] DataAdrM, output wire MemWriteM);
//el clock y reset de toda la vida  
  //los datos de salida
  //usamos el sufijo M como indica el libro para diferenciar las variables de memoria entre los registros
  //los cables intermedios que van tanto a InstructionMemory como a DataMemory
  wire [31:0] PCF;
  wire [31:0] InstrF;
  wire [31:0] ReadDataM;
  arm arm (.clk(clk), .reset(reset), .PC(PC), .InstrF(InstrF), .MemWriteM(MemWriteM), .ALUOutM(DataAdrM),
      .WriteDataM(WriteDataM), .ReadDataM(ReadDataM));
//la memoria de instrucciones
  InstructionMemory imem (.address (PCF), .instruction(InstrF));
  //la memoria de datos
  DataMemory dmem (.clk(clk), .we (MemWriteM), .address  (DataAdrM), 
  .write_data (WriteDataM), .read_data (ReadDataM));
endmodule

module regfile (input wire clk, input wire we3, input wire [3:0] ra1, input wire [3:0] ra2,
input wire [3:0] wa3, input wire [31:0] wd3, input wire [31:0] r15, output wire [31:0] rd1,
output wire [31:0] rd2);
  
  reg [31:0] rf[14:0];
  always @(negedge clk) if (we3) rf[wa3] <= wd3;
  assign rd1 = (ra1 == 4'b1111 ? r15 : rf[ra1]);
  assign rd2 = (ra2 == 4'b1111 ? r15 : rf[ra2]);
endmodule

module InstructionMemory (input wire [31:0] address, output wire [31:0] instruction);

  //el array de memoria 
  reg [31:0] RAM[2097151:0];
  //lectura del memfile.dat
  initial $readmemh("memfile.dat", RAM);
  //lectura de la instruccion
  assign instruction = RAM[address[22:2]];
endmodule

module hazard (
    clk,
    reset,
    Match_1E_M,
    Match_1E_W,
    Match_2E_M,
    Match_2E_W,
    Match_12D_E,
    RegWriteM,
    RegWriteW,
    BranchTakenE,
    MemtoRegE,
    PCWrPendingF,
    PCSrcW,
    ForwardAE,
    ForwardBE,
    StallF,
    StallD,
    FlushD,
    FlushE
);
  reg _sv2v_0;
  input wire clk;
  input wire reset;
  input wire Match_1E_M;
  input wire Match_1E_W;
  input wire Match_2E_M;
  input wire Match_2E_W;
  input wire Match_12D_E;
  input wire RegWriteM;
  input wire RegWriteW;
  input wire BranchTakenE;
  input wire MemtoRegE;
  input wire PCWrPendingF;
  input wire PCSrcW;
  output reg [1:0] ForwardAE;
  output reg [1:0] ForwardBE;
  output wire StallF;
  output wire StallD;
  output wire FlushD;
  output wire FlushE;
  wire ldrStallD;
  always @(*) begin
    if (_sv2v_0);
    if (Match_1E_M & RegWriteM) ForwardAE = 2'b10;
    else if (Match_1E_W & RegWriteW) ForwardAE = 2'b01;
    else ForwardAE = 2'b00;
    if (Match_2E_M & RegWriteM) ForwardBE = 2'b10;
    else if (Match_2E_W & RegWriteW) ForwardBE = 2'b01;
    else ForwardBE = 2'b00;
  end
  assign ldrStallD = Match_12D_E & MemtoRegE;
  assign StallD = ldrStallD;
  assign StallF = ldrStallD | PCWrPendingF;
  assign FlushE = ldrStallD | BranchTakenE;
  assign FlushD = (PCWrPendingF | PCSrcW) | BranchTakenE;
  initial _sv2v_0 = 0;
endmodule

module extend (
    Instr,
    ImmSrc,
    ExtImm
);
  reg _sv2v_0;
  input wire [23:0] Instr;
  input wire [1:0] ImmSrc;
  output reg [31:0] ExtImm;
  always @(*) begin
    if (_sv2v_0);
    case (ImmSrc)
      2'b00:   ExtImm = {24'b000000000000000000000000, Instr[7:0]};
      2'b01:   ExtImm = {20'b00000000000000000000, Instr[11:0]};
      2'b10:   ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'b00};
      default: ExtImm = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    endcase
  end
  initial _sv2v_0 = 0;
endmodule

module adder (
    a,
    b,
    y
);
  parameter WIDTH = 8;
  input wire [WIDTH - 1:0] a;
  input wire [WIDTH - 1:0] b;
  output wire [WIDTH - 1:0] y;
  assign y = a + b;
endmodule

module eqcmp (
    a,
    b,
    y
);
  parameter WIDTH = 8;
  input wire [WIDTH - 1:0] a;
  input wire [WIDTH - 1:0] b;
  output wire y;
  assign y = a == b;
endmodule

module flopenrc (
    clk,
    reset,
    en,
    clear,
    d,
    q
);
  parameter WIDTH = 8;
  input wire clk;
  input wire reset;
  input wire en;
  input wire clear;
  input wire [WIDTH - 1:0] d;
  output reg [WIDTH - 1:0] q;
  always @(posedge clk or posedge reset)
    if (reset) q <= 0;
    else if (en) begin
      if (clear) q <= 0;
      else q <= d;
    end
endmodule

module flopenr (
    clk,
    reset,
    en,
    d,
    q
);
  parameter WIDTH = 8;
  input wire clk;
  input wire reset;
  input wire en;
  input wire [WIDTH - 1:0] d;
  output reg [WIDTH - 1:0] q;
  always @(posedge clk or posedge reset)
    if (reset) q <= 0;
    else if (en) q <= d;
endmodule

module flopr (
    clk,
    reset,
    d,
    q
);
  parameter WIDTH = 8;
  input wire clk;
  input wire reset;
  input wire [WIDTH - 1:0] d;
  output reg [WIDTH - 1:0] q;
  always @(posedge clk or posedge reset)
    if (reset) q <= 0;
    else q <= d;
endmodule

module floprc (
    clk,
    reset,
    clear,
    d,
    q
);
  parameter WIDTH = 8;
  input wire clk;
  input wire reset;
  input wire clear;
  input wire [WIDTH - 1:0] d;
  output reg [WIDTH - 1:0] q;
  always @(posedge clk or posedge reset)
    if (reset) q <= 0;
    else if (clear) q <= 0;
    else q <= d;
endmodule


module mux2 (
    d0,
    d1,
    s,
    y
);
  parameter WIDTH = 8;
  input wire [WIDTH - 1:0] d0;
  input wire [WIDTH - 1:0] d1;
  input wire s;
  output wire [WIDTH - 1:0] y;
  assign y = (s ? d1 : d0);
endmodule


module mux3 (
    d0,
    d1,
    d2,
    s,
    y
);
  parameter WIDTH = 8;
  input wire [WIDTH - 1:0] d0;
  input wire [WIDTH - 1:0] d1;
  input wire [WIDTH - 1:0] d2;
  input wire [1:0] s;
  output wire [WIDTH - 1:0] y;
  assign y = (s[1] ? d2 : (s[0] ? d1 : d0));
endmodule

module datapath (input wire clk, input wire reset, input wire [1:0] RegSrcD, input wire [1:0] ImmSrcD,
input wire ALUSrcE, input wire BranchTakenE, input wire [1:0] ALUControlE, input wire MemtoRegW,
input wire PCSrcW, input wire RegWriteW, output wire [31:0] PCF, input wire [31:0] InstrF,
output wire [31:0] InstrD, output wire [31:0] ALUOutM, output wire [31:0] WriteDataM,
input wire [31:0] ReadDataM, output wire [3:0] ALUFlagsE,
//variables del Hazard Unit
output wire Match_1E_M, output wire Match_1E_W,
output wire Match_2E_M, output wire Match_2E_W, output wire Match_12D_E, input wire [1:0] ForwardAE,
input wire [1:0] ForwardBE, input wire StallF, input wire StallD, input wire FlushD);


  wire [31:0] PCPlus4F;
  wire [31:0] PCnext1F;
  wire [31:0] PCnextF;
  wire [31:0] ExtImmD;
  wire [31:0] rd1D;
  wire [31:0] rd2D;
  wire [31:0] PCPlus8D;
  wire [31:0] rd1E;
  wire [31:0] rd2E;
  wire [31:0] ExtImmE;
  wire [31:0] SrcAE;
  wire [31:0] SrcBE;
  wire [31:0] WriteDataE;
  wire [31:0] ALUResultE;
  wire [31:0] ReadDataW;
  wire [31:0] ALUOutW;
  wire [31:0] ResultW;
  wire [3:0] RA1D;
  wire [3:0] RA2D;
  wire [3:0] RA1E;
  wire [3:0] RA2E;
  wire [3:0] WA3E;
  wire [3:0] WA3M;
  wire [3:0] WA3W;
  wire Match_1D_E;
  wire Match_2D_E;
  mux2 #(
      .WIDTH(32)
  ) pcnextmux (
      .d0(PCPlus4F),
      .d1(ResultW),
      .s (PCSrcW),
      .y (PCnext1F)
  );
  mux2 #(
      .WIDTH(32)
  ) branchmux (
      .d0(PCnext1F),
      .d1(ALUResultE),
      .s (BranchTakenE),
      .y (PCnextF)
  );
  flopenr #(
      .WIDTH(32)
  ) pcreg (
      .clk(clk),
      .reset(reset),
      .en(~StallF),
      .d(PCnextF),
      .q(PCF)
  );
  adder #(
      .WIDTH(32)
  ) pcadd (
      .a(PCF),
      .b(32'h00000004),
      .y(PCPlus4F)
  );
  assign PCPlus8D = PCPlus4F;
  flopenrc #(
      .WIDTH(32)
  ) instrreg (
      .clk(clk),
      .reset(reset),
      .en(~StallD),
      .clear(FlushD),
      .d(InstrF),
      .q(InstrD)
  );
  mux2 #(
      .WIDTH(4)
  ) ra1mux (
      .d0(InstrD[19:16]),
      .d1(4'b1111),
      .s (RegSrcD[0]),
      .y (RA1D)
  );
  mux2 #(
      .WIDTH(4)
  ) ra2mux (
      .d0(InstrD[3:0]),
      .d1(InstrD[15:12]),
      .s (RegSrcD[1]),
      .y (RA2D)
  );
  regfile rf (
      .clk(clk),
      .we3(RegWriteW),
      .ra1(RA1D),
      .ra2(RA2D),
      .wa3(WA3W),
      .wd3(ResultW),
      .r15(PCPlus8D),
      .rd1(rd1D),
      .rd2(rd2D)
  );
  extend ext (
      .Instr (InstrD[23:0]),
      .ImmSrc(ImmSrcD),
      .ExtImm(ExtImmD)
  );
  flopr #(
      .WIDTH(32)
  ) rd1reg (
      .clk(clk),
      .reset(reset),
      .d(rd1D),
      .q(rd1E)
  );
  flopr #(
      .WIDTH(32)
  ) rd2reg (
      .clk(clk),
      .reset(reset),
      .d(rd2D),
      .q(rd2E)
  );
  flopr #(
      .WIDTH(32)
  ) immreg (
      .clk(clk),
      .reset(reset),
      .d(ExtImmD),
      .q(ExtImmE)
  );
  flopr #(
      .WIDTH(4)
  ) wa3ereg (
      .clk(clk),
      .reset(reset),
      .d(InstrD[15:12]),
      .q(WA3E)
  );
  flopr #(
      .WIDTH(4)
  ) ra1reg (
      .clk(clk),
      .reset(reset),
      .d(RA1D),
      .q(RA1E)
  );
  flopr #(
      .WIDTH(4)
  ) ra2reg (
      .clk(clk),
      .reset(reset),
      .d(RA2D),
      .q(RA2E)
  );
  mux3 #(
      .WIDTH(32)
  ) byp1mux (
      .d0(rd1E),
      .d1(ResultW),
      .d2(ALUOutM),
      .s (ForwardAE),
      .y (SrcAE)
  );
  mux3 #(
      .WIDTH(32)
  ) byp2mux (
      .d0(rd2E),
      .d1(ResultW),
      .d2(ALUOutM),
      .s (ForwardBE),
      .y (WriteDataE)
  );
  mux2 #(
      .WIDTH(32)
  ) srcbmux (
      .d0(WriteDataE),
      .d1(ExtImmE),
      .s (ALUSrcE),
      .y (SrcBE)
  );
  alu alu (
      .a(SrcAE),
      .b(SrcBE),
      .ALUControl(ALUControlE),
      .Result(ALUResultE),
      .Flags(ALUFlagsE)
  );
  flopr #(
      .WIDTH(32)
  ) aluresreg (
      .clk(clk),
      .reset(reset),
      .d(ALUResultE),
      .q(ALUOutM)
  );
  flopr #(
      .WIDTH(32)
  ) wdreg (
      .clk(clk),
      .reset(reset),
      .d(WriteDataE),
      .q(WriteDataM)
  );
  flopr #(
      .WIDTH(4)
  ) wa3mreg (
      .clk(clk),
      .reset(reset),
      .d(WA3E),
      .q(WA3M)
  );
  flopr #(
      .WIDTH(32)
  ) aluoutreg (
      .clk(clk),
      .reset(reset),
      .d(ALUOutM),
      .q(ALUOutW)
  );
  flopr #(
      .WIDTH(32)
  ) rdreg (
      .clk(clk),
      .reset(reset),
      .d(ReadDataM),
      .q(ReadDataW)
  );
  flopr #(
      .WIDTH(4)
  ) wa3wreg (
      .clk(clk),
      .reset(reset),
      .d(WA3M),
      .q(WA3W)
  );
  mux2 #(
      .WIDTH(32)
  ) resmux (
      .d0(ALUOutW),
      .d1(ReadDataW),
      .s (MemtoRegW),
      .y (ResultW)
  );
  eqcmp #(
      .WIDTH(4)
  ) m0 (
      .a(WA3M),
      .b(RA1E),
      .y(Match_1E_M)
  );
  eqcmp #(
      .WIDTH(4)
  ) m1 (
      .a(WA3W),
      .b(RA1E),
      .y(Match_1E_W)
  );
  eqcmp #(
      .WIDTH(4)
  ) m2 (
      .a(WA3M),
      .b(RA2E),
      .y(Match_2E_M)
  );
  eqcmp #(
      .WIDTH(4)
  ) m3 (
      .a(WA3W),
      .b(RA2E),
      .y(Match_2E_W)
  );
  eqcmp #(
      .WIDTH(4)
  ) m4a (
      .a(WA3E),
      .b(RA1D),
      .y(Match_1D_E)
  );
  eqcmp #(
      .WIDTH(4)
  ) m4b (
      .a(WA3E),
      .b(RA2D),
      .y(Match_2D_E)
  );
  assign Match_12D_E = Match_1D_E | Match_2D_E;
endmodule

module DataMemory (input wire clk, input wire we, 
input wire [31:0] address, input wire [31:0] write_data, output wire [31:0] read_data);
  reg [31:0] RAM[2097151:0];
  initial $readmemh("memfile.dat", RAM);
  //lectura de la memoria
  assign read_data = RAM[address[22:2]];
  always @(posedge clk) if (we) RAM[address[22:2]] <= write_data;
endmodule

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

module conditional (input wire [3:0] Cond, input wire [3:0] Flags, input wire [3:0] ALUFlags, input wire [1:0] FlagsWrite,
output reg CondEx, output wire [3:0] FlagsNext);
  reg _sv2v_0;
  
  wire neg;
  wire zero;
  wire carry;
  wire overflow;
  wire ge;
  assign {neg, zero, carry, overflow} = Flags;
  assign ge = neg == overflow;
  always @(*) begin
    if (_sv2v_0);
    case (Cond)
      4'b0000: CondEx = zero;
      4'b0001: CondEx = ~zero;
      4'b0010: CondEx = carry;
      4'b0011: CondEx = ~carry;
      4'b0100: CondEx = neg;
      4'b0101: CondEx = ~neg;
      4'b0110: CondEx = overflow;
      4'b0111: CondEx = ~overflow;
      4'b1000: CondEx = carry & ~zero;
      4'b1001: CondEx = ~(carry & ~zero);
      4'b1010: CondEx = ge;
      4'b1011: CondEx = ~ge;
      4'b1100: CondEx = ~zero & ge;
      4'b1101: CondEx = ~(~zero & ge);
      4'b1110: CondEx = 1'b1;
      default: CondEx = 1'bx;
    endcase
  end
  assign FlagsNext[3:2] = (FlagsWrite[1] & CondEx ? ALUFlags[3:2] : Flags[3:2]);
  assign FlagsNext[1:0] = (FlagsWrite[0] & CondEx ? ALUFlags[1:0] : Flags[1:0]);
  initial _sv2v_0 = 0;
endmodule

module arm (input wire clk, input wire reset, output wire [31:0] PCF, input wire [31:0] InstrF,
output wire MemWriteM, output wire [31:0] ALUOutM, output wire [31:0] WriteDataM,
input wire [31:0] ReadDataM);

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
  
  
  controller c (.clk(clk), .reset(reset), .InstrD(InstrD[31:12]), .ALUFlagsE(ALUFlagsE),
  .RegSrcD(RegSrcD), .ImmSrcD(ImmSrcD), .ALUSrcE(ALUSrcE), .BranchTakenE(BranchTakenE),
  .ALUControlE(ALUControlE), .MemWriteM(MemWriteM), .MemtoRegW(MemtoRegW), .PCSrcW(PCSrcW),
  .RegWriteW(RegWriteW), .RegWriteM(RegWriteM), .MemtoRegE(MemtoRegE), .PCWrPendingF(PCWrPendingF),
  .FlushE(FlushE));


  datapath dp (.clk(clk), .reset(reset), .RegSrcD(RegSrcD), .ImmSrcD(ImmSrcD), .ALUSrcE(ALUSrcE),
  .BranchTakenE(BranchTakenE), .ALUControlE(ALUControlE), .MemtoRegW(MemtoRegW), .PCSrcW(PCSrcW),
  .RegWriteW(RegWriteW), .PCF(PCF), .InstrF(InstrF), .InstrD(InstrD), .ALUOutM(ALUOutM),
  .WriteDataM(WriteDataM), .ReadDataM(ReadDataM), .ALUFlagsE(ALUFlagsE), .Match_1E_M(Match_1E_M),
  .Match_1E_W(Match_1E_W), .Match_2E_M(Match_2E_M), .Match_2E_W(Match_2E_W), .Match_12D_E(Match_12D_E),
  .ForwardAE(ForwardAE), .ForwardBE(ForwardBE), .StallF(StallF), .StallD(StallD), .FlushD(FlushD));
  
  
  
  hazard h (.clk(clk), .reset(reset), .Match_1E_M(Match_1E_M), .Match_1E_W(Match_1E_W),
  .Match_2E_M(Match_2E_M), .Match_2E_W(Match_2E_W), .Match_12D_E(Match_12D_E), .RegWriteM(RegWriteM),
  .RegWriteW(RegWriteW), .BranchTakenE(BranchTakenE), .MemtoRegE(MemtoRegE), .PCWrPendingF(PCWrPendingF),
  .PCSrcW(PCSrcW), .ForwardAE(ForwardAE), .ForwardBE(ForwardBE), .StallF(StallF), .StallD(StallD),
  .FlushD(FlushD), .FlushE(FlushE));
endmodule

module alu (input wire [31:0] a, input wire [31:0] b, input wire [1:0] ALUControl, output reg [31:0] Result, output wire [3:0] Flags);
  reg _sv2v_0;
  wire neg;
  wire zero;
  wire carry;
  wire overflow;
  wire [31:0] condinvb;
  wire [32:0] sum;
  assign condinvb = (ALUControl[0] ? ~b : b);
  assign sum = (a + condinvb) + ALUControl[0];
  always @(*) begin
    if (_sv2v_0);
    casex (ALUControl[1:0])
      2'b0z: Result = sum;
      2'b10: Result = a & b;
      2'b11: Result = a | b;
    endcase
  end
  assign neg = Result[31];
  assign zero = Result == 32'b00000000000000000000000000000000;
  assign carry = (ALUControl[1] == 1'b0) & sum[32];
  assign overflow = ((ALUControl[1] == 1'b0) & ~((a[31] ^ b[31]) ^ ALUControl[0])) & (a[31] ^ sum[31]);
  assign Flags = {neg, zero, carry, overflow};
  initial _sv2v_0 = 0;
endmodule