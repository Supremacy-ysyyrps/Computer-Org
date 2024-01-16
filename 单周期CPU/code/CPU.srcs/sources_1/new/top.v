`timescale 1ns / 1ps
module top(
input clk,
input reset,
input run,
input step,
input[2:0] sel1,
input sel0,
output [6:0] sm_duan,//����
output [3:0] sm_wei//�ĸ������,
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
    wire[1:0] memflag;//ָʾ��������
    wire[3:0] aluCtr;//����aluop��ָ���6λ ѡ��alu��������
    //reg
    wire[31:0] RsData, RtData;
    wire[31:0] expand;
    wire[4:0] shamt;
    assign shamt=instruction[10:6];
//EX
    wire[31:0] input1;
    wire[31:0] input2;
    wire ZF,OF,CF,PF,SF; //alu����Ϊ���־ 
    wire[31:0] aluRes; //alu������
    assign input1 = lui? 16:{sham? shamt:RsData};
    //ALU�ĵ�һ������������ָ�����Ϳ���Ϊ16(lui��λ)��shamt�ֶ�(�������߼���λ)��$rs
    assign input2 = alu_src ? expand:RtData;
    //ALU�ĵڶ������������ԼĴ����������ָ���16λ�ķ�����չ
//MEM
    wire[31:0] memreaddata;
//WB
    wire [4:0] regWriteAddr;
    wire [31:0] regWriteData;
    assign regWriteAddr = jal? 5'b11111:{reg_dst ? instruction[15:11] : instruction[20:16]};
    //д�Ĵ�����Ŀ��Ĵ������Կ���Ϊ31(jalָ��)��rt(I��ָ��)��rd(R��ָ��)
    assign regWriteData = memtoreg ? memreaddata:{jal?PC+4:aluRes};
    //д��Ĵ����������������ݴ洢��(lw) ��PC+4(jalд��31�żĴ���)��ALU������(R��ָ��)
//DIS
    //reg[1:0] sel;
    //wire [6:0] sm_duan;//����
    //wire [3:0] sm_wei;//�ĸ������,
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
//����run����cpuʱ����Դ������or������
// ����ָ��洢��
Ins_Rom IMEM(
.clka(clk),          // input �ṩ��Ƶ�ź�
.ena(1'b1),          // input �����������
.addra(PC[9:2]),     // input ��ַ
.douta(instruction)  // output ָ��
);
//ʵ����PC����
next_pc next(
clkcpu,             //cpuʱ��
reset,              //��λ�ź�
branch,             //��ָ֧��
ZF,                 //�Ƿ�Ϊ0��beq��bneʹ��
SF,                 //�Ƿ�Ϊ����bltzʹ��
expand,             //������չ�������ֶΣ������֧Ŀ���ַ
jmp,                //��תָ��
instruction,        //ȡָ���26λ��������תĿ���ַ
jr,                 //jrָ��
RsData,             //rs�д��Ŀ���ַ
PC                  //����µ�PCֵ
);
// ʵ����������ģ��
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
// ʵ���� ALU ����ģ��
aluctr aluctrl(
.ALUOp(aluop),                  //������ģ�����ɵ�aluop
.funct(instruction[5:0]),       //ָ���func�ֶ�
.ALUCtr(aluCtr),                //������alu�����ź�
.jr(jr),                        //jrָ��
.sham(sham));                   //��λָ����Ҫshamt�ֶ�ʱʹ��
// ʵ�����Ĵ���ģ��
RegFile regfile(
clkcpu,                //�½���д��
reset,                  //��λ�ź�
regwrite,               //дʹ���ź�
instruction[25:21],     //rs�ֶ�
instruction[20:16],     //rt�ֶ�
regWriteAddr,           //д��ַ
regWriteData,           //д����
RsData,                 //����������
RtData);
// ʵ����ALUģ��
alu alu(
.input1(input1),        //д��alu������������
.input2(input2),
.aluCtr(aluCtr),        //alu�������ɵ�������alu�����ź�
.ZF(ZF),                //0�����������λ�����š���ż��־λ
.OF(OF),
.CF(CF),
.SF(SF),
.PF(PF),
.aluRes(aluRes));       //������
//ʵ�������ݴ洢��
DM_unit DMEM(
.clk(clkcpu),           //CPUʱ���źţ�����д��
.Wr(memwrite),          //дʹ���źţ��ɿ���������
.reset(reset),          //��λ�ź�
.memflag(memflag),      //�������ֲ��������ֲ��������ֽڲ���
.a(aluRes),             //��ַ����alu����ṩ
.wd(RtData),            //д���ݣ�Ϊ$rt����
.rd(memreaddata));      //������
//ʵ�����������ʾģ��
display Smg(.clk(clk),.sm_wei(sm_wei),.data(data),.sm_duan(sm_duan));
//ʵ����������չģ��
signext signext(.imm(instruction[15:0]),.ExtOp(ExtOp), .data(expand));
endmodule