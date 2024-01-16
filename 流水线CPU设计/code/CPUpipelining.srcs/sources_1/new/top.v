`timescale 1ns / 1ps
module top(
input clk,
input reset,
input run,
input step,
input [2:0] sel1,
input sel0,
output [6:0] sm_duan,//����
output [3:0] sm_wei//�ĸ������,
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
    wire[1:0] memflag;//ָʾ��������
    wire[3:0] aluCtr;//����aluop��ָ���6λ ѡ��alu��������
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
    wire ZF,OF,CF,PF,SF; //alu����Ϊ���־ 
    wire[31:0] aluRes; //alu������
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
//ð��
    wire [3:0] res;
    wire PCwrite, IF_ID_W;
//DIS
    //reg[1:0] sel;
    //wire [6:0] sm_duan;//����
    //wire [3:0] sm_wei;//�ĸ������,
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
    //����run����cpuʱ����Դ������or������

//ʵ����PC����
    next_pc next(
    clkcpu,             //cpuʱ��
    reset,              //��λ�ź�
    PCwrite,            //ð�յ�Ԫ���Ƶ�дʹ���ź� load-use��ð��ʱΪ0
    branch_out3,        //��ָ֧�� MEM�׶�ȷ��Ŀ���ַ
    zf_out3,            //�Ƿ�Ϊ0��beq��bneʹ��
    sf_out3,            //�Ƿ�Ϊ����bltzʹ��
    ext_out3,           //������չ�������ֶΣ������֧Ŀ���ַ
    PC_add_out3,        //��ַ
    jmp,                //jָ���jalָ���ź� ID�׶�ȷ��Ŀ���ַ
    Instruct_out1,      //ȡָ���26λ��������תĿ���ַ
    PC_add_out1,        //ȡ����λ
    jr,                 //jrָ�� EX�׶�ȷ��Ŀ���ַ
    DataBusA_out2,      //rs�д��Ŀ���ַ
    //���
    PC,                 //����µ�PCֵ
    add4);              //���PC+4��ֵ
// ����ָ��洢��
    Ins_Rom IMEM(
    .clka(clk),          // input �ṩ��Ƶ�ź�
    .ena(1'b1),          // input �����������
    .addra(PC[9:2]),     // input ��ַ
    .douta(instruction)  // output ָ��
    );
//IF_ID_REG
    IF_ID if_id(
    clkcpu,             //cpuʱ��
    IF_ID_W,            //ð�յ�Ԫ���Ƶ�дʹ���ź� load-use��ð��ʱΪ0
    res[3],             //ð�յ�Ԫ�����ĸ�λ�ź� ���ڷ�ָ֧��flush
    add4,               //����PC+4
    instruction,        //����ָ��
    PC_add_out1,        //���PC+4
    Instruct_out1);     //���ָ��
// ʵ����������ģ��
    ctrl mainctr(
    .opCode(Instruct_out1[31:26]),  //OP�ֶ�����IF_ID�Ĵ��������ָ��
    .regDst(reg_dst),               //����Ŀ�ļĴ�����
    .aluSrc(alu_src),               //����ALU�ڶ���������Դ
    .memToReg(memtoreg),            //����д�ص�����
    .regWrite(regwrite),            //�Ĵ���д�ź�
    .memRead(memread),              //�洢�����ź�
    .memWrite(memwrite),            //�洢��д�ź�
    .branch(branch),                //��ָ֧���ź�
    .ExtOp(ExtOp),                  //������չ
    .aluop(aluop),                  //aluop�ź�
    .jmp(jmp),
    .lui(lui),
    .jal(jal),
    .memflag(memflag));             //��ȡ��������(�֡����֡��ֽ�)
// ʵ�����Ĵ���ģ��
    RegFile regfile(
    !clkcpu,                 //�½���д��
    reset,                  //��λ�ź�
    RegWrite_out4,          //дʹ���ź�
    Instruct_out1[25:21],   //rs�ֶ�
    Instruct_out1[20:16],   //rt�ֶ�
    Rd_out4,                //д��ַ
    regWriteData,           //д����
    RsData,                 //����������
    RtData);
//ʵ����������չģ��
    signext signext(.imm(Instruct_out1[15:0]),.ExtOp(ExtOp), .data(expand));
//ID_EX
    ID_EX id_ex(
    clkcpu,
    res[2],             //��ָ֧���jrָ���ʱ��Ҫflush
    //��Ҫ���ݵ�����
    PC_add_out1, RsData, RtData, Instruct_out1[25:21], Instruct_out1[20:16], Instruct_out1[15:11], shamt,
    PC_add_out2, DataBusA_out2, DataBusB_out2, Rs_out2, Rt_out2, Rd_out2, Shamt_out2,
    //PC������Ҫ���ź�
    jal, branch,
    jal_out2, branch_out2,
    //EX�׶���Ҫ���ź�
    reg_dst, alu_src, lui, expand, aluop,
    RegDst_out2, ALUSrc_out2, lui_out2, ext_out2, aluop_out2,
    //MEM�׶���Ҫ���ź�
    memread, memwrite, memflag, 
    MemRead_out2,MemWrite_out2, memflag_out2,
    //WB�׶���Ҫ���ź�
    regwrite, memtoreg, RegWrite_out2, MemToReg_out2);
// ʵ���� ALU ����ģ��
    aluctr aluctrl(
    .ALUOp(aluop_out2),             //������ģ�����ɵ�aluop
    .funct(ext_out2[5:0]),          //ָ���func�ֶ�
    .ALUCtr(aluCtr),                //������alu�����ź�
    .jr(jr),                        //jrָ��
    .sham(sham));                   //��λָ����Ҫshamt�ֶ�ʱʹ��
    assign regWriteAddr = jal_out2? 5'b11111:{RegDst_out2 ? Rd_out2 : Rt_out2};
    //д�Ĵ�����Ŀ��Ĵ������Կ���Ϊ31(jalָ��)��rt(I��ָ��)��rd(R��ָ��)
    assign input1 = lui_out2? 16:{sham? Shamt_out2:FA};
    //ALU�ĵ�һ������������ָ�����Ϳ���Ϊ16(lui��λ)��shamt�ֶ�(�������߼���λ)��$rs
    assign input2 = ALUSrc_out2 ? ext_out2:FB;
    //ALU�ĵڶ������������ԼĴ����������ָ���16λ�ķ�����չ
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
 //EX_MEM
     EX_MEM ex_mem(
     clkcpu,
     res[1],            //��ָ֧���ʱ��Ҫflush
     //��Ҫ���ݵ�����
     PC_add_out2, aluRes, FB, regWriteAddr,
     PC_add_out3, ALUout3_out3, DataBusB_out3, Rd_out3,
     //PC������Ҫ���ź�
     branch_out2, ZF, SF, jal_out2, ext_out2,
     branch_out3, zf_out3, sf_out3, jal_out3, ext_out3,
     //MEM�׶���Ҫ���ź�
     MemRead_out2, MemWrite_out2, memflag_out2,
     MemRead_out3, MemWrite_out3, memflag_out3,
     //WB�׶���Ҫ���ź�
     RegWrite_out2, MemToReg_out2,
     RegWrite_out3, MemToReg_out3);
//ʵ�������ݴ洢��
    DM_unit DMEM(
    .clk(clkcpu),                //CPUʱ���źţ�����д��
    .Wr(MemWrite_out3),          //дʹ���źţ��ɿ���������
    .reset(reset),               //��λ�ź�
    .memflag(memflag_out3),      //�������ֲ��������ֲ��������ֽڲ���
    .a(ALUout3_out3),            //��ַ����alu����ṩ
    .wd(DataBusB_out3),          //д���ݣ�Ϊ$rt����
    .rd(memreaddata));      //������
//MEM_WB
    MEM_WB mem_wb(
    clkcpu, res[0],
    //��Ҫ���ݵ�����
    memreaddata, ALUout3_out3, PC_add_out3, Rd_out3,
    MemReadData_out4, ALUout4_out4, PC_add_out4, Rd_out4,
    //PC������Ҫ���ź�
    jal_out3, jal_out4,
    //WB�׶���Ҫ���ź�
    RegWrite_out3, MemToReg_out3,
    RegWrite_out4, MemToReg_out4);
    assign regWriteData = MemToReg_out4 ? MemReadData_out4:{jal_out4 ? PC_add_out4:ALUout4_out4};
    //д��Ĵ����������������ݴ洢��(lw) ��PC+4(jalд��31�żĴ���)��ALU������(R��ָ��)
//ʵ�����������ʾģ��
    display Smg(.clk(clk),.sm_wei(sm_wei),.data(data),.sm_duan(sm_duan));
//ת��
    Forward_Unit FU(
    RegWrite_out3,      //EX/MEM�Ĵ�����д���ź�
    RegWrite_out4,      //MEM/WB�Ĵ�����д���ź�
    Rd_out3,            //EX/MEM��д��ַ
    Rd_out4,            //MEM/WB��д��ַ
    Rs_out2, Rt_out2,   //EX�׶εĶ��Ĵ�����
    DataBusA_out2, DataBusB_out2, ALUout3_out3, regWriteData, //���������Դ RS��RT�����ALU�����д�ؽ׶ε�����
    FA, FB);            //���ת���������
//ð��
    Hazard_Unit HU(
    Instruct_out1[25:21], Instruct_out1[20:16],     //ID�׶ε������Ĵ�����
    Rt_out2, MemRead_out2,                          //����load-use����ð��
    zf_out3, sf_out3, jmp, jr, branch_out3,         //�����֧����ת����ð��
    res, PCwrite, IF_ID_W);                         //�����flush��дʹ���ź�
endmodule