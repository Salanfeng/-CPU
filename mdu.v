`timescale 1ns / 1ps
module npc(
    input clk,
    input reset,
    input start,
	input [3:0] MDUOp,
	input [31:0] A,
    input [31:0] B,
    output [31:0] HI,
    output [31:0] LO,
    output [31:0] Out,
    output busy
    );
reg [31:0] HI_t,LO_t,Out_t,BusyTime;
assign HI = HI_t;
assign LO = LO_t;
assign Out = Out_t;
assign busy = (BusyTime > 0);
always@(posedge clk) begin
    if (reset) begin
        HI_t <= 32'h00000000;
        LO_t <= 32'h00000000;
        Out_t <= 32'h00000000;
        BusyTime <= 32'h00000000;
    end
    else if (BusyTime > 0) begin
        BusyTime = BusyTime - 1;
    end
    else if (start) begin
        case (MDUOp)
            4'b0001: begin
                {HI_t, LO_t} <= $signed(A) * $signed(B);
                BusyTime <= 32'd5;
            end
            4'b0010: begin
                {HI_t, LO_t} <= A * B;
                BusyTime <= 32'd5;
            end
            4'b0011: begin
                {HI_t, LO_t} <= $signed(A) / $signed(B);
                BusyTime <= 32'd10;
            end
            4'b0100: begin
                {HI_t, LO_t} <= (A) / (B);
                BusyTime <= 32'd10;
            end
            4'b0101: begin
                Out_t <= HI_t;
            end
            4'b0110: begin
                Out_t <= LO_t;
            end
            4'b0111: begin
                Hi_t <= A;
            end
            4'b1000: begin
                LO_t <= A;
            end
            default: begin
                Out_t = 32'h00000000;
            end
        endcase
    end
    else begin
        Out_t = 32'h00000000;
    end
end
	 
endmodule

//{HI, LO} <= $signed({HI, LO}) + $signed(A) * $signed(B);