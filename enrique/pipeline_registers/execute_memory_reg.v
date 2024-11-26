// File: pipeline_registers/execute_memory.v
// Flip-flop for the execute_memory stage of the pipeline.


parameter DATA_WIDTH = 32;
parameter WA3_WIDTH = 32;
parameter ALU_FLAGS_WIDTH = 4;

module execute_memory_reg (
    input wire i_clk,   // Clock signal
    input wire i_reset, // Reset signal

    // Controller

    // 1 PCSrc
    input  wire i_PCSrc_E,
    output reg  o_PCSrc_M,
    // 1 RegWrite
    input  wire i_RegWrite_E,
    output reg  o_RegWrite_M,
    // 1 MemToReg
    input  wire i_MemToReg_E,
    output reg  o_MemToReg_M,

    // 1 MemWrite
    input  wire i_MemWrite_E,
    output reg  o_MemWrite_M,


    // Datapath

    // 32 ALU result
    input  wire [DATA_WIDTH - 1 : 0] i_ALUResult_E,
    output reg  [DATA_WIDTH - 1 : 0] o_ALUResult_M,

    // 32 Data to write to memory
    input  wire [DATA_WIDTH - 1 : 0] i_DataToMemory_E,
    output reg  [DATA_WIDTH - 1 : 0] o_DataToMemory_M,

    // 4
    input  wire [WA3_WIDTH - 1 : 0] i_WA3_E,
    output reg  [WA3_WIDTH - 1 : 0] o_WA3_M

);

  // Register Size = 1 + 1 + 1 + 1 + 32 + 32 + 4 = 72

  parameter REGISTER_SIZE = 72;


  wire [REGISTER_SIZE-1:0] FETCH_IN;
  wire [REGISTER_SIZE-1:0] FETCH_OUT;


  assign FETCH_IN = {
    i_PCSrc_E, i_RegWrite_E, i_MemToReg_E, i_MemWrite_E, i_ALUResult_E, i_DataToMemory_E, i_WA3_E
  };
  assign {
    o_PCSrc_M,
    o_RegWrite_M,
    o_MemToReg_M,
    o_MemWrite_M,
    o_ALUResult_M,
    o_DataToMemory_M,
    o_WA3_M
    } = FETCH_OUT;


  flopr #(REGISTER_SIZE) fetch_register (
      .clk(clk),
      .reset(reset),
      .d(FETCH_IN),
      .q(FETCH_OUT)
  );


endmodule
