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



`timescale 1 ps / 1 ps

module alt_e100s10_tx_fc_arbiter_ctrl
#(
    parameter WORDS = 4, //25G = 1, 50G = 2, 100G = 4
    parameter EMPTYBITS = 6, //25G = 3, 50G = 6, 100G = 6
    parameter NUMPRIORITY = 1,
    parameter PREAMBLE_PASS = 0,
    parameter ALLOCATE_4B_CRC = 1 //1=allocate crc for pause/pfc frame ==>64B of packet not including preamble
                                  //0=do not allocate crc for pause/pfc frame ==> 60B of packet not including preamble      
)(
    input clk,
    input reset_n,
    
    input out_ready,
    input data_valid,
    output reg txoff_req,
    input txoff_ack,
    
    input [NUMPRIORITY-1:0] cfg_enable,
    input [NUMPRIORITY-1:0] queue_pause_req,
    input [NUMPRIORITY*16-1:0] queue_pause_quanta,
    
    input cfg_pfc_sel, //1=pfc, 0=pause
    input [47:0] cfg_saddr,
    input [47:0] cfg_daddr,
    
    input stall_req,
    output reg stall_ack,
    input traffic_stall_done,
    
    output reg [NUMPRIORITY-1:0] pause_txin_done,
    output reg fc_sel,
    
    output out_pfc_sop,
    output out_pfc_eop,
    output out_pfc_valid,
    output [511:0] out_pfc_data,
    output [EMPTYBITS-1:0] out_pfc_empty
);

 // ______________________________________________________________________________________
	localparam PRMBL = 64'hFB555555555555D5;
    localparam TYPLEN = 16'h8808;

   	//skyeow: review this later
    //for 25G, packet length is as following
    //no preamble pass thru and no crc pre-allocate, packet length = 60 ==> 8 clock cycles and 4 empty bytes
    //no preamble pass thru and with crc pre-allocate, packet length = 64 ==> 8 clock cycles and 0 empty bytes
    //preamble pass thru and no crc pre-allocate, packet length = 68 ==> 9 clock cycles and 4 empty bytes
    //preamble pass thru and with crc pre-allocate, packet length = 72 ==> 9 clock cycles and 0 empty bytes
    
    //for 50G, packet length is as following
    //preamble pass thru is separate bus and will not affect packet length
    //no crc pre-allocate, packet length = 60 ==> 4 clock cycles and 4 empty bytes
    //with crc pre-allocate, packet length = 64 ==> 4 clock cycles and 0 empty bytes    

    //for 100G, packet length is as following
    //in preamble pass thru mode, preamble will take up the first 8 bytes
    //it does not support CRC pass-through mode
    //so pkt length is set to 60.
    //It relies on the padding logic to make it to 64 byte frame for preamble pass-through mode
    //localparam PACKET_LENGTH = (WORDS ==1 & PREAMBLE_PASS == 0 & ALLOCATE_4B_CRC == 0) ? 60: //25G
    //                           (WORDS ==1 & PREAMBLE_PASS == 0 & ALLOCATE_4B_CRC == 1) ? 64: //25G
    //                           (WORDS ==1 & PREAMBLE_PASS == 1 & ALLOCATE_4B_CRC == 0) ? 68: //25G
    //                           (WORDS ==1 & PREAMBLE_PASS == 1 & ALLOCATE_4B_CRC == 1) ? 72: //25G
    //                                                            (ALLOCATE_4B_CRC == 0) ? 60:64; //50G
    localparam PACKET_LENGTH = 60; //100G
    //localparam PFCCYCLES = (WORDS ==1 & PREAMBLE_PASS == 1) ? 4'd9://25G
    //                       (WORDS ==1 & PREAMBLE_PASS == 0) ? 4'd8://25G
    localparam PFCCYCLES = 4'd1;//100G
	//localparam EMPTYBYTES = (ALLOCATE_4B_CRC == 1) ? 3'h0 : 3'h4; //same for 25G and 50G
	localparam EMPTYBYTES = 6'h4; //100G
    
    //number of PFC/Pause bytes with info
    //no preamble, PFC mode, PFCbyte count = 6B(SA) + 6B(DA) + 2B(TYPE) + 2B(OP) + 2B(EN) + 2B*NUMPRIORITY(QUANTA) = 20B to 34B 
    //with preamble, PFC mode, PFCbyte count = 8B(PREA) + 6B(SA) + 6B(DA) + 2B(TYPE) + 2B(OP) + 2B(EN) + 2B*NUMPRIORITY(QUANTA) = 28B to 42B 
    //no preamble, PAUSE mode, PFCbyte count = 6B(SA) + 6B(DA) + 2B(TYPE) + 2B(OP) + 2B(QUANTA) = 18B 
    //with preamble, PAUSE mode, PFCbyte count = 6B(SA) + 6B(DA) + 2B(TYPE) + 2B(OP) + 2B(QUANTA) = 26B 
    //localparam PFC_INFO_LENGTH = (WORDS ==1 & PREAMBLE_PASS == 1) ? 26 + 2*NUMPRIORITY : 18 + 2*NUMPRIORITY;
    //localparam PAUSE_INFO_LENGTH = (WORDS ==1 & PREAMBLE_PASS == 1) ? 26 : 18;
    localparam PFC_INFO_LENGTH = (PREAMBLE_PASS == 1) ? 26 + 2*NUMPRIORITY : 18 + 2*NUMPRIORITY;
    localparam PAUSE_INFO_LENGTH = (PREAMBLE_PASS == 1) ? 26 : 18;
    
    //number of padding bytes to make byte number an even number of clock cycle
    localparam PFC_PADDING_BYTES = PACKET_LENGTH - PFC_INFO_LENGTH + EMPTYBYTES;
    localparam PAUSE_PADDING_BYTES = PACKET_LENGTH - PAUSE_INFO_LENGTH + EMPTYBYTES;
    // ______________________________________________________________________________________
	localparam IDLE   = 3'd0,
		       WAIT   = 3'd1,
		       STALL  = 3'd2,
		       INSERT = 3'd4,
		       DONE   = 3'd5;
 // ______________________________________________________________________________________
	reg [2:0] state;
	reg [3:0] count;

	wire pfc_insert_done = (count == 4'd0);
	//wire pfc_insert_done_1cyle_earlier = (count == 4'd1);
	reg pfc_insert_done_1cyle_earlier;

    // ________________________________________________________________________________________________________________
    reg [NUMPRIORITY-1:0] queues_served;
    //reg link_pause_req;
    //in pause mode, the request from 1-7 should not impact this.
    //always @ (posedge clk ) begin
   	//    link_pause_req <= cfg_pfc_sel ? |queue_pause_req : queue_pause_req[0];
    //end
    wire link_pause_req;
    assign link_pause_req = cfg_pfc_sel ? |queue_pause_req : queue_pause_req[0];
    //only load queues_served when not in INSERT state
    //this is to in sync with out_pfc_data_reg also load when not in INSERT state
	always @ (posedge clk ) begin
        if (state != INSERT) queues_served <= queue_pause_req;
    end
    // ________________________________________________________________________________________________________________

	// the link pfc done must be asserted aligned with the last cycle of DRAIN
	// so that the priority fsm has already changed state to xoff/xon or idle 
	// and have asserted the pause_priority_en signal by the time this fsm is
	// in the DONE state


    // ________________________________________________________________________________________________________________
    // synchronous reset 
	always@(posedge clk) begin
	    if (~reset_n) begin
		    // while in reset, all controls must
		    // be generated to let the incoming
		    // traffic be passed without any cange
		    // pass on the back pressure from out
		    // to in and the data from in to out 
		    // without any modification anywhere
		    state <= IDLE;
		    count <= 4'd0;
            txoff_req <= 1'b0;
            fc_sel <= 1'b0;
            stall_ack <= 1'b0;
            pause_txin_done <= 1'b0;
            pfc_insert_done_1cyle_earlier <= 1'b0;
	    end else begin
            if (out_ready & data_valid) begin
	    	    // until the pfc sink is ready to receive
		        // freeze the state machine and forward
		        // the back pressure to the input port                
	            case (state)
		        IDLE:begin
		            if (link_pause_req | stall_req) begin
		                // if pause insertion or stop tx request is received
		                // while a packet is in progress, simply
		                // wait for the packet to complete transmission                    
		                count <= 4'd0;
		                state <= WAIT;
                        txoff_req <= 1'b1;
		            end else begin
		                count <= 4'd0;
		                state <= IDLE;
                        txoff_req <= 1'b0;
		            end
                    fc_sel <= 1'b0;
                    stall_ack <= 1'b0;
                    pause_txin_done <= 1'b0;
                    pfc_insert_done_1cyle_earlier <= 1'b0;
                end
		        WAIT:begin
                    if (stall_req & txoff_ack) begin
			            // a packet boundary has been found
			            // move to the stall state                    
			            state <= STALL;
			            count <= 4'd0;
                        txoff_req <= 1'b1;
                        fc_sel <= 1'b0;
                        stall_ack <= 1'b1;
                        pfc_insert_done_1cyle_earlier <= 1'b0;
		            end else if (link_pause_req & txoff_ack) begin
			            // a packet boundary has been found
			            // move to the pause/pfc INSERT state
			            state <= INSERT;
                        pfc_insert_done_1cyle_earlier <= 1'b1;
			            count <= PFCCYCLES-4'd1;
                        txoff_req <= 1'b1;
                        fc_sel <= 1'b1;
                        stall_ack <= 1'b0;
                    end else if (~link_pause_req & ~stall_req) begin
		                // link_pause_req or stall_req must remain asserted
		                // if this is not true, assert a warning and
		                // move back to IDLE state (recovery mechanism)
		                count <= 4'd0;
		                state <= IDLE;
                        txoff_req <= 1'b0;
                        fc_sel <= 1'b0;
                        stall_ack <= 1'b0;
                        pfc_insert_done_1cyle_earlier <= 1'b0;
                        // synthesis translate_off
		                $display ("%m WARNING: link_pause_request/stall_req was de-asserted before a pause frame was sent/traffic stalled \n");
                        // synthesis translate_on
		            end else begin
			            // just wait and do nothing - not even counting sheeps :)
			            state <= state;
		                count <= count;
                        txoff_req <= txoff_req;
                        fc_sel <= fc_sel;
                        stall_ack <= stall_ack;
                        pfc_insert_done_1cyle_earlier <= 1'b0;
		            end
                    pause_txin_done <= 1'b0;
                end
		        STALL:begin
                    if (link_pause_req) begin
                        //during stall state, if link_pause_req is asserted
                        //the state must move to insert state to serve that request
			            state <= INSERT;
                        pfc_insert_done_1cyle_earlier <= 1'b1;
			            count <= PFCCYCLES-4'd1;
                        txoff_req <= 1'b1;
                        fc_sel <= 1'b1;
                        stall_ack <= 1'b1;
		            end else if (traffic_stall_done) begin
                        //after stall counter expired, the state shall move to idle sstate
			            state <= IDLE;
			            count <= 4'd0;
                        txoff_req <= 1'b0;
                        fc_sel <= 1'b0;
                        stall_ack <= 1'b0;
                        pfc_insert_done_1cyle_earlier <= 1'b0;
			        end else begin
                        // maintain the state, keep counting and
			            // of course keep the input pipe stalled
		             	state <= state;
		               	count <= count;
                        txoff_req <= txoff_req;
                        fc_sel <= fc_sel;
                        stall_ack <= stall_ack;
                        pfc_insert_done_1cyle_earlier <= 1'b0;
		            end
                    pause_txin_done <= 1'b0;
                end
		        INSERT:begin
		            if (pfc_insert_done) begin
                        //sending pfc/paause packet done, move to done state
		             	state <= DONE;
		             	count <= 4'd0;
                        fc_sel <= 1'b0;
                        pfc_insert_done_1cyle_earlier <= 1'b0;
		            end else begin
			            // continue the process of pause frame insertion
			            // until it is all completed. Depending on the
			            // width of the input pipe, it may take one or
			            // more cycles to complete this job - so keep
			            // counting.....
		             	state <= state;
		             	count <= count - 4'd1;
                        fc_sel <= 1'b1;
                        pfc_insert_done_1cyle_earlier <= 1'b0;
		       	    end
                    
                    //send pause_txin_done 1 cycle earlier back to onoff_ctrl as there is 1 extra cycle for link pause request deassert to reach here
                    if (pfc_insert_done_1cyle_earlier) begin
                        pause_txin_done <= cfg_pfc_sel ?  queues_served : {{NUMPRIORITY-1{1'b0}},1'b1};
                    end else begin
                        pause_txin_done <= 1'b0;
                    end
                    
                    if (stall_req) begin
                        //if stall_req is still asserted after pfc/pause packet done,
                        //it should continue to stall the data pipe
                        txoff_req <= 1'b1;
                    end else if (pfc_insert_done_1cyle_earlier) begin
                        //deassert txoff_req 1 cycle earlier before INSERT -> DONE
                        //this is to prevent bubble in the data pipeline as the request will not be served immediately                    
                        txoff_req <= 1'b0;
                    end else begin
                        txoff_req <= txoff_req;
                    end
                    
                    stall_ack <= stall_ack;
                end
		        DONE:begin
                    if (stall_req & txoff_req) begin
                        //if stall_req is still asserted and data pipe is still stalled
                        //after after sending pfc/pause frame, then it can move to stall
                        //else the state should go to idle first before can stall                        
			            state <= STALL;
			            count <= 4'd0;
                        txoff_req <= 1'b1;
                        stall_ack <= 1'b1;
                    end else begin
                        // This state is needed for onoff_ctrl state machine to move from ON or OFF state in 1 cycle 
			            // this is a single cycle state after PFC transmission 
			            // and/or link hold-off timer is done 
			            // this state is created to mark the insertion of one 
			            // pause frame for a reported ques(s) congestions. The
			            // fsm returns to IDLE and will initiate another cycle
		                count <= 4'd0;
		                state <= IDLE;
                        txoff_req <= 1'b0;
                        stall_ack <= 1'b0;
		   	        end
                    fc_sel <= 1'b0;
                    pause_txin_done <= 1'b0;
                    pfc_insert_done_1cyle_earlier <= 1'b0;
                end
		        default:begin
			        state <= state;
			        count <= count;
                    txoff_req <= txoff_req;
                    fc_sel <= fc_sel;
                    stall_ack <= stall_ack;
                    pause_txin_done <= pause_txin_done;
                    pfc_insert_done_1cyle_earlier <= pfc_insert_done_1cyle_earlier;
			    end
		        endcase
	        end
	    end
	end	// always begin
	    
    //   _______________   _________________________   ___________________   __________   _____
    //  /               \ /                         \ /                   \ /          \ /
    // X da[5:0],sa[5:4] X sa[3:0],typ[1:0],opc[1:0] X   penv, pq0,1,2     X   pq[3:6]  X  pq[7]        
    //  \_______________/ \_________________________/ \___________________/ \__________/ \______

    wire [15:0] pfc_ena = queue_pause_req;
    wire [16*NUMPRIORITY-1:0] pfc_quanta;
    genvar i;
    generate for (i=0; i< NUMPRIORITY; i=i+1)
	begin:rev
	    assign pfc_quanta[16*(NUMPRIORITY-i)-1:16*(NUMPRIORITY-i-1)] = queue_pause_quanta[16*(i+1)-1:16*i];
	end
    endgenerate

    reg out_pfc_sop_reg;
    reg out_pfc_eop_reg;
    reg [EMPTYBITS-1:0] out_pfc_empty_reg;
    //reg [(PACKET_LENGTH+EMPTYBYTES)*8-1:0] out_pfc_data_reg;
    reg [511:0] out_pfc_data_reg;
    wire [(PFC_PADDING_BYTES)*8-1:0] pfc_padding = {8*(PFC_PADDING_BYTES){1'b0}};
    wire [(PAUSE_PADDING_BYTES)*8-1:0] pause_padding = {8*(PAUSE_PADDING_BYTES){1'b0}};
    wire [15:0] opcode = cfg_pfc_sel ? 16'h0101 : 16'h0001; //1=pfc, 0=pause

    //non resettable flops
    generate if (WORDS == 4 && PREAMBLE_PASS == 1) begin: e100g_preamble_pt
    always @ (posedge clk) begin
        if (out_ready & data_valid) begin
                out_pfc_sop_reg <= 1'b1;
                out_pfc_data_reg <= cfg_pfc_sel ? {PRMBL,cfg_daddr, cfg_saddr, TYPLEN, opcode, pfc_ena,pfc_quanta,pfc_padding}: //PFC
                                                 {PRMBL,cfg_daddr, cfg_saddr, TYPLEN, opcode, queue_pause_quanta[15:0],pause_padding}; //PAUSE
                out_pfc_eop_reg <= 1'b1;
                out_pfc_empty_reg <= EMPTYBYTES;
        end
    end
    end
    endgenerate

    //non resettable flops
    generate if (WORDS == 4 && PREAMBLE_PASS == 0) begin: e100g_preamble_xpt
    always @ (posedge clk) begin
        if (out_ready & data_valid) begin
                out_pfc_sop_reg <= 1'b1;
                out_pfc_data_reg <= cfg_pfc_sel ? {cfg_daddr, cfg_saddr, TYPLEN, opcode, pfc_ena,pfc_quanta,pfc_padding}: //pfc
                                                 {cfg_daddr, cfg_saddr, TYPLEN, opcode, queue_pause_quanta[15:0],pause_padding}; //pause
                out_pfc_eop_reg <= 1'b1;
                out_pfc_empty_reg <= EMPTYBYTES;
        end
    end
    end
    endgenerate

/*
    //non resettable flops
    generate if (WORDS == 1 && PREAMBLE_PASS == 1) begin: e40g_preamble_pt
    always @ (posedge clk) begin
        if (out_ready & data_valid) begin
            if (fc_sel) begin
                out_pfc_sop_reg <= 1'b0;
                out_pfc_data_reg <= {out_pfc_data_reg[(PACKET_LENGTH+EMPTYBYTES-8*1)*8-1:0],{1{64'b0}}}; //25G:left shift 1 word every clock cycle
                if (count == 4'd1) begin
                    out_pfc_eop_reg <= 1'b1;
                    out_pfc_empty_reg <= EMPTYBYTES;
                end else begin
                    out_pfc_eop_reg <= 1'b0;
                    out_pfc_empty_reg <= {EMPTYBITS{1'b0}};
                end
            end else begin
                out_pfc_sop_reg <= 1'b1;
                out_pfc_data_reg <= cfg_pfc_sel ? {PRMBL,cfg_daddr, cfg_saddr, TYPLEN, opcode, pfc_ena,pfc_quanta,pfc_padding}: //PFC
                                                 {PRMBL,cfg_daddr, cfg_saddr, TYPLEN, opcode, queue_pause_quanta[15:0],pause_padding}; //PAUSE
                out_pfc_eop_reg <= 1'b0;
                out_pfc_empty_reg <= {EMPTYBITS{1'b0}};
            end
        end
    end
    end
    endgenerate

    generate if (WORDS == 1 && PREAMBLE_PASS == 0) begin: e25g_preamble_xpt
    always @ (posedge clk) begin
        if (out_ready & data_valid) begin
            if (fc_sel) begin
                out_pfc_sop_reg <= 1'b0;
                out_pfc_data_reg <= {out_pfc_data_reg[(PACKET_LENGTH+EMPTYBYTES-8*1)*8-1:0],{1{64'b0}}}; //25G:left shift 1 word every clock cycle
                if (count == 4'd1) begin
                    out_pfc_eop_reg <= 1'b1;
                    out_pfc_empty_reg <= EMPTYBYTES;
                end else begin
                    out_pfc_eop_reg <= 1'b0;
                    out_pfc_empty_reg <= {EMPTYBITS{1'b0}};
                end
            end else begin
                out_pfc_sop_reg <= 1'b1;
                out_pfc_data_reg <= cfg_pfc_sel ? {cfg_daddr, cfg_saddr, TYPLEN, opcode, pfc_ena,pfc_quanta,pfc_padding}: //pfc
                                                 {cfg_daddr, cfg_saddr, TYPLEN, opcode, queue_pause_quanta[15:0],pause_padding}; //pause
                out_pfc_eop_reg <= 1'b0;
                out_pfc_empty_reg <= {EMPTYBITS{1'b0}};
            end
        end
    end
    end
    endgenerate

    generate if (WORDS == 2) begin: e40g
    always @ (posedge clk) begin
        if (out_ready & data_valid) begin
            if (fc_sel) begin
                out_pfc_sop_reg <= 1'b0;
                out_pfc_data_reg <= {out_pfc_data_reg[(PACKET_LENGTH+EMPTYBYTES-8*2)*8-1:0],{2{64'b0}}}; //50G:left shift 2 word every clock cycle
                if (count == 4'd1) begin
                    out_pfc_eop_reg <= 1'b1;
                    out_pfc_empty_reg <= EMPTYBYTES;
                end else begin
                    out_pfc_eop_reg <= 1'b0;
                    out_pfc_empty_reg <= {EMPTYBITS{1'b0}};
                end
            end else begin
                out_pfc_sop_reg <= 1'b1;
                out_pfc_data_reg <= cfg_pfc_sel ? {cfg_daddr, cfg_saddr, TYPLEN, opcode, pfc_ena,pfc_quanta,pfc_padding}: //pfc
                                                 {cfg_daddr, cfg_saddr, TYPLEN, opcode, queue_pause_quanta[15:0],pause_padding}; //pause
                out_pfc_eop_reg <= 1'b0;
                out_pfc_empty_reg <= {EMPTYBITS{1'b0}};
            end
        end
    end
    end
    endgenerate
*/
    //mapping of out_pfc_data to most significant word of out_pfc_data_reg
    //assign out_pfc_data = out_pfc_data_reg[(PACKET_LENGTH+EMPTYBYTES)*8-1:(PACKET_LENGTH+EMPTYBYTES)*8-64*WORDS];
    assign out_pfc_data = out_pfc_data_reg;
    assign out_pfc_sop = out_pfc_sop_reg;
    assign out_pfc_eop = out_pfc_eop_reg;
    assign out_pfc_empty = out_pfc_empty_reg;
    assign out_pfc_valid = fc_sel;

 endmodule


