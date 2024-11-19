// File: registro 2
// Flip-Flop module with synchronous reset
module registro2(
    input  wire             clk,    // Clock signal
    input  wire             reset,  // Reset signal
    input  wire PCSrcD,        // Program Counter source selector
    input  wire MemtoRegD,    // Memory to Register selector
    input  wire MemWriteD,    // Memory write enable
    input  wire [2:0] ALUControlD,  // ALU operation control
    input  wire ALUSrcD,      // ALU source selector
    input  wire RegWriteD,    // Register write enable
    input  wire [1:0] FlagWriteD,
    input  wire BranchD,
    input  wire [31:0] Rd1D,      // Data input
    input  wire [31:0] Rd2D,      // Data input
    output  reg PCSrcE,        // Program Counter source selector
    output  reg MemtoRegE,    // Memory to Register selector
    output  reg MemWriteE,    // Memory write enable
    output  reg [2:0] ALUControlE,  // ALU operation control
    output  reg ALUSrcE,      // ALU source selector
    output  reg RegWriteE,    // Register write enable
    output  reg [1:0] FlagWriteE,
    output  reg BranchE,
    output  reg [31:0] Rd1E,      // Data input
    output  reg [31:0] Rd2E       // Data input
);
  always @(posedge clk or posedge reset) begin
    if (reset) begin
        PCSrcE<= 1'b0;
        MemtoRegE <= 1'b0; 
        MemWriteE <= 1'b0;
        ALUControlE <= 2'b00;
        ALUSrcE <= 1'b0;
        RegWriteE <= 1'b0;
        FlagWriteE <= 2'b00;
        BranchE <= 1'b0;
        Rd1E <= 32'b0;
        Rd2E <= 32'b0;
    end else begin
        PCSrcE<= PCSrcD;
        MemtoRegE <= MemtoRegD; 
        MemWriteE <= MemWriteD;
        ALUControlE <= ALUControlD;
        ALUSrcE <= ALUSrcD;
        RegWriteE <= RegWriteD;
        FlagWriteE <= FlagWriteD;
        BranchE <= BranchD;
        Rd1E <= Rd1D;
        Rd2E <= Rd2D;
    end
  end
endmodule
