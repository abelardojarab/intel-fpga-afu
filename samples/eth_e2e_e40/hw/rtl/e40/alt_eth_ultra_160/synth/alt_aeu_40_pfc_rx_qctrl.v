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
module alt_aeu_40_pfc_rx_qctrl (
	input        clk,
	input        reset_n,
	input        cfg_enable,
	input        pause_valid,
	input[15:0]  pause_quanta,
	output reg	   rx_xoff_frame,
	output reg	   rx_xon_frame,
	output reg 	   rx_out_pause
);

	parameter XON = 2'd0, 
		WAIT = 2'd1, 
		XOFF = 2'd2;
	reg[1:0] state, next_state;
	reg[16:0] pause_timer;
	
	wire 	xoff_time_up = (state == XOFF) && (pause_timer == 17'd0);
	wire	go_xoff = (pause_valid) &  (|pause_quanta);
	wire	go_xon  = (pause_valid) & ~(|pause_quanta);
	
	always@(*) begin
		next_state = state;
		case (state)
			XON:begin
				if(go_xoff) next_state = XOFF;
				else next_state = state;
			end
			XOFF:begin
				// stay in pause until the timer has been 
				// completely exhausted
	
				// during a pause state, the pause timer does
				// get dynamically updated if there is a valid
				// new pause quanta received. It is however a
				// possibility that rx_xoff_frame and 
				// the pause_time_done pulses can collide - the 
				// fsm must give priority to rx_xoff_frame
				// FSM remain in the pause state and should service
				// the new pause_quanta value arrived
	
				if(go_xoff) next_state = XOFF;
				else if(go_xon | xoff_time_up) next_state = XON;
				else next_state = state;
			end
		endcase
	end
	
	always@(posedge clk or negedge reset_n) begin
		if (~reset_n) begin
			state <= XON;
		end else begin
			state<= next_state;
		end
	end
	
	// the pause_timer must always be updated when a valid
	// pause_valid pulse is received by this module
	// In all other states, the pause_quanta is just updated
	// It is only the pause state when the pause_timer counts
	
	wire pause_timer_ena = (state == XOFF);
	
	// for 256-bit interface the pause quanta translates to 4 cycle for each quanta
	// Make timer 17 bits to support full quanta setting
	wire[16:0] pause_cycles = (pause_quanta << 2);
	
	always@(posedge clk or negedge reset_n) begin
		if (~reset_n) pause_timer <= 17'd0;
		else if(go_xoff) pause_timer <= pause_cycles;
		else if(go_xon) pause_timer <= 17'd0; //
		else if(pause_timer_ena) pause_timer <= pause_timer - 17'd1;
	end
	
	wire rx_pause = (state == XOFF);
	always@(posedge clk or negedge reset_n) begin
		if (~reset_n) begin
			rx_xoff_frame <= 1'b0;
			rx_xon_frame <= 1'b0;
			rx_out_pause <= 1'b0;
		end else begin
			rx_xoff_frame <= go_xoff;
			rx_xon_frame  <= go_xon;
			rx_out_pause <=  cfg_enable & rx_pause;
		end
	end
	
	//	synopsys translate_off
	reg[79:0] FSM;
	always@(state) begin
		case(state)
			XON: FSM = "XON";
			WAIT: FSM = "WAIT";
			XOFF:FSM = "XOFF";
		endcase
	end
	//	synopsys translate_on

endmodule
