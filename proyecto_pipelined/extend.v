module extend (
    Instr, // Instrucción de entrada de 24 bits
    ImmSrc, // Fuente del inmediato, determina cómo extender la instrucción
    ExtImm // Inmediato extendido de salida de 32 bits
);
  input wire [23:0] Instr; // Instrucción de entrada
  input wire [1:0] ImmSrc; // Selección de la fuente del inmediato
  output reg [31:0] ExtImm; // Inmediato extendido de salida

  // El módulo 'extend' toma una parte de la instrucción y la extiende
  // a 32 bits según el tipo de instrucción. Esto es necesario para
  // operaciones que requieren un inmediato de 32 bits.

  always @(*) begin
    // Selección de la extensión basada en 'ImmSrc'
    case (ImmSrc)
      2'b00: 
        // Extensión para instrucciones que usan un inmediato de 8 bits
        // Se extiende con ceros a la izquierda
        ExtImm = {24'b000000000000000000000000, Instr[7:0]};
      2'b01: 
        // Extensión para instrucciones que usan un inmediato de 12 bits
        // Se extiende con ceros a la izquierda
        ExtImm = {20'b00000000000000000000, Instr[11:0]};
      2'b10: 
        // Extensión para instrucciones que usan un inmediato de 24 bits
        // Se extiende con el bit de signo (signo extendido)
        ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'b00};
      default: 
        // Valor por defecto en caso de una selección no válida
        ExtImm = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
    endcase
  end
    // Declare end
endmodule
