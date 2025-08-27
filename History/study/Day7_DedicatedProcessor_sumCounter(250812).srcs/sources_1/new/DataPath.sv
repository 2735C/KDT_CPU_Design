`timescale 1ns / 1ps

module Datapath (
    input logic clk,
    input logic rst,
    input logic SumSrcMuxSel,
    input logic ISrcMuxSel,
    input logic SumEn,
    input logic IEn,
    input logic AdderSrcMuxSel,
    input logic OutPortEn,
    output logic ILe10,
    output logic [7:0] OutPort

);

    logic [7:0] SumSrcMuxOut, ISrcMuxOut;
    logic [7:0] SumRegOut, IRegOut;
    logic [7:0] AdderResult, AdderSrcMuxOut;

    mux_2x1 U_SumSrcMux (
        .sel(SumSrcMuxSel),
        .x0 (0),
        .x1 (AdderResult),
        .y  (SumSrcMuxOut)
    );

    mux_2x1 U_ISrcMux (
        .sel(ISrcMuxSel),
        .x0 (0),
        .x1 (AdderResult),
        .y  (ISrcMuxOut)
    );

    register SumReg (
        .clk(clk),
        .rst(rst),
        .en (SumEn),
        .d  (SumSrcMuxOut),
        .q  (SumRegOut)
    );

    register IReg (
        .clk(clk),
        .rst(rst),
        .en (IEn),
        .d  (ISrcMuxOut),
        .q  (IRegOut)
    );

    Comparator U_ILe10 (
        .a  (IRegOut),
        .b  (10),
        .lte(ILe10)
    );

    mux_2x1 U_AdderSrcMux (
        .sel(AdderSrcMuxSel),
        .x0 (SumRegOut),
        .x1 (1),
        .y  (AdderSrcMuxOut)
    );

    adder U_Adder (
        .a  (AdderSrcMuxOut),
        .b  (IRegOut),
        .sum(AdderResult)
    );

    register U_Outport (
        .clk(clk),
        .rst(rst),
        .en (OutPortEn),
        .d  (SumRegOut),
        .q  (OutPort)
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
    output logic       lte
);
    assign lte = a <= b;
endmodule


