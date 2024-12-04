module DataMemory #(
    parameter MEMFILE = "memfile.dat",
    parameter USE_HARDCODED = 1
) (
    input wire clk,
    input wire we,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);
  localparam NOP = 32'b00001000000000000000000000000000;

  reg [31:0] RAM[0:50];

  localparam FIBONACCI_N = 8'd13;
  localparam INSTRUCTION_COUNT = 20;

  initial begin
    if (USE_HARDCODED) begin
      // Hardcoded instructions
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
    end else begin
      // Dynamically load instructions from a file
      $readmemh(MEMFILE, RAM);
    end
  end

  // Left Shift 2 == * 4 == * word size
  assign read_data = RAM[address[22:2]];
  always @(posedge clk) if (we) RAM[address[22:2]] <= write_data;
endmodule
