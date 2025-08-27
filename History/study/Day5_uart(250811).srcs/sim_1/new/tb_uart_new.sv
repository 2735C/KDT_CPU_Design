`timescale 1ns / 1ps


module tb_uart_new ();

    //global signals
    logic       clk;
    logic       rst;
    //transmitter signals
    logic       start;
    logic [7:0] tx_data;
    logic       tx_busy;
    logic       tx_done;
    logic       tx;

    // receiver siganls
    logic       rx;
    logic [7:0] rx_data;
    logic       rx_done;

    uart dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx(tx),
        .rx(tx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #10;
        rst = 0;
        @(posedge clk);
        tx_data = 8'b11001010; start = 1;
        @(posedge clk)
        start = 0;
        @(rx_done);
        #50;
        $finish();

    end


endmodule
