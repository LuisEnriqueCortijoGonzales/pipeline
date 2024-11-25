module conditional (
    Cond,
    Flags,
    ALUFlags,
    FlagsWrite,
    CondEx,
    FlagsNext
);
  reg _sv2v_0;
  input wire [3:0] Cond;
  input wire [3:0] Flags;
  input wire [3:0] ALUFlags;
  input wire [1:0] FlagsWrite;
  output reg CondEx;
  output wire [3:0] FlagsNext;
  wire neg;
  wire zero;
  wire carry;
  wire overflow;
  wire ge;
  assign {neg, zero, carry, overflow} = Flags;
  assign ge = neg == overflow;
  always @(*) begin
    if (_sv2v_0);
    case (Cond)
      4'b0000: CondEx = zero;
      4'b0001: CondEx = ~zero;
      4'b0010: CondEx = carry;
      4'b0011: CondEx = ~carry;
      4'b0100: CondEx = neg;
      4'b0101: CondEx = ~neg;
      4'b0110: CondEx = overflow;
      4'b0111: CondEx = ~overflow;
      4'b1000: CondEx = carry & ~zero;
      4'b1001: CondEx = ~(carry & ~zero);
      4'b1010: CondEx = ge;
      4'b1011: CondEx = ~ge;
      4'b1100: CondEx = ~zero & ge;
      4'b1101: CondEx = ~(~zero & ge);
      4'b1110: CondEx = 1'b1;
      default: CondEx = 1'bx;
    endcase
  end
  assign FlagsNext[3:2] = (FlagsWrite[1] & CondEx ? ALUFlags[3:2] : Flags[3:2]);
  assign FlagsNext[1:0] = (FlagsWrite[0] & CondEx ? ALUFlags[1:0] : Flags[1:0]);
  initial _sv2v_0 = 0;
endmodule