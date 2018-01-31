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
// $Id: //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/mac/e100_mac_tx_4.v#15 $
// $Revision: #15 $
// $Date: 2013/07/29 $
// $Author: adubey $
// Copyright(C) 2013: Altera Corporation
// Altera corporation Confidential 
// ____________________________________________________________________
// altera message_off 10036 10236

 module alt_aeu_40_sfc_tx_ctrl #(
       parameter cfg_saddr = 48'he100_eefc_5add
      ,parameter cfg_daddr = 48'h0180C2_000001
      ,parameter cfg_typlen= 16'h8808
      ,parameter cfg_opcode= 16'h0001 
      ,parameter INC_PRMBL = 1 
      ,parameter WORDS = 8 
      ,parameter EMPTYBITS = 6 
      ,parameter FCBITS = 1 
      ,parameter READY_LATENCY = 3'd1 )
     (
       input  wire clk 
      ,input  wire reset_n 

      ,output wire sel_in_pkt      		
      ,output wire sel_store_pkt      		
      ,output wire sel_pause_pkt      		

      ,output wire in_ready      		// input ready
      ,input  wire out_ready			// stall input pipe
      ,input  wire pkt_end 
      ,output wire out_pause_valid 
      ,output wire[EMPTYBITS-1:0] out_pause_empty 
      ,output wire[WORDS*64-1:0] out_pause_data 

      ,input  wire[FCBITS-1:0] cfg_enable_txins
      ,input  wire cfg_enable_txoff	// only 802.3
      ,input  wire[16*FCBITS-1:0] cfg_pause_quanta
      ,input  wire[FCBITS-1:0] cfg_qholdoff_en
      ,input  wire[16*FCBITS-1:0] cfg_qholdoff_quanta
      ,output wire[FCBITS-1:0] txon_frame
      ,output wire[FCBITS-1:0] txoff_frame

      ,input  wire rx_txoff_req		// ieee 802.3
      ,input  wire[FCBITS-1:0] in_pause_req
      ,input  wire[FCBITS-1:0] cfg_pause_req 

      );

 // ____________________________________________________________________
 //

  wire[FCBITS-1:0]  queue_pause_req;
  wire[16*FCBITS-1:0] queue_pause_quanta;
  wire pause_txin_done;

  genvar q;
  generate for (q=0; q < FCBITS; q=q+1) begin: queues
    //	_____________________________________________________
	alt_aeu_40_sfc_tx_qctrl #(.WORDS(WORDS))	
        tx_qctrl (
    //	_____________________________________________________
	 .clk			(clk) 
	,.reset_n		(reset_n) 
	,.in_pause_req		(in_pause_req[q]) 
	,.pause_txin_done	(pause_txin_done) 
	,.tx_xon		(txon_frame[q]) 
	,.tx_xoff		(txoff_frame[q]) 
	
	,.cfg_pause_req		(cfg_pause_req[q])
	,.queue_pause_req	(queue_pause_req[q]) 
	,.queue_pause_quanta	(queue_pause_quanta[16*(q+1)-1:16*q])
	,.cfg_enable		(cfg_enable_txins[q]) 
	,.cfg_pause_quanta	(cfg_pause_quanta[16*(q+1)-1:16*q]) 
	,.cfg_holdoff_en	(cfg_qholdoff_en[q]) 
	,.cfg_holdoff_quanta	(cfg_qholdoff_quanta[16*(q+1)-1:16*q]) 
       );
    end
 endgenerate


 // _____________________________________________________
  alt_aeu_40_sfc_tx_lctrl #(
	 .WORDS (WORDS)
	,.FCBITS(FCBITS) 
        ,.INC_PRMBL(INC_PRMBL)
	,.EMPTYBITS(EMPTYBITS) 
	,.READY_LATENCY(READY_LATENCY)  
	,.PFC_BUFF_READ_LATENCY(3'd1)  
	)
   tx_lctrl (
	 .clk			(clk)
	,.reset_n		(reset_n)

	,.cfg_saddr		(cfg_saddr)
	,.cfg_daddr		(cfg_daddr)
	,.cfg_opcode		(cfg_opcode)
	,.cfg_typlen		(cfg_typlen)
	,.cfg_enable_txins	(|cfg_enable_txins)
	,.cfg_enable_txoff	(cfg_enable_txoff)
	 
	,.queue_pause_req	(queue_pause_req[FCBITS-1:0])
	,.queue_pause_quanta	(queue_pause_quanta[16*FCBITS-1:0])
	 
	,.out_ready		(out_ready)
	,.in_ready		(in_ready)
	,.pkt_end		(pkt_end)
	,.rx_txoff_req		(rx_txoff_req)

	,.pause_tx_done		(pause_txin_done)
	,.sel_in_pkt		(sel_in_pkt)
	,.sel_store_pkt		(sel_store_pkt)
	,.sel_pause_pkt		(sel_pause_pkt)
	,.out_pause_valid	(out_pause_valid)
	,.out_pause_empty	(out_pause_empty)
	,.out_pause_data	(out_pause_data)
        );
 // ____________________________________________________________________
 //

 endmodule


