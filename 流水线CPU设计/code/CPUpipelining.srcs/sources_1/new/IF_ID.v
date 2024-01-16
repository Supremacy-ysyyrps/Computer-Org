module IF_ID(
input clk,
input IF_ID_W,
input reset,
input [31:0] PC_add_4_in,
input [31:0] Instruct_in,
output reg [31:0] PC_add_4_out,
output reg [31:0] Instruct_out);

    always @(posedge clk) begin
        if (reset) begin
            PC_add_4_out = 32'b00;
            Instruct_out = 32'b00;
        end
        else if(IF_ID_W) begin
            PC_add_4_out = PC_add_4_in;
            Instruct_out = Instruct_in;
        end
	end
endmodule