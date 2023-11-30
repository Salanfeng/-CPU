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
	input [4:0] Rs,
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
	output [3:0] MDUOp,
	output ID_EXC_RI,
	output [2:0] CP0_Op,
	output Sys
    );


wire  	R_type = (OP == 6'b000000), Ori = (OP == 6'b001101), Lw = (OP == 6'b100011), Sw = (OP == 6'b101011), 
		Beq = (OP == 6'b000100), Lui = (OP == 6'b001111), J = (OP == 6'b000010), Jal = (OP == 6'b000011),
		Addi = (OP == 6'b001000), Andi = (OP == 6'b001100), Lb = (OP == 6'b100000), Sb = (OP == 6'b101000),
		Lh = (OP == 6'b100001), Sh = (OP == 6'b101001), Bne = (OP == 6'b000101), Addiu = (OP == 6'b001001),
		COP0 = (OP == 6'b010000);

wire	Add = (R_type && Funct == 6'b100000), Sub = (R_type && Funct == 6'b100010), Jr_ = (R_type && Funct == 6'b001000), Sll = (R_type && Funct == 6'b000000),//Funct
		And = (R_type && Funct == 6'b100100), Or = (R_type && Funct == 6'b100101), Slt = (R_type && Funct == 6'b101010), Sltu = (R_type && Funct == 6'b101011),
		Mult = (R_type && Funct == 6'b011000), Multu = (R_type && Funct == 6'b011001), Div = (R_type && Funct == 6'b011010), Divu = (R_type && Funct == 6'b011011),
		Mfhi = (R_type && Funct == 6'b010000), Mflo = (R_type && Funct == 6'b010010), Mthi = (R_type && Funct == 6'b010001), Mtlo = (R_type && Funct == 6'b010011),
		Syscall = (R_type && Funct == 001100);

wire 	Mfc0 = (COP0 && Rs == 5'b00000), Mtc0 = (COP0 && Rs == 5'b00100), Eret = (COP0 && Funct == 6'b011000);
assign	CP0_Op =Eret ? 1 :
				Mfc0 ? 2 :
				Mtc0 ? 3 :
				0;
assign Sys = Syscall;
wire store = Sw || Sh || Sb;
wire load  = Lw || Lh || Lb;
wire calc_R = R_type && (!Jr_) && (!Sll);
wire calc_I = Ori || Lui || Addi || Andi || Addiu;

assign 	RegDst = (R_type),
		ALUSrc = (Ori || Lui || Addi ||Addiu|| Andi || store || load),
		MemtoReg = load,
		RegWrite = (MDUOp==0||MDUOp==5||MDUOp==6)&&((R_type) && (!Jr_) || Jal || load || calc_I || Mfc0),
		MemWrite = store,
		Branch = (Beq) ? 1 :
				 (Bne) ? 2 :
				 0,
		ExtOp = ( Beq || Bne || store || load || Addi||Addiu),
		Jump = (J || Jal),
		Link = (Jal),
		Jr = (R_type) && (Jr_),
		ALUOp = (Add||Addi||Addiu)||store||load || Link ? 5'b00000 :
				(Sub) ? 5'b00001 :
				(And)||(Andi) ? 5'b00010 :
				(Or)||(Ori) ? 5'b00011  :
				(Sll)||(Lui) ? 5'b00110 :
				(Slt) ? 5'b01001 :
				(Sltu) ? 5'b01010 :
				5'b11111;
assign	LSOp =  (Lb || Sb) ? 1 :
				(Lh || Sh) ? 2 :
				(Lw || Sw) ? 3 :
				0;
assign  MDUOp = (Mult) ? 1 :
				(Multu) ? 2 :
				(Div) ? 3 :
				(Divu) ? 4 :
				(Mfhi) ? 5 :
				(Mflo) ? 6 :
				(Mthi) ? 7 :
				(Mtlo) ? 8 :
				0;
assign Start = MDUOp > 0;

localparam TMax = 5'd15,TMin = 5'd0;

assign Tuse_rs =calc_R ? 1: //calc_R
				calc_I ? 1: //calc_I
				(R_type)&&(Sll)  ? TMax: //shift
				//(Sllv) ? 1 :
				load ? 1: //load
				store ? 1: //store
				(Beq || Bne)? 0: //branch
				(J)||(Jal) ? TMax : //jump
				((Jr_)) ? 0 : //jr
				TMax;
assign Tuse_rt =calc_R ? 1: //calc_R
				calc_I ? TMax: //calc_I
				Sll ? 1: //shift 				
				//(Sllv) ? 1 :
				load ? TMax: //load
				store ? 1: //store
				(Beq || Bne)? 0: //branch
				(J)||(Jal) ? TMax : //jump
				Jr_ ? TMax : //jump
				TMax;
assign Tnew = 	calc_R? 2: //calc_R
				calc_I ? 2: //calc_I
				//(Sllv) ? 2 :
				load ? 3: //load
				store ? TMin: //store
				(Beq || Bne)? TMin: //branch
				(Jal)? 2 : //jal
				Jr_ ? TMin : //jr
				TMin;


assign ID_EXC_RI = ! (Ori || Lw || Sw || Beq || Lui || J || Jal || Addi || Andi || Lb || Sb || Lh || Sh || Bne || Addiu ||
					Add || Sub || Jr_ || Sll || And || Or || Slt || Sltu || Mult || Multu || Div || Divu || Mfhi || Mflo 
					|| Mthi || Mtlo);


endmodule
