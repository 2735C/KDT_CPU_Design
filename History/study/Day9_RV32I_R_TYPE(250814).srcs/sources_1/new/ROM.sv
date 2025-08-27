`timescale 1ns / 1ps

module ROM (  // 명령어가 저장되어 있는 곳
    input  logic [31:0] addr,
    output logic [31:0] data
);

    logic [31:0] rom[0:61];

    initial begin
        //assembly code에 대한 machine code
        //rom [x] = 32'b func7(7) _ rs2(5) _ rs1(5) _ func3(3) _ rd(5) _ op(7)
        rom[0] = 32'b0000000_00001_00010_000_00100_0110011;  // add x4, x2, x1
        rom[1] = 32'b0100000_00001_00010_000_00101_0110011;  // sub x5, x2, x1
        rom[2] = 32'b0000000_00000_00011_111_00110_0110011;  // and x6, x3, x0
        rom[3] = 32'b0000000_00000_00011_110_00111_0110011;  // and x7, x3, x0
    end

    assign data = rom[addr[31:2]];
    //0-4-8 로 움직이는 걸 0-1-2로 생각하고 싶은데, 
    // 4를 나누면 나누기 연산이 크므로 배열을 잘라버린 것
endmodule

////////////////////////////////////////////////////////
//module ROM (         // 명령어가 저장되어 있는 곳
//    input  logic [31:0] addr,
//    output logic [31:0] data
//);
//
//    logic [31:0] rom[0:61];
//
//    assign data = rom[addr[31:2]]; 
//    //0-4-8 로 움직이는 걸 0-1-2로 생각하고 싶은데, 
//    // 4를 나누면 나누기 연산이 크므로 배열을 잘라버린 것
//endmodule
////////////////////////////////////////////////////////
