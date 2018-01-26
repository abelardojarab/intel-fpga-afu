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
// $Author: pscheidt $
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

module alt_aeu_tx_pkt_40
  #(
    parameter TARGET_CHIP = 2, // 2: stratix v, 5: arria 10
    parameter SYNOPT_PTP = 1,
    parameter EN_LINK_FAULT = 0,
    parameter WORDS = 2 // 4 for 100G
    )    
   (
    input arst,
    input [95:0] tod_txmac_in,
    input ptp_v2,
    input ptp_s2,
    input [31:0] ext_lat,

    input din_valid,
    input [WORDS*64-1:0] din_crc, // data to crc and data to malb is different !!!
    input [WORDS*64-1:0] din_mlab,  // data to crc and data to malb is different !!!
    input [19:0] mac_in_bus, // other data that needs to be pipelined
    input [WORDS-1:0] din_sops,
    input [WORDS*8-1:0] din_eop_pos,

    input  	   din_ptp_dbg_adp,
    input din_sop_adp,
    input din_ptp_adp,
    input [1:0] din_overwrite_adp,
    input [15:0] din_offset_adp,
    input din_zero_tcp_adp,
    input din_ptp_asm_adp,
    input [15:0] din_zero_offset_adp,
    output ts_out_cust_asm,

    input [95:0] tod_txmclk,
//    input [95:0] latency_ahead,
//    input [95:0] latency_adj,
    input [95:0] tod_cust_in,

    output [WORDS*64-1:0] dout_crc,
    output [WORDS*64-1:0] dout_mlab,
    output [19:0] mac_out_bus, // other data that needs to be pipelined
    output [WORDS-1:0]    dout_sops,
    output [WORDS*8-1:0]  dout_eop_pos,
    output [95:0] tod_exit_cust,
    output [95:0] ts_out_cust,
    output dout_valid,

    output [95:0] tod_tx_clk_st2,
    output ptp_pkt_out,

    input clk
    );

   wire [WORDS*64-1:0] 	      dout_crc_mpk;
   wire [WORDS*64-1:0] 	      dout_mlab_mpk;
   wire [WORDS-1:0] 	      dout_sops_mpk;
   wire [WORDS*8-1:0] 	      dout_eop_pos_mpk;
   wire 		      dout_valid_mpk;
   
   wire [2:0] 		      junk3;
   wire [4:0] 		      junk5;
   wire [6:0] 		      junk7;
   wire [3:0] 		      junk4;
   wire [3:0] 		      junk4_3;
   wire [13:0] 		      junk14;
   wire [11:0] 		      junk12;
   wire [12:0] 		      junk13;
   
   
   
   wire 		      din_ptp;
   wire [1:0] 		      din_overwrite;
   wire [15:0] 		      din_offset;
   wire 		      din_zero_tcp;
   wire 		      din_ptp_asm;
   wire [15:0] 		      din_zero_offset;

   reg 			      din_ptp_reg;
   reg [1:0] 		      din_overwrite_reg;
   reg [15:0] 		      din_offset_reg;
   reg 			      din_zero_tcp_reg;
   reg 			      din_ptp_asm_reg;
   reg [15:0] 		      din_zero_offset_reg;
   
   wire [95:0] 		      tot_latency;
   wire [95:0] 		      tod_exit;
   wire [95:0] 		      latency_ahead;


   // add expected delay to the time of the day

   generate
      if (TARGET_CHIP == 2) // S5
	begin
	   if (EN_LINK_FAULT)
	   assign 	      latency_ahead = 22 * 20'h3_3333 + 24'h6B_2FDF;
//	     assign 	      latency_ahead = 22 * 20'h3_3333;
	   else
	   assign 	      latency_ahead = 20 * 20'h3_3333 + 24'h6B_2FDF;
//	     assign 	      latency_ahead = 20 * 20'h3_3333;
	end
      else
	begin
	   if (EN_LINK_FAULT)
	   assign 	      latency_ahead = 22 * 20'h3_3333 + 24'h62_D478;
//	     assign 	      latency_ahead = 22 * 20'h3_3333;
	   else
	   assign 	      latency_ahead = 20 * 20'h3_3333 + 24'h62_D478;
//	     assign 	      latency_ahead = 20 * 20'h3_3333;
	end
   endgenerate
   

	   

   generate
      if (SYNOPT_PTP == 1)
	begin: ptp1   
	   alt_aeu_add_ts_96 adl
	     (
	      .arst(arst), 
	      .enable(1'b1), 
	      .inp_valid(1'b1),
	      .inp1(latency_ahead), 
	      .inp2({64'd0,ext_lat}), 
	      .out_valid(), 
	      .res(tot_latency), 
	      .clk(clk)
	      );
	   
	   reg [95:0] tod_txmclk_d1;
	   
	   always @(posedge clk)
	     tod_txmclk_d1 <= tod_txmac_in;

	   alt_aeu_add_ts_96 adtl
	     (
	      .arst(arst), 
	      .enable(1'b1), 
	      .inp_valid(1'b1),
	      .inp1(tod_txmclk_d1), 
	      .inp2(tot_latency), 
	      .out_valid(), 
	      .res(tod_exit), 
	      .clk(clk)
	      );

	   wire 		      empty_pof;
	   wire 		      full_pof;
	   	   wire 	       data_valid_mac_bus; // enable_r2 bit

	   wire 		      ptp_dbg_out; // used for verification only
	   wire 		      ptp_dbg_out_mlab; // used for verification only
	   wire 		      full_dbug;
	   wire 		      empty_dbug;
	   
	   wire [WORDS*64-1:0] dout_crc_dlc13;
	   wire [WORDS-1:0]    dout_sops_dlc13;
	   wire [WORDS*8-1:0]  dout_eop_pos_dlc13;
	   wire 	       dout_valid_dlc13;
	   
	   reg [WORDS*64-1:0] dout_crc_dlc13_reg=0;
	   reg [WORDS-1:0]    dout_sops_dlc13_reg=0;
	   reg [WORDS*8-1:0]  dout_eop_pos_dlc13_reg=0;
	   reg 	       dout_valid_dlc13_reg=0;
	   reg [WORDS*64-1:0] dout_mlab_dlm13_reg=0;

	   assign ptp_dbg_out = data_valid_mac_bus & ptp_dbg_out_mlab & (|dout_sops_dlc13_reg);

	   reg 		       din_sop_adp_d1;
	   reg 		       din_ptp_adp_d1;
	   reg [1:0] 	       din_overwrite_adp_d1;
	   reg [15:0] 	       din_offset_adp_d1;
	   reg 		       din_zero_tcp_adp_d1;
	   reg 		       din_ptp_asm_adp_d1;
	   reg [15:0] 	       din_zero_offset_adp_d1;

	   always @(posedge clk)
	     begin
		din_ptp_adp_d1 <= din_ptp_adp;
		din_overwrite_adp_d1 <= din_overwrite_adp;
		din_offset_adp_d1 <= din_offset_adp;
		din_sop_adp_d1 <= din_sop_adp;
  		din_zero_tcp_adp_d1 <= din_zero_tcp_adp;
  		din_ptp_asm_adp_d1 <= din_ptp_asm_adp;
  		din_zero_offset_adp_d1 <= din_zero_offset_adp;
	     end // always @ (posedge clk)

	   reg dv; // data out of m20k is valid
	   reg pof_rd;
	   
	   

	   
	   if (TARGET_CHIP == 2)
	     begin: s5
		defparam pofs5.WIDTH = 40;
		defparam pofs5.ADDR_WIDTH = 8;
		scfifo_s5m20k pofs5
		  (
		   .clk(clk),
		   .sclr(arst),
		   .wrreq(din_sop_adp_d1),
		   .data({3'd0,din_ptp_adp_d1,din_overwrite_adp_d1,din_offset_adp_d1,din_zero_tcp_adp_d1,din_ptp_asm_adp_d1,din_zero_offset_adp_d1}),
		   .full(full_pof),
//		   .rdreq((|din_sops) & din_valid),
		   .rdreq(pof_rd),
		   .q({junk3,din_ptp,din_overwrite,din_offset,din_zero_tcp,din_ptp_asm,din_zero_offset}),
		   .empty(empty_pof),
		   .usedw()
		   );

		// synthesis translate_off
		defparam dbug.WIDTH = 8;
		defparam dbug.ADDR_WIDTH = 8;
		scfifo_s5m20k dbug
		  (
		   .clk(clk),
		   .sclr(arst),
		   .wrreq(din_sop_adp),
		   .data({7'd0,din_ptp_dbg_adp}),
		   .full(full_dbug),
		   .rdreq(data_valid_mac_bus & (|dout_sops_dlc13_reg)),
		   .q({junk7,ptp_dbg_out_mlab}),
		   .empty(empty_dbug),
		   .usedw()
		   );
		// synthesis translate_on
	     end // block: s5
	   else
	     begin: a10
		defparam pofa10.WIDTH = 40;
		defparam pofa10.ADDR_WIDTH = 8;

		scfifo_a10m20k pofa10
		  (
		   .clk(clk),
		   .sclr(arst),
		   .wrreq(din_sop_adp_d1),
		   .data({3'd0,din_ptp_adp_d1,din_overwrite_adp_d1,din_offset_adp_d1,din_zero_tcp_adp_d1,din_ptp_asm_adp_d1,din_zero_offset_adp_d1}),
		   .full(full_pof),
//		   .rdreq((|din_sops) & din_valid),
		   .rdreq(pof_rd),
		   .q({junk3,din_ptp,din_overwrite,din_offset,din_zero_tcp,din_ptp_asm,din_zero_offset}),
		   .empty(empty_pof),
		   .usedw()
		   );
		// synthesis translate_off
		defparam dbug.WIDTH = 8;
		defparam dbug.ADDR_WIDTH = 8;
		scfifo_a10m20k dbug
		  (
		   .clk(clk),
		   .sclr(arst),
		   .wrreq(din_sop_adp),
		   .data({7'd0,din_ptp_dbg_adp}),
		   .full(full_dbug),
		   .rdreq(data_valid_mac_bus & (|dout_sops_dlc13_reg)),
		   .q({junk7,ptp_dbg_out_mlab}),
		   .empty(empty_dbug),
		   .usedw()
		   );
		// synthesis translate_on
	     end // else: !if(TARGET_CHIP == 2)
	   
	   reg empty_pof_d1;
	   always @(posedge clk)
	     empty_pof_d1 <= empty_pof;
	   

	   always @(posedge clk or posedge arst)
	     begin
		if (arst)
		  dv <= 1'b0;
		else
		  begin
		     if (dv)
		       begin
			  if ((|din_sops) & din_valid)
			    begin
			       if (!empty_pof_d1)
				 dv <= 1'b1;
			       else
				 dv <= 1'b0;
			    end
		       end
		     else
		       begin
			  if (!empty_pof_d1)
			    dv <= 1'b1;
		       end
		  end // else: !if(arst)
	     end // always @ (posedge clk or posedge arst)

	   always @(*)
	     begin
		pof_rd = 1'b0;
		if (dv)
		  begin
		     if ((|din_sops) & din_valid & (!empty_pof_d1))
		       pof_rd = 1'b1;
		  end
		else
		  begin
		     if (!empty_pof_d1)
		       pof_rd = 1'b1;
		  end
	     end // always @ (*)

	   always @(posedge clk)
	     begin
		if (pof_rd)
		  begin
		     din_ptp_reg <= din_ptp;
		     din_overwrite_reg <= din_overwrite;
		     din_offset_reg <= din_offset;
  		     din_zero_tcp_reg <= din_zero_tcp;
  		     din_ptp_asm_reg <= din_ptp_asm;
  		     din_zero_offset_reg <= din_zero_offset;
		  end
	     end
	   
	   wire [WORDS*64-1:0] dout_crc_dl2;
	   wire [WORDS-1:0]    dout_sops_dl2;
	   wire [WORDS*8-1:0]  dout_eop_pos_dl2;
	   wire 	       dout_valid_dl2;
	   
	   reg [WORDS*64-1:0]  dout_crc_dl2_reg=0;
	   reg [WORDS-1:0]     dout_sops_dl2_reg=0;
	   reg [WORDS*8-1:0]   dout_eop_pos_dl2_reg=0;
	   reg [WORDS-1:0]     dout_valid_dl2_reg=0 /* synthesis preserve */;
	   
// delay signals for zeroing out bytes in packet t the reqd offset	   
	   defparam dl2. LATENCY = 2;
	   defparam dl2. TARGET_CHIP = TARGET_CHIP;
	   defparam dl2. WIDTH = 160;
	   defparam dl2. FRACTURE = 4;
	   
	   delay_mlab dl2 (
			   .clk(clk),
			   .din({13'd0,din_valid,din_sops,din_eop_pos,din_crc}),
			   .dout({junk13,dout_valid_dl2,dout_sops_dl2,dout_eop_pos_dl2,dout_crc_dl2})
			   );
	   always @(posedge clk)
	     begin
		dout_crc_dl2_reg <= dout_crc_dl2;
		dout_sops_dl2_reg <= dout_sops_dl2;
		dout_eop_pos_dl2_reg <= dout_eop_pos_dl2;
		dout_valid_dl2_reg <= {WORDS{dout_valid_dl2}};
	     end
	   

	   defparam dm2. LATENCY = 2;
	   defparam dm2. TARGET_CHIP = TARGET_CHIP;
	   defparam dm2. WIDTH = 140;
	   defparam dm2. FRACTURE = 7;

	   
	   wire [WORDS*64-1:0] dout_mlab_dm2;
	   reg [WORDS*64-1:0]  dout_mlab_dm2_reg=0;
	   
	   delay_mlab dm2 (
			   .clk(clk),
			   .din({12'd0,din_mlab}),
			   .dout({junk12,dout_mlab_dm2})
			   );

	   always @(posedge clk)
	     dout_mlab_dm2_reg <= dout_mlab_dm2;

	   wire [WORDS*64-1:0] dout_crc_ztcp;
	   wire [WORDS*64-1:0] dout_mlab_ztcp;
	   wire [WORDS-1:0]    dout_sops_ztcp;
	   wire [WORDS*8-1:0]  dout_eop_pos_ztcp;
	   wire 	       dout_valid_ztcp;
	   
	   alt_aeu_zr_tcp_40 ztcp
	     (
	      .srst(arst),
	      .ptp_s2(ptp_s2),
	      .din_valid(din_valid),
	      .din_sops(din_sops),
	      .din_zero_tcp(din_zero_tcp_reg),
	      .din_zero_offset(din_zero_offset_reg),
	      .din_crc_d3(dout_crc_dl2_reg),
	      .din_mlab_d3(dout_mlab_dm2_reg),
	      .din_sops_d3(dout_sops_dl2_reg),
	      .din_eop_pos_d3(dout_eop_pos_dl2_reg),
	      .dout_valid(dout_valid_ztcp),
	      .dout_crc(dout_crc_ztcp),
	      .dout_mlab(dout_mlab_ztcp),
	      .dout_sops(dout_sops_ztcp),
	      .dout_eop_pos(dout_eop_pos_ztcp),
	      .clk(clk)
	      );

	   defparam dlc13. LATENCY = 10;
	   defparam dlc13. TARGET_CHIP = TARGET_CHIP;
	   defparam dlc13. WIDTH = 160;
	   
	   delay_mlab dlc13 (
			     .clk(clk),
			     .din({13'd0,dout_valid_ztcp,dout_sops_ztcp,dout_eop_pos_ztcp,dout_crc_ztcp}),
			     .dout({junk13,dout_valid_dlc13,dout_sops_dlc13,dout_eop_pos_dlc13,dout_crc_dlc13})
			     );

	   defparam dlm13. LATENCY = 10;
	   defparam dlm13. TARGET_CHIP = TARGET_CHIP;
	   defparam dlm13. WIDTH = 140;

	   
	   wire [WORDS*64-1:0] dout_mlab_dlm13;
	   
	   delay_mlab dlm13 (
			     .clk(clk),
			     .din({12'd0,dout_mlab_ztcp}),
			     .dout({junk12,dout_mlab_dlm13})
			     );

	   // one xtra cycle delay from above. The xtra stage in mod_pkt not needed for the mac_bus
	   defparam mb13. LATENCY = 15;
	   defparam mb13. TARGET_CHIP = TARGET_CHIP;
	   defparam mb13. WIDTH = 20;

	   wire [19:0] 	       mac_out_bus_mb13;
	   
	   delay_mlab mb13 (
			    .clk(clk),
			    .din({mac_in_bus}),
			    .dout({mac_out_bus_mb13})
			    );

	   assign data_valid_mac_bus = mac_out_bus_mb13[0];
	   
	   
	   reg [19:0] 	       mac_out_bus_mb14=0;
	   always @(posedge clk)
	     mac_out_bus_mb14 <= mac_out_bus_mb13;

	   wire 	       fld_valid_out_exf;
	   wire [1:0] 	       fld_overwrite_out_exf;
	   wire [15:0] 	       fld_offset_out_exf;
	   wire [255:0]        fld_out_exf;
	   wire 	       am_insrt_out_exf;
       wire            fld_ptp_asm_out_exf;
	   
	   alt_aeu_extr_fld_40 exf
	     (
	      .arst(arst),
	      .din_valid(din_valid),
	      .din(din_crc),
	      .din_sops(din_sops),
	      .din_ptp(din_ptp_reg),
	      .din_ptp_asm(din_ptp_asm_reg),
	      .din_overwrite(din_overwrite_reg),
	      .ptp_v2(ptp_v2),
	      .din_offset(din_offset_reg),
	      .fld_valid_out(fld_valid_out_exf),
	      .fld_overwrite_out(fld_overwrite_out_exf),
	      .fld_ptp_asm_out(fld_ptp_asm_out_exf),
	      .fld_offset_out(fld_offset_out_exf),
	      .fld_out(fld_out_exf),
	      .am_insrt_out(am_insrt_out_exf),
	      .clk(clk)
	      );

	   // delay for fifo read
	   reg 		       fr_d1, fr_d2, fr_d3;
	   always @(posedge clk)
	     begin
		fr_d1 <= fld_valid_out_exf;
		fr_d2 <= fr_d1;
		fr_d3 <= fr_d2;
	     end

	   wire [95:0] tod_exit2_tef;
	   reg [95:0]  tod_exit2_tef_fl;
	   
	   defparam tef.TARGET_CHIP = TARGET_CHIP;
	   defparam tef.WIDTH = 100;
	   defparam tef.ADDR_WIDTH = 4;

	   reg 	       din_sop_reg;
	   reg 	       din_ptp_reg_d1;
	   
	   
	   always @(posedge clk)
	     begin
		din_sop_reg <= (|din_sops) & din_valid;
		din_ptp_reg_d1 <= din_ptp_reg;
	     end
	   
	   scfifo_mlab tef
	     (
	      .clk(clk),
	      .sclr(arst),
	      .wdata({4'd0,tod_exit}),
	      .wreq(din_sop_reg&din_ptp_reg_d1),
	      .rdata({junk4_3,tod_exit2_tef}),
	      .rreq(fr_d1)
	      );

	   always @(posedge clk)
	     tod_exit2_tef_fl <= tod_exit2_tef;
	   
	   wire [255:0]        fld_out_shl;
	   wire [1:0] 	       fld_overwrite_out_shl;
	   wire 	       fld_valid_out_shl;
	   wire [15:0] 	       fld_offset_out_shl;
	   wire 	       am_insrt_out_shl;

	   alt_aeu_shft_lft_40 shl
	     (
	      .arst(arst),
	      .din_valid(1'b1),
	      .fld_valid(fld_valid_out_exf),
	      .fld_overwrite(fld_overwrite_out_exf),
	      .fld(fld_out_exf),
	      .am_insrt(am_insrt_out_exf),
	      .fld_offset(fld_offset_out_exf),
	      .fld_out(fld_out_shl),
	      .fld_overwrite_out(fld_overwrite_out_shl),
	      .fld_valid_out(fld_valid_out_shl),
	      .fld_offset_out(fld_offset_out_shl),
	      .am_insrt_out(am_insrt_out_shl),
	      .clk(clk)
	      );

	   wire 	       out_valid_adt;
	   wire [95:0] 	       res_adt;
	   reg [95:0] 	       fld_out_shl_adj;
	   reg 		       fld_valid_out_shl_d1;
		       

	   always @(posedge clk)
	     begin
		fld_out_shl_adj <= ptp_v2 ? fld_out_shl[255:160] : {16'd0,fld_out_shl[255:192],16'd0};
		fld_valid_out_shl_d1 <= fld_valid_out_shl;
	     end
	   
//	   assign fld_out_shl_adj = ptp_v2 ? fld_out_shl[255:160] : {16'd0,fld_out_shl[255:192],16'd0};

	   reg 		       fl_d1, fl_d2, fl_d3, fl_d4, fl_d5, fl_d6, fl_d7, fl_d8;
	   
	   always @(posedge clk)
	     begin
		fl_d1 <= fld_ptp_asm_out_exf & fld_valid_out_exf;
		fl_d2 <= fl_d1;
		fl_d3 <= fl_d2;
		fl_d4 <= fl_d3;
		fl_d5 <= fl_d4;
		fl_d6 <= fl_d5;
		fl_d7 <= fl_d6;
		fl_d8 <= fl_d7;
	     end
	   assign ts_out_cust_asm = fl_d3;
//	   assign ts_out_cust_asm = fld_valid_out_shl_d1;
	   
	   alt_aeu_4_cyc_add_96 adt
	     (
	      .arst(arst), 
//	      .inp1(tod_exit), 
	      .inp1(tod_exit2_tef_fl), 
	      .inp2(fld_out_shl_adj), 
	      .res(res_adt), 
	      .clk(clk)
	      );
	   
//	   alt_aeu_add_ts_96 adt
//	     (
//	      .arst(arst), 
//	      .enable(1'b1), 
//	      .inp_valid(fld_valid_out_shl), 
//	      .inp1(tod_exit), 
//	      .inp2(fld_out_shl_adj), 
//	      .out_valid(out_valid_adt), 
//	      .res(res_adt), 
//	      .clk(clk)
//	      );
	   
	   wire 	       out_valid_sbt;
	   wire [95:0] 	       res_sbt;
	   alt_aeu_4_cyc_sub_96 sbt
	     (
	      .arst(arst), 
//	      .inp1(tod_exit), 
	      .inp1(tod_exit2_tef_fl), 
	      .inp2(fld_out_shl_adj), 
	      .res(res_sbt), 
	      .clk(clk)
	      );

//	   alt_aeu_sub_ts_96 sbt
//	     (
//	      .arst(arst), 
//	      .enable(1'b1), 
//	      .inp_valid(fld_valid_out_shl), 
//	      .inp1(tod_exit),
//	      .inp2(fld_out_shl_adj), 
//	      .out_valid(out_valid_sbt), 
//	      .res(res_sbt), 
//	      .clk(clk)
//	      );

	   defparam dl3.LATENCY = 5;
	   defparam dl3.WIDTH = 120;
	   defparam dl3.TARGET_CHIP = TARGET_CHIP;

	   wire 	       fld_valid_out_dl3;
	   wire [15:0] 	       fld_offset_out_dl3;
	   wire [1:0] 	       fld_overwrite_out_dl3;
	   wire [95:0] 	       fld_out_dl3;
	   wire 	       am_insrt_out_dl3;
	   
	   delay_mlab dl3 (
			   .clk(clk),
			   .din({4'd0,am_insrt_out_shl,fld_valid_out_shl,fld_overwrite_out_shl,fld_offset_out_shl,fld_out_shl_adj}),
			   .dout({junk4,am_insrt_out_dl3,fld_valid_out_dl3,fld_overwrite_out_dl3,fld_offset_out_dl3,fld_out_dl3})
			   );

	   reg 		       fld_valid_out_mx3;
	   reg 		       am_insrt_out_mx3;
	   reg [15:0] 	       fld_offset_out_mx3;
	   reg [95:0] 	       fld_out_mx3;
	   wire [95:0] 	       tod_exit_tox;
	   
	   defparam tox.LATENCY = 4;
	   defparam tox.WIDTH = 100;
	   defparam tox.FRACTURE = 5;
	   defparam tox.TARGET_CHIP = TARGET_CHIP;
	   delay_mlab tox (
			   .clk(clk),
			   .din({4'd0,tod_exit2_tef_fl}),
			   .dout({junk4,tod_exit_tox})
			   );

	   always @(posedge clk)
	     begin
		fld_valid_out_mx3 <= fld_valid_out_dl3;
		fld_offset_out_mx3 <= fld_offset_out_dl3;
		am_insrt_out_mx3 <= am_insrt_out_dl3;
		case (fld_overwrite_out_dl3)
		  2'b00: fld_out_mx3 <= res_adt;
		  2'b01: fld_out_mx3 <= tod_exit_tox;
		  2'b11: if (ptp_v2)
                    fld_out_mx3 <= tod_cust_in;
		  else
                    fld_out_mx3 <= {16'd0,tod_cust_in[95:32],16'd0};
		  default: fld_out_mx3 <= res_sbt;
		endcase // case (fld_overwrite_out_dl3)
	     end

	   wire [255:0] fld_out_shr;
	   wire [31:0] 	fld_mask_out_shr;
	   wire [3:0] 	fld_valid_out_shr;

	   wire [95:0] 	fld_out_mx3_adj;
	   assign fld_out_mx3_adj = ptp_v2 ? fld_out_mx3 : {fld_out_mx3[79:16],32'd0};
	   
	   alt_aeu_shft_rt_40 shr
	     (
	      .arst(arst),
	      .din_valid(1'b1),
	      .ptp_v2(ptp_v2),
	      .fld_valid(fld_valid_out_mx3),
	      .fld({fld_out_mx3_adj,160'd0}),
	      .fld_offset(fld_offset_out_mx3),
	      .am_insrt(am_insrt_out_mx3),
	      .fld_valid_out(fld_valid_out_shr),
	      .fld_out(fld_out_shr),
	      .fld_offset_out(),
	      .fld_mask_out(fld_mask_out_shr),
	      .clk(clk)
	      );


	   always @(posedge clk)
	     begin
		dout_crc_dlc13_reg <= dout_crc_dlc13;
		dout_sops_dlc13_reg <= dout_sops_dlc13;
		dout_eop_pos_dlc13_reg <= dout_eop_pos_dlc13;
		dout_valid_dlc13_reg <= dout_valid_dlc13;
		dout_mlab_dlm13_reg <= dout_mlab_dlm13;
	     end
	   

	   alt_aeu_mod_pkt_40 mpk 
	     (
	      .arst(arst),
	      .ptp_s2(ptp_s2),
	      .din_valid(dout_valid_dlc13_reg),
	      .din_crc(dout_crc_dlc13_reg),
	      .din_mlab(dout_mlab_dlm13_reg),
	      .din_sops(dout_sops_dlc13_reg),
	      .din_eop_pos(dout_eop_pos_dlc13_reg),
	      .mask_valid(fld_valid_out_shr[3]),
	      .mask(fld_mask_out_shr[31:16]),
	      .mask_data(fld_out_shr[255:128]),
	      .dout_valid(dout_valid_mpk),
	      .dout_crc(dout_crc_mpk),
	      .dout_mlab(dout_mlab_mpk),
	      .dout_sops(dout_sops_mpk),
	      .dout_eop_pos(dout_eop_pos_mpk),
	      .clk(clk)
	      );

	   assign dout_crc = dout_crc_mpk;
	   assign dout_mlab = dout_mlab_mpk;
	   assign mac_out_bus = mac_out_bus_mb14;
	   assign dout_sops = dout_sops_mpk;
	   assign dout_eop_pos = dout_eop_pos_mpk;
	   assign dout_valid = dout_valid_mpk;
	   assign tod_tx_clk_st2 = tod_exit;
	   assign ptp_pkt_out = din_ptp_reg & (|din_sops) & din_valid;
	   assign tod_exit_cust = tod_exit2_tef_fl;
	   assign ts_out_cust = fld_out_shl_adj;
	end // block: ptp1
      else
	begin
	   assign dout_crc = din_crc;
	   assign dout_mlab = din_mlab;
	   assign mac_out_bus = mac_in_bus;
	   assign dout_sops = din_sops;
	   assign dout_eop_pos = din_eop_pos;
	   assign dout_valid = din_valid;
	   assign tod_tx_clk_st2 = 96'd0;
	   assign ptp_pkt_out = 1'b0;
	   assign tod_exit_cust = 96'd0;
	   assign ts_out_cust = 96'd0;
	end // else: !if(SYNOPT_PTP == 1)
   endgenerate
   

   
endmodule // alt_aeu_tx_pkt_40





