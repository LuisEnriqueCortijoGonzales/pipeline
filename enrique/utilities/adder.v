// File: utilities/adder.v
// Parameterized Adder module

module adder #(
    parameter WIDTH = 8  // Width of the operands
) (
    input  wire [WIDTH-1:0] a,  // Operand A
    input  wire [WIDTH-1:0] b,  // Operand B
    output wire [WIDTH-1:0] y   // Sum Output
);
  assign y = a + b;  // Perform addition
endmodule
