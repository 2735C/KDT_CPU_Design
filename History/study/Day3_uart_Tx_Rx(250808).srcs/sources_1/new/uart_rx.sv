`timescale 1ns / 1ps

module uart_rx (
    input  logic       clk,
    input  logic       rst,
    input  logic       rx,
    input  logic [7:0] rx_data,
    output logic       rx_busy,
    output logic       rx_done,
    output logic       tx
);

    logic br_tick;

    baudrate_gen U_baudrate_gen_rx (
        .clk(clk),
        .rst(rst),
        .br_tick(br_tick)
    );

    receiver U_receiver (
        .clk(clk),
        .rst(rst),
        .br_tick(br_tick),
        .rx(rx),
        .rx_data(rx_data),
        .rx_busy(rx_busy),
        .rx_done(rx_done),
        .tx(tx)
    );


endmodule

module receiver (
    input  logic       clk,
    input  logic       rst,
    input  logic       br_tick,
    input  logic       rx,
    input  logic [7:0] rx_data,
    output logic       rx_busy,
    output logic       rx_done,
    output logic       tx
);

    typedef enum {
        IDLE,
        START,
        DATA,
        STOP
    } rx_state_e;

    rx_state_e rx_state, rx_next_state;

    logic [7:0] temp_data_reg, temp_data_next;
    logic rx_reg, rx_next;
    logic [3:0] tick_cnt_reg, tick_cnt_next;
    logic [2:0] bit_cnt_reg, bit_cnt_next;
    logic rx_busy_reg, rx_busy_next;
    logic rx_done_reg, rx_done_next;

    assign tx = rx_reg;
    assign rx_busy = rx_busy_reg;
    assign rx_done = rx_done_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_state <= IDLE;
            temp_data_reg <= 8'b0;  // latch 방지용
            rx_reg <= 1'b1;
            tick_cnt_reg <= 0;
            bit_cnt_reg <= 0;
            rx_done_reg = 0;
            rx_busy_reg = 0;
        end else begin
            rx_state <= rx_next_state;
            temp_data_reg <= temp_data_next;  //latch 방지용
            rx_reg <= rx_next;
            tick_cnt_reg <= tick_cnt_next;
            bit_cnt_reg <= bit_cnt_next;
            rx_done_reg = rx_done_next;
            rx_busy_reg = rx_busy_next;
        end
    end

    always_comb begin
        rx_next_state = rx_state;  // 현재 상태 유지
        temp_data_next = temp_data_reg;  //latch 방지용
        //temp_data 하나만 사용하면 START 상태에서만 값이 정의되어 나머지 케이스에서 래치 발생 가능
        //rx는 모든 경우에 정의되어 지금은 ㄱㅊ
        rx_next = rx_reg;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;
        rx_busy_next = rx_busy_reg;
        rx_done_next = rx_done_reg;
        case (rx_state)
            IDLE: begin
                rx_next = 1'b1;
                rx_done_next = 0;
                rx_busy_next = 0;
                if (rx) begin
                    rx_next_state  = START;
                    temp_data_next = rx_data;
                    tick_cnt_next  = 0;
                    bit_cnt_next   = 0;
                    rx_busy_next   = 1;
                end
            end
            START: begin
                rx_next = 1'b0;  // Start bit is low
                if (br_tick) begin
                    if (tick_cnt_reg == 7) begin
                        rx_next_state = DATA;
                        tick_cnt_next = 0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                rx_next = temp_data_reg[0]; // Transmit the least significant bit first
                if (br_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        if (bit_cnt_reg == 7) begin
                            rx_next_state = STOP;
                            bit_cnt_next  = 0;
                        end else begin
                            temp_data_next = {1'b0, temp_data_reg[7:1]};
                            bit_cnt_next   = bit_cnt_reg + 1;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                rx_next = 1'b1;  // Stop bit is high
                if (br_tick) begin
                    if (tick_cnt_reg == 23) begin
                        rx_next_state = IDLE;
                        tick_cnt_next = 0;
                        rx_busy_next  = 0;
                        rx_done_next  = 1;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule
