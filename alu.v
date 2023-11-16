`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:00:19 10/31/2023 
// Design Name: 
// Module Name:    alu 
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
module alu(
    input [3:0] ALUOp,
    input [31:0] A,
    input [31:0] B,
    input [4:0] Shift,
    output [31:0] ALU_Result
    );
wire [31:0] s;
assign Equal = (A == B);
assign s = $signed(B) >>> Shift;
assign ALU_Result =  (ALUOp == 4'b0000) ? A + B :
							(ALUOp == 4'b0001) ? A - B :
							(ALUOp == 4'b0010) ? A & B :
							(ALUOp == 4'b0011) ? A | B :
							(ALUOp == 4'b0100) ? A * B :
							(ALUOp == 4'b0101) ? A / B :
							(ALUOp == 4'b0110) ? B << Shift :
							(ALUOp == 4'b0111) ? B >> Shift :
							(ALUOp == 4'b1000) ? s :
							(ALUOp == 4'b1001) ? {31'b0,($signed(A) > $signed(B))}:
							(ALUOp == 4'b1010) ? {31'b0,(A > B)}:
							(ALUOp == 4'b1011) ? result(A,B):
							A + B;

function [31:0] result;
	input [31:0] A;
	input [31:0] B;

	integer i;
	reg [31:0] cnt = 0;
	reg [31:0] R = 0;
	begin
		cnt = 0;
		R = 0;
		for(i = 0; i < 32; i = i + 1)
		begin
			if(B == cnt)
			begin
				i = 32;
			end
			else if(A[i]==0)
			begin
				R[i] = 1;
				cnt = cnt + 1;
			end
		end
		result = R|A;
	end
endfunction
endmodule
