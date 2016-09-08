module reg_delay 
(
	clk,
	rst,
	din,
	dout
);

parameter 		WIDTH = 32;

input 					clk;
input					rst;
input	[WIDTH-1:0]		din;
output 	[WIDTH-1:0]		dout;

reg 	[WIDTH-1:0]		dout;

always @(posedge clk)
begin
	if(rst)
		dout	<= 0;
	else
		dout	<=	din;
end
endmodule
