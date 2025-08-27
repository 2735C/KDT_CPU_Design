`timescale 1ns / 1ps

module tb_uart ();

    logic clk;
    logic rst;
    logic rx;
    logic tx_busy;
    logic tx_done;
    logic tx;

    uart dut (.*);

    always #5 clk = ~clk;
    //////////////////////////////////////
    //initial begin
    //    br_tick = 0;
    //    forever begin
    //        repeat (5) @(posedge clk);
    //        br_tick = 1'b1;
    //        #11;
    //        br_tick = 1'b0;
    //        #9;
    //    end
    //end
    //////////////////////////////////////

    initial begin
        clk = 0;
        rst = 1;
        rx  = 1;
        #10;
        rst = 0;
        #50;
        rx = 0;
        @(posedge clk);
        rx = 0;
        #1600;
        @(posedge clk);
        rx = 1;
        #1600;
        @(posedge clk);
        rx = 0;
        #1600;
        @(posedge clk);
        rx = 1;
        #1600;
        @(posedge clk);
        rx = 0;
        #1600;
        @(posedge clk);
        rx = 0;
        #1600;
        @(posedge clk);
        rx = 1;
        #1600;
        @(posedge clk);
        rx = 1;
        #1600;
    end

endmodule


