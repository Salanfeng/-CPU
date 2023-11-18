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
    output [1:0] Branch,
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
wire store = OP == Sw || OP == Sh || OP == Sb;
wire load  = OP == Lw || OP == Lh || OP == Lb;
wire calc_R = OP == R_type && (Funct != Jr_) && (Funct != Sll);
wire calc_I = OP == Ori || OP == Lui || OP == Addi || OP == Andi;

assign 	RegDst = (OP == R_type),
		ALUSrc = (OP == Ori || OP == Lui || OP == Addi || OP == Andi || store || load),
		MemtoReg = load,
		RegWrite = (MDUOp==0||MDUOp==5||MDUOp==6)&&((OP == R_type) && (Funct != Jr_) || OP ==Jal || OP == Lui || load || calc_I),
		MemWrite = store,
		Branch = (OP == Beq) ? 1 :
				 (OP == Bne) ? 2 :
				 0,
		ExtOp = ( OP == Beq || OP == Bne || store || load),
		Jump = (OP == J || OP == Jal),
		Link = (OP == Jal),
		Jr = (OP == R_type) && (Funct == Jr_),
		ALUOp = (OP == R_type && (Funct == Add)||(OP == Addi))||store||load ? 5'b00000 :
				(OP == R_type && Funct == Sub) ? 5'b00001 :
				(OP == R_type && Funct == And)||(OP == Andi) ? 5'b00010 :
				(OP == R_type && Funct == Or)||(OP == Ori) ? 5'b00011  :
				(OP == R_type && Funct == Sll)||(OP == Lui) ? 5'b00110 :
				(OP == R_type && Funct == Slt) ? 5'b01001 :
				(OP == R_type && Funct == Sltu) ? 5'b01010 :
				5'b00000;
assign	LSOp =  (OP == Lb || OP == Sb) ? 1 :
				(OP == Lh || OP == Sh) ? 2 :
				(OP == Lw || OP == Sw) ? 3 :
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

assign Tuse_rs =calc_R ? 1: //calc_R
				calc_I ? 1: //calc_I
				(OP == R_type)&&(Funct == Sll)  ? TMax: //shift
				//(OP == Sllv) ? 1 :
				load ? 1: //load
				store ? 1: //store
				(OP == Beq || OP == Bne)? 0: //branch
				(OP == J)||(OP == Jal) ? TMax : //jump
				((OP == R_type) && (Funct == Jr_)) ? 0 : //jr
				TMax;
assign Tuse_rt =calc_R ? 1: //calc_R
				calc_I ? TMax: //calc_I
				(OP == R_type)&&(Funct == Sll) ? 1: //shift 				
				//(OP == Sllv) ? 1 :
				load ? TMax: //load
				store ? 1: //store
				(OP == Beq || OP == Bne)? 0: //branch
				(OP == J)||(OP == Jal) ? TMax : //jump
				((OP == R_type) &&( Funct == Jr_)) ? TMax : //jump
				TMax;
assign Tnew = 	calc_R? 2: //calc_R
				calc_I ? 2: //calc_I
				//(OP == Sllv) ? 2 :
				load ? 3: //load
				store ? TMin: //store
				(OP == Beq || OP == Bne)? TMin: //branch
				(OP == Jal)? 2 : //jal
				((OP == R_type) &&( Funct == Jr_)) ? TMin : //jr
				TMin;


endmodule
