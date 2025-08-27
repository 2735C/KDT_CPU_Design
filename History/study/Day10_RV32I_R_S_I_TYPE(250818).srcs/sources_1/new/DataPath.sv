`timescale 1ns / 1ps
`include "defines.sv"

// Single Cycle

module DataPath (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instrCode,
    input  logic        regFileWe,
    input  logic [ 3:0] aluControl,
    input  logic        aluSrcMuxSel,
    input  logic        RFWDSrcMuxSel,
    output logic [31:0] instrMemAddr,
    output logic [31:0] busAddr,
    output logic [31:0] busWdata,
    output logic [31:0] busRdata
);

    logic [31:0] aluResult, RFData1, RFData2;
    logic [31:0] PCSrcData, PCOutData;
    logic [31:0] aluSrcMuxOut, immExt, RFWDSrcMuxOut;

    assign instrMemAddr = PCOutData;
    assign busAddr = aluResult;
    assign busWdata = RFData2;

    RegisterFile U_RegFile (
        .clk(clk),
        .we (regFileWe),
        .RA1(instrCode[19:15]),
        .RA2(instrCode[24:20]),
        .WA (instrCode[11:7]),
        .WD (RFWDSrcMuxOut),     // 수정 
        .RD1(RFData1),
        .RD2(RFData2)
    );

    mux_2x1 U_AlySrcMux (
        .sel(aluSrcMuxSel),
        .x0 (RFData2),
        .x1 (immExt),
        .y  (aluSrcMuxOut)
    );

    mux_2x1 U_RFWDSrcMux (
        .sel(RFWDSrcMuxSel),
        .x0 (aluResult),
        .x1 (busRdata),
        .y  (RFWDSrcMuxOut)
    );

    alu U_ALU (
        .aluControl(aluControl),
        .a         (RFData1),
        .b         (aluSrcMuxOut),
        .result    (aluResult)
    );

    immExtend U_ImmExtend (

        .instrCode(instrCode),
        .immExt   (immExt)
    );

    register U_PC (  //program Counter
        .clk(clk),
        .rst(rst),
        .en (1'b1),
        .d  (PCSrcData),
        .q  (PCOutData)
    );

    adder U_PC_Adder (
        .a(32'd4),
        .b(PCOutData),
        .y(PCSrcData)
    );
endmodule

module alu (
    input  logic [ 3:0] aluControl,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);

    always_comb begin
        result = 32'bx;
        case (aluControl)
            `ADD:  result = a + b;
            `SUB:  result = a - b;
            `SLL:  result = a << b;
            `SRL:  result = a >> b;
            `SRA:  result = $signed(a) >>> b;
            `SLT:  result = ($signed(a) < $signed(b)) ? 1 : 0;
            `SLTU: result = (a < b) ? 1 : 0;
            `XOR:  result = a ^ b;
            `OR:   result = a | b;
            `AND:  result = a & b;
        endcase
    end
endmodule

module RegisterFile (
    input  logic        clk,
    input  logic        we,
    input  logic [ 4:0] RA1,
    input  logic [ 4:0] RA2,
    input  logic [ 4:0] WA,
    input  logic [31:0] WD,
    output logic [31:0] RD1,
    output logic [31:0] RD2
);

    logic [31:0] mem[0:2**5 -1];

    initial begin  //for simulation test
        for (int i = 0; i < 32; i++) begin
            mem[i] = 10 + i;
        end
    end

    always_ff @(posedge clk) begin
        if (we) mem[WA] <= WD;
    end

    assign RD1 = (RA1 != 0) ? mem[RA1] : 32'b0;
    assign RD2 = (RA2 != 0) ? mem[RA2] : 32'b0;
endmodule


//////////////////////////////////////////////////////
//module RegisterFile (
//    input  logic        clk,
//    input  logic        we,
//    input  logic [ 4:0] RA1,
//    input  logic [ 4:0] RA2,
//    input  logic [ 4:0] WA,
//    input  logic [31:0] WD,
//    output logic [31:0] RD1,
//    output logic [31:0] RD2
//);
//
//    logic [31:0] mem[0:2**5 -1];
//
//    always_ff @(posedge clk) begin
//        if (we) mem[WA] <= WD;
//    end
//
//    assign RD1 = (RA1 != 0) ? mem[RA1] : 32'b0;
//    assign RD2 = (RA2 != 0) ? mem[RA2] : 32'b0;
//endmodule
////////////////////////////////////////////////////////

module register (
    input logic clk,
    input logic rst,
    input logic en,
    input logic [31:0] d,
    output logic [31:0] q
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 0;
        end else begin
            if (en) q <= d;
        end
    end
endmodule


module adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);

    assign y = a + b;
endmodule

module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] x0,
    input  logic [31:0] x1,
    output logic [31:0] y
);

    always_comb begin
        y = 32'bx;
        case (sel)
            1'b0: y = x0;
            1'b1: y = x1;
        endcase
    end

endmodule

module immExtend (
    input  logic [31:0] instrCode,
    output logic [31:0] immExt
);
    wire [6:0] opcode = instrCode[6:0];

    always_comb begin
        immExt = 32'bx;
        case (opcode)
            `OP_TYPE_R: immExt = 32'bx;  // R-type
            `OP_TYPE_L:
            immExt = {{20{instrCode[31]}}, instrCode[31:20]};  // L-type 
            `OP_TYPE_I:
            immExt = {{20{instrCode[31]}}, instrCode[31:20]};  // I-type 
            `OP_TYPE_S:
            immExt = {
                {20{instrCode[31]}}, instrCode[31:25], instrCode[11:7]
            };  // S-type , 부호 비트 extend
        endcase
    end
endmodule
