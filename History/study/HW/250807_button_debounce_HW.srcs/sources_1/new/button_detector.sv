`timescale 1ns / 1ps


module button_detector (
    input  logic clk,
    input  logic rst,
    input  logic in_button,
    output logic rising_edge,
    output logic falling_edge,
    output logic both_edge
);
    logic clk_1khz;
    logic debounce;
    logic [7:0] sh_reg;
    logic [$clog2(100_000)-1:0] div_counter; // 100_000은 1kHz 클럭을 생성하기 위한 카운터 값


    always_ff @( posedge clk or posedge rst ) begin
        if (rst) begin
            div_counter <= 0;
            clk_1khz <= 0;
        end else begin
            if (div_counter == 100_000 -1)begin
                div_counter <= 0;
                clk_1khz <= 1'b1; 
            end else begin
                div_counter <= div_counter +1;
                clk_1khz <=1'b0; 
            end
        end
    end

    shift_register U_shift_register (
        .clk(clk_1khz),
        .rst(rst),
        .in_data(in_button),
        .out_data(sh_reg)
    );

    assign debounce = &sh_reg; // sh_reg의 모든 비트가 1일 때만 debounce 신호가 1이 됨
    //assign out_button = debounce;

    logic [1:0] edge_reg;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            edge_reg <= 0;
        end else begin
            edge_reg[0] <= debounce;  // 현재 상태 저장
            edge_reg[1] <= edge_reg[0];  // 이전 상태 저장
        end
    end

    assign rising_edge = edge_reg[0] & ~edge_reg[1];  // 상승 에지 감지
    assign falling_edge = ~edge_reg[0] & edge_reg[1];  // 하강 에지 감지
    assign both_edge = rising_edge | falling_edge; // 상승 에지만 감지하여 출력
endmodule


module shift_register (
    input logic clk,
    input logic rst,
    input logic in_data,
    output logic [7:0] out_data
);
    logic [7:0] shift_reg;

    always_ff @(posedge clk or posedge rst) begin : blockName
        if (rst) begin
            out_data <= 0;
        end else begin
            out_data <= {in_data, out_data[7:1]};  // right shift: MSB에 in_data를 삽입
            //out_data <= {out_data[6:0], in_data}; // left shift: LSB에 in_data를 삽입
        end
    end
endmodule





