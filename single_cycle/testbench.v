// File: testbench.v

`timescale 1ns / 1ps

module testbench;
  // Clock and reset signals
  reg clk;
  reg reset;

  // Processor outputs (for observation)
  wire [31:0] WriteData;
  wire [31:0] DataAdr;
  wire MemWrite;

  // Instantiate the top-level processor module
  top processor (
      .clk(clk),
      .reset(reset),
      .WriteData(WriteData),
      .DataAdr(DataAdr),
      .MemWrite(MemWrite)
  );

  // Clock generation: 10ns period (100MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // Toggle clock every 5ns
  end

  // Initialize signals and apply reset
  initial begin
    // Dump waveform for GTKWave
    $dumpfile("processor.vcd");
    $dumpvars(0, testbench);

    // Initialize signals
    reset = 1;  // Assert reset
    #20;  // Hold reset for 20ns
    reset = 0;  // De-assert reset

    // Let the processor run for a certain number of cycles
    #200;  // Adjust as needed to allow program execution

    // Finish simulation
    $finish;
  end

  // Monitor signals in the console
  initial begin
    $monitor(
        "Time: %0t | PC: %h |  ALUResult: %h | WriteData: %h | MemWrite: %b | CTRL: %b | Registers: %b %b %b %b ",
        $time,
        // Program counter
        processor.arm_core.data_path.PC,
        // Instruction
        processor.arm_core.data_path.Instr,
        // ALU srcs
        processor.arm_core.ALUSrc, processor.arm_core.data_path.SrcA,
        processor.arm_core.data_path.SrcB,
        // ALU result
        processor.arm_core.data_path.ALUResult, WriteData, MemWrite,
        // ALU control
        processor.arm_core.control_unit.ALUControl,
        // RD0, RD1, RD2, RD3
        processor.arm_core.data_path.registers.rf[0], processor.arm_core.data_path.registers.rf[1],
        processor.arm_core.data_path.registers.rf[2], processor.arm_core.data_path.registers.rf[3]);
  end

  // Verify results after certain time
  initial begin
    // Wait until after reset and a few cycles
    #100;

    // Check specific registers
    // Adjust the hierarchical names based on your module instantiations

    if (processor.arm_core.data_path.registers.rf[0] !== 32'd0) begin
      $display("Error: R0 != 0");
      $stop;
    end

    if (processor.arm_core.data_path.registers.rf[1] !== 32'd4) begin
      $display("Error: R1 != 4");
      $stop;
    end

    if (processor.arm_core.data_path.registers.rf[2] !== 32'd2) begin
      $display("Error: R2 != 2");
      $stop;
    end

    if (processor.arm_core.data_path.registers.rf[3] !== 32'd2) begin
      $display("Error: R3 != 2");
      $stop;
    end


    $display("All checks passed.");
  end

endmodule
