// Módulo principal que implementa un pipeline
module top (
    input wire clk,          // Señal de reloj
    input wire reset,        // Señal de reset
    output wire [31:0] WriteData, // Datos a escribir en memoria
    output wire [31:0] DataAdr,   // Dirección de datos
    output wire MemWrite    // Señal de escritura en memoria
);
    // Instanciación del Datapath con Pipeline
    datapath_pipeline dp (
        .clk(clk),
        .reset(reset),
        .WriteData(WriteData),
        .DataAdr(DataAdr),
        .MemWrite(MemWrite)
    );
endmodule
// Módulo de Control
module control_unit (
    input wire [5:0] Op,       // Código de operación
    input wire [5:0] Funct,    // Campo de función
    output reg RegWriteD,      // Señal de escritura en registro
    output reg MemtoRegD,      // Señal de selección de datos de memoria
    output reg MemWriteD,      // Señal de escritura en memoria
    output reg BranchD,        // Señal de bifurcación
    output reg [1:0] ALUControlD, // Control de la ALU
    output reg ALUSrcD,        // Selección de fuente de la ALU
    output reg RegDstD         // Selección de destino de registro
);
    always @(*) begin
        case (Op)
            6'b000000: begin // Tipo R
                case (Funct)
                    6'b100000: ALUControlD = 2'b00; // ADD
                    6'b100010: ALUControlD = 2'b01; // SUB
                    6'b100100: ALUControlD = 2'b10; // AND
                    6'b100101: ALUControlD = 2'b11; // OR
                    default: ALUControlD = 2'b00;
                endcase
                RegWriteD = 1;
                MemtoRegD = 0;
                MemWriteD = 0;
                BranchD = 0;
                ALUSrcD = 0;
                RegDstD = 1;
            end
            6'b100011: begin // LW
                RegWriteD = 1;
                MemtoRegD = 1;
                MemWriteD = 0;
                BranchD = 0;
                ALUControlD = 2'b00; // ADD
                ALUSrcD = 1;
                RegDstD = 0;
            end
            6'b101011: begin // SW
                RegWriteD = 0;
                MemtoRegD = 0;
                MemWriteD = 1;
                BranchD = 0;
                ALUControlD = 2'b00; // ADD
                ALUSrcD = 1;
                RegDstD = 0;
            end
            6'b000100: begin // BEQ
                RegWriteD = 0;
                MemtoRegD = 0;
                MemWriteD = 0;
                BranchD = 1;
                ALUControlD = 2'b01; // SUB
                ALUSrcD = 0;
                RegDstD = 0;
            end
            default: begin
                RegWriteD = 0;
                MemtoRegD = 0;
                MemWriteD = 0;
                BranchD = 0;
                ALUControlD = 2'b00;
                ALUSrcD = 0;
                RegDstD = 0;
            end
        endcase
    end
endmodule
// Módulo del Datapath con Pipeline
module datapath_pipeline (
    input wire clk,          // Señal de reloj
    input wire reset,        // Señal de reset
    output wire [31:0] WriteData, // Datos a escribir en memoria
    output wire [31:0] DataAdr,   // Dirección de datos
    output wire MemWrite    // Señal de escritura en memoria
);
    // Registros de Pipeline
    // IF/ID: Almacena la instrucción y el PC después de la etapa de Fetch
    reg [31:0] IF_ID_instr, IF_ID_PC;
    // ID/EX: Almacena datos decodificados y señales de control para la etapa de Execute
    reg [31:0] ID_EX_PC, ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_Imm;
    reg [4:0] ID_EX_Rd;
    reg [1:0] ID_EX_RegSrc, ID_EX_ImmSrc, ID_EX_ALUControl;
    reg ID_EX_RegWrite, ID_EX_ALUSrc, ID_EX_MemWrite, ID_EX_MemtoReg, ID_EX_PCSrc;
    // EX/MEM: Almacena resultados de la ALU y datos para la etapa de Memory
    reg [31:0] EX_MEM_ALUResult, EX_MEM_ReadData2;
    reg [4:0] EX_MEM_Rd;
    reg EX_MEM_RegWrite, EX_MEM_MemWrite, EX_MEM_MemtoReg;
    // MEM/WB: Almacena datos de memoria y resultados de la ALU para la etapa de Write Back
    reg [31:0] MEM_WB_ALUResult, MEM_WB_ReadData;
    reg [4:0] MEM_WB_Rd;
    reg MEM_WB_RegWrite, MEM_WB_MemtoReg;
    // Señales de las etapas del pipeline
    wire [31:0] PC, PCNext; // Contador de programa y su siguiente valor
    wire [31:0] Instr;      // Instrucción actual
    wire [31:0] ReadData1, ReadData2, ExtImm; // Datos leídos y extendidos
    wire [31:0] ALUResult;  // Resultado de la ALU
    wire [3:0] ALUFlags;    // Flags de la ALU
    wire [31:0] Result;     // Resultado final
    wire [31:0] ReadData;   // Datos leídos de memoria
    wire [31:0] WriteBackData; // Datos a escribir de vuelta
    // Etapa IF: Fetch de la instrucción
    IMem imem (
        .a(PC),             // Dirección de la instrucción
        .rd(Instr)          // Instrucción leída
    );
    // Suma 4 al PC para obtener la siguiente instrucción
    adder #(32) pcadd1 (
        .a(PC),
        .b(32'd4),
        .y(PCNext)
    );
    // Registro de PC con reset
    flopr #(32) pcreg (
        .clk(clk),
        .reset(reset),
        .d(PCNext),
        .q(PC)
    );
    // Registro IF/ID: Almacena la instrucción y el PC
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IF_ID_instr <= 0;
            IF_ID_PC <= 0;
        end else begin
            IF_ID_instr <= Instr;
            IF_ID_PC <= PC;
        end
    end
    // Etapa ID: Decodificación de la instrucción y lectura de registros
    regfile rf (
        .clk(clk),
        .we3(MEM_WB_RegWrite), // Señal de escritura en el banco de registros
        .ra1(IF_ID_instr[19:16]), // Dirección del primer registro fuente
        .ra2(IF_ID_instr[3:0]),   // Dirección del segundo registro fuente
        .wa3(MEM_WB_Rd),          // Dirección del registro destino
        .wd3(WriteBackData),      // Datos a escribir en el registro destino
        .r15(IF_ID_PC + 4),       // Valor del PC + 4
        .rd1(ReadData1),          // Datos leídos del primer registro
        .rd2(ReadData2)           // Datos leídos del segundo registro
    );
    // Extensión de inmediato
    extend ext (
        .Instr(IF_ID_instr[23:0]), // Parte de la instrucción a extender
        .ImmSrc(ID_EX_ImmSrc),     // Fuente del inmediato
        .ExtImm(ExtImm)            // Inmediato extendido
    );
    // Registro ID/EX: Almacena datos y señales de control para la etapa EX
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            ID_EX_PC <= 0;
            ID_EX_ReadData1 <= 0;
            ID_EX_ReadData2 <= 0;
            ID_EX_Imm <= 0;
            ID_EX_Rd <= 0;
            ID_EX_RegSrc <= 0;
            ID_EX_ImmSrc <= 0;
            ID_EX_ALUControl <= 0;
            ID_EX_RegWrite <= 0;
            ID_EX_ALUSrc <= 0;
            ID_EX_MemWrite <= 0;
            ID_EX_MemtoReg <= 0;
            ID_EX_PCSrc <= 0;
        end else begin
            ID_EX_PC <= IF_ID_PC;
            ID_EX_ReadData1 <= ReadData1;
            ID_EX_ReadData2 <= ReadData2;
            ID_EX_Imm <= ExtImm;
            ID_EX_Rd <= IF_ID_instr[15:12];
            ID_EX_RegSrc <= /* Señales de control */;
            ID_EX_ImmSrc <= /* Señales de control */;
            ID_EX_ALUControl <= /* Señales de control */;
            ID_EX_RegWrite <= /* Señales de control */;
            ID_EX_ALUSrc <= /* Señales de control */;
            ID_EX_MemWrite <= /* Señales de control */;
            ID_EX_MemtoReg <= /* Señales de control */;
            ID_EX_PCSrc <= /* Señales de control */;
        end
    end
    // Etapa EX: Ejecución de la operación
    alu alu (
        .a(ID_EX_ReadData1), // Primer operando
        .b(ID_EX_ALUSrc ? ID_EX_Imm : ID_EX_ReadData2), // Segundo operando
        .control(ID_EX_ALUControl), // Control de la operación
        .y(ALUResult), // Resultado de la ALU
        .flags(ALUFlags) // Flags de la ALU
    );
    // Registro EX/MEM: Almacena resultados de la ALU y datos para la etapa MEM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_MEM_ALUResult <= 0;
            EX_MEM_ReadData2 <= 0;
            EX_MEM_Rd <= 0;
            EX_MEM_RegWrite <= 0;
            EX_MEM_MemWrite <= 0;
            EX_MEM_MemtoReg <= 0;
        end else begin
            EX_MEM_ALUResult <= ALUResult;
            EX_MEM_ReadData2 <= ID_EX_ReadData2;
            EX_MEM_Rd <= ID_EX_Rd;
            EX_MEM_RegWrite <= ID_EX_RegWrite;
            EX_MEM_MemWrite <= ID_EX_MemWrite;
            EX_MEM_MemtoReg <= ID_EX_MemtoReg;
        end
    end
    // Etapa MEM: Acceso a la memoria
    dmem dmem (
        .clk(clk),
        .we(EX_MEM_MemWrite), // Señal de escritura en memoria
        .a(EX_MEM_ALUResult), // Dirección de memoria
        .wd(EX_MEM_ReadData2), // Datos a escribir
        .rd(ReadData) // Datos leídos de memoria
    );

    // Registro MEM/WB: Almacena datos de memoria y resultados de la ALU para la etapa WB
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEM_WB_ALUResult <= 0;
            MEM_WB_ReadData <= 0;
            MEM_WB_Rd <= 0;
            MEM_WB_RegWrite <= 0;
            MEM_WB_MemtoReg <= 0;
        end else begin
            MEM_WB_ALUResult <= EX_MEM_ALUResult;
            MEM_WB_ReadData <= ReadData;
            MEM_WB_Rd <= EX_MEM_Rd;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
            MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
        end
    end

    // Etapa WB: Escritura de resultados de vuelta en los registros
    assign WriteBackData = MEM_WB_MemtoReg ? MEM_WB_ReadData : MEM_WB_ALUResult;

    // Instanciación del módulo de control
    control_unit cu (
        .Op(IF_ID_instr[31:26]), // Código de operación
        .Funct(IF_ID_instr[5:0]), // Campo de función
        .RegWriteD(ID_EX_RegWrite),
        .MemtoRegD(ID_EX_MemtoReg),
        .MemWriteD(ID_EX_MemWrite),
        .BranchD(ID_EX_PCSrc),
        .ALUControlD(ID_EX_ALUControl),
        .ALUSrcD(ID_EX_ALUSrc),
        .RegDstD(ID_EX_RegSrc)
    );
endmodule

// Módulo de Memoria de Instrucciones
module IMem (
    input wire [31:0] a, // Dirección de la instrucción
    output wire [31:0] rd // Instrucción leída
);
    reg [31:0] RAM [63:0]; // Memoria de instrucciones
    initial $readmemh("memfile.dat", RAM); // Inicialización de la memoria
    assign rd = RAM[a[31:2]]; // Lectura de la instrucción
endmodule

// Módulo de Memoria de Datos
module dmem (
    input wire clk, // Señal de reloj
    input wire we, // Señal de escritura
    input wire [31:0] a, // Dirección de datos
    input wire [31:0] wd, // Datos a escribir
    output wire [31:0] rd // Datos leídos
);
    reg [31:0] RAM [63:0]; // Memoria de datos
    always @(posedge clk) begin
        if (we) begin
            RAM[a[31:2]] <= wd; // Escritura en memoria
        end
    end
    assign rd = RAM[a[31:2]]; // Lectura de memoria
endmodule

// Módulo de Banco de Registros
module regfile (
    input wire clk, // Señal de reloj
    input wire we3, // Señal de escritura
    input wire [3:0] ra1, // Dirección del primer registro fuente
    input wire [3:0] ra2, // Dirección del segundo registro fuente
    input wire [3:0] wa3, // Dirección del registro destino
    input wire [31:0] wd3, // Datos a escribir
    input wire [31:0] r15, // Valor del PC + 4
    output wire [31:0] rd1, // Datos leídos del primer registro
    output wire [31:0] rd2 // Datos leídos del segundo registro
);
    reg [31:0] rf [14:0]; // Banco de registros
    always @(posedge clk) begin
        if (we3) begin
            rf[wa3] <= wd3; // Escritura en el registro
        end
    end
    assign rd1 = (ra1 == 4'b1111) ? r15 : rf[ra1]; // Lectura del primer registro
    assign rd2 = (ra2 == 4'b1111) ? r15 : rf[ra2]; // Lectura del segundo registro
endmodule

// Módulo de Extensión de Inmediatos
module extend (
    input wire [23:0] Instr, // Parte de la instrucción a extender
    input wire [1:0] ImmSrc, // Fuente del inmediato
    output reg [31:0] ExtImm // Inmediato extendido
);
    always @(*) begin
        case (ImmSrc)
            2'b00: ExtImm = {24'd0, Instr[7:0]}; // Extensión de 8 bits
            2'b01: ExtImm = {20'd0, Instr[11:0]}; // Extensión de 12 bits
            2'b10: ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'b00}; // Extensión de 24 bits
            default: ExtImm = 32'd0; // Valor por defecto
        endcase
    end
endmodule

// Módulo de ALU
module alu (
    input wire [31:0] a, // Primer operando
    input wire [31:0] b, // Segundo operando
    input wire [1:0] control, // Control de la operación
    output wire [31:0] y, // Resultado de la ALU
    output wire [3:0] flags // Flags de la ALU
);
    reg [31:0] result; // Resultado de la operación
    reg Z, N, C, V; // Flags de la ALU

    always @(*) begin
        case (control)
            2'b00: result = a + b; // Suma
            2'b01: result = a - b; // Resta
            2'b10: result = a & b; // AND
            2'b11: result = a | b; // OR
            default: result = 32'd0; // Valor por defecto
        endcase

        // Cálculo de los flags
        Z = (result == 32'd0) ? 1'b1 : 1'b0; // Flag de cero
        N = result[31]; // Flag de negativo
        // Flags C y V simplificados para este ejemplo
        C = 1'b0;
        V = 1'b0;
    end

    assign y = result; // Asignación del resultado
    assign flags = {N, Z, C, V}; // Asignación de los flags
endmodule

// Módulo de Adder
module adder #(parameter WIDTH = 32) (
    input wire [WIDTH-1:0] a, // Primer operando
    input wire [WIDTH-1:0] b, // Segundo operando
    output wire [WIDTH-1:0] y // Resultado de la suma
);
    assign y = a + b; // Suma de los operandos
endmodule

// Módulo de Flip-Flop con Reset
module flopr #(parameter WIDTH = 32) (
    input wire clk, // Señal de reloj
    input wire reset, // Señal de reset
    input wire [WIDTH-1:0] d, // Datos de entrada
    output reg [WIDTH-1:0] q // Datos de salida
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 0; // Reset del registro
        else
            q <= d; // Almacenamiento de datos
    end
endmodule

// Módulo de Flip-Flop con Reset y Enable
module flopenr #(parameter WIDTH = 32) (
    input wire clk, // Señal de reloj
    input wire reset, // Señal de reset
    input wire en, // Señal de habilitación
    input wire [WIDTH-1:0] d, // Datos de entrada
    output reg [WIDTH-1:0] q // Datos de salida
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            q <= 0; // Reset del registro
        else if (en)
            q <= d; // Almacenamiento de datos si está habilitado
    end
endmodule

// Módulo de Mux de 2 a 1
module mux2 #(parameter WIDTH = 32) (
    input wire [WIDTH-1:0] d0, // Entrada 0
    input wire [WIDTH-1:0] d1, // Entrada 1
    input wire s, // Selección
    output wire [WIDTH-1:0] y // Salida
);
    assign y = s ? d1 : d0; // Selección de la salida
endmodule