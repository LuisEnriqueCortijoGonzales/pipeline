module controller (
    input wire clk,
    input wire reset,
    input wire [31:12] InstrD,
    input wire [ALU_FLAGS_WIDTH-1:0] ALUFlagsE,
    output wire [1:0] RegSrcD,
    output wire [1:0] ImmSrcD,
    output wire ALUSrcE,
    output wire BranchTakenE,
    output wire [ALUCONTROL_WIDTH-1:0] ALUControlE,
    output wire CarryE,
    output wire MemWriteM,
    output wire MemtoRegW,
    output wire PCSrcW,
    output wire RegWriteW,
    output wire RegWriteM,
    output wire MemtoRegE,
    output wire PCWrPendingF,
    input wire FlushE
);
  localparam ALUCONTROL_WIDTH = 5;
  localparam ALU_FLAGS_WIDTH = 5;

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

  wire CarryD;


  wire is_data_op;
  wire sets_flags;
  wire modifies_memory;

  assign is_data_op      = InstrD[27];  // op[0]
  assign is_branch       = InstrD[26];  // op[1]

  assign is_alu_src      = (InstrD[25]);
  assign modifies_memory = (InstrD[20]);


  // Continuous assignments for combinational logic
  assign RegSrcD         = is_data_op ? 2'b00 : is_branch ? 2'b01 : {~modifies_memory, 1'b0};

  assign ImmSrcD         = is_data_op ? 2'b00 : is_branch ? 2'b10 : 2'b01;

  assign ALUSrcD         = is_data_op ? is_alu_src : is_branch ? 1'b0 : 1'b1;

  assign MemtoRegD       = is_data_op ? 1'b0 : is_branch ? 1'b0 : modifies_memory;

  assign RegWriteD       = is_data_op ? 1'b1 : is_branch ? 1'b0 : ~modifies_memory;

  assign MemWriteD       = is_data_op ? 1'b0 : is_branch ? 1'b1 : modifies_memory ? 1'b0 : 1'b1;

  assign BranchD         = is_data_op ? 1'b0 : is_branch ? 1'b1 : 1'b0;

  assign ALUOpD          = is_data_op ? 1'b1 : is_branch ? 1'b0 : 1'b0;


  always @(*) begin
    if (ALUOpD) begin
      case ({
        InstrD[26], InstrD[24:21]
      })
        5'b00000: ALUControlD = 5'b00000;  // ADD
        5'b00001: ALUControlD = 5'b00001;  // ADC
        5'b00010: ALUControlD = 5'b00010;  // QADD
        5'b00011: ALUControlD = 5'b00011;  // SUB
        5'b00100: ALUControlD = 5'b00100;  // SBS
        5'b00101: ALUControlD = 5'b00101;  // SBC
        5'b00110: ALUControlD = 5'b00110;  // QSUB
        5'b00111: ALUControlD = 5'b00111;  // MUL
        5'b01000: ALUControlD = 5'b01000;  // MLA
        5'b01001: ALUControlD = 5'b01001;  // MLS
        5'b01010: ALUControlD = 5'b01010;  // UMULL
        5'b01011: ALUControlD = 5'b01011;  // UMLAL
        5'b01100: ALUControlD = 5'b01100;  // SMULL
        5'b01101: ALUControlD = 5'b01101;  // SMLAL
        5'b01110: ALUControlD = 5'b01110;  // UDIV
        5'b01111: ALUControlD = 5'b01111;  // SDIV
        5'b10000: ALUControlD = 5'b10000;  // AND
        5'b10001: ALUControlD = 5'b10001;  // BIC
        5'b10010: ALUControlD = 5'b10010;  // ORR
        5'b10011: ALUControlD = 5'b10011;  // ORN
        5'b10100: ALUControlD = 5'b10100;  // EOR
        5'b10101: ALUControlD = 5'b10101;  // CMN
        5'b10110: ALUControlD = 5'b10110;  // TST
        5'b10111: ALUControlD = 5'b10111;  // TEQ
        5'b11000: ALUControlD = 5'b11000;  // CMP
        5'b11001: ALUControlD = 5'b11001;  // MOV
        5'b11010: ALUControlD = 5'b11010;  // LSR
        5'b11011: ALUControlD = 5'b11011;  // ASR
        5'b11100: ALUControlD = 5'b11100;  // LSL
        5'b11101: ALUControlD = 5'b11101;  // ROR
        5'b11110: ALUControlD = 5'b11110;  // RRX
        default:  ALUControlD = 5'bxxxx;
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
      .WIDTH(ALUCONTROL_WIDTH + 2)
  ) regsE (
      .clk(clk),
      .reset(reset),
      .d({ALUSrcD, ALUControlD, CarryD}),
      .q({ALUSrcE, ALUControlE, CarryE})
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
      .FlagsNext(FlagsNextE),
      .carry(CarryE)
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
