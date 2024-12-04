`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    NextPC
// Description:
//      This module encapsulates the Program Counter (PC) selection logic for an
//      ARMv7 pipelined processor. It selects the next PC based on branch predictions,
//      actual branch outcomes, and handles mispredictions to ensure correct instruction
//      execution flow.
//////////////////////////////////////////////////////////////////////////////////

module NextPC (
    input wire clk,   // Clock signal
    input wire reset, // Reset signal

    // Next immediate PC
    input wire [31:0] PCPlus4F,


    input wire is_branchF,

    input wire        PredictTakenF,     // Prediction: 1 = taken, 0 = not taken
    input wire [31:0] PredictedBranchPC,

    // Execute stage results
    input wire BranchTakenE,  // Actual branch outcome from EX stage: 1 = taken, 0 = not taken
    input wire [31:0] ALUResultE,  // Actual branch target computed in EX stage

    // Misprediction correction
    input  wire        WrongPredictionE,        // Misprediction detected: 1 = mispredicted, 0 = correct prediction
    input wire [31:0] PCPlus8E,  // Stored PC+8 of the branch instruction, used to revert mispredictions

    output wire [31:0] next_pc  // Next Program Counter
);

  wire [31:0] mux1_out;  // Output of Mux1
  wire [31:0] mux2_out;  // Output of Mux2
  wire [31:0] corrected_pc;

  // Mux1: Select between predicted branch target and PC + 8 based on prediction
  // If prediction is taken, select predicted_branch_target
  // Else, select PC + 8 (next sequential instruction considering pipeline depth)
  assign mux1_out = PredictTakenF ? PredictedBranchPC : PCPlus4F;

  // Mux2: Select between Mux1 output and actual branch target based on actual branch outcome
  // If branch is actually taken, select alu_result_ex
  // Else, select Mux1 output
  assign mux2_out = BranchTakenE ? ALUResultE : mux1_out;

  // Corrected PC in case of misprediction
  // If branch was actually taken, use alu_result_ex
  // Else, use branch_pc + 8 to resume correct sequential execution
  assign corrected_pc = BranchTakenE ? ALUResultE : (PCPlus8E - 32'd4);


  // always @(*) begin
  //   if (reset) begin
  //     next_pc = 32'd0;  // Initialize PC to 0 on reset
  //   end else if (!is_branchF) begin
  //     next_pc = PCPlus4F;
  //   end else if (WrongPredictionE) begin
  //     next_pc = corrected_pc;  // Correct the PC upon misprediction
  //   end else begin
  //     next_pc = mux2_out;  // Use normal branch prediction logic
  //   end
  // end
  assign next_pc = WrongPredictionE ? corrected_pc : (is_branchF ? mux2_out : PCPlus4F);

endmodule
