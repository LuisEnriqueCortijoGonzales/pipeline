// File: pipeline_registers/fetch_decode.v
// Flip-flop for the fetch/decode stage of the pipeline.

parameter INSTRUCTION_WIDTH = 32;

module fetch_decode_reg (
    input wire i_clk,   // Clock signal
    input wire i_reset, // Reset signal

    input  wire [INSTRUCTION_WIDTH - 1:0] i_instruction_F,
    output reg  [INSTRUCTION_WIDTH - 1:0] o_instruction_D
);

  wire [INSTRUCTION_WIDTH - 1:0] FETCH_IN;
  wire [INSTRUCTION_WIDTH - 1:0] FETCH_OUT;

  assign FETCH_IN = i_instruction;
  assign o_instruction = FETCH_OUT;

  flopr #(INSTRUCTION_WIDTH) fetch_register (
      .clk(clk),
      .reset(reset),
      .d(FETCH_IN),
      .q(FETCH_OUT)
  );


endmodule
