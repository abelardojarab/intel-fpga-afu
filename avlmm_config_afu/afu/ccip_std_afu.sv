// ***************************************************************************
// Copyright (c) 2013-2016, Intel Corporation
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// * Neither the name of Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Module Name :    ccip_std_afu
// Project :        ccip afu top
// Description :    This module instantiates CCI-P compliant AFU

// ***************************************************************************
`default_nettype none
import ccip_if_pkg::*;
module ccip_std_afu(
  // CCI-P Clocks and Resets
  pClk,                      // 400MHz - CCI-P clock domain. Primary interface clock
  pClkDiv2,                  // 200MHz - CCI-P clock domain.
  pClkDiv4,                  // 100MHz - CCI-P clock domain.
  uClk_usr,                  // User clock domain. Refer to clock programming guide  ** Currently provides fixed 300MHz clock **
  uClk_usrDiv2,              // User clock domain. Half the programmed frequency  ** Currently provides fixed 150MHz clock **
  pck_cp2af_softReset,       // CCI-P ACTIVE HIGH Soft Reset
  pck_cp2af_pwrState,        // CCI-P AFU Power State
  pck_cp2af_error,           // CCI-P Protocol Error Detected
  
//`ifdef INCLUDE_DDR4
  DDR4_USERCLK,
  DDR4a_waitrequest,
  DDR4a_readdata,
  DDR4a_readdatavalid,
  DDR4a_burstcount,
  DDR4a_writedata,
  DDR4a_address,
  DDR4a_write,
  DDR4a_read,
  DDR4a_byteenable,
  DDR4b_waitrequest,
  DDR4b_readdata,
  DDR4b_readdatavalid,
  DDR4b_burstcount,
  DDR4b_writedata,
  DDR4b_address,
  DDR4b_write,
  DDR4b_read,
  DDR4b_byteenable,
//`endif

  // Interface structures
  pck_cp2af_sRx,             // CCI-P Rx Port
  pck_af2cp_sTx              // CCI-P Tx Port
);
  input           wire             pClk;                     // 400MHz - CCI-P clock domain. Primary interface clock
  input           wire             pClkDiv2;                 // 200MHz - CCI-P clock domain.
  input           wire             pClkDiv4;                 // 100MHz - CCI-P clock domain.
  input           wire             uClk_usr;                 // User clock domain. Refer to clock programming guide  ** Currently provides fixed 300MHz clock **
  input           wire             uClk_usrDiv2;             // User clock domain. Half the programmed frequency  ** Currently provides fixed 150MHz clock **
  input           wire             pck_cp2af_softReset;      // CCI-P ACTIVE HIGH Soft Reset
  input           wire [1:0]       pck_cp2af_pwrState;       // CCI-P AFU Power State
  input           wire             pck_cp2af_error;          // CCI-P Protocol Error Detected
//`ifdef INCLUDE_DDR4 
  input   wire                          DDR4_USERCLK;
  input   wire                          DDR4a_waitrequest;
  input   wire [511:0]                  DDR4a_readdata;
  input   wire                          DDR4a_readdatavalid;
  output  wire [6:0]                    DDR4a_burstcount;
  output  wire [511:0]                  DDR4a_writedata;
  output  wire [25:0]                   DDR4a_address;
  output  wire                          DDR4a_write;
  output  wire                          DDR4a_read;
  output  wire [63:0]                   DDR4a_byteenable;
  input   wire                          DDR4b_waitrequest;
  input   wire [511:0]                  DDR4b_readdata;
  input   wire                          DDR4b_readdatavalid;
  output  wire [6:0]                    DDR4b_burstcount;
  output  wire [511:0]                  DDR4b_writedata;
  output  wire [25:0]                   DDR4b_address;
  output  wire                          DDR4b_write;
  output  wire                          DDR4b_read;
  output  wire [63:0]                   DDR4b_byteenable;
//`endif
  // Interface structures
  input           t_if_ccip_Rx     pck_cp2af_sRx;           // CCI-P Rx Port
  output          t_if_ccip_Tx     pck_af2cp_sTx;           // CCI-P Tx Port

  wire [63:0]                   avs_byteenable;
  wire                          avs_waitrequest;
  wire [511:0]                  avs_readdata;
  wire                          avs_readdatavalid;
  wire [6:0]                    avs_burstcount;
  wire [511:0]                  avs_writedata;
  wire [25:0]                   avs_address;
  wire                          avs_write;
  wire                          avs_read;
  wire [63:0]                   avs_byteenable;

  // bank A
  wire                avs_waitrequest_a; 
  wire [511:0]        avs_readdata_a;     
  wire                avs_readdatavalid_a;
  wire                avs_write_a;
  wire                avs_read_a;

  // bank B
  wire                avs_waitrequest_b; 
  wire [511:0]        avs_readdata_b;     
  wire                avs_readdatavalid_b;
  wire                avs_write_b;
  wire                avs_read_b;

  wire                mem_bank_select;

// =============================================================
// Register SR <--> PR signals at interface before consuming it
// =============================================================

(* noprune *) logic [1:0]  pck_cp2af_pwrState_T1;
(* noprune *) logic        pck_cp2af_error_T1;

logic        pck_cp2af_softReset_T1;
t_if_ccip_Rx pck_cp2af_sRx_T1;
t_if_ccip_Tx pck_af2cp_sTx_T0;

// =============================================================
// Register PR <--> PR signals near interface before consuming it
// =============================================================

ccip_interface_reg inst_green_ccip_interface_reg  (
    .pClk                           (pClk),
    .pck_cp2af_softReset_T0         (pck_cp2af_softReset),
    .pck_cp2af_pwrState_T0          (pck_cp2af_pwrState),
    .pck_cp2af_error_T0             (pck_cp2af_error),
    .pck_cp2af_sRx_T0               (pck_cp2af_sRx),
    .pck_af2cp_sTx_T0               (pck_af2cp_sTx_T0),

    .pck_cp2af_softReset_T1         (pck_cp2af_softReset_T1),
    .pck_cp2af_pwrState_T1          (pck_cp2af_pwrState_T1),
    .pck_cp2af_error_T1             (pck_cp2af_error_T1),
    .pck_cp2af_sRx_T1               (pck_cp2af_sRx_T1),
    .pck_af2cp_sTx_T1               (pck_af2cp_sTx)
);

//===============================================================================================
// User AFU goes here
//===============================================================================================


avlmm_config_afu avlmm_afu (
  .Clk_400             ( pClk ) ,
  .SoftReset           ( pck_cp2af_softReset_T1 ) ,

//`ifdef INCLUDE_DDR4   
  .avs_writedata       ( avs_writedata ),			
  .avs_readdata        ( avs_readdata[63:0] ),
  .avs_address         ( avs_address ),				
  .avs_waitrequest     ( avs_waitrequest ),		
  .avs_write           ( avs_write ),					
  .avs_read	           ( avs_read ),					
  .avs_byteenable      ( avs_byteenable ),		
  .avs_burstcount      ( avs_burstcount ),   
  .avs_readdatavalid   ( avs_readdatavalid ),	 
  .mem_bank_select     ( mem_bank_select ),
//.avs_writeresponsevalid ( DDR4a_writeresponsevalid),
//.avs_response        ( DDR4a_response ),
//`endif

  .cp2af_sRxPort       ( pck_cp2af_sRx_T1 ) ,
  .af2cp_sTxPort       ( pck_af2cp_sTx_T0 )
 
);

assign avs_waitrequest = (mem_bank_select)?avs_waitrequest_b:avs_waitrequest_a;
assign avs_readdata = (mem_bank_select)?avs_readdata_b:avs_readdata_a;
assign avs_readdatavalid = (mem_bank_select)?avs_readdatavalid_b:avs_readdatavalid_a;
assign avs_write_a = (mem_bank_select)?1'b0:avs_write;
assign avs_write_b = (mem_bank_select)?avs_write:1'b0;
assign avs_read_a = (mem_bank_select)?1'b0:avs_read;
assign avs_read_b = (mem_bank_select)?avs_read:1'b0;

altera_avalon_mm_clock_crossing_bridge #(
  .DATA_WIDTH          (512),
  .SYMBOL_WIDTH        (8),
  .HDL_ADDR_WIDTH      (32),
  .BURSTCOUNT_WIDTH    (7),
  .COMMAND_FIFO_DEPTH  (128),
  .RESPONSE_FIFO_DEPTH (128),
  .MASTER_SYNC_DEPTH   (2),
  .SLAVE_SYNC_DEPTH    (2)
) clock_crossing_bridge_0 (
  .m0_clk           (DDR4_USERCLK),                                
  .m0_reset         (pck_cp2af_softReset_T1),                       
  .s0_clk           (pClk),                             
  .s0_reset         (pck_cp2af_softReset_T1),       

  // slave i/f
  .s0_waitrequest   (avs_waitrequest_a),  
  .s0_readdata      (avs_readdata_a),      
  .s0_readdatavalid (avs_readdatavalid_a), 
  .s0_burstcount    (avs_burstcount),   
  .s0_writedata     (avs_writedata),     
  .s0_address       (avs_address),       
  .s0_write         (avs_write_a),        
  .s0_read          (avs_read_a),         
  .s0_byteenable    (avs_byteenable),   
  .s0_debugaccess   (0),  
  
  // master i/f
  .m0_waitrequest   (DDR4a_waitrequest),  
  .m0_readdata      (DDR4a_readdata),    
  .m0_readdatavalid (DDR4a_readdatavalid), 
  .m0_burstcount    (DDR4a_burstcount),   
  .m0_writedata     (DDR4a_writedata),    
  .m0_address       (DDR4a_address),      
  .m0_write         (DDR4a_write),      
  .m0_read          (DDR4a_read),        
  .m0_byteenable    (DDR4a_byteenable)
);


altera_avalon_mm_clock_crossing_bridge #(
  .DATA_WIDTH          (512),
  .SYMBOL_WIDTH        (8),
  .HDL_ADDR_WIDTH      (32),
  .BURSTCOUNT_WIDTH    (7),
  .COMMAND_FIFO_DEPTH  (128),
  .RESPONSE_FIFO_DEPTH (128),
  .MASTER_SYNC_DEPTH   (2),
  .SLAVE_SYNC_DEPTH    (2)
) clock_crossing_bridge_1 (
  .m0_clk           (DDR4_USERCLK),                                
  .m0_reset         (pck_cp2af_softReset_T1),                       
  .s0_clk           (pClk),                             
  .s0_reset         (pck_cp2af_softReset_T1),       

  // slave i/f
  .s0_waitrequest   (avs_waitrequest_b),  
  .s0_readdata      (avs_readdata_b),      
  .s0_readdatavalid (avs_readdatavalid_b), 
  .s0_burstcount    (avs_burstcount),   
  .s0_writedata     (avs_writedata),     
  .s0_address       (avs_address),       
  .s0_write         (avs_write_b),        
  .s0_read          (avs_read_b),         
  .s0_byteenable    (avs_byteenable),   
  .s0_debugaccess   (0),  
  
  // master i/f
  .m0_waitrequest   (DDR4b_waitrequest),  
  .m0_readdata      (DDR4b_readdata),    
  .m0_readdatavalid (DDR4b_readdatavalid), 
  .m0_burstcount    (DDR4b_burstcount),   
  .m0_writedata     (DDR4b_writedata),    
  .m0_address       (DDR4b_address),      
  .m0_write         (DDR4b_write),      
  .m0_read          (DDR4b_read),        
  .m0_byteenable    (DDR4b_byteenable)
);


// =================================================================
// ccip_debug is a reference debug module for tapping cci-p signals
// =================================================================

/*
ccip_debug inst_ccip_debug(
  .pClk                (pClk),
  .pck_cp2af_pwrState  (pck_cp2af_pwrState),
  .pck_cp2af_error     (pck_cp2af_error),

  .pck_cp2af_sRx       (pck_cp2af_sRx),
  .pck_af2cp_sTx       (pck_af2cp_sTx)
);
*/

endmodule
