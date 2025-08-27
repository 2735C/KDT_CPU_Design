`timescale 1ns / 1ps

module tb_RB32I ();

    logic clk;
    logic rst;

    MCU dut (.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #20;
        rst = 0;
        #60;
        $finish;
    end
endmodule
