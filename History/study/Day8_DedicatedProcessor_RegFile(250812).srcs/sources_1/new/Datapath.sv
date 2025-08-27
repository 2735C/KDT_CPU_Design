`timescale 1ns / 1ps

module Datapath (
    input  logic       clk,
    input  logic       rst,
    input  logic       RFSrcMuxSel,
    input  logic [2:0] RAddr1,
    input  logic [2:0] RAddr2,
    input  logic [2:0] WAddr,
    input  logic       we,
    input  logic       OutPortEn,
    output logic       R1Le10,
    output logic [7:0] OutPort
);

    logic [7:0] AddResult, RFSrcMuxOut;
    logic [7:0] RData1, RData2;

    mux_2x1 U_RFSrcMux (
        .sel(RFSrcMuxSel),
        .x0 (AddResult),
        .x1 (8'b1),
        .y  (RFSrcMuxOut)
    );

    RegFile U_RegFile (
        .clk   (clk),
        .RAddr1(RAddr1),
        .RAddr2(RAddr2),
        .WAddr (WAddr),
        .we    (we),
        .WData (RFSrcMuxOut),
        .RData1(RData1),
        .RData2(RData2)
    );

    Comparator U_R1Le10 (
        .a  (RData1),
        .b  (8'd10),
        .lte(R1Le10)
    );

    adder U_Adder (
        .a  (RData1),
        .b  (RData2),
        .sum(AddResult)
    );

    register U_OutPort (
        .clk(clk),
        .rst(rst),
        .en (OutPortEn),
        .d  (RData1),
        .q  (OutPort)
    );

endmodule


module RegFile (
    input  logic       clk,
    input  logic [2:0] RAddr1,
    input  logic [2:0] RAddr2,
    input  logic [2:0] WAddr,
    input  logic       we,
    input  logic [7:0] WData,
    output logic [7:0] RData1,
    output logic [7:0] RData2
);

    logic [7:0] mem[0:2**3 -1];  // 2^3 - 1 = 7

    always_ff @(posedge clk) begin
        if (we) begin
            mem[WAddr] <= WData;
        end
    end

    assign RData1 = (RAddr1 == 0) ? 8'b0 : mem[RAddr1];
    assign RData2 = (RAddr2 == 0) ? 8'b0 : mem[RAddr2];

endmodule


module register (
    input  logic       clk,
    input  logic       rst,
    input  logic       en,
    input  logic [7:0] d,
    output logic [7:0] q
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 0;
        end else begin
            if (en) begin
                q <= d;
            end
        end
    end

endmodule

module mux_2x1 (
    input  logic       sel,
    input  logic [7:0] x0,
    input  logic [7:0] x1,
    output logic [7:0] y
);

    always_comb begin
        y = 8'b0; //경우의 수가 다 있지만 습관을 만들기 위해 default값 추가
        case (sel)
            1'b0: y = x0;
            1'b1: y = x1;
        endcase

    end
endmodule

module adder (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] sum
);
    assign sum = a + b;
endmodule

module Comparator (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic       lte
);
    assign lte = a <= b;
endmodule
