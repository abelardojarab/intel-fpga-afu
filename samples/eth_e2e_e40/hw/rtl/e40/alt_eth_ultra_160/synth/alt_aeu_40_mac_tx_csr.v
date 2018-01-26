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


 // _________________________________________________________________________________________
 // $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/mac/alt_aeu_40_mac_tx_csr.v#2 $
 // $Revision: #2 $
 // $Date: 2016/10/21 $
 // $Author: ktaylor $
 // _________________________________________________________________________________________
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
 // Ajay Dubey Aug 2013
 // _________________________________________________________________________________________
 // turn off bogus verilog processor warnings
 // altera message_off 10034 10035 10036 10037 10230
 // _________________________________________________________________________________________

 module alt_aeu_40_mac_tx_csr #(
		parameter ADDRSIZE=8, 
        parameter BASE=0,
        parameter REVID = 32'h04012014,
        parameter TARGET_CHIP= 2,
        parameter FCBITS= 1
        )(
        input wire reset_csr, 
        input wire clk_csr, 
        input wire clk_tx ,
        input wire reset_tx, 

        input wire serif_master_din ,
        output wire serif_slave_dout, 

        output wire[15:0] cfg_max_fsize,
        output wire cfg_link_fault_gen_en ,
        output wire cfg_link_fault_unidir_en ,
        output wire[7:0] cfg_ipg_col_rem ,
        output wire cfg_tx_crc_ins_en_4debug,
        output wire cfg_pld_length_chk,
        output wire cfg_pld_length_include_vlan  ,
        output wire cfg_cntena_oversize_error ,
        output wire cfg_cntena_undersize_error ,
        output wire cfg_cntena_pldlength_error ,
        output wire cfg_cntena_fcs_error ,
        output wire cfg_cntena_phylink_error // any downstream error
);

// note - i'm skeptical reset_csr is properly hardened in the design above here
//  redoing the synchronization here to be safe
wire init_regs;
sync_regs_m2 ss0 (
	.clk(clk_csr),
	.din(reset_csr),
	.dout(init_regs)	
);
defparam ss0 .WIDTH = 1;

 // ___________________________________________________________
 //     local parameters
 // ___________________________________________________________
        localparam 
                 ADDR_REVID             = 8'h00 ,
                 ADDR_SCRATCH           = 8'h01 ,
                 ADDR_NAME_0            = 8'h02 ,
                 ADDR_NAME_1            = 8'h03 ,
                 ADDR_NAME_2            = 8'h04 ,

                 ADDR_CFG_LINK_FAULT    = 8'h05 ,
                 ADDR_CFG_IPGCOL_REM    = 8'h06 ,
                 ADDR_CFG_FRMSIZE       = 8'h07 ,
                 ADDR_TXMAC_CRCCFG      = 8'h08 ,
                 ADDR_TXMAC_ADDRCFG     = 8'h09 ,// address based filter config
                 ADDR_TXMAC_PLECFG      = 8'h0a, // payload length check configuration
                 ADDR_TXMAC_ERRCFG      = 8'hf0  // mode settings configurations
                 ;
// ____________________________________________________________
 //
 wire read;
 wire write;
 wire [31:0]writedata;
 wire [ADDRSIZE-1:0]address;
 reg readdatavalid;
 reg [31:0]readdata;
/*
 serif_slave_async #(   // for now just from hsl12
         .ADDR_PAGE      (BASE)
        ,.TARGET_CHIP    (TARGET_CHIP)
 )sifsa_txcsr (
         .aclr          (reset_csr)
        ,.sclk          (clk_csr)
        ,.din           (serif_master_din)
        ,.dout          (serif_slave_dout)

        ,.bclk          (clk_tx)
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
 )sifsa_txcsr (
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
   wire [12*8-1:0] ip_name = " 40gMACTxCSR";

   reg [7:0] ipg_col_rem_csr            = 8'd4; 
   reg [1:0] cfg_link_fault_csr                 = 2'b01; 
   reg[15:0] max_fsize_csr                      = 16'd9600;
   reg       tx_crc_ins_en_4debug_csr           = 1'b1; 
   reg       pld_length_chk_csr                 = 1'b1; 
   reg       pld_length_include_vlan_csr        = 1'b0; 
   reg [4:0] err_cfg_csr                        = 5'b11111;

   wire [7:0] ipg_col_rem;
   wire [1:0] cfg_link_fault;
   wire[15:0] max_fsize;
   wire       tx_crc_ins_en_4debug;
   wire       pld_length_chk;
   wire       pld_length_include_vlan;
   wire [4:0] err_cfg;

   assign cfg_ipg_col_rem = ipg_col_rem; 
   assign {cfg_link_fault_unidir_en, cfg_link_fault_gen_en} = cfg_link_fault;
   assign cfg_max_fsize = max_fsize;
   assign cfg_tx_crc_ins_en_4debug = tx_crc_ins_en_4debug;
   assign cfg_pld_length_chk = pld_length_chk;
   assign cfg_pld_length_include_vlan = pld_length_include_vlan;
   assign {cfg_cntena_pldlength_error, cfg_cntena_oversize_error, cfg_cntena_undersize_error, cfg_cntena_fcs_error, cfg_cntena_phylink_error} = err_cfg;

 // _________________________________________________________________________
 // registers writing
 // _________________________________________________________________________
 

always @ (posedge clk_csr) begin 
	if (init_regs) begin

		ipg_col_rem_csr                    <= 8'd4; 
		cfg_link_fault_csr                 <= 2'b01; 
		max_fsize_csr                      <= 16'd9600;
		tx_crc_ins_en_4debug_csr           <= 1'b1; 
		pld_length_chk_csr                 <= 1'b1; 
		pld_length_include_vlan_csr        <= 1'b0; 
		err_cfg_csr                        <= 5'b11111;
	
	end
	else if (write) begin
             case(address) 
			ADDR_SCRATCH          : scratch <= writedata[31:0]; 
                  ADDR_CFG_FRMSIZE      : max_fsize_csr[15:0]                                   <= writedata[15:0]; 
                  ADDR_CFG_LINK_FAULT   : cfg_link_fault_csr                                    <= writedata[1:0]; 
                  ADDR_CFG_IPGCOL_REM   : ipg_col_rem_csr                                       <= writedata[7:0]; 
                  ADDR_TXMAC_CRCCFG     : tx_crc_ins_en_4debug_csr                              <= writedata[0]; 
                  ADDR_TXMAC_PLECFG     : {pld_length_include_vlan_csr,pld_length_chk_csr}      <= writedata[1:0];
                  ADDR_TXMAC_ERRCFG     : err_cfg_csr                                           <= writedata[4:0];
             endcase
        end
end

sync_regs sr1 (
        .clk (clk_tx),
        .din({max_fsize_csr[15:0], cfg_link_fault_csr[1:0], ipg_col_rem_csr[7:0], tx_crc_ins_en_4debug_csr, pld_length_chk_csr, err_cfg_csr[4:0], pld_length_include_vlan_csr}),
        .dout({max_fsize[15:0],    cfg_link_fault[1:0],     ipg_col_rem[7:0],     tx_crc_ins_en_4debug,     pld_length_chk,     err_cfg[4:0],     pld_length_include_vlan})
);
defparam sr1 .WIDTH = 16 + 2 + 8 + 1 + 1 + 5 + 1;

// _____________________________________________________________________
//  readdata logic
// _____________________________________________________________________
   always @ (posedge clk_csr) readdatavalid <= read; 
   
   always @ (posedge clk_csr) 
      begin 
        if (read)
            begin
                case(address)
                   ADDR_SCRATCH          : readdata <= scratch;
                   ADDR_REVID            : readdata <= REVID;
                   ADDR_NAME_0           : readdata <= ip_name[95:64];
                   ADDR_NAME_1           : readdata <= ip_name[63:32] ;
                   ADDR_NAME_2           : readdata <= ip_name[31: 0];
                   ADDR_CFG_LINK_FAULT   : readdata <= {30'd0,cfg_link_fault_csr};
                   ADDR_CFG_IPGCOL_REM   : readdata <= {24'd0,ipg_col_rem_csr};
                   ADDR_TXMAC_CRCCFG     : readdata <= {31'd0,tx_crc_ins_en_4debug_csr};
                   ADDR_CFG_FRMSIZE      : readdata <= {16'd0,max_fsize_csr};
                   ADDR_TXMAC_PLECFG     : readdata <= {30'd0,pld_length_include_vlan_csr, pld_length_chk_csr};
                   ADDR_TXMAC_ERRCFG     : readdata <= {27'd0,err_cfg_csr};
                   default               : readdata <= 32'hdeadc0de;
                endcase
            end
      end

 // _____________________________________________________________________________
  endmodule



