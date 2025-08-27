`timescale 1ns / 1ps

module top_UpDownCounter (
    input  logic       clk,
    input  logic       rst,
    input  logic       button,
    output logic [3:0] fndCom,
    output logic [7:0] fndFont

);

    logic [13:0] count;
    logic falling_edge;

    button_detector U_button_detector (
        .clk         (clk),
        .rst         (rst),
        .in_button   (button),
        .rising_edge (),
        .falling_edge(falling_edge),
        .both_edge   ()
    );

    UpDownCounter U_UpDownCounter (
        .clk   (clk),
        .rst   (rst),
        .button(falling_edge),
        .count (count)
    );


    fndController U_FndController (
        .clk    (clk),
        .rst    (rst),
        .number (count),
        .fndCom (fndCom),
        .fndFont(fndFont)
    );

endmodule
