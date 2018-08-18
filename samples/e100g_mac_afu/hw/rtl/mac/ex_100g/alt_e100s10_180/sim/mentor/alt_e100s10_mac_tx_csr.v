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

module alt_e100s10_mac_tx_csr 
       #(parameter ADDRSIZE=8 
        ,parameter BASE=0
        ,parameter REVID = 32'h08092017
        ,parameter TARGET_CHIP= 2
        ,parameter FCBITS= 1
        )(
         input wire reset_csr 
        ,input wire clk_csr 
        ,input wire clk_tx 
        ,input wire reset_tx 

        ,input  wire write
        ,input  wire read
        ,input  wire[ADDRSIZE-1:0] address
        ,input  wire[31:0] writedata
        ,output reg [31:0] readdata
        ,output reg  readdatavalid

        ,output wire[15:0] cfg_max_fsize
        ,output wire cfg_link_fault_gen_en 
        ,output wire cfg_link_fault_unidir_en 
        ,output wire cfg_link_fault_unidir_en_disable_rf
        ,output wire cfg_link_fault_force_rf              
        ,output wire[7:0] cfg_ipg_col_rem 
        ,output wire cfg_tx_crc_ins_en_4debug
        ,output wire cfg_pld_length_include_vlan
        );

 // ___________________________________________________________
 //     local parameters
 // ___________________________________________________________
        localparam 
                 ADDR_REVID             = {8'h00},
                 ADDR_SCRATCH           = {8'h01},
                 ADDR_NAME_0            = {8'h02},
                 ADDR_NAME_1            = {8'h03},
                 ADDR_NAME_2            = {8'h04},

                 ADDR_CFG_LINK_FAULT    = {8'h05},
                 ADDR_CFG_IPGCOL_REM    = {8'h06},
                 ADDR_CFG_FRMSIZE       = {8'h07},
                 ADDR_TXMAC_CRCCFG      = {8'h08},
                 ADDR_TXMAC_ADDRCFG     = {8'h09},// address based filter config
                 ADDR_TXMAC_PLECFG      = {8'h0a},// payload length check configuration
                 ADDR_TXMAC_ERRCFG      = {8'hf0} // mode settings configurations
                 ;

 // _________________________________________________________________________
 //     config registers 
 // _________________________________________________________________________
   reg[31:0]  scratch;  
   wire [12*8-1:0] ip_name = "100gMACTxCSR";

   reg [7:0] ipg_col_rem_csr; 
   reg [3:0] cfg_link_fault_csr; 
   reg[15:0] max_fsize_csr;
   reg       tx_crc_ins_en_4debug_csr; 
   reg       pld_length_include_vlan_csr; 

   wire [7:0] ipg_col_rem;
   wire [3:0] cfg_link_fault;
   wire[15:0] max_fsize;
   wire       tx_crc_ins_en_4debug;
   wire       pld_length_include_vlan;

   assign cfg_ipg_col_rem = ipg_col_rem; 
   assign {cfg_link_fault_force_rf, cfg_link_fault_unidir_en_disable_rf, cfg_link_fault_unidir_en, cfg_link_fault_gen_en} = cfg_link_fault;  
   assign cfg_max_fsize = max_fsize;
   assign cfg_tx_crc_ins_en_4debug = tx_crc_ins_en_4debug;
   assign cfg_pld_length_include_vlan = pld_length_include_vlan;

 // _________________________________________________________________________
 // registers writing
 // _________________________________________________________________________
   always @ (posedge clk_csr) 
        begin 
            if (reset_csr) begin
                scratch <= 32'h0;
                max_fsize_csr[15:0] <= 16'd9600;
                cfg_link_fault_csr <= 4'b0001;
                ipg_col_rem_csr <= 8'd20;
                tx_crc_ins_en_4debug_csr <= 1'b0;
                pld_length_include_vlan_csr <= 1'b0;
            end
            else if (write) 
             case(address) 
                  ADDR_SCRATCH          : scratch                                               <= writedata[31:0]; // 8'h01  ,
                  ADDR_CFG_FRMSIZE      : max_fsize_csr[15:0]                                   <= writedata[15:0]; 
                  ADDR_CFG_LINK_FAULT   : cfg_link_fault_csr                                    <= writedata[3:0]; 
                  ADDR_CFG_IPGCOL_REM   : ipg_col_rem_csr                                       <= writedata[7:0]; 
                  ADDR_TXMAC_CRCCFG     : tx_crc_ins_en_4debug_csr                              <= writedata[0]; 
                  ADDR_TXMAC_PLECFG     : {pld_length_include_vlan_csr}                         <= writedata[1];
                  default               : cfg_link_fault_csr                                    <= cfg_link_fault_csr; 
             endcase
        end

alt_e100s10_synchronizer sr1 (
        .clk (clk_tx),
        .din({max_fsize_csr[15:0], cfg_link_fault_csr[3:0], ipg_col_rem_csr[7:0], tx_crc_ins_en_4debug_csr, pld_length_include_vlan_csr}),
        .dout({max_fsize[15:0],    cfg_link_fault[3:0],     ipg_col_rem[7:0],     tx_crc_ins_en_4debug,     pld_length_include_vlan})
);
defparam sr1 .WIDTH = 16 + 4 + 8  + 1 + 1;

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
                   ADDR_CFG_LINK_FAULT   : readdata <= {28'd0,cfg_link_fault_csr};
                   ADDR_CFG_IPGCOL_REM   : readdata <= {24'd0,ipg_col_rem_csr};
                   ADDR_TXMAC_CRCCFG     : readdata <= {31'd0,tx_crc_ins_en_4debug_csr};
                   ADDR_CFG_FRMSIZE      : readdata <= {16'd0,max_fsize_csr};
                   ADDR_TXMAC_PLECFG     : readdata <= {30'd0,pld_length_include_vlan_csr,1'b0};
                   default               : readdata <= 32'hdeadc0de;
                endcase
            end
      end

 // _____________________________________________________________________________
  endmodule



