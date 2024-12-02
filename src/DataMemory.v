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
  initial $readmemh(MEMFILE, RAM);
  assign read_data = RAM[address[22:2]];
  always @(posedge clk) if (we) RAM[address[22:2]] <= write_data;
endmodule
