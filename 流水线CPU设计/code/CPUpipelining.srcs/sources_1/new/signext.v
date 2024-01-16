`timescale 1ns / 1ps
module signext(
input [15:0] imm, // ����16λ
input ExtOp,
output [31:0] data // ���32λ
);
    assign data= imm[15:15]&ExtOp?{16'hffff,imm}:{16'h0000,imm}; 
endmodule