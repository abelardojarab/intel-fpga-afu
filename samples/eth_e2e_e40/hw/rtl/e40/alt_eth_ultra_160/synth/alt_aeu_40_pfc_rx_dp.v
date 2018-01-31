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


// altera message_off 10036

`timescale 1 ps / 1 ps
module alt_aeu_40_pfc_rx_dp #(
	parameter SYNOPT_ALIGN_FCSEOP = 0,
	parameter WORDS = 8,
	parameter EMPTYBITS = 6,
	parameter RXERRWIDTH = 6,
	parameter RXSTATUSWIDTH = 3, //RxCtrl
	parameter PIPE_INPUTS = 0
) (
	input clk,
	input reset_n,

	//	avalon st source (mac) to pause interface Rx 
	input [RXERRWIDTH-1:0] in_error,
	input in_error_valid,
	input [RXSTATUSWIDTH-1:0] in_status,
	input in_valid,
	input in_sop,
	input in_eop,
	input[64*WORDS-1:0] in_data,
	input[EMPTYBITS-1:0] in_empty,
	
	input drop_this_frame,
	
	//	pause to avalon st sink (buffer scheduler) Rx 
	output[1:0]  out_sband,
	output  reg out_eop,
	output [RXERRWIDTH-1:0] out_error,
	output out_error_valid,
	output [RXSTATUSWIDTH-1:0] out_status,
	output  reg out_sop,
	output  reg out_valid,
	output  reg[64*WORDS-1:0] out_data,
	output  reg[EMPTYBITS-1:0] out_empty
);
	
	wire rxin_eop;
	wire [RXERRWIDTH-1:0] rxin_error;
	wire [RXSTATUSWIDTH-1:0] rxin_status;
	wire rxin_sop;
	wire rxin_valid;
	wire [64*WORDS-1:0] rxin_data;
	wire [EMPTYBITS-1:0] rxin_empty;
	
	generate if (PIPE_INPUTS == 1) begin:  pipe_inputs
		reg [RXERRWIDTH-1:0] in_pipe_error;
		always @(posedge clk)
			in_pipe_error <= in_error;
	
		reg [RXSTATUSWIDTH-1:0] in_pipe_status;
		always @(posedge clk)
			in_pipe_status <= in_status;
	
		reg in_pipe_sop;
		always @(posedge clk)
			in_pipe_sop <= in_sop;
	
		reg in_pipe_eop;
		always @(posedge clk)
			in_pipe_eop <= in_eop;
	
		reg in_pipe_valid;
		always @(posedge clk)
			in_pipe_valid  <= in_valid;

		reg [WORDS*64-1:0] in_pipe_data;
		always @(posedge clk)
			in_pipe_data  <= in_data;

		reg [EMPTYBITS-1:0]in_pipe_empty;
		always @(posedge clk)
			in_pipe_empty <= in_empty;


		assign rxin_sop 	= in_pipe_sop;
		assign rxin_eop 	= in_pipe_eop;
		assign rxin_valid 	= in_pipe_valid;
		assign rxin_error 	= in_pipe_error;
		assign rxin_status 	= in_pipe_status;
		assign rxin_data 	= in_pipe_data;
		assign rxin_empty 	= in_pipe_empty;
	end else begin:  primary_inputs
		assign rxin_sop 	= in_sop;
		assign rxin_eop 	= in_eop;
		assign rxin_valid 	= in_valid;
		assign rxin_error 	= in_error;
		assign rxin_status 	= in_status;
		assign rxin_data 	= in_data;
		assign rxin_empty 	= in_empty;
	end
	endgenerate

	reg  pipe_1_rx_in_eop;
	reg  [RXERRWIDTH-1:0] pipe_1_rx_in_error;
	reg  [RXSTATUSWIDTH-1:0] pipe_1_rx_in_status;
	reg  pipe_1_rx_in_sop;
	reg  pipe_1_rx_in_val;
	reg[64*WORDS-1:0]  pipe_1_rx_in_data;
	reg[EMPTYBITS-1:0] pipe_1_rx_in_empty;
	
	always@(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			pipe_1_rx_in_eop <= 1'b0;
			pipe_1_rx_in_error <= {RXERRWIDTH{1'b0}};
			pipe_1_rx_in_status <= {RXSTATUSWIDTH{1'b0}};
			pipe_1_rx_in_sop <= 1'b0;
			pipe_1_rx_in_val <= 1'b0;
			pipe_1_rx_in_data <= 0;
			pipe_1_rx_in_empty <= {EMPTYBITS{1'd0}};
		end else begin
			pipe_1_rx_in_eop<= rxin_eop;
			pipe_1_rx_in_sop<= rxin_sop;
			pipe_1_rx_in_val<= rxin_valid;
			pipe_1_rx_in_data<= rxin_data;
			pipe_1_rx_in_empty<= rxin_empty;
			pipe_1_rx_in_error<= rxin_error;
			pipe_1_rx_in_status<= rxin_status;
		end
	end
	
	reg [RXERRWIDTH-1:0] pipe_2_rx_in_error;
	reg [RXSTATUSWIDTH-1:0] pipe_2_rx_in_status;
	always@(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			out_valid <= 0;
			out_sop	  <= 0;
			out_eop	  <= 0;
			out_data  <= 0;
			out_empty <= 0;
			pipe_2_rx_in_error <= 0;
			pipe_2_rx_in_status <= 0;
		end else if (drop_this_frame)  begin //  aligned with pipe stage 1
			out_valid <= 0;
			out_sop	  <= 0;
			out_eop	  <= 0;
			out_data  <= 0;
			out_empty <= 0;
			pipe_2_rx_in_error <= 0;
			pipe_2_rx_in_status <= 0;
		end else begin
			out_valid  <= pipe_1_rx_in_val;
			out_sop	   <= pipe_1_rx_in_sop;
			out_eop	   <= pipe_1_rx_in_eop;
			out_data   <= pipe_1_rx_in_data;
			out_empty  <= pipe_1_rx_in_empty;
			pipe_2_rx_in_error<= pipe_1_rx_in_error;
			pipe_2_rx_in_status<= pipe_1_rx_in_status;
		end
	end
	assign out_sband = {pipe_1_rx_in_sop, pipe_1_rx_in_val};
	
	generate if (SYNOPT_ALIGN_FCSEOP == 1) begin:fcseop_aligned
		assign out_error = pipe_2_rx_in_error;
		assign out_error_valid = out_eop;
		assign out_status = pipe_2_rx_in_status;
	end else begin:fcseop_skewed
		assign out_error = in_error;
		assign out_error_valid = in_error_valid;
		assign out_status = in_status;
	end
	endgenerate

endmodule
