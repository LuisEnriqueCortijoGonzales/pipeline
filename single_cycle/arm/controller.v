// File: arm/controller.v
// Controller module that decodes instructions and generates control signals

module controller (
    input  wire         clk,         // Clock signal
    input  wire         reset,       // Reset signal
    input  wire [31:12] Instr,       // Instruction bits [31:12]
    input  wire [  3:0] ALUFlags,    // ALU Flags (Negative, Zero, Carry, Overflow)
    output wire [  1:0] RegSrc,      // Register source selector
    output wire         RegWriteD,    // Register write enable
    output wire [  1:0] ImmSrc,      // Immediate value source selector
    output wire         ALUSrcD,      // ALU source selector
    output wire [  2:0] ALUControlD,  // ALU operation control
    output wire         MemWriteD,    // Memory write enable
    output wire         MemtoRegD,    // Memory to Register selector
    output wire         PCSrcD,        // Program Counter source selector
    output wire [1:0] FlagWriteD // Flag write enable signals
);
  // Internal control signals from decoder
  
  wire BranchSignal;    // Branch signal
  wire RegisterWrite;   // Register write signal
  wire MemoryWrite;     // Memory write signal

  // Instantiate Decoder
  decode decoder (
      .Op        (Instr[27:26]),   // Opcode field
      .Funct     (Instr[25:20]),   // Function field
      .Rd        (Instr[15:12]),   // Destination register
      .FlagW     (FlagWrite),      // Flag write control
      .PCS       (BranchSignal),   // Branch signal
      .RegW      (RegisterWrite),  // Register write control
      .MemW      (MemoryWrite),    // Memory write control
      .MemtoReg  (MemtoReg),       // Memory to Register control
      .ALUSrc    (ALUSrc),         // ALU source control
      .ImmSrc    (ImmSrc),         // Immediate source control
      .RegSrc    (RegSrc),         // Register source control
      .ALUControl(ALUControl)      // ALU operation control
  );

  // Instantiate Condition Logic
  condlogic condition_logic (
      .clk     (clk),
      .reset   (reset),
      .Cond    (Instr[31:28]),   // Condition field
      .ALUFlags(ALUFlags),       // ALU Flags
      .FlagW   (FlagWrite),      // Flag write control
      .PCS     (BranchSignal),   // Branch signal
      .RegW    (RegisterWrite),  // Register write control
      .MemW    (MemoryWrite),    // Memory write control
      .PCSrc   (PCSrc),          // Program Counter source control
      .RegWrite(RegWrite),       // Register write enable
      .MemWrite(MemWrite)        // Memory write enable
  );

endmodule
