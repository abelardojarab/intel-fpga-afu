// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ps / 1 ps


module alt_e100s10_unframe #(
    parameter   LATENCY = 1
)(
	input clk,
	input [66*4-1:0] din,
	output [2*4-1:0] dout_frame_lag,
	output [64*4-1:0] dout_data	
);

wire [2*4-1:0] dout_frame;
genvar i;
generate
	for (i=0; i<4; i=i+1) begin : lp
		// split the framing and data bits
		assign 
            {dout_data[(i+1)*64-1:i*64],
             dout_frame[(i+1)*2-1:i*2]} = din[(i+1)*66-1:i*66];
    end
endgenerate	

// delay the framing bits 


reg [7:0]   dout_frame_r, dout_frame_rr;

generate

if (LATENCY == 2) begin : l2
   always @(posedge clk) dout_frame_r  <= dout_frame;
   always @(posedge clk) dout_frame_rr  <= dout_frame_r;
end else if (LATENCY == 1) begin : l1
   always @(posedge clk) dout_frame_r  <= dout_frame;
   always @(dout_frame_r) dout_frame_rr = dout_frame_r;
end

endgenerate

assign  dout_frame_lag  = dout_frame_rr;

//alt_e100s10_delay2w8 dr0 (
//	.clk(clk),
//	.din (dout_frame),
//	.dout (dout_frame_lag)
//);
//defparam dr0 .WIDTH = 2*WORDS;
//defparam dr0 .LATENCY = LATENCY;

endmodule
// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  0.0 LUTs
// BENCHMARK INFO :  Combinational ALUTs : 0
// BENCHMARK INFO :  Memory ALUTs : 0
// BENCHMARK INFO :  Dedicated logic registers : 16
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.531 ns, From delay_regs:dr0|storage[5], To delay_regs:dr0|storage[13]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.534 ns, From delay_regs:dr0|storage[6], To delay_regs:dr0|storage[14]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.536 ns, From delay_regs:dr0|storage[4], To delay_regs:dr0|storage[12]}
