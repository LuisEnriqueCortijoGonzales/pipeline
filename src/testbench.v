`timescale 1ns / 1ps

module testbench;
  // Clock and reset signals
  reg clk;
  reg reset;

  // Instantiate the top-level processor module
  top processor (
      .clk  (clk),
      .reset(reset)
  );

  // Clock generation: 10ns period (100MHz)
  initial begin
    clk = 0;
    forever #2 clk = ~clk;  // Toggle clock every 2ns
  end

  // Initialize signals and apply reset
  initial begin
    // Dump waveform for GTKWave
    $dumpfile("processor.vcd");
    $dumpvars(0, testbench);

    // Initialize signals
    reset = 0;  // De-assert reset
    #20;  // Hold reset for 20ns
    reset = 1;  // Assert reset
    #20;  // Hold reset for 20ns
    reset = 0;  // De-assert reset

    // Let the processor run for a certain number of cycles
    #10000;  // Adjust as needed to allow program execution

    // Finish simulation
    $finish;
  end

  // Declare wires to monitor internal signals
  wire [31:0] InstrD;

  wire [31:0] SrcAE, SrcBE, SrcCE, SrcDE;
  wire [63:0] ALUResultE, ResultW, ALUOutM;
  wire [3:0] RA4D, RA3D, RA2D, RA1D;
  wire [3:0] WA3W;
  wire [5:0] ALUControlE;
  wire [5:0] ALUControlD;
  wire [31:0] R[0:14];

  wire [1:0] RegWriteM;
  wire [1:0] RegWriteW;
  wire [1:0] RegWriteD;


  wire ALUSrcE;
  wire [31:0] ExtImm;

  wire PCSrcW;


  wire [1:0] RegSrcD;

  wire [31:0] PCF;

  wire [3:0] WA3D;
  wire [3:0] WD3_IN;
  // regfile
  wire [3:0] wa3;  // Dirección del registro a escribir
  wire [3:0] wa3_2;  // Dirección del segundo registro a escribir (used in long multiplication)

  wire [31:0] wd3;  // Datos a escribir en el registro
  wire [31:0] wd3_2;  // Datos a escribir en el segundo registro (used in long multiplication)

  // Hazards
  wire [1:0] ForwardAE;
  wire [1:0] ForwardBE;
  wire [1:0] ForwardCE;
  wire [1:0] ForwardDE;

  wire [31:0] rd1D;
  wire [31:0] rd2D;
  wire [31:0] rd3D;
  wire [31:0] rd4D;

  wire [1:0] ImmSrcD;

  wire PCSrcD;
  wire PCSrcE;
  wire PCSrcM;

  // Assign wires to internal signals

  assign InstrD = processor.arm.InstrD;
  assign PCF = processor.PCF;


  assign PCSrcW = processor.arm.PCSrcW;
  assign PCSrcD = processor.arm.Control_unit.PCSrcD;
  assign PCSrcE = processor.arm.Control_unit.PCSrcE;
  assign PCSrcM = processor.arm.Control_unit.PCSrcM;

  assign ImmSrcD = processor.arm.ImmSrcD;

  assign ExtImmE = processor.arm.Data_path.ExtImmD;
  assign ExtImmD = processor.arm.Data_path.ExtImmE;

  assign ALUSrcE = processor.arm.ALUSrcE;
  assign SrcAE = processor.arm.Data_path.SrcAE;
  assign SrcBE = processor.arm.Data_path.SrcBE;
  assign SrcCE = processor.arm.Data_path.SrcCE;
  assign SrcDE = processor.arm.Data_path.SrcDE;
  assign RA3D = processor.arm.Data_path.RA3D;
  assign rd3D = processor.arm.Data_path.rd3D;
  assign ALUResultE = processor.arm.Data_path.ALUResultE;
  assign ALUControlE = processor.arm.ALUControlE;
  assign ALUControlD = processor.arm.Control_unit.ALUControlD;

  assign InstrD = processor.arm.Data_path.InstrD;

  assign WA3W = processor.arm.Data_path.WA3W;
  assign WD3_IN = processor.arm.Data_path.WD3_IN;

  assign RegSrcD = processor.arm.RegSrcD;


  assign WA3W = processor.arm.Data_path.WA3W;

  assign WA3D = processor.arm.Data_path.InstrD[15:12];

  assign ALUOutM = processor.arm.Data_path.ALUOutM;
  assign ResultW = processor.arm.Data_path.ResultW;

  assign rd1D = processor.arm.Data_path.rd1D;
  assign rd2D = processor.arm.Data_path.rd2D;
  assign rd3D = processor.arm.Data_path.rd3D;
  assign rd4D = processor.arm.Data_path.rd4D;

  assign RA1D = processor.arm.Data_path.RA1D;
  assign RA2D = processor.arm.Data_path.RA2D;
  assign RA3D = processor.arm.Data_path.RA3D;
  assign RA4D = processor.arm.Data_path.RA4D;


  assign ForwardAE = processor.arm.Hazard_unit.ForwardAE;
  assign ForwardBE = processor.arm.Hazard_unit.ForwardBE;
  assign ForwardCE = processor.arm.Hazard_unit.ForwardCE;
  assign ForwardDE = processor.arm.Hazard_unit.ForwardDE;



  assign RegWriteM = processor.arm.RegWriteM;
  assign RegWriteD = processor.arm.Control_unit.RegWriteD;
  assign RegWriteW = processor.arm.RegWriteW;

  assign wa3 = processor.arm.Data_path.Registros.wa3;
  assign wa3_2 = processor.arm.Data_path.Registros.wa3_2;
  assign wd3 = processor.arm.Data_path.Registros.wd3;
  assign wd3_2 = processor.arm.Data_path.Registros.wd3_2;



  // Assign register values
  genvar i;
  generate
    for (i = 0; i <= 5; i = i + 1) begin : gen_register_alias
      assign R[i] = processor.arm.Data_path.Registros.Registros[i];
    end
  endgenerate

  initial begin
    $monitor(
        "InstrD %b \n RegWriteD %b | RegWriteW %b | WA3W %d \n Forwards: %b %b %b %b \n ResultW %d | ALUOutM:%d | \n  RAxD: %d %d %d %d | RDxD: %d %d %d %d \n SrcA: %d | SrcB: %d | SrcC %d SrcD %d | \n ALUResult: %d | ALUControlD: %b | ALUControlE: %b \n REGS: %d %d %d %d \n",
        InstrD, RegWriteD, RegWriteW, WA3W, ForwardAE, ForwardBE, ForwardCE, ForwardDE, ResultW,
        ALUOutM, RA1D, RA2D, RA3D, RA4D, rd1D, rd2D, rd3D, rd4D, SrcAE, SrcBE, SrcCE, SrcDE,
        ALUResultE, ALUControlD, ALUControlE, R[0], R[1], R[2], R[3]);
  end

  // Verify results after certain time
  initial begin
    // Wait until after reset and a few cycles
    #10000;

    if (R[0] != 32'd10) begin
      $display("Error: R0 != 10");
    end
  end

endmodule
