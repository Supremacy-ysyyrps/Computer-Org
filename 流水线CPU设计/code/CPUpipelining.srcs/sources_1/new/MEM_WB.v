module MEM_WB(
input clk, reset,
input [31:0] MemReadData_in, ALUOut_in, PC_add_in,
input [4:0] Rd_in,
output reg [31:0] MemReadData_out, ALUOut_out, PC_add_out,
output reg [4:0] Rd_out,
//NEXTPC
input jal_in,
output reg jal_out,
//WB
input RegWrite_in,
input MemToReg_in,
output reg RegWrite_out,
output reg MemToReg_out
);

always @(posedge clk) begin
	if (reset) begin
	    MemReadData_out = 32'b00;
        ALUOut_out = 32'b00;
        PC_add_out = 32'b00;
        Rd_out = 5'b00;
        jal_out = 1'b0;
        RegWrite_out = 1'b0;
        MemToReg_out = 1'b0;
	end
    else begin
        MemReadData_out = MemReadData_in;
        ALUOut_out = ALUOut_in;
        PC_add_out = PC_add_in;
        Rd_out = Rd_in;
        jal_out = jal_in;
        RegWrite_out = RegWrite_in;
        MemToReg_out = MemToReg_in;
    end
end
endmodule