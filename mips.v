module mips(
    input clk,                    // 时钟信号
    input reset,                  // 同步复位信号
    input interrupt,              // 外部中断信号
    output [31:0] macroscopic_pc, // 宏观 PC

    output [31:0] i_inst_addr,    // IM 读取地址（取指 PC）
    input  [31:0] i_inst_rdata,   // IM 读取数据

    output [31:0] m_data_addr,    // DM 读写地址
    input  [31:0] m_data_rdata,   // DM 读取数据
    output [31:0] m_data_wdata,   // DM 待写入数据
    output [3 :0] m_data_byteen,  // DM 字节使能信号

    output [31:0] m_int_addr,     // 中断发生器待写入地址
    output [3 :0] m_int_byteen,   // 中断发生器字节使能信号

    output [31:0] m_inst_addr,    // M 级 PC

    output w_grf_we,              // GRF 写使能信号
    output [4 :0] w_grf_addr,     // GRF 待写入寄存器编号
    output [31:0] w_grf_wdata,    // GRF 待写入数据

    output [31:0] w_inst_addr     // W 级 PC
);

//declare
//cpu
wire [31:0] MemOut;
wire [31:0] DM_addr;
wire [31:0] MemData;
wire [3:0] byteen;
wire [31:0] RegData;
//TC
wire T0_WE;
wire T1_WE;
wire [31:0] T0_RD;
wire [31:0] T1_RD;
wire [31:0] T0_Dout;
wire [31:0] T1_Dout;
wire T0_IRQ;
wire T1_IRQ;
wire [5:0] HWInt = {3'b0,interrupt, T1_IRQ, T0_IRQ};
wire IntResponse;
assign macroscopic_pc = m_inst_addr;
assign m_int_addr = IntResponse&&interrupt ? 32'h7F20 : m_data_addr;
assign m_int_byteen = IntResponse&&interrupt ? 4'b1111 : m_data_byteen;
CPU cpu(
    .clk(clk),
    .reset(reset),
    .Instr(i_inst_rdata),
    .MemOut(MemOut),
    .HWInt(HWInt),
///////////////////////////////
    .PC(i_inst_addr),
    .m_PC(m_inst_addr),
    .DM_addr(DM_addr),
    .MemData(MemData),
    .byteen(byteen),
    .RW(w_grf_we),
    .GRF_addr(w_grf_addr),
    .RegData(w_grf_wdata),
    .GRF_PC(w_inst_addr),
    .IntResponse(IntResponse)
);
Bridge bridge(
    .Addr_in(DM_addr),
    .WD_in(MemData),
    .Byteen(byteen),
    .DM_RD(m_data_rdata),
    .T0_RD(T0_Dout),
    .T1_RD(T1_Dout),
///////////////////////////////
    .Addr_out(m_data_addr),
    .WD_out(m_data_wdata),
    .RD_out(MemOut),
    .DM_WE(m_data_byteen),
    .T0_WE(T0_WE),
    .T1_WE(T1_WE)
);


TC t0(
    .clk(clk),
    .reset(reset),
    .Addr(DM_addr[31:2]),
    .WE(T0_WE),
    .Din(MemData),
    .Dout(T0_Dout),
    .IRQ(T0_IRQ)
);

TC t1(
    .clk(clk),
    .reset(reset),
    .Addr(DM_addr[31:2]),
    .WE(T1_WE),
    .Din(MemData),
    .Dout(T1_Dout),
    .IRQ(T1_IRQ)
);


endmodule