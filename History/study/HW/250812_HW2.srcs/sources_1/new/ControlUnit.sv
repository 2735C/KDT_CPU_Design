`timescale 1ns / 1ps

module ControlUnit (
    input  logic       clk,
    input  logic       rst,
    input  logic       R1Le10,
    output logic       RFSrcMuxSel,
    output logic [2:0] RAddr1,
    output logic [2:0] RAddr2,
    output logic [2:0] WAddr,
    output logic       we,
    output logic       OutPortEn,
    output logic [1:0] ALUop
);

    typedef enum {
        S0,
        S1,
        S2,
        S3,
        S4,
        S5,
        S6,
        S7,
        S8,
        S9,
        S10,
        S11,
        S12,
        S13
    } state_e;

    state_e state, next_state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S0;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state  = state;
        RFSrcMuxSel = 0;
        RAddr1      = 0;
        RAddr2      = 0;
        WAddr       = 0;
        we          = 0;
        OutPortEn   = 0;
        ALUop       = 0;
        case (state)
            S0: begin  //R1 = 1
                RFSrcMuxSel = 1;
                RAddr1      = 0;
                RAddr2      = 0;
                WAddr       = 1;
                we          = 1;
                OutPortEn   = 0;
                ALUop       = 0;
                next_state  = S1;
            end
            S1: begin  //R2 = 0
                RFSrcMuxSel = 0;
                RAddr1      = 0;
                RAddr2      = 0;
                WAddr       = 2;
                we          = 1;
                OutPortEn   = 0;
                ALUop       = 0;
                next_state  = S2;
            end
            S2: begin  //R3 = 0
                RFSrcMuxSel = 0;
                RAddr1      = 0;
                RAddr2      = 0;
                WAddr       = 3;
                we          = 1;
                OutPortEn   = 0;
                ALUop       = 0;
                next_state  = S3;
            end
            S3: begin  // R4 = 0
                RFSrcMuxSel = 0;
                RAddr1      = 0;
                RAddr2      = 0;
                WAddr       = 4;
                we          = 1;
                OutPortEn   = 0;
                ALUop       = 0;
                next_state = S4;
            end
            S4: begin  // R2 = R1 + R1
                RFSrcMuxSel = 0;
                RAddr1      = 1;
                RAddr2      = 1;
                WAddr       = 2;
                we          = 1;
                OutPortEn   = 0;
                ALUop       = 0;
                next_state  = S5;
            end
            S5: begin  // R3 = R2 + R1
                RFSrcMuxSel = 0;
                RAddr1      = 1;
                RAddr2      = 2;
                WAddr       = 3;
                we          = 1;
                OutPortEn   = 0;
                ALUop       = 0;
                next_state  = S6;
            end
            S6: begin  // R4 = R3 - R1
                RFSrcMuxSel = 0;
                RAddr1      = 3;
                RAddr2      = 1;
                WAddr       = 4;
                we          = 1;
                OutPortEn   = 0;
                ALUop       = 1;
                next_state  = S7;
            end
            S7: begin  // R1 = R1 or R2	
                RFSrcMuxSel = 0;
                RAddr1      = 1;
                RAddr2      = 2;
                WAddr       = 1;
                we          = 1;
                OutPortEn   = 0;
                ALUop       = 3;
                next_state  = S8;
            end
            S8: begin  // R4 <R2	
                RFSrcMuxSel = 0;
                RAddr1      = 4;
                RAddr2      = 2;
                WAddr       = 0;
                we          = 0;
                OutPortEn   = 0;
                ALUop       = 0;
                if (R1Le10) next_state = S6;
                else next_state = S9;
            end
            S9: begin  // R4 = R4 & R3	
                RFSrcMuxSel = 0;
                RAddr1      = 3;
                RAddr2      = 4;
                WAddr       = 4;
                we          = 1;
                OutPortEn   = 0;
                ALUop       = 2;
                next_state  = S10;
            end
            S10: begin  // R4 = R2 + R3	
                RFSrcMuxSel = 0;
                RAddr1      = 2;
                RAddr2      = 3;
                WAddr       = 4;
                we          = 1;
                OutPortEn   = 0;
                ALUop       = 0;
                next_state  = S11;
            end
            S11: begin  // R4 > R2	
                RFSrcMuxSel = 0;
                RAddr1      = 2;
                RAddr2      = 4;
                WAddr       = 0;
                we          = 0;
                OutPortEn   = 0;
                ALUop       = 0;
                if (R1Le10) next_state = S4;
                else next_state = S12;
            end
            S12: begin  // OutPort = R1
                RFSrcMuxSel = 0;
                RAddr1      = 1;
                RAddr2      = 0;
                WAddr       = 0;
                we          = 0;
                OutPortEn   = 1;
                ALUop       = 0;
                next_state  = S13;
            end
            S13: begin  // Halt
                RFSrcMuxSel = 0;
                RAddr1      = 0;
                RAddr2      = 0;
                WAddr       = 0;
                we          = 0;
                OutPortEn   = 0;
                ALUop       = 0;
                next_state  = S13;
            end
        endcase

    end
endmodule