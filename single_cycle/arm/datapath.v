// File: arm/datapath.v
// Datapath module handling data operations based on control signals

module datapath (
    input  wire        clk,         // Clock signal
    input  wire        reset,       // Reset signal
    input  wire [ 1:0] RegSrc,      // Register source selector
    input  wire        RegWrite,    // Register write enable
    input  wire [ 1:0] ImmSrc,      // Immediate value source selector
    input  wire        ALUSrc,      // ALU source selector
    input  wire [ 2:0] ALUControl,  // ALU operation control
    input  wire        MemtoReg,    // Memory to Register selector
    input  wire        PCSrc,       // Program Counter source selector
    output wire [ 3:0] ALUFlags,    // Flags from ALU
    output wire [31:0] PC,          // Current Program Counter
    input  wire [31:0] Instr,       // Current Instruction
    output wire [31:0] ALUResult,   // ALU Result
    output wire [31:0] WriteData,   // Data to write to memory
    input  wire [31:0] ReadData     // Data read from memory
);
  // Internal wires
  wire [31:0] PCNext;  // Next Program Counter value
  wire [31:0] PCPlus4;  // PC + 4
  wire [31:0] PCPlus8;  // PC + 8 (for link register)
  wire [31:0] ExtendedImm;  // Extended immediate value
  wire [31:0] SrcA;  // Source A for ALU
  wire [31:0] SrcB;  // Source B for ALU
  wire [31:0] WriteDataMuxed;  // Data to write to register
  wire [ 3:0] RA1;  // Register Address 1
  wire [ 3:0] RA2;  // Register Address 2

  // Mux for selecting next PC: PC + 4 or branch target
  mux2 #(32) pc_mux (
      .d0(PCPlus4),
      .d1(ALUResult),  // Assuming ALUResult holds branch target
      .s (PCSrc),
      .y (PCNext)
  );

  // Program Counter Register
  flopr #(32) pc_register (
      .clk(clk),
      .reset(reset),
      .d(PCNext),
      .q(PC)
  );

  // Adder: PC + 4
  adder #(32) pc_add1 (
      .a(PC),
      .b(32'd4),
      .y(PCPlus4)
  );

  // Adder: PC + 8 (for link register in branch instructions)
  adder #(32) pc_add2 (
      .a(PCPlus4),
      .b(32'd4),
      .y(PCPlus8)
  );

  // Mux for Register Address 1: Instr[19:16] or R15 (PC)
  mux2 #(4) ra1_mux (
      .d0(Instr[19:16]),
      .d1(4'd15),         // PC
      .s (RegSrc[0]),
      .y (RA1)
  );

  // Mux for Register Address 2: Instr[3:0] or Instr[15:12]
  mux2 #(4) ra2_mux (
      .d0(Instr[3:0]),
      .d1(Instr[15:12]),
      .s (RegSrc[1]),
      .y (RA2)
  );

  // Register File
  regfile registers (
      .clk(clk),
      .we3(RegWrite),
      .ra1(RA1),
      .ra2(RA2),
      .wa3(Instr[15:12]),    // Destination register
      .wd3(WriteDataMuxed),
      .r15(PCPlus8),         // R15 (PC) holds PC + 8
      .rd1(SrcA),
      .rd2(WriteData)
  );

  // Mux for Write Data: ALUResult or Data from Memory
  mux2 #(32) write_data_mux (
      .d0(ALUResult),
      .d1(ReadData),
      .s (MemtoReg),
      .y (WriteDataMuxed)
  );

  // Immediate Value Extension
  extend immediate_extend (
      .Instr (Instr[23:0]),
      .ImmSrc(ImmSrc),
      .ExtImm(ExtendedImm)
  );

  // Mux for ALU Source B: Register Data or Extended Immediate
  mux2 #(32) srcb_mux (
      .d0(WriteData),
      .d1(ExtendedImm),
      .s (ALUSrc),
      .y (SrcB)
  );

  // ALU Operations
  alu arithmetic_logic_unit (
      .a(SrcA),
      .b(SrcB),
      .ALUControl(ALUControl),
      .Result(ALUResult),
      .ALUFlags(ALUFlags)
  );

endmodule
