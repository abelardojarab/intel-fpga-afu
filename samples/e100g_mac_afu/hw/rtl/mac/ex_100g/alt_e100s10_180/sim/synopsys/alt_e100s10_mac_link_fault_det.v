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


// $Id: $
// $Revision: $
// $Date: $
// $Author: linhua $
//-----------------------------------------------------------------------------

module alt_e100s10_mac_link_fault_det
  #(
    parameter                            WORDS    = 4
    )
    (
    input                clk,
    input                rstn,
    input                ena,
    input [WORDS*64-1:0] mii_data_in,  // read bytes left to right
    input [WORDS*8-1:0]  mii_ctl_in,   // read bits left to right   
    output reg           remote_fault_status,
    output reg           local_fault_status
   );

   //********************************************************************
   // Define Parameters
   //********************************************************************
   // Link Fault SM States
   localparam SEQUENCE                  = 8'h9C;
   localparam NO_FAULT                  = 8'h00;
   localparam LOCAL_FAULT               = 8'h01;
   localparam REMOTE_FAULT              = 8'h02;
   localparam MII_DATA_LOCAL_SEQ_OS  = {SEQUENCE,8'h0,8'h0,LOCAL_FAULT,8'h0,8'h0,8'h0,8'h0};
   localparam MII_DATA_REMOTE_SEQ_OS = {SEQUENCE,8'h0,8'h0,REMOTE_FAULT,8'h0,8'h0,8'h0,8'h0};

   localparam OK_ST             = 2'h0;	//1'b0;
   localparam COUNT_ST          = 2'h1;
   localparam FAULT_ST          = 2'h2;	//1'b1;
   localparam NO_FAULT_TYPE     = 2'b00;
   localparam LOCAL_FAULT_TYPE  = 2'b01;
   localparam REMOTE_FAULT_TYPE = 2'b10;
   //********************************************************************
   // Define variables 
   //********************************************************************
   genvar            i;
   
//---------------------------------------
reg	[1:0]	flt_st, flt_nst;

reg [7:0]          col_cnt, col_cnt_nxt;
reg [2:0]          seq_cnt, seq_cnt_nxt;
reg [1:0]          seq_type, seq_type_nxt;
reg [WORDS*64-1:0] mii_data_d1;  // read bytes left to right
reg [WORDS*8-1:0]  mii_ctl_d1;   // read bits left to right   
   
//********************************************************************
// Pipeline Aggregate block_lock and align_status signals 
// to match datapath latency
//********************************************************************
always @(posedge clk or negedge rstn) begin
  if (!rstn)		mii_ctl_d1 <= 0;
  else			mii_ctl_d1 <= mii_ctl_in;
end

reg mii_vld_d1, mii_vld_d2, mii_vld_d3;
always @(posedge clk) begin
  mii_data_d1 <= mii_data_in;
  mii_vld_d1 <= ena;
  mii_vld_d2 <= mii_vld_d1;
  mii_vld_d3 <= mii_vld_d2;
end

reg [WORDS-1:0] mii_ctl_type_d2;
reg [WORDS-1:0] mii_local_seq_lo_d2, mii_remot_seq_lo_d2;
reg [WORDS-1:0] mii_local_seq_hi_d2, mii_remot_seq_hi_d2;
generate
  for (i=0; i < WORDS; i=i+1) begin : LF_CTRL_DET
	always @(posedge clk) begin
		mii_ctl_type_d2[i] <= mii_vld_d1 & (mii_ctl_d1[8*(i+1)-1:8*i]==8'h80);
		mii_local_seq_lo_d2[i] <= (mii_data_d1[64*i+31 : 64*i+0 ] == MII_DATA_LOCAL_SEQ_OS[31:0]);
		mii_local_seq_hi_d2[i] <= (mii_data_d1[64*i+63 : 64*i+32] == MII_DATA_LOCAL_SEQ_OS[63:32]);
		mii_remot_seq_lo_d2[i] <= (mii_data_d1[64*i+31 : 64*i+0 ] == MII_DATA_REMOTE_SEQ_OS[31:0]);
		mii_remot_seq_hi_d2[i] <= (mii_data_d1[64*i+63 : 64*i+32] == MII_DATA_REMOTE_SEQ_OS[63:32]);
	end
  end
endgenerate

//wire [WORDS-1:0] mii_local_seq = mii_ctl_type_d3 & mii_local_seq_lo_d3 & mii_local_seq_hi_d3;
//wire [WORDS-1:0] mii_remot_seq = mii_ctl_type_d3 & mii_remot_seq_lo_d3 & mii_remot_seq_hi_d3;
reg [WORDS-1:0] mii_local_seq_d3, mii_remot_seq_d3;
always @(posedge clk) begin
	mii_local_seq_d3 <= mii_ctl_type_d2 & mii_local_seq_lo_d2 & mii_local_seq_hi_d2;
	mii_remot_seq_d3 <= mii_ctl_type_d2 & mii_remot_seq_lo_d2 & mii_remot_seq_hi_d2;
end

wire [WORDS-1:0] mii_fault_seq_d3 = mii_local_seq_d3 | mii_remot_seq_d3;
wire		mii_has_fault_seq_d3 = (|mii_local_seq_d3) | (|mii_remot_seq_d3);
wire		mii_mix_fault_seq_d3 = (|mii_local_seq_d3) & (|mii_remot_seq_d3);

//-----------------------
wire [1:0]	mii_din_seq_type_d3;	// linkfault type; could be new type or same as current type;
wire [2:0]	mii_din_seq_cnt_d3;	// linkfault count; could be for new type or for current type;
wire [2:0]	mii_din_lf_cnt_d3;	// local linfault count for current type;
wire [2:0]	mii_din_rf_cnt_d3;	// remote linfault count for current type;
reg [1:0] mii_din_seq_type_d4;

alt_e100s10_mac_link_fault_seq_cnt #(.WORDS(WORDS)) mac_link_fault_seq_cnt (
	.mii_local_seq		(mii_local_seq_d3),
	.mii_remot_seq		(mii_remot_seq_d3),
	.cur_seq_type		(mii_din_seq_type_d4),
	
	.mii_din_seq_type	(mii_din_seq_type_d3),
	.mii_din_seq_cnt	(mii_din_seq_cnt_d3),
	.mii_din_lf_cnt		(mii_din_lf_cnt_d3),
	.mii_din_rf_cnt		(mii_din_rf_cnt_d3)
);


//-----------------------
reg [2:0] mii_din_col_cnt_d3, mii_new_col_cnt_d3;
generate
  if (WORDS==4) begin: DIN_COL_CNT_DET_WORDS4
	always @* begin
		mii_din_col_cnt_d3 = !mii_vld_d3 ? 0 :
					mii_fault_seq_d3[3] ? 0 :
					mii_fault_seq_d3[2] ? 1 :
					mii_fault_seq_d3[1] ? 2 :
					mii_fault_seq_d3[0] ? 3 : 4;

		mii_new_col_cnt_d3 = !mii_vld_d3 ? 0 :
					mii_fault_seq_d3[0] ? 0 :
					mii_fault_seq_d3[1] ? 1 :
					mii_fault_seq_d3[2] ? 2 :
					mii_fault_seq_d3[3] ? 3 : 0;
	end
  end else begin: DIN_COL_CNT_DET_WORDS2
	always @* begin
		mii_din_col_cnt_d3 = !mii_vld_d3 ? 0 : mii_fault_seq_d3[1] ? 0 : mii_fault_seq_d3[0] ? 1 : 2;
		mii_new_col_cnt_d3 = !mii_vld_d3 ? 0 : mii_fault_seq_d3[0] ? 0 : mii_fault_seq_d3[1] ? 1 : 0;
	end
  end
endgenerate

//-----------------------
reg [2:0]	mii_din_lf_cnt_d4, mii_din_lf_cnt_d5;
reg [2:0]	mii_din_rf_cnt_d4, mii_din_rf_cnt_d5;
reg mii_has_fault_seq_d4, mii_mix_fault_seq_d4;
reg [2:0] mii_din_col_cnt_d4, mii_new_col_cnt_d4, mii_din_seq_cnt_d4;
reg has_fault_seq_d5, mix_fault_seq_d5;
reg [1:0] din_seq_type_d5;
reg [2:0] din_col_cnt_d5, new_col_cnt_d5, din_seq_cnt_d5;
always @(posedge clk) begin
	mii_has_fault_seq_d4	<= mii_has_fault_seq_d3;
	mii_mix_fault_seq_d4	<= mii_mix_fault_seq_d3;
	mii_din_seq_type_d4	<= mii_din_seq_type_d3;
	mii_din_seq_cnt_d4	<= mii_din_seq_cnt_d3;
	mii_din_col_cnt_d4	<= mii_din_col_cnt_d3;
	mii_new_col_cnt_d4	<= mii_new_col_cnt_d3;
	mii_din_lf_cnt_d4	<= mii_din_lf_cnt_d3;
	mii_din_rf_cnt_d4	<= mii_din_rf_cnt_d3;

	has_fault_seq_d5	<= mii_has_fault_seq_d4;
	mix_fault_seq_d5	<= mii_mix_fault_seq_d4;
	din_seq_type_d5		<= mii_din_seq_type_d4;
	din_seq_cnt_d5		<= mii_din_seq_cnt_d4;
	din_col_cnt_d5		<= mii_din_col_cnt_d4;
	new_col_cnt_d5		<= mii_new_col_cnt_d4;
	mii_din_lf_cnt_d5	<= mii_din_lf_cnt_d4;
	mii_din_rf_cnt_d5	<= mii_din_rf_cnt_d4;
end

//--------------------------------------------
reg [2:0] cur_seq_cnt_d5;
always @(posedge clk) begin
	cur_seq_cnt_d5 <= (seq_type_nxt == LOCAL_FAULT_TYPE) ? mii_din_lf_cnt_d4 : mii_din_rf_cnt_d4;
end

reg cur_seq_cnt_eq4_d5;
always @* begin
  if (seq_cnt[2])	cur_seq_cnt_eq4_d5 = 1'b1;
  else begin
	case (seq_cnt[1:0])
		2'b11:	if (|cur_seq_cnt_d5)		cur_seq_cnt_eq4_d5 = 1'b1;
			else				cur_seq_cnt_eq4_d5 = 1'b0;
		2'b10:	if (|cur_seq_cnt_d5[2:1])	cur_seq_cnt_eq4_d5 = 1'b1;
			else				cur_seq_cnt_eq4_d5 = 1'b0;
		2'b01:	if (cur_seq_cnt_d5[2])		cur_seq_cnt_eq4_d5 = 1'b1;
			else if (&cur_seq_cnt_d5[1:0])	cur_seq_cnt_eq4_d5 = 1'b1;
			else				cur_seq_cnt_eq4_d5 = 1'b0;
		default:if (cur_seq_cnt_d5[2])		cur_seq_cnt_eq4_d5 = 1'b1;
			else				cur_seq_cnt_eq4_d5 = 1'b0;
	endcase
  end
end

//--------------------------------------------
//wire [3:0] seq_cnt_acc_nxt = seq_cnt_nxt + mii_din_seq_cnt_d4;
reg [2:0] seq_cnt_acc_nxt;
always @* begin
  if (seq_cnt_nxt[2])	seq_cnt_acc_nxt = 3'h4;
  else begin
	case (seq_cnt_nxt[1:0])
		2'b11:	if (|mii_din_seq_cnt_d4)		seq_cnt_acc_nxt = 3'h4;
			else					seq_cnt_acc_nxt = 3'h3;
		2'b10:	if (|mii_din_seq_cnt_d4[2:1])		seq_cnt_acc_nxt = 3'h4;
			else if (mii_din_seq_cnt_d4[0])		seq_cnt_acc_nxt = 3'h3;
			else					seq_cnt_acc_nxt = 3'h2;
		2'b01:	if (mii_din_seq_cnt_d4[2])		seq_cnt_acc_nxt = 3'h4;
			else if (mii_din_seq_cnt_d4==3'h3)	seq_cnt_acc_nxt = 3'h4;
			else if (mii_din_seq_cnt_d4==3'h2)	seq_cnt_acc_nxt = 3'h3;
			else if (mii_din_seq_cnt_d4==3'h1)	seq_cnt_acc_nxt = 3'h2;
			else					seq_cnt_acc_nxt = 3'h1;
		default: if (mii_din_seq_cnt_d4[2])		seq_cnt_acc_nxt = 3'h4;
			else if (mii_din_seq_cnt_d4==3'h3)	seq_cnt_acc_nxt = 3'h3;
			else if (mii_din_seq_cnt_d4==3'h2)	seq_cnt_acc_nxt = 3'h2;
			else if (mii_din_seq_cnt_d4==3'h1)	seq_cnt_acc_nxt = 3'h1;
			else					seq_cnt_acc_nxt = 3'h0;
	endcase
  end
end

wire [7:0] col_cnt_acc_nxt = col_cnt_nxt[7:0] + mii_din_col_cnt_d4[2:0];
reg [7:0] col_cnt_acc_d5;
reg [2:0] seq_cnt_acc_d5;
always @(posedge clk) begin
  if (!rstn) begin
	col_cnt_acc_d5 <= 8'b0;
	seq_cnt_acc_d5 <= 3'b0;
  end else begin
	col_cnt_acc_d5 <= col_cnt_acc_nxt;
	seq_cnt_acc_d5 <= seq_cnt_acc_nxt;
  end
end

reg fault_seq_mismatch_d5;
always @(posedge clk) begin
	fault_seq_mismatch_d5 <= mii_has_fault_seq_d4 & (mii_din_seq_type_d4 != seq_type_nxt);
	//fault_gap_128_d5 <= mii_has_fault_seq_d4 & col_cnt_acc_nxt[7];
end

wire fault_gap_128_d5 = has_fault_seq_d5 & col_cnt_acc_d5[7];
wire has_new_seq_d5 = mix_fault_seq_d5 | fault_seq_mismatch_d5 | fault_gap_128_d5;

//-------------------------
always @(*) begin
  if (has_new_seq_d5)		seq_cnt_nxt	= din_seq_cnt_d5;
  else if (col_cnt_acc_d5[7])	seq_cnt_nxt	= 3'b0;
  else				seq_cnt_nxt	= seq_cnt_acc_d5;
end

always @(*) begin
  if (has_new_seq_d5)		col_cnt_nxt	= new_col_cnt_d5;
  else if (col_cnt_acc_d5[7])	col_cnt_nxt	= 8'b0;
  else if ((flt_st==COUNT_ST) & seq_cnt_acc_d5[2])
				col_cnt_nxt	= new_col_cnt_d5;
  else if (has_fault_seq_d5)	col_cnt_nxt	= new_col_cnt_d5;
  else				col_cnt_nxt	= col_cnt_acc_d5;
end


//-------------------------
always @(*) begin
  case (flt_st)
	OK_ST:	begin
		  if (has_new_seq_d5) begin
			flt_nst		= COUNT_ST;
			seq_type_nxt	= din_seq_type_d5;
		  end else begin
			flt_nst		= OK_ST;
			seq_type_nxt	= 2'b00;
		  end
		end
	COUNT_ST: begin
		  if (has_new_seq_d5) begin
			flt_nst		= COUNT_ST;
			seq_type_nxt	= din_seq_type_d5;
		  end else if (col_cnt_acc_d5[7]) begin
			flt_nst		= OK_ST;
			seq_type_nxt	= 2'b00;
		  end else if (seq_cnt_acc_d5[2]) begin
			flt_nst		= FAULT_ST;
			seq_type_nxt	= seq_type;
		  end else if (has_fault_seq_d5) begin
			flt_nst		= COUNT_ST;
			seq_type_nxt	= seq_type;
		  end else begin
			flt_nst		= COUNT_ST;
			seq_type_nxt	= seq_type;
		  end
		end
	FAULT_ST: begin
		  if (has_new_seq_d5) begin
			flt_nst		= COUNT_ST;
			seq_type_nxt	= din_seq_type_d5;
		  end else if (col_cnt_acc_d5[7]) begin
			flt_nst		= OK_ST;
			seq_type_nxt	= 2'b00;
		  end else if (has_fault_seq_d5) begin
			flt_nst		= FAULT_ST;
			seq_type_nxt	= seq_type;
		  end else begin
			flt_nst		= FAULT_ST;
			seq_type_nxt	= seq_type;
		  end
		end
	default: begin
			flt_nst		= OK_ST;
			seq_type_nxt	= 2'b00;
		end
  endcase
end

always @(posedge clk) begin
  if (!rstn) begin
	flt_st		<= 2'b0;
	seq_type	<= 2'b0;
	seq_cnt		<= 3'b0;
	col_cnt		<= 8'b0;
  end else begin
	flt_st		<= flt_nst;
	seq_type	<= seq_type_nxt;
	seq_cnt		<= seq_cnt_nxt;
	col_cnt		<= col_cnt_nxt;
  end
end

//-------------------------
always @(posedge clk) begin
  if (!rstn) begin
	local_fault_status  <= 1'b1;
	remote_fault_status <= 1'b0;
  end else if (flt_nst==OK_ST) begin
	local_fault_status  <= 1'b0;
	remote_fault_status <= 1'b0;
  end else if (flt_nst==FAULT_ST) begin
	local_fault_status  <= seq_type_nxt[0]; 
	remote_fault_status <= seq_type_nxt[1];
  end else if (cur_seq_cnt_eq4_d5) begin
	local_fault_status  <= seq_type[0]; 
	remote_fault_status <= seq_type[1];
  end
end
 
endmodule // e100_mac_link_fault_det

//-------------------------------------------------------
//-------------------------------------------------------
module alt_e100s10_mac_link_fault_seq_cnt #(parameter WORDS =4) (
	input	[3:0]		mii_local_seq,
	input	[3:0]		mii_remot_seq,
	input	[1:0]		cur_seq_type,
	
	output reg [1:0]	mii_din_seq_type,	// linkfault type; could be new type or same as current type;
	output reg [2:0]	mii_din_seq_cnt,	// linkfault count; could be for new type or for current type;
	output reg [2:0]	mii_din_lf_cnt,		// local linfault count for current type;
	output reg [2:0]	mii_din_rf_cnt		// remote linfault count for current type;
);

   localparam NO_FAULT_TYPE     = 2'b00;
   localparam LOCAL_FAULT_TYPE  = 2'b01;
   localparam REMOTE_FAULT_TYPE = 2'b10;

generate
  if (WORDS==4) begin: DIN_SEQ_CNT_DET_WORDS4
	always @* begin
	  if (mii_local_seq[0]) begin		//---xxxL
		mii_din_seq_type = LOCAL_FAULT_TYPE;
		if (mii_local_seq[1]) begin		//---xxLL
			if (mii_local_seq[2]) begin		//---xLLL
				if (mii_local_seq[3]) begin		//---LLLL
					mii_din_seq_cnt = 3'h4;
					mii_din_lf_cnt  = 3'h4;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RLLL
					mii_din_seq_cnt = 3'h3;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---0LLL
					mii_din_seq_cnt = 3'h3;
					mii_din_lf_cnt  = 3'h3;
					mii_din_rf_cnt  = 3'h0;
				end
			end else if (mii_remot_seq[2]) begin	//---xRLL
				if (mii_local_seq[3]) begin		//---LRLL
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RRLL
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h2;
				end else begin				//---0RLL
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end
			end else begin				//---x0LL
				if (mii_local_seq[3]) begin		//---L0LL
					mii_din_seq_cnt = 3'h3;
					mii_din_lf_cnt  = 3'h3;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---R0LL
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---00LL
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h2;
					mii_din_rf_cnt  = 3'h0;
				end
			end

		end else if (mii_remot_seq[1]) begin	//---xxRL
			if (mii_local_seq[2]) begin		//---xLRL
				if (mii_local_seq[3]) begin		//---LLRL
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h2;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RLRL
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---0LRL
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end
			end else if (mii_remot_seq[2]) begin	//---xRRL
				if (mii_local_seq[3]) begin		//---LRRL
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RRRL
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h3;
				end else begin				//---0RRL
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h2;
				end
			end else begin				//---x0RL
				if (mii_local_seq[3]) begin		//---L0RL
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---R0RL
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h2;
				end else begin				//---00RL
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end
			end

		end else begin			//---xx0L
			if (mii_local_seq[2]) begin		//---xL0L
				if (mii_local_seq[3]) begin		//---LL0L
					mii_din_seq_cnt = 3'h3;
					mii_din_lf_cnt  = 3'h3;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RL0L
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---0L0L
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h2;
					mii_din_rf_cnt  = 3'h0;
				end
			end else if (mii_remot_seq[2]) begin	//---xR0L
				if (mii_local_seq[3]) begin		//---LR0L
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RR0L
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h2;
				end else begin				//---0R0L
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end
			end else begin				//---x00L
				if (mii_local_seq[3]) begin		//---L00L
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h2;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---R00L
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---000L
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end
			end
		end
	  end

	  else if (mii_remot_seq[0]) begin	//---xxxR
		mii_din_seq_type = REMOTE_FAULT_TYPE;
		if (mii_local_seq[1]) begin		//---xxLR
			if (mii_local_seq[2]) begin		//---xLLR
				if (mii_local_seq[3]) begin		//---LLLR
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h3;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RLLR
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---0LLR
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h2;
					mii_din_rf_cnt  = 3'h0;
				end
			end else if (mii_remot_seq[2]) begin	//---xRLR
				if (mii_local_seq[3]) begin		//---LRLR
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RRLR
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h2;
				end else begin				//---0RLR
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end
			end else begin				//---x0LR
				if (mii_local_seq[3]) begin		//---L0LR
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h2;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---R0LR
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---00LR
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end
			end
		end else if (mii_remot_seq[1]) begin	//---xxRR
			if (mii_local_seq[2]) begin		//---xLRR
				if (mii_local_seq[3]) begin		//---LLRR
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h2;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RLRR
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---0LRR
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end
			end else if (mii_remot_seq[2]) begin	//---xRRR
				if (mii_local_seq[3]) begin		//---LRRR
					mii_din_seq_cnt = 3'h3;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RRRR
					mii_din_seq_cnt = 3'h4;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h4;
				end else begin				//---0RRR
					mii_din_seq_cnt = 3'h3;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h3;
				end
			end else begin				//---x0RR
				if (mii_local_seq[3]) begin		//---L0RR
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---R0RR
					mii_din_seq_cnt = 3'h3;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h3;
				end else begin				//---00RR
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h2;
				end
			end
		end else begin			//---xx0R
			if (mii_local_seq[2]) begin		//---xL0R
				if (mii_local_seq[3]) begin		//---LL0R
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h2;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RL0R
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---0L0R
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end
			end else if (mii_remot_seq[2]) begin	//---xR0R
				if (mii_local_seq[3]) begin		//---LR0R
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RR0R
					mii_din_seq_cnt = 3'h3;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h3;
				end else begin				//---0R0R
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h2;
				end
			end else begin				//---x00R
				if (mii_local_seq[3]) begin		//---L00R
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---R00R
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h2;
				end else begin				//---000R
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end
			end
		end
	  end
	  else begin				//---xxx0
		if (mii_local_seq[1]) begin		//---xxL0
			mii_din_seq_type = LOCAL_FAULT_TYPE;
			if (mii_local_seq[2]) begin		//---xLL0
				if (mii_local_seq[3]) begin		//---LLL0
					mii_din_seq_cnt = 3'h3;
					mii_din_lf_cnt  = 3'h3;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RLL0
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---0LL0
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h2;
					mii_din_rf_cnt  = 3'h0;
				end
			end else if (mii_remot_seq[2]) begin	//---xRL0
				if (mii_local_seq[3]) begin		//---LRL0
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RRL0
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h2;
				end else begin				//---0RL0
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end
			end else begin				//---x0L0
				if (mii_local_seq[3]) begin		//---L0L0
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h2;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---R0L0
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---00L0
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end
			end

		end else if (mii_remot_seq[1]) begin	//---xxR0
			mii_din_seq_type = REMOTE_FAULT_TYPE;
			if (mii_local_seq[2]) begin		//---xLR0
				if (mii_local_seq[3]) begin		//---LLR0
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h2;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RLR0
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---0LR0
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end
			end else if (mii_remot_seq[2]) begin	//---xRR0
				if (mii_local_seq[3]) begin		//---LRR0
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RRR0
					mii_din_seq_cnt = 3'h3;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h3;
				end else begin				//---0RR0
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h2;
				end
			end else begin				//---x0R0
				if (mii_local_seq[3]) begin		//---L0R0
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---R0R0
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h2;
				end else begin				//---00R0
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end
			end

		end else begin			//---xx00
			if (mii_local_seq[2]) begin		//---xL00
				mii_din_seq_type = LOCAL_FAULT_TYPE;
				if (mii_local_seq[3]) begin		//---LL00
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h2;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RL00
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---0L00
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end
			end else if (mii_remot_seq[2]) begin	//---xR00
				mii_din_seq_type = REMOTE_FAULT_TYPE;
				if (mii_local_seq[3]) begin		//---LR00
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---RR00
					mii_din_seq_cnt = 3'h2;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h2;
				end else begin				//---0R00
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end
			end else begin				//---x000
				if (mii_local_seq[3]) begin		//---L000
					mii_din_seq_type = LOCAL_FAULT_TYPE;
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h1;
					mii_din_rf_cnt  = 3'h0;
				end else if (mii_remot_seq[3]) begin	//---R000
					mii_din_seq_type = REMOTE_FAULT_TYPE;
					mii_din_seq_cnt = 3'h1;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h1;
				end else begin				//---0000
					//mii_din_seq_type = NO_FAULT_TYPE;
					mii_din_seq_type = cur_seq_type;
					mii_din_seq_cnt = 3'h0;
					mii_din_lf_cnt  = 3'h0;
					mii_din_rf_cnt  = 3'h0;
				end
			end
		end
	  end
	end

  end else begin: DIN_SEQ_CNT_DET_WORDS2
	always @* begin
	  if (mii_local_seq[0]) begin		//---xL
		mii_din_seq_type = LOCAL_FAULT_TYPE;
		if (mii_local_seq[1]) begin		//---LL
			mii_din_seq_cnt = 3'h2;
			mii_din_lf_cnt  = 3'h2;
			mii_din_rf_cnt  = 3'h0;
		end else if (mii_remot_seq[1]) begin	//---RL
			mii_din_seq_cnt = 3'h1;
			mii_din_lf_cnt  = 3'h0;
			mii_din_rf_cnt  = 3'h1;
		end else begin				//---0L
			mii_din_seq_cnt = 3'h1;
			mii_din_lf_cnt  = 3'h1;
			mii_din_rf_cnt  = 3'h0;
		end
	  end
	  else if (mii_remot_seq[0]) begin	//---xR
		mii_din_seq_type = REMOTE_FAULT_TYPE;
		if (mii_local_seq[1]) begin		//---LR
			mii_din_seq_cnt = 3'h1;
			mii_din_lf_cnt  = 3'h1;
			mii_din_rf_cnt  = 3'h0;
		end else if (mii_remot_seq[1]) begin	//---RR
			mii_din_seq_cnt = 3'h2;
			mii_din_lf_cnt  = 3'h0;
			mii_din_rf_cnt  = 3'h2;
		end else begin				//---0R
			mii_din_seq_cnt = 3'h1;
			mii_din_lf_cnt  = 3'h0;
			mii_din_rf_cnt  = 3'h1;
		end
	  end
	  else begin				//---x0
		if (mii_local_seq[1]) begin		//---L0
			mii_din_seq_type = LOCAL_FAULT_TYPE;
			mii_din_seq_cnt = 3'h1;
			mii_din_lf_cnt  = 3'h1;
			mii_din_rf_cnt  = 3'h0;
		end else if (mii_remot_seq[1]) begin	//---R0
			mii_din_seq_type = REMOTE_FAULT_TYPE;
			mii_din_seq_cnt = 3'h1;
			mii_din_lf_cnt  = 3'h0;
			mii_din_rf_cnt  = 3'h1;
		end else begin				//---00
			//mii_din_seq_type = NO_FAULT_TYPE;
			mii_din_seq_type = cur_seq_type;
			mii_din_seq_cnt = 3'h0;
			mii_din_lf_cnt  = 3'h0;
			mii_din_rf_cnt  = 3'h0;
		end
	  end
	end
  end
endgenerate

endmodule
