// File: arm/control_unit.v
// Controller module that decodes instructions and generates control signals

parameter ALU_FLAGS_WIDTH = 4;

module cond_unit (
    input  wire                       i_clk,          // Clock signal
    input  wire                       i_reset,        // Reset signal
    input  reg  [                1:0] i_FlagWrite_E,  // Flag Write control
    input  wire [                3:0] i_Cond_E,       // Condition field from instruction
    input  wire [ALU_FLAGS_WIDTH-1:0] i_Flags_E,      //Current flags
    input  wire [ALU_FLAGS_WIDTH-1:0] i_ALUFlags,     // ALU flags
    output wire [ALU_FLAGS_WIDTH-1:0] o_Flags,        // next flags'
    output wire                       o_CondEx_E
);

endmodule
