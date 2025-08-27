`timescale 1ns / 1ps

module top_UpDownCounter (
    input  logic       clk,
    input  logic       rst,
    input  logic       mode,
    input  logic       left,
    input  logic       right,
    output logic [3:0] fndCom,
    output logic [7:0] fndFont,
    output logic [3:0] led

);

    logic [13:0] count;
    logic o_mode, o_left, o_center, o_right;

    button_detector U_mode_detector (
        .clk         (clk),
        .rst         (rst),
        .in_button   (mode),
        .rising_edge (),
        .falling_edge(o_mode),
        .both_edge   ()
    );

    button_detector U_left_detector (
        .clk         (clk),
        .rst         (rst),
        .in_button   (left),
        .rising_edge (),
        .falling_edge(o_left),
        .both_edge   ()
    );

    button_detector U_right_detector (
        .clk         (clk),
        .rst         (rst),
        .in_button   (right),
        .rising_edge (),
        .falling_edge(o_right),
        .both_edge   ()
    );


    UpDownCounter U_UpDownCounter (
        .clk  (clk),
        .rst  (rst),
        .mode (o_mode),
        .run  (o_left),
        .clear(o_right),
        .count(count),
        .led  (led)
    );



    fndController U_FndController (
        .clk    (clk),
        .rst    (rst),
        .number (count),
        .fndCom (fndCom),
        .fndFont(fndFont)
    );

endmodule
