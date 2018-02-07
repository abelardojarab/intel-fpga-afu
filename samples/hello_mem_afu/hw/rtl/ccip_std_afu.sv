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

// ***************************************************************************

import ccip_if_pkg::*;

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

    // CCI-P structures
    input  t_if_ccip_Rx pck_cp2af_sRx,        // CCI-P Rx Port
    output t_if_ccip_Tx pck_af2cp_sTx,        // CCI-P Tx Port

    // Local memory interface
    avalon_mem_if.to_fiu local_mem[NUM_LOCAL_MEM_BANKS]
);

    logic [63:0]                avs_byteenable;
    logic                       avs_waitrequest;
    logic [511:0]               avs_readdata;
    logic                       avs_readdatavalid;
    logic [6:0]                 avs_burstcount;
    logic [511:0]               avs_writedata;
    local_mem_cfg_pkg::t_local_mem_addr  avs_address;
    logic                       avs_write;
    logic                       avs_read;

    // bank A
    logic                avs_waitrequest_a;
    logic [511:0]        avs_readdata_a;
    logic                avs_readdatavalid_a;
    logic                avs_write_a;
    logic                avs_read_a;

    // bank B
    logic                avs_waitrequest_b;
    logic [511:0]        avs_readdata_b;
    logic                avs_readdatavalid_b;
    logic                avs_write_b;
    logic                avs_read_b;

    // choose which memory bank to test
    logic                mem_bank_select;

    // ====================================================================
    // Pick the proper clk and reset, as chosen by the AFU's JSON file
    // ====================================================================

    // The platform may transform the CCI-P clock from pClk to a clock
    // chosen in the AFU's JSON file.  ccip_if_clock() is provided to
    // return the chosen clock so that the AFU code here can connect
    // to the proper clock without the possibility of a mismatch with
    // the JSON.

    logic clk;
    logic reset;

    // Use .* to avoid naming any clocks or resets.  They will match
    // from top-level interface names.
    ccip_if_clock pick_clk(.*, .clk(clk), .reset(reset));


    // ====================================================================
    // Register signals at interface before consuming them
    // ====================================================================

    (* noprune *) logic [1:0]  cp2af_pwrState_T1;
    (* noprune *) logic        cp2af_error_T1;

    logic        reset_T1;
    t_if_ccip_Rx cp2af_sRx_T1;
    t_if_ccip_Tx af2cp_sTx_T0;

    ccip_interface_reg inst_green_ccip_interface_reg
       (
        .pClk                    (clk),
        .pck_cp2af_softReset_T0  (reset),
        .pck_cp2af_pwrState_T0   (pck_cp2af_pwrState),
        .pck_cp2af_error_T0      (pck_cp2af_error),
        .pck_cp2af_sRx_T0        (pck_cp2af_sRx),
        .pck_af2cp_sTx_T0        (af2cp_sTx_T0),

        .pck_cp2af_softReset_T1  (reset_T1),
        .pck_cp2af_pwrState_T1   (cp2af_pwrState_T1),
        .pck_cp2af_error_T1      (cp2af_error_T1),
        .pck_cp2af_sRx_T1        (cp2af_sRx_T1),
        .pck_af2cp_sTx_T1        (pck_af2cp_sTx)
        );


    // ====================================================================
    // User AFU goes here
    // ====================================================================

    //
    // hello_mem_afu depends on CCI-P and local memory being in the same
    // clock domain.  This is accomplished by choosing a common clock
    // in the AFU's JSON description.  The platform instantiates clock-
    // crossing shims automatically, as needed.
    //

    hello_mem_afu
      #(
        .DDR_ADDR_WIDTH(local_mem_cfg_pkg::LOCAL_MEM_ADDR_WIDTH)
        ) hello_mem_afu_inst
       (
        .clk                 (clk),
        .SoftReset           (reset_T1),

        .avs_writedata       (avs_writedata),
        .avs_readdata        (avs_readdata[63:0]),
        .avs_address         (avs_address),
        .avs_waitrequest     (avs_waitrequest),
        .avs_write           (avs_write),
        .avs_read	     (avs_read),
        .avs_byteenable      (avs_byteenable),
        .avs_burstcount      (avs_burstcount),
        .avs_readdatavalid   (avs_readdatavalid),
        .mem_bank_select     (mem_bank_select),

        .cp2af_sRxPort       (cp2af_sRx_T1),
        .af2cp_sTxPort       (af2cp_sTx_T0)
        );

    //
    // Map Avalon MM requests from hello_mem_afu to memory banks.
    //
    assign avs_waitrequest   = (mem_bank_select)?avs_waitrequest_b:avs_waitrequest_a;
    assign avs_readdata      = (mem_bank_select)?avs_readdata_b:avs_readdata_a;
    assign avs_readdatavalid = (mem_bank_select)?avs_readdatavalid_b:avs_readdatavalid_a;
    assign avs_write_a       = (mem_bank_select)?1'b0:avs_write;
    assign avs_write_b       = (mem_bank_select)?avs_write:1'b0;
    assign avs_read_a        = (mem_bank_select)?1'b0:avs_read;
    assign avs_read_b        = (mem_bank_select)?avs_read:1'b0;

    always_comb
    begin
        avs_waitrequest_a = local_mem[0].waitrequest;
        avs_readdata_a = local_mem[0].readdata;
        avs_readdatavalid_a = local_mem[0].readdatavalid;
        local_mem[0].burstcount = avs_burstcount;
        local_mem[0].writedata = avs_writedata;
        local_mem[0].address = avs_address;
        local_mem[0].write = avs_write_a;
        local_mem[0].read = avs_read_a;
        local_mem[0].byteenable = avs_byteenable;
    end

    always_comb
    begin
        avs_waitrequest_b = local_mem[1].waitrequest;
        avs_readdata_b = local_mem[1].readdata;
        avs_readdatavalid_b = local_mem[1].readdatavalid;
        local_mem[1].burstcount = avs_burstcount;
        local_mem[1].writedata = avs_writedata;
        local_mem[1].address = avs_address;
        local_mem[1].write = avs_write_b;
        local_mem[1].read = avs_read_b;
        local_mem[1].byteenable = avs_byteenable;
    end

endmodule
