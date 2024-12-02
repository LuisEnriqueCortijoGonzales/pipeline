module InstructionMemory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

  // Declaración de un array de memoria que almacena las instrucciones
  // Cada instrucción tiene 32 bits y la memoria puede almacenar hasta 2,097,152 instrucciones
  reg [31:0] RAM[50:0];

  //initial $readmemh(MEMFILE, RAM);
  initial begin

    RAM[0] = 32'hEF200005;
    RAM[1] = 32'hEF201001;
    RAM[2] = 32'hEF202001;
    RAM[3] = 32'hEF100001;
    RAM[4] = 32'h94000004;
    RAM[5] = 32'hE8013002;
    RAM[6] = 32'hED201002;
    RAM[7] = 32'hED202003;
    RAM[8] = 32'hEA700001;
    RAM[9] = 32'hC4FFFFFA;
  end
  // La dirección se ajusta para acceder a la instrucción correcta en la memoria
  assign instruction = RAM[address[22:2]];
endmodule
