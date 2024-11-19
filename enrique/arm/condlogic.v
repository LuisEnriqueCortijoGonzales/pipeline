// File: arm/condlogic.v
// Condition Logic module determining if an instruction should execute based on condition codes.

module condlogic (
    input  wire       clk,       // Clock signal
    input  wire       reset,     // Reset signal
    input  wire [3:0] Cond,      // Condition field from instruction
    input  wire [3:0] ALUFlags,  // ALU Flags (Negative, Zero, Carry, Overflow)
    input  wire [1:0] FlagW,     // Flag write control
    input  wire       PCS,       // Program Counter Source control (branch)
    input  wire       RegW,      // Register Write control
    input  wire       MemW,      // Memory Write control
    output wire       PCSrc,     // Program Counter Source selector
    output wire       RegWrite,  // Register Write enable
    output wire       MemWrite   // Memory Write enable
);
  // Internal wires
  wire [1:0] FlagWriteEnable;  // Flag write enable after condition check
  wire [3:0] CurrentFlags;  // Current processor flags
  wire       ConditionMet;  // Indicates if condition is met

  // Register the flags (only update if FlagWriteEnable is asserted)
  flopenr #(2) flag_register_high (
      .clk(clk),
      .reset(reset),
      .en(FlagWriteEnable[1]),
      .d(ALUFlags[3:2]),
      .q(CurrentFlags[3:2])
  );

  flopenr #(2) flag_register_low (
      .clk(clk),
      .reset(reset),
      .en(FlagWriteEnable[0]),
      .d(ALUFlags[1:0]),
      .q(CurrentFlags[1:0])
  );

  // Instantiate Condition Checker
  condcheck condition_checker (
      .Cond  (Cond),
      .Flags (CurrentFlags),
      .CondEx(ConditionMet)
  );

  // Control signal gating based on condition
  assign FlagWriteEnable = FlagW & {2{ConditionMet}};
  assign RegWrite        = RegW & ConditionMet;
  assign MemWrite        = MemW & ConditionMet;
  assign PCSrc           = PCS & ConditionMet;

endmodule
