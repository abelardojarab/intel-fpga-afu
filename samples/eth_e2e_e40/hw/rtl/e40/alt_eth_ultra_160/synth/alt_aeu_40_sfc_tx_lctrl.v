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
// $Id: alt_aeu_40_sfc_tx_lctrl.v,v 1.4 2015/02/23 21:51:59 marmstro Exp marmstro $
// $Revision: 1.4 $
// $Date: 2015/02/23 21:51:59 $
// $Author: marmstro $
// Copyright(C) 2013: Altera Corporation
// Altera corporation Confidential 
// ____________________________________________________________________
// altera message_off 10036 10236
// altera message_off 10230	

 module alt_aeu_40_sfc_tx_lctrl 
     #(
       parameter WORDS = 8 
      ,parameter EMPTYBITS = 6 
      ,parameter FCBITS = 2 
      ,parameter INC_PRMBL = 1 
      ,parameter READY_LATENCY = 3'd1  
      ,parameter PFC_BUFF_READ_LATENCY = 3'd1  
      )(
       input  wire clk 
      ,input  wire reset_n 

      ,input wire out_ready 
      ,output wire in_ready 
      ,input wire pkt_end 
       
      ,input wire cfg_enable_txins 
      ,input wire cfg_enable_txoff 
      ,input wire[FCBITS-1:0] queue_pause_req 
      ,input wire[FCBITS*16-1:0] queue_pause_quanta 
      ,input wire rx_txoff_req	

       ,input wire[47:0] cfg_saddr 
       ,input wire[47:0] cfg_daddr 
       ,input wire[15:0] cfg_typlen 
       ,input wire[15:0] cfg_opcode 
        
       ,output wire pause_tx_done 
       ,output wire sel_in_pkt 
       ,output wire sel_pause_pkt 
       ,output wire sel_store_pkt 
       ,output wire out_pause_valid 
       ,output wire[WORDS*64-1:0] out_pause_data
       ,output wire[EMPTYBITS-1:0] out_pause_empty 
      );

 // ______________________________________________________________________________________
	localparam SRC_READY_LATENCY = 3'd0;
	localparam PRMBL = 64'hfbaaaaaaaaaaaaab;
 // ______________________________________________________________________________________
	localparam IDLE   = 3'd0
		 , WAIT   = 3'd1
		 , STALL  = 3'd2
		 , INSERT = 3'd4
		 , DRAIN  = 3'd5
		 , HLDOFF = 3'd6
		 , DONE   = 3'd7;
        localparam pausecycles = 3'd1;
 // ______________________________________________________________________________________
	reg[2:0] state;
	reg[18:0] count;

	wire pause_insert_done = (count ==0); 
        wire sync_rxtxoff_req;

        alt_aeu_40_status_sync #(.WIDTH(1)) sync_rxpause_req (.clk(clk), .din(rx_txoff_req & cfg_enable_txoff), .dout(sync_rxtxoff_req));

        wire [FCBITS-1:0] pause_req = queue_pause_req;
   	wire link_pause_req = |pause_req & cfg_enable_txins;

	wire traffic_stall_done = !sync_rxtxoff_req; 
  	wire drain_buff_done = (count == 0); 
	reg  stall_input_pipe;

  	assign in_ready = ~stall_input_pipe;
	assign pause_tx_done = (out_ready) && (state == DONE) && (count == 0); 

	assign sel_in_pkt = ~stall_input_pipe;
	assign sel_pause_pkt = (state == INSERT);
	assign sel_store_pkt = (state == DRAIN);

	always@(posedge clk or negedge reset_n) begin
	    if (~reset_n) 
  		begin
		    state <= IDLE;
		    count <= 19'd0;
		    stall_input_pipe <= 1'b0;
	    	end
	    else if (out_ready) 
	    // until the pause sink is ready to receive
	    // freeze the state machine and forward
	    // the back pressure to the input port
		begin
	        case (state)
		   IDLE:
		   if (sync_rxtxoff_req & pkt_end)
		   	begin
		          state <= STALL; 
		          count <= 19'd0;
		    	  stall_input_pipe <= 1'b1;
		   	end
		   else if (link_pause_req & pkt_end)
		   	begin
			  state <= INSERT;
			  count <= pausecycles-3'd1;
		    	  stall_input_pipe <= 1'b1;
		   	end
		   else if (link_pause_req)
		   // if pause insertion request is received
		   // while a packet is in progress, simply
		   // wait for the packet to complete transmission
		   	begin
		          count <= 19'd0;
		          state <= WAIT;
		          stall_input_pipe <= 1'b0;
		          //in_ready <= out_ready;
		   	end
		   else 
		   	begin
		          count <= 19'd0;
		          state <= IDLE;
		    	  stall_input_pipe <= 1'b0;
		          //in_ready <= out_ready;
		   	end
		   WAIT:
		   if (sync_rxtxoff_req & pkt_end)
		   // need to stop egress traffic as
		   // requested by the ingress pause
		   // processing logic 
		   	begin
		          state <= STALL; 
		          count <= 19'd0;
		    	  stall_input_pipe <= 1'b1;
		          //in_ready <= 1'b0;
		   	end
		   else if (~link_pause_req)  
		   // link_pause_req must remain asserted in
		   // a true case of ingress buffer congestion
		   // if this is not true, assert a warning and
		   // move back to IDLE state (recovery mechanism)
			begin
		             count <= 0;
		             state <= IDLE;
		    	     stall_input_pipe <= 1'b0;
		             //in_ready <= out_ready;
		             $display ("%m WARNING: link_pause_request was de-asserted before a pause frame was sent \n");
		   	end
		   else if (pkt_end) 
			// a packet boundary has been found
			// move to stall the input pipe and
			// then to the pause/pause INSERT state
			begin
			  state <= INSERT;
		    	  stall_input_pipe <= 1'b1;
			  count <= pausecycles-3'd1;
		     	end
		   else // just wait and do nothing
			begin
		           state <= state;
		           count <= count;
		           //in_ready <= out_ready;
		      	end
		   STALL:
		   if (link_pause_req) 
 		   // handle pause insert request even if in STALL state
			begin
			    state <= INSERT;
		            stall_input_pipe <= 1'b1;
			    count <= pausecycles-3'd1;
			end
		   else if (traffic_stall_done) 
		  // if not, just move to IDLE
		    	begin
		      	   state <= IDLE;
		      	   count <= 0 ;
		    	   stall_input_pipe <= 1'b0;
		    	end
		   else // maintain the state, keep counting and
			// of course keep the input pipe stalled
		    	begin
		      	   state <= state;
		      	   count <= count - 19'd1;
		      	   //in_ready <= 1'b0;
		    	end
		   INSERT:
		   if (pause_insert_done) 
			// now move to drain the head-end of a new pkt
			// that might have started around the boundary
			// and then eventually to repeat the fsm cycles
			// in pipe will continue to be stalled in drain
			begin
		    	    state <= DRAIN;
		    	    count <= (READY_LATENCY+PFC_BUFF_READ_LATENCY-2); 
		            stall_input_pipe <= 1'b1;
		    	    //in_ready <= 1'b0;
		       	end 
		   else  
			// continue the process of pause frame insertion
			// until it is all completed. Depending on the
			// width of the input pipe, it may take one or
			// more cycles to complete this job - so keep
			// counting.....
			begin
		    	    state <= state;
		    	    count <= count - 19'd1;
		            stall_input_pipe <= 1'b1;
		    	    //in_ready <= 1'b0;
		  	end
		    DRAIN:
		    if (drain_buff_done) 
		    	begin
		       	   state <= DONE;
		       	   count <= 19'd0;
		           stall_input_pipe <= 1'b1;
		       	   //in_ready <= out_ready;
		    	end
		    else 
		    	begin
		    	// keep counting and keep the
		    	// pipe stalled while draining
		           state <= state;
		           count <= count - 19'd1;
		           stall_input_pipe <= 1'b1;
		           //in_ready <= 1'b0;
		    	end
		    DONE:
			// this is a single cycle state after PFC transmission 
			// this state is created to mark the insertion of one 
			// pause frame for a reported ques(s) congestions. The
			// fsm returns to IDLE and will initiate another cycle
			// if queue conegstions still persist.  If we are in rxtx_off
			// condition, go back to STALL state
		    if (sync_rxtxoff_req) 
			begin
		       	    state <= STALL;
		       	    count <= 19'd0;
		            stall_input_pipe <= 1'b1;
		       	    //in_ready <= out_ready;
		    	end else
			begin
		       	    state <= IDLE;
		       	    count <= 19'd0;
		            stall_input_pipe <= 1'b0;
		       	    //in_ready <= out_ready;
		    	end
		    default:
			begin
			    state <= state;
			    count <= count;
		            stall_input_pipe <= 1'b0;
			    //in_ready <= out_ready;
			end
		   endcase
	        end
	    else 	// if it is neither enabled nor the ready signal is asserted
	         begin
		    count <= count;
		    state <= state;
		    stall_input_pipe <= stall_input_pipe;
		    //in_ready <= out_ready;
	         end
	    end	// always begin
	    
   wire[15:0] pause_ena = {15'd0,pause_req};
   wire[16*FCBITS-1:0] pause_quanta ;
   genvar i; 
   generate for (i=0; i< FCBITS; i=i+1) 
      begin : pquanta
	 assign pause_quanta[16*(FCBITS-i)-1:16*(FCBITS-i-1)] = queue_pause_quanta[16*(i+1)-1:16*i]; 
      end 
   endgenerate

  localparam PAUSE_EMPTY =  8*WORDS -18;
   generate
       if (INC_PRMBL == 1) 
          begin:inc_prmble
   	     wire[(8*WORDS -18 -8*INC_PRMBL)*8-1:0] pause_padding = {((8*WORDS -18 -8*INC_PRMBL)*8){1'b0}}; /*synthesys keep */ 
	     assign out_pause_empty = PAUSE_EMPTY - 8;
	     assign out_pause_valid = sel_pause_pkt;
   	     assign out_pause_data = {PRMBL, cfg_daddr, cfg_saddr, cfg_typlen, cfg_opcode, pause_quanta,pause_padding};
          end
       else 
          begin: no_prmble
   	     wire[(8*WORDS -18 -8*INC_PRMBL)*8-1:0] pause_padding = {((8*WORDS -18 -8*INC_PRMBL)*8){1'b0}}; /*synthesys keep */ 
	     assign out_pause_empty = PAUSE_EMPTY - 8;
	     assign out_pause_valid = sel_pause_pkt;
   	     assign out_pause_data = {cfg_daddr, cfg_saddr, cfg_typlen, cfg_opcode, pause_quanta,pause_padding};
          end
   endgenerate
   
 // synopsys translate_off
   reg[79:0] FSM;
   always@(state)
      begin
	 case(state)
	    IDLE: FSM = "IDLE";
	    STALL: FSM = "STALL";
	    INSERT: FSM = "INSERT";
	    DRAIN: FSM = "DRAIN";
	    WAIT: FSM = "WAIT";
	    DONE: FSM = "DONE";
	    HLDOFF: FSM = "HLDOFF";
	    default: FSM = "FIXIT";
	 endcase
      end
 // synopsys translate_on

 endmodule


