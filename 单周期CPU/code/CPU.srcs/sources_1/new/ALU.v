`timescale 1ns / 1ps
module alu
#(parameter WIDTH=32)
(input [WIDTH-1:0] input1,
input [WIDTH-1:0] input2,
input [3:0] aluCtr,
output reg[WIDTH-1:0] aluRes,
output reg ZF, //0标志位, 运算结果为0(全零)则置1, 否则置0
           CF, //进借位标志位, 取最高位进位C,加法时C=1则CF=1表示有进位,减法时C=0则CF=1表示有借位
           OF, //溢出标志位，对有符号数运算有意义，溢出则OF=1，否则为0                     
           SF, //符号标志位，与F的最高位相同
           PF  //奇偶标志位，F有奇数个1，则PF=1，否则为0
);
reg C;
always @(input1 or input2 or aluCtr) // 运算数或控制码变化时操作
begin
    case(aluCtr)
        4'b0000: // 与
            aluRes = input1 & input2;
        4'b0001: // 或
            aluRes = input1 | input2;
        4'b0010: // 加
            {C,aluRes} = input1 + input2;
        4'b0011: // 左移
            aluRes = input2 << input1;
        4'b0100: //算术右移
            aluRes = input2 >>> input1;
        4'b0101: //右移
            aluRes = input2 >> input1;
        4'b0110: // 减
            {C,aluRes} = input1 - input2;
        4'b0111: // 小于设置
            aluRes=(input1<input2)? 1:0;
        4'b1000: // 异或
            aluRes = input1^input2;
        4'b1100: // 或非
            aluRes = ~(input1 | input2);        
        default:
            aluRes = 0;
    endcase
     ZF = aluRes==0;//F全为0，则ZF=1
     CF = C; //进位借位标志
     OF = input1[WIDTH-1]^input2[WIDTH-1]^aluRes[WIDTH-1]^C;//溢出标志公式
     SF = aluRes[WIDTH-1];//符号标志,取F的最高位
     PF = ~^aluRes;//奇偶标志，F有奇数个1，则F=1；偶数个1，则F=0
end
endmodule