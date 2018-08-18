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
// baeckler - 06-09-2010

module alt_aeuex_packet_gen2_40 #(
	parameter WORDS = 5,
	parameter WIDTH = 64,
	parameter MORE_SPACING = 1'b1,
	parameter CNTR_PAYLOAD = 1'b0,
    parameter SOP_ON_LANE0 = 1'b0
)(
	input clk,
	input ena,
	input idle,
		
	output [WORDS-1:0] sop,
	output [WORDS*8-1:0] eop,
	output [WORDS*WIDTH-1:0] dout,
  output ptp,
  output [15:0] ptp_offset,
  output [1:0] ptp_overwrite,
  output ptp_zero_tcp,
  output [15:0] ptp_tcp_offset,
  output [15:0] cnt_out,
	
	output reg [WORDS*16-1:0] sernum
);

/////////////////////////////////////////////////
// build some semi reasonable random bits

   reg [15:0] cnt = 0;

   reg [WORDS-1:0] sop_g2;
   reg [WORDS*8-1:0] eop_g2;
   reg [WORDS*WIDTH-1:0] dout_g2;
   reg ptp_g2;
   reg [15:0] ptp_offset_g2;
   reg [1:0] ptp_overwrite_g2;
   reg ptp_zero_tcp_g2;
   reg [15:0] ptp_tcp_offset_g2;

   always @(posedge clk)
     begin
	if (idle)
	  begin
	     cnt <= 16'd0;
	  end
	else
	  begin
	     if (cnt == 16'd1024)
	       cnt <= 16'd1024; // freeze
	     else
	       begin
		  if (ena)
		    cnt <= cnt + 16'd1;
	       end
	  end // else: !if(idle)
     end // always @ (posedge clk)

   always @(posedge clk)
     begin
//		if (cnt[1:0] == 2'b01)
//		  dout_g2 <= {(WORDS*8){8'h00}};
//		else
//		  dout_g2 <= {(WORDS*8){cnt[9:2]}};
		dout_g2 <= 256'd0;
     end

   reg [7:0] mod_cnt;
   
   always @(posedge clk)
	 begin
		if (idle)
		  begin
			 mod_cnt <= 8'd0;
		  end
		else
		  begin
			 if ((cnt[1:0] == 2'b11) & (ena))
			   begin
				  if (mod_cnt == 8'd2)
					mod_cnt <= 8'd0;
				  else
					mod_cnt <= mod_cnt + 8'd1;
			   end
		  end // else: !if(idle)
	 end // always @ (posedge clk)

   always @(posedge clk)
	 begin
		if (mod_cnt == 8'd1)
		  ptp_g2 = 1'b1;
		else
		  ptp_g2 = 1'b0;
	 end

   always @(posedge clk)
     begin
	if (ena)
	  begin
	     case (cnt[1:0])
	       2'b00: begin
		  sop_g2 <= 4'h0;
		  eop_g2 <= 32'd0;
//		  ptp_g2 <= 1'b0;
		  ptp_offset_g2 <= 16'd32;
		  ptp_overwrite_g2 <= 2'b01;
		  ptp_zero_tcp_g2 <= 1'b0;
		  ptp_tcp_offset_g2 <= 16'd0;
	       end
	       2'b01: begin
		  sop_g2 <= 4'h8;
		  eop_g2 <= 32'd0;
//		  if (cnt[4:2] == 3'b001) // every 8th packet
//		    ptp_g2 <= 1'b1;
//		  else
//		    ptp_g2 <= 1'b0;
		  ptp_offset_g2 <= 16'd32;
		  ptp_overwrite_g2 <= 2'b01;
		  ptp_zero_tcp_g2 <= 1'b0;
		  ptp_tcp_offset_g2 <= 16'd0;
	       end
	       2'b10: begin
		  sop_g2 <= 4'h0;
		  eop_g2 <= 32'h0000_0001;
//		  ptp_g2 <= 1'b0;
		  ptp_offset_g2 <= 16'd32;
		  ptp_overwrite_g2 <= 2'b01;
		  ptp_zero_tcp_g2 <= 1'b0;
		  ptp_tcp_offset_g2 <= 16'd0;
	       end
	       2'b11: begin
		  sop_g2 <= 4'h0;
		  eop_g2 <= 32'd0;
//		  ptp_g2 <= 1'b0;
		  ptp_offset_g2 <= 16'd32;
		  ptp_overwrite_g2 <= 2'b01;
		  ptp_zero_tcp_g2 <= 1'b0;
		  ptp_tcp_offset_g2 <= 16'd0;
	       end
	     endcase // case (cnt[1:0])
	  end // if (ena)
     end // always @ (posedge clk)
   
   assign sop = sop_g2;
   assign eop = eop_g2;
   assign dout = dout_g2;
   assign ptp = ptp_g2;
   assign ptp_offset = ptp_offset_g2;
   assign ptp_overwrite = ptp_overwrite_g2;
   assign ptp_zero_tcp = ptp_zero_tcp_g2;
   assign ptp_tcp_offset = ptp_tcp_offset_g2;
   assign cnt_out = cnt;


endmodule // alt_aeuex_packet_gen2_40


