// File: alu/alu.v
// Arithmetic Logic Unit (ALU) module performing arithmetic and logical operations


// changes for division:
//     - extend the ALUControl to 3 bits
//     - Modified alu encoding:
//         - 0000: Addition
//         - 0001: Subtraction
//         - 0010: Multiplication
//         - 0011: Unsigned division
//         - 0100: signed division
//         - 0101: Bitwise AND
//         - 0110: Bitwise OR
//         - 0111: XOR
//         - 1000: NOT
//         - 1001: LSL
//         - 1010: LSR
//         - 1011: ASR
//         - 1100: Igualdad
//         - 1101: Mayor
//         - 1110: Menor
//         - 1111: Por defecto


module alu (
    input       [31:0] a,           // Operand A
    input       [31:0] b,           // Operand B
    input       [ 3:0] ALUControl,  // ALU control signal
    output reg  [31:0] Result,      // ALU result
    output wire [ 3:0] ALUFlags     // ALU Flags: {Negative, Zero, Carry, Overflow}
);
  // Internal wires
  wire        neg_flag;  // Negative flagQuick Access
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
  wire [31:0] udiv;
  assign udiv = (b != 0) ? (a / b) : 32'd0;
  
  /// MULTIPLICATION
  wire [31:0] mul;
  assign mul = (a == 0 || b==0) ? 32'd0 : (a*b);
  
  // ALU operation based on ALUControl
  always @(*) begin
    case (ALUControl[3:0])
      4'b0000, 3'b001: Result = sum;  // Addition or Subtraction ADD/SUB
      4'b0101:         Result = a & b;  // Bitwise AND 
      4'b0110:         Result = a | b;  // Bitwise ORR
      4'b0100:         Result = sdiv;  // signed division SDIV
      4'b0011:         Result = udiv;  // unsigned division UDIV
      4'b0010:         Result = mul;  // multiplication MUL
      4'b0111:         Result = (a*(~b))+((~a)*b); //XOR
      4'b1000:         Result = ~a; //NOT o negate para logica
      4'b1001:         Result = a << b[4:0]; //LSL
      4'b1010:         Result = a >> b[4:0]; //LSR
      4'b1011:         Result = $signed(a) >> b[4:0]; // ASR
      4'b1100:         Result = (a==b) ? 32'd1: 32'd0;//Igualdad para logica
      4'b1101:         Result = (a>b) ? 32'd1: 32'd0; //Mayor para logica
      4'b1110:         Result =  (a<b) ? 32'd1: 32'd0;//Menor para logica
      4'b1111:         Result =  32'd0;//meme
      
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
