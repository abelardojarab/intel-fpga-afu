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


// altera message_off 10036 10236
// altera message_off 10230	

`timescale 1 ps / 1 ps
 module alt_aeu_40_pfc_tx_lctrl #(
      parameter WORDS = 4,
      parameter EMPTYBITS = 5,
      parameter NUMPRIORITY = 2,
      parameter PREAMBLE_PASS = 1,
      parameter READY_LATENCY = 1,
      parameter PFC_BUFF_READ_LATENCY = 1
 )(
      input clk,
      input reset_n,

      input out_ready,
      output in_ready,
      input pkt_end,
       
      input cfg_enable,
      input cfg_holdoff_en,
      input [15:0] cfg_holdoff_quanta, 	// link holdoff
      input [NUMPRIORITY-1:0] queue_pause_req,
      input [NUMPRIORITY*16-1:0] queue_pause_quanta,

      input [47:0] cfg_saddr,
      input [47:0] cfg_daddr,
      input [15:0] cfg_typlen,
      input [15:0] cfg_opcode,
        
      output [NUMPRIORITY-1:0] pause_txin_done,
      output sel_in_pkt,
      output sel_pfc_pkt,
      output sel_store_pkt,
      output out_pfc_valid,
      output [8*64-1:0] out_pfc_data, // PFC data width 512; does not fit in 4 words
      output [EMPTYBITS-1:0] out_pfc_empty
 );

	localparam PRMBL = 64'hfbaaaaaaaaaaaaab;
	// CALCULATION BELOW SEEMS WRONG: PACKET IS ALWAYS MINIMUM SIZE, NOT SMALLER
	localparam PFCBYTES = 6+6+2+2+2+2*NUMPRIORITY;	// 18 + 2*N Bytes = 20-34Bytes
	localparam EMPTYBYTES = (WORDS == 8)				    	    	   ?  WORDS*8-PFCBYTES-PREAMBLE_PASS*8:
			      ( (WORDS == 4) && (PREAMBLE_PASS == 1) && (NUMPRIORITY <  4))?  6-2*NUMPRIORITY 	 : //    WORDS*8 - 1*8 - PFCBYTES = 32-8-(18 + 2*N) = 6-2*N; n<=3
			      ( (WORDS == 4) && (PREAMBLE_PASS == 1) && (NUMPRIORITY >= 4))?  2*NUMPRIORITY-6	 : //    1*8 - PFCBYTES - 8*WORDS = 8+(18 + 2*N) - 32 = 2*N-6; n>=4
			      ( (WORDS == 4) && (PREAMBLE_PASS == 0) && (NUMPRIORITY <  8))?  14-2*NUMPRIORITY	 : //    WORDS*8 - PFCBYTES = 32 - (18 + 2*N) = 14-2*N; n<=7
			      ( (WORDS == 4) && (PREAMBLE_PASS == 0) && (NUMPRIORITY == 8))?  2			 : //    WORDS*8 - PFCBYTES = (18 + 2*8) - 8*4 = 34-32 = 2
										               WORDS*8-PFCBYTES-PREAMBLE_PASS*8; // first option

	localparam IDLE   = 3'd0,
		WAIT   = 3'd1,
		STALL  = 3'd2,
		INSERT = 3'd4,
		DRAIN  = 3'd5,
		HLDOFF = 3'd6,
		DONE   = 3'd7;

	reg[2:0] state;
	reg[16:0] count;

	wire pfc_insert_done = (count == 17'd0);
	// 40G is only 4 words (256 bits) wide, so each quanta is two cycles
    // NOTE: WIDTH IS WRONG; NEED TO FIX
	wire[16:0] holdoff_cycles = {cfg_holdoff_quanta, 1'b0}; // quanta == 512 bits == 2 words
	reg[NUMPRIORITY-1:0] queues_served;
	wire link_pause_req = |queue_pause_req;
	always@(posedge clk ) begin  
		if (sel_pfc_pkt) begin
			queues_served <= queue_pause_req;
		end
	end

	// the link pfc done must be asserted aligned with the last cycle of DRAIN
	// so that the priority fsm has already changed state to xoff/xon or idle 
	// and have asserted the pause_priority_en signal by the time this fsm is
	// in the DONE state
	// wire data_pass_state = (state == IDLE)||(state == WAIT)||(state == DONE)||(state == HLDOFF);

	assign pause_txin_done = ((state == DONE)&&(!(|count)))? queues_served:{NUMPRIORITY{1'b0}};
	wire traffic_stall_done = (count == 17'd0);
	wire lane_holdoff_done = (count ==  17'd0);
	wire drain_buff_done = (count ==  17'd0);

	wire stall_input_pipe = (state == STALL) || (state == INSERT) || (state == DRAIN);
	assign in_ready = ~stall_input_pipe;

	assign sel_pfc_pkt = (state == INSERT);
	assign sel_in_pkt = ~stall_input_pipe;
	assign sel_store_pkt = (state == DRAIN);

	always@(posedge clk or negedge reset_n) begin
		if (~reset_n) begin
			// while in reset, all controls must
			// be generated to let the incoming
			// traffic be passed without any cange
			// pass on the back pressure from out
			// to in and the data from in to out 
			// without any modification anywhere
			state <= IDLE;
			count <= 17'd0;
		end else if (out_ready & cfg_enable) begin
			// until the pfc sink is ready to receive
			// freeze the state machine and forward
			// the back pressure to the input port
			case (state)
				IDLE:
					if (link_pause_req & pkt_end) begin
						state <= INSERT;
						count <= 17'd1;
					end else if (link_pause_req) begin
						// if pause insertion request is received
						// while a packet is in progress, simply
						// wait for the packet to complete transmission
						count <= 17'd0;
						state <= WAIT;
					end else begin
						count <= 17'd0;
						state <= IDLE;
					end
				WAIT:
					// link_pause_req must remain asserted in
					// a true case of ingress buffer congestion
					// if this is not true, assert a warning and
					// move back to IDLE state (recovery mechanism)
					if (~link_pause_req) begin
						count <= 17'd0; 
						state <= IDLE;
						$display ("%m WARNING: link_pause_request was de-asserted before a pause frame was sent \n");
					end else if (pkt_end) begin
						// a packet boundary has been found
						// move to stall the input pipe and
						// then to the pause/pfc INSERT state
						state <= INSERT;
						count <= 17'd1;
					end else begin
						// just wait and do nothing
						state <= state;
						count <= count;
					end
				STALL:
					// stall the incoming traffic and when necessary
					// buffer any head-end of a packet that might've
					// started after b/p was asserted. Select the i/p
					// buffer depth accordingly. This implementation
					// assumes a 0 cycle ready latency
					if (traffic_stall_done) begin
						// house keeping related to stalling the pipe
						// has been done and now is the time to move
						// to the insertion of pause frames next
						state <= INSERT;
						count <= 17'd1;
					end else begin
						// maintain the state, keep counting and
						// keep the input pipe stalled
						state <= state;
						count <= count - 17'd1;
					end
				INSERT:
					if (pfc_insert_done) begin
						// now move to drain the head-end of a new pkt
						// that might have started around the boundary
						// and then eventually to repeat the fsm cycles
						// in pipe will continue to be stalled in drain
						state <= DRAIN;
						count <= (READY_LATENCY+PFC_BUFF_READ_LATENCY-2);
					end else begin
						// continue the process of pause frame insertion
						// until it is all completed. Depending on the
						// width of the input pipe, it may take one or
						// more cycles to complete this job - so keep
						// counting.....
						state <= state;
						count <= count - 17'd1;
					end
				DRAIN:
					if (drain_buff_done & cfg_holdoff_en) begin
						state <= HLDOFF;
						count <= holdoff_cycles;
					end else if (drain_buff_done) begin
						state <= DONE;
						count <= 17'd0;
					end else begin
						// keep counting and keep the
						// pipe stalled while draining
						state <= state;
						count <= count - 17'd1;
					end
				HLDOFF:
					if (lane_holdoff_done) begin
						// the hold period is done and the LFSM should be ready
						// to process fifo_full request from any ingress buffer
						// if they are present.
						state <= DONE;
						count <= 17'd0;
					end else begin
						// continue this state
						state <= state;
						count <= count - 17'd1;
					end
				DONE:
					// this is a single cycle state after PFC transmission 
					// and/or link hold-off timer is done 
					// this state is created to mark the insertion of one 
					// pause frame for a reported ques(s) congestions. The
					// fsm returns to IDLE and will initiate another cycle
					begin
						count <= 17'd0;
						state <= IDLE;
					end
				default:
				begin
					state <= state;
					count <= count;
				end
			endcase
		end else begin
			// if it is neither enabled nor the ready signal is asserted
			count <= count;
			state <= state;
		end
	end	// always begin
	
 //   _______________   _________________________   ___________________   __________   _____
 //  /               \ /                         \ /                   \ /          \ /
 // X da[5:0],sa[5:4] X sa[3:0],typ[1:0],opc[1:0] X   penv, pq0,1,2     X   pq[3:6]  X  pq[7]        
 //  \_______________/ \_________________________/ \___________________/ \__________/ \______

   wire[15:0] pfc_ena = {16'd0,queue_pause_req};
   wire[16*NUMPRIORITY-1:0] pfc_quanta;
   genvar i;
   generate for (i=0; i< NUMPRIORITY; i=i+1)
	begin:rev
	      assign pfc_quanta[16*(NUMPRIORITY-i)-1:16*(NUMPRIORITY-i-1)] = queue_pause_quanta[16*(i+1)-1:16*i];
	end
   endgenerate

	// CHANGE THIS - WRONG
	assign out_pfc_empty = EMPTYBYTES;
	assign out_pfc_valid = sel_pfc_pkt;
	// CHANGE CALCULATION OF PAD LENGTH; NOT FUNCTION OF NUMBER OF QUEUES
	// CHANGE IT BACK; EASIER THAN CALCULATING SPACE FOR UNUSED QUEUES
	localparam PKTBYTES = 6+6+2+2+2+2*NUMPRIORITY;
	// NEED TO CHANGE BELOW SO IT INCLUDES THE SPACE TAKEN BY UNUSED QUEUES
	localparam PADBYTES = 8*8-(PKTBYTES + PREAMBLE_PASS*8);
	wire [PADBYTES*8-1:0] pfc_padding = {8*PADBYTES{1'b0}};
	assign out_pfc_data = (PREAMBLE_PASS == 1) ? 
		{PRMBL,cfg_daddr, cfg_saddr, cfg_typlen, cfg_opcode, pfc_ena,pfc_quanta,pfc_padding} :
		{cfg_daddr, cfg_saddr, cfg_typlen, cfg_opcode, pfc_ena,pfc_quanta,pfc_padding};

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
