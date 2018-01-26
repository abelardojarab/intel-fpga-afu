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
// $Id: alt_aeu_40_efc_top.v,v 1.4 2015/01/29 06:23:02 marmstro Exp marmstro $
// $Revision: 1.4 $
// $Date: 2015/01/29 06:23:02 $
// $Author: marmstro $
// ____________________________________________________________________
// altera message_off 10036 10236
// adubey 06.2013

 module alt_aeu_40_efc_top #( 
        parameter SYNOPT_ALIGN_FCSEOP = 0
       ,parameter SYNOPT_PREAMBLE_PASS = 1 
       ,parameter SYNOPT_PAUSE_TYPE = 0 // PAUSE
       ,parameter FCBITS = 1 
       ,parameter TARGET_CHIP = 2 
       ,parameter BASE_TXFC = 0 
       ,parameter BASE_RXFC = 1 
       ,parameter REVID = 32'h04142014 
       ,parameter WORDS = 4 
       ,parameter DWIDTH = 512 
       ,parameter EMPTYBITS = 6 
       ,parameter RXERRWIDTH = 6
       ,parameter RXSTATUSWIDTH  = 3                          
       ,parameter TXDBGWIDTH = 1 
       ,parameter RXDBGWIDTH = 3 
       ,parameter BYPASS = 0 
      )(
       input  wire clk_rx
      ,input  wire clk_tx
      ,input  wire reset_rx_n
      ,input  wire reset_tx_n
      ,input  wire clk_mm 
      ,input  wire reset_mm 
      ,input  wire smm_master_dout 
      ,output wire smm_slave_dout 
      
      ,output wire tx_in_ready
      ,input  wire tx_in_valid
      ,input  wire tx_in_sop
      ,input  wire tx_in_eop
      ,input  wire [DWIDTH-1:0] tx_in_data
      ,input  wire [EMPTYBITS-1:0] tx_in_empty 
      ,input  wire tx_in_error
      ,input  wire [TXDBGWIDTH-1:0] tx_in_debug
      
      ,input  wire tx_out_ready
      ,output wire tx_out_valid
      ,output wire tx_out_sop
      ,output wire tx_out_eop
      ,output wire [DWIDTH-1:0] tx_out_data
      ,output wire [EMPTYBITS-1:0] tx_out_empty 
      ,output wire tx_out_error
      ,output wire [TXDBGWIDTH-1:0] tx_out_debug
      
      ,output wire rx_in_ready
      ,input  wire rx_in_valid
      ,input  wire rx_in_sop
      ,input  wire rx_in_eop
      ,input  wire [WORDS*64-1:0] rx_in_data
      ,input  wire [EMPTYBITS-1:0] rx_in_empty 
      ,input  wire [RXERRWIDTH-1:0] rx_in_error
      ,input  wire [RXSTATUSWIDTH-1:0] rx_in_status     
      ,input  wire rx_in_error_valid
      ,input  wire [RXDBGWIDTH-1:0] rx_in_debug
      
      ,input  wire rx_out_ready
      ,output wire rx_out_valid
      ,output wire rx_out_sop
      ,output wire rx_out_eop
      ,output wire [WORDS*64-1:0] rx_out_data
      ,output wire [EMPTYBITS-1:0] rx_out_empty 
      ,output wire [RXERRWIDTH-1:0] rx_out_error
      ,output wire [RXSTATUSWIDTH-1:0] rx_out_status    
      ,output wire rx_out_error_valid
      ,output wire [RXDBGWIDTH-1:0] rx_out_debug
      
      ,input  wire [FCBITS-1:0] tx_in_pause      // ingress buffer congestion indication 
      ,output wire [FCBITS-1:0] rx_out_pause     // pause signal to egress buffer 
      );
 // ________________________________________________________________
 //
  generate if (SYNOPT_PAUSE_TYPE == 0)  
        begin
                assign tx_in_ready      = tx_out_ready;
                assign tx_out_valid     = tx_in_valid;
                assign tx_out_sop       = tx_in_sop;
                assign tx_out_eop       = tx_in_eop;
                assign tx_out_data      = tx_in_data;
                assign tx_out_empty     = tx_in_empty;
                assign tx_out_error     = tx_in_error;
                assign tx_out_debug     = tx_in_debug;
                assign smm_slave_dout   = 1'b1; 
                
                assign rx_in_ready      = rx_out_ready;
                assign rx_out_valid     = rx_in_valid;
                assign rx_out_sop       = rx_in_sop;
                assign rx_out_eop       = rx_in_eop;
                assign rx_out_data      = rx_in_data;
                assign rx_out_empty     = rx_in_empty;
                assign rx_out_error     = rx_in_error;
                assign rx_out_status    = rx_in_status;
                assign rx_out_error_valid=rx_in_error_valid;
                assign rx_out_debug     = rx_in_debug;
                assign rx_out_pause     = tx_in_pause;  
        end
  else if (SYNOPT_PAUSE_TYPE == 2)      // PFC
      begin:pfc
            alt_aeu_40_pfc_top #( 
                 .SYNOPT_ALIGN_FCSEOP   (SYNOPT_ALIGN_FCSEOP )
                ,.SYNOPT_PREAMBLE_PASS  (SYNOPT_PREAMBLE_PASS)
                ,.SYNOPT_NUMPRIORITY    (FCBITS         )
                ,.TARGET_CHIP           ( TARGET_CHIP   )
                ,.REVID                 (REVID  )
                ,.BASE_TXFC             (BASE_TXFC      )
                ,.BASE_RXFC             (BASE_RXFC      )
                ,.WORDS                 (WORDS          )
                ,.DWIDTH                (DWIDTH         )
                ,.EMPTYBITS             (EMPTYBITS      )
               //,.TXDBGWIDTH           (TXDBGWIDTH     ) // build it later
               //,.RXDBGWIDTH           (RXDBGWIDTH     ) // build it later
               ,.RXSTATUSWIDTH        (RXSTATUSWIDTH  ) // RxCtrl                               
           ) pfc_top (
                .clk_mm                 (clk_mm         )
               ,.reset_mm               (reset_mm       )
               ,.smm_master_dout        (smm_master_dout)
               ,.smm_slave_dout         (smm_slave_dout)
                                                              
               ,.clk_tx                 (clk_tx         )
               ,.reset_tx_n             (reset_tx_n     )
               ,.tx_in_ready            (tx_in_ready    ) // output
               ,.tx_in_valid            (tx_in_valid    ) // inputs
               ,.tx_in_sop              (tx_in_sop      ) // inputs
               ,.tx_in_eop              (tx_in_eop      ) // inputs
               ,.tx_in_data             (tx_in_data     ) // inputs
               ,.tx_in_empty            (tx_in_empty    ) // inputs
               ,.tx_in_error            (tx_in_error    ) // inputs
               ,.tx_in_debug            (tx_in_debug    ) // TBD
           
               ,.tx_out_ready           (tx_out_ready   ) // input
               ,.tx_out_valid           (tx_out_valid   )
               ,.tx_out_sop             (tx_out_sop     )
               ,.tx_out_eop             (tx_out_eop     )
               ,.tx_out_data            (tx_out_data    )
               ,.tx_out_empty           (tx_out_empty   )
               ,.tx_out_error           (tx_out_error   )
               ,.tx_out_debug           (tx_out_debug   ) // TBD
        
               ,.clk_rx                 (clk_rx         )
               ,.reset_rx_n             (reset_rx_n     )
               ,.rx_in_ready            (rx_in_ready    ) // output
               ,.rx_in_valid            (rx_in_valid    ) // inputs
               ,.rx_in_sop              (rx_in_sop      ) // inputs
               ,.rx_in_eop              (rx_in_eop      ) // inputs
               ,.rx_in_data             (rx_in_data     ) // inputs
               ,.rx_in_empty            (rx_in_empty    ) // inputs
               ,.rx_in_error            (rx_in_error    ) // inputs
               ,.rx_in_status           (rx_in_status   ) // inputs //RxCtrl                                  
               ,.rx_in_error_valid      (rx_in_error_valid) // inputs
               ,.rx_in_debug             (rx_in_debug    ) // TBD
        
               ,.rx_out_ready           (rx_out_ready   ) // input
               ,.rx_out_valid           (rx_out_valid   ) // output
               ,.rx_out_sop             (rx_out_sop     ) // output
               ,.rx_out_eop             (rx_out_eop     ) // output
               ,.rx_out_data            (rx_out_data    ) // output
               ,.rx_out_empty           (rx_out_empty   ) // output
               ,.rx_out_error           (rx_out_error   ) // output
               ,.rx_out_status          (rx_out_status  ) // output ///RxCtrl                         
               ,.rx_out_error_valid     (rx_out_error_valid) // output
               ,.rx_out_debug           (rx_out_debug   ) // output
               ,.rx_out_pause           (rx_out_pause   ) // output
               ,.tx_in_pause            (tx_in_pause    ) // input
               ,.rx_inc_xon             ()
               ,.rx_inc_xoff            ()
               ,.tx_inc_xon             ()
               ,.tx_inc_xoff            ()
             );
      end
 else begin:pause
        // ____________________________________________________________ 
           alt_aeu_40_sfc_top          #( 
                 .SYNOPT_ALIGN_FCSEOP   (SYNOPT_ALIGN_FCSEOP )
                ,.SYNOPT_PREAMBLE_PASS  (SYNOPT_PREAMBLE_PASS)
                ,.FCBITS                (1              )
                ,.TARGET_CHIP           ( TARGET_CHIP)
                ,.REVID                 (REVID  )
                ,.BASE_TXFC             (BASE_TXFC      )
                ,.BASE_RXFC             (BASE_RXFC      )
                ,.WORDS                 (WORDS          )
                ,.DWIDTH                (DWIDTH         )
                ,.EMPTYBITS             (EMPTYBITS      )
                ,.RXERRWIDTH            (RXERRWIDTH     )
                ,.TXDBGWIDTH            (TXDBGWIDTH     )
                ,.RXDBGWIDTH            (RXDBGWIDTH     )
                ,.RXSTATUSWIDTH        (RXSTATUSWIDTH  ) // RxCtrl                                                                        
           ) pause_top (
                .clk_mm                 (clk_mm         )
               ,.reset_mm               (reset_mm       )
               ,.smm_master_dout        (smm_master_dout)
               ,.smm_slave_dout         (smm_slave_dout )
                                                              
               ,.clk_tx                 (clk_tx         )
               ,.reset_tx_n             (reset_tx_n     )
               ,.tx_in_ready            (tx_in_ready    ) // output
               ,.tx_in_valid            (tx_in_valid    ) // inputs
               ,.tx_in_sop              (tx_in_sop      ) // inputs
               ,.tx_in_eop              (tx_in_eop      ) // inputs
               ,.tx_in_data             (tx_in_data     ) // inputs
               ,.tx_in_empty            (tx_in_empty    ) // inputs
               ,.tx_in_error            (tx_in_error    ) // inputs
               ,.tx_in_debug            (tx_in_debug    ) // inputs
           
               ,.tx_out_ready           (tx_out_ready   ) // input
               ,.tx_out_valid           (tx_out_valid   )
               ,.tx_out_sop             (tx_out_sop     )
               ,.tx_out_eop             (tx_out_eop     )
               ,.tx_out_data            (tx_out_data    )
               ,.tx_out_empty           (tx_out_empty   )
               ,.tx_out_error           (tx_out_error   )
               ,.tx_out_debug           (tx_out_debug   )
        
               ,.clk_rx                 (clk_rx         )
               ,.reset_rx_n             (reset_rx_n     )
               ,.rx_in_ready            (rx_in_ready    ) // output
               ,.rx_in_valid            (rx_in_valid    ) // inputs
               ,.rx_in_sop              (rx_in_sop      ) // inputs
               ,.rx_in_eop              (rx_in_eop      ) // inputs
               ,.rx_in_data             (rx_in_data     ) // inputs
               ,.rx_in_empty            (rx_in_empty    ) // inputs
               ,.rx_in_error            (rx_in_error    ) // inputs
               ,.rx_in_status           (rx_in_status   ) // inputs //RxCtrl                            
               ,.rx_in_error_valid      (rx_in_error_valid) // inputs
               ,.rx_in_debug            (rx_in_debug    ) // inputs
        
               ,.rx_out_ready           (rx_out_ready   ) // input
               ,.rx_out_valid           (rx_out_valid   ) // output
               ,.rx_out_sop             (rx_out_sop     ) // output
               ,.rx_out_eop             (rx_out_eop     ) // output
               ,.rx_out_data            (rx_out_data    ) // output
               ,.rx_out_empty           (rx_out_empty   ) // output
               ,.rx_out_error           (rx_out_error   ) // output
               ,.rx_out_status          (rx_out_status  ) // output ///RxCtrl                                           
               ,.rx_out_error_valid     (rx_out_error_valid) // output
               ,.rx_out_debug           (rx_out_debug   ) // output
                                                             
               ,.rx_out_pause           (rx_out_pause   ) // output
               ,.tx_in_pause            (tx_in_pause    ) // input
             );
           // ____________________________________________________________________
           //
       end
    endgenerate


 endmodule
