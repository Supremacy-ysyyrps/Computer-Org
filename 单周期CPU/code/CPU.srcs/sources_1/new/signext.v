`timescale 1ns / 1ps
module signext(
input [15:0] imm, // 输入16位
input ExtOp,
output [31:0] data // 输出32位
);
    assign data= imm[15:15]&ExtOp?{16'hffff,imm}:{16'h0000,imm}; 
endmodule