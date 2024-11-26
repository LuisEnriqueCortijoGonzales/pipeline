// File: arm/arm_processor.v
// ARM Processor module which instantiates the 5 pipeline divisor registers

module arm_processor (
    input wire clk,   // Clock signal
    input wire reset  // Reset signal
);

  // wire        MemWrite;  // Memory write enable
  // wire [31:0] DataAdr;  // Result from ALU
  // wire [31:0] WriteData;  // Data to write to memory
  //
  // wire [31:0] PC;  // Program Counter
  // wire [31:0] Instruction;  // Current instruction
  // wire [31:0] ReadData;  // Data read from memory
  //
  // wire [ 3:0] ALUFlags;  // Flags from ALU (Negative, Zero, Carry, Overflow)
  // wire        RegWrite;  // Register write enable
  // wire        ALUSrc;  // ALU source selector
  // wire        MemtoReg;  // Memory to Register selector
  // wire        PCSrc;  // Program Counter source selector
  // wire [ 1:0] RegSrc;  // Register source selector
  // wire [ 1:0] ImmSrc;  // Immediate value source selector
  // wire [ 2:0] ALUControl;  // ALU operation control



  wire [31:0] PCSrc;
  wire [31:0] Result;

  wire [31:0] PCPlus8_D;
  wire [31:0] Instruction_F;
  wire [31:0] Instruction_D;

  fetch fetc (
      .i_clk(clk),
      .i_reset(reset),
      .i_PCSrc_W(PCSrc),
      .i_Result_W(Result),
      .o_PCPlus8_F(PCPlus8_D),
      .o_Instruction_F(Instruction_F)
  );

  fetch_decode fetch_decod (
      .i_clk(clk),
      .i_reset(reset),
      .i_instruction_F(Instruction_F),
      .o_instruction_D(Instruction_D)
  );

endmodule
