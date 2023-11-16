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
    output [3:0] ALUOp
    );


localparam R_type = 6'b000000, Ori = 6'b001101, Lw = 6'b100011, Sw = 6'b101011, 
				Beq = 6'b000100, Lui = 6'b001111, J = 6'b000010, Jal = 6'b000011;
				
localparam Add = 6'b100000, Sub = 6'b100010, Jr_ = 6'b001000, Sll = 6'b000000;


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
		ALUOp = (OP == R_type && Funct == Add) ? 4'b0000 :
				(OP == R_type && Funct == Sub) ? 4'b0001 :
				(OP == Ori) ? 4'b0011 :
				(OP == Lw) ? 4'b0000 :
				(OP == Sw) ? 4'b0000 :
				(OP == Beq) ? 4'b0000 :
				(OP == Lui) ? 4'b0110 :
				(OP == J) ? 4'b0000 :
				(OP == Jal) ? 4'b0000 :
				(OP == R_type && Funct == Jr_) ? 4'b0000 :
				(OP == R_type && Funct == Sll) ? 4'b0110 :
				4'b0000;

	

endmodule
