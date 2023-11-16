`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:44:55 10/31/2023 
// Design Name: 
// Module Name:    mips 
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
	module mips(
		 input clk,
		 input reset
	);
	

	
	initial begin
	end
//declare
		//ifu
		wire [31:0] PC;
		wire [31:0] Instr;
		
		//spliter
		wire [5:0] OP, Funct;
		wire [4:0] Rs, Rt, Rd, Shamt;
		wire [15:0] Imm16;
		wire [25:0] InstrAddr;

		//ext
		wire [31:0] offset;

		//npc
		wire [31:0] B_PC;
		wire [31:0] next_PC , PC_plus4;
		wire [1 :0] PCSrc;

		//cu
		wire [3:0] Tuse_rs,Tuse_rt,Tnew;

		wire RegDst;
		wire ALUSrc;
		wire MemtoReg;
		wire RegWrite;
		wire MemWrite;
		wire Branch;
		wire ExtOp;
		wire Jump;
		wire Link;
		wire Jr;
		wire [4:0] ALUOp;

		//grf
		wire [31:0] NumA;
		wire [31:0] NumB;
		wire RW;
		wire [31:0] GRF_PC;
		wire [31:0] RD1;

		//alu
		wire [31:0] A;
		wire [31:0] B;
		wire [31:0] Bt;
		wire [4:0] Shift;
		wire Equal;
		wire [31:0] ALU_Result;

		reg [3:0] busy;



		//dm
		wire [31:0] MemData;
		wire [31:0] MemOut;
		//mem 
		reg [31:0] MEM_ALU_Result;

		//grf_wb
		wire [4:0] A3;
		wire [31:0] RegData;


		//Hazard Control
		wire [1:0] FowardAE;
		wire [1:0] FowardBE;
		wire [1:0] FowardAD;
		wire [1:0] FowardBD;
		wire IF_stall;
		wire IF_fluse;
		wire npc_stall;
		wire ID_clr;
		wire [4:0] EX_WA;


//module
//////////////Fetch (IF)//////////////////

		ifu _ifu(
			.CLK(clk),
			.Reset(reset),
			.PC(next_PC),
			.npc_stall(npc_stall),
			.Now_PC(PC),
			.Instr(Instr)
			);

		npc _npc(
			.PC(PC), 
			.instr_addr(InstrAddr), 
			.ra(RD1), 
			.B_PC(B_PC),
			.PCSrc(PCSrc),
			.next_PC(next_PC), 
			.PC_plus4(PC_plus4)
			);


//////////////////////////////////////////
//				IF|ID
reg [31:0] ID_PC;
reg [31:0] ID_Instr;

always @(posedge clk) begin
if (reset) begin
	ID_PC <= 32'h00003000;
	ID_Instr <= 32'h00000000;
end
else if(!IF_stall)begin
	if (IF_fluse) begin
		ID_Instr <= 32'h00000000;
	end
	else begin
	ID_PC <= PC;
	ID_Instr <= Instr;
	end
end
end

//////////////Decode (ID)/////////////////

assign 	OP = ID_Instr[31:26], Funct = ID_Instr[5:0],
		Rs = ID_Instr[25:21], Rt = ID_Instr[20:16], Rd = ID_Instr[15:11],
		Shamt = ID_Instr[10:6], Imm16 = ID_Instr[15:0], InstrAddr = ID_Instr[25:0];

		cu _cu(
			.OP(OP), 
			.Funct(Funct), 
			.RegDst(RegDst), 
			.ALUSrc(ALUSrc),
			.MemtoReg(MemtoReg),
			.RegWrite(RegWrite),
			.MemWrite(MemWrite),
			.Branch(Branch),
			.ExtOp(ExtOp),
			.Jump(Jump),
			.Link(Link),
			.Jr(Jr),
			.Tuse_rs(Tuse_rs),
			.Tuse_rt(Tuse_rt),
			.Tnew(Tnew),
			.ALUOp(ALUOp)
			);


		grf _grf(
			.CLK(clk), 
			.Reset(reset), 
			.A1(Rs), 
			.A2(Rt),
			.A3(A3),
			.WD(RegData), 
			.WE(RW), 
			.PC(GRF_PC),
			.RD1(NumA), 
			.RD2(NumB)
			);
			
assign offset = ExtOp ? {{16{Imm16[15]}},Imm16} : {16'b0, Imm16};
assign B_PC = ID_PC + 4 + (offset << 2);
assign  RD1 	=   FowardAD == 2'b10 ? MEM_ALU_Result :
					FowardAD == 2'b01 ? RegData :
					NumA;
wire [31:0] RD2 =   FowardBD == 2'b10 ? MEM_ALU_Result :
					FowardBD == 2'b01 ? RegData :
					NumB;
/////CMP/////
assign PCSrc = ((RD1 == RD2) && Branch) ? 1 : //Branch
				Jump ? 2 :
				Jr ? 3 :
				0;

assign IF_fluse = 0;
//////////////////////////////////////////
//				ID|EX
reg [31:0] EX_PC;
reg [31:0] EX_RD1;
reg [31:0] EX_RD2;
reg [31:0] EX_offset;
reg [4:0] EX_Rs;
reg [4:0] EX_Rt;
reg [4:0] EX_Rd;
reg [4:0] EX_Shamt;

reg EX_ALUSrc;
reg EX_MemtoReg;
reg EX_RegWrite;
reg EX_RegDst;
reg EX_MemWrite;
reg EX_Branch;
reg EX_Jump;
reg EX_Link;
reg EX_Jr;
reg [3:0] EX_Tnew;
reg [4:0] EX_ALUOp;
always @(posedge clk) begin
if (reset || ID_clr) begin
	EX_PC <= 32'h00003000;
	EX_RD1 <= 32'h00000000;
	EX_RD2 <= 32'h00000000;
	EX_offset <= 32'h00000000;
	EX_Shamt <= 5'h00;

	EX_Rs <= 5'h00;
	EX_Rt <= 5'h00;
	EX_Rd <= 5'h00;
	EX_ALUSrc <= 0;
	EX_MemtoReg <= 0;
	EX_RegWrite <= 0;
	EX_RegDst <= 0;
	EX_MemWrite <= 0;
	EX_Branch <= 0;
	EX_Jump <= 0;
	EX_Link <= 0;
	EX_Jr <= 0;
	EX_Tnew <= 0;
	EX_ALUOp <= 0;
end
else begin
	EX_PC <= ID_PC;
	EX_RD1 <= RD1;
	EX_RD2 <= RD2;
	EX_offset <= offset;
	EX_Shamt <= Shamt;
	EX_Rs <= Rs;
	EX_Rt <= Rt;
	EX_Rd <= Rd;
	
	EX_ALUSrc <= ALUSrc;
	EX_MemtoReg <= MemtoReg;
	EX_RegWrite <= RegWrite;
	EX_RegDst <= RegDst;
	EX_MemWrite <= MemWrite;
	EX_Branch <= Branch;
	EX_Jump <= Jump;
	EX_Link <= Link;
	EX_Jr <= Jr;
	EX_Tnew <= Tnew > 0 ? Tnew - 1 : 0;
	EX_ALUOp <= ALUOp;
end
end

//////////////Execute (EX)////////////////

//RegData,MEM_ALU_Result
assign  A = FowardAE == 2'b10 ? MEM_ALU_Result :
			FowardAE == 2'b01 ? RegData :
			EX_Link ? EX_PC :
			EX_RD1;
assign  Bt =FowardBE == 2'b10 ? MEM_ALU_Result :
			FowardBE == 2'b01 ? RegData :
			EX_Link ? 8 :
			EX_RD2;
assign  B = EX_ALUSrc ? EX_offset : Bt;
assign 	Shift = EX_ALUSrc ? 5'h10 : EX_Shamt;

		alu _alu(
			.ALUOp(EX_ALUOp), 
			.A(A),
			.B(B),
			.Shift(Shift),
			.ALU_Result(ALU_Result)
			);

//////////div&mult////////////
reg [31:0] HI,LO;
always@(posedge clk) begin
	if (EX_ALUOp == 0)
	{HI, LO} <= $signed({HI, LO}) + $signed(A) * $signed(B);
end

assign EX_WA = 	EX_Link ? 5'h1f : 
				EX_RegDst ? EX_Rd:
				EX_Rt;

//////////////////////////////////////////
//				EX|MEM
reg [31:0] MEM_PC;
//reg [31:0] MEM_ALU_Result;
reg [31:0] MEM_WD;
reg [4:0] MEM_WA;

reg MEM_MemtoReg;
reg MEM_RegWrite;
reg MEM_MemWrite;
reg MEM_Jump;
reg MEM_Link;
reg MEM_Jr;
reg [3:0] MEM_Tnew;
always @(posedge clk) begin
if (reset) begin
	MEM_PC <= 32'h00003000;
	MEM_ALU_Result <= 32'h00000000;
	MEM_WD <= 32'h00000000;
	MEM_WA <= 5'h00;

	MEM_MemtoReg <= 1'b0;
	MEM_RegWrite <= 1'b0;
	MEM_MemWrite <= 1'b0;
	MEM_Jump <= 1'b0;
	MEM_Link <= 1'b0;
	MEM_Jr <= 1'b0;
	MEM_Tnew <= 0;
end
else begin
	MEM_PC <= EX_PC;
	MEM_ALU_Result <= ALU_Result;
	MEM_WD <= Bt;
	MEM_WA <= EX_WA;

	MEM_MemtoReg <= EX_MemtoReg;
	MEM_RegWrite <= EX_RegWrite;
	MEM_MemWrite <= EX_MemWrite;
	MEM_Jump <= EX_Jump;
	MEM_Link <= EX_Link;
	MEM_Jr <= EX_Jr;
	MEM_Tnew <= EX_Tnew > 0 ? EX_Tnew - 1 : 0;
end
end

//////////////Memory (MEM)////////////////



assign MemData = MEM_WD;

		dm _dm(
			.CLK(clk), 
			.Reset(reset), 
			.Addr(MEM_ALU_Result[13:2]), 
			.WD(MemData),
			.WE(MEM_MemWrite), 
			.RD(MemOut), 
			.PC(MEM_PC)
		);

//////////////////////////////////////////
//				MEM|WB
reg [31:0] WB_PC;
reg [31:0] WB_MemOut;
reg [31:0] WB_ALU_Result;
reg [4:0] WB_WA;

reg WB_MemtoReg;
reg WB_RegWrite;
reg WB_Link;
reg [3:0] WB_Tnew;
always @(posedge clk) begin
if (reset) begin
	WB_PC <= 32'h00003000;
	WB_MemOut <= 32'h00000000;
	WB_ALU_Result <= 32'h00000000;
	WB_WA <= 5'h00;

	WB_MemtoReg <= 1'b0;
	WB_RegWrite <= 1'b0;
	WB_Link <= 1'b0;
	WB_Tnew <= 0;
end
else begin
	WB_PC <= MEM_PC;
	WB_MemOut <= MemOut;
	WB_ALU_Result <= MEM_ALU_Result;
	WB_WA <= MEM_WA;

	WB_MemtoReg <= MEM_MemtoReg;
	WB_RegWrite <= MEM_RegWrite;
	WB_Link <= MEM_Link;
	WB_Tnew <= MEM_Tnew > 0 ? MEM_Tnew - 1 : 0;
end
end

//////////////Writeback (WB)//////////////

assign RegData =WB_MemtoReg? WB_MemOut:
				WB_ALU_Result;
assign A3 = WB_WA;
assign RW = WB_RegWrite;
assign GRF_PC = WB_PC;

//////////////////////////////////////////
//Hazard Control

hctrl _hctrl(
	.ID_Rs(Rs),
	.ID_Rt(Rt),
	.EX_Rs(EX_Rs),
	.EX_Rt(EX_Rt),
	.EX_WA(EX_WA),
	.MEM_WA(MEM_WA),
	.WB_WA(WB_WA),
	.EX_MemtoReg(EX_MemtoReg),
	.MEM_MemtoReg(MEM_MemtoReg),
	.EX_RegWrite(EX_RegWrite),
	.MEM_RegWrite(MEM_RegWrite),
	.WB_RegWrite(WB_RegWrite),
	.Tuse_rs(Tuse_rs),
	.Tuse_rt(Tuse_rt),
	.EX_Tnew(EX_Tnew),
	.MEM_Tnew(MEM_Tnew),
	.WB_Tnew(WB_Tnew),
	.npc_stall(npc_stall),
	.IF_stall(IF_stall),
	.ID_clr(ID_clr),
	.FowardAE(FowardAE),
	.FowardBE(FowardBE),
	.FowardAD(FowardAD),
	.FowardBD(FowardBD)
	);


endmodule
