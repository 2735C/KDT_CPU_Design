`timescale 1ns / 1ps


module tb_UpDownCounter( );

    logic clk;
    logic rst;
    logic sw_mode;
    logic [3:0] fndCom;
    logic [7:0] fndFont;

    //top moduleinstance 랑 이름이 아예 같으면 아래처럼 처리 가능

    top_UpDownCounter dut(.*);
    ////////////////////////////////
    //top_UpDownCounter dut(
    //    .clk(clk),
    //    .rst(rst),
    //    .sw_mode(sw_mode),
    //    .fndCom(fndCom),
    //    .fndFont(fndFont)
    //);
    ////////////////////////////////

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        sw_mode = 0;

        #20;
        rst = 0;

    end
    
endmodule
