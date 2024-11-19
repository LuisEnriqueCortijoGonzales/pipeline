// File: top.v
// Top-level module for the single-cycle ARM processor

module top (
    input  wire        clk,        // Clock signal
    input  wire        reset,      // Reset signal
    output wire [31:0] WriteData,  // Data to be written to memory
    output wire [31:0] DataAdr,    // Address for data memory
    output wire        MemWrite    // Memory write enable signal
);
  // Internal wires connecting submodules
  wire [31:0] PC;  // Program Counter
  wire [31:0] InstructionF;  // Current instruction
  wire [31:0] ReadData;  // Data read from memory
  wire [31:0] InstructionD; //Exit from r1
  // Instantiate ARM core
  arm arm_core (
      .clk(clk),
      .reset(reset),
      .PC(PC),
      .Instr(InstructionD),
      .MemWrite(MemWrite),
      .ALUResult(DataAdr),
      .WriteData(WriteData),
      .ReadData(ReadData)
  );

  // Instantiate Instruction Memory
  imem instruction_memory (
      .address (PC),
      .instruction(InstructionF)
  );

  // Instantiate Data Memory
  dmem data_memory (
      .clk(clk),
      .we(MemWrite),
      .address(DataAdr),
      .write_data(WriteData),
      .read_data(ReadData)
  );
  
  r1 registro1(.clk(clk), .reset(reset), .d(InstructionF), .q(InstructionD));

endmodule