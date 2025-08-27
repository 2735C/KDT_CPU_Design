`timescale 1ns / 1ps

module tb_RV32I_update ();
    logic clk;
    logic rst;

    MCU dut (.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #10;
        rst = 0;
        #(160) $finish;
    end
endmodule
