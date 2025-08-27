`timescale 1ns / 1fs

class transation;
    rand bit button;
    function  bit run_random(); //return data type, function name
        return button;
    endfunction
endclass //trsansation


module tb_button_detector ();

    logic clk;
    logic rst;
    logic in_button;
    logic rising_edge;
    logic falling_edge;
    logic both_edge;

    transation tr; //make class instance

    button_detector dut (
        .clk(clk),
        .rst(rst),
        .in_button(in_button),
        .rising_edge(rising_edge),
        .falling_edge(falling_edge),
        .both_edge(both_edge)
    );

    always #5 clk = ~clk; // 10ns 주기로 클럭 생성

    initial begin
        clk = 0;
        rst = 1;
        tr = new(); // 클래스 인스턴스 생성
        #10;
        rst = 0;
        in_button = 0; // 초기 버튼 상태
        #20;

        //push button
        in_button = 1; // 버튼 눌림 상태
        for (int i = 0; i < 60; i ++) begin  
            tr.randomize(); // 랜덤 버튼 값 생성
            in_button = tr.run_random(); // 클래스 메소드 호출
            #1;
        end
        in_button = 1;
        #150;

        //release button
        in_button = 0;
        for (int i = 0; i < 30; i ++) begin  
            tr.randomize(); // 랜덤 버튼 값 생성
            in_button = tr.run_random(); // 클래스 메소드 호출
            #1;
        end
        in_button = 0;
        #100;
        $finish; // 시뮬레이션 종료
    end
    

endmodule
