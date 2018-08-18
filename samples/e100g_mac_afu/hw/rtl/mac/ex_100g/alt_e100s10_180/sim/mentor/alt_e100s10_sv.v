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


// 25G/50G/100G Statistics Vector Module
// latency: 10 cycles from eop
// 06/01/2017

//----------------------------------
// assumption: there is atmost one sop and one eop happens in each input frm_data;
//----------------------------------

`timescale 1ps/1ps

module alt_e100s10_sv #
(
    parameter   SIM_EMULATE = 1'b0,     
    parameter   SYNOPT_PREAMBLE_PT = 1'b0,  // do not change
    parameter   WORDS = 4,   		// 4 for 100G, 2 for 50G, 1 for 25G
    parameter   PLD_DUALCHK = 1'b0  // payload dual check
) (
    input                           clk,    // clock_port pragma
    input                           reset,

    //---CSR if---
    input                           cfg_crc_included,
    input  [15:0]                   cfg_max_frm_length,
    input                           cfg_vlandet_disable,
   
    //---data path if---
    input   [WORDS*64-1:0]          frm_data,
    input   [WORDS-1:0]             frm_sop,    // points to preamble byte if PREAMBLE_PT=1;
    input   [WORDS-1:0]             frm_eop,
    input                           frm_valid,
    input   [WORDS*3-1:0]           frm_eop_empty,
    
    //---stats output---
    output  [41:0]                  stats,
    output                          stats_valid,
    output  [2:0]                   frm_error
);

//------------------------------
// Header Extraction
//------------------------------
reg [WORDS*64-1:0]	data_d1;
reg [64-1:0]		w0_d2, w1_d2, w2_d2;
wire [63:0]		w0_d2_rev, w1_d2_rev, w2_d2_rev;
reg [63:0]		w0_d3_rev, w1_d3_rev, w2_d3_rev;

reg [WORDS-1:0]		sop_d1_0 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_1 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_2 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_3 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_4 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_5 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_6 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_7 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_8 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_9 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_10 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_11 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_12 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		sop_d1_13 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		eop_d1_0 /*synthesis preserve_syn_only */;
reg [WORDS-1:0]		eop_d1_1 /*synthesis preserve_syn_only */;
reg			has_sop_d1, has_eop_d1;	
reg	sop_only_d1, eop_only_d1, sop_eop_d1;
reg	eop_sop_d1, eop_sop_d2, eop_sop_d3, eop_sop_d4;
reg	vld_sop_d2, vld_sop_d3;
reg	vld_eop_d2, vld_eop_d3, vld_eop_d4, vld_eop_d5, vld_eop_d6, vld_eop_d7, vld_eop_d8, vld_eop_d9, vld_eop_d10;
reg	invalid_sop_d1, invalid_eop_d1;
reg	frm_vld_d1;
reg	shft_sop_d1_t;

//------------------------------
reg [7:0]	rst_l /* synthesis preserve_syn_only */;
always @ (posedge clk)	rst_l <= {8{reset}};

wire frm_vld_i = frm_valid;	// & ~rst_l[0];
reg  frm_sop_r0;
wire [3:0] frm_sop_psthr = (SYNOPT_PREAMBLE_PT==0) ? frm_sop : {frm_sop_r0, frm_sop[3:1]};

always @ (posedge clk) begin
  if (rst_l[1]) begin
	frm_sop_r0 <= 1'b0;
	sop_d1_0  <= 4'h0;
	sop_d1_1  <= 4'h0;
	sop_d1_2  <= 4'h0;
	sop_d1_3  <= 4'h0;
	sop_d1_4  <= 4'h0;
	sop_d1_5  <= 4'h0;
	sop_d1_6  <= 4'h0;
	sop_d1_7  <= 4'h0;
	sop_d1_8  <= 4'h0;
	sop_d1_9  <= 4'h0;
	sop_d1_10 <= 4'h0;
	sop_d1_11 <= 4'h0;
	sop_d1_12 <= 4'h0;
	sop_d1_13 <= 4'h0;
	eop_d1_0  <= 4'h0;
	eop_d1_1  <= 4'h0;
	has_sop_d1  <= 1'b0;
	has_eop_d1  <= 1'b0;
  end else if (frm_vld_i) begin
	frm_sop_r0 <= frm_sop[0];
	sop_d1_0  <= frm_sop_psthr;
	sop_d1_1  <= frm_sop_psthr;
	sop_d1_2  <= frm_sop_psthr;
	sop_d1_3  <= frm_sop_psthr;
	sop_d1_4  <= frm_sop_psthr;
	sop_d1_5  <= frm_sop_psthr;
	sop_d1_6  <= frm_sop_psthr;
	sop_d1_7  <= frm_sop_psthr;
	sop_d1_8  <= frm_sop_psthr;
	sop_d1_9  <= frm_sop_psthr;
	sop_d1_10 <= frm_sop_psthr;
	sop_d1_11 <= frm_sop_psthr;
	sop_d1_12 <= frm_sop_psthr;
	sop_d1_13 <= frm_sop_psthr;
	eop_d1_0  <= frm_eop;
	eop_d1_1  <= frm_eop;
	has_sop_d1  <= |frm_sop_psthr;
	has_eop_d1  <= |frm_eop;
  end else begin
	eop_d1_0  <= 4'h0;
	eop_d1_1  <= 4'h0;
	has_eop_d1  <= 1'b0;
  end
  if (frm_vld_i) 	data_d1 <= frm_data;
  frm_vld_d1 <= frm_vld_i;
end

always @ (posedge clk) begin
  if (rst_l[2]) begin
	sop_only_d1 <= 1'b0;
	eop_only_d1 <= 1'b0;
	sop_eop_d1  <= 1'b0;
	eop_sop_d1  <= 1'b0;
  end else if (frm_vld_i) begin
	sop_only_d1 <= (|frm_sop_psthr) & ~(|frm_eop);
	eop_only_d1 <= ~(|frm_sop_psthr) & (|frm_eop);
	sop_eop_d1  <= (|frm_sop_psthr) & (|frm_eop) & (frm_sop_psthr > frm_eop);
	eop_sop_d1  <= (|frm_sop_psthr) & (|frm_eop) & (frm_sop_psthr < frm_eop);
  end
	shft_sop_d1_t  <= (|frm_sop_psthr) & (|frm_eop) & (frm_sop_psthr > frm_eop) & frm_vld_i;
end

wire vld_sop_d1 = (sop_only_d1 | sop_eop_d1 | eop_sop_d1) & ~invalid_sop_d1;
wire vld_eop_d1 = (|eop_d1_1) & ~invalid_eop_d1;
wire shft_sop_d1 = frm_vld_i | shft_sop_d1_t;

always @ (posedge clk) begin
	vld_sop_d2 <= vld_sop_d1 & shft_sop_d1;
	vld_sop_d3 <= vld_sop_d2;
end

wire latch_sop_d2 = vld_sop_d2;
wire latch_type_d3 = vld_sop_d3;

always @(posedge clk) begin
	vld_eop_d2 <= vld_eop_d1;
	vld_eop_d3 <= vld_eop_d2;
	vld_eop_d4 <= vld_eop_d3;
	vld_eop_d5 <= vld_eop_d4;
	vld_eop_d6 <= vld_eop_d5;
	vld_eop_d7 <= vld_eop_d6;
	vld_eop_d8 <= vld_eop_d7;
	vld_eop_d9 <= vld_eop_d8;
	vld_eop_d10 <= vld_eop_d9;
	eop_sop_d2  <= eop_sop_d1;
	eop_sop_d3  <= eop_sop_d2;
	eop_sop_d4  <= eop_sop_d3;
end

generate 
  if (WORDS == 4) begin
	always @ (posedge clk) begin
		invalid_sop_d1 <= ((frm_sop_psthr[3] + frm_sop_psthr[2] + frm_sop_psthr[1] + frm_sop_psthr[0]) >= 2) & frm_vld_i;
		invalid_eop_d1 <= ((frm_eop[3] + frm_eop[2] + frm_eop[1] + frm_eop[0]) >= 2) & frm_vld_i;
	end
  end else if (WORDS == 2) begin
	always @ (posedge clk) begin
		invalid_sop_d1 <= frm_sop_psthr[1] & frm_sop_psthr[0] & frm_vld_i;
		invalid_eop_d1 <= frm_eop[1] & frm_eop[0] & frm_vld_i;
	end
  end else begin
	always @ (posedge clk) begin
		invalid_sop_d1 <= 1'b0;
		invalid_eop_d1 <= 1'b0;
	end
  end
endgenerate

reg	invld_sop_d2, invld_sop_d3, invld_sop_d4, invld_sop_d5, invld_sop_d6, invld_sop_d7, invld_sop_d8, invld_sop_d9, invld_sop_d10;
reg	invld_eop_d2, invld_eop_d3, invld_eop_d4, invld_eop_d5, invld_eop_d6, invld_eop_d7, invld_eop_d8, invld_eop_d9, invld_eop_d10;
always @(posedge clk) begin
	invld_sop_d2 <= invalid_sop_d1;
	invld_sop_d3 <= invld_sop_d2;
	invld_sop_d4 <= invld_sop_d3;
	invld_sop_d5 <= invld_sop_d4;
	invld_sop_d6 <= invld_sop_d5;
	invld_sop_d7 <= invld_sop_d6;
	invld_sop_d8 <= invld_sop_d7;
	invld_sop_d9 <= invld_sop_d8;
	invld_sop_d10 <= invld_sop_d9;

	invld_eop_d2 <= invalid_eop_d1;
	invld_eop_d3 <= invld_eop_d2;
	invld_eop_d4 <= invld_eop_d3;
	invld_eop_d5 <= invld_eop_d4;
	invld_eop_d6 <= invld_eop_d5;
	invld_eop_d7 <= invld_eop_d6;
	invld_eop_d8 <= invld_eop_d7;
	invld_eop_d9 <= invld_eop_d8;
	invld_eop_d10 <= invld_eop_d9;
end

//---------------------------
generate 
  if (WORDS == 4) begin
	always @ (posedge clk) begin
	    if (shft_sop_d1) begin
		if (sop_d1_0[3])		w0_d2[15:0] <= data_d1[3*64+15 : 3*64];
		else if (sop_d1_0[2])		w0_d2[15:0] <= data_d1[2*64+15 : 2*64];
		else if (sop_d1_0[1])		w0_d2[15:0] <= data_d1[64+15 : 64];
		else if (sop_d1_0[0])		w0_d2[15:0] <= data_d1[15 : 0];
		if (sop_d1_1[3])		w0_d2[31:16] <= data_d1[3*64+31 : 3*64+16];
		else if (sop_d1_1[2])		w0_d2[31:16] <= data_d1[2*64+31 : 2*64+16];
		else if (sop_d1_1[1])		w0_d2[31:16] <= data_d1[64+31 : 64+16];
		else if (sop_d1_1[0])		w0_d2[31:16] <= data_d1[31 : 16];
		if (sop_d1_2[3])		w0_d2[47:32] <= data_d1[3*64+47 : 3*64+32];
		else if (sop_d1_2[2])		w0_d2[47:32] <= data_d1[2*64+47 : 2*64+32];
		else if (sop_d1_2[1])		w0_d2[47:32] <= data_d1[64+47 : 64+32];
		else if (sop_d1_2[0])		w0_d2[47:32] <= data_d1[47 : 32];
		if (sop_d1_3[3])		w0_d2[63:48] <= data_d1[3*64+63 : 3*64+48];
		else if (sop_d1_3[2])		w0_d2[63:48] <= data_d1[2*64+63 : 2*64+48];
		else if (sop_d1_3[1])		w0_d2[63:48] <= data_d1[64+63 : 64+48];
		else if (sop_d1_3[0])		w0_d2[63:48] <= data_d1[63 : 48];

		if (sop_d1_4[3])		w1_d2[15:0]  <=  data_d1[2*64+15 : 2*64];
		else if (sop_d1_4[2])		w1_d2[15:0]  <=  data_d1[  64+15 :   64];
		else if (sop_d1_4[1])		w1_d2[15:0]  <=  data_d1[     15 :    0];
		else if (sop_d1_4[0])		w1_d2[15:0]  <= frm_data[3*64+15 : 3*64];
		if (sop_d1_5[3])		w1_d2[31:16] <=  data_d1[2*64+31 : 2*64+16];
		else if (sop_d1_5[2])		w1_d2[31:16] <=  data_d1[  64+31 :   64+16];
		else if (sop_d1_5[1])		w1_d2[31:16] <=  data_d1[     31 :      16];
		else if (sop_d1_5[0])		w1_d2[31:16] <= frm_data[3*64+31 : 3*64+16];
		if (sop_d1_6[3])		w1_d2[47:32] <=  data_d1[2*64+47 : 2*64+32];
		else if (sop_d1_6[2])		w1_d2[47:32] <=  data_d1[  64+47 :   64+32];
		else if (sop_d1_6[1])		w1_d2[47:32] <=  data_d1[     47 :      32];
		else if (sop_d1_6[0])		w1_d2[47:32] <= frm_data[3*64+47 : 3*64+32];
		if (sop_d1_7[3])		w1_d2[63:48] <=  data_d1[2*64+63 : 2*64+48];
		else if (sop_d1_7[2])		w1_d2[63:48] <=  data_d1[  64+63 :   64+48];
		else if (sop_d1_7[1])		w1_d2[63:48] <=  data_d1[     63 :      48];
		else if (sop_d1_7[0])		w1_d2[63:48] <= frm_data[3*64+63 : 3*64+48];

		if (sop_d1_8[3])		w2_d2[15:0] <=  data_d1[  64+15 :   64];
		else if (sop_d1_8[2])		w2_d2[15:0] <=  data_d1[     15 :    0];
		else if (sop_d1_8[1])		w2_d2[15:0] <= frm_data[3*64+15 : 3*64];
		else if (sop_d1_8[0])		w2_d2[15:0] <= frm_data[2*64+15 : 2*64];
		if (sop_d1_9[3])		w2_d2[31:16] <=  data_d1[  64+31 :   64+16];
		else if (sop_d1_9[2])		w2_d2[31:16] <=  data_d1[     31 :      16];
		else if (sop_d1_9[1])		w2_d2[31:16] <= frm_data[3*64+31 : 3*64+16];
		else if (sop_d1_9[0])		w2_d2[31:16] <= frm_data[2*64+31 : 2*64+16];
		if (sop_d1_10[3])		w2_d2[47:32] <=  data_d1[  64+47 :   64+32];
		else if (sop_d1_10[2])		w2_d2[47:32] <=  data_d1[     47 :      32];
		else if (sop_d1_10[1])		w2_d2[47:32] <= frm_data[3*64+47 : 3*64+32];
		else if (sop_d1_10[0])		w2_d2[47:32] <= frm_data[2*64+47 : 2*64+32];
		if (sop_d1_11[3])		w2_d2[63:48] <=  data_d1[  64+63 :   64+48];
		else if (sop_d1_11[2])		w2_d2[63:48] <=  data_d1[     63 :      48];
		else if (sop_d1_11[1])		w2_d2[63:48] <= frm_data[3*64+63 : 3*64+48];
		else if (sop_d1_11[0])		w2_d2[63:48] <= frm_data[2*64+63 : 2*64+48];
	    end
	end
  end else if (WORDS == 2) begin
	always @ (posedge clk) begin
	    if (shft_sop_d1) begin
		if (sop_d1_0[1])		w0_d2 <= data_d1[2*64-1 : 64];
		else if (sop_d1_0[0])		w0_d2 <= data_d1[64-1 : 0];

		if (sop_d1_1[1])		w1_d2 <= data_d1[64-1 : 0];
		else if (sop_d1_1[0])		w1_d2 <= frm_data[2*64-1 : 1*64];

		if (sop_d1_2[1])		w2_d2 <= frm_data[2*64-1 : 1*64];
		else if (sop_d1_2[0])		w2_d2 <= frm_data[64-1 : 0];
	    end
	end
  end else begin
	always @ (posedge clk) begin
	    if (shft_sop_d1) begin
		if (sop_d1_0[0])		w0_d2 <= data_d1[63:0];
		if (sop_d1_1[0])		w1_d2 <= frm_data[63:0];
		w2_d2 <= 64'h0;		// not used; no loads;
	    end
	end
  end
endgenerate

genvar i, j;
generate
  if (WORDS == 1) begin
	for (i=0; i<8; i=i+1) begin :rev
            assign w0_d2_rev[(i*8) +: 8] = w0_d2[(63-i*8) -: 8 ];
            assign w1_d2_rev[(i*8) +: 8] = w1_d2[(63-i*8) -: 8 ];
            assign w2_d2_rev[(i*8) +: 8] = frm_data[(63-i*8) -: 8 ];
	end
  end else begin
	for (i=0; i<8; i=i+1) begin :rev
            assign w0_d2_rev[(i*8) +: 8] = w0_d2[(63-i*8) -: 8 ];
            assign w1_d2_rev[(i*8) +: 8] = w1_d2[(63-i*8) -: 8 ];
            assign w2_d2_rev[(i*8) +: 8] = w2_d2[(63-i*8) -: 8 ];
	end
  end
endgenerate

always @ (posedge clk) begin
  if (latch_sop_d2) begin
	w0_d3_rev	<= w0_d2_rev;
	w1_d3_rev	<= w1_d2_rev;
	w2_d3_rev	<= w2_d2_rev;
  end
end

//------------------------------
// Header Processing
// Extracting information for downstream processing
//------------------------------
  // regular packet headers 
  //            : EthTyp = Bytes[13,14], 
  //            : OpCode = Bytes[15,16]
  // vlan tagged packet headers 
  //            : VlanTag = Bytes[13,14] 
  //            : EthType = Bytes[17,18]

  // svlan tagged packet headers 
  //            : VLanTag = Bytes[13,14] 
  //            : SVLanTag= Bytes[17,18] 
  //            : EthType = Bytes[21,22]

localparam SBYTE_DEST_ADDR = 0, EBYTE_DEST_ADDR = 6;
localparam SBYTE_NORM_TLEN = 12-8, EBYTE_NORM_TLEN = 14-8; 
localparam SBYTE_CTRL_TLEN = 14-8, EBYTE_CTRL_TLEN = 16-8;
localparam SBYTE_VLAN_TLEN = 16-16, EBYTE_VLAN_TLEN = 18-16; 
localparam SBYTE_SVLAN_TLEN = 20-16, EBYTE_SVLAN_TLEN = 22-16; 

wire[47:0] valid_dest_addr_d3 = w0_d3_rev [EBYTE_DEST_ADDR*8 -1 : SBYTE_DEST_ADDR*8 ];

wire[15:0] valid_norm_tlen_d3 = w1_d3_rev [EBYTE_NORM_TLEN*8 -1 : SBYTE_NORM_TLEN*8 ];  
wire[7:0] valid_norm_tlen_hi_d3 = w1_d3_rev [(EBYTE_NORM_TLEN-1)*8 -1 : SBYTE_NORM_TLEN*8 ]; 
wire[7:0] valid_norm_tlen_lo_d3 = w1_d3_rev [EBYTE_NORM_TLEN*8 -1 : (SBYTE_NORM_TLEN+1)*8 ]; 

//wire[15:0] valid_ctrl_opcd_d3 = w1_d3_rev [EBYTE_CTRL_TLEN*8 -1 : SBYTE_CTRL_TLEN*8 ]; 
wire[7:0] valid_ctrl_opcd_hi_d3 = w1_d3_rev [(EBYTE_CTRL_TLEN-1)*8 -1 : SBYTE_CTRL_TLEN*8 ];
wire[7:0] valid_ctrl_opcd_lo_d3 = w1_d3_rev [EBYTE_CTRL_TLEN*8 -1 : (SBYTE_CTRL_TLEN+1)*8 ];

wire[15:0] valid_rvln_tlen_d3 = w2_d3_rev [EBYTE_VLAN_TLEN*8-1 : SBYTE_VLAN_TLEN*8 ]; 
wire[7:0] valid_rvln_tlen_hi_d3 = w2_d3_rev [(EBYTE_VLAN_TLEN-1)*8 -1 : SBYTE_VLAN_TLEN*8 ];
wire[7:0] valid_rvln_tlen_lo_d3 = w2_d3_rev [EBYTE_VLAN_TLEN*8 -1 : (SBYTE_VLAN_TLEN+1)*8 ];

//wire [15:0] valid_svln_tlen_d3 = w2_d3_rev[EBYTE_SVLAN_TLEN*8-1 : SBYTE_SVLAN_TLEN*8 ];
wire[7:0] valid_svln_tlen_hi_d3 = w2_d3_rev [(EBYTE_SVLAN_TLEN-1)*8-1 : SBYTE_SVLAN_TLEN*8];
wire[7:0] valid_svln_tlen_lo_d3 = w2_d3_rev [EBYTE_SVLAN_TLEN*8-1 : (SBYTE_SVLAN_TLEN+1)*8];


wire valid_type_ctrl_0_d3 = (valid_norm_tlen_d3[5:0]   == 6'b001000); //8808
wire valid_type_ctrl_1_d3 = (valid_norm_tlen_d3[11:6]  == 6'b100010);
wire valid_type_ctrl_2_d3 = (valid_norm_tlen_d3[15:12] == 4'b0000);

wire valid_type_rvln_0_d3 = (valid_norm_tlen_d3[5:0]   == 6'b000001); //8100
wire valid_type_rvln_1_d3 = (valid_norm_tlen_d3[11:6]  == 6'b000010);
wire valid_type_rvln_2_d3 = (valid_norm_tlen_d3[15:12] == 4'b0000);

wire valid_type_svln_0_d3 = (valid_rvln_tlen_d3[5:0]   == 6'b000001); //8100
wire valid_type_svln_1_d3 = (valid_rvln_tlen_d3[11:6]  == 6'b000010);
wire valid_type_svln_2_d3 = (valid_rvln_tlen_d3[15:12] == 4'b0000);


//----------------------------------------------------
reg [47:0]  pkt_da_d4;
reg [15:0]  pkt_opcd_d4;
reg [15:0]  pkt_norm_tlen_d4, pkt_rvln_tlen_d4, pkt_svln_tlen_d4;
reg         pkt_type_ctrl_0_d4, pkt_type_ctrl_1_d4, pkt_type_ctrl_2_d4;
reg         pkt_type_rvln_0_d4, pkt_type_rvln_1_d4, pkt_type_rvln_2_d4;
reg         pkt_type_svln_0_d4, pkt_type_svln_1_d4, pkt_type_svln_2_d4;

always @(posedge clk) begin 
    if (rst_l[5]) begin
        pkt_type_ctrl_0_d4 <= 1'b0;
        pkt_type_ctrl_1_d4 <= 1'b0;
        pkt_type_ctrl_2_d4 <= 1'b0;
        pkt_type_rvln_0_d4 <= 1'b0;
        pkt_type_rvln_1_d4 <= 1'b0;
        pkt_type_rvln_2_d4 <= 1'b0;
        pkt_type_svln_0_d4 <= 1'b0;
        pkt_type_svln_1_d4 <= 1'b0;
        pkt_type_svln_2_d4 <= 1'b0;
    end else if (latch_type_d3) begin
        pkt_type_ctrl_0_d4 <= valid_type_ctrl_0_d3;
        pkt_type_ctrl_1_d4 <= valid_type_ctrl_1_d3;
        pkt_type_ctrl_2_d4 <= valid_type_ctrl_2_d3;
        pkt_type_rvln_0_d4 <= valid_type_rvln_0_d3;
        pkt_type_rvln_1_d4 <= valid_type_rvln_1_d3;
        pkt_type_rvln_2_d4 <= valid_type_rvln_2_d3;
        pkt_type_svln_0_d4 <= valid_type_svln_0_d3;
        pkt_type_svln_1_d4 <= valid_type_svln_1_d3;
        pkt_type_svln_2_d4 <= valid_type_svln_2_d3;
    end

	pkt_da_d4          <=  valid_dest_addr_d3;
	pkt_opcd_d4        <=  {valid_ctrl_opcd_hi_d3, valid_ctrl_opcd_lo_d3};
	pkt_norm_tlen_d4   <= {valid_norm_tlen_hi_d3, valid_norm_tlen_lo_d3};
	pkt_rvln_tlen_d4   <= {valid_rvln_tlen_hi_d3, valid_rvln_tlen_lo_d3};
	pkt_svln_tlen_d4   <= {valid_svln_tlen_hi_d3, valid_svln_tlen_lo_d3};
end
    
wire	pkt_type_ctrl_d4 = pkt_type_ctrl_0_d4 & pkt_type_ctrl_1_d4 & pkt_type_ctrl_2_d4;
wire	pkt_type_rvln_d4 = pkt_type_rvln_0_d4 & pkt_type_rvln_1_d4 & pkt_type_rvln_2_d4;
wire	pkt_type_svln_d4 = pkt_type_svln_0_d4 & pkt_type_svln_1_d4 & pkt_type_svln_2_d4;

reg	pkt_type_ctrl_d4_r, pkt_type_rvln_d4_r, pkt_type_svln_d4_r;
reg [47:0]  pkt_da_d4_r;
reg [15:0]  pkt_opcd_d4_r;
reg [15:0]  pkt_norm_tlen_d4_r, pkt_rvln_tlen_d4_r, pkt_svln_tlen_d4_r;
always @(posedge clk) begin
	pkt_da_d4_r <= pkt_da_d4;
	pkt_opcd_d4_r <= pkt_opcd_d4;
	pkt_type_ctrl_d4_r <= pkt_type_ctrl_d4;
	pkt_type_rvln_d4_r <= pkt_type_rvln_d4;
	pkt_type_svln_d4_r <= pkt_type_svln_d4;
	pkt_norm_tlen_d4_r <=  pkt_norm_tlen_d4;
	pkt_rvln_tlen_d4_r <=  pkt_rvln_tlen_d4;
	pkt_svln_tlen_d4_r <=  pkt_svln_tlen_d4;
end

//------------------------------
// decode the packet type
//------------------------------
// XCast Decoding
// Pause & Control Frame decoding
// SVLAN/VLAN frame decoding

reg last_40_d5, addr_bcast_hi_d5, addr_bcast_lo_d5;
reg pkt_type_ctrl_d5, pkt_opcd_sfc_d5, pkt_opcd_pfc_d5;
reg pkt_type_rvln_d5, pkt_type_svln_d5;
reg [15:0]  pkt_norm_tlen_d5, pkt_rvln_tlen_d5, pkt_svln_tlen_d5;

wire [23:0] pkt_da_lo_d4 = pkt_da_d4[23:0];
wire [23:0] pkt_da_hi_d4 = pkt_da_d4[47:24];
wire [23:0] pkt_da_lo_d4_r = pkt_da_d4_r[23:0];
wire [23:0] pkt_da_hi_d4_r = pkt_da_d4_r[47:24];

always @(posedge clk) begin
   if (eop_sop_d4) begin	// eop first, then sop in same cycle; the values are for next pkt; use previous value;
	last_40_d5 <= pkt_da_d4_r[0];
	addr_bcast_lo_d5 <= &pkt_da_lo_d4_r;
	addr_bcast_hi_d5 <= &pkt_da_hi_d4_r;
	pkt_type_ctrl_d5 <= pkt_type_ctrl_d4_r;
	pkt_opcd_sfc_d5  <= (pkt_opcd_d4_r == 16'h0001); 
	pkt_opcd_pfc_d5  <= (pkt_opcd_d4_r == 16'h0101); 
	pkt_type_rvln_d5 <=  pkt_type_rvln_d4_r & ~pkt_type_svln_d4_r;  
	pkt_type_svln_d5 <=  pkt_type_rvln_d4_r & pkt_type_svln_d4_r;  

	pkt_norm_tlen_d5   <=  pkt_norm_tlen_d4_r;
	pkt_rvln_tlen_d5   <=  pkt_rvln_tlen_d4_r;
	pkt_svln_tlen_d5   <=  pkt_svln_tlen_d4_r;
   end else begin
	last_40_d5 <= pkt_da_d4[0];
	addr_bcast_lo_d5 <= &pkt_da_lo_d4;
	addr_bcast_hi_d5 <= &pkt_da_hi_d4;
	pkt_type_ctrl_d5 <= pkt_type_ctrl_d4;
	pkt_opcd_sfc_d5  <= (pkt_opcd_d4 == 16'h0001); 
	pkt_opcd_pfc_d5  <= (pkt_opcd_d4 == 16'h0101); 
	pkt_type_rvln_d5 <=  pkt_type_rvln_d4 & ~pkt_type_svln_d4;  
	pkt_type_svln_d5 <=  pkt_type_rvln_d4 & pkt_type_svln_d4;  

	pkt_norm_tlen_d5   <=  pkt_norm_tlen_d4;
	pkt_rvln_tlen_d5   <=  pkt_rvln_tlen_d4;
	pkt_svln_tlen_d5   <=  pkt_svln_tlen_d4;
   end
end

wire pkt_addr_bcast_d5 = addr_bcast_hi_d5 & addr_bcast_lo_d5;
wire pkt_addr_mcast_d5 = last_40_d5 & ~pkt_addr_bcast_d5;
wire pkt_addr_ucast_d5 = ~last_40_d5;
wire pkt_ctrl_pause_d5 = pkt_type_ctrl_d5 & pkt_opcd_sfc_d5;
wire pkt_ctrl_pfc_d5   = pkt_type_ctrl_d5 & pkt_opcd_pfc_d5;

reg dp_addr_mcast_d6, dp_addr_bcast_d6, dp_addr_ucast_d6;
reg dp_ctrl_d6, dp_ctrl_pfc_d6, dp_opcd_pause_d6;
reg dp_ptype_rvln_d6, dp_ptype_svln_d6;

// pkt_*_d5 should be ready first; then vld_eop_d5 be valid;
always @(posedge clk) begin
	dp_addr_bcast_d6 <= pkt_addr_bcast_d5 & vld_eop_d5;
	dp_addr_mcast_d6 <= pkt_addr_mcast_d5 & vld_eop_d5;
	dp_addr_ucast_d6 <= pkt_addr_ucast_d5 & vld_eop_d5;
	dp_ctrl_d6       <= pkt_type_ctrl_d5 & vld_eop_d5;
	dp_ctrl_pfc_d6   <= pkt_ctrl_pfc_d5 & vld_eop_d5;
	dp_opcd_pause_d6 <= pkt_ctrl_pause_d5 & vld_eop_d5;
	// CC-6 (earliest)
	dp_ptype_rvln_d6 <= pkt_type_rvln_d5 & vld_eop_d5;
	dp_ptype_svln_d6 <= pkt_type_svln_d5 & vld_eop_d5;
end

//------------------------------------------
//------------------------------------------
// Payload/Frame length  Calculation
//------------------------------------------
//------------------------------------------
// count the active #clocks and shift it by 3 or 4 depending on word width.
// This will give a coarse value. Refine it with eop empty, sop & packet header type info

// counting valid frame cycles
reg [12:0]   vld_cyc_cnt, vld_cyc_cnt_d2;
wire [16:0]   pld_bcnt_d2;
reg [16:0]   pld_bcnt_d3, pld_bcnt_d4, pld_bcnt_d5, pld_bcnt_d6, pld_bcnt_d7, pld_bcnt_d8_17bit;

always @(posedge clk) begin
  if (rst_l[6])				vld_cyc_cnt <= 13'h0;
  else if (frm_vld_d1 & has_sop_d1)	vld_cyc_cnt <= 13'h0;
  else if (frm_vld_d1 & ~has_eop_d1)	// start with next cycle from sop;
	vld_cyc_cnt <= vld_cyc_cnt + 1'b1;

  if (frm_vld_d1 & has_eop_d1) begin
	if (sop_eop_d1)		vld_cyc_cnt_d2 <= 13'h0;
	else			vld_cyc_cnt_d2 <= vld_cyc_cnt;
  end
end

// sop/eop data byte counts;
reg [5:0]	eop_bcnt_d2, eop_bcnt_d3;
reg [5:0]	sop_bcnt_d2, sop_bcnt_d3;

reg [2:0]	eop_blk_bcnt_d1;	// one byte less than byte counts in eop blck (64bits);
//reg [5:0]	sop_eop_bcnt_d2;	// total byte counts for sop and eop cycles (combine both sop cycle and eop cycle);

generate 
  if (WORDS == 4) begin
    always @(posedge clk) begin
	if (frm_vld_i & |frm_eop)
		eop_blk_bcnt_d1 <= (~frm_eop_empty[11:9] & {3{frm_eop[3]}}) | (~frm_eop_empty[8:6] & {3{frm_eop[2]}})
				| (~frm_eop_empty[5:3] & {3{frm_eop[1]}}) | (~frm_eop_empty[2:0] & {3{frm_eop[0]}});
	else	eop_blk_bcnt_d1 <= 3'h0;
    end

    always @(posedge clk) begin
	if (rst_l[7])		sop_bcnt_d2 <= 6'b0;
	else begin
		if (sop_d1_12[3]) begin
			if (eop_d1_0[2])	sop_bcnt_d2 <= 6'd8;
			else if (eop_d1_0[1])	sop_bcnt_d2 <= 6'd16;
			else if (eop_d1_0[0])	sop_bcnt_d2 <= 6'd24;
			else			sop_bcnt_d2 <= 6'd32;
		end else if (sop_d1_12[2]) begin
			if (eop_d1_0[1])	sop_bcnt_d2 <= 6'd8;
			else if (eop_d1_0[0])	sop_bcnt_d2 <= 6'd16;
			else			sop_bcnt_d2 <= 6'd24;
		end else if (sop_d1_12[1]) begin
			if (eop_d1_0[0])	sop_bcnt_d2 <= 6'd8;
			else			sop_bcnt_d2 <= 6'd16;
		end else if (sop_d1_12[0]) begin
						sop_bcnt_d2 <= 6'd8;
		end
	end
    end

    always @(posedge clk) begin
	if (rst_l[4])		eop_bcnt_d2 <= 6'b0;
	else begin
		if (eop_d1_1[0]) begin
			if (sop_d1_13[3] | sop_d1_13[2] | sop_d1_13[1])
				eop_bcnt_d2 <= eop_blk_bcnt_d1 + 6'd1;
			else	eop_bcnt_d2 <= eop_blk_bcnt_d1 + 6'd25;
		end else if (eop_d1_1[1]) begin
			if (sop_d1_13[3] | sop_d1_13[2])
				eop_bcnt_d2 <= eop_blk_bcnt_d1 + 6'd1;
			else	eop_bcnt_d2 <= eop_blk_bcnt_d1 + 6'd17;
		end else if (eop_d1_1[2]) begin
			if (sop_d1_13[3])
				eop_bcnt_d2 <= eop_blk_bcnt_d1 + 6'd1;
			else	eop_bcnt_d2 <= eop_blk_bcnt_d1 + 6'd9;
		end else if (eop_d1_1[3]) begin
				eop_bcnt_d2 <= eop_blk_bcnt_d1 + 6'd1;
		end
	end
    end

    assign pld_bcnt_d2 = vld_cyc_cnt_d2[11:0] << 5;

  end else if (WORDS == 2) begin	// generate WORDS==2 branch;
    always @(posedge clk) begin
	if (frm_vld_i & |frm_eop)
		eop_blk_bcnt_d1 <= (~frm_eop_empty[5:3] & {3{frm_eop[1]}}) | (~frm_eop_empty[2:0] & {3{frm_eop[0]}});
	else	eop_blk_bcnt_d1 <= 3'h0;
    end

    always @(posedge clk) begin
	if (rst_l[7])		sop_bcnt_d2 <= 6'b0;
	else begin
	   case (sop_d1_12)
		2'b10:
			case (eop_d1_0)
				2'b01:	 sop_bcnt_d2 <= 6'd8;
				default: sop_bcnt_d2 <= 6'd16;
			endcase
		2'b01:		sop_bcnt_d2 <= 6'd8;
	   endcase
	end
    end

    always @(posedge clk) begin
	if (rst_l[4])		eop_bcnt_d2 <= 6'b0;
	else begin
	   case (eop_d1_0)
		2'b10:	eop_bcnt_d2 <= eop_blk_bcnt_d1 + 6'd1;
		2'b01:	
			case (sop_d1_13)
				2'b10:	 eop_bcnt_d2 <= eop_blk_bcnt_d1 + 6'd1;
				default: eop_bcnt_d2 <= eop_blk_bcnt_d1 + 6'd9;
			endcase
		default:	eop_bcnt_d2 <= 0;
	   endcase
	end
    end

    assign pld_bcnt_d2 = vld_cyc_cnt_d2[12:0] << 4;

  end else begin	// generate WORDS==1 branch;
    always @(posedge clk) begin
	if (frm_vld_i & frm_eop)
		eop_blk_bcnt_d1 <= (~frm_eop_empty[2:0] & {3{frm_eop[0]}});
	else	eop_blk_bcnt_d1 <= 3'h0;
    end

    always @(posedge clk) begin
	sop_bcnt_d2 <= 6'd8;
	eop_bcnt_d2 <= eop_blk_bcnt_d1 + 6'd1;
    end
    assign pld_bcnt_d2 = vld_cyc_cnt_d2 << 3;
  end
endgenerate

//------------------------------------------
// delay cfg_crc
// if crc included, eop/eop_empty will point to end of crc;
// if crc is not included, eop/eop_empty will point to end of data;
wire cfg_crc_included_d4;
alt_e100s10_delay_regs #(.LATENCY(4), .WIDTH(1)) d10 (
    .clk    (clk),
    .din    (cfg_crc_included),   
    .dout   (cfg_crc_included_d4)
);
wire [2:0]	fcs_bcnt = cfg_crc_included_d4 ? 4 : 0;

//------------------------------------------
// pld_bcnt_d5: include sop_cnt, eop_cnt, and crc_cnt;
always @(posedge clk) begin
	sop_bcnt_d3 <= sop_bcnt_d2;
	eop_bcnt_d3 <= eop_bcnt_d2;

	pld_bcnt_d3 <= pld_bcnt_d2 + (eop_sop_d2 ? sop_bcnt_d3 : sop_bcnt_d2);
	pld_bcnt_d4 <= pld_bcnt_d3 + eop_bcnt_d3;
	pld_bcnt_d5 <= pld_bcnt_d4 - fcs_bcnt;	// remove crc bcnt;

	// pkt data bcnt only; should match packet SIZE value if there is no padding;
	// remove bcnt for da(6), sa(6), type/size(2), and rvln(4), svln(8) tags;
	if (pkt_type_rvln_d5)		pld_bcnt_d6 <= pld_bcnt_d5 - 5'd18;
	else if (pkt_type_svln_d5)	pld_bcnt_d6 <= pld_bcnt_d5 - 5'd22;
	else				pld_bcnt_d6 <= pld_bcnt_d5 - 5'd14;
end

// add back rvln(4), svln(8) tag bcnt for status vector report;
reg [3:0]	vlan_d6;
always @(posedge clk) begin
	if (cfg_vlandet_disable & pkt_type_rvln_d5)
		vlan_d6 <= 4'h4;
	else if (cfg_vlandet_disable & pkt_type_svln_d5)
		vlan_d6 <= 4'h8;
	else	vlan_d6 <= 4'h0;
end

reg [16:0]	frame_bcnt_d6_17bit;	// from first byte of DA, to last byte of CRC; including DA, SA, pkt, CRC;
always @(posedge clk) begin
	frame_bcnt_d6_17bit <= pld_bcnt_d5 + 3'd4;	// add back crc(4) bcnt for frame bcnt;
	pld_bcnt_d7 <= pld_bcnt_d6 + vlan_d6;	// not including DA, SA, and CRC;
	pld_bcnt_d8_17bit <= pld_bcnt_d7;
end

wire [15:0]	frame_bcnt_d6;
wire [15:0]	pld_bcnt_d8;
assign frame_bcnt_d6 = frame_bcnt_d6_17bit[16] ? 16'hFFFF : frame_bcnt_d6_17bit[15:0];
assign pld_bcnt_d8   = pld_bcnt_d8_17bit[16] ? 16'hFFFF : pld_bcnt_d8_17bit[15:0];

//------------------------------------------
// Checking of payload length
//------------------------------------------
reg [15:0]  pkt_len_fld_d6;
always @(posedge clk) begin
	if (pkt_type_rvln_d5) begin
		pkt_len_fld_d6     <=  pkt_rvln_tlen_d5;
	end else if (pkt_type_svln_d5) begin
		pkt_len_fld_d6     <=  pkt_svln_tlen_d5;
	end else begin
		pkt_len_fld_d6     <=  pkt_norm_tlen_d5;
	end
end

//---compare received pkt bytes length with length in header;
wire    nerr_min_d9;
alt_e100s10_lte   lte0 (	// 3 cycles delay
    .clk    (clk),
    .dina   ({2'b00, pkt_len_fld_d6}),
    .dinb   ({1'b0, pld_bcnt_d6}),
    .lte    (nerr_min_d9)      // CC-9
);

// advertised pkt length <= 1500
wire    pkt_len_valid_d9;
alt_e100s10_lte   lte5 (
    .clk    (clk),
    .dina   ({2'b00, pkt_len_fld_d6}),
    .dinb   (18'd1500),
    .lte    (pkt_len_valid_d9)      // CC-9
);

// error decision
reg pld_len_err_d10;
wire dp_ctrl_d8;

generate
  if (PLD_DUALCHK == 1'b1) begin
	// payload equality comparator
	wire    pkt_len_eq_pld_bcnt_d8;
	alt_e100s10_eq18t2  eql(  
		.clk    (clk),
		.din_a  ({2'b00, pkt_len_fld_d6}),
		.din_b  ({1'b0, pld_bcnt_d6}),
		.match  (pkt_len_eq_pld_bcnt_d8)    // CC-8
	);
    
	// less than min comparators
	wire    min_rv_d7;
	wire    min_sv_d7;
	wire    min_nl_d7;
	alt_e100s10_lte   lte1 (
		.clk    (clk),
		.dina   ({2'b00, pkt_rvln_tlen_d4}),
		.dinb   (18'd41),	//41+18+4=63; need padding; (18'd42),
		.lte    (min_rv_d7)        //CC-7
	);

	alt_e100s10_lte   lte2 (
		.clk    (clk),
		.dina   ({2'b00, pkt_svln_tlen_d4}),
		.dinb   (18'd37),	//37+18+8=63; need padding; (18'd38),
		.lte    (min_sv_d7)        //CC-7
	);

	alt_e100s10_lte   lte3 (
		.clk    (clk),
		.dina   ({2'b00, pkt_norm_tlen_d4}),
		.dinb   (18'd45),	//45+18=63; need padding if frame len is less than 64 bytes; (18'd44),
		.lte    (min_nl_d7)        //CC-7
	);


	wire    ptype_rvln_d7;
	wire    ptype_svln_d7;
	//alt_e100s10_delay2w2 d9 (
	alt_e100s10_delay_regs #(.LATENCY(2), .WIDTH(2)) d9 (
		.clk    (clk),
		.din    ({pkt_type_rvln_d5, pkt_type_svln_d5}),
		.dout   ({ptype_rvln_d7, ptype_svln_d7})
	);

	reg minchk_d8;
	reg minchk_d9;
	always @(posedge clk) begin
		minchk_d8   <=   (min_nl_d7 & ~ptype_rvln_d7 & ~ptype_svln_d7) 
					| (min_rv_d7 & ptype_rvln_d7) | (min_sv_d7 & ptype_svln_d7);
		minchk_d9   <=   minchk_d8 ;
	end

	reg pkt_len_eq_pld_bcnt_d9;
	always @(posedge clk) begin
		pkt_len_eq_pld_bcnt_d9   <=  pkt_len_eq_pld_bcnt_d8 | dp_ctrl_d8; 
		// CC-10
		if (minchk_d9)	pld_len_err_d10  <=  ~nerr_min_d9;   
		else		pld_len_err_d10  <=  ~pkt_len_eq_pld_bcnt_d9 & pkt_len_valid_d9;    
	end
  end else begin	// generate PLD_DUALCHK == 0 branch
    reg det_disabled_d6;
    always @(posedge clk) begin
        // CC-6
        det_disabled_d6 <=  cfg_vlandet_disable & (pkt_type_rvln_d5 | pkt_type_svln_d5) | pkt_type_ctrl_d5 ;
    end

    wire    det_disabled_d9;
    //alt_e100s10_delay3w1 d9 (
    alt_e100s10_delay_regs #(.LATENCY(3), .WIDTH(1)) d9 (
        .clk    (clk)  ,
        .din    (det_disabled_d6) ,
        .dout   (det_disabled_d9)
    );

    always @(posedge clk) begin
        // CC-10
        pld_len_err_d10  <=  ~nerr_min_d9 & ~det_disabled_d9 & pkt_len_valid_d9;
    end
end
endgenerate

/////////////////////////////
// Frame length checking
/////////////////////////////

wire    fln_ovr_n_d9;
alt_e100s10_lte   lte4 (
    .clk    (clk),
    .dina   ({1'b0, frame_bcnt_d6_17bit}),
    .dinb   ({2'b00, cfg_max_frm_length}),
    .lte    (fln_ovr_n_d9)        //CC-9
);

reg oversize_d10;
always @(posedge clk) begin
    // CC-10
    oversize_d10   <= ~fln_ovr_n_d9;
end

reg undersize_d8;
reg undersize_a_d7;
reg undersize_b_d7;
always @(posedge clk) begin
    // CC-7
    undersize_a_d7 <=  (|frame_bcnt_d6[11:6]);
    undersize_b_d7 <=  (|frame_bcnt_d6[15:12]);

    // CC-8
    undersize_d8   <=  ~(undersize_a_d7 | undersize_b_d7) ;
end


///////////////////////////////////////
// Delay/Alignment & Output connections
///////////////////////////////////////

wire ptype_svln_d10;
wire ptype_rvln_d10;
wire ptype_ctrl_d10;
wire ptype_pause_d10;
wire ptype_bcast_d10;
wire ptype_mcast_d10;
wire ptype_ucast_d10;
wire ptype_pfc_d10;

wire dp_ptype_svln_d8;
wire dp_ptype_rvln_d8;
wire dp_opcds_pause_d8;

alt_e100s10_delay_regs #(.LATENCY(2), .WIDTH(4)) d1 (
    .clk    (clk),
    .din    ({dp_ptype_svln_d6, dp_ptype_rvln_d6, dp_ctrl_d6, dp_opcd_pause_d6}),
    .dout   ({dp_ptype_svln_d8, dp_ptype_rvln_d8, dp_ctrl_d8, dp_opcds_pause_d8})
);

alt_e100s10_delay_regs #(.LATENCY(2), .WIDTH(4)) d2 (
    .clk    (clk),
    .din    ({dp_ptype_svln_d8, dp_ptype_rvln_d8, dp_ctrl_d8, dp_opcds_pause_d8}),
    .dout   ({ptype_svln_d10, ptype_rvln_d10, ptype_ctrl_d10, ptype_pause_d10})
);

alt_e100s10_delay_regs #(.LATENCY(4), .WIDTH(1)) d3 (
    .clk    (clk),
    .din    ({dp_addr_ucast_d6}),  
    .dout   ({ptype_ucast_d10})
);

alt_e100s10_delay_regs #(.LATENCY(4), .WIDTH(1)) d4 (
    .clk    (clk),
    .din    ({dp_ctrl_pfc_d6}),  
    .dout   ({ptype_pfc_d10})
);

wire [15:0] pld_bcnt_d10;
wire [15:0] frame_bcnt_d8;
wire [15:0] frame_bcnt_d10;
wire dp_addr_bcast_d8;
wire dp_addr_mcast_d8;

alt_e100s10_delay_regs #(.LATENCY(2), .WIDTH(9)) d5a (
    .clk    (clk),
    .din    (frame_bcnt_d6[8:0]),
    .dout   (frame_bcnt_d8[8:0])
);

alt_e100s10_delay_regs #(.LATENCY(2), .WIDTH(9)) d5b (
    .clk    (clk),
    .din    ({dp_addr_bcast_d6, dp_addr_mcast_d6, frame_bcnt_d6[15:9]}),
    .dout   ({dp_addr_bcast_d8, dp_addr_mcast_d8, frame_bcnt_d8[15:9]})
);


alt_e100s10_delay_regs #(.LATENCY(2), .WIDTH(34)) d6 (
    .clk    (clk),
    .din    ({dp_addr_bcast_d8, dp_addr_mcast_d8, pld_bcnt_d8, frame_bcnt_d8}),
    .dout   ({ptype_bcast_d10, ptype_mcast_d10, pld_bcnt_d10, frame_bcnt_d10})
);


wire undersize_d10;
alt_e100s10_delay_regs #(.LATENCY(2), .WIDTH(1)) d7 (
    .clk    (clk),
    .din    (undersize_d8),
    .dout   (undersize_d10)
);

assign  frm_error[0] = undersize_d10;   
assign  frm_error[1] = oversize_d10;    
assign  frm_error[2] = pld_len_err_d10;  

assign  stats[15:0] = pld_bcnt_d10;   
assign  stats[31:16] = frame_bcnt_d10;  
assign  stats[32] = ptype_svln_d10;     
assign  stats[33] = ptype_rvln_d10;     
assign  stats[34] = ptype_ctrl_d10;     
assign  stats[35] = ptype_pause_d10;    
assign  stats[36] = ptype_bcast_d10;    
assign  stats[37] = ptype_mcast_d10;    
assign  stats[38] = ptype_ucast_d10;    
assign  stats[39] = ptype_pfc_d10;      
assign  stats[40] = invld_sop_d10;	//hua;
assign  stats[41] = invld_eop_d10;	//hua;

assign  stats_valid = vld_eop_d10;
endmodule
