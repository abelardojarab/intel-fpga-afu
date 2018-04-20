module lpbk1_RdRspRAM2PORT (
		input  wire [533:0] data,      //  ram_input.datain
		input  wire [8:0]   wraddress, //           .wraddress
		input  wire [8:0]   rdaddress, //           .rdaddress
		input  wire         wren,      //           .wren
		input  wire         clock,     //           .clock
		output wire [533:0] q          // ram_output.dataout
	);
endmodule

