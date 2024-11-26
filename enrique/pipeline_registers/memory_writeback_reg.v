// File: pipeline_registers/memory_writeback.v
// Flip-flop for the memory_writeback stage of the pipeline.


parameter DATA_WIDTH = 32;
parameter WA3_WIDTH = 32;
parameter ALU_FLAGS_WIDTH = 4;

module memory_writeback_reg (
    input wire i_clk,   // Clock signal
    input wire i_reset, // Reset signal

    // Controller

    // 1 PCSrc
    input  wire i_PCSrc_M,
    output reg  o_PCSrc_W,
    // 1 RegWrite
    input  wire i_RegWrite_M,
    output reg  o_RegWrite_W,
    // 1 MemToReg
    input  wire i_MemToReg_M,
    output reg  o_MemToReg_W,


    // Datapath

    // 32 Data read from memory
    input  wire [DATA_WIDTH - 1 : 0] i_ReadData_M,
    output reg  [DATA_WIDTH - 1 : 0] o_ReadData_W,

    // 32 ALU result
    input  wire [DATA_WIDTH - 1 : 0] i_ALUOut_M,
    output reg  [DATA_WIDTH - 1 : 0] o_ALUOut_W,

    // 4
    input  wire [WA3_WIDTH - 1 : 0] i_WA3_E,
    output reg  [WA3_WIDTH - 1 : 0] o_WA3_M


);

  // Register Size = 1 + 1 + 1 + 1 + 32 + 32 + 4 = 72

  parameter REGISTER_SIZE = 72;


  wire [REGISTER_SIZE-1:0] FETCH_IN;
  wire [REGISTER_SIZE-1:0] FETCH_OUT;


  assign FETCH_IN = {
    i_PCSrc_M, i_RegWrite_M, i_MemToReg_M, i_MemWrite_E, i_ALUResult_E, i_DataToMemory_E, i_WA3_E
  };
  assign {
    o_PCSrc_W,
    o_RegWrite_W,
    o_MemToReg_W,
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
