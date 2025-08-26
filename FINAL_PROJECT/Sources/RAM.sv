`timescale 1ns / 1ps
`include "defines.sv"

module RAM (
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] instrCode,
    input  logic [31:0] addr,
    input  logic [31:0] wData,
    output logic [31:0] rData
);
    logic [31:0] mem[0:2**8 - 1]; //0x00~0xff
        wire [2:0] func3 = instrCode[14:12];


    always_ff @( posedge clk ) begin
        if (we) begin
            case (func3)
                `SB: mem[addr[31:0]][7:0] <= wData[7:0];
                `SH: mem[addr[31:1]][15:0] <= wData[15:0];
                default: mem[addr[31:2]] <= wData; // SW
            endcase
        end 
    end

    assign rData = mem[addr[31:2]];
endmodule