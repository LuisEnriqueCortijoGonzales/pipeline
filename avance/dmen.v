module dmem (
    clk,
    we,
    a,
    wd,
    rd
);
  input wire clk;
  input wire we;
  input wire [31:0] a;
  input wire [31:0] wd;
  output wire [31:0] rd;
  reg [31:0] RAM[2097151:0];
  initial $readmemh("memfile.dat", RAM);
  assign rd = RAM[a[22:2]];
  always @(posedge clk) if (we) RAM[a[22:2]] <= wd;
endmodule