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
// Copyright(C) 2013: Altera Corporation
// $Id: alt_aeu_40_sfc_rx_ctrl.v,v 1.2 2015/08/17 22:00:12 marmstro Exp marmstro $
// $Revision: 1.2 $
// $Date: 2015/08/17 22:00:12 $
// $Author: marmstro $
// ____________________________________________________________________
// altera message_off 10030 10036 10236
// adubey 06.2013

 module alt_aeu_40_sfc_rx_ctrl #(
	parameter SYNOPT_ALIGN_FCSEOP = 0
       ,parameter FCBITS = 2
       ,parameter INC_PRMBL = 1
       ,parameter WORDS = 8
       ,parameter EMPTYBITS = 6
       ,parameter cfg_typlen= 16'h8808
       ,parameter cfg_opcode= 16'h0001 
       )(
	input  wire clk,
	input  wire reset_n,
	
	input  wire in_fcserror,
	input  wire in_fcsval,
	input  wire in_sop,
	input  wire in_valid,
	input  wire[WORDS*64-1:0] in_data,
	input  wire[EMPTYBITS-1:0]  in_empty,
	input  wire[FCBITS-1:0] cfg_enable,
        input  wire[47:0] cfg_daddr, 
	input  wire cfg_fwd_pause_frame,

	output reg drop_this_frame,
 	output wire[FCBITS-1:0] rxon_frame,
 	output wire[FCBITS-1:0] rxoff_frame,
 	output wire[FCBITS-1:0] rx_out_pause
      );

 // _____________________________________________________________________ 
      localparam 
      ADDR_BCAST = 48'h0180C2_000001
   // 6 Bytes of dadr
     ,MSBDADR = 64*WORDS -01 - INC_PRMBL*08*08
     ,LSBDADR = 64*WORDS -48 - INC_PRMBL*08*08

   // 6 Bytes of saddr 
     ,MSBSADR = LSBDADR - 01
     ,LSBSADR = LSBDADR - 48

   // 6 Bytes of Type
     ,MSBTYPE = LSBSADR - 01
     ,LSBTYPE = LSBSADR - 16

   // 6 Bytes of opcode
     ,MSBOPCD = LSBTYPE - 01
     ,LSBOPCD = LSBTYPE - 16

   // 6 Bytes of enable
     ,MPENVEC = LSBOPCD - 01
     ,LPENVEC = LSBOPCD - 16

   // p*2 Bytes of quanta
     ,MPFCQNT = LPENVEC - 01
     ,LPFCQNT = LPENVEC - 16*FCBITS
     ;

  // the fcs error checks will be performed for case when fcs error input is aligned with the eop.
  // for other cases all pause frames will be evaluated
   wire in_error;  
   generate 
	if (SYNOPT_ALIGN_FCSEOP == 0) begin assign in_error = 1'b0; end
	else begin assign in_error = in_fcsval && in_fcserror; end 
   endgenerate

   reg pipe_one_noerror = 1'b0; always@(posedge clk) pipe_one_noerror <= ~in_error;
   reg pipe_one_start = 1'b0; always@(posedge clk) if (in_valid & in_sop) pipe_one_start <= 1'b1; else if(in_valid & pipe_one_start) pipe_one_start <= 1'b0;
   reg[WORDS*64-1:0] pipe_one_data = {64*WORDS{1'b0}};always@(posedge clk) pipe_one_data <= in_data;

   wire valid_pkt_start =  in_valid && in_sop;
   wire valid_adr_match = (valid_pkt_start) && ((in_data[MSBDADR:LSBDADR] == cfg_daddr)||(in_data[MSBDADR:LSBDADR] == ADDR_BCAST));
   wire valid_typ_match = (valid_pkt_start) &&  (in_data[MSBTYPE:LSBTYPE] == cfg_typlen);
   wire valid_opc_match = (valid_pkt_start) &&  (in_data[MSBOPCD:LSBOPCD] == cfg_opcode);
   wire valid_hdr_match = (valid_adr_match) &&  (valid_typ_match) && (valid_opc_match);
   reg  pipe_one_hdr_match = 1'b0; always@(posedge clk) pipe_one_hdr_match <= valid_hdr_match;
   wire pipe_one_valid_pause = (pipe_one_noerror) && (pipe_one_start) &&  (pipe_one_hdr_match);

   wire pause_type_802d3 = (cfg_opcode == 16'h0001);
   wire[15:0] pause_802d3_quanta = pipe_one_data[MPENVEC:LPENVEC]; 

   reg[FCBITS-1:0] pipe_two_pause_valid;
   reg[16*FCBITS-1:0] pipe_two_pause_quanta = 0;
   wire pause_valid = pipe_two_pause_valid; // created for puneet's tb

  // _________________________________________________________________________________________
   always@(posedge clk or negedge reset_n)
       begin
  	 if (~reset_n) pipe_two_pause_valid <= 0;
  	 else if (pipe_one_valid_pause & pause_type_802d3)pipe_two_pause_valid <= {FCBITS{1'b1}};
	 else pipe_two_pause_valid <= 0;
       end

   always@(posedge clk) 
       begin 
          if (pipe_one_valid_pause & pause_type_802d3) pipe_two_pause_quanta <= pause_802d3_quanta; 
	  else pipe_two_pause_quanta <= 0; 

   	  if (valid_hdr_match) drop_this_frame <= ~cfg_fwd_pause_frame;
	  else if (valid_pkt_start) drop_this_frame <= 1'b0;
       end
  // _________________________________________________________________________________________
  //


  genvar q;
  generate for (q=0; q < FCBITS; q=q+1) 
     begin: queues
 	alt_aeu_40_sfc_rx_qctrl	 rx_qctrl 
       (
	.clk             	 (clk),
	.reset_n           	 (reset_n),
	.cfg_enable           	 (cfg_enable[q]),
	.pause_valid 		 (pipe_two_pause_valid[q]),
	.pause_quanta  		 (pipe_two_pause_quanta[16*(q+1)-1:16*q]),
	.rx_xon_frame  	 	 (rxon_frame[q]),
	.rx_xoff_frame  	 (rxoff_frame[q]),
 	.rx_out_pause	 	 (rx_out_pause[q])
       );
      end
   endgenerate

 // _________________________________________________________________________________________
 //

 endmodule


