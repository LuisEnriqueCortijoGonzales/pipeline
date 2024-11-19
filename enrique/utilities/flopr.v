// File: utilities/flopr.v
// Flip-Flop module with synchronous reset

module flopr #(
    parameter WIDTH = 8  // Width of the data bus
) (
    input  wire             clk,    // Clock signal
    input  wire             reset,  // Reset signal
    input  wire [WIDTH-1:0] d,      // Data input
    output reg  [WIDTH-1:0] q       // Data output
);
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      q <= {WIDTH{1'b0}};  // Reset output to zero
    end else begin
      q <= d;  // Update output with input data
    end
  end
endmodule
