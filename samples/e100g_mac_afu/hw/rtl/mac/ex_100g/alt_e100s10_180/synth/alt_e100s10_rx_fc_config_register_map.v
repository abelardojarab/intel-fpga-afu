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
module alt_e100s10_rx_fc_config_register_map (
// register offset : 0x0, field offset : 0, access : RO
// register offset : 0x1, field offset : 0, access : RW
// register offset : 0x2, field offset : 0, access : RO
// register offset : 0x3, field offset : 0, access : RO
// register offset : 0x4, field offset : 0, access : RO
// register offset : 0x5, field offset : 0, access : RW
output	reg  FC_RX_PFC_ENA_rx_pfc_en_q0 ,
// register offset : 0x5, field offset : 1, access : RW
output	reg  FC_RX_PFC_ENA_rx_pfc_en_q1 ,
// register offset : 0x5, field offset : 2, access : RW
output	reg  FC_RX_PFC_ENA_rx_pfc_en_q2 ,
// register offset : 0x5, field offset : 3, access : RW
output	reg  FC_RX_PFC_ENA_rx_pfc_en_q3 ,
// register offset : 0x5, field offset : 4, access : RW
output	reg  FC_RX_PFC_ENA_rx_pfc_en_q4 ,
// register offset : 0x5, field offset : 5, access : RW
output	reg  FC_RX_PFC_ENA_rx_pfc_en_q5 ,
// register offset : 0x5, field offset : 6, access : RW
output	reg  FC_RX_PFC_ENA_rx_pfc_en_q6 ,
// register offset : 0x5, field offset : 7, access : RW
output	reg  FC_RX_PFC_ENA_rx_pfc_en_q7 ,
// register offset : 0x5, field offset : 8, access : RO
// register offset : 0x7, field offset : 0, access : RW
output	reg [31:0] FC_RX_DEST_ADDR_LOW_fc_rx_dest_addr ,
// register offset : 0x8, field offset : 0, access : RW
output	reg [15:0] FC_RX_DEST_ADDR_HI_fc_rx_dest_addr ,
// register offset : 0x8, field offset : 16, access : RO
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
wire	[3:0]  we_FC_SCR_PAD		=	we  & (addr[7:0]  == 8'h1)	?	byteenable[3:0]	:	{4{1'b0}};
// register FC_RX_PFC_ENA with  writeType:  write
wire	  we_FC_RX_PFC_ENA		=	we  & (addr[7:0]  == 8'h5)	?	byteenable[0]	:	1'b0;
// register FC_RX_DEST_ADDR_LOW with  writeType:  write
wire	[3:0]  we_FC_RX_DEST_ADDR_LOW		=	we  & (addr[7:0]  == 8'h7)	?	byteenable[3:0]	:	{4{1'b0}};
// register FC_RX_DEST_ADDR_HI with  writeType:  write
wire	[1:0]  we_FC_RX_DEST_ADDR_HI		=	we  & (addr[7:0]  == 8'h8)	?	byteenable[1:0]	:	{2{1'b0}};

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
// reset value : 0x46435278 
// NO register generated


/* Definitions of REGISTER "FC_VAR2" */

// FC_VAR2_fc_var2
// customType  RO
// hwAccess: NA 
// reset value : 0x00435352 
// NO register generated


/* Definitions of REGISTER "FC_RX_PFC_ENA" */

// FC_RX_PFC_ENA_rx_pfc_en_q0
// bitfield description: RX PFC enable queue 0
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_RX_PFC_ENA_rx_pfc_en_q0 <= 1'h1;
   end
   else  begin
      if (we_FC_RX_PFC_ENA) begin 
         FC_RX_PFC_ENA_rx_pfc_en_q0   <=  din[0];  //
      end
end

// FC_RX_PFC_ENA_rx_pfc_en_q1
// bitfield description: RX PFC enable queue 1
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_RX_PFC_ENA_rx_pfc_en_q1 <= 1'h1;
   end
   else  begin
      if (we_FC_RX_PFC_ENA) begin 
         FC_RX_PFC_ENA_rx_pfc_en_q1   <=  din[1];  //
      end
end

// FC_RX_PFC_ENA_rx_pfc_en_q2
// bitfield description: RX PFC enable queue 2
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_RX_PFC_ENA_rx_pfc_en_q2 <= 1'h1;
   end
   else  begin
      if (we_FC_RX_PFC_ENA) begin 
         FC_RX_PFC_ENA_rx_pfc_en_q2   <=  din[2];  //
      end
end

// FC_RX_PFC_ENA_rx_pfc_en_q3
// bitfield description: RX PFC enable queue 3
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_RX_PFC_ENA_rx_pfc_en_q3 <= 1'h1;
   end
   else  begin
      if (we_FC_RX_PFC_ENA) begin 
         FC_RX_PFC_ENA_rx_pfc_en_q3   <=  din[3];  //
      end
end

// FC_RX_PFC_ENA_rx_pfc_en_q4
// bitfield description: RX PFC enable queue 4
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_RX_PFC_ENA_rx_pfc_en_q4 <= 1'h1;
   end
   else  begin
      if (we_FC_RX_PFC_ENA) begin 
         FC_RX_PFC_ENA_rx_pfc_en_q4   <=  din[4];  //
      end
end

// FC_RX_PFC_ENA_rx_pfc_en_q5
// bitfield description: RX PFC enable queue 5
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_RX_PFC_ENA_rx_pfc_en_q5 <= 1'h1;
   end
   else  begin
      if (we_FC_RX_PFC_ENA) begin 
         FC_RX_PFC_ENA_rx_pfc_en_q5   <=  din[5];  //
      end
end

// FC_RX_PFC_ENA_rx_pfc_en_q6
// bitfield description: RX PFC enable queue 6
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_RX_PFC_ENA_rx_pfc_en_q6 <= 1'h1;
   end
   else  begin
      if (we_FC_RX_PFC_ENA) begin 
         FC_RX_PFC_ENA_rx_pfc_en_q6   <=  din[6];  //
      end
end

// FC_RX_PFC_ENA_rx_pfc_en_q7
// bitfield description: RX PFC enable queue 7
// customType  RW
// hwAccess: RO 
// reset value : 0x1 

always @( posedge clk)
   if (!reset_n)  begin
      FC_RX_PFC_ENA_rx_pfc_en_q7 <= 1'h1;
   end
   else  begin
      if (we_FC_RX_PFC_ENA) begin 
         FC_RX_PFC_ENA_rx_pfc_en_q7   <=  din[7];  //
      end
end

// FC_RX_PFC_ENA_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x000000 
// NO register generated


/* Definitions of REGISTER "FC_RX_DEST_ADDR_LOW" */

// FC_RX_DEST_ADDR_LOW_fc_rx_dest_addr
// customType  RW
// hwAccess: RO 
// reset value : 0xc2000001 

always @( posedge clk)
   if (!reset_n)  begin
      FC_RX_DEST_ADDR_LOW_fc_rx_dest_addr <= 32'hc2000001;
   end
   else  begin
      if (we_FC_RX_DEST_ADDR_LOW[0]) begin 
         FC_RX_DEST_ADDR_LOW_fc_rx_dest_addr[7:0]   <=  din[7:0];  //
      end
      if (we_FC_RX_DEST_ADDR_LOW[1]) begin 
         FC_RX_DEST_ADDR_LOW_fc_rx_dest_addr[15:8]   <=  din[15:8];  //
      end
      if (we_FC_RX_DEST_ADDR_LOW[2]) begin 
         FC_RX_DEST_ADDR_LOW_fc_rx_dest_addr[23:16]   <=  din[23:16];  //
      end
      if (we_FC_RX_DEST_ADDR_LOW[3]) begin 
         FC_RX_DEST_ADDR_LOW_fc_rx_dest_addr[31:24]   <=  din[31:24];  //
      end
end

/* Definitions of REGISTER "FC_RX_DEST_ADDR_HI" */

// FC_RX_DEST_ADDR_HI_fc_rx_dest_addr
// customType  RW
// hwAccess: RO 
// reset value : 0x0180 

always @( posedge clk)
   if (!reset_n)  begin
      FC_RX_DEST_ADDR_HI_fc_rx_dest_addr <= 16'h0180;
   end
   else  begin
      if (we_FC_RX_DEST_ADDR_HI[0]) begin 
         FC_RX_DEST_ADDR_HI_fc_rx_dest_addr[7:0]   <=  din[7:0];  //
      end
      if (we_FC_RX_DEST_ADDR_HI[1]) begin 
         FC_RX_DEST_ADDR_HI_fc_rx_dest_addr[15:8]   <=  din[15:8];  //
      end
end

// FC_RX_DEST_ADDR_HI_reserved
// bitfield description: Reserved
// customType  RO
// hwAccess: NA 
// reset value : 0x0000 
// NO register generated





// read process
always @ (*)
begin
rdata_comb = 32'h0;
   if(re) begin
      case (addr)  
	8'h0 : begin
		rdata_comb [31:0]	= 32'h08092017 ;  // FC_REV_ID_rev_id 	is reserved or a constant value, a read access gives the reset value
	end
	8'h1 : begin
		rdata_comb [31:0]	= FC_SCR_PAD_scr_pad [31:0] ;		// readType = read   writeType =write
	end
	8'h2 : begin
		rdata_comb [31:0]	= 32'h31303047 ;  // FC_VAR0_fc_var0 	is reserved or a constant value, a read access gives the reset value
	end
	8'h3 : begin
		rdata_comb [31:0]	= 32'h46435278 ;  // FC_VAR1_fc_var1 	is reserved or a constant value, a read access gives the reset value
	end
	8'h4 : begin
		rdata_comb [31:0]	= 32'h00435352 ;  // FC_VAR2_fc_var2 	is reserved or a constant value, a read access gives the reset value
	end
	8'h5 : begin
		rdata_comb [0]	= FC_RX_PFC_ENA_rx_pfc_en_q0  ;		// readType = read   writeType =write
		rdata_comb [1]	= FC_RX_PFC_ENA_rx_pfc_en_q1  ;		// readType = read   writeType =write
		rdata_comb [2]	= FC_RX_PFC_ENA_rx_pfc_en_q2  ;		// readType = read   writeType =write
		rdata_comb [3]	= FC_RX_PFC_ENA_rx_pfc_en_q3  ;		// readType = read   writeType =write
		rdata_comb [4]	= FC_RX_PFC_ENA_rx_pfc_en_q4  ;		// readType = read   writeType =write
		rdata_comb [5]	= FC_RX_PFC_ENA_rx_pfc_en_q5  ;		// readType = read   writeType =write
		rdata_comb [6]	= FC_RX_PFC_ENA_rx_pfc_en_q6  ;		// readType = read   writeType =write
		rdata_comb [7]	= FC_RX_PFC_ENA_rx_pfc_en_q7  ;		// readType = read   writeType =write
		rdata_comb [31:8]	= 24'h000000 ;  // FC_RX_PFC_ENA_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	8'h7 : begin
		rdata_comb [31:0]	= FC_RX_DEST_ADDR_LOW_fc_rx_dest_addr [31:0] ;		// readType = read   writeType =write
	end
	8'h8 : begin
		rdata_comb [15:0]	= FC_RX_DEST_ADDR_HI_fc_rx_dest_addr [15:0] ;		// readType = read   writeType =write
		rdata_comb [31:16]	= 16'h0000 ;  // FC_RX_DEST_ADDR_HI_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	default : begin
		rdata_comb = 32'hdeadc0de;
	end
      endcase
   end
end

endmodule
