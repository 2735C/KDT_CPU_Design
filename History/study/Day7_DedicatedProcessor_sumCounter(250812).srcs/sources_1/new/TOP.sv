`timescale 1ns / 1ps



module TOP (
    input logic clk,
    input logic rst,
    output logic [3:0] fndCom,
    output logic [7:0] fndFont
);


    logic clk_10hz;
    logic [7:0] OutPort;


    clk_div_10hz U_ClkDiv (

        .clk(clk),
        .rst(rst),
        .clk_10hz(clk_10hz)
    );

    DedicatedProcessor U_DedicatedProcessor (
        .clk(clk_10hz),
        .rst(rst),
        .OutPort(OutPort)
    );

    fndController U_FndController (
        .clk(clk),
        .rst(rst),
        .number({6'b0, OutPort}),
        .fndCom(fndCom),
        .fndFont(fndFont)
    );
endmodule



module clk_div_10hz (

    input  logic clk,
    input  logic rst,
    output logic clk_10hz
);

    logic [$clog2(10_000_0000 -1):0] div_counter;


    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            div_counter <= 0;
            clk_10hz <= 1'b0;
        end else begin
            if (div_counter == 10_000_000 - 1) begin  //0.1s
                div_counter <= 0;
                clk_10hz <= 1'b1;
            end else begin
                div_counter <= div_counter + 1;
                clk_10hz <= 1'b0;
            end
        end
    end

endmodule
