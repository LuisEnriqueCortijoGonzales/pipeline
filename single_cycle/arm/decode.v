// File: arm/decode.v
// Decode module interpreting the Op and Funct fields to generate control signals.

// Modified
//     - extend the ALUControl to 3 bits

module decode (
    input  wire [1:0] Op,         // Opcode field
    input  wire [5:0] Funct,      // Function field
    input  wire [3:0] Rd,         // Destination register
    output reg  [1:0] FlagW,      // Flag write control
    output wire       PCS,        // Program Counter Source (branch)
    output wire       RegW,       // Register Write control
    output wire       MemW,       // Memory Write control
    output wire       MemtoReg,   // Memory to Register selector
    output wire       ALUSrc,     // ALU Source selector
    output wire [1:0] ImmSrc,     // Immediate Source selector
    output wire [1:0] RegSrc,     // Register Source selector
    output reg  [2:0] ALUControl  // ALU Operation Control
);
  // Internal control signals
  reg [9:0] controls; // Aggregated control signals: {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, Branch, ALUOp}
  wire BranchSignal;  // Branch control signal
  wire ALUOperation;  // ALU operation enable

  // Decode opcode and function fields to set control signals
  always @(*) begin
    casex (Op)
      2'b00: begin
        if (Funct[5]) begin
          controls = 10'b0000101001;
        end else begin
          controls = 10'b0000001001;  // div has no immediate value
        end
      end
      2'b01: begin
        if (Funct[0]) begin
          controls = 10'b0001111000;
        end else begin
          controls = 10'b1001110100;
        end
      end
      2'b10:   controls = 10'b0110100010;
      default: controls = 10'bxxxxxxxxxx;
    endcase
  end

  // Assign control signals to respective outputs
  assign {RegSrc, ImmSrc, ALUSrc, MemtoReg, RegW, MemW, BranchSignal, ALUOperation} = controls;

  // Determine ALU control signals based on ALUOp and Funct fields
  always @(*) begin
    if (ALUOperation) begin
      case (Funct[4:1])
        4'b0100: ALUControl = 3'b000;  // ADD
        4'b0010: ALUControl = 3'b001;  // SUB
        4'b0000: ALUControl = 3'b100;
        4'b1100: ALUControl = 3'b110;
        // new instructions (div)
        4'b1011: ALUControl = 3'b101;  // SDIV
        4'b1010: ALUControl = 3'b111;  // UDIV
        default: ALUControl = 3'bxxx;
      endcase
      FlagW[1] = Funct[0];  // Control flag write based on Funct[0]
      FlagW[0] = Funct[0] & ((ALUControl == 3'b000) | (ALUControl == 3'b001)); // Conditional flag write
    end else begin
      ALUControl = 3'b000;  // Default ALU operation
      FlagW      = 2'b00;  // No flag write
    end
  end

  // Determine Program Counter Source: if Rd is R15 (PC) and RegWrite is enabled, or if it's a branch
  assign PCS = ((Rd == 4'b1111) & RegW) | BranchSignal;

endmodule
