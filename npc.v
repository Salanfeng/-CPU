`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:04:08 10/31/2023 
// Design Name: 
// Module Name:    npc 
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
module npc(
    input [31:0] PC,
    input [25:0] instr_addr,
    input [31:0] ra,
	input [31:0] B_PC,
	input [1:0] PCSrc,
    output [31:0] next_PC,
    output [31:0] PC_plus4
    );
reg [31:0] tmp_next_PC;

initial begin
	tmp_next_PC = 32'h00003000;
end

assign PC_plus4 = PC + 32'h4;
assign next_PC = tmp_next_PC;
always@(*) begin
	if (PCSrc == 1) begin //Branch
		tmp_next_PC = B_PC;
	end
	else if (PCSrc == 2) begin //Jump
		tmp_next_PC = {PC[31:28],instr_addr,2'b00};
	end
	else if (PCSrc == 3) begin //Jr
		tmp_next_PC = ra;
	end
	else begin
		tmp_next_PC = PC + 32'h4;
	end
end
	 
endmodule
