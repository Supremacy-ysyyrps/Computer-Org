`timescale 1ns / 1ps
module top(
input clk,
input reset,
input run,
input step,
input [2:0] sel1,
input sel0,
output [6:0] sm_duan,//段码
output [3:0] sm_wei//哪个数码管,
);
//IF
    wire [31:0] PC, add4;
    wire [31:0] instruction; 
//IF_ID
    wire [31:0] PC_add_out1, Instruct_out1;
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
    assign shamt=Instruct_out1[10:6];
//ID_EX
    wire [31:0] PC_add_out2, DataBusA_out2, DataBusB_out2;
    wire [4:0] Rs_out2, Rt_out2, Rd_out2, Shamt_out2;
    //NEXTPC
    wire jal_out2;
    wire [1:0] branch_out2;
    //EX
    wire RegDst_out2, ALUSrc_out2, lui_out2;
    wire [31:0] ext_out2;
    wire [3:0] aluop_out2;
    //MEM
    wire MemRead_out2, MemWrite_out2;
    wire [1:0] memflag_out2;
    //WB
    wire RegWrite_out2, MemToReg_out2;
//EX
    wire[31:0] input1,input2,FA,FB;
    wire ZF,OF,CF,PF,SF; //alu运算为零标志 
    wire[31:0] aluRes; //alu运算结果
//EX_MEM
    wire[31:0] PC_add_out3, ALUout3_out3, DataBusB_out3;
    wire[4:0]  Rd_out3;
    //NEXTPC
    wire[1:0] branch_out3;
    wire zf_out3, sf_out3, jal_out3;
    wire [31:0] ext_out3;
    //MEM
    wire MemRead_out3,MemWrite_out3;
    wire[1:0] memflag_out3;
    //WB
    wire RegWrite_out3, MemToReg_out3;
//MEM
    wire[31:0] memreaddata;
//MEM_WB
    wire [31:0] MemReadData_out4, ALUout4_out4, PC_add_out4;
    wire [4:0] Rd_out4;
    //NEXTPC
    wire jr_out4, jal_out4;
    //WB
    wire RegWrite_out4, MemToReg_out4;
//WB
    wire [4:0] regWriteAddr;
    wire [31:0] regWriteData;
//冒险
    wire [3:0] res;
    wire PCwrite, IF_ID_W;
//DIS
    //reg[1:0] sel;
    //wire [6:0] sm_duan;//段码
    //wire [3:0] sm_wei;//哪个数码管,
    reg [31:0] content;
    wire [15:0] data;
    always@(*)
    begin
        case(sel1)
            3'b000: content=PC;
            3'b001: content=instruction;
            3'b010: content=RsData;
            3'b011: content=RtData;
            3'b100: content=aluRes;
            3'b101: content=memreaddata;
            3'b110: content=Rd_out4;
            3'b111: content=regWriteData;
        endcase
    end
    assign data = sel0?content[31:16]:content[15:0];
//DIV
    integer clk_cnt=0;
    reg clkin=1;
    always @(posedge clk)
    if(clk_cnt==99)//50000000
        begin
            clk_cnt <= 1'b0;
            clkin <= ~clkin;
        end
    else
        clk_cnt <= clk_cnt+1;
    wire clkcpu;
    assign clkcpu = run?clkin:step;
    //根据run决定cpu时钟来源（连续or单步）

//实例化PC更新
    next_pc next(
    clkcpu,             //cpu时钟
    reset,              //复位信号
    PCwrite,            //冒险单元控制的写使能信号 load-use型冒险时为0
    branch_out3,        //分支指令 MEM阶段确定目标地址
    zf_out3,            //是否为0，beq、bne使用
    sf_out3,            //是否为负，bltz使用
    ext_out3,           //符号扩展立即数字段，计算分支目标地址
    PC_add_out3,        //基址
    jmp,                //j指令和jal指令信号 ID阶段确定目标地址
    Instruct_out1,      //取指令低26位，生成跳转目标地址
    PC_add_out1,        //取高四位
    jr,                 //jr指令 EX阶段确定目标地址
    DataBusA_out2,      //rs中存放目标地址
    //输出
    PC,                 //输出新的PC值
    add4);              //输出PC+4的值
// 例化指令存储器
    Ins_Rom IMEM(
    .clka(clk),          // input 提供高频信号
    .ena(1'b1),          // input 数据输出允许
    .addra(PC[9:2]),     // input 地址
    .douta(instruction)  // output 指令
    );
//IF_ID_REG
    IF_ID if_id(
    clkcpu,             //cpu时钟
    IF_ID_W,            //冒险单元控制的写使能信号 load-use型冒险时为0
    res[3],             //冒险单元产生的复位信号 用于分支指令flush
    add4,               //输入PC+4
    instruction,        //输入指令
    PC_add_out1,        //输出PC+4
    Instruct_out1);     //输出指令
// 实例化控制器模块
    ctrl mainctr(
    .opCode(Instruct_out1[31:26]),  //OP字段来自IF_ID寄存器输出的指令
    .regDst(reg_dst),               //决定目的寄存器号
    .aluSrc(alu_src),               //决定ALU第二个输入来源
    .memToReg(memtoreg),            //决定写回的数据
    .regWrite(regwrite),            //寄存器写信号
    .memRead(memread),              //存储器读信号
    .memWrite(memwrite),            //存储器写信号
    .branch(branch),                //分支指令信号
    .ExtOp(ExtOp),                  //符号扩展
    .aluop(aluop),                  //aluop信号
    .jmp(jmp),
    .lui(lui),
    .jal(jal),
    .memflag(memflag));             //存取操作对象(字、半字、字节)
// 实例化寄存器模块
    RegFile regfile(
    !clkcpu,                 //下降沿写入
    reset,                  //复位信号
    RegWrite_out4,          //写使能信号
    Instruct_out1[25:21],   //rs字段
    Instruct_out1[20:16],   //rt字段
    Rd_out4,                //写地址
    regWriteData,           //写数据
    RsData,                 //两个读数据
    RtData);
//实例化符号扩展模块
    signext signext(.imm(Instruct_out1[15:0]),.ExtOp(ExtOp), .data(expand));
//ID_EX
    ID_EX id_ex(
    clkcpu,
    res[2],             //分支指令和jr指令发生时需要flush
    //需要传递的数据
    PC_add_out1, RsData, RtData, Instruct_out1[25:21], Instruct_out1[20:16], Instruct_out1[15:11], shamt,
    PC_add_out2, DataBusA_out2, DataBusB_out2, Rs_out2, Rt_out2, Rd_out2, Shamt_out2,
    //PC更新需要的信号
    jal, branch,
    jal_out2, branch_out2,
    //EX阶段需要的信号
    reg_dst, alu_src, lui, expand, aluop,
    RegDst_out2, ALUSrc_out2, lui_out2, ext_out2, aluop_out2,
    //MEM阶段需要的信号
    memread, memwrite, memflag, 
    MemRead_out2,MemWrite_out2, memflag_out2,
    //WB阶段需要的信号
    regwrite, memtoreg, RegWrite_out2, MemToReg_out2);
// 实例化 ALU 控制模块
    aluctr aluctrl(
    .ALUOp(aluop_out2),             //主控制模块生成的aluop
    .funct(ext_out2[5:0]),          //指令的func字段
    .ALUCtr(aluCtr),                //真正的alu控制信号
    .jr(jr),                        //jr指令
    .sham(sham));                   //移位指令需要shamt字段时使用
    assign regWriteAddr = jal_out2? 5'b11111:{RegDst_out2 ? Rd_out2 : Rt_out2};
    //写寄存器的目标寄存器来自可能为31(jal指令)、rt(I型指令)或rd(R型指令)
    assign input1 = lui_out2? 16:{sham? Shamt_out2:FA};
    //ALU的第一个操作数根据指令类型可以为16(lui移位)，shamt字段(算术和逻辑移位)，$rs
    assign input2 = ALUSrc_out2 ? ext_out2:FB;
    //ALU的第二个操作数来自寄存器堆输出或指令低16位的符号扩展
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
 //EX_MEM
     EX_MEM ex_mem(
     clkcpu,
     res[1],            //分支指令发生时需要flush
     //需要传递的数据
     PC_add_out2, aluRes, FB, regWriteAddr,
     PC_add_out3, ALUout3_out3, DataBusB_out3, Rd_out3,
     //PC更新需要的信号
     branch_out2, ZF, SF, jal_out2, ext_out2,
     branch_out3, zf_out3, sf_out3, jal_out3, ext_out3,
     //MEM阶段需要的信号
     MemRead_out2, MemWrite_out2, memflag_out2,
     MemRead_out3, MemWrite_out3, memflag_out3,
     //WB阶段需要的信号
     RegWrite_out2, MemToReg_out2,
     RegWrite_out3, MemToReg_out3);
//实例化数据存储器
    DM_unit DMEM(
    .clk(clkcpu),                //CPU时钟信号，控制写入
    .Wr(MemWrite_out3),          //写使能信号，由控制器产生
    .reset(reset),               //复位信号
    .memflag(memflag_out3),      //决定是字操作、半字操作还是字节操作
    .a(ALUout3_out3),            //地址，由alu输出提供
    .wd(DataBusB_out3),          //写数据，为$rt内容
    .rd(memreaddata));      //读数据
//MEM_WB
    MEM_WB mem_wb(
    clkcpu, res[0],
    //需要传递的数据
    memreaddata, ALUout3_out3, PC_add_out3, Rd_out3,
    MemReadData_out4, ALUout4_out4, PC_add_out4, Rd_out4,
    //PC更新需要的信号
    jal_out3, jal_out4,
    //WB阶段需要的信号
    RegWrite_out3, MemToReg_out3,
    RegWrite_out4, MemToReg_out4);
    assign regWriteData = MemToReg_out4 ? MemReadData_out4:{jal_out4 ? PC_add_out4:ALUout4_out4};
    //写入寄存器的数据来自数据存储器(lw) 、PC+4(jal写入31号寄存器)、ALU运算结果(R型指令)
//实例化数码管显示模块
    display Smg(.clk(clk),.sm_wei(sm_wei),.data(data),.sm_duan(sm_duan));
//转发
    Forward_Unit FU(
    RegWrite_out3,      //EX/MEM寄存器的写回信号
    RegWrite_out4,      //MEM/WB寄存器的写回信号
    Rd_out3,            //EX/MEM的写地址
    Rd_out4,            //MEM/WB的写地址
    Rs_out2, Rt_out2,   //EX阶段的读寄存器数
    DataBusA_out2, DataBusB_out2, ALUout3_out3, regWriteData, //输出数据来源 RS、RT本身和ALU结果、写回阶段的数据
    FA, FB);            //输出转发后的数据
//冒险
    Hazard_Unit HU(
    Instruct_out1[25:21], Instruct_out1[20:16],     //ID阶段的两个寄存器号
    Rt_out2, MemRead_out2,                          //处理load-use类型冒险
    zf_out3, sf_out3, jmp, jr, branch_out3,         //处理分支、跳转控制冒险
    res, PCwrite, IF_ID_W);                         //输出的flush、写使能信号
endmodule