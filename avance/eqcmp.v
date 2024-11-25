module eqcmp (
    a,
    b,
    y
);
  parameter WIDTH = 8;
  input wire [WIDTH - 1:0] a;
  input wire [WIDTH - 1:0] b;
  output wire y;
  assign y = a == b;
endmodule