`define StartAddrDM 32'h0000_0000
`define EndAddrDM 32'h0000_2fff
`define StartAddrTC0 32'h0000_7f00
`define EndAddrTC0 32'h0000_7f0b
`define StartAddrTC1 32'h0000_7f10
`define EndAddrTC1 32'h0000_7f1b
`define StartAddrStall 32'h0000_7f20
`define EndAddrStall 32'h0000_7f23


module loadbyte(
    input [31:0] addr,
    input [1:0] LSOp,
    input [31:0] WD_in,
    input MemtoReg,
    output [31:0] WD_out,
    output MEM_EXC_AdEL
    );
reg [31:0] WD_out_t;
assign WD_out = WD_out_t;
always@(*) begin
    if (LSOp == 2'b11) begin
        WD_out_t = WD_in;
    end
    else if (LSOp == 2'b10) begin
        if (addr[1] == 0) begin
            WD_out_t = {{16{WD_in[15]}},WD_in[15:0]};
        end
        else begin
            WD_out_t = {{16{WD_in[31]}},WD_in[31:16]};
        end
    end
    else if (LSOp == 2'b01) begin
        if (addr[1:0] == 0) begin
            WD_out_t = {{24{WD_in[7]}},WD_in[7:0]};
        end
        else if (addr[1:0] == 1) begin
            WD_out_t = {{24{WD_in[15]}},WD_in[15:8]};
        end
        else if (addr[1:0] == 2) begin
            WD_out_t = {{24{WD_in[23]}},WD_in[23:16]};
        end
        else begin
            WD_out_t = {{24{WD_in[31]}},WD_in[31:24]};
        end
    end
    else begin
        WD_out_t = WD_in;
    end
end

wire ErrAlign = ((LSOp == 3) && (|addr[1:0])) ||
                    ((LSOp == 2) && (addr[0]));
    
wire ErrOutOfRange = !(((addr >= `StartAddrDM) && (addr <= `EndAddrDM)) ||
                        ((addr >= `StartAddrTC0) && (addr <= `EndAddrTC0)) ||
                        ((addr >= `StartAddrTC1) && (addr <= `EndAddrTC1)) ||
                        ((addr >= `StartAddrStall) && (addr <= `EndAddrStall)));

wire ErrTimer = ((addr >= `StartAddrTC0 && addr <= `EndAddrTC0) ||
                (addr >= `StartAddrTC1 && addr <= `EndAddrTC1)) &&
                (LSOp != 3);

assign MEM_EXC_AdEL = (LSOp) && MemtoReg && (ErrAlign || ErrOutOfRange || ErrTimer);

endmodule
