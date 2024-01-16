module aluctr(input [3:0] ALUOp, input [5:0] funct, output reg [3:0]  ALUCtr, output reg jr, output reg sham);
always @(ALUOp or funct) //  如果操作码或者功能码变化执行操作
begin
    jr=0;
    sham=0;
    casex({ALUOp, funct}) // 拼接操作码和功能码便于下一步的判断
        10'b0000xxxxxx: ALUCtr = 4'b0010; // lw，sw，addiu
        10'b0001xxxxxx: ALUCtr = 4'b0110; // beq
        10'b0010xxxxxx: ALUCtr = 4'b0001; // ori
        10'b0011xxxxxx: ALUCtr = 4'b0111; // slti
        10'b0100xxxxxx: ALUCtr = 4'b0000; // andi
        10'b0110xxxxxx: ALUCtr = 4'b0110; // bne
        10'b1011xxxxxx: ALUCtr = 4'b0011; // lui
        10'b1100xxxxxx: ALUCtr = 4'b1000; // xori
        10'b1111000000: begin ALUCtr = 4'b0011;sham=1;end// sll
        10'b1111000010: begin ALUCtr = 4'b0101;sham=1;end// srl
        10'b1111000011: begin ALUCtr = 4'b0100;sham=1;end// sra
        10'b1111000100: ALUCtr = 4'b0011; // sllv
        10'b1111000110: ALUCtr = 4'b0101; // srlv
        10'b1111000111: ALUCtr = 4'b0100; // srav
        10'b1111001000: begin ALUCtr = 4'b0000;jr=1;end // jr
        10'b1111100000: ALUCtr = 4'b0010; // add
        10'b1111100001: ALUCtr = 4'b0010; // addu
        10'b1111100010: ALUCtr = 4'b0110; // sub 
        10'b1111100011: ALUCtr = 4'b0110; // subu
        10'b1111100100: ALUCtr = 4'b0000; // and 
        10'b1111100101: ALUCtr = 4'b0001; // or
        10'b1111100110: ALUCtr = 4'b1000; // xor
        10'b1111100111: ALUCtr = 4'b1100; // nor
        10'b1111101010: ALUCtr = 4'b0111; // slt
        10'b1111101011: ALUCtr = 4'b1001; // sltu
        default:ALUCtr = 4'b0010;
    endcase
end
endmodule