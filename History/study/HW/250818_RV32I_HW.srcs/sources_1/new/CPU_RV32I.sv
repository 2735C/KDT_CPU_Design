`timescale 1ns / 1ps


module CPU_RV32I (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instrCode,
    output logic [31:0] instrMemAddr,
    output logic        busWe,
    output logic [31:0] busAddr,
    output logic [31:0] busWdata,
    output logic [31:0] busRdata
);

    logic       regFileWe;
    logic [3:0] aluControl;
    logic       aluSrcMuxSel;
    logic       RFWDSrcMuxSel;

    ControlUnit U_ControlUnit (.*);
    DataPath U_DataPath (.*);
endmodule
