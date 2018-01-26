// ***************************************************************************  
//
//          Copyright (C) 2017 Intel Corporation All Rights Reserved.
//
// The source code contained or described herein and all  documents related to
// the  source  code  ("Material")  are  owned  by  Intel  Corporation  or its
// suppliers  or  licensors.    Title  to  the  Material  remains  with  Intel
// Corporation or  its suppliers  and licensors.  The Material  contains trade
// secrets  and  proprietary  and  confidential  information  of  Intel or its
// suppliers and licensors.  The Material is protected  by worldwide copyright
// and trade secret laws and treaty provisions. No part of the Material may be
// used,   copied,   reproduced,   modified,   published,   uploaded,  posted,
// transmitted,  distributed,  or  disclosed  in any way without Intel's prior
// express written permission.
//
// No license under any patent,  copyright, trade secret or other intellectual
// property  right  is  granted  to  or  conferred  upon  you by disclosure or
// delivery  of  the  Materials, either expressly, by implication, inducement,
// estoppel or otherwise.  Any license under such intellectual property rights
// must be express and approved by Intel in writing.
//
// Engineer:    mariano.aguirre@intel.com
// Create Date: March/2017
// Module Name: ccip_eth_csr.v
// Project:     Ethernet
//
// Description: 
// This module implements the CSR for HSSI ETH GBS, with a CCIP interface

// ***************************************************************************

//`default_nettype none
import ccip_if_pkg::*;

module ccip_eth_csr (
    // CCI-P Clocks and Resets
    pClk,                   // 400MHz - CCI-P clock domain. Primary clock
    pClkDiv2,               // 200MHz - CCI-P clock domain.
    pClkDiv4,               // 100MHz - CCI-P clock domain.
    uClk_usr,               // User clock domain. Refer to clock programming guide
    uClk_usrDiv2,           // User clock domain. Half the programmed frequency
    pck_cp2af_softReset,    // CCI-P ACTIVE HIGH Soft Reset
    pck_cp2af_pwrState,     // CCI-P AFU Power State
    pck_cp2af_error,        // CCI-P Protocol Error Detected
    // Interface structures
    pck_cp2af_sRx,          // CCI-P Rx Port
    pck_af2cp_sTx,          // CCI-P Tx Port
    // Register input/outputs (100 MHz)
    eth_ctrl_addr,          // control/address
    eth_wr_data,            // write data
    eth_rd_data,            // read data
    init_start,             // AFU init start
    init_done               // AFU init done
);

input           pClk;                
input           pClkDiv2;            
input           pClkDiv4;            
input           uClk_usr;            
input           uClk_usrDiv2;        
input           pck_cp2af_softReset; 
input     [1:0] pck_cp2af_pwrState;  
input           pck_cp2af_error;     

input  t_if_ccip_Rx pck_cp2af_sRx;
output t_if_ccip_Tx pck_af2cp_sTx;

output reg  [31:0] eth_ctrl_addr;
output reg  [31:0] eth_wr_data;
input       [31:0] eth_rd_data;
output reg         init_start;
input              init_done;

//------------------------------------------------------------------------------
// Internal signals
//------------------------------------------------------------------------------

reg  [31:0] ctrl_addr;
reg  [31:0] wr_data;
reg  [31:0] rd_data;

reg         init_done_r;

reg  [63:0] afu_scratch;
reg  [63:0] afu_init;

//------------------------------------------------------------------------------
// CSR Address Map
//------------------------------------------------------------------------------

localparam AFU_DFH       = 16'h0000;
localparam AFU_ID_L      = 16'h0008;
localparam AFU_ID_H      = 16'h0010;
localparam AFU_INIT      = 16'h0018;
localparam ETH_CTRL_ADDR = 16'h0020;
localparam ETH_WR_DATA   = 16'h0028;
localparam ETH_RD_DATA   = 16'h0030;
localparam AFU_SCRATCH   = 16'h0038;

//------------------------------------------------------------------------------
// Register PR <--> PR signals near interface before consuming it
//------------------------------------------------------------------------------

(* noprune *) logic [1:0]  pck_cp2af_pwrState_T1;
(* noprune *) logic        pck_cp2af_error_T1;

logic        pck_cp2af_softReset_T1;
t_if_ccip_Rx pck_cp2af_sRx_T1;
t_if_ccip_Tx pck_af2cp_sTx_T0;

ccip_interface_reg inst_green_ccip_interface_reg
(
    .pClk                   (pClk),
    .pck_cp2af_softReset_T0 (pck_cp2af_softReset),
    .pck_cp2af_pwrState_T0  (pck_cp2af_pwrState), 
    .pck_cp2af_error_T0     (pck_cp2af_error),    
    .pck_cp2af_sRx_T0       (pck_cp2af_sRx),      
    .pck_af2cp_sTx_T0       (pck_af2cp_sTx_T0), 
    
    .pck_cp2af_softReset_T1 (pck_cp2af_softReset_T1),
    .pck_cp2af_pwrState_T1  (pck_cp2af_pwrState_T1), 
    .pck_cp2af_error_T1     (pck_cp2af_error_T1),    
    .pck_cp2af_sRx_T1       (pck_cp2af_sRx_T1),      
    .pck_af2cp_sTx_T1       (pck_af2cp_sTx)    
);   
  
//------------------------------------------------------------------------------
// extracting/setting signals on CCIP interface structure 
//------------------------------------------------------------------------------

t_ccip_c0_ReqMmioHdr    cp2csr_MmioHdr;
logic                   cp2csr_MmioWrEn;
logic                   cp2csr_MmioRdEn;
t_ccip_mmioData         cp2csr_MmioDin; 
t_ccip_c2_RspMmioHdr    csr2cp_MmioHdr;
t_ccip_mmioData         csr2cp_MmioDout;
logic                   csr2cp_MmioDout_v;

always_comb
begin
    // Extract Cfg signals from C0 channel
    cp2csr_MmioHdr   = t_ccip_c0_ReqMmioHdr'(pck_cp2af_sRx_T1.c0.hdr);
    cp2csr_MmioWrEn  = pck_cp2af_sRx_T1.c0.mmioWrValid;
    cp2csr_MmioRdEn  = pck_cp2af_sRx_T1.c0.mmioRdValid;
    cp2csr_MmioDin   = pck_cp2af_sRx_T1.c0.data[CCIP_MMIODATA_WIDTH-1:0];
    // Setting Rsp signals to C2 channel
    pck_af2cp_sTx_T0                  = 'b0;
    pck_af2cp_sTx_T0.c2.hdr           = csr2cp_MmioHdr;
    pck_af2cp_sTx_T0.c2.data          = csr2cp_MmioDout;
    pck_af2cp_sTx_T0.c2.mmioRdValid   = csr2cp_MmioDout_v;
end

//------------------------------------------------------------------------------
// logic to capture eth_rd_data (coming from 100MHz domain)
//------------------------------------------------------------------------------

reg        read_d1;

always @(posedge pClkDiv4)
begin
    eth_ctrl_addr <= ctrl_addr;
    eth_wr_data   <= wr_data;
    init_start    <= afu_init[0];
    init_done_r   <= init_done;
    read_d1 <= eth_ctrl_addr[17];
    // RD command
    if (read_d1)
        rd_data <= eth_rd_data;
end

//------------------------------------------------------------------------------
// CSR registers 
//------------------------------------------------------------------------------

reg  [ 1:0] wr_extend;
reg  [ 1:0] rd_extend;

wire [15:0] csr_addr_4B = cp2csr_MmioHdr.address;
wire [14:0] csr_addr_8B = cp2csr_MmioHdr.address[15:1];

t_ccip_mmioData csr_rd_data;

always @(posedge pClk or posedge pck_cp2af_softReset_T1)
begin
    if (pck_cp2af_softReset_T1)
    begin
        afu_init    <= 'b0;
        ctrl_addr   <= 'b0;
        wr_data     <= 'b0;
        afu_scratch <= 'b0;
    end
    else
    begin
        if (cp2csr_MmioWrEn)
            case (csr_addr_8B[2:0])
                AFU_INIT     [5:3]: afu_init    <= cp2csr_MmioDin;
                ETH_CTRL_ADDR[5:3]: ctrl_addr   <= cp2csr_MmioDin[31:0];
                ETH_WR_DATA  [5:3]: wr_data     <= cp2csr_MmioDin[31:0];
                AFU_SCRATCH  [5:3]: afu_scratch <= cp2csr_MmioDin;           
                default: ;
            endcase
        if (&wr_extend) ctrl_addr[16] <= 1'b0;
        if (&rd_extend) ctrl_addr[17] <= 1'b0;
    end
end

always @(posedge pClk)
begin
    case (csr_addr_8B[2:0])
        AFU_DFH	     [5:3]: csr_rd_data <= 'h1000000000000001;	
// For E2E e10
`ifdef E2E_E10
        AFU_ID_L     [5:3]: csr_rd_data <= 'hB74F291AF34E1783;
        AFU_ID_H     [5:3]: csr_rd_data <= 'h05189FE40676DD24;
`endif
// For E2E e40
`ifdef E2E_E40
        AFU_ID_L     [5:3]: csr_rd_data <= 'hB3C151A1B62ED6C2;
        AFU_ID_H     [5:3]: csr_rd_data <= 'h26B40788034B4389;
`endif
        AFU_INIT     [5:3]: begin
                            csr_rd_data    <= afu_init;
                            csr_rd_data[1] <= init_done_r;
                            end
        ETH_CTRL_ADDR[5:3]: csr_rd_data <= 64'b0 | ctrl_addr;
        ETH_WR_DATA  [5:3]: csr_rd_data <= 64'b0 | wr_data;
        ETH_RD_DATA  [5:3]: csr_rd_data <= 64'b0 | rd_data;
        AFU_SCRATCH  [5:3]: csr_rd_data <= afu_scratch;
        default:            csr_rd_data <= 'h0000deadc0de0000;
    endcase
end

//------------------------------------------------------------------------------
// build the response signals for CCIP interface 
//------------------------------------------------------------------------------

logic           csr_ren_T1;
t_ccip_tid      csr_tid_T1;

always @(posedge pClk or posedge pck_cp2af_softReset_T1)
begin
    if (pck_cp2af_softReset_T1)
    begin
        csr_ren_T1        <= 1'b0;
        csr2cp_MmioDout_v <= 1'b0;
    end
    else
    begin
        // Pipe Stage T1
        csr_ren_T1 <= cp2csr_MmioRdEn;
        // Pipe Stage T2
        csr2cp_MmioDout_v <= csr_ren_T1;
    end
end    

always @(posedge pClk)
begin
    // Pipe Stage T1
    csr_tid_T1 <= cp2csr_MmioHdr.tid;
    // Pipe Stage T2
    csr2cp_MmioHdr      <= csr_tid_T1;
    csr2cp_MmioDout     <= csr_rd_data;
end    
    
// Pulse extenders for ETH CTRL RD/WR commands

always @(posedge pClk or posedge pck_cp2af_softReset_T1)
begin
    if (pck_cp2af_softReset_T1)
    begin
        wr_extend <= 'b0;
        rd_extend <= 'b0;
    end
    else
    begin
        wr_extend <= wr_extend + ctrl_addr[16];
        rd_extend <= rd_extend + ctrl_addr[17];
    end
end

endmodule
