module param_delay
(
	clock,
	reset,
	data_in,
	data_out
);
parameter 	DEPTH 	= 2;
parameter	WIDTH	= 32;

input 					clock;
input 	[WIDTH-1:0]		data_in;
input					reset;
output	[WIDTH-1:0]		data_out;

wire	[WIDTH-1:0] 	temp_wire [DEPTH:0];

assign  data_out		=	temp_wire[DEPTH];
assign 	temp_wire[0]	=	data_in;


genvar i;

generate
	for(i = 1; i<=DEPTH ;i=i+1)
		begin : generate_delay
			reg_delay #(.WIDTH(WIDTH)) REG (clock,reset,temp_wire[i-1],temp_wire[i]);
		end
endgenerate

endmodule