// Copyright 2012 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

// baeckler - 01-16-2012

`timescale 1ps/1ps

// DESCRIPTION
// 
// This is a low level instantiation of the Stratix 4 MLAB. Note that the inputs with _reg in the name need to
// be directly driven by registers to pass legality checking.
// 


module s4mlab #(
	parameter WIDTH = 20,
	parameter ADDR_WIDTH = 5
)
(
	input wclk,
	input wena,
	input [ADDR_WIDTH-1:0] waddr_reg,
	input [WIDTH-1:0] wdata_reg,
	input [ADDR_WIDTH-1:0] raddr,
	output [WIDTH-1:0] rdata		
);

genvar i;
generate
	for (i=0; i<WIDTH; i=i+1)  begin : ml
		stratixiv_mlab_cell lrm (
			.clk0(wclk),
			.ena0(wena),
			.portabyteenamasks(1'b1),
			.portadatain(wdata_reg[i]),
			.portaaddr(waddr_reg),
			.portbaddr(raddr),
			.portbdataout(rdata[i])
		);

		defparam lrm .mixed_port_feed_through_mode = "dont_care";
		defparam lrm .logical_ram_name = "lrm";
		defparam lrm .logical_ram_depth = 1 << ADDR_WIDTH;
		defparam lrm .logical_ram_width = WIDTH;
		defparam lrm .first_address = 0;
		defparam lrm .last_address = (1 << ADDR_WIDTH)-1;
		defparam lrm .first_bit_number = i;
		defparam lrm .data_width = 1;
		defparam lrm .address_width = ADDR_WIDTH;
	end
endgenerate

endmodule	
// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Quartus II 64-Bit Version 13.1.0 Build 162 10/23/2013 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  alt_s4mlab.v
// BENCHMARK INFO :  Total registers : N/A until Partition Merge
// BENCHMARK INFO :  Total pins : N/A until Partition Merge
// BENCHMARK INFO :  Total virtual pins : N/A until Partition Merge
// BENCHMARK INFO :  Total block memory bits : N/A until Partition Merge
