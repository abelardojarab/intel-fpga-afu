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

module alt_e100s10_mac_rx_csr 
       #(parameter ADDRSIZE=8 
        ,parameter BASE=0
        ,parameter REVID = 32'h08092017
        ,parameter TARGET_CHIP= 2
        )(
         input wire reset_csr 
        ,input wire clk_csr 
        ,input wire clk_rx 
        ,input wire reset_rx 

        ,input  wire write
        ,input  wire read
        ,input  wire[ADDRSIZE-1:0] address
        ,input  wire[31:0] writedata
        ,output reg [31:0] readdata
        ,output reg  readdatavalid

        ,input  wire remote_fault_status 
        ,input  wire local_fault_status
 
        ,output wire cfg_pld_length_include_vlan
        ,output wire[15:0] cfg_max_fsize
        ,output wire cfg_keep_rx_crc
        ,output wire cfg_pld_length_sfd_det_on           //UNH
        ,output wire cfg_pld_length_premable_det_on      //UNH
        );

 //
 // ___________________________________________________________
        localparam 
                  ADDR_REVID    = {8'h00} ,
                  ADDR_SCRATCH  = {8'h01} ,
                  ADDR_NAME_0   = {8'h02} ,
                  ADDR_NAME_1   = {8'h03} ,
                  ADDR_NAME_2   = {8'h04} ,

                  ADDR_RXMAC_SZECFG ={8'h06},    // max rx frame size config
                  ADDR_RXMAC_CRCCFG ={8'h07},    // Rx CRC config (passthru)
                  ADDR_RXMAC_LNKFLT ={8'h08},    // receive link fault status 
                  ADDR_RXMAC_AFLCFG ={8'h09},    // address based filter config
                  ADDR_RXMAC_PLECFG ={8'h0a}     // payload length check configuration
                 ;
 // _________________________________________________________________________
 //     config registers 
 // _________________________________________________________________________
   reg[31:0]  scratch;  
   wire [12*8-1:0] ip_name = "100gMACRxCSR";

     reg        pld_length_include_vlan_csr;
  
   reg        keep_rx_crc_csr; 
   reg[15:0]  max_fsize_csr;  
   reg        pld_length_sfd_det_on_csr;//0xa [4]
   reg        pld_length_premable_det_on_csr;//0xa [5]
   
   wire       pld_length_include_vlan;
   wire       pld_length_sfd_det_on     ;//0xa [4]
   wire       pld_length_premable_det_on;//0xa [5]
  
   wire       keep_rx_crc;
   wire[15:0] max_fsize;

   assign cfg_pld_length_include_vlan = pld_length_include_vlan;
   assign cfg_pld_length_sfd_det_on       = pld_length_sfd_det_on      ; //UNH
   assign cfg_pld_length_premable_det_on  = pld_length_premable_det_on ; //UNH
   assign cfg_keep_rx_crc    = keep_rx_crc;
   assign cfg_max_fsize      = max_fsize;
 // _________________________________________________________________________
 //     registers writing
 // _________________________________________________________________________
   always @ (posedge clk_csr) 
        begin 
           if (reset_csr) begin
                scratch <= 32'h0;
                max_fsize_csr[15:0] <= 16'd9600;
                keep_rx_crc_csr <= 1'b0;
                {pld_length_premable_det_on_csr, pld_length_sfd_det_on_csr, pld_length_include_vlan_csr} <= 3'b110;
            end 
            else if (write) 
             case(address) 
                  ADDR_SCRATCH          : scratch             <= writedata[31:0]; 
                  ADDR_RXMAC_SZECFG     : max_fsize_csr[15:0] <= writedata[15:0]; 
                  ADDR_RXMAC_CRCCFG     : keep_rx_crc_csr     <= writedata[0]; 
                  ADDR_RXMAC_PLECFG     : {pld_length_premable_det_on_csr, pld_length_sfd_det_on_csr, pld_length_include_vlan_csr}     <= {writedata[4:3], writedata[1]};
             endcase
        end

alt_e100s10_synchronizer sr1 (
        .clk (clk_rx),
        .din ({max_fsize_csr[15:0], keep_rx_crc_csr, pld_length_include_vlan_csr,  pld_length_premable_det_on_csr, pld_length_sfd_det_on_csr}),
        .dout({max_fsize[15:0],     keep_rx_crc,     pld_length_include_vlan    ,  pld_length_premable_det_on,     pld_length_sfd_det_on})
);
defparam sr1 .WIDTH = 16 + 1 + 1  + 2;

wire remote_fault_status_csr, local_fault_status_csr;
alt_e100s10_synchronizer sr2 (
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
                    ADDR_RXMAC_CRCCFG: readdata <= {31'd0,keep_rx_crc_csr};
                    ADDR_RXMAC_LNKFLT: readdata <= {30'd0,remote_fault_status_csr, local_fault_status_csr};
                    ADDR_RXMAC_PLECFG: readdata <= {27'd0, pld_length_premable_det_on_csr, pld_length_sfd_det_on_csr, 1'b0, pld_length_include_vlan_csr, 1'b0};
                   default           : readdata <= 32'hdeadc0de;
                endcase
            end
      end

 // _____________________________________________________________________________
  endmodule



