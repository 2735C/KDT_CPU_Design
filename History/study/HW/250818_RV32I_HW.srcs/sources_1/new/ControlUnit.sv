`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    input  logic [31:0] instrCode,
    output logic        regFileWe,
    output logic [ 3:0] aluControl,
    output logic        aluSrcMuxSel,
    output logic        busWe,
    output logic        RFWDSrcMuxSel
);
    wire  [6:0] opcode = instrCode[6:0];
    wire  [3:0] operator = {instrCode[30], instrCode[14:12]};
    logic [3:0] signals;
    assign {regFileWe, aluSrcMuxSel, busWe, RFWDSrcMuxSel} = signals;

    always_comb begin
        signals = 4'b0;
        case (opcode)
            //{regFileWe, aluSrcMuxSel, busWe, RFWDSrcMuxSel} = signals;
            `OP_TYPE_R: signals = 4'b1_0_0_0;
            `OP_TYPE_S: signals = 4'b0_1_1_0;
            `OP_TYPE_L: signals = 4'b1_1_0_1;
            `OP_TYPE_I: signals = 4'b1_1_0_0;
        endcase
    end

    always_comb begin
        aluControl = 4'bx;
        case (opcode)
            `OP_TYPE_R: aluControl = operator;
            `OP_TYPE_S: aluControl = `ADD;
            `OP_TYPE_L: aluControl = `ADD;
            `OP_TYPE_I: begin
                aluControl =  (operator[1:0] == 1) ?operator:{1'b0, operator[2:0]};
            end
        endcase
    end
endmodule


///////////////////////////////////////////////////
//always_comb begin
//    regFileWe = 1'b0;
//    aluSrcMuxSel = 1'b0;
//    case (opcode)
//         `OP_TYPE_R: begin
//             regFileWe = 1'b1; // R-type
//             aluSrcMuxSel = 1'b0;
//             busWe = 1'b0;
//         end
//         `OP_TYPE_S: begin
//             regFileWe = 1'b0; // S-type
//             aluSrcMuxSel = 1'b1;
//             busWe = 1'b1;
//         end
//    endcase
//end
//////////////////////////////////////////////////////

/////////////////////////////////////////////
//always_comb begin
//  aluControl = 4'bx;
//   case (operator)
//      4'b0000: aluControl = 4'b0000;  //add
//      4'b1000: aluControl = 4'b1000;  //sub 
//      4'b0001: aluControl = 4'b0001;  //sll 
//      4'b0101: aluControl = 4'b0101;  //srl 
//      4'b1101: aluControl = 4'b1101;  //sra 
//      4'b0010: aluControl = 4'b0010;  //slt
//      4'b0011: aluControl = 4'b0011;  //sltu
//      4'b0100: aluControl = 4'b0100;  //xor
//      4'b0110: aluControl = 4'b0110;  //or
//      4'b0111: aluControl = 4'b0111;  //and
//   endcase
//end
//////////////////////////////////////////////
