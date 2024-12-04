module DataMemory #(
    parameter MEMFILE = "memfile.dat"
) (
    input wire clk,
    input wire we,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);
  reg [31:0] RAM[50:0];

  localparam FIBONACCI_N = 8'd13;

  initial begin

    RAM[0] = {24'hEF2000, FIBONACCI_N - 8'd1};
    RAM[1] = 32'hEF201000;
    RAM[2] = 32'hEF202001;
    RAM[3] = 32'hEF100001;
    RAM[4] = 32'h94000004;
    RAM[5] = 32'hE8013002;
    RAM[6] = 32'hED201002;
    RAM[7] = 32'hED202003;
    RAM[8] = 32'hEA700001;
    RAM[9] = 32'hC4FFFFFA;
  end

  // Left Shift 2 == * 4 == * word size
  assign read_data = RAM[address[22:2]];
  always @(posedge clk) if (we) RAM[address[22:2]] <= write_data;
endmodule
