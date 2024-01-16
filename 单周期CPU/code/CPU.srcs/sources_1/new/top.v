`timescale 1ns / 1ps
module top(
input clk,
input reset,
input run,
input step,
input[2:0] sel1,
input sel0,
output [6:0] sm_duan,//段码
output [3:0] sm_wei//哪个数码管,
);
//IF
    wire [31:0] PC;
    wire [7:0]pc;
    assign pc = PC[9:2];
    wire [31:0] instruction; 
//ID
    //ctrl
    wire reg_dst,jmp, memread, memwrite, memtoreg,alu_src,ExtOp, regwrite, lui, jal, jr, sham;
    wire[1:0] branch;
    wire[3:0] aluop;
    wire[1:0] memflag;//指示操作对象
    wire[3:0] aluCtr;//根据aluop和指令后6位 选择alu运算类型
    //reg
    wire[31:0] RsData, RtData;
    wire[31:0] expand;
    wire[4:0] shamt;
    assign shamt=instruction[10:6];
//EX
    wire[31:0] input1;
    wire[31:0] input2;
    wire ZF,OF,CF,PF,SF; //alu运算为零标志 
    wire[31:0] aluRes; //alu运算结果
    assign input1 = lui? 16:{sham? shamt:RsData};
    //ALU的第一个操作数根据指令类型可以为16(lui移位)，shamt字段(算术和逻辑移位)，$rs
    assign input2 = alu_src ? expand:RtData;
    //ALU的第二个操作数来自寄存器堆输出或指令低16位的符号扩展
//MEM
    wire[31:0] memreaddata;
//WB
    wire [4:0] regWriteAddr;
    wire [31:0] regWriteData;
    assign regWriteAddr = jal? 5'b11111:{reg_dst ? instruction[15:11] : instruction[20:16]};
    //写寄存器的目标寄存器来自可能为31(jal指令)、rt(I型指令)或rd(R型指令)
    assign regWriteData = memtoreg ? memreaddata:{jal?PC+4:aluRes};
    //写入寄存器的数据来自数据存储器(lw) 、PC+4(jal写入31号寄存器)、ALU运算结果(R型指令)
//DIS
    //reg[1:0] sel;
    //wire [6:0] sm_duan;//段码
    //wire [3:0] sm_wei;//哪个数码管,
    reg [31:0] content;
    wire [15:0] data;
    always@(*)
    begin
        case(sel1)
            3'b000: content=pc;
            3'b001: content=instruction;
            3'b010: content=RsData;
            3'b011: content=RtData;
            3'b100: content=input1;
            3'b101: content=input2;
            3'b110: content=aluRes;
            3'b111: content=memreaddata;
        endcase
    end
    assign data = sel0?content[31:16]:content[15:0];
integer clk_cnt=0;
reg clkin=0;
always @(posedge clk)
if(clk_cnt==50000000)//50000000
    begin
        clk_cnt <= 1'b0;
        clkin <= ~clkin;
    end
else
    clk_cnt <= clk_cnt+1;
wire clkcpu;
assign clkcpu = run?clkin:step;
//根据run决定cpu时钟来源（连续or单步）
// 例化指令存储器
Ins_Rom IMEM(
.clka(clk),          // input 提供高频信号
.ena(1'b1),          // input 数据输出允许
.addra(PC[9:2]),     // input 地址
.douta(instruction)  // output 指令
);
//实例化PC更新
next_pc next(
clkcpu,             //cpu时钟
reset,              //复位信号
branch,             //分支指令
ZF,                 //是否为0，beq、bne使用
SF,                 //是否为负，bltz使用
expand,             //符号扩展立即数字段，计算分支目标地址
jmp,                //跳转指令
instruction,        //取指令低26位，生成跳转目标地址
jr,                 //jr指令
RsData,             //rs中存放目标地址
PC                  //输出新的PC值
);
// 实例化控制器模块
ctrl mainctr(
.opCode(instruction[31:26]),
.regDst(reg_dst),
.aluSrc(alu_src),
.memToReg(memtoreg),
.regWrite(regwrite),
.memRead(memread),
.memWrite(memwrite),
.branch(branch),
.ExtOp(ExtOp),
.aluop(aluop),
.jmp(jmp),
.lui(lui),
.jal(jal),
.memflag(memflag));
// 实例化 ALU 控制模块
aluctr aluctrl(
.ALUOp(aluop),                  //主控制模块生成的aluop
.funct(instruction[5:0]),       //指令的func字段
.ALUCtr(aluCtr),                //真正的alu控制信号
.jr(jr),                        //jr指令
.sham(sham));                   //移位指令需要shamt字段时使用
// 实例化寄存器模块
RegFile regfile(
clkcpu,                //下降沿写入
reset,                  //复位信号
regwrite,               //写使能信号
instruction[25:21],     //rs字段
instruction[20:16],     //rt字段
regWriteAddr,           //写地址
regWriteData,           //写数据
RsData,                 //两个读数据
RtData);
// 实例化ALU模块
alu alu(
.input1(input1),        //写入alu的两个操作数
.input2(input2),
.aluCtr(aluCtr),        //alu控制生成的真正的alu控制信号
.ZF(ZF),                //0、溢出、进借位、符号、奇偶标志位
.OF(OF),
.CF(CF),
.SF(SF),
.PF(PF),
.aluRes(aluRes));       //运算结果
//实例化数据存储器
DM_unit DMEM(
.clk(clkcpu),           //CPU时钟信号，控制写入
.Wr(memwrite),          //写使能信号，由控制器产生
.reset(reset),          //复位信号
.memflag(memflag),      //决定是字操作、半字操作还是字节操作
.a(aluRes),             //地址，由alu输出提供
.wd(RtData),            //写数据，为$rt内容
.rd(memreaddata));      //读数据
//实例化数码管显示模块
display Smg(.clk(clk),.sm_wei(sm_wei),.data(data),.sm_duan(sm_duan));
//实例化符号扩展模块
signext signext(.imm(instruction[15:0]),.ExtOp(ExtOp), .data(expand));
endmodule