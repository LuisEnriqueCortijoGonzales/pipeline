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
    output wire MemWriteM,
    output wire MemtoRegW,
    output wire PCSrcW,
    output wire [1:0] RegWriteW,
    output wire [1:0] RegWriteM,
    output wire MemtoRegE,
    output wire PCWrPendingF,
    input wire FlushE,
    output wire [ALU_FLAGS_WIDTH-1:0] FlagsE
);
  localparam ALUCONTROL_WIDTH = 6;
  localparam ALU_FLAGS_WIDTH = 5;

  wire CondExE;
  wire ALUOpD;
  reg [ALUCONTROL_WIDTH-1:0] ALUControlD;
  wire ALUSrcD;
  wire MemtoRegD;
  wire MemtoRegM;
  wire [1:0] RegWriteD;
  wire [1:0] RegWriteE;
  wire [1:0] RegWriteGatedE;
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

  wire [3:0] CondE;


  wire is_data_processing;
  wire sets_flags;
  wire is_branch;

  wire is_branch;
  wire is_immediate;

  assign is_data_processing = InstrD[27];  // op[0]
  assign is_branch = InstrD[26];  // op[1]

  assign is_immediate  /* or alusrc */ = InstrD[25];
  assign sets_flags = (InstrD[20]);


  assign RegSrcD = is_data_processing ? 2'b00 : is_branch ? 2'b01 : {~sets_flags, 1'b0};

  assign ImmSrcD = is_data_processing ? 2'b00 : is_branch ? 2'b10 : 2'b01;

  assign ALUSrcD = is_data_processing ? is_immediate : 1'b1;

  assign MemtoRegD = is_data_processing ? 1'b0 : is_branch ? 1'b0 : sets_flags;

  assign RegWriteD = is_data_processing ? 1'b1 : is_branch ? 1'b0 : ~sets_flags;

  assign MemWriteD = is_data_processing ? 1'b0 : is_branch ? 1'b1 : sets_flags ? 1'b0 : 1'b1;

  assign BranchD = is_data_processing ? 1'b0 : is_branch ? 1'b1 : 1'b0;

  assign ALUOpD = is_data_processing;


  always @(*) begin
    if (ALUOpD) begin
      is_64b_return = 1'b0;
      case ({
        InstrD[26], InstrD[24:21]
      })
        5'b00000: ALUControlD = 6'b100000;  // ADD
        5'b00001: ALUControlD = 6'b100001;  // ADC
        5'b00010: ALUControlD = 6'b100010;  // QADD
        5'b00011: ALUControlD = 6'b100011;  // SUB
        5'b00100: ALUControlD = 6'b100100;  // SBS
        5'b00101: ALUControlD = 6'b100101;  // SBC
        5'b00110: ALUControlD = 6'b100110;  // QSUB
        5'b00111: ALUControlD = 6'b100111;  // MUL
        5'b01000: ALUControlD = 6'b101000;  // MLA
        5'b01001: ALUControlD = 6'b101001;  // MLS
        5'b01010: ALUControlD = 6'b101010;  // UMULL
        5'b01011: ALUControlD = 6'b101011;  // UMLAL
        5'b01100: ALUControlD = 6'b101100;  // SMULL
        5'b01101: ALUControlD = 6'b101101;  // SMLAL
        5'b01110: ALUControlD = 6'b101110;  // UDIV
        5'b01111: ALUControlD = 6'b101111;  // SDIV
        5'b10000: ALUControlD = 6'b110000;  // AND
        5'b10001: ALUControlD = 6'b110001;  // BIC
        5'b10010: ALUControlD = 6'b110010;  // ORR
        5'b10011: ALUControlD = 6'b110011;  // ORN
        5'b10100: ALUControlD = 6'b110100;  // EOR
        5'b10101: ALUControlD = 6'b110101;  // CMN
        5'b10110: ALUControlD = 6'b110110;  // TST
        5'b10111: ALUControlD = 6'b110111;  // TEQ
        5'b11000: ALUControlD = 6'b111000;  // CMP
        5'b11001: ALUControlD = 6'b111001;  // MOV
        5'b11010: ALUControlD = 6'b111010;  // LSR
        5'b11011: ALUControlD = 6'b111011;  // ASR
        5'b11100: ALUControlD = 6'b111100;  // LSL
        5'b11101: ALUControlD = 6'b111101;  // ROR
        5'b11110: ALUControlD = 6'b111110;  // RRX
        default:  ALUControlD = 6'bxxxxxx;
      endcase
      FlagWriteD[1] = sets_flags;
      FlagWriteD[0] = sets_flags & ((ALUControlD == 6'b100000) | (ALUControlD == 6'b100001) | (ALUControlD == 6'b100010) | (ALUControlD == 6'b100011) |
      (ALUControlD == 6'b100100) | (ALUControlD == 6'b100101) | (ALUControlD == 6'b100110) | (ALUControlD == 6'b110000) | (ALUControlD == 6'b110001) |
      (ALUControlD == 6'b110010) | (ALUControlD == 6'b110011) | (ALUControlD == 6'b110100) | (ALUControlD == 6'b110101) | (ALUControlD == 6'b110110) |
      (ALUControlD == 6'b110111) | (ALUControlD == 6'b111000) | (ALUControlD == 6'b111010) | (ALUControlD == 6'b111011) | (ALUControlD == 6'b111100) |
      (ALUControlD == 6'b111101) | (ALUControlD == 6'b111110));
    end else begin
      if (is_branch) begin
        case (InstrD[25:24])
          2'b00:   ALUControlD = 6'b010000;  // B
          2'b01:   ALUControlD = 6'b010001;  // BL
          2'b11:   ALUControlD = 6'b010010;  // CBZ Test & branch
          2'b10:   ALUControlD = 6'b010011;  // CBNZ Test & branch
          default: ALUControlD = 6'bxxxxxx;
        endcase
        FlagWriteD = 2'b00;
      end else begin
        case (InstrD[24:21])
          4'b0000: ALUControlD = 6'b000010;  // LDR Offset
          4'b0001: ALUControlD = 6'b000011;  // STR Offset
          4'b0010: ALUControlD = 6'b000100;  // LDR Pre-offset
          4'b0011: ALUControlD = 6'b000101;  // STR Pre-offset
          4'b0100: ALUControlD = 6'b000110;  // LDR Post-offset
          4'b0101: ALUControlD = 6'b000111;  // STR Post-offset
          4'b0110: ALUControlD = 6'b001000;  // LDR Indexed
          4'b0111: ALUControlD = 6'b001001;  // STR Indexed
          4'b1000: ALUControlD = 6'b001010;  // LDR Literal
          4'b1001: ALUControlD = 6'b001011;  // STR Literal
          4'b1010: ALUControlD = 6'b001100;  // STMIA Positive stack
          4'b1011: ALUControlD = 6'b001101;  // LDMDB Positive stack
          4'b1100: ALUControlD = 6'b001110;  // STMDB Negative stack
          4'b1101: ALUControlD = 6'b001111;  // LDMIA Negative stack
          default: ALUControlD = 6'bxxxxxx;
        endcase
        FlagWriteD = 2'b00;
      end
    end
  end
  assign PCSrcD = ((InstrD[15:12] == 4'b1111) & RegWriteD[0]) | BranchD;

  registro_flanco_positivo_habilitacion_limpieza #(
      .WIDTH(8)
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
      .FlagsNext(FlagsNextE)
  );

  // Branch Predictor: Determina si una rama debe tomarse basándose en la
  // condición evaluada en la etapa de ejecución, mejorando la precisión de
  // predicción y reduciendo el número de instrucciones incorrectas en el pipeline.
  assign BranchTakenE   = BranchE & CondExE;
  assign RegWriteGatedE = CondExE ? RegWriteE : 2'b00;
  assign MemWriteGatedE = MemWriteE & CondExE;
  wire PCSrcGatedE;
  assign PCSrcGatedE = PCSrcE & CondExE;
  registro_flanco_positivo #(
      .WIDTH(5)
  ) regs_M (
      .clk(clk),
      .reset(reset),
      .d({MemWriteGatedE, MemtoRegE, RegWriteGatedE, PCSrcGatedE}),
      .q({MemWriteM, MemtoRegM, RegWriteM, PCSrcM})
  );
  registro_flanco_positivo #(
      .WIDTH(4)
  ) regs_W (
      .clk(clk),
      .reset(reset),
      .d({MemtoRegM, RegWriteM, PCSrcM}),
      .q({MemtoRegW, RegWriteW, PCSrcW})
  );
  assign PCWrPendingF = (PCSrcD | PCSrcE) | PCSrcM;
endmodule
