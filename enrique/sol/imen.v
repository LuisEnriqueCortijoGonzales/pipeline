module imem (
    a,
    rd
);
  input wire [31:0] a;
  output wire [31:0] rd;
  reg [31:0] RAM[2097151:0];
  initial $readmemh("memfile.dat", RAM);
  assign rd = RAM[a[22:2]];
endmodule