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
	output Start,
	output [3:0] Tuse_rs,
	output [3:0] Tuse_rt,
	output [3:0] Tnew,
    output [4:0] ALUOp,
	output [1:0] LSOp,
	output [3:0] MDUOp
    );


localparam  R_type = 6'b000000, Ori = 6'b001101, Lw = 6'b100011, Sw = 6'b101011, 
		    Beq = 6'b000100, Lui = 6'b001111, J = 6'b000010, Jal = 6'b000011,
			Addi = 6'b001000, Andi = 6'b001100, Lb = 6'b100000, Sb = 6'b101000,
			Lh = 6'b100001, Sh = 6'b101001, Bne = 6'b000101;
				
localparam  Add = 6'b100000, Sub = 6'b100010, Jr_ = 6'b001000, Sll = 6'b000000,//Funct
			And = 6'b100100, Or = 6'b100101, Slt = 6'b101010, Sltu = 6'b101011,
			Mult = 6'b011000, Multu = 6'b011001, Div = 6'b011010, Divu = 6'b011011,
			Mfhi = 6'b010000, Mflo = 6'b010010, Mthi = 6'b010001, Mtlo = 6'b010011;

//AND Logic
assign 	RegDst = (OP == R_type),
		ALUSrc = (OP == Ori || OP == Lui || OP == Lw || OP == Sw),
		MemtoReg = (OP == Lw),
		RegWrite = ((OP == R_type) && (Funct != Jr_) || OP == Ori || OP == Lui || OP ==Jal || OP == Lw),
		MemWrite = (OP == Sw),
		Branch = (OP == Beq),
		ExtOp = (OP == Lw || OP == Sw || OP == Beq),
		Jump = (OP == J || OP == Jal),
		Link = (OP == Jal),
		Jr = (OP == R_type) && (Funct == Jr_),
		ALUOp = (OP == R_type && (Funct == Add)||(Funct == Addi))||(OP == Lw)||(OP == Sw) ? 5'b00000 :
				(OP == R_type && Funct == Sub) ? 5'b00001 :
				(OP == R_type && Funct == And) ? 5'b00010 :
				(OP == R_type && Funct == Or) ? 5'b00011  :
				(OP == Ori) ? 5'b00011 :
				(OP == Lui) ? 5'b00110 :
				(OP == R_type && Funct == Sll) ? 5'b00110 :
				5'b00000;
assign	LSOp =  (OP == Lh || OP == Sh) ? 1 :
				(OP == Lb || OP == Sb) ? 2 :
				0;
assign  MDUOp = (OP == R_type && Funct == Mult) ? 1 :
				(OP == R_type && Funct == Multu) ? 2 :
				(OP == R_type && Funct == Div) ? 3 :
				(OP == R_type && Funct == Divu) ? 4 :
				(OP == R_type && Funct == Mfhi) ? 5 :
				(OP == R_type && Funct == Mflo) ? 6 :
				(OP == R_type && Funct == Mthi) ? 7 :
				(OP == R_type && Funct == Mtlo) ? 8 :
				0;
assign Start = MDUOp > 0;

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
assign Tnew = 	((OP == R_type)&& (Funct != Jr_))? 2: //calc_R
				(OP == Ori) || (OP == Lui) ? 2: //calc_I
				//(OP == Sllv) ? 2 :
				(OP == Lw) ? 3: //load
				(OP == Sw) ? TMin: //store
				(OP == Beq)? TMin: //branch
				(OP == Jal)? 2 : //jal
				((OP == R_type) &&( Funct == Jr_)) ? TMin : //jr
				TMin;


endmodule
