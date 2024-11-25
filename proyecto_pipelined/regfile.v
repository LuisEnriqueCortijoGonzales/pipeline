//El del libro

module regfile (
  input wire clk, // Señal de reloj
  input wire we3, // Señal de habilitación de escritura de los flip-flops como vimos en arqui
  input wire [3:0] ra1, // Dirección del primer registro a leer
  input wire [3:0] ra2, // Dirección del segundo registro a leer
  input wire [3:0] wa3, // Dirección del registro a escribir
  input wire [31:0] wd3, // Datos a escribir en el registro
  input wire [31:0] r15, // Valor especial para el registro 15 usado para el PC
  output wire [31:0] rd1, // Datos leídos del primer registro
  output wire [31:0] rd2 // Datos leídos del segundo registro
);

  // Declaración de un banco de registros de 32 bits de ancho y 15 registros de profundidad
  //Empleo de la palabra Registros para simplifcar el debug en Vivado
  reg [31:0] Registros[14:0];

  // Bloque siempre activo en el flanco negativo del reloj
  // Si la señal de habilitación de escritura (we3) está activa, escribe 'wd3' en el registro 'wa3'
  always @(negedge clk) 
    if (we3) 
      rf[wa3] <= wd3;

  // Asignación de salida para 'rd1'
  // Si 'ra1' es 15 (4'b1111), se devuelve 'r15', de lo contrario, se lee del registro 'ra1'
  assign rd1 = (ra1 == 4'b1111 ? r15 : Registros[ra1]);

  // Asignación de salida para 'rd2'
  // Si 'ra2' es 15 (4'b1111), se devuelve 'r15', de lo contrario, se lee del registro 'ra2'
  assign rd2 = (ra2 == 4'b1111 ? r15 : Registros[ra2]);

endmodule