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


// (C) 2001-2012 Altera Corporation. All rights reserved.
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


`timescale 1 ps / 1 ps
// baeckler - 03-14-2010

module alt_aeuex_ptp_captr_40 #
  (
   parameter WORDS = 8,
   parameter WIDTH = 64,
   parameter DEVICE_FAMILY = "Stratix V"
   )
   (
    input arst,
    input clk,

    input  rst_wraddr,
    input [8:0] raddr,

    input    [511:0] l8_rx_data,
    input      [63:0] l8_rx_empty,
    input            l8_rx_endofpacket,
    input            l8_rx_error,
    input            l8_rx_startofpacket,
    input            l8_rx_valid,
    input [95:0]     rx_tod,

    output reg [8:0] wraddr_reg,
    output reg [511:0] rx_data_cpm_reg,
    output reg [95:0]    rx_tod_cpm_reg,
    output reg [95:0] ts_in_pkt_cpm_reg

    );

   reg 				 l8_rx_valid_d1;

   reg [511:0] 			 l8_rx_data_d1;
   reg [5:0] 			 l8_rx_empty_d1;
   reg 				 l8_rx_endofpacket_d1;
   reg 				 l8_rx_error_d1;
   reg 				 l8_rx_startofpacket_d1;
   reg [95:0] 			 rx_tod_d1;

   reg [511:0] 			 l8_rx_data_d2;
   reg [5:0] 			 l8_rx_empty_d2;
   reg 				 l8_rx_endofpacket_d2;
   reg 				 l8_rx_error_d2;
   reg 				 l8_rx_startofpacket_d2;
   reg [95:0] 			 rx_tod_d2;
   reg [95:0] 			 rx_tod_d3;
   reg [95:0] 			 rx_tod_d4;
   reg [95:0] 			 ts_in_pkt_d2;

   reg [15:0] 			 pkt_cnt;
   reg [7:0] 			 mod_pkt_cnt;

   reg 				 wr_mem_reg;
   
   wire [31:0] 			 junk32;
   
   always @(posedge clk or posedge arst)
     begin
	if (arst)
	  l8_rx_valid_d1 <= 1'b0;
	else
	  l8_rx_valid_d1 <= l8_rx_valid;
     end
   
   always @(posedge clk)
     begin
		l8_rx_data_d1 <= l8_rx_data;
		l8_rx_empty_d1 <= l8_rx_empty;
		l8_rx_endofpacket_d1 <= l8_rx_endofpacket;
		l8_rx_error_d1 <= l8_rx_error;
		l8_rx_startofpacket_d1 <= l8_rx_startofpacket;
		rx_tod_d1 <= rx_tod;
     end

   always @(posedge clk)
     begin
		l8_rx_data_d2 <= l8_rx_data_d1;
		l8_rx_empty_d2 <= l8_rx_empty_d1;
		l8_rx_endofpacket_d2 <= l8_rx_endofpacket_d1;
		l8_rx_error_d2 <= l8_rx_error_d1;
		l8_rx_startofpacket_d2 <= l8_rx_startofpacket_d1;
		rx_tod_d2 <= rx_tod_d1;
		rx_tod_d3 <= rx_tod_d2;
		rx_tod_d4 <= rx_tod_d3;
		//	ts_in_pkt_d2 <= l8_rx_data_d1[255:160];
		ts_in_pkt_d2 <= {l8_rx_data_d1[255:176],l8_rx_data_d1[127:112]};
     end

   reg wr_mem_reg_d1, wr_mem_reg_d2;
   
   always @(posedge clk)
     begin
		if (arst)
		  wr_mem_reg <= 1'b0;
		else
		  wr_mem_reg <= l8_rx_valid_d1 & l8_rx_startofpacket_d1 & (mod_pkt_cnt[2:0] == 3'b001);
		wr_mem_reg_d1 <= wr_mem_reg;
		wr_mem_reg_d2 <= wr_mem_reg_d1;
     end

   always @(posedge clk or posedge arst)
     begin
	if (arst)
	  wraddr_reg <= 8'd0;
	else
	  begin
	     if (rst_wraddr)
	       wraddr_reg <= 8'd0;
	     else
	       if (wr_mem_reg_d2)
		 wraddr_reg <= wraddr_reg + 8'd1;
	  end
     end // always @ (posedge clk or posedge arst)

   always @(posedge clk)
     begin
	if (arst)
	  begin
	     pkt_cnt <= 16'd0;
		 mod_pkt_cnt <= 8'd0;
	  end
	else
	  begin
	     if (l8_rx_valid_d1 & l8_rx_startofpacket_d1)
		   begin
			  pkt_cnt <= pkt_cnt + 16'd1;
			  if (mod_pkt_cnt == 8'd2)
				mod_pkt_cnt <= 8'd0;
			  else
				mod_pkt_cnt <= mod_pkt_cnt + 8'd1;
		   end
	  end // else: !if(arst)
	 end // always @ (posedge clk)
   
	
   defparam cpm.DATA_WIDTH = 720;
   defparam cpm.ADDR_WIDTH = 9;
   defparam cpm.EXTRA_ADDR_REGS = 0;

    wire [511:0] rx_data_cpm;
    wire [95:0]    rx_tod_cpm;
   wire [95:0] 	   ts_in_pkt_cpm;
   

   alt_a10m20k_group cpm
     (
      .wclk(clk),
      .wena(wr_mem_reg_d2),
      .waddr(wraddr_reg),
      .wdata({l8_rx_data_d2,rx_tod_d4,ts_in_pkt_d2}),
      .rclk(clk),
      .raddr(raddr),
      .rdata({l8_rx_data_cpm,rx_tod_cpm,ts_in_pkt_cpm}),
      .sticky_err(sticky_err),
      .sclr_err(sclr_err)
      );

   always @(posedge clk)
     begin
	rx_data_cpm_reg <= l8_rx_data_cpm;
	rx_tod_cpm_reg <= rx_tod_cpm;
	ts_in_pkt_cpm_reg <= ts_in_pkt_cpm;
     end

endmodule // alt_aeuex_ptp_captr_40


