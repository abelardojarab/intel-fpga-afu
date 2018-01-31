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
// $Id: alt_aeu_40_sfc_tx_qctrl.v,v 1.3 2015/01/24 01:26:50 marmstro Exp marmstro $
// $Revision: 1.3 $
// $Date: 2015/01/24 01:26:50 $
// $Author: marmstro $
// Copyright(C) 2013: Altera Corporation
// Altera corporation Confidential 
// ____________________________________________________________________
 // altera message_off 10036 10236
 
 module alt_aeu_40_sfc_tx_qctrl 
       #(
         parameter WORDS = 8
	)
	(
	input  wire	   clk,
	input  wire	   reset_n,

	input  wire	   pause_txin_done,
	input  wire	   cfg_holdoff_en,
	input  wire[15:0]  cfg_holdoff_quanta,
	input  wire	   cfg_enable,
	input  wire[15:0]  cfg_pause_quanta,
	input  wire	   in_pause_req,
        input  wire        cfg_pause_req, // expected to be in the tx clock domain
	output reg	   tx_xoff,
	output reg	   tx_xon,
	output wire	   queue_pause_req,
	output wire[15:0]  queue_pause_quanta
      );

 // _____________________________________________________________________
 //
	localparam IDL = 2'd0, XOF = 2'd1, XON = 3'd2, HLD = 3'd3; 
 // _____________________________________________________________________

     // both the pause and hold off quanta values are in multiples of 512-bits 
     // or 8 WORDS and need to be converted to appropriate number of cycles
	wire[16:0] holdoff_cycles; //
        generate 
	            if (WORDS == 8) assign holdoff_cycles = {1'b0,cfg_holdoff_quanta}; // - 20'd1 ;
	       else if (WORDS == 4) assign holdoff_cycles = {cfg_holdoff_quanta[15:0],1'b0}; // - 20'd1 ;
        endgenerate

	reg[1:0] state, next_state;
	reg[16:0] count, next_count;
	assign queue_pause_req = (state == XOF)||(state == XON);			// potential retiming for timing margin here
	assign queue_pause_quanta = (state == XON)? 16'd0:cfg_pause_quanta;		// potential retiming for timing margin here
	wire holdoff_done = (state == HLD) && (count == holdoff_cycles);

    //	frame pulses generated at the end of frame pulse transmission
	wire  xoff_frame = (state == XOF) && pause_txin_done;
	wire  xon_frame  = (state == XON) && pause_txin_done;
    
    // _____________________________________________________________________
    //	buffer full cleared signal to exit HOLDOFF state
    //	and immediately send an xon frame
    // _____________________________________________________________________
        wire pause_req = in_pause_req | cfg_pause_req;
        reg[1:0] in_pause_req_dly; 

        wire xoff_req=  in_pause_req_dly[1] |( in_pause_req_dly[0] & ~in_pause_req_dly[1]);
        wire xon_req = ~in_pause_req_dly[1] |(~in_pause_req_dly[0] &  in_pause_req_dly[1]);
        always@(posedge clk) begin if (~reset_n) in_pause_req_dly <= 2'd0; 
	else in_pause_req_dly[1:0]<= {in_pause_req_dly[0],pause_req}; end 
    
    // _____________________________________________________________________
    //	indication for transmitted xon and xoff frames
	always@(posedge clk) begin tx_xoff <= xoff_frame; tx_xon <= xon_frame; end
    // _____________________________________________________________________
	always@(posedge clk or negedge reset_n)
	     begin
		if (~reset_n) 
		    begin
			state <= IDL;
			count <= 17'd0;
		    end
		else if (cfg_enable)
		    begin
			state <= next_state;
			count <= next_count;
		    end
		else //if (cfg_enable)
		    begin
			state <= IDL;
			count <= 17'd0;
		    end
	     end

	always@(*)
	    begin
		next_state = state;
		next_count = count;
		case(state)
		IDL:begin
		      next_count = 17'd0;
		      if(xoff_req)
		      begin
		         next_state = XOF;
		         next_count = 17'd0;
		      end
		      else
		       begin
		          next_state = state;
		          next_count = count;
		       end
		    end
		XOF:begin
		     // once entered this state, the fsm will remain
		     // in xoff, until the xoff pause frame has been sent
		     // by the link fsm - indicated by the pause_txin_done
		     
		     // if congestion is removed by the time xoff frame
		     // is sent, fsm will take immediate action to send
		     // an xon frame - even if holdoff is enabled

		     //	otherwise - if priority hold off is enabled,fsm
		     //	will move to holdoff state and hence delay
		     //	the next opportunity to resend the pause frame
		     //	at the end of the hold off period
		     
		        next_count = 17'd0;
			if (pause_txin_done & xon_req) next_state = XON;
			else if (pause_txin_done & cfg_holdoff_en) next_state = HLD;
			else if (pause_txin_done & xoff_req) next_state = XOF;
			else if (pause_txin_done) next_state = IDL;
			else next_state = XOF;
		     end
		XON: begin
		     //	the buffer congestion does not exist anymore
		     //	send last pause frame with null pause quanta
		     // though the ingress buffer is practically never
		     // expected to be filled again just between xoff
		     // and xonn states - however - this design does
		     // respond to a buffer full signal and moves to the
		     // xoff state. If no buffer full it moves to idle
			if(pause_txin_done & xoff_req) next_state = XOF;
			else if (pause_txin_done) next_state = IDL;
			else next_state = state;
		     end
		HLD:begin
		     // during a HOLDOFF state, if buffer_full flag is cleared
		     // exit the state to send an xon frame
		     // ehen hold period is done and the fsm should be ready
		     // assert request xoff to lfsm if buffer still filled
			next_count = count + 17'd1;
			if (xon_req)  next_state = XON;
			else if (holdoff_done & xoff_req) next_state = XOF;
			else if (holdoff_done)  next_state = IDL;
			else next_state = state;
		    end
		default:begin
			next_state = state;
			next_count = count;
		    end
	     endcase
	  end		// always begin
	    
 
 // ___________________________________________________________________________
 //
 //	synopsys translate_off
   reg[79:0] FSM;
   always@(*)
      begin
	 case(state)
	    IDL: FSM = "IDL";
	    XOF: FSM = "XOF";
	    XON: FSM = "XON";
	    HLD: FSM = "HLD";
	 endcase
      end
 //	synopsys translate_on

 endmodule


