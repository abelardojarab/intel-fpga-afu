// ***************************************************************************
//
//        Copyright (C) 2008-2015 Intel Corporation All Rights Reserved.
//
// Engineer :           Pratik Marolia
// Creation Date :	20-05-2015
// Last Modified :	Wed 20 May 2015 03:03:09 PM PDT
// Module Name :	green top
// Project :
// Description :    This module instantiates CCI-P compliant AFU

// ***************************************************************************
`include "interfaces/sys_cfg_pkg.svh"
import ccip_if_pkg::*;
module green_top(
  // CCI-P Clocks and Resets
  input           logic             pClk,              // 400MHz - CCI-P clock domain. Primary interface clock
  input           logic             pClkDiv2,          // 200MHz - CCI-P clock domain.
  input           logic             pClkDiv4,          // 100MHz - CCI-P clock domain.
  input           logic             uClk_usr,          // User clock domain. Refer to clock programming guide  ** Currently provides fixed 300MHz clock **
  input           logic             uClk_usrDiv2,      // User clock domain. Half the programmed frequency  ** Currently provides fixed 150MHz clock **
  input           logic             pck_cp2af_softReset,      // CCI-P ACTIVE HIGH Soft Reset
  input           logic [1:0]       pck_cp2af_pwrState,       // CCI-P AFU Power State
  input           logic             pck_cp2af_error,          // CCI-P Protocol Error Detected

  // Interface structures
  input           t_if_ccip_Rx      pck_cp2af_sRx,        // CCI-P Rx Port
  output          t_if_ccip_Tx      pck_af2cp_sTx,        // CCI-P Tx Port

  // JTAG interface for PR region debug
  input           logic             sr2pr_tms,
  input           logic             sr2pr_tdi,
  output          logic             pr2sr_tdo,
  input           logic             sr2pr_tck,

  // Avalon MM Interface Signals
  input   wire         avs_waitrequest,   //                          .waitrequest
  input   wire [511:0] avs_readdata,      //                          .readdata
  input   wire         avs_readdatavalid, //                          .readdatavalid
  output  wire [6:0]   avs_burstcount,    //                          .burstcount
  output  wire [511:0] avs_writedata,     //                          .writedata
  output  wire [31:0]  avs_address,       //                          .address
  output  wire         avs_write,         //                          .write
  output  wire         avs_read,          //                          .read
  output  wire [63:0]  avs_byteenable     //                          .byteenable
);

// ===========================================
// AFU - Remote Debug JTAG IP instantiation
// ===========================================

`ifdef SIMULATION_MODE
assign pr2sr_tdo = 0;

`else
wire loopback;
sld_virtual_jtag  (.tdi(loopback), .tdo(loopback));
SCJIO
inst_SCJIO (
		.tms         (sr2pr_tms),         //        jtag.tms
		.tdi         (sr2pr_tdi),         //            .tdi
		.tdo         (pr2sr_tdo),         //            .tdo
		.tck         (sr2pr_tck)          //         tck.clk
);
`endif

// ===========================================
// CCI-P AFU Instantiation
// ===========================================

ccip_std_afu inst_ccip_std_afu (
    .pClk                   ( pClk),                  // 16ui link/protocol clock domain. Interface Clock
    .pClkDiv2               ( pClkDiv2),              // 32ui link/protocol clock domain. Synchronous to interface clock
    .pClkDiv4               ( pClkDiv4),              // 64ui link/protocol clock domain. Synchronous to interface clock
    .uClk_usr               ( uClk_usr),
    .uClk_usrDiv2           ( uClk_usrDiv2),
    .pck_cp2af_softReset    ( pck_cp2af_softReset),
    .pck_cp2af_pwrState     ( pck_cp2af_pwrState),
    .pck_cp2af_error        ( pck_cp2af_error),

    .pck_af2cp_sTx          ( pck_af2cp_sTx),         // CCI-P Tx Port
    .pck_cp2af_sRx          ( pck_cp2af_sRx),         // CCI-P Rx Port

    // memory interface (needs to be updated)
    .avs_writedata	        (avs_writedata),          
    .avs_readdata	          (avs_readdata),           
    .avs_address	          (avs_address),            
    .avs_waitrequest        (avs_waitrequest),        
    .avs_burstcount         (avs_burstcount),         
    .avs_write		          (avs_write),              
    .avs_read		            (avs_read),     	        
    .avs_byteenable	        (avs_byteenable),         
    .avs_readdatavalid      (avs_readdatavalid)	      

);

// ======================================================
// Workaround: To preserve uClk_usr routing to  PR region
// ======================================================

(* noprune *) logic uClk_usr_q1, uClk_usr_q2;
(* noprune *) logic uClk_usrDiv2_q1, uClk_usrDiv2_q2;
(* noprune *) logic pClkDiv4_q1, pClkDiv4_q2;
(* noprune *) logic pClkDiv2_q1, pClkDiv2_q2;

always  @(posedge uClk_usr)
begin
  uClk_usr_q1     <= 1;
  uClk_usr_q2     <= !uClk_usr_q1;
end

always  @(posedge uClk_usrDiv2)
begin
  uClk_usrDiv2_q1 <= 0;
  uClk_usrDiv2_q2 <= !uClk_usrDiv2_q1;
end

always  @(posedge pClkDiv4)
begin
  pClkDiv4_q1     <= 1;
  pClkDiv4_q2     <= !pClkDiv4_q1;
end

always  @(posedge pClkDiv2)
begin
  pClkDiv2_q1     <= 1;
  pClkDiv2_q2     <= !pClkDiv2_q1;
end


endmodule
