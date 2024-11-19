// File: utilities/flopenr.v
// Flip-Flop module with synchronous reset and enable

module flopenr #(
    parameter WIDTH = 8  // Width of the data bus
) (
    input  wire             clk,    // Clock signal
    input  wire             reset,  // Reset signal
    input  wire             en,     // Enable signal
    input  wire [WIDTH-1:0] d,      // Data input
    output reg  [WIDTH-1:0] q       // Data output
);
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      q <= {WIDTH{1'b0}};  // Reset output to zero
    end else if (en) begin
      q <= d;  // Update output with input data if enabled
    end
  end
endmodule
