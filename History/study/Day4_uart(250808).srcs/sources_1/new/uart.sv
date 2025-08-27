`timescale 1ns / 1ps

module uart (
    input  logic       clk,
    input  logic       rst,
    input  logic       start,
    input  logic [7:0] tx_data,
    output logic       tx_busy,
    output logic       tx_done,
    output logic       tx
);

    logic br_tick;

    baudrate_gen U_baudrate_gen (
        .clk(clk),
        .rst(rst),
        .br_tick(br_tick)
    );

    transmitter U_transmitter (
        .clk(clk),
        .rst(rst),
        .br_tick(br_tick),
        .start(start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx(tx)
    );


endmodule

module baudrate_gen (
    input  logic clk,
    input  logic rst,
    output logic br_tick
);
    //logic [$clog2(100_000_000/9600/16) -1:0] br_counter; // 16번 sampling for 9600 baud rate
    logic [3:0] br_counter;  // For simulation purposes, using a smaller counter

    always_ff @(posedge clk or posedge rst) begin : blockName
        if (rst) begin
            br_counter <= 0;
            br_tick <= 1'b0;
        end else begin
            //if  (br_counter == 100_000_000/9600 /16 -1) begin //9600hz = 9600 bps, 100_000_000 :1hz 원하는 주파수를 만들려면 1hz/ 원하는 주파수 
            if (br_counter == 10 - 1) begin
                br_counter <= 0;
                br_tick <= 1'b1;
            end else begin
                br_counter <= br_counter + 1;
                br_tick <= 1'b0;
            end
        end
    end

endmodule


module transmitter (
    input  logic       clk,
    input  logic       rst,
    input  logic       br_tick,
    input  logic       start,
    input  logic [7:0] tx_data,
    output logic       tx_busy,
    output logic       tx_done,
    output logic       tx
);

    typedef enum {
        IDLE,
        START,
        DATA,
        STOP
    } tx_state_e;

    tx_state_e tx_state, tx_next_state;

    logic [7:0] temp_data_reg, temp_data_next;
    logic tx_reg, tx_next;
    logic [3:0] tick_cnt_reg, tick_cnt_next;
    logic [2:0] bit_cnt_reg, bit_cnt_next;
    logic tx_busy_reg, tx_busy_next;
    logic tx_done_reg, tx_done_next;

    assign tx = tx_reg;
    assign tx_busy = tx_busy_reg;
    assign tx_done = tx_done_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_state <= IDLE;
            temp_data_reg <= 8'b0;  // latch 방지용
            tx_reg <= 1'b1;
            tick_cnt_reg <= 0;
            bit_cnt_reg <= 0;
            tx_done_reg = 0;
            tx_busy_reg = 0;
        end else begin
            tx_state <= tx_next_state;
            temp_data_reg <= temp_data_next;  //latch 방지용
            tx_reg <= tx_next;
            tick_cnt_reg <= tick_cnt_next;
            bit_cnt_reg <= bit_cnt_next;
            tx_done_reg = tx_done_next;
            tx_busy_reg = tx_busy_next;
        end
    end

    always_comb begin
        tx_next_state = tx_state;  // 현재 상태 유지
        temp_data_next = temp_data_reg;  //latch 방지용
        //temp_data 하나만 사용하면 START 상태에서만 값이 정의되어 나머지 케이스에서 래치 발생 가능
        //tx는 모든 경우에 정의되어 지금은 ㄱㅊ
        tx_next = tx_reg;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;
        tx_busy_next = tx_busy_reg;
        tx_done_next = tx_done_reg;
        case (tx_state)
            IDLE: begin
                tx_next = 1'b1;
                tx_done_next = 0;
                tx_busy_next = 0;
                if (start) begin
                    tx_next_state  = START;
                    temp_data_next = tx_data;
                    tick_cnt_next  = 0;
                    bit_cnt_next   = 0;
                    tx_busy_next   = 1;
                end
            end
            START: begin
                tx_next = 1'b0;  // Start bit is low
                if (br_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tx_next_state = DATA;
                        tick_cnt_next = 0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                tx_next = temp_data_reg[0]; // Transmit the least significant bit first
                if (br_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        if (bit_cnt_reg == 7) begin
                            tx_next_state = STOP;
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
                tx_next = 1'b1;  // Stop bit is high
                if (br_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tx_next_state = IDLE;
                        tick_cnt_next = 0;
                        tx_busy_next  = 0;
                        tx_done_next  = 1;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule
