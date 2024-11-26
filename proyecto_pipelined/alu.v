module alu (
    a,  // Primer operando de entrada
    b,  // Segundo operando de entrada
    ALUControl,  // Señal de control que determina la operación a realizar
    Result,  // Resultado de la operación
    Flags  // Flags de estado resultantes de la operación
);
  input wire [31:0] a;  // Entrada 'a' de 32 bits
  input wire [31:0] b;  // Entrada 'b' de 32 bits
  input wire [1:0] ALUControl;  // Señal de control de 2 bits para seleccionar la operación
  output reg [31:0] Result;    // Salida 'Result' de 32 bits que contiene el resultado de la operación
  output wire [3:0] Flags;  // Salida 'Flags' de 4 bits que contiene los flags de estado

  // Declaración de wires para los flags individuales
  wire        neg;  // Flag de negativo
  wire        zero;  // Flag de cero
  wire        carry;  // Flag de acarreo
  wire        overflow;  // Flag de desbordamiento

  // Wire para el valor condicionalmente invertido de 'b'
  wire [31:0] condinvb;
  // Wire para el resultado de la suma extendida a 33 bits para detectar acarreo
  wire [32:0] sum;

  // Asignación condicional de 'b' basado en ALUControl[0]
  assign condinvb = (ALUControl[0] ? ~b : b);
  // Realiza la suma de 'a' y 'condinvb', incluyendo el bit de acarreo
  assign sum = (a + condinvb) + ALUControl[0];

  // Bloque always para determinar el resultado basado en ALUControl
  always @(*) begin
    casex (ALUControl[1:0])
      2'b0z:   Result = sum;  // Operación de suma/resta
      2'b10:   Result = a & b;  // Operación AND
      2'b11:   Result = a | b;  // Operación OR
      default: Result = 32'bx;  // Valor indefinido para otras combinaciones
    endcase
  end

  // Asignación de los flags de estado
  assign neg = Result[31];  // El bit más significativo indica si el resultado es negativo
  assign zero = (Result == 32'b0);  // Indica si el resultado es cero
  assign carry = (ALUControl[1] == 1'b0) & sum[32];  // Indica si hubo acarreo en la suma
  assign overflow = ((ALUControl[1] == 1'b0) & ~((a[31] ^ b[31]) ^ ALUControl[0])) & (a[31] ^ sum[31]); // Indica si hubo desbordamiento

  // Combinación de los flags en un solo bus de salida
  assign Flags = {neg, zero, carry, overflow};
endmodule
