`timescale 1ns / 1ps

// logic으로 선언 안 하면 default가 wire로 선언됨
module UpDownCounter (
    input  logic        clk,
    input  logic        rst,
    input  logic        button,
    output logic [13:0] count
);

    logic tick_10hz;
    logic mode;

    control_unit U_control_unit (
        .clk(clk),
        .rst(rst),
        .button(button),
        .mode(mode)
    );

    clk_div_10hz U_Clk_Div_10hz (
        .clk      (clk),
        .rst      (rst),
        .tick_10hz(tick_10hz)
    );

    up_down_counter U_Up_Down_Counter (
        .clk  (clk),
        .rst  (rst),
        .tick (tick_10hz),
        .mode (mode),
        .count(count)
    );



endmodule

module up_down_counter (
    input  logic        clk,
    input  logic        rst,
    input  logic        tick,
    input  logic        mode,
    output logic [13:0] count
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
        end else begin
            if (mode == 1'b0) begin  // up counter
                if (tick) begin
                    if (count == 9999) begin
                        count <= 0;
                    end else begin
                        count <= count + 1;
                    end
                end
            end else begin  // down counter
                if (tick) begin
                    if (count == 0) begin
                        count <= 9999;
                    end else begin
                        count <= count - 1;
                    end
                end
            end
        end
    end
endmodule


module clk_div_10hz (
    input  logic clk,
    input  logic rst,
    output logic tick_10hz
);
    //logic [23:0] div_counter;
    logic [$clog2(10_000_000)-1:0] div_counter;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            div_counter <= 0;
            tick_10hz   <= 1'b0;
        end else begin
            if (div_counter == 10_000_000 - 1) begin
                div_counter <= 0;
                tick_10hz   <= 1'b1;
            end else begin
                div_counter <= div_counter + 1;
                tick_10hz   <= 1'b0;
            end
        end
    end
endmodule


module control_unit (
    input  logic clk,
    input  logic rst,
    input  logic button,
    output logic mode
);

    typedef enum {
        UP,
        DOWN
    } state_e;

    state_e state, next_state;

    //state memory
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= UP;
        end else begin
            state <= next_state;
        end
    end

    //output logic
    always_comb begin
        next_state = state;  // 기본적으로 현재 상태 유지
        mode = 0;  // 기본 모드 설정
        case (state)
            UP: begin
                mode = 0;
                if (button) begin
                    next_state = DOWN; // 버튼이 눌리면 DOWN 상태로 전환
                end
            end
            DOWN: begin
                mode = 1;
                if (button) begin
                    next_state = UP;  // 버튼이 눌리면 UP 상태로 전환
                end
            end
        endcase
    end

endmodule
