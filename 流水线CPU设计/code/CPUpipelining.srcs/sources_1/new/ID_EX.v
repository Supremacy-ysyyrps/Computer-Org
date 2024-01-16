module ID_EX(
input clk, reset,
input [31:0] PC_add_4_in, DataBusA_in, DataBusB_in,
input [4:0] Rs_in, Rt_in, Rd_in, Shamt_in,
output reg [31:0] PC_add_4_out, DataBusA_out, DataBusB_out,
output reg [4:0] Rs_out, Rt_out, Rd_out, Shamt_out,
//NEXTPC
input jal_in,
input [1:0] branch_in,
output reg jal_out,
output reg [1:0] branch_out,
//EX
input RegDst_in, ALUSrc_in, lui_in,
input [31:0] ext_in,
input [3:0] aluop_in,
output reg RegDst_out, ALUSrc_out, lui_out,
output reg [31:0] ext_out,
output reg [3:0] aluop_out,
//MEM
input MemRead_in,MemWrite_in,
input [1:0] memflag_in,
output reg MemRead_out,MemWrite_out,
output reg [1:0] memflag_out,
//WB
input RegWrite_in,
input MemToReg_in,
output reg RegWrite_out,
output reg MemToReg_out);

always @(posedge clk) begin
	if (reset) begin
        PC_add_4_out = 32'b00;
        DataBusA_out = 32'b00;
        DataBusB_out = 32'b00;
        Rs_out = 5'b00;
        Rt_out = 5'b00;
        Rd_out = 5'b00;
        Shamt_out = 5'b00;
        jal_out = 1'b0;
        branch_out = 2'b0;
        RegDst_out = 2'b0;
        ALUSrc_out = 1'b0;
        lui_out = 1'b0;
        ext_out = 32'b0;
        aluop_out = 4'b0;
        MemRead_out = 1'b0;
        MemWrite_out = 1'b0;
        memflag_out = 2'b0;
        RegWrite_out = 1'b0;
        MemToReg_out = 1'b0;
	end
    else begin
        PC_add_4_out = PC_add_4_in;
        DataBusA_out = DataBusA_in;
        DataBusB_out = DataBusB_in;
        Rs_out = Rs_in;
        Rt_out = Rt_in;
        Rd_out = Rd_in;
        Shamt_out = Shamt_in;
        jal_out = jal_in;
        branch_out = branch_in;
        RegDst_out = RegDst_in;
        ALUSrc_out = ALUSrc_in;
        lui_out = lui_in;
        ext_out = ext_in;
        aluop_out = aluop_in;
        MemRead_out = MemRead_in;
        MemWrite_out = MemWrite_in;
        memflag_out = memflag_in;
        RegWrite_out = RegWrite_in;
        MemToReg_out = MemToReg_in;
    end
end
endmodule
