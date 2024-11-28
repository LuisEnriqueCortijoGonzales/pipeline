module InstructionMemory #(
    parameter MEMFILE = "memfile.dat"
) (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

  // Declaración de un array de memoria que almacena las instrucciones
  // Cada instrucción tiene 32 bits y la memoria puede almacenar hasta 2,097,152 instrucciones
  reg [31:0] RAM[0:2097151];

  initial $readmemh(MEMFILE, RAM);
  // La dirección se ajusta para acceder a la instrucción correcta en la memoria
  assign instruction = RAM[address[22:2]];
endmodule
