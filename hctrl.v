`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:31:31 11/09/2023 
// Design Name: 
// Module Name:    hctrl 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module hctrl(
    input [4:0] ID_Rs,
    input [4:0] ID_Rt,
    input [4:0] EX_Rs,
    input [4:0] EX_Rt,
    input [4:0] EX_WA,
    input [4:0] MEM_WA,
    input [4:0] WB_WA,
    input EX_MemtoReg,
    input MEM_MemtoReg,
    input EX_RegWrite,
    input MEM_RegWrite,
    input WB_RegWrite,
    output npc_stall,
    output IF_stall,
    output ID_clr,
    output [1:0] FowardAE,
    output [1:0] FowardBE,
    output [1:0] FowardAD,
    output [1:0] FowardBD
    );
    assign npc_stall = ((EX_MemtoReg) && (ID_Rs == EX_WA || ID_Rt == EX_WA) && EX_WA!=0)|| 
                       ((MEM_MemtoReg) && (ID_Rs == MEM_WA || ID_Rt == MEM_WA) && MEM_WA!=0);
    assign IF_stall = npc_stall;
    assign ID_clr = npc_stall;

    assign FowardAE = (MEM_RegWrite && (EX_Rs == MEM_WA) && MEM_WA!=0) ? 2'b10 :
                     (WB_RegWrite && (EX_Rs == WB_WA)&& WB_WA!=0) ? 2'b01 :
                     2'b00;
    assign FowardBE = (MEM_RegWrite && (EX_Rt == MEM_WA)&& MEM_WA!=0) ? 2'b10 :
                     (WB_RegWrite && (EX_Rt == WB_WA)&& WB_WA !=0) ? 2'b01 :
                     2'b00;
    assign FowardAD = (EX_RegWrite && (ID_Rs == EX_WA) && EX_WA!=0) ? 2'b11 :
                     (MEM_RegWrite && (ID_Rs == MEM_WA)&& MEM_WA!=0) ? 2'b10 :
                     (WB_RegWrite && (ID_Rs == WB_WA) && WB_WA !=0) ? 2'b01 :
                     2'b00;
    assign FowardBD = (EX_RegWrite && (ID_Rt == EX_WA) && EX_WA!=0) ? 2'b11 :
                     (MEM_RegWrite && (ID_Rt == MEM_WA)&& MEM_WA!=0) ? 2'b10 :
                     (WB_RegWrite && (ID_Rt == WB_WA)&& WB_WA !=0) ? 2'b01 :
                     2'b00;
endmodule
