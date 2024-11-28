module branch_predictor (
    input wire clk,
    input wire reset,
    input wire branch,
    input wire taken,
    output reg predict_taken
);

    // Estados del predictor de dos bits
    parameter STRONGLY_NOT_TAKEN = 2'b00;
    parameter WEAKLY_NOT_TAKEN   = 2'b01;
    parameter WEAKLY_TAKEN       = 2'b10;
    parameter STRONGLY_TAKEN     = 2'b11;

    reg [1:0] state, nextstate;

        // Lógica de transición de estados
    always @(*) begin
        case (state)
            STRONGLY_NOT_TAKEN: next_state = taken ? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN;
            WEAKLY_NOT_TAKEN:   next_state = taken ? WEAKLY_TAKEN : STRONGLY_NOT_TAKEN;
            WEAKLY_TAKEN:       next_state = taken ? STRONGLY_TAKEN : WEAKLY_NOT_TAKEN;
            STRONGLY_TAKEN:     next_state = taken ? STRONGLY_TAKEN : WEAKLY_TAKEN;
            default:            next_state = STRONGLY_NOT_TAKEN;
        endcase
    end

    // Actualización del estado
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= STRONGLY_NOT_TAKEN;
        else if (branch)
            state <= next_state;
    end

    // Predicción de la rama
    always @(*) begin
        case (state)
            STRONGLY_NOT_TAKEN, WEAKLY_NOT_TAKEN: predict_taken = 1'b0;
            WEAKLY_TAKEN, STRONGLY_TAKEN:         predict_taken = 1'b1;
        endcase
    end
endmodule