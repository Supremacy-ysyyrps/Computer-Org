`timescale 1ns / 1ps
module Hazard_Unit(
input [4:0] IF_ID_RS, IF_ID_RT, ID_EX_RT,
input ID_EX_MR, ZF, SF, jmp, jr,
input [1:0] branch,
output reg [3:0] reset,
output reg PCwrite, IF_ID_W
    );
initial begin reset = 4'b0000; PCwrite = 1; IF_ID_W = 1; end
//branch»°÷∏£∫01beq£¨10bne£¨11bltz
always@(*)//(IF_ID_RS or IF_ID_RT or ID_EX_MR or ID_EX_RT)
    if((branch[0]&!branch[1]&ZF)||(branch[1]&!branch[0]&!ZF)||(branch[0]&branch[1]&SF))
        begin reset = 4'b1110; PCwrite = 1; IF_ID_W = 1; end
    else if(ID_EX_MR && (ID_EX_RT == IF_ID_RS || ID_EX_RT == IF_ID_RT ))
        begin reset = 4'b0100; PCwrite = 0; IF_ID_W = 0; end
    else if(jr)
        begin reset = 4'b1100; PCwrite = 1; IF_ID_W = 1; end
    else if(jmp)
        begin reset = 4'b1000; PCwrite = 1; IF_ID_W = 1; end
    else begin reset = 4'b0000; PCwrite = 1; IF_ID_W = 1; end
endmodule