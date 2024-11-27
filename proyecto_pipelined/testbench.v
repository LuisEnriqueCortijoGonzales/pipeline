// File: testbench.v

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
    forever #5 clk = ~clk;  // Toggle clock every 5ns
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
        "Time: %0t | WriteDataM: %d | rd2D: %d | PC: %h | AluSRC %b | AluA %d - AluB %d | ALUResult: %d | AluCTRL: %b | Registers: %d %d %d ",
        $time, processor.WriteDataM, processor.arm.Data_path.rd2D,

        // Program counter
        processor.PCF,
        // ALU srcs
        processor.arm.ALUSrcE, processor.arm.Data_path.SrcAE, processor.arm.Data_path.SrcBE,
        // ALU result
        processor.arm.Data_path.ALUResultE,
        // ALU control
        processor.arm.ALUControlE,
        // RD0, RD1, RD2
        processor.arm.Data_path.Registros.Registros[0],
        processor.arm.Data_path.Registros.Registros[1],
        processor.arm.Data_path.Registros.Registros[2]);
  end

  // Verify results after certain time
  initial begin
    // Wait until after reset and a few cycles
    #400;

    // Check specific registers
    // Adjust the hierarchical names based on your module instantiations

    if (processor.arm.Data_path.Registros.Registros[0] !== 32'd0) begin
      $display("Error: R0 != 0");
      $stop;
    end



    $display("All checks passed.");
  end

endmodule
