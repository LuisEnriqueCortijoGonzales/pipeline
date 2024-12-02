module adder (
    a,  // Primer operando de entrada
    b,  // Segundo operando de entrada
    y  // Resultado de la suma
);
  parameter WIDTH = 8;  // Ancho de los operandos y el resultado
  input wire [WIDTH - 1:0] a;  // Entrada 'a' de WIDTH bits
  input wire [WIDTH - 1:0] b;  // Entrada 'b' de WIDTH bits
  output wire [WIDTH - 1:0] y;  // Salida 'y' de WIDTH bits
  assign y = a + b;  // Realiza la suma de 'a' y 'b'
endmodule

module comparador_igualdad (
    a,  // Primer operando de entrada
    b,  // Segundo operando de entrada
    y  // Resultado de la comparación
);
  parameter WIDTH = 8;  // Ancho de los operandos
  input wire [WIDTH - 1:0] a;  // Entrada 'operando_a' de WIDTH bits
  input wire [WIDTH - 1:0] b;  // Entrada 'operando_b' de WIDTH bits
  output wire y; // Salida 'resultado', 1 si 'operando_a' es igual a 'operando_b', 0 en caso contrario
  assign y = a == b;  // Compara si 'operando_a' es igual a 'operando_b'
endmodule

module comparador_igualdad_doble (
    input wire [(WIDTH*2) - 1:0] a,
    input wire [WIDTH - 1:0] b,
    output wire y
);
  parameter WIDTH = 8;
  // TODO: compare a[(WIDTH*2)-1:WIDTH] == b if they are used
  assign y = a[WIDTH-1:0] == b;
endmodule

module registro_flanco_positivo_habilitacion_limpieza (
    clk,  // Señal de reloj
    reset,  // Señal de reinicio
    en,  // Señal de habilitación
    clear,  // Señal de limpieza
    clear_value,
    d,  // Datos de entrada
    q  // Datos de salida
);
  parameter WIDTH = 8;  // Ancho de los datos
  input wire clk;  // Entrada de reloj
  input wire reset;  // Entrada de reinicio
  input wire en;  // Entrada de habilitación
  input wire clear;  // Entrada de limpieza
  input wire [WIDTH-1:0] clear_value;
  input wire [WIDTH - 1:0] d;  // Datos de entrada de WIDTH bits
  output reg [WIDTH - 1:0] q;  // Datos de salida de WIDTH bits
  always @(posedge clk or posedge reset)
    if (reset) q <= 0;  // Reinicia 'datos_salida' a 0 si 'reinicio' está activo
    else if (en) begin
      if (clear) q <= clear_value;
      else q <= d;  // De lo contrario, carga 'datos_entrada' en 'datos_salida'
    end
endmodule

module registro_flanco_positivo_habilitacion (
    clk,  // Señal de reloj
    reset,  // Señal de reinicio
    en,  // Señal de habilitación
    d,  // Datos de entrada
    q  // Datos de salida
);
  parameter WIDTH = 8;  // Ancho de los datos
  input wire clk;  // Entrada de reloj
  input wire reset;  // Entrada de reinicio
  input wire en;  // Entrada de habilitación
  input wire [WIDTH - 1:0] d;  // Datos de entrada de WIDTH bits
  output reg [WIDTH - 1:0] q;  // Datos de salida de WIDTH bits
  always @(posedge clk or posedge reset)
    if (reset) q <= 0;  // Reinicia 'datos_salida' a 0 si 'reinicio' está activo
    else if (en) q <= d;  // Si 'habilitacion' está activo, carga 'datos_entrada' en 'datos_salida'
endmodule

module registro_flanco_positivo (
    clk,  // Señal de reloj
    reset,  // Señal de reinicio
    d,  // Datos de entrada
    q  // Datos de salida
);
  parameter WIDTH = 8;  // Ancho de los datos
  input wire clk;  // Entrada de reloj
  input wire reset;  // Entrada de reinicio
  input wire [WIDTH - 1:0] d;  // Datos de entrada de WIDTH bits
  output reg [WIDTH - 1:0] q;  // Datos de salida de WIDTH bits
  always @(posedge clk or posedge reset)
    if (reset) q <= 0;  // Reinicia 'datos_salida' a 0 si 'reinicio' está activo
    else q <= d;  // De lo contrario, carga 'datos_entrada' en 'datos_salida'
endmodule

module mux2 (
    d0,  // Primer dato de entrada
    d1,  // Segundo dato de entrada
    s,  // Señal de selección
    y  // Salida del multiplexor
);
  parameter WIDTH = 8;  // Ancho de los datos
  input wire [WIDTH - 1:0] d0;  // Entrada 'd0' de WIDTH bits
  input wire [WIDTH - 1:0] d1;  // Entrada 'd1' de WIDTH bits
  input wire s;  // Señal de selección
  output wire [WIDTH - 1:0] y;  // Salida 'y' de WIDTH bits
  assign y = (s ? d1 : d0);  // Selecciona 'd1' si 's' es 1, de lo contrario 'd0'
endmodule

module mux3 (
    d0,  // Primer dato de entrada
    d1,  // Segundo dato de entrada
    d2,  // Tercer dato de entrada
    s,  // Señal de selección de 2 bits
    y  // Salida del multiplexor
);
  parameter WIDTH = 8;  // Ancho de los datos
  input wire [WIDTH - 1:0] d0;  // Entrada 'd0' de WIDTH bits
  input wire [WIDTH - 1:0] d1;  // Entrada 'd1' de WIDTH bits
  input wire [WIDTH - 1:0] d2;  // Entrada 'd2' de WIDTH bits
  input wire [1:0] s;  // Señal de selección de 2 bits
  output wire [WIDTH - 1:0] y;  // Salida 'y' de WIDTH bits
  assign y = (s[1] ? d2 : (s[0] ? d1 : d0)); // Selecciona 'd2' si 's[1]' es 1, 'd1' si 's[0]' es 1, de lo contrario 'd0'
endmodule
