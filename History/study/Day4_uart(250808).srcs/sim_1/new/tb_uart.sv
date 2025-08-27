`timescale 1ns / 1ps

module tb_uart ();

    logic       clk;
    logic       rst;
    logic       start;
    logic [7:0] tx_data;
    logic       tx_busy;
    logic       tx_done;
    logic       tx;


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
        #10;
        rst = 0;
        #10;
        @(posedge clk);
        tx_data = 8'b11001010;
        start   = 1;
        @(posedge clk);
        start = 0;
    end

endmodule
