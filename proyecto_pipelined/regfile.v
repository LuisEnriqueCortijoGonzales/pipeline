// Generic RegFile implementation

module regfile (
    input wire clk,  // Señal de reloj
    input wire we3,  // Señal de habilitación de escritura de los flip-flops como vimos en arqui
    input wire [3:0] ra1,  // Dirección del primer registro a leer
    input wire [3:0] ra2,  // Dirección del segundo registro a leer
    input wire [3:0] ra3,  // Dirección del tercer registro a leer (used in long multiplication)
    input wire [3:0] wa3,  // Dirección del registro a escribir
    input wire [3:0] wa3_2,  // Dirección del segundo registro a escribir (used in long multiplication)
    input wire [31:0] wd3,  // Datos a escribir en el registro
    input wire [31:0] wd3_2,  // Datos a escribir en el segundo registro (used in long multiplication)
    input wire [31:0] r15,  // Valor especial para el registro 15 usado para el PC
    output wire [31:0] rd1,  // Datos leídos del primer registro
    output wire [31:0] rd2,  // Datos leídos del segundo registro
    output wire [31:0] rd3  // Datos leídos del tercer registro (used in long multiplication)
);

  // Declaración de un banco de registros de 32 bits de ancho y 15 registros de profundidad
  //Empleo de la palabra Registros para simplifcar el debug en Vivado
  reg [31:0] Registros[14:0];

  // IF we3 ->
  //    write wd3 to wa3 &
  //    write wd3_2 to wa3_2
  always @(negedge clk) begin
    if (we3) begin
      Registros[wa3]   <= wd3;
      Registros[wa3_2] <= wd3_2;
    end
  end



  // Asignación de salida para 'rd1'
  // Si 'ra1' es 15 (4'b1111), se devuelve 'r15', de lo contrario, se lee del registro 'ra1'
  assign rd1 = (ra1 == 4'b1111 ? r15 : Registros[ra1]);

  // Asignación de salida para 'rd2'
  // Si 'ra2' es 15 (4'b1111), se devuelve 'r15', de lo contrario, se lee del registro 'ra2'
  assign rd2 = (ra2 == 4'b1111 ? r15 : Registros[ra2]);

  assign rd3 = Registros[ra3];

  // Close
endmodule
