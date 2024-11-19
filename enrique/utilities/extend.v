// File: utilities/extend.v
// Immediate Value Extension module for different immediate formats

module extend (
    input  wire [23:0] Instr,   // Instruction bits containing immediate value
    input  wire [ 1:0] ImmSrc,  // Immediate source selector
    output reg  [31:0] ExtImm   // Extended immediate value
);
  always @(*) begin
    case (ImmSrc)
      2'b00: begin
        // Zero-extend 8-bit immediate
        ExtImm = {24'd0, Instr[7:0]};
      end
      2'b01: begin
        // Zero-extend 12-bit immediate
        ExtImm = {20'd0, Instr[11:0]};
      end
      2'b10: begin
        // Sign-extend 24-bit immediate and shift left by 2 (for branch offsets)
        ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'd0};
      end
      default: begin
        // Undefined immediate extension
        ExtImm = 32'bx;
      end
    endcase
  end

endmodule
