module alu (
    input wire [DATA_WIDTH-1:0] a,
    input wire [DATA_WIDTH-1:0] b,
    input wire [ALUCONTROL_WIDTH-1:0] ALUControl,
    input wire CarryIn,  // Carry used for ADC, SBC, etc.
    output reg [DATA_WIDTH-1:0] Result,
    output wire [ALUCONTROL_WIDTH-1:0] ALUFlags
);

  parameter ALUCONTROL_WIDTH = 5;
  localparam ALU_FLAGS_WIDTH = 5;
  parameter DATA_WIDTH = 32;

  // ALUControl Encodings
  localparam ADD = 5'b00000;
  localparam ADC = 5'b00001;
  localparam QADD = 5'b00010;

  localparam SUB = 5'b00011;
  localparam SBC = 5'b00100;
  localparam RSB = 5'b00101;
  localparam QSUB = 5'b00110;

  localparam MUL = 5'b00111;
  // More complex multiplications are implemented in the mac module
  // localparam MLA    = 5'b01000;
  // localparam MLS    = 5'b01001;
  // localparam UMULL  = 5'b01010;
  // localparam UMLAL  = 5'b01011;
  // localparam SMULL  = 5'b01100;
  // localparam SMLAL  = 5'b01101;

  localparam UDIV = 5'b01110;
  localparam SDIV = 5'b01111;

  localparam AND_OP = 5'b10000;
  localparam BIC = 5'b10001;
  localparam ORR = 5'b10010;
  localparam ORN = 5'b10011;
  localparam EOR = 5'b10100;

  localparam CMN = 5'b10101;
  localparam TST = 5'b10110;
  localparam TEQ = 5'b10111;
  localparam CMP = 5'b11000;

  localparam MOV = 5'b11001;
  localparam LSHIFT = 5'b11100;
  localparam RSHIFT = 5'b11010;
  localparam ASHIFT = 5'b11011;
  localparam ROR = 5'b11101;
  localparam RRX = 5'b11110;


  // Flag bits
  wire neg;
  wire zero;
  wire carry;
  wire overflow;
  wire saturated;

  localparam SATURATED_MAX = 32'h7FFFFFFF;  // 2,147,483,648
  localparam SATURATED_MIN = 32'h80000000;  // -2,147,483,648


  // Temporal/Result wires
  wire [DATA_WIDTH:0] extended_add;
  wire [DATA_WIDTH:0] extended_sub;
  wire [4:0] shift_amount;
  wire [DATA_WIDTH-1:0] sdiv_result;
  wire [DATA_WIDTH-1:0] udiv_result;




  assign shift_amount = b[4:0];  // max shift amount is 32

  assign extended_add = {1'b0, a} + {1'b0, b};
  assign extended_sub = {1'b0, a} - {1'b0, b};

  // the added complexity should be fine right?
  assign sdiv_result  = (b != 0) ? ($signed(a) / $signed(b)) : 32'b0;
  assign udiv_result  = (b != 0) ? (a / b) : 32'b0;

  // Bloque always para determinar el resultado basado en ALUControl
  always @(*) begin
    casex (ALUControl)
      ADD: Result = a + b;
      ADC: Result = a + b + CarryIn;
      QADD:
      Result = extended_add > SATURATED_MAX ? SATURATED_MAX : (extended_add < SATURATED_MIN ? SATURATED_MIN : extended_add[DATA_WIDTH-1: 0]);

      SUB: Result = a - b;
      SBC: Result = a - b - ~CarryIn;
      RSB: Result = b - a;
      QSUB:
      Result = extended_sub > SATURATED_MAX ? SATURATED_MAX : (extended_sub < SATURATED_MIN ? SATURATED_MIN : extended_sub[DATA_WIDTH-1: 0]);

      MUL: Result = a * b;
      // More complex multiplications are implemented in the mac module

      UDIV: Result = udiv_result;
      SDIV: Result = sdiv_result;

      AND_OP: Result = a & b;
      BIC: Result = a & ~b;
      ORR: Result = a | b;
      ORN: Result = a | ~b;
      EOR: Result = a ^ b;

      CMN: Result = a + b;
      TST: Result = a & b;
      TEQ: Result = a ^ b;
      CMP: Result = a - b;
      MOV: Result = b;

      LSHIFT: Result = a << shift_amount;
      ASHIFT: Result = $signed(a) >>> shift_amount;
      RSHIFT: Result = a >> shift_amount;
      ROR: Result = (a >> shift_amount) | (a << (DATA_WIDTH - shift_amount));
      RRX: Result = {CarryIn, a[DATA_WIDTH-1:1]};
      default: Result = 32'b0;

    endcase
  end

  // Flag wires
  wire carry_sub = a[0];  // LSB
  wire carry_adc = (a[0] & b[0]) | (b[0] & Result[0]) | (Result[0] & a[0]);
  wire carry_sbc = ~a[0] & b[0] | b[0] & Result[0] | Result[0] & ~a[0];
  wire carry_shift = (ALUControl == LSHIFT) ? a[DATA_WIDTH-shift_amount] :
                     (ALUControl == RSHIFT) ? a[shift_amount-1] :
                     (ALUControl == ASHIFT) ? a[DATA_WIDTH-1] :
                     1'b0;

  // Asignación de los flags de estado
  assign neg = Result[DATA_WIDTH-1];
  assign zero = (Result == 0);

  // TODO: Simplify with overflow flag?
  assign saturated = (ALUControl == QADD) ?
      // sum overflow
      ((extended_add[DATA_WIDTH] != extended_add[DATA_WIDTH-1])) : (ALUControl == QSUB) ?
      // sub overflow
      ((extended_sub[DATA_WIDTH] != extended_sub[DATA_WIDTH-1])) : 1'b0;


  assign carry = (ALUControl == ADD)    ? extended_add[DATA_WIDTH] :
                (ALUControl == SUB)    ? extended_sub[DATA_WIDTH] :
                   (ALUControl == ADC)    ? carry_adc :
                   (ALUControl == SBC)    ? carry_sbc :
                   (ALUControl == LSHIFT || ALUControl == RSHIFT || ALUControl == ASHIFT) ? carry_shift :
                   1'b0;



  assign overflow = ((ALUControl[1] == 1'b0) & ~((a[31] ^ b[31]) ^ ALUControl[0])) & (a[31] ^ extended_add[31]); // Indica si hubo desbordamiento


  // Combinación de los flags en un solo bus de salida
  assign ALUFlags = {neg, zero, CarryIn, overflow, saturated};
endmodule
