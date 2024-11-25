module alu (
    input wire [31:0] a, // Primer operando de entrada de 32 bits
    input wire [31:0] b, // Segundo operando de entrada de 32 bits
    input wire [1:0] ALUControl, // Señal de control de 2 bits para seleccionar la operación
    output reg [31:0] Result, // Resultado de la operación de 32 bits
    output wire [3:0] Flags // Bandera de 4 bits que indica el estado del resultado
);
  reg _sv2v_0; // Registro interno para control (no utilizado)
  wire neg; // Bandera de negativo
  wire zero; // Bandera de cero
  wire carry; // Bandera de acarreo
  wire overflow; // Bandera de desbordamiento
  wire [31:0] condinvb; // B condicionado e invertido
  wire [32:0] sum; // Resultado de la suma con acarreo

  // Condicionalmente invierte 'b' si ALUControl[0] es 1, de lo contrario deja 'b' sin cambios
  assign condinvb = (ALUControl[0] ? ~b : b);

  // Calcula la suma de 'a' y 'condinvb', incluyendo el acarreo si ALUControl[0] es 1
  assign sum = (a + condinvb) + ALUControl[0];

  // Bloque siempre activo que selecciona la operación a realizar basada en ALUControl
  always @(*) begin
    if (_sv2v_0); // Línea sin efecto, posiblemente un remanente
    casex (ALUControl[1:0])
      2'b0z: Result = sum; // Realiza la suma o resta
      2'b10: Result = a & b; // Realiza la operación AND
      2'b11: Result = a | b; // Realiza la operación OR
    endcase
  end

  // Calcula las banderas basadas en el resultado
  assign neg = Result[31]; // Bandera de negativo, se activa si el bit más significativo es 1
  assign zero = Result == 32'b0; // Bandera de cero, se activa si el resultado es cero
  assign carry = (ALUControl[1] == 1'b0) & sum[32]; // Bandera de acarreo, se activa si hay un acarreo en la suma
  assign overflow = ((ALUControl[1] == 1'b0) & ~((a[31] ^ b[31]) ^ ALUControl[0])) & (a[31] ^ sum[31]); // Bandera de desbordamiento

  // Asigna las banderas al bus de salida Flags
  assign Flags = {neg, zero, carry, overflow};
endmodule