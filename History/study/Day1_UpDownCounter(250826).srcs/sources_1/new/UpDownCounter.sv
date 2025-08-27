`timescale 1ns / 1ps

// logic으로 선언 안 하면 default가 wire로 선언됨
module UpDownCounter (
    input  logic        clk,
    input  logic        rst,
    input  logic        sw_mode,
    output logic [13:0] count
);

    logic tick_10hz;
    logic i_mode, o_mode;

    btn_debounce U_btn_debounce(
        .clk(clk),
        .rst(rst),
        .i_btn(sw_mode),
        .o_btn(i_mode)
    );

    mode_trigger U_mode_trigger(
        .clk(clk),
        .rst(rst),
        .i_mode(i_mode),
        .o_mode(o_mode)
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
        .mode (o_mode),
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

module btn_debounce (
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);
    parameter F_COUNT = 1000;  // 100M /100k
    // 100khz
    reg [$clog2(F_COUNT)-1:0] r_counter;
    reg r_clk;
    reg [7:0] q_reg, q_next; // for shift register
    wire w_debounce;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter <=0;
            r_clk <= 0;
        end else begin
            if (r_counter == (F_COUNT-1)) begin
                r_counter <= 0;
                r_clk <= 1'b1;
            end else begin
                r_counter <= r_counter +1;
                r_clk <= 1'b0;
            end
        end
    end

    // shift debounce

    always @(posedge r_clk, posedge rst) begin
        if (rst) begin
            q_reg <= 0;
        end else begin
            q_reg <= q_next;
        end 
    end

    always @(i_btn, q_reg) begin
        q_next = {i_btn, q_reg [7:1]};
    end

    reg r_edge_q; // Q5

    // 8 input and gate
    assign w_debounce = &q_reg;

    // edge detectior 
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_edge_q <= 0;
        end else begin
            r_edge_q <= w_debounce;
        end
    end

     // rising edge
     assign o_btn = w_debounce;


endmodule

module mode_trigger (
    input  logic clk,
    input  logic rst,
    input  logic i_mode,
    output logic o_mode
);
    logic mode;

    always_ff @( posedge clk or posedge rst ) begin 
        if (rst) begin
            o_mode <= 1'b0;
            mode <= 0;
        end else begin
            mode <= i_mode;
            if (mode && (i_mode == 0)) begin
                o_mode <= ~o_mode; // toggle mode
            end
        end
    end
    
endmodule