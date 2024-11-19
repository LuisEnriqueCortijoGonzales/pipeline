// File: imem.v
// Instruction Memory module with combinational read

module imem (
    input wire [31:0] address,  // Address to fetch instruction from
    output wire [31:0] instruction  // Fetched instruction
);
  // Memory array: 64 words of 32 bits each
  reg [31:0] RAM[0:63];

  // Initialize memory contents from file
  initial begin
    $readmemh("memfile.dat", RAM);
  end

  // Read operation: combinational read based on address
  assign instruction = RAM[address[31:2]];

endmodule
