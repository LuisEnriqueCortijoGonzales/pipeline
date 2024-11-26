// File: arm/datapath.v
// Datapath module handling data operations based on control signals

module datapath (
    input  wire        clk,         // Clock signal
    input  wire        reset,       // Reset signal
    input  wire [ 1:0] RegSrc,      // Register source selector
    input  wire        RegWrite,    // Register write enable
    input  wire [ 1:0] ImmSrc,      // Immediate value source selector
    input  wire        ALUSrc,      // ALU source selector
    input  wire [ 2:0] ALUControl,  // ALU operation control
    input  wire        MemtoReg,    // Memory to Register selector
    input  wire        PCSrc,       // Program Counter source selector
    output wire [ 3:0] ALUFlags,    // Flags from ALU
    output wire [31:0] PC,          // Current Program Counter
    inout  wire [31:0] Instr,       // Current Instruction
    output wire [31:0] ALUResult,   // ALU Result
    output wire [31:0] WriteData,   // Data to write to memory
    inout  wire [31:0] ReadData,    // Data read from memory
    input  wire        MemWrite     // Memory write enable
);
  // Internal wires
  wire [31:0] PCNext;  // Next Program Counter value
  wire [31:0] PCPlus4;  // PC + 4
  wire [31:0] PCPlus8;  // PC + 8 (for link register)
  wire [31:0] ExtendedImm;  // Extended immediate value
  wire [31:0] SrcA;  // Source A for ALU
  wire [31:0] SrcB;  // Source B for ALU
  wire [31:0] ResultW;  // Data to write to register
  wire [ 3:0] RA1;  // Register Address 1
  wire [ 3:0] RA2;  // Register Address 2

  wire [ 3:0] WA3W;  // EL GRANDE

  /// STAGE 1: FETCH

  // Instruction 32
  // PCPlus4 32

  wire [63:0] FETCH_IN;
  wire [63:0] FETCH_OUT;

  // Mux for selecting next PC: PC + 4 or branch target
  mux2 #(32) pc_mux (
      .d0(PCPlus4),
      .d1(ResultW),  // Assuming ALUResult holds branch target
      .s (PCSrc),
      .y (PCNext)
  );

  // Program Counter Register
  flopr #(32) pc_register (
      .clk(clk),
      .reset(reset),
      .d(PCNext),
      .q(PC)
  );

  // Adder: PC + 4
  adder #(32) pc_add1 (
      .a(PC),
      .b(32'd4),
      .y(PCPlus4)
  );

  // Instantiate Instruction Memory
  imem instruction_memory (
      .address(PC),
      .instruction(Instr)
  );

  assign FETCH_IN = {Instr, PCPlus4};

  // Outputs:
  // - Instr
  // - PCPlus4

  flopr #(64) fetch_register (
      .clk(clk),
      .reset(reset),
      .d(FETCH_IN),
      .q(FETCH_OUT)
  );

  wire [31:0] Instr_decode;
  wire [31:0] PCPlus4_decode;
  assign Instr_decode   = FETCH_OUT[63:32];
  assign PCPlus4_decode = FETCH_OUT[31:0];



  /// STAGE 2: DECODE

  // SrcA 32
  // WriteData 32
  // Instr[15:12] 4
  // ExtendedImm 32
  //
  wire [99:0] DECODE_IN;
  wire [99:0] DECODE_OUT;

  // Mux for Register Address 1: Instr[19:16] or R15 (PC)
  // + 32
  mux2 #(4) ra1_mux (
      .d0(Instr_decode[19:16]),
      .d1(4'd15),                // PC
      .s (RegSrc[0]),
      .y (RA1)
  );

  // Mux for Register Address 2: Instr[3:0] or Instr[15:12]
  mux2 #(4) ra2_mux (
      .d0(Instr_decode[3:0]),
      .d1(Instr_decode[15:12]),
      .s (RegSrc[1]),
      .y (RA2)
  );


  // Adder: PC + 8 (for link register in branch instructions)
  adder #(32) pc_add2 (
      .a(PCPlus4_decode),
      .b(32'd4),
      .y(PCPlus8)
  );

  // Register File
  regfile registers (
      .clk(clk),
      .we3(RegWrite),
      .ra1(RA1),
      .ra2(RA2),
      .wa3(WA3W),      // Destination register
      .wd3(ResultW),
      .r15(PCPlus8),   // R15 (PC) holds PC + 8
      .rd1(SrcA),
      .rd2(WriteData)
  );

  // Immediate Value Extension
  extend immediate_extend (
      .Instr (Instr_decode[23:0]),
      .ImmSrc(ImmSrc),
      .ExtImm(ExtendedImm)
  );

  assign DECODE_IN = {SrcA, WriteData, Instr_decode[15:12], ExtendedImm};

  flopr #(100) decode_register (
      .clk(clk),
      .reset(reset),
      .d(DECODE_IN),
      .q(DECODE_OUT)
  );


  wire [31:0] SrcA_execute;
  wire [31:0] WriteData_execute;
  wire [ 3:0] WA3D_execute;
  wire [31:0] ExtendedImm_execute;

  assign SrcA_execute = DECODE_OUT[99:68];
  assign WriteData_execute = DECODE_OUT[67:36];
  assign WA3D_execute = DECODE_OUT[35:32];
  assign ExtendedImm_execute = DECODE_OUT[31:0];



  /// STAGE 3: EXECUTE

  // WriteData 32
  // ALUResult 32
  // WA3E 4

  wire [67:0] EXECUTE_IN;
  wire [67:0] EXECUTE_OUT;


  // Mux for ALU Source B: Register Data or Extended Immediate
  mux2 #(32) srcb_mux (
      .d0(WriteData_execute),
      .d1(ExtendedImm_execute),
      .s (ALUSrc),
      .y (SrcB)
  );

  // ALU Operations
  alu arithmetic_logic_unit (
      .a(SrcA_execute),
      .b(SrcB),
      .ALUControl(ALUControl),
      .Result(ALUResult),
      .ALUFlags(ALUFlags)
  );

  assign EXECUTE_IN = {WriteData, ALUResult, WA3D_execute};

  flopr #(68) execute_register (
      .clk(clk),
      .reset(reset),
      .d(EXECUTE_IN),
      .q(EXECUTE_OUT)
  );

  wire [31:0] WriteData_memory;
  wire [31:0] ALUResult_memory;
  wire [ 3:0] WA3E_memory;


  assign WriteData_memory = EXECUTE_OUT[67:36];
  assign ALUResult_memory = EXECUTE_OUT[35:4];
  assign WA3E_memory = EXECUTE_OUT[3:0];

  /// STAGE 4: MEMORY

  // ALUResult 32
  // ReadData 32
  // WA3M 4
  wire [67:0] MEMORY_IN;
  wire [67:0] MEMORY_OUT;

  dmem data_memory (
      .clk(clk),
      .we(MemWrite),
      .address(ALUResult_memory),
      .write_data(WriteData_memory),
      .read_data(ReadData)
  );


  assign MEMORY_IN = {ALUResult, ReadData, WA3E_memory};

  flopr #(68) memory_register (
      .clk(clk),
      .reset(reset),
      .d(MEMORY_IN),
      .q(MEMORY_OUT)
  );

  wire [31:0] ALUResult_writeback;
  wire [31:0] ReadData_writeback;


  /// STAGE 5: WRITE BACK

  // Mux for Write Data: ALUResult or Data from Memory
  mux2 #(32) write_data_mux (
      .d0(ALUResult_writeback),
      .d1(ReadData_writeback),
      .s (MemtoReg),
      .y (ResultW)
  );

endmodule
