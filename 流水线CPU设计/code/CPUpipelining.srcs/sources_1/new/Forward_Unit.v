`timescale 1ns / 1ps
module Forward_Unit(
input EX_MEM_RW, MEM_WB_RW,
input [4:0] EX_MEM_RD, MEM_WB_RD, ID_EX_RS, ID_EX_RT,
input [31:0] rs, rt, aluout, memout,
output [31:0] FA, FB
);
reg [1:0] ForwardA, ForwardB;
initial begin ForwardA = 2'b0; ForwardB = 2'b0;end
always@(*)//(EX_MEM_RW or MEM_WB_RW or EX_MEM_RD or MEM_WB_RD or ID_EX_RS or ID_EX_RT)
    begin
        if (EX_MEM_RW && EX_MEM_RD!=0 && (EX_MEM_RD==ID_EX_RS)) ForwardA=2'b01;
            else if (MEM_WB_RW && MEM_WB_RD!=0 && (MEM_WB_RD==ID_EX_RS)) ForwardA=2'b10;
            else ForwardA=2'b00;
        if (EX_MEM_RW && EX_MEM_RD!=0 && (EX_MEM_RD==ID_EX_RT)) ForwardB=2'b01;
            else if (MEM_WB_RW && MEM_WB_RD!=0 && (MEM_WB_RD==ID_EX_RT)) ForwardB=2'b10;
            else ForwardB=2'b00;
    end
assign FA = (ForwardA==2'b00) ? rs:(ForwardA==2'b01) ? aluout:memout;
assign FB = (ForwardB==2'b00) ? rt:(ForwardB==2'b01) ? aluout:memout;
endmodule