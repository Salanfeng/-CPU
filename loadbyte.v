module loadbyte(
    input [1:0] addr,
    input [1:0] LSOp,
    input [31:0] WD_in,
    output [31:0] WD_out
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
        if (addr == 0) begin
            WD_out_t = {{24{WD_in[7]}},WD_in[7:0]};
        end
        else if (addr == 1) begin
            WD_out_t = {{24{WD_in[15]}},WD_in[15:8]};
        end
        else if (addr == 2) begin
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

endmodule
