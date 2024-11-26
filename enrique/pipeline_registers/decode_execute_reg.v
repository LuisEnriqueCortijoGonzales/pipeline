// File: pipeline_registers/decode_execute.v
// Flip-flop for the decode/execute stage of the pipeline.


parameter DATA_WIDTH = 32;
parameter WA3_WIDTH = 32;
parameter ALU_FLAGS_WIDTH = 4;

module decode_execute_reg (
    input wire i_clk,   // Clock signal
    input wire i_reset, // Reset signal

    // Controller

    // 1 PC source selector
    input  wire i_PCSource_D,
    output reg  o_PCSource_E,

    // 1 Register write enable
    input  wire i_RegWriteEnable_D,
    output reg  o_RegWriteEnable_E,

    // 1 Memory to register selector
    input  wire i_MemToReg_D,
    output reg  o_MemToReg_E,

    // 1 Memory write enable
    input  wire i_MemWriteEnable_D,
    output reg  o_MemWriteEnable_E,

    // 3 ALU Control
    input  wire [2:0] i_ALUControl_D,
    output reg  [2:0] o_ALUControl_E,

    // 1 Program Counter Source control (branch)
    input  wire i_Branch_D,
    output reg  o_Branch_E,

    // 1 ALU source selector
    input  wire i_ALUSrc_D,
    output reg  o_ALUSrc_E,


    // 2 Flag Write control
    input  wire [1:0] i_FlagWrite_D,
    output reg  [1:0] o_FlagWrite_E,


    // 4 Condition field from instruction
    input  wire [3:0] i_Cond_D,
    output reg  [3:0] o_Cond_E,

    // 4 Current flags
    input  wire [ALU_FLAGS_WIDTH-1:0] i_Flags_D,
    output reg  [ALU_FLAGS_WIDTH-1:0] o_Flags_E,

    // Datapath

    // 32
    input  wire [DATA_WIDTH - 1 : 0] i_RD1_D,
    output reg  [DATA_WIDTH - 1 : 0] o_RD1_E,

    // 32
    input  wire [DATA_WIDTH - 1 : 0] i_RD2_D,
    output reg  [DATA_WIDTH - 1 : 0] o_RD2_E,

    // 4
    input  wire [WA3_WIDTH - 1 : 0] i_WA3_D,
    output reg  [WA3_WIDTH - 1 : 0] o_WA3_E,

    // 32
    input  wire [DATA_WIDTH - 1 : 0] i_ExtendedImmediate_D,
    output reg  [DATA_WIDTH - 1 : 0] o_ExtendedImmediate_E
);

  // register size = 1 + 1 + 1 + 1 + 3 + 1 + 1 + 4 + 4 + 32 + 32 + 4 + 32 = 87w

  wire [86:0] FETCH_IN;
  wire [86:0] FETCH_OUT;

  assign FETCH_IN = {
    i_PCSource_D,
    i_RegWriteEnable_D,
    i_MemToReg_D,
    i_MemWriteEnable_D,
    i_ALUControl_D,
    i_Branch_D,
    i_ALUSrc_D,
    i_Cond_D,
    i_Flags_D,
    i_RD1_D,
    i_RD2_D,
    i_WA3_D,
    i_ExtendedImmediate_D
  };
  assign {
    o_PCSource_E,
    o_RegWriteEnable_E,
    o_MemToReg_E,
    o_MemWriteEnable_E,
    o_ALUControl_E,
    o_Branch_E,
    o_ALUSrc_E,
    o_Cond_E,
    o_Flags_E,
    o_RD1_E,
    o_RD2_E,
    o_WA3_E,
    o_ExtendedImmediate_E
    } = FETCH_OUT;

  flopr #(87) fetch_register (
      .clk(clk),
      .reset(reset),
      .d(FETCH_IN),
      .q(FETCH_OUT)
  );


endmodule
