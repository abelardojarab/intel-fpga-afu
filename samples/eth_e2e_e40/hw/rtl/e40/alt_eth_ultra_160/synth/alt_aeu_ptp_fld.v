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


// $Id: //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/pcs/e100_rx_pcs_4.v#1 $
// $Revision: #1 $
// $Date: 2013/02/27 $
// $Author: rkane $
//-----------------------------------------------------------------------------
// Copyright 2012 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps

module alt_aeu_ptp_fld
  #(
    parameter TARGET_CHIP = 2, // 2: stratix v, 5: arria 10
	parameter W2_WIDTH = 9,
	parameter EXTR_FIFO_DEPTH = 15,
	parameter FD_DLY = 47,
    parameter WORDS = 4
    )    
   (
	input srst,
	input [1:0] fld, // fld 0,1 or 2. used for special handling

    input din_valid,
	input din_sop,
	input din_extr,
	input din_spl_hndl,
	input din_wr_off, // write the extracted data into old value fifo to be sent to calc
	input [1:0] din_ptp_asm,
    input [WORDS*64-1:0] din,
    input [15:0] din_offset,
    input [4:0] din_offset_adj,

	input old_val_read,
	input nvl_valid,
	input [(W2_WIDTH+1)*8-1:0] 			  nvl,
//	input nvl_read,
	output old_ff_empty,

	output old_val_offset_lsb,
	output [(W2_WIDTH+1)*8-1:0] old_val,
	output old_val_valid,
	output [1:0] old_ptp_asm,

    output [WORDS*64-1:0] dout,
	output [WORDS*8-1:0] dout_mask,
	output dout_valid,
	
    input clk
   
	);

   wire dout_valid_ext;
   wire  dout_ipg_ext;
//   wire  dout_spl_hndl;
   wire  [1:0] dout_ptp_asm_ext;
   
    wire [(2*8+W2_WIDTH)*8-1:0] dout_ext;
	wire [15:0] dout_offset_ext /* synthesis preserve */;
	wire [1:0] dout_offset_cp1_ext /* synthesis preserve */;
   wire 	   dout_spl_hndl_ext;
   wire 	   dout_wr_off_ext;
   wire 	   pre_dout_valid_ext;
   wire 	   pre_dout_spl_hndl_ext;
   

   alt_aeu_ptp_extr ext
	 (
	  .srst(srst),
	  .din_valid(din_valid),
	  .din_sop(din_sop),
	  .din_extr(din_extr),
	  .din_spl_hndl(din_spl_hndl),
	  .din_wr_off(din_wr_off),
	  .din_ptp_asm(din_ptp_asm),
	  .din(din),
	  .din_offset(din_offset),
	  .din_offset_adj(din_offset_adj),
	  .pre_dout_valid(pre_dout_valid_ext),
	  .pre_dout_spl_hndl(pre_dout_spl_hndl_ext),
	  .dout_valid(dout_valid_ext),
	  .dout_ipg(dout_ipg_ext),
	  .dout_spl_hndl(dout_spl_hndl_ext),
	  .dout_wr_off(dout_wr_off_ext),
	  .dout_ptp_asm(dout_ptp_asm_ext),
	  .dout_offset(dout_offset_ext),
	  .dout_offset_cp1(dout_offset_cp1_ext),
	  .dout(dout_ext),
	  .clk(clk)
	  );

   reg [FD_DLY-1:0] 		   nvl_dly_fifo;
   always @(posedge clk)
	 begin
	   if (srst)
		 nvl_dly_fifo <= {FD_DLY{1'b0}};
	   else
		 nvl_dly_fifo <= {nvl_dly_fifo[FD_DLY-2:0],pre_dout_valid_ext};
	 end

   wire nvl_read;
   assign nvl_read = nvl_dly_fifo[FD_DLY-1];

   reg [FD_DLY-1:0] 		   spl_hndl_dly_fifo;
   always @(posedge clk)
	 begin
	   if (srst)
		 spl_hndl_dly_fifo <= {FD_DLY{1'b0}};
	   else
		 spl_hndl_dly_fifo <= {spl_hndl_dly_fifo[FD_DLY-2:0],(pre_dout_valid_ext&pre_dout_spl_hndl_ext)};
	 end

   wire spl_hndl_read;
   assign spl_hndl_read = spl_hndl_dly_fifo[FD_DLY-1];

   defparam ext.TARGET_CHIP = TARGET_CHIP;
   defparam ext.W2_WIDTH = W2_WIDTH;
   defparam ext.WORDS = WORDS;
   

   defparam shl.TARGET_CHIP = TARGET_CHIP;
   defparam shl.W2_WIDTH = W2_WIDTH;
   defparam shl.MAX_WIDTH = 16+W2_WIDTH;
   defparam shl.WORDS = 2;

   wire 						  dout_valid_shl;
   wire 						  dout_ipg_shl;
   wire 						  dout_spl_hndl_shl;
   wire 						  dout_wr_off_shl;
   wire [1:0]					  dout_ptp_asm_shl;
   wire [(W2_WIDTH+1)*8-1:0] 	  dout_shl;
   wire [15:0] 					  dout_offset_shl;
   
   alt_aeu_fld_shl shl
	 (
	  .srst(srst),
	  .din_valid(dout_valid_ext),
	  .din_ipg(dout_ipg_ext),
	  .din(dout_ext),
	  .din_spl_hndl(dout_spl_hndl_ext),
	  .din_wr_off(dout_wr_off_ext),
	  .din_ptp_asm(dout_ptp_asm_ext),
	  .din_offset(dout_offset_ext),
	  .din_offset_cp1(dout_offset_cp1_ext),
	  .dout_valid(dout_valid_shl),
	  .dout_ipg(dout_ipg_shl),
	  .dout_spl_hndl(dout_spl_hndl_shl),
	  .dout_wr_off(dout_wr_off_shl),
	  .dout_ptp_asm(dout_ptp_asm_shl),
	  .dout(dout_shl),
	  .dout_offset(dout_offset_shl),
	  .clk(clk)
	  );

   wire [(W2_WIDTH+1)*8-1:0] 			  out_ext;
   assign out_ext = 80'haaaa_aaaa_aaaa_aaaa_aaaa;
   
   // fifo for offset
   wire [15:0] 					  dout_offset_ofs;
   wire 						  dout_ipg_ofs;
   wire 						  dout_spl_hndl_ofs;
   
   scfifo_mlab ofs
	 (
	  .clk(clk),
	  .sclr(srst),
	  .wdata({dout_offset_shl,dout_ipg_shl,dout_spl_hndl_shl}),
	  .wreq(dout_valid_shl),
	  .rdata({dout_offset_ofs,dout_ipg_ofs,dout_spl_hndl_ofs}),
	  .rreq(nvl_read)
	  );
   defparam ofs.TARGET_CHIP = TARGET_CHIP;
   defparam ofs.WIDTH = 20;
//   defparam ofs.WIDTH = 6;
   defparam ofs.ADDR_WIDTH = 5;


   // old value
//   wire [(W2_WIDTH+1)*8-1:0] 	  dout_shl_old;
//   scfifo_mlab old
//	 (
//	  .clk(clk),
//	  .sclr(srst),
//	  .wdata({dout_shl,dout_ptp_asm_shl}),
//	  .wreq(dout_valid_shl),
//	  .empty(old_ff_empty),
//	  .rdata({dout_shl_old,dout_ptp_asm_shl_old}),
//	  .rreq(old_val_read)
//	  );

//   reg 							  old_val_valid_m1;
   
    sc_fifo_ptp #(
        .DEVICE_FAMILY       ( (TARGET_CHIP == 2) ? "Stratic V" : "Arria 10"),
        .ENABLE_MEM_ECC      (0),
        .REGISTER_ENC_INPUT  (0),
        
        .SYMBOLS_PER_BEAT    (1),
        .BITS_PER_SYMBOL     ((W2_WIDTH+1)*8+3),   //Data width, eg: 96 for TODp FIFO
        .FIFO_DEPTH          (16),            //FIFO Depth
        .CHANNEL_WIDTH       (0),
        .ERROR_WIDTH         (0),
        .USE_PACKETS         (0)
    ) tod_fifo_inst (
        .clk               (clk),                      // clock signal                         
        .reset             (srst),          //active high reset                  
        .in_data           ({dout_ptp_asm_shl,dout_offset_shl[0],dout_shl}),      //data to be written into sc fifo          
//        .in_valid          (dout_valid_shl),                    //push sc fifo signal
        .in_valid          (dout_valid_shl & (~dout_wr_off_shl)),                    //push sc fifo signal
        .in_ready          (),                                     
        .out_data          ({old_ptp_asm,old_val_offset_lsb,old_val}),                              //data to be read out from sc fifo
        .out_valid         (old_val_valid),    //sc fifo not empty signal, 1 indicate not empty   
        .out_ready         (old_val_read),                 //pop sc fifo signal
        .in_startofpacket  (1'b0),                                 
        .in_endofpacket    (1'b0),                                 
        .out_startofpacket (),                                     
        .out_endofpacket   (),                                     
        .in_empty          (1'b0),                                 
        .out_empty         (),                                     
        .in_error          (1'b0),                                 
        .out_error         (),                                     
        .in_channel        (1'b0),                                 
        .out_channel       (),
        .ecc_err_corrected (),
        .ecc_err_fatal     ()
    );

//   always @(posedge clk)
//	 begin
//		old_val <= dout_shl_old;
//		old_ptp_asm <= dout_ptp_asm_shl_old & old_val_valid_m1;
//		old_val_valid_m1 <= old_val_read;
//		old_val_valid <= old_val_valid_m1;
//	 end
   
//   defparam old.TARGET_CHIP = TARGET_CHIP;
//   defparam old.WIDTH = (W2_WIDTH+1)*8;
//   defparam old.WIDTH = 80;
//   defparam old.ADDR_WIDTH = 5;

   wire [79:0] 					  dout_nvl;
//   wire 						  dout_valid_wdm;
   wire 						  nvl_out_read;
   assign nvl_out_read = (fld == 2'b11) ? (nvl_read&(~spl_hndl_read)):nvl_read;

   reg 							  nvl_valid_d1;
   reg [(W2_WIDTH+1)*8-1:0] 	  nvl_d1;

   always @(posedge clk)
	 begin
		nvl_valid_d1 <= nvl_valid;
		nvl_d1 <= nvl;
	 end
   
   // fifo for new value
   scfifo_mlab nvl_out
	 (
	  .clk(clk),
	  .sclr(srst),
	  .wdata(nvl_d1),
	  .wreq(nvl_valid_d1),
	  .rdata(dout_nvl),
//	  .rreq(nvl_read)
//	  .rreq(dout_valid_wdm)
//	  .rreq(nvl_read&(~spl_hndl_read))
	  .rreq(nvl_out_read)
	  );

   defparam nvl_out.TARGET_CHIP = TARGET_CHIP;
   defparam nvl_out.WIDTH = 80;
   defparam nvl_out.ADDR_WIDTH = 5;

   wire [WORDS*8*8-1:0] 		  dout_shr;
   wire [WORDS*8-1:0] 			  dout_mask_shr;
   wire 						  dout_valid_shr;

   reg 							  nvl_read_d1;
   always @(posedge clk)
	 begin
	   if (fld == 2'b11)
		 nvl_read_d1 <= nvl_read | spl_hndl_read;
	   else
		 nvl_read_d1 <= nvl_read;
	 end
   // hack for 40g testing only
//   reg 							  dout_valid_shl_d1;
//   reg 							  dout_ipg_shl_d1;
//   reg [15:0] 					  dout_offset_shl_d1;
//
//   always @(posedge clk)
//	 begin
//		dout_valid_shl_d1 <= dout_valid_shl;
//		dout_ipg_shl_d1 <= dout_ipg_shl;
//		dout_offset_shl_d1 <= dout_offset_shl;
//	 end

//   defparam wdm. WORDS = WORDS;
//
//   wire [15:0] 					  dout_offset_wdm;
//   wire 						  dout_spl_hndl_wdm;
//   wire 						  dout_ipg_wdm;
//   
//   wire [79:0] 					  dout_wdm;
//   
//   alt_aeu_wd_match wdm
//	 (
//	  .srst(srst),
//	  .din_valid(nvl_read_d1),
//	  .din_offset(dout_offset_ofs),
//	  .din_spl_hndl(dout_spl_hndl_ofs),
//	  .din_ipg(dout_ipg_ofs),
//	  .din(dout_nvl),
//	  .dout_valid(dout_valid_wdm),
//	  .dout(dout_wdm),
//	  .dout_offset(dout_offset_wdm),
//	  .dout_spl_hndl(dout_spl_hndl_wdm),
//	  .dout_ipg(dout_ipg_wdm),
//	  .clk(clk)
//	  );

   reg 						  dout_valid_wdm_d1;
   reg [15:0] 					  dout_offset_wdm_d1;
   reg 						  dout_spl_hndl_wdm_d1;
   reg 						  dout_ipg_wdm_d1;
//   reg [79:0] 					  dout_wdm_d1;

//   always @(posedge clk)
//	 begin
//		dout_valid_wdm_d1 <= dout_valid_wdm;
//		dout_offset_wdm_d1 <= dout_offset_wdm;
//		dout_spl_hndl_wdm_d1 <= dout_spl_hndl_wdm;
//		dout_ipg_wdm_d1 <= dout_ipg_wdm;
//		dout_wdm_d1 <= dout_wdm;
//	 end
   
   always @(posedge clk)
	 begin
		dout_valid_wdm_d1 <= nvl_read_d1;
		dout_offset_wdm_d1 <= dout_offset_ofs;
		dout_spl_hndl_wdm_d1 <= dout_spl_hndl_ofs;
		dout_ipg_wdm_d1 <= dout_ipg_ofs;
//		dout_wdm_d1 <= dout_nvl;
	 end
   
   alt_aeu_fld_shr shr
	 (
	  .srst(srst),
	  .fld(fld),
// 100g working code	  
	  .din_valid(dout_valid_wdm_d1),
	  .din(dout_nvl),
	  .din_offset(dout_offset_wdm_d1[4:0]),
	  .din_spl_hndl(dout_spl_hndl_wdm_d1),
	  .din_ipg(dout_ipg_wdm_d1),
// 100g working code

	  
	  .dout(dout_shr),
	  .dout_mask(dout_mask_shr),
	  .dout_valid(dout_valid_shr),
	  .clk(clk)
	  );
   
   defparam shr.TARGET_CHIP = TARGET_CHIP;
   defparam shr.W2_WIDTH = W2_WIDTH;
   defparam shr.WORDS = WORDS;

   assign dout = dout_shr;
   assign dout_mask = dout_mask_shr;
   assign dout_valid = dout_valid_shr;

endmodule // alt_aeu_ptp_fld


