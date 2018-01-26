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


// ____________________________________________________________________
//Copyright(C) 2013: Altera Corporation
// $Id: alt_aeu_40_sfc_tx.v,v 1.2 2015/01/23 22:37:14 marmstro Exp marmstro $
// $Revision: 1.2 $
// $Date: 2015/01/23 22:37:14 $
// $Author: marmstro $
// ____________________________________________________________________
// altera message_off 10030 10036 10236
// adubey 06.2013

  module alt_aeu_40_sfc_tx #(
         parameter CSRADDRSIZE = 8
        ,parameter REVID = 32'h02062015
        ,parameter TARGET_CHIP = 2 
        ,parameter BASE_TXFC = 1
        ,parameter SYNOPT_PREAMBLE_PASS = 1 
        ,parameter DBGWIDTH = 1
        ,parameter FCBITS = 1
        ,parameter WORDS = 8            // to create pause frame
        ,parameter DWIDTH = 512
        ,parameter EMPTYBITS = 6 
        ,parameter FSMPDEPTH = 2 
        ,parameter ODEPTH = 2 
        ,parameter PDEPTH = 2 
        )
        (
         input  wire clk_mm 
        ,input  wire reset_mm 
        ,input  wire smm_master_dout 
        ,output wire smm_slave_dout 

        ,input  wire reset_n 
        ,input  wire clk 
        ,output wire in_ready                   
        ,input wire in_valid            
        ,input wire in_error      
        ,input wire in_sop      
        ,input wire in_eop      
        ,input wire [DWIDTH-1:0] in_data 
        ,input wire [EMPTYBITS-1:0] in_empty
        
        ,input wire out_ready           
        ,output wire out_valid      
        ,output wire out_sop    
        ,output wire out_eop    
        ,output wire out_error  
        ,output wire [DWIDTH-1:0] out_data      
        ,output wire [EMPTYBITS-1:0] out_empty 
        
        ,input  wire rx_txoff_req               // ieee 802.3
        ,input  wire [FCBITS-1:0] in_pause_req

        ,input  wire [DBGWIDTH-1:0] in_debug    // un-used (for future DFV needs)
        ,output wire [DBGWIDTH-1:0] out_debug   // TBD: add definitions for this port
        );
 
 // __________________________________________________________________________
 // 
     wire[WORDS*64-1:0] out_pause_data;
     wire[EMPTYBITS-1:0] out_pause_empty;
     wire[FCBITS-1:0] txon_frame;
     wire[FCBITS-1:0] txoff_frame;

     wire idp_valid ;
     wire idp_sop ;
     wire idp_eop;
     wire idp_error ;
     wire [DWIDTH-1:0] idp_data;
     wire [EMPTYBITS-1:0] idp_empty ;
     wire codp_ready;

     wire out_debug_odp;
     assign out_debug = {out_debug_odp};

     wire pkt_end;

   //___________________________________________________________________________________________________________
     alt_aeu_40_sfc_tx_idp #(.DWIDTH(DWIDTH) ,.EMPTYBITS(EMPTYBITS) ,.PDEPTH(PDEPTH) ,.FSMPDEPTH(FSMPDEPTH) ,.ODEPTH(ODEPTH))
   //___________________________________________________________________________________________________________
     txidp (
         .clk                   (clk)
        ,.rst_n                 (reset_n)
                                                           
        ,.pkt_end               (pkt_end) 
                                                           
        ,.in_ready              (in_ready)              //TBD // input ready
        ,.in_valid              (in_valid)              // input val
        ,.in_sop                (in_sop)                // sop word
        ,.in_eop                (in_eop)                // sop word
        ,.in_error              (in_error)
        ,.in_data               (in_data)               // data 
        ,.in_empty              (in_empty)              // eop byte(one hot)
                                                           
        ,.out_ready             (codp_ready)            // stall input pipe
        ,.out_valid             (idp_valid)             // output val
        ,.out_sop               (idp_sop)               // sop word      
        ,.out_eop               (idp_eop)               // sop word      
        ,.out_error             (idp_error)
        ,.out_data              (idp_data)              // data
        ,.out_empty             (idp_empty)             // eop byte (one hot)
        ,.pipe_data             ()
     );

     wire cfg_enable_txoff;
     wire[FCBITS-1:0] cfg_enable_txins;
     wire[16*FCBITS-1:0] cfg_pause_quanta;
     wire[FCBITS-1:0] cfg_qholdoff_en;
     wire[16*FCBITS-1:0] cfg_qholdoff_quanta;
     wire[FCBITS-1:0] cfg_pause_req;

     wire ctrl_ready, odp_ready;
     assign codp_ready = ctrl_ready & odp_ready;
     wire sel_in_pkt;
     wire sel_store_pkt;
     wire sel_pause_pkt;
     wire out_pause_valid;
   //________________________________________________________________________________
     alt_aeu_40_sfc_tx_ctrl                     #(
         .WORDS                 (WORDS)                 // to format pause frame
        ,.INC_PRMBL             (SYNOPT_PREAMBLE_PASS)
        ,.FCBITS                (FCBITS)
        ,.EMPTYBITS     (EMPTYBITS)
        ,.cfg_saddr             (48'he100_eefc_5add)
        ,.cfg_daddr             (48'h0180C2_000001)
        ,.cfg_opcode            (16'h0001)
        ,.cfg_typlen            (16'h8808)
      )
   //________________________________________________________________________________
     tx_ctrl                    (
         .clk                   (clk)
        ,.reset_n               (reset_n)
        ,.cfg_pause_req         (cfg_pause_req)
        ,.cfg_enable_txins      (cfg_enable_txins)
        ,.cfg_enable_txoff      (cfg_enable_txoff) // enables transmit off 
        ,.cfg_pause_quanta      (cfg_pause_quanta[FCBITS*16-1:0])

        ,.cfg_qholdoff_en       (cfg_qholdoff_en[FCBITS-1:0])
        ,.cfg_qholdoff_quanta   (cfg_qholdoff_quanta[16*FCBITS-1:0]) 

        ,.rx_txoff_req          (rx_txoff_req)
        ,.in_pause_req          (in_pause_req[FCBITS-1:0])
        ,.txon_frame            (txon_frame[FCBITS-1:0])
        ,.txoff_frame           (txoff_frame[FCBITS-1:0])

        ,.out_ready             (odp_ready)
        ,.in_ready              (ctrl_ready)

        ,.pkt_end               (pkt_end) 
        ,.sel_in_pkt            (sel_in_pkt)
        ,.sel_store_pkt         (sel_store_pkt)
        ,.sel_pause_pkt         (sel_pause_pkt)
        ,.out_pause_valid       (out_pause_valid)
        ,.out_pause_empty       (out_pause_empty)
        ,.out_pause_data        (out_pause_data)
        );

   //___________________________________________________________________________________________________________
     alt_aeu_40_sfc_tx_odp #(.WORDS(WORDS) ,.DWIDTH(DWIDTH) ,.EMPTYBITS(EMPTYBITS))
   //___________________________________________________________________________________________________________
     txodp (
       .clk                     (clk)
      ,.rst_n                   (reset_n)
                                                         
      ,.sel_in_pkt              (sel_in_pkt)            // insert 
      ,.sel_pause_pkt           (sel_pause_pkt)
      ,.sel_store_pkt           (sel_store_pkt)
                                                         
      ,.in_ready                (odp_ready)             // input ready
      ,.in_valid                (idp_valid)             // input val
      ,.in_sop                  (idp_sop)               // sop word
      ,.in_eop                  (idp_eop)               // sop word
      ,.in_error                (idp_error)
      ,.in_data                 (idp_data)              // data 
      ,.in_empty                (idp_empty)             // eop byte(one hot)
      ,.in_pause_valid          (out_pause_valid)
      ,.in_pause_empty          (out_pause_empty)
      ,.in_pause_data           (out_pause_data)
                                                         
      ,.out_ready               (out_ready)             // stall input pipe
      ,.out_valid               (out_valid)             // output val
      ,.out_sop                 (out_sop)               // sop word      
      ,.out_eop                 (out_eop)               // sop word      
      ,.out_error               (out_error)
      ,.out_data                (out_data)              // data
      ,.out_empty               (out_empty)             // eop byte (one hot)

      ,.out_debug               (out_debug_odp)         // sop word
     );

   //___________________________________________________________________________________________________________
     wire read ;
     wire write ;
     wire readdatavalid ;
     wire [07:0]address ;
     wire [31:0]writedata ;
     wire [31:0]readdata ;
/*
     serif_slave_async #(.ADDR_PAGE(BASE_TXFC), .TARGET_CHIP(TARGET_CHIP)) 
     avalon_serial_brdg (
         .aclr  (reset_mm) 
        ,.sclk  (clk_mm) 
        ,.din   (smm_master_dout) 
        ,.dout  (smm_slave_dout) 
        ,.bclk  (clk) 
        ,.wr    (write) 
        ,.rd    (read) 
        ,.addr  (address) 
        ,.wdata (writedata) 
        ,.rdata (readdata) 
        ,.rdata_valid(readdatavalid)
     );
*/

     serif_slave #(.ADDR_PAGE(BASE_TXFC), .TARGET_CHIP(TARGET_CHIP)) 
     avalon_serial_brdg (
         .clk   (clk_mm) 
        ,.din   (smm_master_dout) 
        ,.dout  (smm_slave_dout) 

        ,.wr    (write) 
        ,.rd    (read) 
        ,.addr  (address) 
        ,.wdata (writedata) 
        ,.rdata (readdata) 
        ,.rdata_valid(readdatavalid)
     );

   //___________________________________________________________________________________________________________
   alt_aeu_40_sfc_tx_csr #(.CSRADDRSIZE(CSRADDRSIZE),  .FCBITS(FCBITS), .REVID(REVID))
   //___________________________________________________________________________________________________________
   tx_csr(
         .clk                   (clk)
        ,.clk_mm                (clk_mm)   
        ,.reset_n               (reset_n)
        ,.read                  (read)
        ,.write                 (write)
        ,.address               (address)
        ,.writedata             (writedata)
        ,.readdatavalid         (readdatavalid)
        ,.readdata              (readdata)
                                
        ,.cfg_enable_txoff      (cfg_enable_txoff) // enables transmit off 
        ,.cfg_enable_txins      (cfg_enable_txins) // enables pause insertion
        ,.cfg_paureq            (cfg_pause_req)
        ,.cfg_pause_quanta      (cfg_pause_quanta)
        ,.cfg_qholdoff_en       (cfg_qholdoff_en)
        ,.cfg_qholdoff_quanta   (cfg_qholdoff_quanta)
        ,.txon_frame            (txon_frame)
        ,.txoff_frame           (txoff_frame)
        );

 endmodule


