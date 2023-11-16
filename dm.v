`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:07:04 10/31/2023 
// Design Name: 
// Module Name:    dm 
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
module dm(
    input CLK,
    input Reset,
    input [11:0] Addr,
    input [31:0] WD,
    input WE,
	input [31:0] PC,
    output [31:0] RD
    );

	 reg [31:0] dm [0:3071];
integer i;
always@(posedge CLK) begin
	if (Reset) begin
		for(i=0;i<3072;i=i+1) begin
			dm[i] <= 32'b0;
		end
	end
	else if (WE) begin
		$display("%d@%h: *%h <= %h", $time, PC, {18'b0,Addr,2'b0}, WD);
		dm[Addr] = WD;
	end
end

assign RD = dm[Addr];

endmodule
