`timescale 1ns / 1ps

module Dedicated_Processor_Counter (
    input logic clk,
    input logic rst,
    output logic [7:0] OutBuffer
);

    logic ASrcMuxSel;
    logic AEn;
    logic ALt10;
    logic OutBufEn;
    logic [$clog2(10_000_0000 -1):0] div_counter;
    logic clk_10hz;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            div_counter <= 0;
        end else begin
            if (div_counter == 10_000_000 - 1) begin  //0.1s
                div_counter <= 0;
                clk_10hz <= 1'b1;
            end else begin
                div_counter <= div_counter + 1;
                clk_10hz <= 1'b0;
            end
        end
    end

    Controlunit U_Controlunit (
        .clk(clk_10hz),  //clk_10hz
        .*
    );
    Datapath U_Datapath (
        .clk(clk_10hz), // clk_10hz
        .*
    );

endmodule


module Datapath (
    input logic clk,
    input logic rst,
    input logic ASrcMuxSel,
    input logic AEn,
    input logic OutBufEn,
    output logic ALt10,
    output logic [7:0] OutBuffer
);

    logic [7:0] AdderResult, ASrcMuxOut, ARegOut;

    mux_2x1 U_ASrcMux (
        .sel(ASrcMuxSel),
        .x0 (8'b0),
        .x1 (AdderResult),
        .y  (ASrcMuxOut)
    );

    register U_A_Reg (
        .clk(clk),
        .rst(rst),
        .en (AEn),
        .d  (ASrcMuxOut),
        .q  (ARegOut)
    );

    Comparator U_ALt10 (
        .a (ARegOut),
        .b (8'd10),
        .lt(ALt10)
    );

    adder U_Adder (
        .a  (ARegOut),
        .b  (1),
        .sum(AdderResult)
    );

    //OutBuf U_OutBuf (
    //    .en(OutBufEn),
    //    .x (ARegOut),
    //    .y (OutBuffer)
    //);

    
    register U_OutReg (  // 값을 유지하게 만들고 싶어서 buffer 대신 register로 교체
        .clk(clk),
        .rst(rst),
        .en (OutBufEn),
        .d  (ARegOut),
        .q  (OutBuffer)
    );

endmodule

module register (
    input  logic       clk,
    input  logic       rst,
    input  logic       en,
    input  logic [7:0] d,
    output logic [7:0] q
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 0;
        end else begin
            if (en) begin
                q <= d;
            end
        end

    end

endmodule

module mux_2x1 (
    input  logic       sel,
    input  logic [7:0] x0,
    input  logic [7:0] x1,
    output logic [7:0] y
);

    always_comb begin
        y = 8'b0; //경우의 수가 다 있지만 습관을 만들기 위해 default값 추가
        case (sel)
            1'b0: y = x0;
            1'b1: y = x1;
        endcase

    end
endmodule

module adder (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] sum
);
    assign sum = a + b;
endmodule

module Comparator (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic       lt
);
    assign lt = a < b;
endmodule

module OutBuf (
    input logic en,
    input logic [7:0] x,
    output logic [7:0] y
);
    assign y = en ? x : 8'bx;
endmodule

module Controlunit (
    input  logic clk,
    input  logic rst,
    input  logic ALt10,
    output logic ASrcMuxSel,
    output logic AEn,
    output logic OutBufEn
);
    typedef enum {
        S0,
        S1,
        S2,
        S3,
        S4
    } state_e;

    state_e state, next_state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S0;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        ASrcMuxSel = 0;
        AEn = 0;
        OutBufEn = 0;
        next_state = state;
        case (state)
            S0: begin
                ASrcMuxSel = 0;
                AEn = 1;
                OutBufEn = 0;
                next_state = S1;
            end
            S1: begin
                ASrcMuxSel = 1;
                AEn = 0;
                OutBufEn = 0;
                if (ALt10) next_state = S2;
                else next_state = S4;
            end
            S2: begin
                ASrcMuxSel = 1;
                AEn = 0;
                OutBufEn = 1;
                next_state = S3;
            end
            S3: begin
                ASrcMuxSel = 1;
                AEn = 1;
                OutBufEn = 0;
                next_state = S1;
            end
            S4: begin
                ASrcMuxSel = 1;
                AEn = 0;
                OutBufEn = 0;
                next_state = S4;
            end
        endcase
    end
endmodule
