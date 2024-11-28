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
  wire ALUSrcE;
  wire [31:0] SrcAE, SrcBE, SrcCE, ALUResultE;
  wire [3:0] RA3D;
  wire [4:0] ALUControlE;
  wire [31:0] R[0:14];

  // Assign wires to internal signals
  assign ALUSrcE = processor.arm.ALUSrcE;
  assign SrcAE = processor.arm.Data_path.SrcAE;
  assign SrcBE = processor.arm.Data_path.SrcBE;
  assign SrcCE = processor.arm.Data_path.rd3E;
  assign RA3D = processor.arm.Data_path.RA3D;
  assign rd3D = processor.arm.Data_path.rd3D;
  assign ALUResultE = processor.arm.Data_path.ALUResultE;
  assign ALUControlE = processor.arm.ALUControlE;

  // Assign register values
  genvar i;
  generate
    for (i = 0; i <= 5; i = i + 1) begin : gen_register_alias
      assign R[i] = processor.arm.Data_path.Registros.Registros[i];
    end
  endgenerate

  initial begin
    $monitor(
        "ALUSrc: %b | SrcA: %d | SrcB: %d | SrcC %d|  ALUResult: %d | ALUControl: %b | Registers: R0=%d R1=%d R2=%d R3=%d R4=%d R5=%d",
        ALUSrcE, SrcAE, SrcBE, SrcCE, ALUResultE, ALUControlE, R[0], R[1], R[2], R[3], R[4], R[5]);
  end

  // Verify results after certain time
  initial begin
    // Wait until after reset and a few cycles
    #10000;

    // Use local wires R[0] to R[5]
    if (R[0] !== 32'd9) begin
      $display("Error: R0 != 9");
      $stop;
    end
    if (R[1] !== 32'd15) begin
      $display("Error: R1 != 15");
      $stop;
    end
    if (R[2] !== 32'd8) begin
      $display("Error: R2 != 8");
      $stop;
    end
    if (R[3] !== 32'd30) begin
      $display("Error: R3 != 30");
      $stop;
    end
    if (R[4] !== 32'd1) begin
      $display("Error: R4 != 1");
      $stop;
    end
    if (R[5] !== 32'd8) begin
      $display("Error: R5 != 8");
      $stop;
    end

    $display("All checks passed.");
  end

endmodule
