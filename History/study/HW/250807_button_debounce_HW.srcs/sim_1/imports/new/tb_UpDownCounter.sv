`timescale 1ns / 1ps

class transation;
    rand bit button;
    function  bit run_random(); //return data type, function name
        return button;
    endfunction
endclass //trsansation

module tb_UpDownCounter( );

    logic clk;
    logic rst;
    logic button;
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
    transation tr; //make class instance

    always #5 clk = ~clk; // 10ns 주기로 클럭 생성

    initial begin
        clk = 0;
        rst = 1;
        tr = new(); // 클래스 인스턴스 생성
        #10;
        rst = 0;
        button = 0; // 초기 버튼 상태
        #20;

        //push button
        button = 1; // 버튼 눌림 상태
        for (int i = 0; i < 60; i ++) begin  
            tr.randomize(); // 랜덤 버튼 값 생성
            button = tr.run_random(); // 클래스 메소드 호출
            #1;
        end
        button = 1;
        #150;

        //release button
        button = 0;
        for (int i = 0; i < 30; i ++) begin  
            tr.randomize(); // 랜덤 버튼 값 생성
            button = tr.run_random(); // 클래스 메소드 호출
            #1;
        end
        button = 0;
        #100;
        $finish; // 시뮬레이션 종료
    end
    
endmodule
