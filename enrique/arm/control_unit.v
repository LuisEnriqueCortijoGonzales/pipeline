// File: arm/control_unit.v
// Controller module that decodes instructions and generates control signals

module control_unit (
    input wire       i_clk,    // Clock signal
    input wire       i_reset,  // Reset signal
    input wire [1:0] i_Op,
    input wire [5:0] i_Funct,
    input wire [3:0] i_Rd,

    output wire       o_PCSrc_D,       // Program Counter source selector
    output wire       o_RegWrite_D,    // Register write enable
    output wire       o_MemtoReg_D,    // Memory to Register selector
    output wire       o_MemWrite_D,    // Memory write enable
    output wire [2:0] o_ALUControl_D,  // ALU operation control
    output wire       o_Branch_D,      // Program Counter Source control (branch)
    output wire       o_ALUSrc_D,      // ALU source selector
    output wire [1:0] o_FlagWrite_D,   // Flag write control
    output wire [1:0] o_ImmSrc_D,      // Immediate value source selector
    output wire [1:0] o_RegSrc_D       // Register source selector
);

endmodule
