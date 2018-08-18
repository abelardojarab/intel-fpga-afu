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



// Jim - 09-03-2010
//
// if e...s.... & drop 1st => 0...s....
// if e...s.... & drop 2nd => e...0....

// only swap if mac dst is an individual address, not group or broadcast


`define IPV4_TYPE    16'h0800
`define MCAST_INTF   48'hffffff224001
`define MCAST_ROUTER 48'hffffff224002

`timescale 1ps/1ps

module alt_aeuex_addr_swap #(
	parameter WORDS = 5,
	parameter WIDTH = 64	
)(
	// RX from Ethernet
	input arst,
	input clk_rx,
	input swap_ipv4_en,
	input swap_mac_en,
	input drop_mcast_intf_en,
	input drop_mcast_router_en,
	input drop_mcast_all_en,
	input rx_valid,
	input [WIDTH*WORDS-1:0] rx_data,
	input [WORDS-1:0] rx_start,
	input [WORDS*8-1:0] rx_end_pos,	

	// signal after swap
	output reg rx_valid_swap,
	output wire [WIDTH*WORDS-1:0] rx_data_swap,
	output wire [WORDS-1:0] rx_start_swap,
	output wire [WORDS*8-1:0] rx_end_pos_swap	
);

reg	[WIDTH*WORDS-1:0] rx_data_p1, rx_data_p2, rx_data_p3;
reg	[WORDS-1:0] rx_start_p1, rx_start_p2, rx_start_p3;
reg	[WORDS-1:0] rx_start_p2_x;
reg	[WORDS*8-1:0] rx_end_pos_p1, rx_end_pos_p2, rx_end_pos_p3;	
reg	[WORDS*8-1:0] rx_end_pos_p2_y;

reg	[WIDTH*WORDS-1:0] rx_data_p1_swap, rx_data_p2_swap;
reg	drop_sop;
reg	drop_eop;

assign	rx_data_swap = rx_data_p3;
assign	rx_start_swap = rx_start_p3;
assign	rx_end_pos_swap = rx_end_pos_p3;

always @(posedge clk_rx) rx_valid_swap <= rx_valid;

always @(posedge clk_rx or posedge arst) begin
	if (arst) begin
		rx_data_p1 <= 0;
		rx_data_p2 <= 0;
		rx_data_p3 <= 0;
	end
	else if (rx_valid) begin
		rx_data_p1 <= rx_data;
		rx_data_p2 <= rx_data_p1_swap;
		rx_data_p3 <= rx_data_p2_swap;
	end
end

always @(posedge clk_rx or posedge arst) begin
	if (arst) begin
		rx_start_p1 <= 0;
		rx_start_p2 <= 0;
		rx_start_p3 <= 0;
	end
	else if (rx_valid) begin
		rx_start_p1 <= rx_start;
		rx_start_p2 <= rx_start_p1;
		rx_start_p3 <= drop_sop ? rx_start_p2_x : rx_start_p2;
	end
end


always @(posedge clk_rx or posedge arst) begin
	if (arst) begin
		rx_end_pos_p1 <= 0;
		rx_end_pos_p2 <= 0;
		rx_end_pos_p3 <= 0;
	end
	else if (rx_valid) begin
		rx_end_pos_p1 <= rx_end_pos;
		rx_end_pos_p2 <= rx_end_pos_p1;
		rx_end_pos_p3 <= drop_eop ? rx_end_pos_p2_y : rx_end_pos_p2;
	end
end

wire	[2*WIDTH*WORDS-1:0] buffer_2 = {rx_data_p2, rx_data_p1};

wire [ 47:0] mac_dst   [WORDS-1:0];
wire [ 47:0] mac_src   [WORDS-1:0];
wire [111:0] between   [WORDS-1:0];
wire [ 31:0] ipv4_src  [WORDS-1:0];
wire [ 31:0] ipv4_dst  [WORDS-1:0];
wire [ 15:0] ether_type[WORDS-1:0];

wire [ WORDS-1:0]  mac_mcast_intf;
wire [ WORDS-1:0]  mac_mcast_router;
wire [ WORDS-1:0]  drop_mcast;
wire [ WORDS-1:0]  dst_is_single;
wire [ WORDS-1:0]  swap_ipv4;
wire [47:0]  mac_dst_new [WORDS-1:0];
wire [47:0]  mac_src_new [WORDS-1:0];
wire [31:0]  ipv4_src_new[WORDS-1:0];
wire [31:0]  ipv4_dst_new[WORDS-1:0];

genvar i;
generate
	for (i=0; i<WORDS; i=i+1) begin : addr
		assign mac_dst[WORDS-1-i]    = buffer_2[(80-i*8)*8-1: (74-i*8)*8];
		assign mac_src[WORDS-1-i]    = buffer_2[(74-i*8)*8-1: (68-i*8)*8];
		assign between[WORDS-1-i]    = buffer_2[(68-i*8)*8-1: (54-i*8)*8];
		assign ipv4_src[WORDS-1-i]   = buffer_2[(54-i*8)*8-1: (50-i*8)*8];
		assign ipv4_dst[WORDS-1-i]   = buffer_2[(50-i*8)*8-1: (46-i*8)*8];
		assign ether_type[WORDS-1-i] = buffer_2[(68-i*8)*8-1: (66-i*8)*8];

		assign mac_mcast_intf[i]   = (mac_dst[i]==`MCAST_INTF);
		assign mac_mcast_router[i] = (mac_dst[i]==`MCAST_ROUTER);
		assign dst_is_single[i]    = (mac_dst[i][47]==0);
		assign swap_ipv4[i]        = swap_ipv4_en && (ether_type[i] == `IPV4_TYPE) && dst_is_single[i];
		assign mac_dst_new[i]      = swap_mac_en && dst_is_single[i] ?
						mac_src[i] : mac_dst[i];
		assign mac_src_new[i]      = swap_mac_en && dst_is_single[i] ? 
						mac_dst[i] : mac_src[i];
		assign ipv4_src_new[i]     = swap_ipv4[i] ? 
						ipv4_dst[i] : ipv4_src[i];
		assign ipv4_dst_new[i]     = swap_ipv4[i] ? 
						ipv4_src[i] : ipv4_dst[i];
		assign drop_mcast[WORDS-1-i]= drop_mcast_all_en && (mac_dst[WORDS-1-i][47:40]!=8'b0);
	end
endgenerate
	
wire [80*8-1:(80- 8)*8] leading3  = buffer_2[80*8-1 : (80-8)*8];
wire [80*8-1:(80-16)*8] leading2  = buffer_2[80*8-1 : (80-16)*8];
wire [80*8-1:(80-24)*8] leading1  = buffer_2[80*8-1 : (80-24)*8];
wire [80*8-1:(80-32)*8] leading0  = buffer_2[80*8-1 : (80-32)*8];

wire [46     *8-1:0] 	trailing4 = buffer_2[46*8-1     : 0];
wire [(46-8) *8-1:0] 	trailing3 = buffer_2[(46-8)*8-1 : 0];
wire [(46-16)*8-1:0] 	trailing2 = buffer_2[(46-16)*8-1: 0];
wire [(46-24)*8-1:0]    trailing1 = buffer_2[(46-24)*8-1: 0];
wire [(46-32)*8-1:0]    trailing0 = buffer_2[(46-32)*8-1: 0];

always @(posedge clk_rx or posedge arst) begin
	if (arst)				 		drop_eop <= 1'b0;
	else if (rx_valid && drop_sop)		 		drop_eop <= 1'b1;
	else if (rx_valid && (|rx_end_pos_p2 || |rx_start_p2))  drop_eop <= 1'b0; // clear if eop or sop appears
end

always @(*) begin
	if (rx_start_p2[4])	 rx_end_pos_p2_y = rx_end_pos_p2;
	else if (rx_start_p2[3]) rx_end_pos_p2_y = { 8'b0, rx_end_pos_p2[31:0]};
	else if (rx_start_p2[2]) rx_end_pos_p2_y = {16'b0, rx_end_pos_p2[23:0]};
	else if (rx_start_p2[1]) rx_end_pos_p2_y = {24'b0, rx_end_pos_p2[15:0]};
	else if (rx_start_p2[0]) rx_end_pos_p2_y = {32'b0, rx_end_pos_p2[ 7:0]};
	else			 rx_end_pos_p2_y = 40'b0;
end

always @(*) begin
	if (rx_start_p2==0) begin
		{rx_data_p2_swap, rx_data_p1_swap} = { rx_data_p2, rx_data_p1};
		rx_start_p2_x = rx_start_p2;
		drop_sop = 1'b0;
	end
	else if (rx_start_p2[0]) begin
		{rx_data_p2_swap, rx_data_p1_swap} = {
			leading0,
			mac_dst_new[0],
			mac_src_new[0],
			between[0],
			ipv4_src_new[0],
			ipv4_dst_new[0],
			trailing0};
		drop_sop = (drop_mcast_router_en && mac_mcast_router[0]) ||
			   (drop_mcast_intf_en   && mac_mcast_intf[0])   ||
			   (drop_mcast[0]);
		rx_start_p2_x = {rx_start_p2[WORDS-1: (WORDS-4)], {((WORDS-4)){1'b0}}};
	end
	else if (rx_start_p2[1]) begin
		{rx_data_p2_swap, rx_data_p1_swap} = {
			leading1,
			mac_dst_new[1],
			mac_src_new[1],
			between[1],
			ipv4_src_new[1],
			ipv4_dst_new[1],
			trailing1};
		drop_sop = (drop_mcast_router_en && mac_mcast_router[1]) ||
			   (drop_mcast_intf_en   && mac_mcast_intf[1])   ||
			   (drop_mcast[1]);
		rx_start_p2_x = {rx_start_p2[WORDS-1: (WORDS-3)], {((WORDS-3)){1'b0}}};
	end
	else if (rx_start_p2[2]) begin
		{rx_data_p2_swap, rx_data_p1_swap} = {
			leading2,
			mac_dst_new[2],
			mac_src_new[2],
			between[2],
			ipv4_src_new[2],
			ipv4_dst_new[2],
			trailing2};
		drop_sop = (drop_mcast_router_en && mac_mcast_router[2]) ||
			   (drop_mcast_intf_en   && mac_mcast_intf[2])   ||
			   (drop_mcast[2]);
		rx_start_p2_x = {rx_start_p2[WORDS-1: (WORDS-2)], {((WORDS-2)){1'b0}}};
	end
	else if (rx_start_p2[3]) begin
		{rx_data_p2_swap, rx_data_p1_swap} = {
			leading3,
			mac_dst_new[3],
			mac_src_new[3],
			between[3],
			ipv4_src_new[3],
			ipv4_dst_new[3],
			trailing3};
		drop_sop = (drop_mcast_router_en && mac_mcast_router[3]) ||
			   (drop_mcast_intf_en   && mac_mcast_intf[3])   ||
			   (drop_mcast[3]);
		rx_start_p2_x = {rx_start_p2[WORDS-1: (WORDS-1)], {((WORDS-1)){1'b0}}};
	end
	else if (rx_start_p2[4]) begin
		{rx_data_p2_swap, rx_data_p1_swap} = {
			mac_dst_new[4],
			mac_src_new[4],
			between[4],
			ipv4_src_new[4],
			ipv4_dst_new[4],
			trailing4};
		drop_sop = (drop_mcast_router_en && mac_mcast_router[4]) ||
		 	   (drop_mcast_intf_en   && mac_mcast_intf[4])   ||
			   (drop_mcast[4]);
		rx_start_p2_x = {(WORDS){1'b0}};
	end
	else begin
		{rx_data_p2_swap, rx_data_p1_swap} = { rx_data_p2, rx_data_p1};
		drop_sop = 1'b0;
		rx_start_p2_x = rx_start_p2;
	end
end	
	
endmodule
