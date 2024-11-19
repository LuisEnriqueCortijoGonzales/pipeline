// File: register_file/regfile.v
// Register File module with 15 general-purpose registers and a link register (R15)

module regfile (
    input  wire        clk,  // Clock signal
    input  wire        we3,  // Write enable for port 3
    input  wire [ 3:0] ra1,  // Read address 1
    input  wire [ 3:0] ra2,  // Read address 2
    input  wire [ 3:0] wa3,  // Write address 3
    input  wire [31:0] wd3,  // Write data 3
    input  wire [31:0] r15,  // Link register data (R15)
    output wire [31:0] rd1,  // Read data 1
    output wire [31:0] rd2   // Read data 2
);
  // Register file: 15 general-purpose registers (R0 - R14)
  reg [31:0] rf[14:0];

  // Write operation: synchronous write on positive clock edge
  always @(posedge clk) begin
    if (we3) begin
      rf[wa3] <= wd3;  // Write data to specified register
    end
  end

  // Read operation 1: if ra1 is R15 (1111), return r15; else, return register value
  assign rd1 = (ra1 == 4'd15) ? r15 : rf[ra1];

  // Read operation 2: if ra2 is R15 (1111), return r15; else, return register value
  assign rd2 = (ra2 == 4'd15) ? r15 : rf[ra2];

endmodule
