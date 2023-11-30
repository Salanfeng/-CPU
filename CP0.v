`timescale 1ns / 1ps
`define IM SR[15:10] //Interrupt Mask
`define EXL SR[1]   //Exception Level
`define IE SR[0]    //Interrupt Enable
`define BD Cause[31] //Branch Delay
`define IP Cause[15:10] //Interrupt Pending
`define ExcCode Cause[6:2] //Exception Code
module CP0(
    input clk,
    input reset,
    input en,
    input [4:0] CP0Addr, //寄存器地址
    input [31:0] CP0In,  //CP0 写入数据
    output [31:0] CP0Out, //CP0 读出数据
    input [31:0] VPC,    //受害PC
    input BDin,          //是否是延迟槽指令
    input [4:0] ExcCodeIn,//记录异常类型
    input [5:0] HWInt,   //输入中断信号
    input EXLClr,
    output [31:0] EPCOut,
    output Req
    );
reg [31:0] SR;   //12
reg [31:0] Cause;//13
reg [31:0] EPC;  //14

wire IntReq = (|(HWInt & `IM)) && !`EXL && `IE; // 允许当前中断 且 不在中断异常中 且 允许中断发生
wire ExcReq = (|ExcCodeIn) && !`EXL; // 存在异常 且 不在中断中
assign Req  = IntReq || ExcReq;

wire [31:0] tempEPC = (Req) ? (BDin ? VPC[31:0]-4 : VPC[31:0])
                            : EPC;

assign EPCOut = tempEPC;


always@(posedge clk) begin
    `IP <= HWInt;
    if(reset) begin
        SR <= 0;
        Cause <= 0;
        EPC <= 0;
    end
    else begin
        if (EXLClr) begin
            `EXL <= 1'b0;
        end
        if (Req) begin
            `ExcCode <= IntReq ? 5'b0 : ExcCodeIn;
            `EXL <= 1'b1;
            EPC <= tempEPC;
            `BD <= BDin;
        end
        if(en) begin
            case (CP0Addr)
                12: SR <= CP0In;
                13: Cause <= CP0In;
                14: EPC <= CP0In;
                default: begin
                    SR <= SR;
                    Cause <= Cause;
                    EPC <= EPC;
                end
            endcase
        end
    end
end

assign CP0Out = (CP0Addr == 12) ? SR :
                (CP0Addr == 13) ? Cause :
                (CP0Addr == 14) ? EPC :
                32'b0;

	
endmodule
