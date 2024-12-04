module display_controller (
    input wire clk,  // Reloj para multiplexar los displays
    input wire reset,
    input wire [31:0] R0,
    input wire [31:0] R1,
    output reg [6:0] seg,  // Segmentos del display
    output reg [3:0] an  // Anodos del display
);

  reg [ 3:0] digit;
  reg [31:0] display_value;
  reg [19:0] refresh_counter;  // Contador para multiplexar los displays

  // Actualización del valor a mostrar y manejo del reset
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      display_value   <= 32'b0;  // Reiniciar el valor del display
      refresh_counter <= 0;
    end else begin
      display_value   <= R1;  // Mostrar siempre el valor de R1
      refresh_counter <= refresh_counter + 1;
    end
  end

  // Selección de dígito y encendido de anodos correspondientes
  always @(posedge clk) begin
    case (refresh_counter[1:0])
      2'b00: begin
        digit <= display_value[3:0];
        an <= 4'b1110;  // Encender el primer dígito
      end
      2'b01: begin
        digit <= display_value[7:4];
        an <= 4'b1101;  // Encender el segundo dígito
      end
      2'b10: begin
        digit <= display_value[11:8];
        an <= 4'b1011;  // Encender el tercer dígito
      end
      2'b11: begin
        digit <= display_value[15:12];
        an <= 4'b0111;  // Encender el cuarto dígito
      end
    endcase
  end

  // Conversión de dígito a segmentos
  always @(*) begin
    case (digit)
      4'h0: seg = 7'b1000000;
      4'h1: seg = 7'b1111001;
      4'h2: seg = 7'b0100100;
      4'h3: seg = 7'b0110000;
      4'h4: seg = 7'b0011001;
      4'h5: seg = 7'b0010010;
      4'h6: seg = 7'b0000010;
      4'h7: seg = 7'b1111000;
      4'h8: seg = 7'b0000000;
      4'h9: seg = 7'b0010000;
      4'hA: seg = 7'b0001000;
      4'hB: seg = 7'b0000011;
      4'hC: seg = 7'b1000110;
      4'hD: seg = 7'b0100001;
      4'hE: seg = 7'b0000110;
      4'hF: seg = 7'b0001110;
      default: seg = 7'b1111111;  // Apagar todos los segmentos
    endcase
  end

endmodule


module clock_divider (
    input  wire clk_in,
    input  wire reset,
    output reg  clk_out
);
  reg [31:0] counter = 0;
  parameter DIVISOR = 25000000;  //para un clock de 5 segundos

  always @(posedge clk_in) begin

    if (reset) begin
      counter <= 0;
      clk_out <= 0;
    end else begin
      counter <= counter + 1;
      if (counter >= DIVISOR) begin
        clk_out <= ~clk_out;
        counter <= 0;
      end
    end

  end
endmodule

module clock_divider1 (
    input  wire clk_in,
    input  wire reset,
    output reg  clk_out
);
  reg [31:0] counter = 0;
  parameter DIVISOR = 100000;  //para un clock de 5 segundos

  always @(posedge clk_in) begin

    if (reset) begin
      counter <= 0;
      clk_out <= 0;
    end else begin
      counter <= counter + 1;
      if (counter >= DIVISOR) begin
        clk_out <= ~clk_out;
        counter <= 0;
      end
    end

  end
endmodule
