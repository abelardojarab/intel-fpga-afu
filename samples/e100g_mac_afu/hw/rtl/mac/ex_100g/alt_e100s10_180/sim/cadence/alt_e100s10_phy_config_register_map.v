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


//-----------------------------------------------------------------------------------------------//
//   Generated with Magillem S.A. MRV generator.                                  
//   MRV generator version : 0.2
//   Protocol :  AVALON
//   Wait State : WS1_OUTPUT                                         

//-----------------------------------------------------------------------------------------------//

`timescale 1 ps / 1 ps

//-----------------------------------------------------------------------------------------------//
//   Verilog Register Bank
//   Component Name: alt_e100s10_phy_config_register_map
                                      
//   Magillem Version :   5.8.2.3_engineering                                                                         
//-----------------------------------------------------------------------------------------------//
// 
module alt_e100s10_phy_config_register_map (
// register offset : 0x00, field offset : 0, access : RO
// register offset : 0x01, field offset : 0, access : RW
// register offset : 0x02, field offset : 0, access : RO
// register offset : 0x03, field offset : 0, access : RO
// register offset : 0x04, field offset : 0, access : RO
// register offset : 0x10, field offset : 0, access : RW
output	reg  PHY_CONFIG_eio_sys_rst ,
output  reg  PHY_RSFEC_enable_rsfec,
// register offset : 0x10, field offset : 1, access : RW
output	reg  PHY_CONFIG_soft_txp_rst ,
// register offset : 0x10, field offset : 2, access : RW
output	reg  PHY_CONFIG_soft_rxp_rst ,
// register offset : 0x10, field offset : 4, access : RW
output	reg  PHY_CONFIG_set_ref_lock ,
// register offset : 0x10, field offset : 5, access : RW
output	reg  PHY_CONFIG_set_data_lock ,
// register offset : 0x12, field offset : 0, access : RO
// register offset : 0x13, field offset : 0, access : RW
output	reg [3:0] PHY_PMA_SLOOP_phy ,
// register offset : 0x14, field offset : 0, access : RW
output	reg [2:0] PHY_PCS_INDIRECT_ADDR_phy ,
// register offset : 0x15, field offset : 0, access : RO
// register offset : 0x21, field offset : 0, access : RO
// register offset : 0x22, field offset : 0, access : RO
// register offset : 0x22, field offset : 1, access : RO
// register offset : 0x22, field offset : 2, access : RO
// register offset : 0x23, field offset : 0, access : RO
// register offset : 0x24, field offset : 0, access : RW
output	reg  PHY_SCLR_FRAME_ERROR_phy ,
// register offset : 0x25, field offset : 0, access : RW
output	reg  PHY_EIO_SFTRESET_phy ,

// register offset : 0x26, field offset : 0, access : RO
// register offset : 0x26, field offset : 1, access : RO
// register offset : 0x27, field offset : 0, access : WO
output	reg [3:0] ERR_INJ_phy ,
// register offset : 0x28, field offset : 0, access : RO
// register offset : 0x29, field offset : 0, access : RO
// register offset : 0x29, field offset : 1, access : RO
// register offset : 0x30, field offset : 0, access : RO
// register offset : 0x30, field offset : 2, access : RO
// register offset : 0x30, field offset : 4, access : RO
// register offset : 0x30, field offset : 6, access : RO
// register offset : 0x31, field offset : 0, access : WO
output	reg [5:0] PHY_RX_delay ,
// register offset : 0x40, field offset : 0, access : RO
// register offset : 0x41, field offset : 0, access : RO
// register offset : 0x42, field offset : 0, access : RO
// register offset : PHY_RXPCS_STATUS, field offset : 1, access : RO
input    PHY_RXPCS_STATUS_hi_ber_i,
// register offset : LANE_DESKEWED, field offset : 0, access : RO
input    LANE_DESKEWED_locked_i,
// register offset : PHY_EIOFREQ_LOCK, field offset : 0, access : RO
input  [3:0]  PHY_EIOFREQ_LOCK_phy_i,
// register offset : PHY_RXCLK_KHZ, field offset : 0, access : RO
input  [31:0]  PHY_RXCLK_KHZ_phy_i,
// register offset : WORD_LOCK, field offset : 0, access : RO
input  [19:0]  WORD_LOCK_phy_i,
// register offset : PHY_TX_COREPLL_LOCKED, field offset : 0, access : RO
input    PHY_TX_COREPLL_LOCKED_txa_online_i,
// register offset : PCS_VLANE, field offset : 2, access : RO
input  [24:0]  PCS_VLANE_vlane1_i,
// register offset : PHY_PCS_INDIRECT_DATA, field offset : 0, access : RO
input  [3:0]  PHY_PCS_INDIRECT_DATA_phy_i,
// register offset : PCS_VLANE, field offset : 4, access : RO
input  [24:0]  PCS_VLANE_vlane2_i,
// register offset : PHY_TX_COREPLL_LOCKED, field offset : 2, access : RO
input    PHY_TX_COREPLL_LOCKED_rxp_clk_stable_i,
// register offset : AM_LOCK, field offset : 0, access : RO
input  [0:0]  AM_LOCK_phy_i,
// register offset : PHY_RXPCS_STATUS, field offset : 0, access : RO
input    PHY_RXPCS_STATUS_fully_aligned_i,
// register offset : LANE_DESKEWED, field offset : 1, access : RO
input    LANE_DESKEWED_sticky_bit_i,
// register offset : PHY_TXCLK_KHZ, field offset : 0, access : RO
input  [31:0]  PHY_TXCLK_KHZ_phy_i,
// register offset : PHY_REFCLK_KHZ, field offset : 0, access : RO
input  [31:0]  PHY_REFCLK_KHZ_phy_i,
// register offset : PHY_CLK_TX_RS, field offset : 0, access : RO
input  [31:0]  PHY_CLK_TX_RS_phy_i,
// register offset : PHY_CLK_RX_RS, field offset : 0, access : RO
input  [31:0]  PHY_CLK_RX_RS_phy_i,

// register offset : PHY_FRAME_ERROR, field offset : 0, access : RO
input  [19:0]  PHY_FRAME_ERROR_phy_i,
// register offset : PCS_VLANE, field offset : 6, access : RO
input  [24:0]  PCS_VLANE_vlane3_i,
// register offset : PCS_VLANE, field offset : 0, access : RO
input  [24:0]  PCS_VLANE_vlane0_i,
// register offset : PHY_TX_COREPLL_LOCKED, field offset : 1, access : RO
input    PHY_TX_COREPLL_LOCKED_txp_clk_stable_i,
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
input [6:0] address

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
wire [6:0] addr = address[6:0];
wire [31:0] din  = writedata [31:0];
// A write byte enable for each register
// register PHY_SCRATCH with  writeType:  write
wire	[3:0]  we_PHY_SCRATCH		=	we  & (addr[6:0]  == 7'h01)	?	byteenable[3:0]	:	{4{1'b0}};
// register PHY_CONFIG with  writeType:  write
wire	  we_PHY_CONFIG		=	we  & (addr[6:0]  == 7'h10)	?	byteenable[0]	:	1'b0;
// register PHY_RSFEC with  writeType:  write
wire	  we_PHY_RSFEC		=	we  & (addr[6:0]  == 7'h50)	?	byteenable[0]	:	1'b0;

// register PHY_PMA_SLOOP with  writeType:  write
wire	  we_PHY_PMA_SLOOP		=	we  & (addr[6:0]  == 7'h13)	?	byteenable[0]	:	1'b0;
// register PHY_PCS_INDIRECT_ADDR with  writeType:  write
wire	  we_PHY_PCS_INDIRECT_ADDR		=	we  & (addr[6:0]  == 7'h14)	?	byteenable[0]	:	1'b0;
// register PHY_SCLR_FRAME_ERROR with  writeType:  write
wire	  we_PHY_SCLR_FRAME_ERROR		=	we  & (addr[6:0]  == 7'h24)	?	byteenable[0]	:	1'b0;
// register PHY_EIO_SFTRESET with  writeType:  write
wire	[1:0]  we_PHY_EIO_SFTRESET		=	we  & (addr[6:0]  == 7'h25)	?	byteenable[1:0]	:	{2{1'b0}};
// register ERR_INJ with  writeType:  write
wire	[3:0]  we_ERR_INJ		=	we  & (addr[6:0]  == 7'h27)	?	byteenable[3:0]	:	{4{1'b0}};
// register PHY_RX with  writeType:  write
wire	  we_PHY_RX		=	we  & (addr[6:0]  == 7'h31)	?	byteenable[0]	:	1'b0;

// A read byte 	enable for each register


/* Definitions of REGISTER "PHY_REVID" */

// PHY_REVID_phy
// customType  RO
// hwAccess: NA 
// reset value : 0x08092017 
// NO register generated


/* Definitions of REGISTER "PHY_SCRATCH" */
reg [31:0] PHY_SCRATCH_phy; // 

// PHY_SCRATCH_phy
// customType  RW
// hwAccess: NA 
// reset value : 0x00000000 
// hardware write enable	:  "we_PHY_SCRATCH_phy"  

always @( posedge clk)
   if (!reset_n)  begin
      PHY_SCRATCH_phy <= 32'h00000000;
   end
   else begin
      if (we_PHY_SCRATCH[0]) begin
         PHY_SCRATCH_phy[7:0] <= din[7:0];
      end
      if (we_PHY_SCRATCH[1]) begin
         PHY_SCRATCH_phy[15:8] <= din[15:8];
      end
      if (we_PHY_SCRATCH[2]) begin
         PHY_SCRATCH_phy[23:16] <= din[23:16];
      end
      if (we_PHY_SCRATCH[3]) begin
         PHY_SCRATCH_phy[31:24] <= din[31:24];
      end
end

/* Definitions of REGISTER "PHY_NAME_0" */

// PHY_NAME_0_phy
// customType  RO
// hwAccess: NA 
// reset value : 0x00313030 
// NO register generated


/* Definitions of REGISTER "PHY_NAME_1" */

// PHY_NAME_1_phy
// customType  RO
// hwAccess: NA 
// reset value : 0x00004745 
// NO register generated


/* Definitions of REGISTER "PHY_NAME_2" */

// PHY_NAME_2_phy
// customType  RO
// hwAccess: NA 
// reset value : 0x00706373 
// NO register generated


/* Definitions of REGISTER "PHY_CONFIG" */

// PHY_CONFIG_eio_sys_rst
// bitfield description: PHY configuration registers.Bit [0] : eio_sys_rst
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      PHY_CONFIG_eio_sys_rst <= 1'h0;
   end
   else begin
      if (we_PHY_CONFIG) begin 
         PHY_CONFIG_eio_sys_rst   <=  din[0];  //
      end
end

always @( posedge clk)
   if (!reset_n)  begin
      PHY_RSFEC_enable_rsfec <= 1'h1;
   end
   else begin
      if (we_PHY_RSFEC) begin 
         PHY_RSFEC_enable_rsfec   <=  din[0];  //
      end
end
// PHY_CONFIG_soft_txp_rst
// bitfield description: PHY configuration registers.Bit [1] : soft_tx_rst : TX soft reset.
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      PHY_CONFIG_soft_txp_rst <= 1'h0;
   end
   else begin
      if (we_PHY_CONFIG) begin 
         PHY_CONFIG_soft_txp_rst   <=  din[1];  //
      end
end

// PHY_CONFIG_soft_rxp_rst
// bitfield description: PHY configuration registers.Bit [2] : soft_rxp_rst : RX soft reset.
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      PHY_CONFIG_soft_rxp_rst <= 1'h0;
   end
   else begin
      if (we_PHY_CONFIG) begin 
         PHY_CONFIG_soft_rxp_rst   <=  din[2];  //
      end
end

// PHY_CONFIG_set_ref_lock
// bitfield description: PHY configuration registers.Bit [4] : set_ref_lock.
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      PHY_CONFIG_set_ref_lock <= 1'h0;
   end
   else begin
      if (we_PHY_CONFIG) begin 
         PHY_CONFIG_set_ref_lock   <=  din[4];  //
      end
end

// PHY_CONFIG_set_data_lock
// bitfield description: PHY configuration registers.Bit [5] : set_data_lock : Directs the RX CDR PLL to lock data.
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      PHY_CONFIG_set_data_lock <= 1'h0;
   end
   else begin
      if (we_PHY_CONFIG) begin 
         PHY_CONFIG_set_data_lock   <=  din[5];  //
      end
end

/* Definitions of REGISTER "WORD_LOCK" */

// WORD_LOCK_phy
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


/* Definitions of REGISTER "PHY_PMA_SLOOP" */

// PHY_PMA_SLOOP_phy
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      PHY_PMA_SLOOP_phy <= 4'h0;
   end
   else begin
      if (we_PHY_PMA_SLOOP) begin 
         PHY_PMA_SLOOP_phy[3:0]   <=  din[3:0];  //
      end
end

/* Definitions of REGISTER "PHY_PCS_INDIRECT_ADDR" */

// PHY_PCS_INDIRECT_ADDR_phy
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      PHY_PCS_INDIRECT_ADDR_phy <= 3'h0;
   end
   else begin
      if (we_PHY_PCS_INDIRECT_ADDR) begin 
         PHY_PCS_INDIRECT_ADDR_phy[2:0]   <=  din[2:0];  //
      end
end

/* Definitions of REGISTER "PHY_PCS_INDIRECT_DATA" */

// PHY_PCS_INDIRECT_DATA_phy
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


/* Definitions of REGISTER "PHY_EIOFREQ_LOCK" */

// PHY_EIOFREQ_LOCK_phy
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


/* Definitions of REGISTER "PHY_TX_COREPLL_LOCKED" */

// PHY_TX_COREPLL_LOCKED_txa_online
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


// PHY_TX_COREPLL_LOCKED_txp_clk_stable
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


// PHY_TX_COREPLL_LOCKED_rxp_clk_stable
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


/* Definitions of REGISTER "PHY_FRAME_ERROR" */

// PHY_FRAME_ERROR_phy
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


/* Definitions of REGISTER "PHY_SCLR_FRAME_ERROR" */

// PHY_SCLR_FRAME_ERROR_phy
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      PHY_SCLR_FRAME_ERROR_phy <= 1'h0;
   end
   else begin
      if (we_PHY_SCLR_FRAME_ERROR) begin 
         PHY_SCLR_FRAME_ERROR_phy   <=  din[0];  //
      end
end

/* Definitions of REGISTER "PHY_EIO_SFTRESET" */

// PHY_EIO_SFTRESET_phy
// customType  RW
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      PHY_EIO_SFTRESET_phy <= 1'h0;
   end
   else begin
      if (we_PHY_EIO_SFTRESET[0]) begin 
         PHY_EIO_SFTRESET_phy   <=  din[0];  //
      end
end


/* Definitions of REGISTER "PHY_RXPCS_STATUS" */

// PHY_RXPCS_STATUS_fully_aligned
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


// PHY_RXPCS_STATUS_hi_ber
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


/* Definitions of REGISTER "ERR_INJ" */

// ERR_INJ_phy
// customType  WO
// hwAccess: RO 
// reset value : 0x0 

always @( posedge clk)
   if (!reset_n)  begin
      ERR_INJ_phy <= 4'h0;
   end
   else begin
      if (we_ERR_INJ) begin 
         ERR_INJ_phy[3:0]   <=  din[3:0];  //
      end
end

/* Definitions of REGISTER "AM_LOCK" */

// AM_LOCK_phy
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


/* Definitions of REGISTER "LANE_DESKEWED" */

// LANE_DESKEWED_locked
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


// LANE_DESKEWED_sticky_bit
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


/* Definitions of REGISTER "PCS_VLANE" */

// PCS_VLANE_vlane0
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


// PCS_VLANE_vlane1
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


// PCS_VLANE_vlane2
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


// PCS_VLANE_vlane3
// customType  RO
// hwAccess: WO 
// reset value : 0x0 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


/* Definitions of REGISTER "PHY_RX" */

// PHY_RX_delay
// customType  WO
// hwAccess: RO 
// reset value : 0x00 

always @( posedge clk)
   if (!reset_n)  begin
      PHY_RX_delay <= 6'h00;
   end
   else begin
      if (we_PHY_RX) begin 
         PHY_RX_delay[5:0]   <=  din[5:0];  //
      end
end

/* Definitions of REGISTER "PHY_REFCLK_KHZ" */

// PHY_REFCLK_KHZ_phy
// customType  RO
// hwAccess: WO 
// reset value : 0x00000000 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


/* Definitions of REGISTER "PHY_RXCLK_KHZ" */

// PHY_RXCLK_KHZ_phy
// customType  RO
// hwAccess: WO 
// reset value : 0x00000000 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated


/* Definitions of REGISTER "PHY_TXCLK_KHZ" */

// PHY_TXCLK_KHZ_phy
// customType  RO
// hwAccess: WO 
// reset value : 0x00000000 
// inputPort: "EMPTY" 
// outputPort:  "" 
// NO register generated





// read process
always @ (*)
begin
rdata_comb = 32'h0;
   if(re) begin
      case (addr)  
	7'h00 : begin
		rdata_comb [31:0]	= 32'h08092017 ;  // PHY_REVID_phy 	is reserved or a constant value, a read access gives the reset value
	end
	7'h01 : begin
		rdata_comb [31:0]	= PHY_SCRATCH_phy [31:0] ;		// readType = read   writeType =write
	end
	7'h02 : begin
		rdata_comb [31:0]	= 32'h00313030 ;  // PHY_NAME_0_phy 	is reserved or a constant value, a read access gives the reset value
	end
	7'h03 : begin
		rdata_comb [31:0]	= 32'h00004745 ;  // PHY_NAME_1_phy 	is reserved or a constant value, a read access gives the reset value
	end
	7'h04 : begin
		rdata_comb [31:0]	= 32'h00706373 ;  // PHY_NAME_2_phy 	is reserved or a constant value, a read access gives the reset value
	end
	7'h10 : begin
		rdata_comb [0]	= PHY_CONFIG_eio_sys_rst  ;		// readType = read   writeType =write
		rdata_comb [1]	= PHY_CONFIG_soft_txp_rst  ;		// readType = read   writeType =write
		rdata_comb [2]	= PHY_CONFIG_soft_rxp_rst  ;		// readType = read   writeType =write
		rdata_comb [4]	= PHY_CONFIG_set_ref_lock  ;		// readType = read   writeType =write
		rdata_comb [5]	= PHY_CONFIG_set_data_lock  ;		// readType = read   writeType =write
                	end
	7'h12 : begin
		rdata_comb [19:0]	= WORD_LOCK_phy_i [19:0] ;		// readType = read   writeType =illegal
	end
	7'h13 : begin
		rdata_comb [3:0]	= PHY_PMA_SLOOP_phy [3:0] ;		// readType = read   writeType =write
	end
	7'h14 : begin
		rdata_comb [2:0]	= PHY_PCS_INDIRECT_ADDR_phy [2:0] ;		// readType = read   writeType =write
	end
	7'h15 : begin
		rdata_comb [3:0]	= PHY_PCS_INDIRECT_DATA_phy_i [3:0] ;		// readType = read   writeType =illegal
	end
	7'h21 : begin
		rdata_comb [3:0]	= PHY_EIOFREQ_LOCK_phy_i [3:0] ;		// readType = read   writeType =illegal
	end
	7'h22 : begin
		rdata_comb [0]	= PHY_TX_COREPLL_LOCKED_txa_online_i  ;		// readType = read   writeType =illegal
		rdata_comb [1]	= PHY_TX_COREPLL_LOCKED_txp_clk_stable_i  ;		// readType = read   writeType =illegal
		rdata_comb [2]	= PHY_TX_COREPLL_LOCKED_rxp_clk_stable_i  ;		// readType = read   writeType =illegal
	end
	7'h23 : begin
		rdata_comb [19:0]	= PHY_FRAME_ERROR_phy_i [19:0] ;		// readType = read   writeType =illegal
	end
	7'h24 : begin
		rdata_comb [0]	= PHY_SCLR_FRAME_ERROR_phy  ;		// readType = read   writeType =write
	end
	7'h25 : begin
		rdata_comb [0]	= PHY_EIO_SFTRESET_phy  ;		// readType = read   writeType =write
	end
	7'h26 : begin
		rdata_comb [0]	= PHY_RXPCS_STATUS_fully_aligned_i  ;		// readType = read   writeType =illegal
		rdata_comb [1]	= PHY_RXPCS_STATUS_hi_ber_i  ;		// readType = read   writeType =illegal
	end
    7'h27 : begin
        rdata_comb [3:0]    = ERR_INJ_phy [3:0] ;     // readType = read   writeType =write
    end

	7'h28 : begin
		rdata_comb [0:0]	= AM_LOCK_phy_i [0:0] ;		// readType = read   writeType =illegal
	end
	7'h29 : begin
		rdata_comb [0]	= LANE_DESKEWED_locked_i  ;		// readType = read   writeType =illegal
		rdata_comb [1]	= LANE_DESKEWED_sticky_bit_i  ;		// readType = read   writeType =illegal
	end
	7'h30 : begin
		rdata_comb [24:0]	= PCS_VLANE_vlane0_i [24:0] ;		// readType = read   writeType =illegal
	end
    7'h31 : begin
        rdata_comb [24:0]    = PCS_VLANE_vlane1_i [24:0] ;        // readType = read   writeType =illegal
    end
    7'h32 : begin
        rdata_comb [24:0]    = PCS_VLANE_vlane2_i [24:0] ;        // readType = read   writeType =illegal
    end
    7'h33 : begin
        rdata_comb [24:0]    = PCS_VLANE_vlane3_i [24:0] ;        // readType = read   writeType =illegal
    end

	7'h40 : begin
		rdata_comb [31:0]	= PHY_REFCLK_KHZ_phy_i [31:0] ;		// readType = read   writeType =illegal
	end
	7'h41 : begin
		rdata_comb [31:0]	= PHY_RXCLK_KHZ_phy_i [31:0] ;		// readType = read   writeType =illegal
	end
	7'h42 : begin
		rdata_comb [31:0]	= PHY_TXCLK_KHZ_phy_i [31:0] ;		// readType = read   writeType =illegal
	end

        7'h43 : begin
                rdata_comb [31:0]       = PHY_CLK_TX_RS_phy_i [31:0] ;          // readType = read   writeType =illegal
        end
        7'h44 : begin
                rdata_comb [31:0]       = PHY_CLK_RX_RS_phy_i [31:0] ;          // readType = read   writeType =illegal
        end
        7'h50 : begin
                rdata_comb [0]       = PHY_RSFEC_enable_rsfec ;          // readType = read   writeType =illegal
        end

	default : begin
		rdata_comb = 32'hdeadc0de;
	end
      endcase
   end
end

endmodule

