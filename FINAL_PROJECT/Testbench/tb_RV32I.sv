`timescale 1ns / 1ps

module tb_RV32I_update ();
    logic clk;
    logic reset;

    MCU dut (.*);

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        #10;
        reset = 0;
        #(1000);
        #(25000) $finish;
    end
endmodule
