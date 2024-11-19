// File: arm/arm_processor.v
// ARM Processor module integrating the controller and datapath.

module arm (
    input  wire        clk,        // Clock signal
    input  wire        reset,      // Reset signal
    output wire [31:0] PC,         // Current Program Counter
    input  wire [31:0] Instr,      // Current Instruction
    output wire        MemWrite,   // Memory write enable
    output wire [31:0] ALUResult,  // Result from ALU
    output wire [31:0] WriteData,  // Data to write to memory
    input  wire [31:0] ReadData    // Data read from memory
);
  // Internal signals
  wire [3:0] ALUFlags;  // Flags from ALU (Negative, Zero, Carry, Overflow)
  wire       RegWrite;  // Register write enable
  wire       ALUSrc;  // ALU source selector
  wire       MemtoReg;  // Memory to Register selector
  wire       PCSrc;  // Program Counter source selector
  wire [1:0] RegSrc;  // Register source selector
  wire [1:0] ImmSrc;  // Immediate value source selector
  wire [2:0] ALUControl;  // ALU operation control

  // Instantiate Controller
  controller control_unit (
      .clk       (clk),
      .reset     (reset),
      .Instr     (Instr[31:12]),  // Pass relevant instruction bits to controller
      .ALUFlags  (ALUFlags),
      .RegSrc    (RegSrc),
      .RegWrite  (RegWrite),
      .ImmSrc    (ImmSrc),
      .ALUSrc    (ALUSrc),
      .ALUControl(ALUControl),
      .MemWrite  (MemWrite),
      .MemtoReg  (MemtoReg),
      .PCSrc     (PCSrc)
  );

  // Instantiate Datapath
  datapath data_path (
      .clk(clk),
      .reset(reset),
      .RegSrc(RegSrc),
      .RegWrite(RegWrite),
      .ImmSrc(ImmSrc),
      .ALUSrc(ALUSrc),
      .ALUControl(ALUControl),
      .MemtoReg(MemtoReg),
      .PCSrc(PCSrc),
      .ALUFlags(ALUFlags),
      .PC(PC),
      .Instr(Instr),
      .ALUResult(ALUResult),
      .WriteData(WriteData),
      .ReadData(ReadData)
  );

endmodule
