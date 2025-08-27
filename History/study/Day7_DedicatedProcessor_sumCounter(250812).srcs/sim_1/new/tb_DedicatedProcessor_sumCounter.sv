`timescale 1ns / 1ps



module tb_DedicatedProcessor_sumCounter ();

    logic clk;
    logic rst;
    logic [7:0] OutPort;
    DedicatedProcessor dut (.*);


    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #10;
        rst = 0;
    end
endmodule
