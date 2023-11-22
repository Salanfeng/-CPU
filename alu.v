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
    input [4:0] ALUOp,
    input [31:0] A,
    input [31:0] B,
    input [4:0] Shift,
    output [31:0] ALU_Result
	);
wire [31:0] s;
reg [31:0] ALU_Others;
assign s = $signed(B) >>> Shift;
assign ALU_Result =  (ALUOp == 5'b00000) ? A + B :
							(ALUOp == 5'b00001) ? A - B :
							(ALUOp == 5'b00010) ? A & B :
							(ALUOp == 5'b00011) ? A | B :
							(ALUOp == 5'b00100) ? A * B :
							(ALUOp == 5'b00101) ? A / B :
							(ALUOp == 5'b00110) ? B << Shift :
							(ALUOp == 5'b00111) ? B >> Shift :
							(ALUOp == 5'b01000) ? s :
							(ALUOp == 5'b01001) ? {31'b0,($signed(A) < $signed(B))}:
							(ALUOp == 5'b01010) ? {31'b0,(A < B)}:
							ALU_Others;

reg [31:0] Cnt;
reg [31:0] Out;
integer  i;
always@(*) begin
	if (ALUOp == 5'b01100) begin
		//循环左移
		if(B[4:0] == 5'd0) ALU_Others = A;
		else ALU_Others = A << B[4:0] | A >> (5'd31 - B[4:0] + 5'd1);
	end
	else if (ALUOp == 5'b11111) begin
		Cnt = 0;
		Out = 0;
		for (i = 0;i<32;i=i+1) begin
			if (Cnt == B) begin
				Cnt = 0;
				i = 32;
			end
			else if (A[i] == 0) begin
				Cnt = Cnt + 1;
				Out [i] = 1;
			end
		end
		ALU_Others = Out | A;
	end
	else begin
		ALU_Others = A + B;
	end
end


endmodule
