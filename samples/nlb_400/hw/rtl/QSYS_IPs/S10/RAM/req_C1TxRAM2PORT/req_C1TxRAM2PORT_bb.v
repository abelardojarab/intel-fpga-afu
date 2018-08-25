module req_C1TxRAM2PORT (
		input  wire [555:0] data,      //  ram_input.datain
		input  wire [8:0]   wraddress, //           .wraddress
		input  wire [8:0]   rdaddress, //           .rdaddress
		input  wire         wren,      //           .wren
		input  wire         clock,     //           .clock
		output wire [555:0] q          // ram_output.dataout
	);
endmodule

