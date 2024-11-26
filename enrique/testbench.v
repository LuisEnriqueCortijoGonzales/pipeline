// File: testbench.v

`timescale 1ns / 1ps

module testbench;
  // Clock and reset signals
  reg clk;
  reg reset;

  // Instantiate the top-level processor module
  arm_processor processor (
      .clk(clk),
      .reset(reset),
      .MemWrite(MemWrite),
      .DataAdr(DataAdr),
      .WriteData(WriteData)
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
    reset = 0;  // De-assert reset
    #50;  // Hold reset for 20ns
    reset = 1;  // Assert reset
    #50;  // Hold reset for 20ns
    reset = 0;  // De-assert reset

    // Let the processor run for a certain number of cycles
    #200;  // Adjust as needed to allow program execution

    // Finish simulation
    $finish;
  end

  // Monitor signals in the console
  // initial begin
  //   $monitor("Time: %0t | PC: %h | Alu control: %b | Registers: %b %b %b  ", $time,
  //            // Program counter
  //            processor.data_path.PC,
  //            // ALU control
  //            processor.control_unit.ALUControl,
  //            // RD0, RD1, RD2, RD3
  //            processor.data_path.registers.rf[0], processor.data_path.registers.rf[1],
  //            processor.data_path.registers.rf[2]);
  // end

  initial begin
    $monitor(
        "Time: %0t | PC: %h | AluSRC %b | AluA %d - AluB %d | ALUResult: %d | AluCTRL: %b | Registers: %d %d %d ",
        $time,
        // Program counter
        processor.data_path.PC,
        // Instruction
        // processor.data_path.Instr,
        // ALU srcs
        processor.ALUSrc, processor.data_path.SrcA, processor.data_path.SrcB,
        // ALU result
        processor.data_path.ALUResult,
        // ALU control
        processor.control_unit.ALUControl,
        // RD0, RD1, RD2, RD3
        processor.data_path.registers.rf[0], processor.data_path.registers.rf[1],
        processor.data_path.registers.rf[2]);
  end

  // Verify results after certain time
  initial begin
    // Wait until after reset and a few cycles
    #200;

    // Check specific registers
    // Adjust the hierarchical names based on your module instantiations

    if (processor.data_path.registers.rf[0] !== 32'd0) begin
      $display("Error: R0 != 0");
      $stop;
    end

    if (processor.data_path.registers.rf[1] !== 32'd4) begin
      $display("Error: R1 != 4");
      $stop;
    end

    if (processor.data_path.registers.rf[2] !== 32'd2) begin
      $display("Error: R2 != 2");
      $stop;
    end


    $display("All checks passed.");
  end

endmodule
