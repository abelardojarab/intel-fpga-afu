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
// baeckler - 01-20-2010
// capture 1 pulses on the flag, and hold until acknowledged across domains

module alt_aeuex_sticky_flag (
	input flag,
	input flag_clk,
	
	input sys_clk,
	input sys_sclr,
	output sys_flag	
);

localparam SYNC_STAGES = 3;

wire flag_ack;
reg flag_launch = 1'b0 /* synthesis preserve_syn_only */
/* synthesis ALTERA_ATTRIBUTE = "-name SDC_STATEMENT \"set_false_path -from [get_keepers *alt_aeuex_sticky_flag*flag_launch]\" " */;
always @(posedge flag_clk) begin
	if (flag) flag_launch <= 1'b1;
	if (flag_ack) flag_launch <= 1'b0;
end

// move the flag over to the system domain
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS"}*) 
reg [SYNC_STAGES-1:0] flag_capture = 0 /* synthesis preserve_syn_only */;

always @(posedge sys_clk) begin
	flag_capture <= {flag_capture[SYNC_STAGES-2:0], flag_launch};
end
assign sys_flag = flag_capture[SYNC_STAGES-1];

reg sys_ack = 0 /* synthesis preserve_syn_only */;
always @(posedge sys_clk) begin
	if (sys_sclr) begin
		sys_ack <= ~sys_ack;
	end	
end

// move the acknowledge back to the flag domain
(* altera_attribute = {"-name SYNCHRONIZER_IDENTIFICATION FORCED_IF_ASYNCHRONOUS; -name SDC_STATEMENT \"set_false_path -to [get_keepers *alt_aeuex_sticky_flag*ack_capture\[0\]]\" "}*) 
reg [SYNC_STAGES-1:0] ack_capture = 0 /* synthesis preserve_syn_only */;

always @(posedge flag_clk) begin
	ack_capture <= {ack_capture[SYNC_STAGES-2:0], sys_ack};
end

wire hard_sys_ack = ack_capture[SYNC_STAGES-1];
reg last_hard_sys_ack = 1'b0;
always @(posedge flag_clk) begin
	last_hard_sys_ack <= hard_sys_ack;
end
assign flag_ack = hard_sys_ack ^ last_hard_sys_ack;

endmodule
