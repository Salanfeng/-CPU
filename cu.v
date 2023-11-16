`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:57:28 10/31/2023 
// Design Name: 
// Module Name:    cu 
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
module cu(
    input [5:0] OP,
    input [5:0] Funct,
    output RegDst,
    output ALUSrc,
    output MemtoReg,
    output RegWrite,
    output MemWrite,
    output Branch,
    output ExtOp,
    output Jump,
    output Link,
    output Jr,
	output [3:0] Tuse_rs,
	output [3:0] Tuse_rt,
	output [3:0] Tnew,
    output [4:0] ALUOp
    );


localparam R_type = 6'b000000, Ori = 6'b001101, Lw = 6'b100011, Sw = 6'b101011, 
		   Beq = 6'b000100, Lui = 6'b001111, J = 6'b000010, Jal = 6'b000011;
				
localparam Add = 6'b100000, Sub = 6'b100010, Jr_ = 6'b001000, Sll = 6'b000000;//Funct


//AND Logic
assign 	RegDst = (OP == R_type) && (Funct == Add || Funct == Sub || Funct == Sll),
		ALUSrc = (OP == Ori || OP == Lui || OP == Lw || OP == Sw),
		MemtoReg = (OP == Lw),
		RegWrite = ((OP == R_type) && (Funct == Add || Funct == Sub || Funct == Sll) || OP == Ori || OP == Lui || OP ==Jal || OP == Lw),
		MemWrite = (OP == Sw),
		Branch = (OP == Beq),
		ExtOp = (OP == Lw || OP == Sw || OP == Beq),
		Jump = (OP == J || OP == Jal),
		Link = (OP == Jal),
		Jr = (OP == R_type) && (Funct == Jr_),
		ALUOp = (OP == R_type && Funct == Add) ? 5'b00000 :
				(OP == R_type && Funct == Sub) ? 5'b00001 :
				(OP == Ori) ? 5'b00011 :
				(OP == Lw) ? 5'b00000 :
				(OP == Sw) ? 5'b00000 :
				(OP == Beq) ? 5'b00000 :
				(OP == Lui) ? 5'b00110 :
				(OP == J) ? 5'b00000 :
				(OP == Jal) ? 5'b00000 :
				(OP == R_type && Funct == Jr_) ? 5'b00000 :
				(OP == R_type && Funct == Sll) ? 5'b00110 :
				5'b00000;
localparam TMax = 5'd15,TMin = 5'd0;

assign Tuse_rs =((OP == R_type)&& (Funct != Jr_) && (Funct != Sll)) ? 1: //calc_R
				(OP == Ori) || (OP == Lui) ? 1: //calc_I
				(OP == R_type)&&(Funct == Sll)  ? TMax: //shift  				
				//(OP == Sllv) ? 1 :
				(OP == Lw) ? 1: //load
				(OP == Sw) ? 1: //store
				(OP == Beq)? 0: //branch
				(OP == J)||(OP == Jal) ? TMax : //jump
				((OP == R_type) && (Funct == Jr_)) ? 0 : //jr
				TMax;
assign Tuse_rt =((OP == R_type)&& (Funct != Jr_) && (Funct != Sll)) ? 1: //calc_R
				(OP == Ori) || (OP == Lui) ? TMax: //calc_I
				(OP == R_type)&&(Funct == Sll) ? 1: //shift 				
				//(OP == Sllv) ? 1 :
				(OP == Lw) ? TMax: //load
				(OP == Sw) ? 1: //store
				(OP == Beq)? 0: //branch
				(OP == J)||(OP == Jal) ? TMax : //jump
				((OP == R_type) &&( Funct == Jr_)) ? TMax : //jump
				TMax;
assign Tnew = 	((OP == R_type)&& (Funct != Jr_) && (Funct != Sll)) ? 2: //calc_R
				(OP == Ori) || (OP == Lui) ? 2: //calc_I
				(OP == R_type)&&(Funct == Sll) ? 2: //shift
				//(OP == Sllv) ? 2 :
				(OP == Lw) ? 3: //load
				(OP == Sw) ? TMin: //store
				(OP == Beq)? TMin: //branch
				(OP == Jal)? 2 : //jal
				((OP == R_type) &&( Funct == Jr_)) ? TMin : //jr
				TMin;


endmodule
