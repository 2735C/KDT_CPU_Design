`timescale 1ns / 1ps

module TEST_UART (
    input logic clk,
    input logic reset,
    input logic rx,

    output logic tx
);

    logic [7:0] rx_data;
    logic rx_done;

    uart UART (
        .clk(clk),
        .reset(reset),
        .start(rx_done),
        .tx_data(rx_data),
        .rx(rx),

        .rx_data(rx_data),
        .rx_done(rx_done),
        .rx_busy(),
        .tx(tx),
        .tx_done(),
        .tx_busy()
    );


    module uart (
    input  logic clk,
    input  logic rst,
    input  logic rx,
    //output logic tx_busy,
    //output logic tx_done,
    output logic tx
);

endmodule



`timescale 1ns / 1ps

module uart (
    input logic       clk,
    input logic       reset,
    input logic       start,
    input logic [7:0] tx_data,
    input logic       rx,

    output logic [7:0] rx_data,
    output logic       rx_done,
    output logic       rx_busy,
    output logic       tx,
    output logic       tx_done,
    output logic       tx_busy
);
    logic w_baud_tick;
    logic w_rx_done_tx_start;

    baudrate_gen U_BAUD_GEN (
        .clk(clk),
        .reset(reset),
        .baud_tick(w_baud_tick)
    );

    transmitter U_TRANSMITTER (
        .clk(clk),
        .reset(reset),
        .start(w_rx_done_tx_start),
        .baud_tick(w_baud_tick),
        .tx_data(rx_data),

        .tx(tx),
        .tx_done(),
        .tx_busy()
    );

    receiver U_RECEIVER (
        .clk(clk),
        .reset(reset),
        .baud_tick(w_baud_tick),
        .rx(rx),

        .rx_data(rx_data),
        .rx_done(w_rx_done_tx_start)
    );


endmodule



// baud rate : 9600bps -> 9600*16bps (안정된 신호를 위한 bit sampling 16회 )
// 100_000_000 / 1 -> 1hz
// 100_000_000 / 10 -> 10hz
// 100_000_000 / 9600 -> 9600hz
module baudrate_gen (
    input  logic clk,
    input  logic reset,
    output logic baud_tick
);
    logic [$clog2(100_000_000 / 9600 / 16)-1:0] baud_counter;
    // logic [3:0] baud_counter;  // simulation용

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            baud_counter <= 0;
            baud_tick <= 1'b0;
        end else begin
            if (baud_counter == (100_000_000 / 9600 / 16) - 1) begin
            // if (baud_counter == 10 - 1) begin  // simulation용
                baud_counter <= 0;
                baud_tick <= 1'b1;
            end else begin
                baud_counter <= baud_counter + 1;
                baud_tick <= 1'b0;
            end
        end
    end

endmodule



module receiver (
    input  logic       clk,
    input  logic       reset,
    input  logic       baud_tick,
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    typedef enum {
        IDLE,
        START,
        DATA,
        STOP
    } rx_state_e;

    rx_state_e c_rx_state, n_rx_state;

    logic [7:0] temp_data_reg, temp_data_next;
    logic [4:0] tick_cnt_reg, tick_cnt_next;
    logic [2:0] bit_cnt_reg, bit_cnt_next;
    logic rx_done_reg, rx_done_next;

    assign rx_data = temp_data_reg;
    assign rx_done = rx_done_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            c_rx_state <= IDLE;
            temp_data_reg <= 0;
            tick_cnt_reg <= 0;
            bit_cnt_reg <= 0;
            rx_done_reg <= 0;
        end else begin
            c_rx_state <= n_rx_state;
            temp_data_reg <= temp_data_next;
            tick_cnt_reg <= tick_cnt_next;
            bit_cnt_reg <= bit_cnt_next;
            rx_done_reg <= rx_done_next;
        end
    end

    always_comb begin
        n_rx_state = c_rx_state;
        temp_data_next = temp_data_reg;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;
        rx_done_next = rx_done_reg;
        case (c_rx_state)
            IDLE: begin
                rx_done_next = 0;
                if (rx == 0) begin
                    temp_data_next = 0;
                    tick_cnt_next = 0;
                    bit_cnt_next = 0;
                    n_rx_state = START;
                end
            end
            START: begin
                if (baud_tick) begin
                    if (tick_cnt_reg == 7) begin
                        n_rx_state = DATA;
                        tick_cnt_next = 0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                if (baud_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next  = 0;
                        temp_data_next = {rx, temp_data_reg[7:1]};
                        if (bit_cnt_reg == 7) begin
                            n_rx_state   = STOP;
                            bit_cnt_next = 0;
                        end else begin
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                if (baud_tick) begin
                    if (tick_cnt_reg == 23) begin
                        tick_cnt_next = 0;
                        rx_done_next = 1;
                        n_rx_state = IDLE;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule





module transmitter (
    input  logic       clk,
    input  logic       reset,
    input  logic       start,
    input  logic       baud_tick,
    input  logic [7:0] tx_data,
    output logic       tx,
    output logic       tx_done,
    output logic       tx_busy
);
    typedef enum {
        IDLE,
        START,
        DATA,
        STOP
    } tx_state_e;

    tx_state_e c_tx_state, n_tx_state;

    logic [7:0] temp_data_reg, temp_data_next;
    logic [3:0] tick_cnt_reg, tick_cnt_next;
    logic [2:0] bit_cnt_reg, bit_cnt_next;
    logic tx_done_reg, tx_done_next;
    logic tx_busy_reg, tx_busy_next;
    // logic tx_reg, tx_next;

    assign tx_done = tx_done_reg;
    assign tx_busy = tx_busy_reg;
    // assign tx = tx_reg;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            c_tx_state    <= IDLE;
            temp_data_reg <= 0;
            tick_cnt_reg <= 0;
            bit_cnt_reg <= 0;
            tx_done_reg <=0;
            tx_busy_reg <= 0;
            // tx_reg <= 0;
        end else begin
            c_tx_state    <= n_tx_state;
            temp_data_reg <= temp_data_next;
            tick_cnt_reg <= tick_cnt_next;
            bit_cnt_reg <= bit_cnt_next;
            tx_done_reg <=tx_done_next;
            tx_busy_reg <= tx_busy_next;
            // tx_reg <= tx_next;
        end
    end

    always_comb begin
        n_tx_state = c_tx_state;
        temp_data_next = temp_data_reg;
        tick_cnt_next = tick_cnt_reg;
        bit_cnt_next = bit_cnt_reg;
        tx_done_next = tx_done_reg;
        tx_busy_next = tx_busy_reg;
        tx = 0;
        // tx_next = tx_reg;
        case (c_tx_state)
            IDLE: begin
                tx = 1'b1;
                tx_done_next = 1'b0;
                tx_busy_next = 1'b0;
                if (start) begin
                    n_tx_state = START;
                    temp_data_next = tx_data;
                    tick_cnt_next = 0;
                    bit_cnt_next = 0;
                    tx_done_next = 1'b0;
                    tx_busy_next = 1'b1;
                end
            end
            START: begin
                tx = 1'b0;
                if (baud_tick) begin
                    if (tick_cnt_reg == 15) begin
                        n_tx_state = DATA;
                        tick_cnt_next = 0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA: begin
                tx = temp_data_reg[0];
                if (baud_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        if (bit_cnt_reg == 7) begin
                            n_tx_state   = STOP;
                            bit_cnt_next = 0;
                        end else begin
                            temp_data_next = {
                                1'b0, temp_data_reg[7:1]
                            };  // bit right shift
                            bit_cnt_next = bit_cnt_reg + 1;
                        end
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            STOP: begin
                tx = 1'b1;
                if (baud_tick) begin
                    if (tick_cnt_reg == 15) begin
                        tick_cnt_next = 0;
                        n_tx_state = IDLE;
                        tx_done_next = 1'b1;
                        tx_busy_next = 1'b0;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
        endcase
    end

endmodule
