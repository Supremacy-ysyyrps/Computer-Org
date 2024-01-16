`timescale 1ns / 1ps
module next_pc(
input clkin,
input reset,
input PCW,
input [1:0]branch, 
input zero,
input sf,
input [31:0] expand, add41,
input jmp,
input [31:0] instruction, add42,
input jr,
input [31:0] rs,
output reg[31:0] pc,add4
);
    wire PCSrc1, PCSrc2;
    wire [31:0] J_Addr, branch_Addr;
    reg [31:0] next_pc;
    assign J_Addr =jr? rs:{add42[31:28], instruction[25:0], 2'b00};
    assign branch_Addr = add41 + (expand<<2);
    assign PCSrc2 = (jmp | jr)? 1'b1:1'b0;
    assign PCSrc1 = (branch[0]&!branch[1]&zero)||(branch[1]&!branch[0]&!zero)||(branch[0]&branch[1]&sf)? 1'b1:1'b0;
    //branchÀàÐÍ£º01beq£¬10bne£¬11bltz
    always@(*)begin
        casex({PCSrc2, PCSrc1})
            2'b00:next_pc<=add4;
            2'bx1:next_pc<=branch_Addr;
            2'b10:next_pc<=J_Addr;
            default:next_pc<=add4;
        endcase
end
initial add4=0;
always@ (posedge clkin or posedge reset)
begin
    if(reset) begin pc = 32'b0; add4 = pc+4;end
    else if(PCW) begin pc = next_pc; add4 = pc+4;end
end
endmodule