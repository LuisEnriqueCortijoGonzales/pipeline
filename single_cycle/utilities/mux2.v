// File: utilities/mux2.v
// 2-input Multiplexer module with parameterizable width

module mux2 #(
    parameter WIDTH = 8  // Width of the data inputs
) (
    input  wire [WIDTH-1:0] d0,  // Data input 0
    input  wire [WIDTH-1:0] d1,  // Data input 1
    input  wire             s,   // Select signal
    output wire [WIDTH-1:0] y    // Output
);
  assign y = (s) ? d1 : d0;  // Select between d0 and d1 based on s
endmodule
