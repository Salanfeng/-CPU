`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:58:45 10/31/2023 
// Design Name: 
// Module Name:    ifu 
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
module ifu(
    input CLK,
    input Reset,
    input  [31:0] PC,
	input npc_stall,
	input Req,
	input ID_eret,
	input [31:0] EPC,
	output IF_EXC_AdEL,
    output [31:0] Now_PC
	);
	reg [31:0] reg_PC;
	wire [31:0] addr;
    initial begin
		reg_PC = 32'h3000;
    end
	 
	always@(posedge CLK) begin
	if (Reset) begin
		reg_PC <= 32'h3000;
		end
	else if (ID_eret) begin
		reg_PC <= EPC;
	end
	else if (Req) begin
		reg_PC <= 32'h4180;
	end
	else if(!npc_stall)begin
		reg_PC <= PC;
	end
	end
	
	assign Now_PC = reg_PC;
	assign IF_EXC_AdEL = ((|Now_PC[1:0]) | (Now_PC < 32'h0000_3000) | (Now_PC > 32'h0000_6ffc)) && !ID_eret;

endmodule
