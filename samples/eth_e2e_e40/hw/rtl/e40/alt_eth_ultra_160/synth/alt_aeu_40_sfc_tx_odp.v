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


// ____________________________________________________________________
//Copyright(C) 2013: Altera Corporation
// $Id$
// $Revision$
// $Date$
// $Author$
// ____________________________________________________________________
// adubey 06.2013
// altera message_off 10230
 module alt_aeu_40_sfc_tx_odp 
     #( 
       parameter WORDS = 8 
      ,parameter DWIDTH = 512 
      ,parameter EMPTYBITS = 6 
      )(
       input wire clk 
      ,input wire rst_n 

 //    link control interface signals
      ,input wire sel_in_pkt 			// forward incoming frame
      ,input wire sel_pause_pkt 		// insert pause frame
      ,input wire sel_store_pkt 		// select buffered data

 //   input data-path interface
      ,output wire in_ready      		// input ready
      ,input wire in_valid      			// input val
      ,input wire in_sop   			// sop word
      ,input wire in_eop   			// sop word
      ,input wire in_error
      ,input wire [DWIDTH-1:0] in_data 	// data 
      ,input wire [EMPTYBITS-1:0] in_empty 	// eop byte(one hot)
      ,input wire in_pause_valid
      ,input wire [WORDS*64-1:0] in_pause_data 
      ,input wire [EMPTYBITS-1:0] in_pause_empty 	// eop byte(one hot)

//     output data-path interface
      ,input wire out_ready			// stall input pipe
      ,output reg out_valid      		// output val
      ,output reg out_sop 			// sop cycle      
      ,output reg out_eop 			// eop cycle      
      ,output reg out_error
      ,output reg [DWIDTH-1:0] out_data 	// data
      ,output reg [EMPTYBITS-1:0] out_empty 	// eop byte (one hot)
      ,output reg out_debug 			// sop aligned pause frame valid
     );

 // ____________________________________________________________________

    wire tx_pause_sop = 1'b1;
    wire tx_pause_eop = 1'b1;	

    assign in_ready = out_ready;
    always@ (posedge clk)
       begin
	  if (out_ready)
	     begin
     		out_debug <= sel_pause_pkt;
		if (sel_pause_pkt) 
	     	    begin
	     		out_valid <= in_pause_valid;
	     		out_sop <= tx_pause_sop;
	     		out_eop <= tx_pause_eop;
                        out_error <= 1'b0;
	     		out_data <= {{DWIDTH{1'b0}},in_pause_data}; 
	     		out_empty <= in_pause_empty;
	     	    end 
		else if (sel_store_pkt) 
		// the link fsm provides for the store state
		// for a future need (if we decide to add a
		// buffer at the input and drain it later 
	      	    begin
	     		out_valid <=1'b0;
	     		out_sop  <= 1'b0;
	     		out_eop  <= 1'b0;
                        out_error <= 1'b0;
	     		out_data <= 1'b0;
	     		out_empty <= 0;
	      	    end
		else if (sel_in_pkt) 
	      	    begin
	     		out_valid <=in_valid;
	     		out_sop  <= in_sop;
	     		out_eop  <= in_eop;
                        out_error <= in_error;
	     		out_data <= in_data;
	     		out_empty <= in_empty;
	      	    end
		else // possible when rx_txoff_req is high
	      	    begin
	     		out_valid <=1'b0;
	     		out_sop  <= 1'b0;
	     		out_eop  <= 1'b0;
                        out_error <= 1'b0;
			// other signals doesn't matter
			// may impact mux size otherwise
			// it seems following logic may be
			// looking at sop/eop without valid
	      	    end
	     end
       end


 endmodule


