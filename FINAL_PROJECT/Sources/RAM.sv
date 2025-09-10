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

    logic [7:0] mem[0:2**8 - 1]; // 0x00~0xff
    wire [2:0] func3 = instrCode[14:12];

    // Write
    always_ff @(posedge clk) begin
        if (we) begin
            case (func3)
                `SB: mem[addr] <= wData[7:0]; // byte write
                `SH: begin
                    mem[addr]   <= wData[7:0];   // low byte
                    mem[addr+1] <= wData[15:8];  // high byte
                end
                default: begin // SW
                    mem[addr]   <= wData[7:0];
                    mem[addr+1] <= wData[15:8];
                    mem[addr+2] <= wData[23:16];
                    mem[addr+3] <= wData[31:24];
                end
            endcase
        end
    end

    // Read
    always_comb begin
        case (func3)
            `LB:  rData = $signed({{24{mem[addr][7]}}, mem[addr]});
            `LH:  rData = $signed({{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]});
            `LBU: rData = {24'b0, mem[addr]};
            `LHU: rData = {16'b0, mem[addr+1], mem[addr]};
            default: rData = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]}; // LW
        endcase
    end

endmodule

/////////////////////////////////////////////////////////////////////////
//module RAM (
//    input  logic        clk,
//    input  logic        we,
//    input  logic [31:0] instrCode,
//    input  logic [31:0] addr,
//    input  logic [31:0] wData,
//    output logic [31:0] rData
//);
//    logic [31:0] mem[0:2**8 - 1]; //0x00~0xff
//        wire [2:0] func3 = instrCode[14:12];
//
//
//    always_ff @( posedge clk ) begin
//        if (we) begin
//            case (func3)
//                `SB: mem[addr[31:0]][7:0] <= wData[7:0];
//                `SH: mem[addr[31:1]][15:0] <= wData[15:0];
//                default: mem[addr[31:2]] <= wData; // SW
//            endcase
//        end 
//    end
//
//    assign rData = mem[addr[31:2]];
//endmodule
/////////////////////////////////////////////////////////////////////////