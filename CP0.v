`timescale 1ns / 1ps
`define IM SR[15:10]
`define EXL SR[1]
`define IE SR[0]
`define BD Cause[31]
`define IP Cause[15:10]
`define ExcCode Cause[6:2]
module CP0(
    input clk,
    input reset,
    input en,
    input [4:0] CP0Addr, //寄存器地址
    input [31:0] CP0In,  //CP0 写入数据
    input [31:0] CP0Out, //CP0 读出数据
    input [31:0] VPC,    //受害PC
    input BDin,          //是否是延迟槽指令
    input [4:0] ExcCodeIn,//记录异常类型
    input [5:0] HWInt, //输入中断信号
    input EXLClr,
    output [31:0] EPCOut,
    output Req
    );
reg [31:0] SR;
reg [31:0] Cause;
reg [31:0] EPC;
assign EPCOut = EPC;

wire IntReq = (|(HWInt & `IM)) && !`EXL && `IE; // 允许当前中断 且 不在中断异常中 且 允许中断发生
wire ExcReq = (|ExcCodeIn) && !`EXL; // 存在异常 且 不在中断中
assign Req  = IntReq || ExcReq;

always@(posedge clk) begin
    if(reset) begin
        SR <= 0;
        Cause <= 0;
        EPC <= 0;
    end
    else if(en) begin
        case(CP0Addr)
            12 : SR <= CP0In;
            13 : Cause <= CP0In;
            14 : EPC <= CP0In;
            default : begin
                SR <= SR;
                Cause <= Cause;
                EPC <= EPC;
            end
        endcase
    end
    else begin
        SR <= SR;
        Cause <= Cause;
        EPC <= EPC;
    end
end



	
endmodule
