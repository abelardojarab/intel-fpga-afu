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


// altera message_off 10230

`timescale 1 ps / 1 ps
// baeckler - 05-01-2014

// DESCRIPTION
// 
// This is a wrapper to simplify reading from the on die temperature sense diode and ADC. It continuously
// poles the temperature and reports in degrees Celsius and Fahrenheit. The temperature sense diode is
// only accurate within a few degrees Celsius, and may in some extreme cases be influenced by core
// switching activity. Please treat it as information only.
// 

// CONFIDENCE
// The temperature sense for A10 is not working yet.  Highly speculative.
// 

module alt_aeuex_a10_temp_sense (
	input clk, 
	output reg [7:0] degrees_c,
	output reg [7:0] degrees_f	
);

// WYS connection to sense diode ADC
wire [9:0] tsd_out;

// make sure it actually routes, out of caution for flakey new port connections
wire trst = 1'b0 /* synthesis keep */;
wire corectl = 1'b1 /* synthesis keep */;

twentynm_tsdblock tsd
(
	.corectl(corectl),
	.reset(trst),
	.tempout(tsd_out),
	.eoc()	
);

wire [9:0] tsd_out_s;
alt_aeuex_status_sync sr0 (
	.clk(clk),
	.din(tsd_out),
	.dout(tsd_out_s)
);
defparam sr0 .WIDTH = 10;

// convert valid samples to better format

reg [12:0] p0 = 13'h0;
reg [10:0] p1 = 11'h0;
reg [14:0] scaled_tsd = 15'h0;
always @(posedge clk) begin
	
	// NPP says Temp = val * (706 / 1024) - 275
	// that fraction is 1/2 + 1/8 + 1/16 + 1/512
	p0 <= {1'b0,tsd_out_s,2'b0} +
		  {3'b0,tsd_out_s};
	p1 <= {1'b0,tsd_out_s} +
		  {6'b0,tsd_out_s[9:5]};
	
	scaled_tsd <= {1'b0,p0,1'b0} + {4'b0,p1};				  
end		

reg [14:0] scaled_ofs_tsd = 15'h0;
always @(posedge clk) begin
	scaled_ofs_tsd <= scaled_tsd - {9'd275,4'b0};
end	

initial degrees_c = 0;
always @(posedge clk) begin
	degrees_c <= scaled_ofs_tsd[11:4];
end	
	
// F = C * 1.8 + 32
wire [9:0] fscaled;
alt_aeuex_times_1pt8 at0 (
	.clk(clk),
	.din(scaled_ofs_tsd[11:2]),
	.dout(fscaled)
);	
defparam at0 .WIDTH = 10;
	
initial degrees_f = 0;
always @(posedge clk) begin
	degrees_f <= fscaled[9:2] + 8'd32;
end

endmodule

// BENCHMARK INFO :  10AX115R3F40I2SGES
// BENCHMARK INFO :  Quartus II 64-Bit Version 14.0a10.0 Build 323 04/29/2014 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  alt_a10_temp_sense.v
// BENCHMARK INFO :  Uses helper file :  alt_sync_regs_m2.v
// BENCHMARK INFO :  Max depth :  2.7 LUTs
// BENCHMARK INFO :  Total registers : 65
// BENCHMARK INFO :  Total pins : 17
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  54                 
// BENCHMARK INFO :  ALMs : 30 / 427,200 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.670 ns, From degrees_c[0]~reg0, To degrees_f[7]~reg0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.475 ns, From degrees_c[5]~reg0, To degrees_f[7]~reg0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.262 ns, From degrees_c[4]~reg0, To degrees_f[7]~reg0}
