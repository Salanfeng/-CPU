`define StartAddrDM 32'h0000_0000
`define EndAddrDM 32'h0000_2fff
`define StartAddrTC0 32'h0000_7f00
`define EndAddrTC0 32'h0000_7f0b
`define StartAddrTC1 32'h0000_7f10
`define EndAddrTC1 32'h0000_7f1b
`define StartAddrStall 32'h0000_7f20
`define EndAddrStall 32'h0000_7f23


module savebyte(
    input Req,
    input [31:0] addr,
    input [1:0] LSOp,
    input [31:0] WD_in,
    input MemtoReg,
    output [3:0] byteen,
    output [31:0] WD_out,
	output MEM_EXC_AdES
    );
reg [3:0] byteen_t;
reg [31:0] WD_out_t;
assign byteen = MEM_EXC_AdES === 1 ? 0 :
                Req ? 0 :
                byteen_t;
assign WD_out = WD_out_t;
always@(*) begin
    if (LSOp == 2'b11 && !MemtoReg) begin
        byteen_t = 4'b1111;
        WD_out_t = WD_in;
    end
    else if (LSOp == 2'b10 && !MemtoReg) begin
        if (addr[1] == 0) begin
            byteen_t = 4'b0011;
            WD_out_t = {16'b0,WD_in[15:0]};
        end
        else begin
            byteen_t = 4'b1100;
            WD_out_t = {WD_in[15:0],16'b0};
        end
    end
    else if (LSOp == 2'b01 && !MemtoReg) begin
        if (addr[1:0] == 0) begin
            byteen_t = 4'b0001;
            WD_out_t = {24'b0,WD_in[7:0]};
        end
        else if (addr[1:0] == 1) begin
            byteen_t = 4'b0010;
            WD_out_t = {16'b0,WD_in[7:0],8'b0};
        end
        else if (addr[1:0] == 2) begin
            byteen_t = 4'b0100;
            WD_out_t = {8'b0,WD_in[7:0],16'b0};
        end
        else begin
            byteen_t = 4'b1000;
            WD_out_t = {WD_in[7:0],24'b0};
        end
    end
    else begin
        byteen_t = 4'b0000;
        WD_out_t = 32'b0;
    end
end

//EXC

wire ErrAlign = ((LSOp == 3) && (|addr[1:0])) ||
                    ((LSOp == 2) && (addr[0]));
    
wire ErrOutOfRange = !(((addr >= `StartAddrDM) && (addr <= `EndAddrDM)) ||
                        ((addr >= `StartAddrTC0) && (addr <= `EndAddrTC0)) ||
                        ((addr >= `StartAddrTC1) && (addr <= `EndAddrTC1)) ||
                        ((addr >= `StartAddrStall) && (addr <= `EndAddrStall)));

wire ErrTimer = ((addr >= `StartAddrTC0 && addr <= `EndAddrTC0) ||
                (addr >= `StartAddrTC1 && addr <= `EndAddrTC1)) &&
                (LSOp != 3);
wire ErrCount = ((addr >= `StartAddrTC0 + 8 && addr <= `EndAddrTC0)||
                (addr >= `StartAddrTC1 +8 && addr <= `EndAddrTC1));

assign MEM_EXC_AdES = (LSOp) && !MemtoReg && (ErrAlign || ErrOutOfRange || ErrTimer || ErrCount);

endmodule
