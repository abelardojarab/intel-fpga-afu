// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// (C) 2001-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.

// altera message_off 10030 10036 10236

`timescale 1 ps / 1 ps
module alt_aeu_40_pfc_rx_ctrl #(
	parameter SYNOPT_ALIGN_FCSEOP = 0,
	parameter NUMPRIORITY = 2,
	parameter SYNOPT_PREAMBLE_PASS = 1,
	parameter WORDS = 8,
	parameter PIPE_INPUTS = 0,
	parameter cfg_typlen= 16'h8808,
	parameter cfg_opcode= 16'h0101
)(
	input clk,
	input reset_n,
	
	input in_fcserror,
	input in_fcsval,
	input in_sop,
	input in_valid,
	input [WORDS*64-1:0] in_data,
	input [NUMPRIORITY-1:0] cfg_enable,
	input[47:0] cfg_daddr,
	input cfg_fwd_pause_frame,
	
	output reg drop_this_frame,
	output [NUMPRIORITY-1:0] rxon_frame,
	output [NUMPRIORITY-1:0] rxoff_frame,
	output [NUMPRIORITY-1:0] rx_out_pause
);

	localparam
		ADDR_MCAST = 48'h0180C2_000001,
		// 6 Bytes of dadr
		MSBDADR = 64*WORDS -01 - SYNOPT_PREAMBLE_PASS*08*08,
		LSBDADR = 64*WORDS -48 - SYNOPT_PREAMBLE_PASS*08*08,
	
		// 6 Bytes of saddr 
		MSBSADR = LSBDADR - 01,
		LSBSADR = LSBDADR - 48,
	
		// 2 Bytes of Type
		MSBTYPE = LSBSADR - 01,
		LSBTYPE = LSBSADR - 16,
	
		// 2 Bytes of opcode
		MSBOPCD = LSBTYPE - 01,
		LSBOPCD = LSBTYPE - 16,
	
		// 2 Bytes of enable
		MPENVEC = LSBOPCD - 01,
		LPENVEC = LSBOPCD - 16,
	
		// 2*N Bytes of quanta
		MPFCQNT = LPENVEC - 01,
		LPFCQNT = LPENVEC - 16*NUMPRIORITY; // Not usable for 4-WORD case
	
	//	input pipeline
	reg  in_pipe_fcserror;
	always @(posedge clk)
		in_pipe_fcserror <= in_fcserror;
	
	reg  in_pipe_fcsval;
	always @(posedge clk)
		in_pipe_fcsval <= in_fcsval;
	
	reg  in_pipe_sop;
	always @(posedge clk)
		in_pipe_sop <= in_sop;
	
	reg  in_pipe_valid;
	always @(posedge clk)
		in_pipe_valid  <= in_valid;
	
	reg [WORDS*64-1:0] in_pipe_data;
	always @(posedge clk)
		in_pipe_data  <= in_data;
	
	wire rxin_sop;
	wire rxin_valid;
	wire rxin_fcsval;
	wire rxin_fcserror;
	wire [WORDS*64-1:0] rxin_data;
	
	generate if (PIPE_INPUTS == 1) begin: pipe_inputs
		assign rxin_sop 	= in_pipe_sop;
		assign rxin_valid 	= in_pipe_valid;
		assign rxin_fcsval 	= in_pipe_fcsval;
		assign rxin_fcserror 	= in_pipe_fcserror;
		assign rxin_data 	= in_pipe_data;
	end else begin: primary_inputs
		assign rxin_sop 	= in_sop;
		assign rxin_valid 	= in_valid;
		assign rxin_fcsval 	= in_fcsval;
		assign rxin_fcserror 	= in_fcserror;
		assign rxin_data 	= in_data;
	end
	endgenerate
	
	// the fcs error checks will be performed for case when fcs error input is aligned with the eop.
	// for other cases all pause frames will be evaluated
	wire rxin_error;
	generate
		if (SYNOPT_ALIGN_FCSEOP == 0) begin 
			assign rxin_error = 1'b0; 
		end else begin 
			assign rxin_error = rxin_fcsval && rxin_fcserror; 
		end
	endgenerate
	
	wire valid_pkt_start =  rxin_valid && rxin_sop;
	wire valid_adr_match = (valid_pkt_start) && ((rxin_data[MSBDADR:LSBDADR] == cfg_daddr)||(rxin_data[MSBDADR:LSBDADR] == ADDR_MCAST));
	wire valid_typ_match = (valid_pkt_start) &&  (rxin_data[MSBTYPE:LSBTYPE] == cfg_typlen);
	wire valid_opc_match = (valid_pkt_start) &&  (rxin_data[MSBOPCD:LSBOPCD] == cfg_opcode);
	wire valid_hdr_match = (valid_adr_match) &&  (valid_typ_match) && (valid_opc_match);
	
	reg pfc_match = 1'b0;
	always @(posedge clk)
		if (rxin_valid) begin
			pfc_match <= valid_hdr_match;
		end
	
	reg [15:0] pause_en_vector;
	reg [111-64*SYNOPT_PREAMBLE_PASS:0] low_q_quanta; // FUNCTION OF PREAMBLE PASSTHROUGH
	always @(posedge clk)
		if (valid_hdr_match) begin
			pause_en_vector <= rxin_data[MPENVEC:LPENVEC];
			low_q_quanta <= rxin_data[MPFCQNT:0];
		end
	
	reg [15+64*SYNOPT_PREAMBLE_PASS:0] high_q_quanta; // FUNCTION OF PREAMBLE PASSTHROUGH
	always @(posedge clk)
		if (pfc_match & rxin_valid) begin
			high_q_quanta <= rxin_data[255:240-64*SYNOPT_PREAMBLE_PASS];
		end

	reg pfc_data_valid;	
	always @(posedge clk) begin
		pfc_data_valid <= pfc_match & rxin_valid & ~rxin_error;
	end
	wire [15:0] gated_pause_valid = pfc_data_valid ? pause_en_vector : 16'h0;
	
	wire [16*8-1:0] raw_pause_quanta = {low_q_quanta, high_q_quanta};
	
	wire [16*8-1:0] pause_quanta;
	genvar i;
	generate for (i=0; i< 8; i=i+1) begin:rev
		assign pause_quanta [16*(i+1)-1:16*i] = raw_pause_quanta[16*(8-i)-1:16*(8-i-1)];
	end
	endgenerate
	
	always@(posedge clk) begin
		if (valid_hdr_match) 
			drop_this_frame <= ~cfg_fwd_pause_frame;
		else if (valid_pkt_start) 
			drop_this_frame <= 1'b0;
	end
	
	genvar q;
	generate for (q=0; q < NUMPRIORITY; q=q+1) begin: queues
		alt_aeu_40_pfc_rx_qctrl rx_qctrl (
			.clk(clk),
			.reset_n(reset_n),
			.cfg_enable(cfg_enable[q]),
			.pause_valid(gated_pause_valid[q]),
			.pause_quanta(pause_quanta[16*(q+1)-1:16*q]),
			.rx_xon_frame(rxon_frame[q]),
			.rx_xoff_frame(rxoff_frame[q]),
			.rx_out_pause(rx_out_pause[q])
			);
	end
	endgenerate
	
endmodule
