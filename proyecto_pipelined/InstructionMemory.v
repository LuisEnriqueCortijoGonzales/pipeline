module InstructionMemory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);
  // Declaración de un array de memoria que almacena las instrucciones
  // Cada instrucción tiene 32 bits y la memoria puede almacenar hasta 2,097,152 instrucciones
  reg [31:0] RAM[2097151:0];
  // Bloque inicial que carga las instrucciones desde un archivo externo
  // 'memfile.dat' contiene las instrucciones en formato hexadecimal
  initial $readmemh("memfile.dat", RAM);
  // Asignación de la instrucción de salida
  // La dirección se ajusta para acceder a la instrucción correcta en la memoria
  assign instruction = RAM[address[22:2]];
endmodule
