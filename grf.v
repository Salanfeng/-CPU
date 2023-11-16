`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:01:15 10/31/2023 
// Design Name: 
// Module Name:    grf 
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
module grf(
    input CLK,
    input Reset,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD,
    input WE,
	 input  [31:0] PC,
    output [31:0] RD1,
    output [31:0] RD2
    );
	reg [31:0] rf [0:31];
	integer i;
assign RD1 = rf[A1];
assign RD2 = rf[A2];

initial begin
	for(i=0;i<32;i=i+1) begin
			rf[i] <= 32'b0;
	end
end
	always@(negedge CLK) begin
		if (Reset) begin
			for(i=0;i<32;i=i+1) begin
				rf[i] <= 32'b0;
			end
		end
		else begin
			if (WE && A3!=0) begin
				$display("%d@%h: $%d <= %h", $time, PC, A3, WD);
				rf[A3] <= WD;
			end
		end
	end
endmodule
