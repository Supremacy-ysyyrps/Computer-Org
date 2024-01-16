`timescale 1ns / 1ps
module topsim; 
// Inputs 
reg clkin; 
reg reset; 
reg run;
reg step;
reg [2:0] sel1;
reg sel0;
// Instantiate the Unit Under Test (UUT) 
top uut ( 
clkin,
reset,
run,
step,
sel1,
sel0
); 
//wire reg_dst,jmp,branch, memread, memwrite, memtoreg,alu_src; 
//ire[1:0] aluop;

initial begin 
// Initialize Inputs 
reset = 1; 
run=1;
step=0;
sel1=3'b000;
sel0=0;
// Wait 100 ns for global reset to finish 
#10; 
reset = 0; 
end
parameter PERIOD = 20; 
always begin 
clkin = 1'b1; 
#(PERIOD / 2) clkin = 1'b0; 
#(PERIOD / 2) ; 
end 
endmodule 