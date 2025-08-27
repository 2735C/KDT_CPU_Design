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

    logic [31:0] mem[0:2**8-1];  // 256 words (32bit)
    wire [2:0] func3 = instrCode[14:12];

    // ----------------------
    // Write Logic (store)
    // ----------------------
    always_ff @(posedge clk) begin
        if (we) begin
            case (func3)
                `SB: begin
                    case (addr[1:0])
                        2'b00: mem[addr[31:2]] <= {mem[addr[31:2]][31:8], wData[7:0]};
                        2'b01: mem[addr[31:2]] <= {mem[addr[31:2]][31:16], wData[7:0], mem[addr[31:2]][7:0]};
                        2'b10: mem[addr[31:2]] <= {mem[addr[31:2]][31:24], wData[7:0], mem[addr[31:2]][15:0]};
                        2'b11: mem[addr[31:2]] <= {wData[7:0], mem[addr[31:2]][23:0]};
                    endcase
                end
                `SH: begin
                    case (addr[1])
                        1'b0: mem[addr[31:2]] <= {mem[addr[31:2]][31:16], wData[15:0]};
                        1'b1: mem[addr[31:2]] <= {wData[15:0], mem[addr[31:2]][15:0]};
                    endcase
                end
                default: mem[addr[31:2]] <= wData; // SW
            endcase
        end
    end

    // ----------------------
    // Read Logic (load)
    // write-first: 같은 clk에 write가 있으면 최신값 반영
    // ----------------------
    always_comb begin
        logic [31:0] word = mem[addr[31:2]];

        // write-forward 처리
        if (we && addr[31:2] == addr[31:2]) begin
            case (func3)
                `SB: begin
                    case (addr[1:0])
                        2'b00: word = {word[31:8], wData[7:0]};
                        2'b01: word = {word[31:16], wData[7:0], word[7:0]};
                        2'b10: word = {word[31:24], wData[7:0], word[15:0]};
                        2'b11: word = {wData[7:0], word[23:0]};
                    endcase
                end
                `SH: begin
                    case (addr[1])
                        1'b0: word = {word[31:16], wData[15:0]};
                        1'b1: word = {wData[15:0], word[15:0]};
                    endcase
                end
                default: word = wData; // SW
            endcase
        end

        // Load 처리
        case (func3)
            `LB: begin
                case (addr[1:0])
                    2'b00: rData = {{24{word[7]}},  word[7:0]};
                    2'b01: rData = {{24{word[15]}}, word[15:8]};
                    2'b10: rData = {{24{word[23]}}, word[23:16]};
                    2'b11: rData = {{24{word[31]}}, word[31:24]};
                endcase
            end
            `LBU: begin
                case (addr[1:0])
                    2'b00: rData = {24'b0, word[7:0]};
                    2'b01: rData = {24'b0, word[15:8]};
                    2'b10: rData = {24'b0, word[23:16]};
                    2'b11: rData = {24'b0, word[31:24]};
                endcase
            end
            `LH: begin
                case (addr[1])
                    1'b0: rData = {{16{word[15]}}, word[15:0]};
                    1'b1: rData = {{16{word[31]}}, word[31:16]};
                endcase
            end
            `LHU: begin
                case (addr[1])
                    1'b0: rData = {16'b0, word[15:0]};
                    1'b1: rData = {16'b0, word[31:16]};
                endcase
            end
            default: rData = word; // LW
        endcase
    end

endmodule
