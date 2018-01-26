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
// Copyright(C) 2013: Altera Corporation
// $Id: alt_aeu_40_sfc_rx.v,v 1.2 2015/08/17 21:58:20 marmstro Exp marmstro $
// $Revision: 1.2 $
// $Date: 2015/08/17 21:58:20 $
// $Author: marmstro $
// ____________________________________________________________________
// altera message_off 10036 10236
// adubey 06.2013

 module alt_aeu_40_sfc_rx #( 
         parameter SYNOPT_ALIGN_FCSEOP = 0
        ,parameter TARGET_CHIP = 2 
        ,parameter REVID = 32'h02062015
        ,parameter FCBITS = 1 
        ,parameter SYNOPT_PREAMBLE_PASS = 1 
        ,parameter BASE_RXFC = 1 
        ,parameter ADDRSIZE = 8 
        ,parameter WORDS = 4 
        ,parameter EMPTYBITS = 6
        ,parameter RXERRWIDTH = 6
        ,parameter RXSTATUSWIDTH =3 // RxCtrl                        
       )( 
         input  wire clk_mm 
        ,input  wire reset_mm 
        ,input  wire smm_master_dout 
        ,output wire smm_slave_dout 
     
        ,input  wire clk
        ,input  wire reset_n
     
        ,output wire in_ready
        ,input  wire [RXERRWIDTH-1:0]    in_error 
        ,input  wire [RXSTATUSWIDTH-1:0] in_status  
        ,input  wire in_error_valid
        ,input  wire in_valid
        ,input  wire in_eop
        ,input  wire in_sop
        ,input  wire [EMPTYBITS-1:0]in_empty 
        ,input  wire [WORDS*64-1:0] in_data
     
        ,input  wire  out_ready
        ,output wire [RXERRWIDTH-1:0]    out_error 
        ,output wire [RXSTATUSWIDTH-1:0] out_status  
        ,output wire out_error_valid
        ,output wire out_valid
        ,output wire out_sop
        ,output wire out_eop
        ,output wire[2:0] out_sband
        ,output wire[EMPTYBITS-1:0] out_empty 
        ,output wire[WORDS*64-1:0] out_data
        ,output wire[FCBITS-1:0] out_pause
       );

     wire drop_this_frame;
     assign out_sband[2] = drop_this_frame;
 //     _________________________________________________________________
 //
     assign in_ready = out_ready;
     wire [FCBITS-1:0] rxon_frame;
     wire [FCBITS-1:0] rxoff_frame;
     wire [FCBITS-1:0] rx_out_pause;
     wire [FCBITS-1:0] cfg_enable;
     wire[47:0] cfg_daddr;
     wire cfg_fwd_pause_frame;
     
     wire read ;
     wire write ;
     wire readdatavalid ;
     wire [07:0]address ;
     wire [31:0]writedata ;
     wire [31:0]readdata ;
/*  
 // _________________________________________________________________
     serif_slave_async #(.ADDR_PAGE(BASE_RXFC), .TARGET_CHIP(TARGET_CHIP)) 
 // _________________________________________________________________
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
 // _________________________________________________________________
     serif_slave #(.ADDR_PAGE(BASE_RXFC), .TARGET_CHIP(TARGET_CHIP)) 
 // _________________________________________________________________
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
   
 // _________________________________________________________________
     alt_aeu_40_sfc_rx_csr #(.ADDRSIZE( 8 ) ,.FCBITS(FCBITS), .REVID(REVID)) 
 // _________________________________________________________________
     rx_csr  (
         .clk                   (clk                  )
        ,.clk_mm                (clk_mm               )       
        ,.reset_n               (reset_n              )
        ,.read                  (read                 )
        ,.write                 (write                )
        ,.address               (address              )
        ,.readdata              (readdata             )
        ,.writedata             (writedata            )
        ,.waitrequest           (                     )
        ,.readdatavalid         (readdatavalid        )
                                
        ,.rxon_frame            (rxon_frame           )
        ,.rxoff_frame           (rxoff_frame          )
        ,.cfg_enable            (cfg_enable           )
        ,.cfg_daddr             (cfg_daddr            )
        ,.cfg_fwd_pause_frame   (cfg_fwd_pause_frame  )
     );

 // _________________________________________________________________
      alt_aeu_40_sfc_rx_ctrl   #(
         .WORDS                 (WORDS) 
        ,.SYNOPT_ALIGN_FCSEOP   (SYNOPT_ALIGN_FCSEOP)
        ,.INC_PRMBL             (SYNOPT_PREAMBLE_PASS)
        ,.FCBITS                (FCBITS)
        ,.EMPTYBITS             (EMPTYBITS)
        ,.cfg_typlen            (16'h8808)
        ,.cfg_opcode            (16'h0001)
      )
 // _________________________________________________________________
      rx_ctrl (
         .clk                   (clk                    )
        ,.reset_n               (reset_n                )
        ,.cfg_enable            (cfg_enable             )
        ,.cfg_daddr             (cfg_daddr              )
        ,.cfg_fwd_pause_frame   (cfg_fwd_pause_frame    )
          
        ,.in_fcserror           (in_error[1]            )
        ,.in_fcsval             (in_error_valid         )
        ,.in_sop                (in_sop                 )
        ,.in_valid              (in_valid               )                       
        ,.in_data               (in_data                )
        ,.in_empty              (in_empty               )
        ,.rxon_frame            (rxon_frame             )
        ,.rxoff_frame           (rxoff_frame            )
        ,.rx_out_pause          (out_pause              )
        ,.drop_this_frame       (drop_this_frame        )
        );

   // ____________________________________________
     alt_aeu_40_sfc_rx_dp                       #(
         .SYNOPT_ALIGN_FCSEOP   (SYNOPT_ALIGN_FCSEOP)
        ,.RXERRWIDTH            (RXERRWIDTH)
        ,.WORDS                 (WORDS)
        ,.EMPTYBITS             (EMPTYBITS)
        ,.RXSTATUSWIDTH         (RXSTATUSWIDTH)//RxCtrl                                           
   // ____________________________________________
   ) rxdp (
       .clk                     (clk),
       .reset_n                 (reset_n),
       .drop_this_frame         (drop_this_frame),
                                                         
       .in_eop                  (in_eop),
       .in_error                (in_error ),
       .in_status               (in_status),//RxCtrl,       
       .in_error_valid          (in_error_valid),
       .in_sop                  (in_sop),
       .in_valid                (in_valid),
       .in_data                 (in_data),
       .in_empty                (in_empty ), 
                                                         
       .out_sband               (out_sband[1:0]),
       .out_eop                 (out_eop),
       .out_error               (out_error ),
       .out_status              (out_status),//RxCtrl      
       .out_error_valid         (out_error_valid),
       .out_sop                 (out_sop ),
       .out_valid               (out_valid) ,
       .out_data                (out_data),
       .out_empty               (out_empty)); 
 // ____________________________________________________________________
 //

 endmodule


