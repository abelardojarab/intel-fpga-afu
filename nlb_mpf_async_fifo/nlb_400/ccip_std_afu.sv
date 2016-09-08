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
// Module Name :	  ccip_std_afu
// Project :        ccip afu top 
// Description :    This module instantiates CCI-P compliant AFU

// ***************************************************************************
import ccip_if_pkg::*;
`include "cci_mpf_if.vh"

module nlb_mpf_async_fifo_wrapper_top(
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
  output          t_if_ccip_Tx      pck_af2cp_sTx         // CCI-P Tx Port
);


//===============================================================================================
// User AFU goes here
//===============================================================================================
localparam MPF_DFH_MMIO_ADDR = 'h1000;

// Async shim 
   logic 	  reset_pass;   
   logic 	  afu_clk;   

   t_if_ccip_Tx mpf_tx;
   t_if_ccip_Rx mpf_rx;
    t_if_ccip_Rx      pck_cp2af_sRx_T1;     // CCI-P Rx Port
   
   logic pck_cp2af_softReset_T1;
      
   
   
   always@(posedge pClk)
   begin
        pck_cp2af_sRx_T1 <= pck_cp2af_sRx;     // CCI-P Rx Port
        
	pck_cp2af_softReset_T1 <=pck_cp2af_softReset;
	
   end
   
      
   assign afu_clk = uClk_usr;
   
   ccip_async_shim ccip_async_shim (
				    .bb_softreset    (pck_cp2af_softReset_T1),
				    .bb_clk          (pClk),
				    .bb_tx           (pck_af2cp_sTx),
				    .bb_rx           (pck_cp2af_sRx_T1),
				    .afu_softreset   (reset_pass),
				    .afu_clk         (afu_clk),
				    .afu_tx          (mpf_tx),
				    .afu_rx          (mpf_rx)
				    );

// Expose FIU as an MPF interface

cci_mpf_if fiu(.clk(afu_clk));

ccip_wires_to_mpf
  #(
    .REGISTER_INPUTS(0),
    .REGISTER_OUTPUTS(1)
    )
  map_ifc(.pClk(afu_clk),                            // 400MHz - CCI-P clock domain. Primary interface clock
          .pClkDiv2(pClkDiv2),                   // 200MHz - CCI-P clock domain.
          .pClkDiv4(pClkDiv4),                  // 100MHz - CCI-P clock domain.
          .uClk_usr(uClk_usr),                 // User clock domain. Refer to clock programming guide  ** Currently provides fixed 300MHz clock **
          .uClk_usrDiv2(uClk_usrDiv2),        // User clock domain. Half the programmed frequency  ** Currently provides fixed 150MHz clock **
          .pck_cp2af_softReset(reset_pass), // CCI-P ACTIVE HIGH Soft Reset
          .pck_cp2af_pwrState(pck_cp2af_pwrState),                       // CCI-P AFU Power State
          .pck_cp2af_error(pck_cp2af_error),                         // CCI-P Protocol Error Detected

    // Interface structures
          .pck_cp2af_sRx(mpf_rx),       // CCI-P Rx Port
          .pck_af2cp_sTx(mpf_tx),       // CCI-P Tx Port
          .fiu(fiu)
);

// Put MPF between AFU and FIU.

cci_mpf_if afu(.clk(afu_clk));

cci_mpf
  #(
    .SORT_READ_RESPONSES(1),
    .PRESERVE_WRITE_MDATA(1),
    // Don't enforce write/write or write/read ordering within a cache line.
    // (Default CCI behavior.)
    .ENFORCE_WR_ORDER(0),

    // Address of the MPF feature header
    .DFH_MMIO_BASE_ADDR(MPF_DFH_MMIO_ADDR)
    )
  mpf
   (
    .clk(afu_clk),
    .fiu(fiu),
    .afu(afu)
    );

t_if_ccip_Rx afu_rx;
t_if_ccip_Tx afu_tx;

always_comb
begin
    afu_rx.c0 = afu.c0Rx;
    afu_rx.c1 = afu.c1Rx;

    afu_rx.c0TxAlmFull = afu.c0TxAlmFull;
    afu_rx.c1TxAlmFull = afu.c1TxAlmFull;

    afu.c0Tx = cci_mpf_cvtC0TxFromBase(afu_tx.c0);
    // Treat all addresses as virtual
    if (cci_mpf_c0TxIsReadReq(afu.c0Tx))
    begin
        afu.c0Tx.hdr.ext.addrIsVirtual = 1'b1;
    end

    afu.c1Tx = cci_mpf_cvtC1TxFromBase(afu_tx.c1);
    if (cci_mpf_c1TxIsWriteReq(afu.c1Tx))
    begin
        afu.c1Tx.hdr.ext.addrIsVirtual = 1'b1;
    end

    afu.c2Tx = afu_tx.c2;
end

//===============================================================================================
// User AFU goes here
//===============================================================================================
// NLB AFU- provides validation, performance characterization modes. It also serves as a reference design
nlb_lpbk#()
 nlb_lpbk(
  .Clk_400             ( afu_clk) ,
  .SoftReset           ( reset_pass) ,
  .cp2af_sRxPort       ( afu_rx ) ,
  .af2cp_sTxPort       ( afu_tx ) 
);





endmodule
