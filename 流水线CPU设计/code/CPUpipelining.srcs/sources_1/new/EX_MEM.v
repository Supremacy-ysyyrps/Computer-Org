module EX_MEM(
input clk, reset,
input [31:0] PC_add_in, ALUOut_in, DataBusB_in,
input [4:0] Rd_in,
output reg [31:0] PC_add_out, ALUOut_out, DataBusB_out,
output reg [4:0] Rd_out,
//NEXTPC
input [1:0] branch_in,
input zf_in, sf_in, jal_in,
input [31:0] ext_in,
output reg [1:0] branch_out,
output reg zf_out, sf_out, jal_out,
output reg [31:0] ext_out,
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
        PC_add_out = 32'b00;
        ALUOut_out = 32'b00;
        DataBusB_out = 32'b00;
        Rd_out = 5'b00;
        branch_out = 2'b0;
        zf_out = 1'b0;
        sf_out = 1'b0;
        jal_out = 1'b0;
        ext_out = 32'b0;
        MemRead_out = 1'b0;
        MemWrite_out = 1'b0;
        memflag_out = 2'b0;
        RegWrite_out = 1'b0;
        MemToReg_out = 1'b0;
	end
    else begin
        PC_add_out = PC_add_in;
        ALUOut_out = ALUOut_in;
        DataBusB_out = DataBusB_in;
        Rd_out = Rd_in;
        branch_out = branch_in;
        zf_out = zf_in;
        sf_out = sf_in;
        jal_out = jal_in;
        ext_out = ext_in;
        MemRead_out = MemRead_in;
        MemWrite_out = MemWrite_in;
        memflag_out = memflag_in;
        RegWrite_out = RegWrite_in;
        MemToReg_out = MemToReg_in;
    end
end
endmodule
