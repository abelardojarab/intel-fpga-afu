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
// baeckler - 03-14-2010

module alt_aeuex_40_sample_tx_rom_2 #(
	parameter WORDS = 2,
	parameter DEVICE_FAMILY = "Stratix V"
)(
	input clk, ena,
	input idle,
	
	output reg [WORDS-1:0] dout_start,
	output reg [WORDS*8-1:0] dout_endpos,
	output reg [64*WORDS-1:0] dout	
);

wire [WORDS-1:0] dout_start_w;
wire [WORDS*8-1:0] dout_endpos_w;
wire [64*WORDS-1:0] dout_w;	

initial dout_start = 0;
initial dout_endpos = 0;
initial dout = 0;

reg [7:0] addr = 0;

always @(posedge clk) begin
	if (ena) begin
		if (idle && addr == 8'h0) addr <= 0;
		else addr <= addr + 1'b1;
	end
end

always @(posedge clk) begin
	if (ena) begin
		dout_start <= dout_start_w;
		dout_endpos <= dout_endpos_w;
		dout <= dout_w;
	end
end

// some unused surplus bits to make the byte count even
wire [5:0] discard;

altsyncram	altsyncram_component (
			.clocken0 (ena),
			.clock0 (clk),
			.address_a (addr),
			.q_a ({discard,dout_start_w,dout_endpos_w,dout_w}),
			.aclr0 (1'b0),
			.aclr1 (1'b0),
			.address_b (1'b1),
			.addressstall_a (1'b0),
			.addressstall_b (1'b0),
			.byteena_a (1'b1),
			.byteena_b (1'b1),
			.clock1 (1'b1),
			.clocken1 (1'b1),
			.clocken2 (1'b1),
			.clocken3 (1'b1),
			.data_a ({152{1'b1}}),
			.data_b (1'b1),
			.eccstatus (),
			.q_b (),
			.rden_a (1'b1),
			.rden_b (1'b1),
			.wren_a (1'b0),
			.wren_b (1'b0));
defparam
	altsyncram_component.address_aclr_a = "NONE",
	altsyncram_component.clock_enable_input_a = "NORMAL",
	altsyncram_component.clock_enable_output_a = "NORMAL",
	altsyncram_component.init_file = "alt_aeuex_40_sample_tx_rom.hex",
	altsyncram_component.intended_device_family = DEVICE_FAMILY,
	altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
	altsyncram_component.lpm_type = "altsyncram",
	altsyncram_component.numwords_a = 256,
	altsyncram_component.operation_mode = "ROM",
	altsyncram_component.outdata_aclr_a = "NONE",
	altsyncram_component.outdata_reg_a = "CLOCK0",
	altsyncram_component.ram_block_type = (DEVICE_FAMILY == "Stratix V" || DEVICE_FAMILY == "Arria 10") ? "M20K" : "M9K",
	altsyncram_component.widthad_a = 8,
	altsyncram_component.width_a = 152,
	altsyncram_component.width_byteena_a = 1;

endmodule
