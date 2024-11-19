// File: dmem.v
// Data Memory module with synchronous write and combinational read

module dmem (
    input  wire        clk,         // Clock signal
    input  wire        we,          // Write enable
    input  wire [31:0] address,     // Address for memory access
    input  wire [31:0] write_data,  // Data to write to memory
    output wire [31:0] read_data    // Data read from memory
);
  // Memory array: 64 words of 32 bits each
  reg [31:0] RAM[63:0];

  // Read operation: combinational read based on address
  assign read_data = RAM[address[31:2]];

  // Write operation: synchronous write on positive clock edge
  always @(posedge clk) begin
    if (we) begin
      RAM[address[31:2]] <= write_data;
    end
  end

endmodule
