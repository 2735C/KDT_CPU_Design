`timescale 1ns / 1ps



module tb_dedicated_processor_counter ();

    logic clk;
    logic rst;
    logic [7:0] OutBuffer;

    Dedicated_Processor_Counter dut (.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #10;
        rst = 0;
        #50;
    end

endmodule
