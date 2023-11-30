`timescale 1ns / 1ps
`define StartAddrDM 32'h0000_0000
`define EndAddrDM 32'h0000_2fff
`define StartAddrTC0 32'h0000_7f00
`define EndAddrTC0 32'h0000_7f0b
`define StartAddrTC1 32'h0000_7f10
`define EndAddrTC1 32'h0000_7f1b
`define StartAddrStall 32'h0000_7f20
`define EndAddrStall 32'h0000_7f23
module Bridge(
    input [31:0] Addr_in,
    input [31:0] WD_in,
    input [3:0] Byteen,
    input [31:0] DM_RD,
    input [31:0] T0_RD,
    input [31:0] T1_RD,
    output [31:0] Addr_out,
    output [31:0] WD_out,
    output [31:0] RD_out,
    output [3:0] DM_WE,
    output  T0_WE,
    output  T1_WE
	);
wire sel_TC0 = (Addr_in >= `StartAddrTC0) && (Addr_in <= `EndAddrTC0),
     sel_TC1 = (Addr_in >= `StartAddrTC1) && (Addr_in <= `EndAddrTC1),
     sel_DM = (Addr_in >= `StartAddrDM) && (Addr_in <= `EndAddrDM);

assign Addr_out = Addr_in;
assign WD_out = WD_in;
assign DM_WE = sel_DM ? Byteen : 0;
assign T0_WE = sel_TC0 ? &Byteen : 0;
assign T1_WE = sel_TC1 ? &Byteen : 0;
assign RD_out = sel_DM ? DM_RD :
                sel_TC0 ? T0_RD :
                sel_TC1 ? T1_RD :
                0;

endmodule