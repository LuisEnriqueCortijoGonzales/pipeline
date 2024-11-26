// File pipeline_stages/decode.v

module decode (
    input wire        i_clk,            // Clock signal
    input wire        i_reset,          // Reset signal
    input wire [31:0] i_Result_W,       // Data to write to register
    input wire [31:0] i_Instruction_D,
    input wire [31:0] i_WA3_W,          // Write Address 3
    input wire [31:0] i_PCPlus8_D,

    input wire i_RegWrite_W,  // Register write enable

    // control unit outputs (all but ImmSrc & RegSrc)
    output wire       o_PCSrc_D,       // Program Counter source selector
    output wire       o_RegWrite_D,    // Register write enable
    output wire       o_MemtoReg_D,    // Memory to Register selector
    output wire       o_MemWrite_D,    // Memory write enable
    output wire [2:0] o_ALUControl_D,  // ALU operation control
    output wire       o_Branch_D,      // Program Counter Source control (branch)
    output wire       o_ALUSrc_D,      // ALU source selector
    output wire [1:0] o_FlagWrite_D,   // Flag write control

    // Read data from register file
    output wire [31:0] o_RD1_D,
    output wire [31:0] o_RD2_D,

    // Extend
    output reg [31:0] o_ExtImm_D  // Extended immediate value
);

  wire RegSrcD[1:0];  // Register source selector
  wire ImmSrcD[1:0];  // Immediate value source selector

  wire [3:0] RA1;  // Register Address 1
  wire [3:0] RA2;  // Register Address 2

  control_unit control_unit (
      .i_clk(i_clk),
      .i_reset(i_reset),
      .i_Op(i_Instruction_D[27:26]),
      .i_Func(i_Instruction_D[25:20]),
      .i_Rd(i_Instruction_D[15:12]),

      .o_PCSrc_D(o_PCSrc_D),
      .o_RegWrite_D(o_RegWrite_D),
      .o_MemtoReg_D(o_MemtoReg_D),
      .o_MemWrite_D(o_MemWrite_D),
      .o_ALUControl_D(o_ALUControl_D),
      .o_Branch_D(o_Branch_D),
      .o_ALUSrc_D(o_ALUSrc_D),
      .o_FlagWrite_D(o_FlagWrite_D),
      .o_ImmSrc_D(ImmSrcD),
      .o_RegSrc_D(RegSrcD)
  );

  mux2 #(4) ra1_mux (
      .d0(i_Instruction_D[19:16]),
      .d1(4'd15),                   // PC
      .s (RegSrcD[0]),
      .y (RA1)
  );

  // Mux for Register Address 2: Instr[3:0] or Instr[15:12]
  mux2 #(4) ra2_mux (
      .d0(i_Instruction_D[3:0]),
      .d1(i_Instruction_D[15:12]),
      .s (RegSrcD[1]),
      .y (RA2)
  );

  // Register File
  regfile registers (
      .clk(clk),
      .we3(i_RegWrite_W),
      .ra1(RA1),
      .ra2(RA2),
      .wa3(i_WA3_W),       // Destination register
      .wd3(i_Result_W),
      .r15(i_PCPlus8_D),   // R15 (PC) holds PC + 8
      .rd1(o_RD1_D),
      .rd2(o_RD2_D)
  );

  // Immediate Value Extension
  extend immediate_extend (
      .Instr (i_Instruction_D[23:0]),
      .ImmSrc(ImmSrcD),
      .ExtImm(o_ExImm_D)
  );

endmodule
