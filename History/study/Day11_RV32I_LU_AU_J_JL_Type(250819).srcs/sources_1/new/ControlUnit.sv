`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 3:0] aluControl,
    output logic        aluSrcMuxSel,
    output logic        busWe,
    output logic        RFWDSrcMuxSel,
    output logic        LUSrcMuxSel,
    output logic        AUSrcMuxSel,
    output logic        JSrcMuxSel,
    output logic        J_MUX,
    output logic        JLSrcMuxSel,
    output logic        branch
);
    wire  [6:0] opcode = instrCode[6:0];
    wire  [3:0] operator = {instrCode[30], instrCode[14:12]};
    logic [9:0] signals;
    assign {regFileWe, aluSrcMuxSel, busWe, RFWDSrcMuxSel, branch, LUSrcMuxSel, AUSrcMuxSel, JSrcMuxSel, J_MUX, JLSrcMuxSel} = signals;

    always_comb begin
        signals = 9'b0;
        case (opcode)
            //{regFileWe, aluSrcMuxSel, busWe, RFWDSrcMuxSel, branch, LUSrcMuxSel, AUSrcMuxSel, JSrcMuxSel, J_MUX, JLSrcMuxSel} = signals;
            `OP_TYPE_R: signals = 10'b1_0_0_0_0_0_0_0_1_0;
            `OP_TYPE_S: signals = 10'b0_1_1_0_0_0_0_0_1_0;
            `OP_TYPE_L: signals = 10'b1_1_0_1_0_0_0_0_1_0;
            `OP_TYPE_I: signals = 10'b1_1_0_0_0_0_0_0_1_0;
            `OP_TYPE_B: signals = 10'b0_0_0_0_1_0_1_0_1_0;

            `OP_TYPE_LU: signals = 10'b1_0_0_0_0_1_0_0_1_0;
            `OP_TYPE_AU: signals = 10'b1_0_0_0_0_1_1_0_1_0;
            `OP_TYPE_J:  signals = 10'b1_0_0_0_0_1_1_1_0_0;
            `OP_TYPE_JL: signals = 10'b1_0_0_0_0_1_1_1_0_1;
        endcase
    end

    always_comb begin
        aluControl = 4'bx;
        case (opcode)
            `OP_TYPE_R: aluControl = operator;
            `OP_TYPE_S: aluControl = `ADD;
            `OP_TYPE_L: aluControl = `ADD;
            `OP_TYPE_I: begin
                if (operator == 4'b1101) aluControl = operator;
                else aluControl = {1'b0, operator[2:0]};
                // aluControl = (operator == 4'b1101)? operator:  {1'b0, operator[2:0]};
            end
            `OP_TYPE_B: aluControl = operator;
            `OP_TYPE_LU: aluControl = `ADD;
            `OP_TYPE_AU: aluControl = `ADD;
            `OP_TYPE_J:  aluControl = `ADD;
            `OP_TYPE_JL: aluControl = `ADD;
        endcase
    end
endmodule
