module testbench;
  reg clk;
  reg reset;
  wire [31:0] WriteData;
  wire [31:0] DataAdr;
  wire MemWrite; // MemWrite asimilation declaration.
  top pipelined (
      clk,
      reset,
      WriteData,
      DataAdr,
      MemWrite
  );
  initial begin
    reset <= 1;
    #(22);
    reset <= 0;
  end
  always begin
    clk <= 1;
    #(5);
    clk <= 0;
    #(5);
  end
  always @(negedge clk)
    if (MemWrite) begin // Declare initialization if MemWrite is flagged.
      if ((DataAdr === 100) & (WriteData === 7)) begin
        $display("Simulation succeeded");
        $stop;
      end else if (DataAdr !== 96) begin // Alternative initialization if MemWrite is negated DataAdr diff from 96.
        $display("Simulation failed");
        $stop;
      end
  end
endmodule
