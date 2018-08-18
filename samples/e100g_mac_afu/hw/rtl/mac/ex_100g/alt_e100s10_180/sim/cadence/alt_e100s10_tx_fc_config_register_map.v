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

// 
module alt_e100s10_tx_fc_config_register_map (
// register offset : 0x00, field offset : 0, access : RO
// register offset : 0x01, field offset : 0, access : RW
// register offset : 0x02, field offset : 0, access : RO
// register offset : 0x03, field offset : 0, access : RO
// register offset : 0x04, field offset : 0, access : RO
// register offset : 0x40, field offset : 0, access : RW
output	reg  PFC_SEL_pfc_sel ,
// register offset : 0x40, field offset : 1, access : RO
// register offset : 0x05, field offset : 0, access : RW
output	reg  FC_ENA_ena_q0 ,
// register offset : 0x05, field offset : 1, access : RW
output	reg  FC_ENA_ena_q1 ,
// register offset : 0x05, field offset : 2, access : RW
output	reg  FC_ENA_ena_q2 ,
// register offset : 0x05, field offset : 3, access : RW
output	reg  FC_ENA_ena_q3 ,
// register offset : 0x05, field offset : 4, access : RW
output	reg  FC_ENA_ena_q4 ,
// register offset : 0x05, field offset : 5, access : RW
output	reg  FC_ENA_ena_q5 ,
// register offset : 0x05, field offset : 6, access : RW
output	reg  FC_ENA_ena_q6 ,
// register offset : 0x05, field offset : 7, access : RW
output	reg  FC_ENA_ena_q7 ,
// register offset : 0x05, field offset : 8, access : RO
// register offset : 0x20, field offset : 0, access : RW
output	reg [15:0] FC_QUANTA0_pfc_quanta0 ,
// register offset : 0x20, field offset : 16, access : RO
// register offset : 0x21, field offset : 0, access : RW
output	reg [15:0] FC_QUANTA1_pfc_quanta1 ,
// register offset : 0x21, field offset : 16, access : RO
// register offset : 0x22, field offset : 0, access : RW
output	reg [15:0] FC_QUANTA2_pfc_quanta2 ,
// register offset : 0x22, field offset : 16, access : RO
// register offset : 0x23, field offset : 0, access : RW
output	reg [15:0] FC_QUANTA3_pfc_quanta3 ,
// register offset : 0x23, field offset : 16, access : RO
// register offset : 0x24, field offset : 0, access : RW
output	reg [15:0] FC_QUANTA4_pfc_quanta4 ,
// register offset : 0x24, field offset : 16, access : RO
// register offset : 0x25, field offset : 0, access : RW
output	reg [15:0] FC_QUANTA5_pfc_quanta5 ,
// register offset : 0x25, field offset : 16, access : RO
// register offset : 0x26, field offset : 0, access : RW
output	reg [15:0] FC_QUANTA6_pfc_quanta6 ,
// register offset : 0x26, field offset : 16, access : RO
// register offset : 0x27, field offset : 0, access : RW
output	reg [15:0] FC_QUANTA7_pfc_quanta7 ,
// register offset : 0x27, field offset : 16, access : RO
// register offset : 0x41, field offset : 0, access : RW
output	reg  FC_REQ_MODE_fc_2b_mode_csr_sel_q0 ,
// register offset : 0x41, field offset : 1, access : RW
output	reg  FC_REQ_MODE_fc_2b_mode_csr_sel_q1 ,
// register offset : 0x41, field offset : 2, access : RW
output	reg  FC_REQ_MODE_fc_2b_mode_csr_sel_q2 ,
// register offset : 0x41, field offset : 3, access : RW
output	reg  FC_REQ_MODE_fc_2b_mode_csr_sel_q3 ,
// register offset : 0x41, field offset : 4, access : RW
output	reg  FC_REQ_MODE_fc_2b_mode_csr_sel_q4 ,
// register offset : 0x41, field offset : 5, access : RW
output	reg  FC_REQ_MODE_fc_2b_mode_csr_sel_q5 ,
// register offset : 0x41, field offset : 6, access : RW
output	reg  FC_REQ_MODE_fc_2b_mode_csr_sel_q6 ,
// register offset : 0x41, field offset : 7, access : RW
output	reg  FC_REQ_MODE_fc_2b_mode_csr_sel_q7 ,
// register offset : 0x41, field offset : 8, access : RO
// register offset : 0x41, field offset : 16, access : RW
output	reg  FC_REQ_MODE_fc_2b_mode_sel ,
// register offset : 0x41, field offset : 17, access : RO
// register offset : 0x06, field offset : 0, access : RW
output	reg  FC_XONXOFF_REQ_req0_q0 ,
// register offset : 0x06, field offset : 1, access : RW
output	reg  FC_XONXOFF_REQ_req0_q1 ,
// register offset : 0x06, field offset : 2, access : RW
output	reg  FC_XONXOFF_REQ_req0_q2 ,
// register offset : 0x06, field offset : 3, access : RW
output	reg  FC_XONXOFF_REQ_req0_q3 ,
// register offset : 0x06, field offset : 4, access : RW
output	reg  FC_XONXOFF_REQ_req0_q4 ,
// register offset : 0x06, field offset : 5, access : RW
output	reg  FC_XONXOFF_REQ_req0_q5 ,
// register offset : 0x06, field offset : 6, access : RW
output	reg  FC_XONXOFF_REQ_req0_q6 ,
// register offset : 0x06, field offset : 7, access : RW
output	reg  FC_XONXOFF_REQ_req0_q7 ,
// register offset : 0x06, field offset : 8, access : RO
// register offset : 0x06, field offset : 16, access : RW
output	reg  FC_XONXOFF_REQ_req1_q0 ,
// register offset : 0x06, field offset : 17, access : RW
output	reg  FC_XONXOFF_REQ_req1_q1 ,
// register offset : 0x06, field offset : 18, access : RW
output	reg  FC_XONXOFF_REQ_req1_q2 ,
// register offset : 0x06, field offset : 19, access : RW
output	reg  FC_XONXOFF_REQ_req1_q3 ,
// register offset : 0x06, field offset : 20, access : RW
output	reg  FC_XONXOFF_REQ_req1_q4 ,
// register offset : 0x06, field offset : 21, access : RW
output	reg  FC_XONXOFF_REQ_req1_q5 ,
// register offset : 0x06, field offset : 22, access : RW
output	reg  FC_XONXOFF_REQ_req1_q6 ,
// register offset : 0x06, field offset : 23, access : RW
output	reg  FC_XONXOFF_REQ_req1_q7 ,
// register offset : 0x06, field offset : 24, access : RO
// register offset : 0x0d, field offset : 0, access : RW
output	reg [31:0] FC_DEST_ADDR_LOW_fc_dest_addr ,
// register offset : 0x0e, field offset : 0, access : RW
output	reg [15:0] FC_DEST_ADDR_HI_fc_dest_addr ,
// register offset : 0x0e, field offset : 16, access : RO
// register offset : 0x28, field offset : 0, access : RW
output	reg [15:0] FC_HOLD_QUANTA0_hold_quanta0 ,
// register offset : 0x28, field offset : 16, access : RO
// register offset : 0x29, field offset : 0, access : RW
output	reg [15:0] FC_HOLD_QUANTA1_hold_quanta1 ,
// register offset : 0x29, field offset : 16, access : RO
// register offset : 0x2a, field offset : 0, access : RW
output	reg [15:0] FC_HOLD_QUANTA2_hold_quanta2 ,
// register offset : 0x2a, field offset : 16, access : RO
// register offset : 0x2b, field offset : 0, access : RW
output	reg [15:0] FC_HOLD_QUANTA3_hold_quanta3 ,
// register offset : 0x2b, field offset : 16, access : RO
// register offset : 0x2c, field offset : 0, access : RW
output	reg [15:0] FC_HOLD_QUANTA4_hold_quanta4 ,
// register offset : 0x2c, field offset : 16, access : RO
// register offset : 0x2d, field offset : 0, access : RW
output	reg [15:0] FC_HOLD_QUANTA5_hold_quanta5 ,
// register offset : 0x2d, field offset : 16, access : RO
// register offset : 0x2e, field offset : 0, access : RW
output	reg [15:0] FC_HOLD_QUANTA6_hold_quanta6 ,
// register offset : 0x2e, field offset : 16, access : RO
// register offset : 0x2f, field offset : 0, access : RW
output	reg [15:0] FC_HOLD_QUANTA7_hold_quanta7 ,
// register offset : 0x2f, field offset : 16, access : RO
// register offset : 0x0f, field offset : 0, access : RW
output	reg [31:0] FC_SRC_ADDR_LOW_fc_src_addr ,
// register offset : 0x10, field offset : 0, access : RW
output	reg [15:0] FC_SRC_ADDR_HI_fc_src_addr ,
// register offset : 0x10, field offset : 16, access : RO
// register offset : 0x0a, field offset : 0, access : RW
output	reg  FC_TX_OFF_EN_tx_off_en ,
// register offset : 0x0a, field offset : 1, access : RO
// Interrupt Ports
//Bus Interface
input clk,

input reset,
input [31:0] writedata,
input read,
input write,
input [3:0] byteenable,
output reg [31:0] readdata,
output reg readdatavalid,
input [7:0] address

);

wire reset_n = !reset;	

// Protocol management
// combinatorial read data signal declaration
reg [31:0] rdata_comb;

// synchronous process for the read
always @(posedge clk)  
   if (!reset_n) readdata[31:0] <= 32'h0; else readdata[31:0] <= rdata_comb[31:0];

// read data is always returned on the next cycle
always @( posedge clk)
   if (!reset_n) readdatavalid <= 1'b0; else readdatavalid <= read;
//
//  Protocol specific assignment to inside signals
//
wire  we = write;
wire  re = read;
wire [7:0] addr = address[7:0];
wire [31:0] din  = writedata [31:0];
// A write byte enable for each register
// register FC_SCR_PAD with  writeType:  write
wire	[3:0]  we_FC_SCR_PAD		=	we  & (addr[7:0]  == 8'h01)	?	byteenable[3:0]	:	{4{1'b0}};
// register PFC_SEL with  writeType:  write
wire	  we_PFC_SEL		=	we  & (addr[7:0]  == 8'h40)	?	byteenable[0]	:	1'b0;
// register FC_ENA with  writeType:  write
wire	  we_FC_ENA		=	we  & (addr[7:0]  == 8'h05)	?	byteenable[0]	:	1'b0;
// register FC_QUANTA0 with  writeType:  write
wire	[1:0]  we_FC_QUANTA0		=	we  & (addr[7:0]  == 8'h20)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_QUANTA1 with  writeType:  write
wire	[1:0]  we_FC_QUANTA1		=	we  & (addr[7:0]  == 8'h21)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_QUANTA2 with  writeType:  write
wire	[1:0]  we_FC_QUANTA2		=	we  & (addr[7:0]  == 8'h22)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_QUANTA3 with  writeType:  write
wire	[1:0]  we_FC_QUANTA3		=	we  & (addr[7:0]  == 8'h23)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_QUANTA4 with  writeType:  write
wire	[1:0]  we_FC_QUANTA4		=	we  & (addr[7:0]  == 8'h24)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_QUANTA5 with  writeType:  write
wire	[1:0]  we_FC_QUANTA5		=	we  & (addr[7:0]  == 8'h25)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_QUANTA6 with  writeType:  write
wire	[1:0]  we_FC_QUANTA6		=	we  & (addr[7:0]  == 8'h26)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_QUANTA7 with  writeType:  write
wire	[1:0]  we_FC_QUANTA7		=	we  & (addr[7:0]  == 8'h27)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_REQ_MODE with  writeType:  write
wire	[2:0]  we_FC_REQ_MODE		=	we  & (addr[7:0]  == 8'h41)	?	byteenable[2:0]	:	{3{1'b0}};
// register FC_XONXOFF_REQ with  writeType:  write
wire	[2:0]  we_FC_XONXOFF_REQ		=	we  & (addr[7:0]  == 8'h06)	?	byteenable[2:0]	:	{3{1'b0}};
// register FC_DEST_ADDR_LOW with  writeType:  write
wire	[3:0]  we_FC_DEST_ADDR_LOW		=	we  & (addr[7:0]  == 8'h0d)	?	byteenable[3:0]	:	{4{1'b0}};
// register FC_DEST_ADDR_HI with  writeType:  write
wire	[1:0]  we_FC_DEST_ADDR_HI		=	we  & (addr[7:0]  == 8'h0e)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_HOLD_QUANTA0 with  writeType:  write
wire	[1:0]  we_FC_HOLD_QUANTA0		=	we  & (addr[7:0]  == 8'h28)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_HOLD_QUANTA1 with  writeType:  write
wire	[1:0]  we_FC_HOLD_QUANTA1		=	we  & (addr[7:0]  == 8'h29)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_HOLD_QUANTA2 with  writeType:  write
wire	[1:0]  we_FC_HOLD_QUANTA2		=	we  & (addr[7:0]  == 8'h2a)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_HOLD_QUANTA3 with  writeType:  write
wire	[1:0]  we_FC_HOLD_QUANTA3		=	we  & (addr[7:0]  == 8'h2b)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_HOLD_QUANTA4 with  writeType:  write
wire	[1:0]  we_FC_HOLD_QUANTA4		=	we  & (addr[7:0]  == 8'h2c)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_HOLD_QUANTA5 with  writeType:  write
wire	[1:0]  we_FC_HOLD_QUANTA5		=	we  & (addr[7:0]  == 8'h2d)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_HOLD_QUANTA6 with  writeType:  write
wire	[1:0]  we_FC_HOLD_QUANTA6		=	we  & (addr[7:0]  == 8'h2e)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_HOLD_QUANTA7 with  writeType:  write
wire	[1:0]  we_FC_HOLD_QUANTA7		=	we  & (addr[7:0]  == 8'h2f)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_SRC_ADDR_LOW with  writeType:  write
wire	[3:0]  we_FC_SRC_ADDR_LOW		=	we  & (addr[7:0]  == 8'h0f)	?	byteenable[3:0]	:	{4{1'b0}};
// register FC_SRC_ADDR_HI with  writeType:  write
wire	[1:0]  we_FC_SRC_ADDR_HI		=	we  & (addr[7:0]  == 8'h10)	?	byteenable[1:0]	:	{2{1'b0}};
// register FC_TX_OFF_EN with  writeType:  write
wire	  we_FC_TX_OFF_EN		=	we  & (addr[7:0]  == 8'h0a)	?	byteenable[0]	:	1'b0;

// A read byte 	enable for each register


/* Definitions of REGISTER "FC_REV_ID" */

// FC_REV_ID_rev_id
// customType  RO
// hwAccess: NA 
// reset value : 0x09162016 
// NO register generated


/* Definitions of REGISTER "FC_SCR_PAD" */

// FC_SCR_PAD_scr_pad
// customType  RW
// hwAccess: NA 
// reset value : 0x00000000 

reg [31:0] FC_SCR_PAD_scr_pad; // 
always @( posedge clk)
   if (!reset_n)  begin
      FC_SCR_PAD_scr_pad <= 32'h00000000;
   end
   else  begin
      if (we_FC_SCR_PAD[0]) begin 
         FC_SCR_PAD_scr_pad[7:0]   <=  din[7:0];  //
      end
      if (we_FC_SCR_PAD[1]) begin 
         FC_SCR_PAD_scr_pad[15:8]   <=  din[15:8];  //
      end
      if (we_FC_SCR_PAD[2]) begin 
         FC_SCR_PAD_scr_pad[23:16]   <=  din[23:16];  //
      end
      if (we_FC_SCR_PAD[3]) begin 
         FC_SCR_PAD_scr_pad[31:24]   <=  din[31:24];  //
      end
end

/* Definitions of REGISTER "FC_VAR0" */

// FC_VAR0_fc_var0
// customType  RO
// hwAccess: NA 
// reset value : 0x31303047 
// NO register generated


/* Definitions of REGISTER "FC_VAR1" */

// FC_VAR1_fc_var1
// customType  RO
// hwAccess: NA 
// reset value : 0x46435478 
// NO register generated


/* Definitions of REGISTER "FC_VAR2" */

// FC_VAR2_fc_var2
// customType  RO
// hwAccess: NA 
// reset value : 0x00435352 
// NO register generated


/* Definitions of REGISTER "PFC_SEL" */

// PFC_SEL_pfc_sel
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      PFC_SEL_pfc_sel <= 1'h1;
   end
   else  begin
      if (we_PFC_SEL) begin 
         PFC_SEL_pfc_sel   <=  din[0];  //
      end
end

// PFC_SEL_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x00000000 
// NO register generated


/* Definitions of REGISTER "FC_ENA" */

// FC_ENA_ena_q0
// bitfield description: Enable bit for PFC queue 0
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_ENA_ena_q0 <= 1'h1;
   end
   else  begin
      if (we_FC_ENA) begin 
         FC_ENA_ena_q0   <=  din[0];  //
      end
end

// FC_ENA_ena_q1
// bitfield description: Enable bit for PFC queue 1
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_ENA_ena_q1 <= 1'h1;
   end
   else  begin
      if (we_FC_ENA) begin 
         FC_ENA_ena_q1   <=  din[1];  //
      end
end

// FC_ENA_ena_q2
// bitfield description: Enable bit for PFC queue 2
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_ENA_ena_q2 <= 1'h1;
   end
   else  begin
      if (we_FC_ENA) begin 
         FC_ENA_ena_q2   <=  din[2];  //
      end
end

// FC_ENA_ena_q3
// bitfield description: Enable bit for PFC queue 3
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_ENA_ena_q3 <= 1'h1;
   end
   else  begin
      if (we_FC_ENA) begin 
         FC_ENA_ena_q3   <=  din[3];  //
      end
end

// FC_ENA_ena_q4
// bitfield description: Enable bit for PFC queue 4
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_ENA_ena_q4 <= 1'h1;
   end
   else  begin
      if (we_FC_ENA) begin 
         FC_ENA_ena_q4   <=  din[4];  //
      end
end

// FC_ENA_ena_q5
// bitfield description: Enable bit for PFC queue 5
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_ENA_ena_q5 <= 1'h1;
   end
   else  begin
      if (we_FC_ENA) begin 
         FC_ENA_ena_q5   <=  din[5];  //
      end
end

// FC_ENA_ena_q6
// bitfield description: Enable bit for PFC queue 6
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_ENA_ena_q6 <= 1'h1;
   end
   else  begin
      if (we_FC_ENA) begin 
         FC_ENA_ena_q6   <=  din[6];  //
      end
end

// FC_ENA_ena_q7
// bitfield description: Enable bit for PFC queue 7
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_ENA_ena_q7 <= 1'h1;
   end
   else  begin
      if (we_FC_ENA) begin 
         FC_ENA_ena_q7   <=  din[7];  //
      end
end

// FC_ENA_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x000000 
// NO register generated


/* Definitions of REGISTER "FC_QUANTA0" */

// FC_QUANTA0_pfc_quanta0
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_QUANTA0_pfc_quanta0 <= 16'hffff;
   end
   else  begin
      if (we_FC_QUANTA0[0]) begin 
         FC_QUANTA0_pfc_quanta0[7:0]   <=  din[7:0];  //
      end
      if (we_FC_QUANTA0[1]) begin 
         FC_QUANTA0_pfc_quanta0[15:8]   <=  din[15:8];  //
      end
end

// FC_QUANTA0_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_QUANTA1" */

// FC_QUANTA1_pfc_quanta1
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_QUANTA1_pfc_quanta1 <= 16'hffff;
   end
   else  begin
      if (we_FC_QUANTA1[0]) begin 
         FC_QUANTA1_pfc_quanta1[7:0]   <=  din[7:0];  //
      end
      if (we_FC_QUANTA1[1]) begin 
         FC_QUANTA1_pfc_quanta1[15:8]   <=  din[15:8];  //
      end
end

// FC_QUANTA1_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_QUANTA2" */

// FC_QUANTA2_pfc_quanta2
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_QUANTA2_pfc_quanta2 <= 16'hffff;
   end
   else  begin
      if (we_FC_QUANTA2[0]) begin 
         FC_QUANTA2_pfc_quanta2[7:0]   <=  din[7:0];  //
      end
      if (we_FC_QUANTA2[1]) begin 
         FC_QUANTA2_pfc_quanta2[15:8]   <=  din[15:8];  //
      end
end

// FC_QUANTA2_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_QUANTA3" */

// FC_QUANTA3_pfc_quanta3
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_QUANTA3_pfc_quanta3 <= 16'hffff;
   end
   else  begin
      if (we_FC_QUANTA3[0]) begin 
         FC_QUANTA3_pfc_quanta3[7:0]   <=  din[7:0];  //
      end
      if (we_FC_QUANTA3[1]) begin 
         FC_QUANTA3_pfc_quanta3[15:8]   <=  din[15:8];  //
      end
end

// FC_QUANTA3_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_QUANTA4" */

// FC_QUANTA4_pfc_quanta4
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_QUANTA4_pfc_quanta4 <= 16'hffff;
   end
   else  begin
      if (we_FC_QUANTA4[0]) begin 
         FC_QUANTA4_pfc_quanta4[7:0]   <=  din[7:0];  //
      end
      if (we_FC_QUANTA4[1]) begin 
         FC_QUANTA4_pfc_quanta4[15:8]   <=  din[15:8];  //
      end
end

// FC_QUANTA4_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_QUANTA5" */

// FC_QUANTA5_pfc_quanta5
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_QUANTA5_pfc_quanta5 <= 16'hffff;
   end
   else  begin
      if (we_FC_QUANTA5[0]) begin 
         FC_QUANTA5_pfc_quanta5[7:0]   <=  din[7:0];  //
      end
      if (we_FC_QUANTA5[1]) begin 
         FC_QUANTA5_pfc_quanta5[15:8]   <=  din[15:8];  //
      end
end

// FC_QUANTA5_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_QUANTA6" */

// FC_QUANTA6_pfc_quanta6
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_QUANTA6_pfc_quanta6 <= 16'hffff;
   end
   else  begin
      if (we_FC_QUANTA6[0]) begin 
         FC_QUANTA6_pfc_quanta6[7:0]   <=  din[7:0];  //
      end
      if (we_FC_QUANTA6[1]) begin 
         FC_QUANTA6_pfc_quanta6[15:8]   <=  din[15:8];  //
      end
end

// FC_QUANTA6_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_QUANTA7" */

// FC_QUANTA7_pfc_quanta7
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_QUANTA7_pfc_quanta7 <= 16'hffff;
   end
   else  begin
      if (we_FC_QUANTA7[0]) begin 
         FC_QUANTA7_pfc_quanta7[7:0]   <=  din[7:0];  //
      end
      if (we_FC_QUANTA7[1]) begin 
         FC_QUANTA7_pfc_quanta7[15:8]   <=  din[15:8];  //
      end
end

// FC_QUANTA7_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_REQ_MODE" */

// FC_REQ_MODE_fc_2b_mode_csr_sel_q0
// bitfield description: Request mode for PFC queue 0
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_REQ_MODE_fc_2b_mode_csr_sel_q0 <= 1'h0;
   end
   else  begin
      if (we_FC_REQ_MODE[0]) begin 
         FC_REQ_MODE_fc_2b_mode_csr_sel_q0   <=  din[0];  //
      end
end

// FC_REQ_MODE_fc_2b_mode_csr_sel_q1
// bitfield description: Request mode for PFC queue 1
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_REQ_MODE_fc_2b_mode_csr_sel_q1 <= 1'h0;
   end
   else  begin
      if (we_FC_REQ_MODE[0]) begin 
         FC_REQ_MODE_fc_2b_mode_csr_sel_q1   <=  din[1];  //
      end
end

// FC_REQ_MODE_fc_2b_mode_csr_sel_q2
// bitfield description: Request mode for PFC queue 2
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_REQ_MODE_fc_2b_mode_csr_sel_q2 <= 1'h0;
   end
   else  begin
      if (we_FC_REQ_MODE[0]) begin 
         FC_REQ_MODE_fc_2b_mode_csr_sel_q2   <=  din[2];  //
      end
end

// FC_REQ_MODE_fc_2b_mode_csr_sel_q3
// bitfield description: Request mode for PFC queue 3
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_REQ_MODE_fc_2b_mode_csr_sel_q3 <= 1'h0;
   end
   else  begin
      if (we_FC_REQ_MODE[0]) begin 
         FC_REQ_MODE_fc_2b_mode_csr_sel_q3   <=  din[3];  //
      end
end

// FC_REQ_MODE_fc_2b_mode_csr_sel_q4
// bitfield description: Request mode for PFC queue 4
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_REQ_MODE_fc_2b_mode_csr_sel_q4 <= 1'h0;
   end
   else  begin
      if (we_FC_REQ_MODE[0]) begin 
         FC_REQ_MODE_fc_2b_mode_csr_sel_q4   <=  din[4];  //
      end
end

// FC_REQ_MODE_fc_2b_mode_csr_sel_q5
// bitfield description: Request mode for PFC queue 5
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_REQ_MODE_fc_2b_mode_csr_sel_q5 <= 1'h0;
   end
   else  begin
      if (we_FC_REQ_MODE[0]) begin 
         FC_REQ_MODE_fc_2b_mode_csr_sel_q5   <=  din[5];  //
      end
end

// FC_REQ_MODE_fc_2b_mode_csr_sel_q6
// bitfield description: Request mode for PFC queue 6
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_REQ_MODE_fc_2b_mode_csr_sel_q6 <= 1'h0;
   end
   else  begin
      if (we_FC_REQ_MODE[0]) begin 
         FC_REQ_MODE_fc_2b_mode_csr_sel_q6   <=  din[6];  //
      end
end

// FC_REQ_MODE_fc_2b_mode_csr_sel_q7
// bitfield description: Request mode for PFC queue 7
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_REQ_MODE_fc_2b_mode_csr_sel_q7 <= 1'h0;
   end
   else  begin
      if (we_FC_REQ_MODE[0]) begin 
         FC_REQ_MODE_fc_2b_mode_csr_sel_q7   <=  din[7];  //
      end
end

// FC_REQ_MODE_reserved1
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x00 
// NO register generated


// FC_REQ_MODE_fc_2b_mode_sel
// bitfield description: 1-bit vs 2-bit request
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_REQ_MODE_fc_2b_mode_sel <= 1'h0;
   end
   else  begin
      if (we_FC_REQ_MODE[2]) begin 
         FC_REQ_MODE_fc_2b_mode_sel   <=  din[16];  //
      end
end

// FC_REQ_MODE_reserved2
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_XONXOFF_REQ" */

// FC_XONXOFF_REQ_req0_q0
// bitfield description: Request bit-0 for PFC queue 0
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req0_q0 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[0]) begin 
         FC_XONXOFF_REQ_req0_q0   <=  din[0];  //
      end
end

// FC_XONXOFF_REQ_req0_q1
// bitfield description: Request bit-0 for PFC queue 1
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req0_q1 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[0]) begin 
         FC_XONXOFF_REQ_req0_q1   <=  din[1];  //
      end
end

// FC_XONXOFF_REQ_req0_q2
// bitfield description: Request bit-0 for PFC queue 2
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req0_q2 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[0]) begin 
         FC_XONXOFF_REQ_req0_q2   <=  din[2];  //
      end
end

// FC_XONXOFF_REQ_req0_q3
// bitfield description: Request bit-0 for PFC queue 3
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req0_q3 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[0]) begin 
         FC_XONXOFF_REQ_req0_q3   <=  din[3];  //
      end
end

// FC_XONXOFF_REQ_req0_q4
// bitfield description: Request bit-0 for PFC queue 4
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req0_q4 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[0]) begin 
         FC_XONXOFF_REQ_req0_q4   <=  din[4];  //
      end
end

// FC_XONXOFF_REQ_req0_q5
// bitfield description: Request bit-0 for PFC queue 5
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req0_q5 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[0]) begin 
         FC_XONXOFF_REQ_req0_q5   <=  din[5];  //
      end
end

// FC_XONXOFF_REQ_req0_q6
// bitfield description: Request bit-0 for PFC queue 6
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req0_q6 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[0]) begin 
         FC_XONXOFF_REQ_req0_q6   <=  din[6];  //
      end
end

// FC_XONXOFF_REQ_req0_q7
// bitfield description: Request bit-0 for PFC queue 7
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req0_q7 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[0]) begin 
         FC_XONXOFF_REQ_req0_q7   <=  din[7];  //
      end
end

// FC_XONXOFF_REQ_reserved1
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x00 
// NO register generated


// FC_XONXOFF_REQ_req1_q0
// bitfield description: Request bit-1 for PFC queue 0
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req1_q0 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[2]) begin 
         FC_XONXOFF_REQ_req1_q0   <=  din[16];  //
      end
end

// FC_XONXOFF_REQ_req1_q1
// bitfield description: Request bit-1 for PFC queue 1
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req1_q1 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[2]) begin 
         FC_XONXOFF_REQ_req1_q1   <=  din[17];  //
      end
end

// FC_XONXOFF_REQ_req1_q2
// bitfield description: Request bit-1 for PFC queue 2
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req1_q2 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[2]) begin 
         FC_XONXOFF_REQ_req1_q2   <=  din[18];  //
      end
end

// FC_XONXOFF_REQ_req1_q3
// bitfield description: Request bit-1 for PFC queue 3
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req1_q3 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[2]) begin 
         FC_XONXOFF_REQ_req1_q3   <=  din[19];  //
      end
end

// FC_XONXOFF_REQ_req1_q4
// bitfield description: Request bit-1 for PFC queue 4
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req1_q4 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[2]) begin 
         FC_XONXOFF_REQ_req1_q4   <=  din[20];  //
      end
end

// FC_XONXOFF_REQ_req1_q5
// bitfield description: Request bit-1 for PFC queue 5
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req1_q5 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[2]) begin 
         FC_XONXOFF_REQ_req1_q5   <=  din[21];  //
      end
end

// FC_XONXOFF_REQ_req1_q6
// bitfield description: Request bit-1 for PFC queue 6
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req1_q6 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[2]) begin 
         FC_XONXOFF_REQ_req1_q6   <=  din[22];  //
      end
end

// FC_XONXOFF_REQ_req1_q7
// bitfield description: Request bit-1 for PFC queue 7
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_XONXOFF_REQ_req1_q7 <= 1'h0;
   end
   else  begin
      if (we_FC_XONXOFF_REQ[2]) begin 
         FC_XONXOFF_REQ_req1_q7   <=  din[23];  //
      end
end

// FC_XONXOFF_REQ_reserved2
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x00 
// NO register generated


/* Definitions of REGISTER "FC_DEST_ADDR_LOW" */

// FC_DEST_ADDR_LOW_fc_dest_addr
// customType  RW
// hwAccess: RO 
// reset value : 0xc2000001 

always @( posedge clk)
   if (!reset_n)  begin
      FC_DEST_ADDR_LOW_fc_dest_addr <= 32'hc2000001;
   end
   else  begin
      if (we_FC_DEST_ADDR_LOW[0]) begin 
         FC_DEST_ADDR_LOW_fc_dest_addr[7:0]   <=  din[7:0];  //
      end
      if (we_FC_DEST_ADDR_LOW[1]) begin 
         FC_DEST_ADDR_LOW_fc_dest_addr[15:8]   <=  din[15:8];  //
      end
      if (we_FC_DEST_ADDR_LOW[2]) begin 
         FC_DEST_ADDR_LOW_fc_dest_addr[23:16]   <=  din[23:16];  //
      end
      if (we_FC_DEST_ADDR_LOW[3]) begin 
         FC_DEST_ADDR_LOW_fc_dest_addr[31:24]   <=  din[31:24];  //
      end
end

/* Definitions of REGISTER "FC_DEST_ADDR_HI" */

// FC_DEST_ADDR_HI_fc_dest_addr
// customType  RW
// hwAccess: RO 
// reset value : 0x0180 

always @( posedge clk)
   if (!reset_n)  begin
      FC_DEST_ADDR_HI_fc_dest_addr <= 16'h0180;
   end
   else  begin
      if (we_FC_DEST_ADDR_HI[0]) begin 
         FC_DEST_ADDR_HI_fc_dest_addr[7:0]   <=  din[7:0];  //
      end
      if (we_FC_DEST_ADDR_HI[1]) begin 
         FC_DEST_ADDR_HI_fc_dest_addr[15:8]   <=  din[15:8];  //
      end
end

// FC_DEST_ADDR_HI_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_HOLD_QUANTA0" */

// FC_HOLD_QUANTA0_hold_quanta0
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_HOLD_QUANTA0_hold_quanta0 <= 16'hffff;
   end
   else  begin
      if (we_FC_HOLD_QUANTA0[0]) begin 
         FC_HOLD_QUANTA0_hold_quanta0[7:0]   <=  din[7:0];  //
      end
      if (we_FC_HOLD_QUANTA0[1]) begin 
         FC_HOLD_QUANTA0_hold_quanta0[15:8]   <=  din[15:8];  //
      end
end

// FC_HOLD_QUANTA0_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_HOLD_QUANTA1" */

// FC_HOLD_QUANTA1_hold_quanta1
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_HOLD_QUANTA1_hold_quanta1 <= 16'hffff;
   end
   else  begin
      if (we_FC_HOLD_QUANTA1[0]) begin 
         FC_HOLD_QUANTA1_hold_quanta1[7:0]   <=  din[7:0];  //
      end
      if (we_FC_HOLD_QUANTA1[1]) begin 
         FC_HOLD_QUANTA1_hold_quanta1[15:8]   <=  din[15:8];  //
      end
end

// FC_HOLD_QUANTA1_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_HOLD_QUANTA2" */

// FC_HOLD_QUANTA2_hold_quanta2
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_HOLD_QUANTA2_hold_quanta2 <= 16'hffff;
   end
   else  begin
      if (we_FC_HOLD_QUANTA2[0]) begin 
         FC_HOLD_QUANTA2_hold_quanta2[7:0]   <=  din[7:0];  //
      end
      if (we_FC_HOLD_QUANTA2[1]) begin 
         FC_HOLD_QUANTA2_hold_quanta2[15:8]   <=  din[15:8];  //
      end
end

// FC_HOLD_QUANTA2_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_HOLD_QUANTA3" */

// FC_HOLD_QUANTA3_hold_quanta3
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_HOLD_QUANTA3_hold_quanta3 <= 16'hffff;
   end
   else  begin
      if (we_FC_HOLD_QUANTA3[0]) begin 
         FC_HOLD_QUANTA3_hold_quanta3[7:0]   <=  din[7:0];  //
      end
      if (we_FC_HOLD_QUANTA3[1]) begin 
         FC_HOLD_QUANTA3_hold_quanta3[15:8]   <=  din[15:8];  //
      end
end

// FC_HOLD_QUANTA3_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_HOLD_QUANTA4" */

// FC_HOLD_QUANTA4_hold_quanta4
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_HOLD_QUANTA4_hold_quanta4 <= 16'hffff;
   end
   else  begin
      if (we_FC_HOLD_QUANTA4[0]) begin 
         FC_HOLD_QUANTA4_hold_quanta4[7:0]   <=  din[7:0];  //
      end
      if (we_FC_HOLD_QUANTA4[1]) begin 
         FC_HOLD_QUANTA4_hold_quanta4[15:8]   <=  din[15:8];  //
      end
end

// FC_HOLD_QUANTA4_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_HOLD_QUANTA5" */

// FC_HOLD_QUANTA5_hold_quanta5
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_HOLD_QUANTA5_hold_quanta5 <= 16'hffff;
   end
   else  begin
      if (we_FC_HOLD_QUANTA5[0]) begin 
         FC_HOLD_QUANTA5_hold_quanta5[7:0]   <=  din[7:0];  //
      end
      if (we_FC_HOLD_QUANTA5[1]) begin 
         FC_HOLD_QUANTA5_hold_quanta5[15:8]   <=  din[15:8];  //
      end
end

// FC_HOLD_QUANTA5_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_HOLD_QUANTA6" */

// FC_HOLD_QUANTA6_hold_quanta6
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_HOLD_QUANTA6_hold_quanta6 <= 16'hffff;
   end
   else  begin
      if (we_FC_HOLD_QUANTA6[0]) begin 
         FC_HOLD_QUANTA6_hold_quanta6[7:0]   <=  din[7:0];  //
      end
      if (we_FC_HOLD_QUANTA6[1]) begin 
         FC_HOLD_QUANTA6_hold_quanta6[15:8]   <=  din[15:8];  //
      end
end

// FC_HOLD_QUANTA6_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_HOLD_QUANTA7" */

// FC_HOLD_QUANTA7_hold_quanta7
// customType  RW
// hwAccess: RO 
// reset value : 0xffff 

always @( posedge clk)
   if (!reset_n)  begin
      FC_HOLD_QUANTA7_hold_quanta7 <= 16'hffff;
   end
   else  begin
      if (we_FC_HOLD_QUANTA7[0]) begin 
         FC_HOLD_QUANTA7_hold_quanta7[7:0]   <=  din[7:0];  //
      end
      if (we_FC_HOLD_QUANTA7[1]) begin 
         FC_HOLD_QUANTA7_hold_quanta7[15:8]   <=  din[15:8];  //
      end
end

// FC_HOLD_QUANTA7_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_SRC_ADDR_LOW" */

// FC_SRC_ADDR_LOW_fc_src_addr
// customType  RW
// hwAccess: RO 
// reset value : 0xcbfc5add 

always @( posedge clk)
   if (!reset_n)  begin
      FC_SRC_ADDR_LOW_fc_src_addr <= 32'hcbfc5add;
   end
   else  begin
      if (we_FC_SRC_ADDR_LOW[0]) begin 
         FC_SRC_ADDR_LOW_fc_src_addr[7:0]   <=  din[7:0];  //
      end
      if (we_FC_SRC_ADDR_LOW[1]) begin 
         FC_SRC_ADDR_LOW_fc_src_addr[15:8]   <=  din[15:8];  //
      end
      if (we_FC_SRC_ADDR_LOW[2]) begin 
         FC_SRC_ADDR_LOW_fc_src_addr[23:16]   <=  din[23:16];  //
      end
      if (we_FC_SRC_ADDR_LOW[3]) begin 
         FC_SRC_ADDR_LOW_fc_src_addr[31:24]   <=  din[31:24];  //
      end
end

/* Definitions of REGISTER "FC_SRC_ADDR_HI" */

// FC_SRC_ADDR_HI_fc_src_addr
// customType  RW
// hwAccess: RO 
// reset value : 0xe100 

always @( posedge clk)
   if (!reset_n)  begin
      FC_SRC_ADDR_HI_fc_src_addr <= 16'he100;
   end
   else  begin
      if (we_FC_SRC_ADDR_HI[0]) begin 
         FC_SRC_ADDR_HI_fc_src_addr[7:0]   <=  din[7:0];  //
      end
      if (we_FC_SRC_ADDR_HI[1]) begin 
         FC_SRC_ADDR_HI_fc_src_addr[15:8]   <=  din[15:8];  //
      end
end

// FC_SRC_ADDR_HI_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated


/* Definitions of REGISTER "FC_TX_OFF_EN" */

// FC_TX_OFF_EN_tx_off_en
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      FC_TX_OFF_EN_tx_off_en <= 1'h0;
   end
   else  begin
      if (we_FC_TX_OFF_EN) begin 
         FC_TX_OFF_EN_tx_off_en   <=  din[0];  //
      end
end

// FC_TX_OFF_EN_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x00000000 
// NO register generated





// read process
always @ (*)
begin
rdata_comb = 32'h0;
   if(re) begin
      case (addr)  
	8'h00 : begin
		rdata_comb [31:0]	= 32'h08092017 ;  // FC_REV_ID_rev_id 	is reserved or a constant value, a read access gives the reset value
	end
	8'h01 : begin
		rdata_comb [31:0]	= FC_SCR_PAD_scr_pad [31:0] ;		// readType = read   writeType =write
	end
	8'h02 : begin
		rdata_comb [31:0]	= 32'h31303047 ;  // FC_VAR0_fc_var0 	is reserved or a constant value, a read access gives the reset value
	end
	8'h03 : begin
		rdata_comb [31:0]	= 32'h46435478 ;  // FC_VAR1_fc_var1 	is reserved or a constant value, a read access gives the reset value
	end
	8'h04 : begin
		rdata_comb [31:0]	= 32'h00435352 ;  // FC_VAR2_fc_var2 	is reserved or a constant value, a read access gives the reset value
	end
	8'h40 : begin
		rdata_comb [0]	= PFC_SEL_pfc_sel  ;		// readType = read   writeType =write
		rdata_comb [31:1]	= 31'h00000000 ;  // PFC_SEL_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h05 : begin
		rdata_comb [0]	= FC_ENA_ena_q0  ;		// readType = read   writeType =write
		rdata_comb [1]	= FC_ENA_ena_q1  ;		// readType = read   writeType =write
		rdata_comb [2]	= FC_ENA_ena_q2  ;		// readType = read   writeType =write
		rdata_comb [3]	= FC_ENA_ena_q3  ;		// readType = read   writeType =write
		rdata_comb [4]	= FC_ENA_ena_q4  ;		// readType = read   writeType =write
		rdata_comb [5]	= FC_ENA_ena_q5  ;		// readType = read   writeType =write
		rdata_comb [6]	= FC_ENA_ena_q6  ;		// readType = read   writeType =write
		rdata_comb [7]	= FC_ENA_ena_q7  ;		// readType = read   writeType =write
		rdata_comb [31:8]	= 24'h000000 ;  // FC_ENA_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h20 : begin
		rdata_comb [15:0]	= FC_QUANTA0_pfc_quanta0 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_QUANTA0_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h21 : begin
		rdata_comb [15:0]	= FC_QUANTA1_pfc_quanta1 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_QUANTA1_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h22 : begin
		rdata_comb [15:0]	= FC_QUANTA2_pfc_quanta2 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_QUANTA2_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h23 : begin
		rdata_comb [15:0]	= FC_QUANTA3_pfc_quanta3 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_QUANTA3_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h24 : begin
		rdata_comb [15:0]	= FC_QUANTA4_pfc_quanta4 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_QUANTA4_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h25 : begin
		rdata_comb [15:0]	= FC_QUANTA5_pfc_quanta5 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_QUANTA5_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h26 : begin
		rdata_comb [15:0]	= FC_QUANTA6_pfc_quanta6 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_QUANTA6_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h27 : begin
		rdata_comb [15:0]	= FC_QUANTA7_pfc_quanta7 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_QUANTA7_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h41 : begin
		rdata_comb [0]	= FC_REQ_MODE_fc_2b_mode_csr_sel_q0  ;		// readType = read   writeType =write
		rdata_comb [1]	= FC_REQ_MODE_fc_2b_mode_csr_sel_q1  ;		// readType = read   writeType =write
		rdata_comb [2]	= FC_REQ_MODE_fc_2b_mode_csr_sel_q2  ;		// readType = read   writeType =write
		rdata_comb [3]	= FC_REQ_MODE_fc_2b_mode_csr_sel_q3  ;		// readType = read   writeType =write
		rdata_comb [4]	= FC_REQ_MODE_fc_2b_mode_csr_sel_q4  ;		// readType = read   writeType =write
		rdata_comb [5]	= FC_REQ_MODE_fc_2b_mode_csr_sel_q5  ;		// readType = read   writeType =write
		rdata_comb [6]	= FC_REQ_MODE_fc_2b_mode_csr_sel_q6  ;		// readType = read   writeType =write
		rdata_comb [7]	= FC_REQ_MODE_fc_2b_mode_csr_sel_q7  ;		// readType = read   writeType =write
		rdata_comb [15:8]	= 8'h00 ;  // FC_REQ_MODE_reserved1 	is reserved or a constant value, a read access gives the reset value
		rdata_comb [16]	= FC_REQ_MODE_fc_2b_mode_sel  ;		// readType = read   writeType =write
		rdata_comb [31:17]	= 15'h0000 ;  // FC_REQ_MODE_reserved2 	is reserved or a constant value, a read access gives the reset value
	end
	8'h06 : begin
		rdata_comb [0]	= FC_XONXOFF_REQ_req0_q0  ;		// readType = read   writeType =write
		rdata_comb [1]	= FC_XONXOFF_REQ_req0_q1  ;		// readType = read   writeType =write
		rdata_comb [2]	= FC_XONXOFF_REQ_req0_q2  ;		// readType = read   writeType =write
		rdata_comb [3]	= FC_XONXOFF_REQ_req0_q3  ;		// readType = read   writeType =write
		rdata_comb [4]	= FC_XONXOFF_REQ_req0_q4  ;		// readType = read   writeType =write
		rdata_comb [5]	= FC_XONXOFF_REQ_req0_q5  ;		// readType = read   writeType =write
		rdata_comb [6]	= FC_XONXOFF_REQ_req0_q6  ;		// readType = read   writeType =write
		rdata_comb [7]	= FC_XONXOFF_REQ_req0_q7  ;		// readType = read   writeType =write
		rdata_comb [15:8]	= 8'h00 ;  // FC_XONXOFF_REQ_reserved1 	is reserved or a constant value, a read access gives the reset value
		rdata_comb [16]	= FC_XONXOFF_REQ_req1_q0  ;		// readType = read   writeType =write
		rdata_comb [17]	= FC_XONXOFF_REQ_req1_q1  ;		// readType = read   writeType =write
		rdata_comb [18]	= FC_XONXOFF_REQ_req1_q2  ;		// readType = read   writeType =write
		rdata_comb [19]	= FC_XONXOFF_REQ_req1_q3  ;		// readType = read   writeType =write
		rdata_comb [20]	= FC_XONXOFF_REQ_req1_q4  ;		// readType = read   writeType =write
		rdata_comb [21]	= FC_XONXOFF_REQ_req1_q5  ;		// readType = read   writeType =write
		rdata_comb [22]	= FC_XONXOFF_REQ_req1_q6  ;		// readType = read   writeType =write
		rdata_comb [23]	= FC_XONXOFF_REQ_req1_q7  ;		// readType = read   writeType =write
		rdata_comb [31:24]	= 8'h00 ;  // FC_XONXOFF_REQ_reserved2 	is reserved or a constant value, a read access gives the reset value
	end
	8'h0d : begin
		rdata_comb [31:0]	= FC_DEST_ADDR_LOW_fc_dest_addr [31:0] ;		// readType = read   writeType =write
	end
	8'h0e : begin
		rdata_comb [15:0]	= FC_DEST_ADDR_HI_fc_dest_addr [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_DEST_ADDR_HI_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h28 : begin
		rdata_comb [15:0]	= FC_HOLD_QUANTA0_hold_quanta0 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_HOLD_QUANTA0_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h29 : begin
		rdata_comb [15:0]	= FC_HOLD_QUANTA1_hold_quanta1 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_HOLD_QUANTA1_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h2a : begin
		rdata_comb [15:0]	= FC_HOLD_QUANTA2_hold_quanta2 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_HOLD_QUANTA2_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h2b : begin
		rdata_comb [15:0]	= FC_HOLD_QUANTA3_hold_quanta3 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_HOLD_QUANTA3_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h2c : begin
		rdata_comb [15:0]	= FC_HOLD_QUANTA4_hold_quanta4 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_HOLD_QUANTA4_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h2d : begin
		rdata_comb [15:0]	= FC_HOLD_QUANTA5_hold_quanta5 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_HOLD_QUANTA5_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h2e : begin
		rdata_comb [15:0]	= FC_HOLD_QUANTA6_hold_quanta6 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_HOLD_QUANTA6_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h2f : begin
		rdata_comb [15:0]	= FC_HOLD_QUANTA7_hold_quanta7 [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_HOLD_QUANTA7_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h0f : begin
		rdata_comb [31:0]	= FC_SRC_ADDR_LOW_fc_src_addr [31:0] ;		// readType = read   writeType =write
	end
	8'h10 : begin
		rdata_comb [15:0]	= FC_SRC_ADDR_HI_fc_src_addr [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_SRC_ADDR_HI_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h0a : begin
		rdata_comb [0]	= FC_TX_OFF_EN_tx_off_en  ;		// readType = read   writeType =write
		rdata_comb [31:1]	= 31'h00000000 ;  // FC_TX_OFF_EN_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	default : begin
		rdata_comb = 32'hdeadc0de;
	end
      endcase
   end
end

endmodule
