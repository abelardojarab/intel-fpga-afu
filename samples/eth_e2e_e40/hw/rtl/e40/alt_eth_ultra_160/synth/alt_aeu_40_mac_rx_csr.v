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


//-----------------------------------------------------------------------------
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/mac/alt_aeu_40_mac_rx_csr.v#2 $
// $Revision: #2 $
// $Date: 2016/10/21 $
// $Author: ktaylor $
// File          : rx_csr.v
//-----------------------------------------------------------------------------
// Copyright 2011 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera

// turn off bogus verilog processor warnings
// altera message_off 10034 10035 10036 10037 10230
// ajay dubey 06.2013

module alt_aeu_40_mac_rx_csr 
       #(parameter ADDRSIZE=8 
        ,parameter BASE=0
        ,parameter REVID = 32'h04012014
        ,parameter TARGET_CHIP= 2
        )(
         input wire reset_csr 
        ,input wire clk_csr 
        ,input wire clk_rx 
        ,input wire reset_rx 

        ,input wire serif_master_din 
        ,output wire serif_slave_dout 

        ,input  wire remote_fault_status 
        ,input  wire local_fault_status
 
        ,output wire cfg_enable_txoff 
        ,output wire cfg_fwd_pframes 
        ,output wire cfg_pld_length_chk
        ,output wire cfg_pld_length_include_vlan
        ,output wire cfg_cntena_oversize_error 
        ,output wire cfg_cntena_undersize_error 
        ,output wire cfg_cntena_pldlength_error 
        ,output wire cfg_cntena_fcs_error 
        ,output wire cfg_cntena_phylink_error // any downstream error
        ,output wire[47:0] cfg_dst_address 
        ,output wire[15:0] cfg_max_fsize
        ,output wire cfg_keep_rx_crc 
        );

 //
 // ___________________________________________________________
        localparam 
                  ADDR_REVID    = 8'h00 ,
                  ADDR_SCRATCH  = 8'h01 ,
                  ADDR_NAME_0   = 8'h02 ,
                  ADDR_NAME_1   = 8'h03 ,
                  ADDR_NAME_2   = 8'h04 ,

                  ADDR_RXMAC_TFLCFG = 8'h05,    // type based filter config
                  ADDR_RXMAC_SZECFG = 8'h06,    // max rx frame size config
                  ADDR_RXMAC_CRCCFG = 8'h07,    // Rx CRC config (passthru)
                  ADDR_RXMAC_LNKFLT = 8'h08,    // receive link fault status 
                  ADDR_RXMAC_AFLCFG = 8'h09,    // address based filter config
                  ADDR_RXMAC_PLECFG = 8'h0a,    // payload length check configuration
                  ADDR_RXMAC_ERRCFG = 8'hf0     // mode settings configurations
                 ;
 // ___________________________________________________________
 //


// note - i'm skeptical reset_csr is properly hardened in the design above here
//  redoing the synchronization here to be safe
wire init_regs;
sync_regs_m2 ss0 (
	.clk(clk_csr),
	.din(reset_csr),
	.dout(init_regs)
);
defparam ss0 .WIDTH = 1;

 wire read;
 wire write;
 wire [31:0]writedata;
 wire [ADDRSIZE-1:0]address;
 reg readdatavalid;
 reg [31:0]readdata;
/*
 serif_slave_async #(
         .ADDR_PAGE      (BASE)
        ,.TARGET_CHIP    (TARGET_CHIP)
 )sifsa_rxcsr (
         .aclr          (reset_csr)
        ,.sclk          (clk_csr)
        ,.din           (serif_master_din)
        ,.dout          (serif_slave_dout)

        ,.bclk          (clk_rx)
        ,.wr            (write)
        ,.rd            (read)
        ,.addr          (address)
        ,.wdata         (writedata)
        ,.rdata         (readdata)
        ,.rdata_valid   (readdatavalid)
        );
*/

 serif_slave #( // for now just from hsl12
         .ADDR_PAGE      (BASE)
        ,.TARGET_CHIP    (TARGET_CHIP)
 )sifsa_rxcsr (
    .clk(clk_csr),
    .sclr(init_regs),
    .din(serif_master_din),
    .dout(serif_slave_dout),

    .wr(write),
    .rd(read),
    .addr(address),
    .wdata(writedata),
    .rdata(readdata),
    .rdata_valid(readdatavalid)
);

 // _________________________________________________________________________
 //     config registers 
 // _________________________________________________________________________
   reg[31:0]  scratch = 32'd0;  
   wire [12*8-1:0] ip_name = " 40gMACRxCSR";

   reg        fwd_pframes_csr                   = 1'b0; 
   reg        pld_length_chk_csr                = 1'b1;
   reg        pld_length_include_vlan_csr       = 1'b0; 
   reg        keep_rx_crc_csr                   = 1'b0; 
   reg[15:0]  max_fsize_csr                     = 16'd9600;  
   reg [4:0]  err_cfg_csr                       = 5'b11111;
   reg        enable_txoff                      = 1'b1; 
   reg [47:0] dst_address                       = 48'h0180C2000001;  

   wire       fwd_pframes;
   wire       pld_length_chk;
   wire       pld_length_include_vlan;
   wire       keep_rx_crc;
   wire[15:0] max_fsize;
   wire [4:0] err_cfg;

   assign cfg_enable_txoff              = enable_txoff;
   assign cfg_fwd_pframes               = fwd_pframes;
   assign cfg_pld_length_chk            = pld_length_chk;
   assign cfg_pld_length_include_vlan   = pld_length_include_vlan;
   assign cfg_keep_rx_crc               = keep_rx_crc;
   assign cfg_max_fsize                 = max_fsize;
   assign cfg_dst_address               = dst_address;
   assign {cfg_cntena_pldlength_error, cfg_cntena_oversize_error, cfg_cntena_undersize_error, cfg_cntena_fcs_error, cfg_cntena_phylink_error} = err_cfg;

 // _________________________________________________________________________
 //     registers writing
 // _________________________________________________________________________


always @ (posedge clk_csr) begin 

	if (init_regs) begin
		max_fsize_csr <= 16'd9600;  
		fwd_pframes_csr <= 1'b0; 
		keep_rx_crc_csr <= 1'b0; 
		err_cfg_csr <= 5'b11111;
		pld_length_chk_csr <= 1'b1;
		pld_length_include_vlan_csr <= 1'b0; 
		enable_txoff <= 1'b1; 
		
		// is this supposed to be written?
		dst_address <=48'h0180C2000001;  
	end 
	else if (write) begin
             case(address) 
                  ADDR_SCRATCH          : scratch                                               <= writedata[31:0]; 
                  ADDR_RXMAC_SZECFG     : max_fsize_csr[15:0]                                   <= writedata[15:0]; 
                  ADDR_RXMAC_TFLCFG     : fwd_pframes_csr                                       <= writedata[0]; 
                  ADDR_RXMAC_CRCCFG     : keep_rx_crc_csr                                       <= writedata[0]; 
                  ADDR_RXMAC_ERRCFG     : err_cfg_csr[4:0]                                      <= writedata[4:0];
                  ADDR_RXMAC_PLECFG     : {pld_length_include_vlan_csr,pld_length_chk_csr}      <= writedata[1:0];
                  default               : enable_txoff                                          <= enable_txoff; 
             endcase
        end
end

sync_regs sr1 (
        .clk (clk_rx),
        .din ({max_fsize_csr[15:0], fwd_pframes_csr, keep_rx_crc_csr, err_cfg_csr[4:0], pld_length_chk_csr, pld_length_include_vlan_csr}),
        .dout({max_fsize[15:0],     fwd_pframes,     keep_rx_crc,     err_cfg[4:0],     pld_length_chk    , pld_length_include_vlan})
);
defparam sr1 .WIDTH = 16 + 1 + 1 + 5 + 1 + 1;

wire local_fault_status_csr;
wire remote_fault_status_csr;

sync_regs sr2 (
        .clk (clk_csr),
        .din ({remote_fault_status,     local_fault_status}),
        .dout({remote_fault_status_csr, local_fault_status_csr})
);
defparam sr2 .WIDTH = 2;

// _____________________________________________________________________
//  readdata logic
// _____________________________________________________________________
   always @ (posedge clk_csr) readdatavalid <= read; 
   always @ (posedge clk_csr) 
      begin 
        if (read)
            begin
                case(address)
                    ADDR_SCRATCH     : readdata <= scratch;
                    ADDR_REVID       : readdata <= REVID;
                    ADDR_NAME_0      : readdata <= ip_name[95:64];
                    ADDR_NAME_1      : readdata <= ip_name[63:32] ;
                    ADDR_NAME_2      : readdata <= ip_name[31: 0];
                    ADDR_RXMAC_SZECFG: readdata <= {16'd0,max_fsize_csr};
                    ADDR_RXMAC_TFLCFG: readdata <= {31'd0,fwd_pframes_csr};
                    ADDR_RXMAC_CRCCFG: readdata <= {31'd0,keep_rx_crc_csr};
                    ADDR_RXMAC_LNKFLT: readdata <= {30'd0,remote_fault_status_csr, local_fault_status_csr};
                    ADDR_RXMAC_ERRCFG: readdata <= {27'd0,err_cfg_csr};
                    ADDR_RXMAC_PLECFG: readdata <= {30'd0,pld_length_include_vlan_csr, pld_length_chk_csr};
                   default           : readdata <= 32'hdeadc0de;
                endcase
            end
      end

 // _____________________________________________________________________________
  endmodule



