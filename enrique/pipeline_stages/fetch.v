// File pipeline_stages/fetch.v

module fetch (
    input  wire        i_clk,           // Clock signal
    input  wire        i_reset,         // Reset signal
    input  wire        i_PCSrc_W,       // Program Counter source selector
    input  wire [31:0] i_Result_W,      // Data to write to register
    output wire [31:0] o_PCPlus8_F,
    output wire [31:0] o_Instruction_F
);

  wire [31:0] PCNext;  // Next Program Counter value
  wire [31:0] o_PCPlus8_F;  // PC + 8 (for link register)
  wire [31:0] PC;  // ProgramCounter

  // Mux for selecting next PC: PC + 4 or branch target
  mux2 #(32) pc_mux (
      .d0(PCPlus8),
      .d1(i_Result_W),  // Assuming ALUResult holds branch target
      .s (i_PCSrc_W),
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
      .y(o_PCPlus8_F)
  );

  // Instantiate Instruction Memory
  imem instruction_memory (
      .address(PC),
      .instruction(o_Instruction_F)
  );
endmodule
