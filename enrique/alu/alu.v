// File: alu/alu.v
// Arithmetic Logic Unit (ALU) module performing arithmetic and logical operations


// changes for division:
//     - extend the ALUControl to 3 bits
//     - Modified alu encoding:
//         - 000: Addition
//         - 001: Subtraction
//         - 100: Bitwise AND
//         - 110: Bitwise OR
//         - 101: signed division
//         - 111: unsigned division

module alu (
    input       [31:0] a,           // Operand A
    input       [31:0] b,           // Operand B
    input       [ 2:0] ALUControl,  // ALU control signal
    output reg  [31:0] Result,      // ALU result
    output wire [ 3:0] ALUFlags     // ALU Flags: {Negative, Zero, Carry, Overflow}
);
  // Internal wires
  wire        neg_flag;  // Negative flag
  wire        zero_flag;  // Zero flag
  wire        carry_flag;  // Carry flag
  wire        overflow_flag;  // Overflow flag
  wire [31:0] inverted_b;  // Inverted B for subtraction
  wire [32:0] sum;  // Sum including carry

  // Compute inverted B if ALUControl[0] is set (for subtraction)
  assign inverted_b = ALUControl[0] ? ~b : b;

  // Compute sum with carry-in (ALUControl[0])
  assign sum = a + inverted_b + ALUControl[0];


  /// DIVISION

  // Signed division handling
  wire signed [31:0] a_signed = a;
  wire signed [31:0] b_signed = b;
  wire [31:0] sdiv;
  assign sdiv = (b_signed != 0) ? (a_signed / b_signed) : 32'd0;

  // Unsigned division handling
  wire [31:0] udiv_result;
  assign udiv = (b != 0) ? (a / b) : 32'd0;

  // ALU operation based on ALUControl
  always @(*) begin
    case (ALUControl[2:0])
      3'b000, 3'b001: Result = sum;  // Addition or Subtraction
      3'b100:         Result = a & b;  // Bitwise AND
      3'b110:         Result = a | b;  // Bitwise OR
      3'b101:         Result = sdiv;  // signed division
      3'b111:         Result = udiv;  // unsigned division
    endcase
  end

  // Generate ALU Flags
  assign neg_flag = Result[31];  // Negative flag
  assign zero_flag = (Result == 32'd0);  // Zero flag
  assign carry_flag = (ALUControl[2] == 1'b0) & sum[32];  // Carry flag for addition/subtraction
  assign overflow_flag = (ALUControl[2] == 1'b0) & ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ sum[31]); // Overflow flag
  // same

  // Assign flags to ALUFlags output
  assign ALUFlags = {neg_flag, zero_flag, carry_flag, overflow_flag};

endmodule
