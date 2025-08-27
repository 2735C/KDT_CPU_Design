`timescale 1ns / 1ps


module Dedicated_Processor_Counter (
    input logic clk,
    input logic rst,
    output logic [7:0] SOutReg
);

    logic ASrcMuxSel;
    logic SumMuxSel;
    logic AEn;
    logic SumEn;
    logic ALt10;
    logic SLt45;
    logic OutBufEn;
    logic SOutBufEn;
    logic S2OutBufEn;
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
        .clk(clk),  //clk_10hz
        .*
    );
    Datapath U_Datapath (
        .clk(clk),  // clk_10hz
        .*
    );

endmodule


module Datapath (
    input logic clk,
    input logic rst,
    input logic ASrcMuxSel,
    input logic SumMuxSel,
    input logic AEn,
    input logic SumEn,
    input logic OutBufEn,
    input logic SOutBufEn,
    input logic S2OutBufEn,
    output logic ALt10,
    output logic SLt45,
    output logic [7:0] SOutReg
);

    logic [7:0]
        AdderResult,
        ASrcMuxOut,
        ARegOut,
        SdderResult,
        SumMuxOut,
        SOutBuf,
        SRegOut, OutBuffer;

    mux_2x1 U_ASrcMux (
        .sel(ASrcMuxSel),
        .x0 (8'b0),
        .x1 (AdderResult),
        .y  (ASrcMuxOut)
    );

    mux_2x1 U_SumMux (
        .sel(SumMuxSel),
        .x0 (8'b0),
        .x1 (SdderResult),
        .y  (SumMuxOut)
    );

    register U_A_Reg (
        .clk(clk),
        .rst(rst),
        .en (AEn),
        .d  (ASrcMuxOut),
        .q  (ARegOut)
    );

    register U_S_Reg (
        .clk(clk),
        .rst(rst),
        .en (SumEn),
        .d  (SumMuxOut),
        .q  (SRegOut)
    );

    Comparator U_ALt10 (
        .a (ARegOut),
        .b (8'd10),
        .lt(ALt10)
    );

    Comparator U_SLt45 (
        .a (SRegOut),
        .b (8'd45),
        .lt(SLt45)
    );

    adder U_Adder (
        .a  (ARegOut),
        .b  (1),
        .sum(AdderResult)
    );

    adder U_S_Adder (
        .a  (SRegOut),
        .b  (ARegOut),
        .sum(SdderResult)
    );

    register U_OutReg (
        .clk(clk),
        .rst(rst),
        .en (OutBufEn),
        .d  (ARegOut),
        .q  (OutBuffer)
    );


    register U_S_InReg (
        .clk(clk),
        .rst(rst),
        .en (SOutBufEn),
        .d  (SRegOut),
        .q  (SOutBuf)
    );

    register U_S_OutReg (
        .clk(clk),
        .rst(rst),
        .en (S2OutBufEn),
        .d  (SdderResult),
        .q  (SOutReg)
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
    input  logic SLt45,
    output logic ASrcMuxSel,
    output logic SumMuxSel,
    output logic AEn,
    output logic SumEn,
    output logic OutBufEn,
    output logic SOutBufEn,
    output logic S2OutBufEn
);

    typedef enum {
        S0,
        S1,
        S2,
        S3,
        S4,
        S5
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

        ASrcMuxSel= 0;
        SumMuxSel= 0;
        AEn= 0;
        SumEn= 0;
        OutBufEn= 0;
        SOutBufEn= 0;
        S2OutBufEn= 0;
        next_state = state;

        case (state)
            S0: begin  // A = 0, Sum = 0
                ASrcMuxSel = 0;
                AEn = 1;
                OutBufEn = 0;

                SumMuxSel = 0;
                SumEn = 1;
                SOutBufEn  = 0;
                S2OutBufEn = 0; 

                next_state = S1;
            end
            S1: begin  // A < 10, Sum < 45
                ASrcMuxSel = 1;
                AEn = 0;
                OutBufEn = 0;
                if (ALt10) next_state = S2;
                else next_state = S5;
                
                SumMuxSel = 1;
                SumEn = 0;
                SOutBufEn  = 0;
                S2OutBufEn = 0; 

                if (SLt45) next_state = S2;
                else next_state = S5;
            end
            S2: begin  // Output = A, Output = Sum
                ASrcMuxSel = 1;
                AEn = 0;
                OutBufEn = 1;

                SumMuxSel = 1;
                SumEn = 0;
                SOutBufEn  = 1;
                S2OutBufEn = 0; 

                next_state = S3;
            end
            S3: begin  // A = A + 1 , Sum = Sum +A
                ASrcMuxSel = 1;
                AEn = 1;
                OutBufEn = 0;

                SumMuxSel = 1;
                SumEn = 1;
                SOutBufEn  = 0;
                S2OutBufEn = 0; 
                
                next_state = S4;
            end
            S4: begin  // output = Sum
                ASrcMuxSel = 0;
                AEn = 0;
                OutBufEn = 0;

                SumMuxSel = 0;
                SumEn = 0;
                SOutBufEn  = 0;
                S2OutBufEn = 1; 

                next_state = S1;
            end
            S5: begin  // halt
                ASrcMuxSel = 1;
                AEn = 0;
                OutBufEn = 0;
                next_state = S5;
            end
        endcase
    end
endmodule


