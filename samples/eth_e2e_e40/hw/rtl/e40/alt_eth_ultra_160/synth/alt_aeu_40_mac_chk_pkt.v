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


module alt_aeu_40_mac_chk_pkt #(
      parameter SYNOPT_PREAMBLE_PASS = 0,
      parameter WORDS = 2
)(
      input                 clk,
      input                 in_fcs_error,
      input                 in_fcs_valid,
      input                 in_rxi_in_packet,
      input [WORDS*8-1:0]   in_ctl,
      input [WORDS*64-1:0]  in_data,
      input                 in_valid,
      input [WORDS-1:0]     in_sop,
      input [WORDS-1:0]     in_eop,
      input [WORDS*3-1:0]   in_eop_empty,
      input [WORDS-1:0]     in_idle,
      output                out_fcs_error,
      output                out_fcs_valid,
      output [WORDS*8-1:0]  out_ctl,
      output [WORDS*64-1:0] out_data,
      output                out_valid,
      output [WORDS-1:0]    out_sop,
      output [WORDS-1:0]    out_eop,
      output [WORDS*3-1:0]  out_eop_empty,
      output [WORDS-1:0]    out_idle,
      output                out_rx_mii_err
);



  reg                   chk_dout_fcs_error_0,chk_dout_fcs_error_1;
  reg                   chk_dout_fcs_valid_0,chk_dout_fcs_valid_1;
  reg                   chk_rxi_in_packet_0;
  reg			chk_out_data_valid_0,chk_out_data_valid_1; 
  reg [WORDS-1:0]  	chk_out_idle_0,      chk_out_idle_1;
  reg [WORDS-1:0]  	chk_out_sop_0,       chk_out_sop_1;		// 1-bit per byte, indicates last byte of pkt
  reg [WORDS-1:0]  	chk_out_eop_0,       chk_out_eop_1;		// 1-bit per byte, indicates last byte of pkt
  reg [3*WORDS-1:0]  	chk_out_eop_empty_0, chk_out_eop_empty_1;		// 1-bit per byte, indicates last byte of pkt
  reg [64*WORDS-1:0]  	chk_out_data_0,      chk_out_data_1; 		// 4-words wide data input
  reg [8*WORDS-1:0]  	chk_out_ctl_0,       chk_out_ctl_1;  		// 1-bit per byte like xxGMII control signal
  reg                                        chk_out_rx_error_1;
  //reg                                        chk_out_rx_ill_1;
  reg                   rx_error_detect = 0;
  
  reg [8*WORDS-1:0]     mii_nonterm=0;
  reg [8*WORDS-1:0]     mii_term=0;

  reg                   chk_dout_fcs_error_f;
  reg                   chk_dout_fcs_valid_f;
  reg                   chk_rxi_in_packet_f;
  reg			chk_out_data_valid_f; 
  reg [WORDS-1:0]  	chk_out_idle_f;
  reg [WORDS-1:0]  	chk_out_sop_f;		// 1-bit per byte, indicates last byte of pkt
  reg [WORDS-1:0]  	chk_out_eop_f;		// 1-bit per byte, indicates last byte of pkt
  reg [3*WORDS-1:0]  	chk_out_eop_empty_f;		// 1-bit per byte, indicates last byte of pkt
  reg [64*WORDS-1:0]  	chk_out_data_f; 		// 4-words wide data input
  reg [8*WORDS-1:0]  	chk_out_ctl_f;  		// 1-bit per byte like xxGMII control signal

  reg                   mii_nonterm_gt_term_w1_0;
  reg                   mii_nonterm_gt_term_w0_0;

  reg                   chk_out_ctl_w0_0;
  genvar i, j;

  generate 
     for (i=0; i<WORDS; i=i+1) begin: FE
        for (j=0; j<8; j=j+1) begin: BYTE
           always @(posedge clk) begin
	         mii_term[i*8+j]     <= (in_data[(i*8+j+1)*8-1:(i*8+j)*8]==8'hfd) && (in_ctl[i*8+j]==1'b1) && in_valid;
	         mii_nonterm[i*8+j]  <= (in_data[(i*8+j+1)*8-1:(i*8+j)*8]!=8'hfd) && (in_ctl[i*8+j]==1'b1) && in_valid;
           end
        end
     end
  endgenerate

  always @(posedge clk) begin
              mii_nonterm_gt_term_w1_0 <= mii_nonterm[15:8] > mii_term[15:8];
              mii_nonterm_gt_term_w0_0 <= mii_nonterm[15:8]==mii_term[15:8] && mii_nonterm[7:0] > mii_term[7:0];
              chk_out_ctl_w0_0 <= mii_nonterm[7:0] > mii_term[7:0];
  end

reg same_cycle_err;
reg same_cycle_mii_err;
reg same_cycle_sop_err;
reg same_cycle_sop_mii_err;

always @(posedge clk) begin
                chk_rxi_in_packet_f  <= in_rxi_in_packet;
		chk_out_ctl_f        <= in_ctl;
		chk_out_data_f       <= in_data;
		chk_dout_fcs_error_f <= in_fcs_error;
		chk_dout_fcs_valid_f <= in_fcs_valid;
		chk_out_data_valid_f <= in_valid;
		chk_out_sop_f        <= in_sop;
		chk_out_eop_f        <= in_eop;
		chk_out_eop_empty_f  <= in_eop_empty;
		chk_out_idle_f       <= in_idle;

                chk_rxi_in_packet_0  <= chk_rxi_in_packet_f;
		chk_out_ctl_0        <= chk_out_ctl_f;
		chk_out_data_0       <= chk_out_data_f;
		chk_dout_fcs_error_0 <= chk_dout_fcs_error_f;
		chk_dout_fcs_valid_0 <= chk_dout_fcs_valid_f;
                if (chk_out_data_valid_0) begin 
                   same_cycle_err       <= (chk_out_sop_0[1] && chk_out_ctl_w0_0);

                end

                if (chk_out_data_valid_0) begin 
                   same_cycle_sop_err   <= !SYNOPT_PREAMBLE_PASS && (
                                            (chk_out_sop_0[1] && |(chk_out_ctl_0[15:8]))  ||
                                            (chk_out_sop_0[0] && |(chk_out_ctl_0[7:0])));
                
                end

		chk_out_data_valid_0 <= chk_out_data_valid_f;
		chk_out_sop_0        <= chk_out_sop_f;
		chk_out_eop_0        <= chk_out_eop_f;
		chk_out_eop_empty_0  <= chk_out_eop_empty_f;
		chk_out_idle_0       <= chk_out_idle_f;

		chk_dout_fcs_error_1 <= chk_dout_fcs_error_0;
		chk_dout_fcs_valid_1 <= chk_dout_fcs_valid_0;
		chk_out_ctl_1        <= chk_out_ctl_0;
		chk_out_data_1       <= chk_out_data_0;
		chk_out_data_valid_1 <= chk_out_data_valid_0;
		chk_out_sop_1        <= chk_out_sop_0;
		chk_out_eop_1        <= chk_out_eop_0;
		chk_out_eop_empty_1  <= chk_out_eop_empty_0;
		chk_out_idle_1       <= chk_out_idle_0;

	        chk_out_rx_error_1   <= 1'b0;
	        //chk_out_rx_ill_1     <= 1'b0;

	       if ((rx_error_detect == 1'b0) && (chk_out_data_valid_0 == 1'b1)) begin
                  if (same_cycle_sop_err) begin
			   //if (same_cycle_sop_mii_err)   chk_out_rx_error_1     <= 1'b1;
                           //else                          chk_out_rx_ill_1       <= 1'b1;
                           chk_out_rx_error_1        <= 1'b1; // any control char will assert rx_error
			   chk_out_eop_1             <= 2'b01;
			   chk_out_eop_empty_1       <= 0;
		           chk_out_idle_1[1:0]       <= 2'b00;
			   chk_dout_fcs_error_1      <= 1'b1;
			   chk_dout_fcs_valid_1      <= 1'b1;
                           rx_error_detect           <= 1'b1;
	          end
                  else if (chk_rxi_in_packet_0 && same_cycle_err) begin
			   //if (same_cycle_mii_err)   chk_out_rx_error_1     <= 1'b1;
                           //else                          chk_out_rx_ill_1       <= 1'b1;
                           chk_out_rx_error_1        <= 1'b1; // any control char will assert rx_error
			   chk_out_eop_1             <= 2'b01;
			   chk_out_eop_empty_1       <= 0;
		           chk_out_idle_1[1:0]       <= 2'b00;
			   chk_dout_fcs_error_1      <= 1'b1;
			   chk_dout_fcs_valid_1      <= 1'b1;
                           rx_error_detect           <= 1'b1;
	          end
                  else if (chk_rxi_in_packet_0 && mii_nonterm_gt_term_w1_0) begin
                           //else                          chk_out_rx_ill_1       <= 1'b1;
                           chk_out_rx_error_1        <= 1'b1; // any control char will assert rx_error
			   chk_out_eop_1             <= 2'b10;
			   chk_out_eop_empty_1       <= 0;
		           if (chk_out_sop_0[0])   chk_out_idle_1[1:0]  <= 2'b00;
		           else                    chk_out_idle_1[1:0]  <= 2'b01;
			   chk_dout_fcs_error_1      <= 1'b1;
			   chk_dout_fcs_valid_1      <= 1'b1;
                           if (!chk_out_sop_0[0]) rx_error_detect           <= 1'b1;
	          end
                  else if (chk_rxi_in_packet_0 && mii_nonterm_gt_term_w0_0) begin
                           //else                          chk_out_rx_ill_1       <= 1'b1;
                           chk_out_rx_error_1        <= 1'b1; // any control char will assert rx_error
			   chk_out_eop_1             <= 2'b01;
			   chk_out_eop_empty_1       <= 0;
		           chk_out_idle_1[1:0]       <= 2'b00;
			   chk_dout_fcs_error_1      <= 1'b1;
			   chk_dout_fcs_valid_1      <= 1'b1;
                           rx_error_detect           <= 1'b1;
	          end
                end
                else if (|chk_out_sop_0 && chk_out_data_valid_0) rx_error_detect <= 1'b0;
		
		// filter the rest of the packet until the next valid start appears
		if (rx_error_detect) begin
		        if (!chk_out_sop_0[1])      begin
		           if (chk_out_sop_0[0]) begin
			      chk_out_eop_1[1]   <= 1'b0;
                              chk_out_idle_1[1]  <= 1'b1;
			      chk_out_eop_empty_1[5:3]  <= 3'h0;
			      chk_dout_fcs_valid_1 <= 1'b0;
                           end
		           else begin                       
			      chk_out_eop_1[1:0]   <= 2'b00;
                              chk_out_idle_1[1:0]  <= 2'b11;
			      chk_dout_fcs_error_1 <= 1'b0;
			      chk_dout_fcs_valid_1 <= 1'b0;
		              chk_out_data_valid_1 <= 1'b0;
			      chk_out_eop_empty_1[5:0]  <= 6'h0;
                           end
                        end
		end
end
/*
assign out_fcs_error   = chk_dout_fcs_error_1;
assign out_fcs_valid   = chk_dout_fcs_valid_1;
assign out_ctl	       = chk_out_ctl_1;
assign out_data	       = chk_out_data_1;   
assign out_valid       = chk_out_data_valid_1;
assign out_sop         = chk_out_sop_1;   
assign out_eop         = chk_out_eop_1;   
assign out_eop_empty   = chk_out_eop_empty_1;
assign out_idle        = chk_out_idle_1;   
assign out_rx_mii_err  = chk_out_rx_error_1;
*/
//////////////////////////////////////////////////////////////////////////////
// The following is to move the eop/rx_error/... signals one cycle later
// in the case of sop and eop at the same cycle or one cycle apart.
// This is because the adapter will not be able to handle such a short frame.
///////////////////////////////////////////////////////////////////////////////

reg                   chk_dout_fcs_error_2;
reg                   chk_dout_fcs_valid_2;
reg                   chk_out_data_valid_2;
//reg[WORDS-1:0]        chk_out_word_valid_2;       // 1-bit per data word, indicates valid word
reg[WORDS-1:0]        chk_out_sop_2;              // 1-bit per data word, indicates start of pkt
reg[WORDS-1:0]        chk_out_sop_2x=0;           // 1-bit per data word, indicates start of pkt
reg[WORDS-1:0]        chk_out_eop_2;           
reg[3*WORDS-1:0]      chk_out_eop_empty_2;    
reg[WORDS-1:0]        chk_out_idle_2;           
reg[64*WORDS-1:0]     chk_out_data_2;                 // 5-words wide data input
reg[8*WORDS-1:0]      chk_out_ctl_2;                  // 1-bit per byte like xxGMII control signal
reg                   chk_out_rx_error_2;
reg                   chk_out_last_postpone_2=1'b0;
reg                   chk_out_last_postpone_rx_err_2;

//wire    postpone_1 = (chk_out_rx_error_1 || chk_out_rx_ill_1) && chk_out_data_valid_1 && ((|chk_out_sop_2x && |chk_out_eop_1 && !(|chk_out_sop_1)) || (chk_out_sop_1[1] && chk_out_eop_1[0])); 
wire    postpone_1 = chk_out_rx_error_1 && chk_out_data_valid_1 && ((|chk_out_sop_2x && |chk_out_eop_1 && !(|chk_out_sop_1)) || (chk_out_sop_1[1] && chk_out_eop_1[0])); 
wire    postpone_rx_err_1 = postpone_1 && chk_out_rx_error_1;


always @(posedge clk) begin
        chk_dout_fcs_error_2  <= chk_out_last_postpone_2 ? 1'b1 : postpone_1 ? 1'b0 : chk_dout_fcs_error_1;
        chk_dout_fcs_valid_2  <= chk_out_last_postpone_2 ? 1'b1 : postpone_1 ? 1'b0 : chk_dout_fcs_valid_1;
        chk_out_ctl_2         <= chk_out_ctl_1;
        chk_out_data_2        <= chk_out_data_1;
        chk_out_data_valid_2  <= chk_out_last_postpone_2 ? 1'b1 : chk_out_data_valid_1;
        chk_out_sop_2         <= chk_out_sop_1 & {2{chk_out_data_valid_1}};
        chk_out_eop_2         <= chk_out_last_postpone_2 ? 2'b01 : postpone_1 ?  2'b00 : chk_out_eop_1;
        chk_out_eop_empty_2   <= chk_out_last_postpone_2 ? 6'h0 : postpone_1 ?  6'h0 : chk_out_eop_empty_1;
        chk_out_idle_2        <= chk_out_last_postpone_2 ? 2'b00 : postpone_1 ?  2'b00 : chk_out_idle_1;
        //chk_out_rx_error_2    <= chk_out_last_postpone_2 ? 1'b1 : postpone_1 ? 1'b0 : chk_out_rx_error_1;
        chk_out_rx_error_2    <= chk_out_last_postpone_2 ? chk_out_last_postpone_rx_err_2 : postpone_1 ? 1'b0 : chk_out_rx_error_1;
        chk_out_last_postpone_2 <= postpone_1;
        chk_out_last_postpone_rx_err_2 <= postpone_rx_err_1;
        if (chk_out_data_valid_1) chk_out_sop_2x  <= chk_out_sop_1;

end

assign out_fcs_error    = chk_dout_fcs_error_2;
assign out_fcs_valid    = chk_dout_fcs_valid_2;
assign out_ctl          = chk_out_ctl_2;
assign out_data         = chk_out_data_2;        // 5 word out stream, regular left to right
assign out_valid        = chk_out_data_valid_2;
assign out_sop          = chk_out_sop_2;         // word pos first data after preamble
assign out_eop          = chk_out_eop_2;         // byte pos of last data before FCS
assign out_eop_empty    = chk_out_eop_empty_2;   // byte pos of last data before FCS
assign out_idle         = chk_out_idle_2;        // this is user data, not control
assign out_rx_mii_err   = chk_out_rx_error_2;

endmodule
