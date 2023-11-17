module savebyte(
    input [1:0] addr,
    input [1:0] LSOp,
    input [31:0] WD_in,
    output [3:0] byteen,
    output [31:0] WD_out
    );
reg [3:0] byteen_t;
reg [31:0] WD_out_t;
assign byteen = byteen_t;
assign WD_out = WD_out_t;
always@(*) begin
    if (LSOp == 2'b00) begin
        byteen_t = 4'b1111;
        WD_out_t = WD_in;
    end
    else if (LSOp == 2'b01) begin
        if (addr[1] == 0) begin
            byteen_t = 4'b0011;
            WD_out_t = {16'b0,WD_in[15:0]};
        end
        else begin
            byteen_t = 4'b1100;
            WD_out_t = {WD_in[15:0],16'b0};
        end
    end
    else if (LSOp == 2'b10) begin
        if (addr == 0) begin
            byteen_t = 4'b0001;
            WD_out_t = {24'b0,WD_in[7:0]};
        end
        else if (addr == 1) begin
            byteen_t = 4'b0010;
            WD_out_t = {16'b0,WD_in[15:8],8'b0};
        end
        else if (addr == 2) begin
            byteen_t = 4'b0100;
            WD_out_t = {8'b0,WD_in[23:16],16'b0};
        end
        else begin
            byteen_t = 4'b1000;
            WD_out_t = {WD_in[31:24],24'b0};
        end
    end
    else begin
        byteen_t = 4'b0000;
        WD_out_t = 32'b0;
    end
end

endmodule
