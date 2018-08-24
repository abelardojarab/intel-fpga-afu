// ***************************************************************************
// Copyright (c) 2013-2018, Intel Corporation
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

`include "platform_if.vh"

module ccip_std_afu
  #(
    parameter NUM_LOCAL_MEM_BANKS = 2
    )
   (
    // CCI-P Clocks and Resets
    input  logic        pClk,                 // Primary CCI-P interface clock.
    input  logic        pClkDiv2,             // Aligned, pClk divided by 2.
    input  logic        pClkDiv4,             // Aligned, pClk divided by 4.
    input  logic        uClk_usr,             // User clock domain. Refer to clock programming guide.
    input  logic        uClk_usrDiv2,         // Aligned, user clock divided by 2.
    input  logic        pck_cp2af_softReset,  // CCI-P ACTIVE HIGH Soft Reset

    input  logic [1:0]  pck_cp2af_pwrState,   // CCI-P AFU Power State
    input  logic        pck_cp2af_error,      // CCI-P Protocol Error Detected

`ifdef PLATFORM_PROVIDES_LOCAL_MEMORY
    // Local memory interface
    avalon_mem_if.to_fiu local_mem[NUM_LOCAL_MEM_BANKS],
`endif

    // CCI-P structures
    input  t_if_ccip_Rx pck_cp2af_sRx,        // CCI-P Rx Port
    output t_if_ccip_Tx pck_af2cp_sTx         // CCI-P Tx Port
    );

// =============================================================
// Select the clock that will drive the AFU, specified in the AFU's
// JSON file.  The Platform Interface Manager provides these macros.
// =============================================================

logic afu_clk;
assign afu_clk = `PLATFORM_PARAM_CCI_P_CLOCK;
logic afu_reset;
assign afu_reset = `PLATFORM_PARAM_CCI_P_RESET;

// =============================================================
// Register SR <--> PR signals at interface before consuming it
// =============================================================

(* noprune *) logic [1:0]  pck_cp2af_pwrState_T1;
(* noprune *) logic        pck_cp2af_error_T1;

logic        afu_reset_T1;
t_if_ccip_Rx pck_cp2af_sRx_T1;
t_if_ccip_Tx pck_af2cp_sTx_T0;

// =============================================================
// Register PR <--> PR signals near interface before consuming it
// =============================================================

ccip_interface_reg
  inst_green_ccip_interface_reg
   (
    .pClk                       (afu_clk),
    .pck_cp2af_softReset_T0     (afu_reset),
    .pck_cp2af_pwrState_T0      (pck_cp2af_pwrState),
    .pck_cp2af_error_T0         (pck_cp2af_error),
    .pck_cp2af_sRx_T0           (pck_cp2af_sRx),
    .pck_af2cp_sTx_T0           (pck_af2cp_sTx_T0),

    .pck_cp2af_softReset_T1     (afu_reset_T1),
    .pck_cp2af_pwrState_T1      (pck_cp2af_pwrState_T1),
    .pck_cp2af_error_T1         (pck_cp2af_error_T1),
    .pck_cp2af_sRx_T1           (pck_cp2af_sRx_T1),
    .pck_af2cp_sTx_T1           (pck_af2cp_sTx)
    );

// =================================================================
// NLB AFU- provides validation, performance characterization modes.
// It also serves as a reference design
// =================================================================

// Need a 100 MHz clock
logic clk_100;
generate
    if (ccip_cfg_pkg::PCLK_FREQ == 400)
        assign clk_100 = pClkDiv4;
    else if (ccip_cfg_pkg::PCLK_FREQ == 200)
        assign clk_100 = pClkDiv2;
endgenerate

nlb_lpbk
  #(
    .NUM_LOCAL_MEM_BANKS(NUM_LOCAL_MEM_BANKS)
    )
  nlb_lpbk
   (
    .Clk_400                    (afu_clk),
`ifdef INCLUDE_REMOTE_STP
    .Clk_100                    (clk_100),
`endif
    .SoftReset                  (afu_reset_T1),

`ifdef PLATFORM_PROVIDES_LOCAL_MEMORY
    // Local memory interface
    .local_mem                  (local_mem),
`endif

    .cp2af_sRxPort              (pck_cp2af_sRx_T1),
    .af2cp_sTxPort              (pck_af2cp_sTx_T0)
);

endmodule
