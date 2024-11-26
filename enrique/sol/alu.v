module alu (
    a,
    b,
    ALUControl,
    Result,
    Flags
);
  reg _sv2v_0;
  input wire [31:0] a;
  input wire [31:0] b;
  input wire [1:0] ALUControl;
  output reg [31:0] Result;
  output wire [3:0] Flags;
  wire neg;
  wire zero;
  wire carry;
  wire overflow;
  wire [31:0] condinvb;
  wire [32:0] sum;
  assign condinvb = (ALUControl[0] ? ~b : b);
  assign sum = (a + condinvb) + ALUControl[0];
  always @(*) begin
    if (_sv2v_0);
    casex (ALUControl[1:0])
      2'b0z: Result = sum;
      2'b10: Result = a & b;
      2'b11: Result = a | b;
    endcase
  end
  assign neg = Result[31];
  assign zero = Result == 32'b00000000000000000000000000000000;
  assign carry = (ALUControl[1] == 1'b0) & sum[32];
  assign overflow = ((ALUControl[1] == 1'b0) & ~((a[31] ^ b[31]) ^ ALUControl[0])) & (a[31] ^ sum[31]);
  assign Flags = {neg, zero, carry, overflow};
  initial _sv2v_0 = 0;
endmodule