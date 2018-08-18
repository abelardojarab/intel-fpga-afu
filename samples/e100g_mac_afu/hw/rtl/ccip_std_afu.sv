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
// Include MPF data types, including the CCI interface pacakge.
`include "platform_if.vh"

module ccip_std_afu
  #(
    parameter NUM_LOCAL_MEM_BANKS = 0
    )
 (
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

    wire afu_clk;       // 200MHz
    wire avmm_clk;      // 100MHz
    assign afu_clk = pClk;
    assign avmm_clk = pClkDiv2;

    t_if_ccip_Rx pck_cp2af_mmio_sRx;
    always_comb begin
        pck_cp2af_mmio_sRx = pck_cp2af_sRx;
        //disable rsp valid on mmio path
        //pck_cp2af_mmio_sRx.c0.rspValid = 0;
    end

//===============================================================================================
// User AFU goes here
//===============================================================================================

afu #(
  .NUM_LOCAL_MEM_BANKS(NUM_LOCAL_MEM_BANKS)
 )
    afu_inst
   (
    .afu_clk(afu_clk),
    .avmm_clk(avmm_clk),
    `ifdef PLATFORM_PROVIDES_LOCAL_MEMORY
    // Local memory interface
    .local_mem               (local_mem),
`endif
    .reset               ( pck_cp2af_softReset ) ,
    .cp2af_mmio_c0rx     ( pck_cp2af_mmio_sRx.c0 ) ,
    .af2cp_sTxPort       ( pck_af2cp_sTx ) 
);

endmodule
