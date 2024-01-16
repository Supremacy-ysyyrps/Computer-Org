module DM_unit(input clk, Wr, reset,
              input [1:0] memflag,
              input [7:0] a,
		      input [31:0] wd,
			  output [31:0] rd);
reg [7:0] RAM[255:0];
//read
assign rd=memflag[1]? {{RAM[a+3]},{RAM[a+2]},{RAM[a+1]},{RAM[a+0]}} : ( memflag[0]?{{16{RAM[a+1][7]}},{RAM[a+1]},{RAM[a]}}:{{24{RAM[a][7]}},RAM[a]});
//write
integer i;
always @ (posedge clk,posedge reset)
begin
    if(reset)
        begin
            for(i = 0; i < 256; i = i + 1) 
                RAM[i]=0;
        end
    else if (Wr)
        begin
            if(memflag==2'b00)
                RAM[a]=wd[7:0];
            else if(memflag==2'b01)
                {{RAM[a+1]},{RAM[a]}}=wd[15:0];
            else if(memflag==2'b11 )
                {{RAM[a+3]},{RAM[a+2]},{RAM[a+1]},{RAM[a+0]}}=wd;
        end
end
endmodule