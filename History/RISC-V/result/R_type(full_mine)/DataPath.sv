`timescale 1ns / 1ps

// Single Cycle

module DataPath (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instrCode,
    input  logic        regFileWe,
    input  logic [ 3:0] aluControl,
    output logic [31:0] instrMemAddr
);

    logic [31:0] aluResult, RFData1, RFData2;
    logic [31:0] PCSrcData, PCOutData;

    assign instrMemAddr = PCOutData;

    RegisterFile U_RegFile (
        .clk(clk),
        .we (regFileWe),
        .RA1(instrCode[19:15]),
        .RA2(instrCode[24:20]),
        .WA (instrCode[11:7]),
        .WD (aluResult),
        .RD1(RFData1),
        .RD2(RFData2)
    );

    alu U_ALU (
        .aluControl(aluControl),
        .a         (RFData1),
        .b         (RFData2),
        .result    (aluResult)
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

    // signed로 해석할 변수
    logic signed [31:0] signed_a, signed_b;

    always_comb begin
        signed_a = $signed(a);
        signed_b = $signed(b);
        result = 32'bx;
        case (aluControl)
            4'd0: result = a + b;
            4'd1: result = a - b;
            4'd2: result = a & b;
            4'd3: result = a | b;

            4'd4: result = a << b[4:0]; //SLL: Shift Left Logical << 0 붙음
            4'd5: result = a >> b[4:0]; //SRL: Shift Right Logical >> 0 붙음
            4'd6: result = signed_a >>> b[4:0]; //SRA: Shift Rigjt Arith* >>> 자료형에에 따라 부호비트
            4'd7: result = (signed_a < signed_b) ? 32'b1 : 32'b0; //SLT: Set Less Than  ? : 2's Complement
            4'd8: result = (a < b) ? 32'b1 : 32'b0; //SLTU: Set Less Than (U) ? : 그냥 크기 비교
            4'd9: result = a ^ b; //XOR 
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
        for (int i = 0; i <32; i++) begin
            mem[i] = 10+ i;
            //mem[i] = -20+ i;
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
