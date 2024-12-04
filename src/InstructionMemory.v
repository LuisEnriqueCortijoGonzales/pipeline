module InstructionMemory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

  // Declaración de un array de memoria que almacena las instrucciones
  // Cada instrucción tiene 32 bits y la memoria puede almacenar hasta 2,097,152 instrucciones
  reg [31:0] RAM[50:0];

  localparam FIBONACCI_N = 8'd13;

  localparam INSTRUCTION_COUNT = 9;

  localparam NOP = 32'b00001000000000000000000000000000;
  initial begin
    // MOV     R0, #5
    RAM[0] = {24'hEF2000, FIBONACCI_N - 8'd1};
    // MOV     R1, #0
    RAM[1] = 32'hEF201000;
    // MOV     R2, #1
    RAM[2] = 32'hEF202001;
    // CMP     R0, #1
    RAM[3] = 32'hEF100001;
    // BLS     4
    RAM[4] = 32'h94000004;
    // ADD     R3, R1, R2
    RAM[5] = 32'hE8013002;
    // MOV     R1, R2
    RAM[6] = 32'hED201002;
    // MOV     R2, R3
    RAM[7] = 32'hED202003;
    // SUBS    R0, R0, #1
    RAM[8] = 32'hEA700001;
    // BGT     -6
    RAM[9] = 32'hC4FFFFFA;
    // RAM[9] = 32'hC400000A;
  end
  // La dirección se ajusta para acceder a la instrucción correcta en la memoria
  // assign instruction = RAM[address[22:2]];
  // consider nop for invalid address or empty (x) value in ram
  assign instruction = (address[22:2] <= INSTRUCTION_COUNT) ? RAM[address[22:2]] : NOP;


endmodule
