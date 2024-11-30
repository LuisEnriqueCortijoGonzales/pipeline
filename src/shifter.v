module shifter (
    input wire [DATA_WIDTH-1:0] register_data,
    input wire [6:0] shifting_data,
    output reg [DATA_WIDTH-1:0] shifted_result
);
  parameter DATA_WIDTH = 32;

  localparam LSL = 2'b00;
  localparam LSR = 2'b01;
  localparam ASR = 2'b10;
  localparam ROR = 2'b11;

  wire [3:0] shift_amount = shifting_data[6:2];

  always @(*) begin
    case (shifting_data[1:0])
      LSL: shifted_result = register_data << shift_amount;
      ASR: shifted_result = register_data >>> shift_amount;
      LSR: shifted_result = register_data >> shift_amount;
      ROR:
      shifted_result = (register_data >> shift_amount) | (register_data << (DATA_WIDTH - shift_amount));
      default: shifted_result = 32'dx;
    endcase

  end
endmodule
