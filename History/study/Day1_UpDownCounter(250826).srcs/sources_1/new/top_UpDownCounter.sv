`timescale 1ns / 1ps

module top_UpDownCounter (
    input logic clk,
    input logic rst,
    input logic sw_mode,
    output logic [3:0] fndCom,
    output logic [7:0] fndFont

);

    logic [13:0] count;

    UpDownCounter U_UpDownCounter (
        .clk(clk),
        .rst(rst),
        .sw_mode(sw_mode),
        .count(count)
    );


    fndController U_FndController (
        .clk(clk),
        .rst(rst),
        .number(count),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );

endmodule
