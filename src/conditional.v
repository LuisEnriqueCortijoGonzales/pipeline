module conditional (
    input  wire [                3:0] Cond,        // Código de condición de 4 bits
    input  wire [ALU_FLAGS_WIDTH-1:0] Flags,       // Flags actuales de 4 bits (N, Z, C, V)
    input  wire [ALU_FLAGS_WIDTH-1:0] ALUFlags,    // Flags generados por la ALU
    input  wire [                1:0] FlagsWrite,  // Control de escritura de flags
    output reg                        CondEx,      // Salida que indica si la condición se cumple
    output wire [ALU_FLAGS_WIDTH-1:0] FlagsNext    // Flags que se escribirán en el siguiente ciclo
);
  localparam ALU_FLAGS_WIDTH = 5;
  // Descomposición de los flags en señales individuales
  wire neg;  // Flag de negativo
  wire zero;  // Flag de cero
  wire overflow;  // Flag de desbordamiento
  wire ge;  // Señal que indica si es mayor o igual
  wire saturated;  // Señal de saturación
  wire carry;

  // Asignación de los flags a las señales individuales
  assign {saturated, neg, zero, carry, overflow} = Flags;
  // Determina si el resultado es mayor o igual (N == V)
  assign ge = neg == overflow;

  // Bloque always para evaluar la condición
  always @(*) begin
    case (Cond)
      4'b0000: CondEx = zero;  // EQ: Igual (Z == 1)
      4'b0001: CondEx = ~zero;  // NE: No igual (Z == 0)
      4'b0010: CondEx = carry;  // CS/HS: Acarreo establecido (C == 1)
      4'b0011: CondEx = ~carry;  // CC/LO: Acarreo limpio (C == 0)
      4'b0100: CondEx = neg;  // MI: Negativo (N == 1)
      4'b0101: CondEx = ~neg;  // PL: Positivo o cero (N == 0)
      4'b0110: CondEx = overflow;  // VS: Desbordamiento (V == 1)
      4'b0111: CondEx = ~overflow;  // VC: Sin desbordamiento (V == 0)
      4'b1000: CondEx = carry & ~zero;  // HI: Mayor sin signo (C == 1 y Z == 0)
      4'b1001: CondEx = ~(carry & ~zero);  // LS: Menor o igual sin signo (C == 0 o Z == 1)
      4'b1010: CondEx = ge;  // GE: Mayor o igual (N == V)
      4'b1011: CondEx = ~ge;  // LT: Menor (N != V)
      4'b1100: CondEx = ~zero & ge;  // GT: Mayor (Z == 0 y N == V)
      4'b1101: CondEx = ~(~zero & ge);  // LE: Menor o igual (Z == 1 o N != V)
      4'b1110: CondEx = 1'b1;  // AL: Siempre (siempre verdadero)
      default: CondEx = 1'bx;  // Condición no definida
    endcase
  end

  // Asignación de los flags que se escribirán en el siguiente ciclo
  assign FlagsNext[3:2] = FlagsWrite[1] & CondEx ? ALUFlags[3:2] : Flags[3:2];
  assign FlagsNext[1:0] = FlagsWrite[0] & CondEx ? ALUFlags[1:0] : Flags[1:0];
endmodule
