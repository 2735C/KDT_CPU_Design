`timescale 1ns / 1ps


module DedicatedProcessor (
    input logic clk,
    input logic rst,
    output logic [7:0] OutPort
);

    logic SumSrcMuxSel;
    logic ISrcMuxSel;
    logic SumEn;
    logic IEn;
    logic ILe10;
    logic AdderSrcMuxSel;
    logic OutPortEn;


    Controlunit U_ControlUnit (.*);

    Datapath U_DataPath (.*);
endmodule
