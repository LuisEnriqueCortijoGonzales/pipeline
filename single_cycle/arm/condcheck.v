// File: arm/condcheck.v
// Condition Checker module that evaluates condition codes against flags

module condcheck (
    input  wire [3:0] Cond,   // Condition field
    input  wire [3:0] Flags,  // Current processor flags
    output reg        CondEx  // Condition Execute signal
);
  // Individual flag signals
  wire neg;  // Negative flag
  wire zero;  // Zero flag
  wire carry;  // Carry flag
  wire overflow;  // Overflow flag
  wire ge;  // Greater or Equal flag

  // Assign flags
  assign {neg, zero, carry, overflow} = Flags;

  // Compute GE (Greater or Equal) flag based on N and V flags
  assign ge = (neg == overflow);

  // Evaluate condition based on Cond field
  always @(*) begin
    case (Cond)
      4'b0000: CondEx = zero;  // EQ: Equal
      4'b0001: CondEx = ~zero;  // NE: Not Equal
      4'b0010: CondEx = carry;  // CS/HS: Carry Set/Unsigned Higher or Same
      4'b0011: CondEx = ~carry;  // CC/LO: Carry Clear/Unsigned Lower
      4'b0100: CondEx = neg;  // MI: Minus/Negative
      4'b0101: CondEx = ~neg;  // PL: Plus/Positive or Zero
      4'b0110: CondEx = overflow;  // VS: Overflow
      4'b0111: CondEx = ~overflow;  // VC: No Overflow
      4'b1000: CondEx = carry & ~zero;  // HI: Unsigned Higher
      4'b1001: CondEx = ~(carry & ~zero);  // LS: Unsigned Lower or Same
      4'b1010: CondEx = ge;  // GE: Signed Greater Than or Equal
      4'b1011: CondEx = ~ge;  // LT: Signed Less Than
      4'b1100: CondEx = ~zero & ge;  // GT: Signed Greater Than
      4'b1101: CondEx = ~(~zero & ge);  // LE: Signed Less Than or Equal
      4'b1110: CondEx = 1'b1;  // AL: Always (unconditional)
      default: CondEx = 1'bx;  // Undefined condition
    endcase
  end

endmodule
