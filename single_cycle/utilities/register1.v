// File: registro 1
// Flip-Flop module with synchronous reset
module registro1(
    input  wire             clk,    // Clock signal
    input  wire             reset,  // Reset signal
    input  wire [31:0] d,      // Data input
    output reg  [31:0] q       // Data output
);
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      q <= 32'b0;  // Reset output to zero
    end else begin
      q <= d;  // Update output with input data
    end
  end
endmodule
