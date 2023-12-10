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
    input Allstall,
    input [4:0] ID_Rs,
    input [4:0] ID_Rt,
    input [4:0] EX_Rs,
    input [4:0] EX_Rt,
    input [4:0] EX_WA,
    input [4:0] MEM_WA,
    input [4:0] WB_WA,
    input EX_RegWrite,
    input MEM_RegWrite,
    input WB_RegWrite,
    input [3:0] Tuse_rs,
    input [3:0] Tuse_rt,
    input [3:0] EX_Tnew,
    input [3:0] MEM_Tnew,
    input [3:0] WB_Tnew,
    output npc_stall,
    output IF_stall,
    output ID_clr,
    output [1:0] FowardAE,
    output [1:0] FowardBE,
    output [1:0] FowardAD,
    output [1:0] FowardBD
    );
    assign npc_stall = ((((ID_Rs == EX_WA )&&(EX_Tnew > Tuse_rs ))|| ((ID_Rt == EX_WA)&&(EX_Tnew > Tuse_rt))) && EX_WA!=0 && EX_RegWrite)|| 
                       ((((ID_Rs == MEM_WA)&&(MEM_Tnew > Tuse_rs))|| ((ID_Rt == MEM_WA)&&(MEM_Tnew > Tuse_rt))) && MEM_WA!=0 && MEM_RegWrite) ||
                       Allstall;
    assign IF_stall = npc_stall;
    assign ID_clr = npc_stall;

    assign FowardAE =(MEM_RegWrite && (EX_Rs == MEM_WA) && MEM_WA!=0) ? 2'b10 :
                     (WB_RegWrite && (EX_Rs == WB_WA)&& WB_WA!=0) ? 2'b01 :
                     2'b00;
    assign FowardBE =(MEM_RegWrite && (EX_Rt == MEM_WA)&& MEM_WA!=0) ? 2'b10 :
                     (WB_RegWrite && (EX_Rt == WB_WA)&& WB_WA !=0) ? 2'b01 :
                     2'b00;
    assign FowardAD =(EX_RegWrite && (ID_Rs == EX_WA) && EX_WA!=0) ? 2'b11 : // && EX_Tnew > Tuse_rs
                     (MEM_RegWrite && (ID_Rs == MEM_WA)&& MEM_WA!=0) ? 2'b10 :
                     (WB_RegWrite && (ID_Rs == WB_WA) && WB_WA !=0) ? 2'b01 :
                     2'b00;
    assign FowardBD =(EX_RegWrite && (ID_Rt == EX_WA) && EX_WA!=0) ? 2'b11 : // && EX_Tnew > Tuse_rt
                     (MEM_RegWrite && (ID_Rt == MEM_WA)&& MEM_WA!=0) ? 2'b10 :
                     (WB_RegWrite && (ID_Rt == WB_WA)&& WB_WA !=0) ? 2'b01 :
                     2'b00;
endmodule
