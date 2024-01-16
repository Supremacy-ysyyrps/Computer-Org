`timescale 1ns / 1ps
module alu
#(parameter WIDTH=32)
(input [WIDTH-1:0] input1,
input [WIDTH-1:0] input2,
input [3:0] aluCtr,
output reg[WIDTH-1:0] aluRes,
output reg ZF, //0��־λ, ������Ϊ0(ȫ��)����1, ������0
           CF, //����λ��־λ, ȡ���λ��λC,�ӷ�ʱC=1��CF=1��ʾ�н�λ,����ʱC=0��CF=1��ʾ�н�λ
           OF, //�����־λ�����з��������������壬�����OF=1������Ϊ0                     
           SF, //���ű�־λ����F�����λ��ͬ
           PF  //��ż��־λ��F��������1����PF=1������Ϊ0
);
reg C;
always @(input1 or input2 or aluCtr) // �������������仯ʱ����
begin
    case(aluCtr)
        4'b0000: // ��
            aluRes = input1 & input2;
        4'b0001: // ��
            aluRes = input1 | input2;
        4'b0010: // ��
            {C,aluRes} = input1 + input2;
        4'b0011: // ����
            aluRes = input2 << input1;
        4'b0100: //��������
            aluRes = input2 >>> input1;
        4'b0101: //����
            aluRes = input2 >> input1;
        4'b0110: // ��
            {C,aluRes} = input1 - input2;
        4'b0111: // С������
            aluRes=(input1<input2)? 1:0;
        4'b1000: // ���
            aluRes = input1^input2;
        4'b1100: // ���
            aluRes = ~(input1 | input2);        
        default:
            aluRes = 0;
    endcase
     ZF = aluRes==0;//FȫΪ0����ZF=1
     CF = C; //��λ��λ��־
     OF = input1[WIDTH-1]^input2[WIDTH-1]^aluRes[WIDTH-1]^C;//�����־��ʽ
     SF = aluRes[WIDTH-1];//���ű�־,ȡF�����λ
     PF = ~^aluRes;//��ż��־��F��������1����F=1��ż����1����F=0
end
endmodule