// ***************************************************************************
// Copyright (c) 2013-2017, Intel Corporation All Rights Reserved.
// The source code contained or described herein and all  documents related to
// the  source  code  ("Material")  are  owned by  Intel  Corporation  or  its
// suppliers  or  licensors.    Title  to  the  Material  remains  with  Intel
// Corporation or  its suppliers  and licensors.  The Material  contains trade
// secrets and  proprietary  and  confidential  information  of  Intel or  its
// suppliers and licensors.  The Material is protected  by worldwide copyright
// and trade secret laws and treaty provisions. No part of the Material may be
// copied,    reproduced,    modified,    published,     uploaded,     posted,
// transmitted,  distributed,  or  disclosed  in any way without Intel's prior
// express written permission.
// ***************************************************************************
//
// Module Name:         hello_mem_afu.sv 
// Project:             Hello Memory AFU 
// Modified:            PSG - ADAPT
// Description:         Demonstrates simple transactions to DCP memory interface
//                      
// Hello_Mem_AFU is provided as as starting point for developing AFUs that 
// transact with the external memory interface (EMIF). It lets you trigger 
// transactions to EMIF using simple CCIP MMIO writes and reads. 
//
// It is strongly recommended: 
// - register all AFU inputs and outputs 
// - output registers should be initialized with a reset 
// - Host Writes and Reads must be sent on Virtual Channel (VC): VH0 - PCIe0 link
// - MMIO addressing must be QuardWord Aligned (Quadword = 8 bytes)
// - AFU_ID must be re-generated for new AFUs. 
//
// Scratch_Reg[63:0] @ Byte Address 0x0080 is provided to test MMIO Reads and Writes to the AFU. 
//
// Restrictions of Avalon memory interface (verify with Colleen)
// - operates with respect to 400 MHz clock 
// - only single bursts are currently supported
// - No response status is supported
// - No support for posted writes
// - Recommended to use lower [63:0] of data bus
//
//`default_nettype none
import ccip_if_pkg::*;
module hello_mem_afu #(
   parameter DDR_ADDR_WIDTH=26
) (
	// ---------------------------global signals-------------------------------------------------
  input	Clk_400,	  //Core clock. CCI interface is synchronous to this clock.
  input	SoftReset,	//CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH

	// ---------------------------IF signals between CCI and AFU  --------------------------------
	input	  t_if_ccip_Rx  cp2af_sRxPort,
	output	t_if_ccip_Tx	af2cp_sTxPort,

  // --------------------------- AMM signals 
	output	logic [511:0]   avs_writedata,     	
	input	  logic [63:0]    avs_readdata,     	
	output	logic [DDR_ADDR_WIDTH-1:0]    avs_address,       	
	input	  logic	          avs_waitrequest,   	
	output	logic           avs_write,        	
	output	logic           avs_read,         	
	output	logic [63:0]    avs_byteenable,   	
  output  logic [11:0]    avs_burstcount,
	input			              avs_readdatavalid,  
  input                   avs_writeresponsevalid, 
  input         [1:0]     avs_response,

  output logic mem_bank_select
);

  wire [63:0] avm_writedata, avm_readdata;
  wire mem_testmode;
  wire            ready_for_sw_cmd;

  wire [4:0]      addr_test_status;
  wire            addr_test_done; 

  wire [DDR_ADDR_WIDTH-1:0]     avm_address;
  wire [11:0]     avm_burstcount;
  wire [1:0]      avm_response;
  wire            avm_read;
  wire            avm_write;

  wire  [1:0]     rdwr_done;  
  wire  [4:0]     rdwr_status; 
  wire            rdwr_reset;

  logic [63:0]    avs_writedata_r;     
  logic [63:0]    avs_readdata_r;     	
  logic [DDR_ADDR_WIDTH-1:0]    avs_address_r;       
  logic	         avs_waitrequest_r;   
  logic           avs_write_r;        	
  logic           avs_read_r;         	
  logic [63:0]    avs_byteenable_r;   	
  logic [11:0]    avs_burstcount_r;
  logic           avs_writeresponsevalid_r; 
  logic           avs_readdatavalid_r;     	
  logic  [1:0]    avs_response_r; 
  
  mem_csr #(
    .DDR_ADDR_WIDTH         (DDR_ADDR_WIDTH)
  ) csr(
    .Clk_400                (Clk_400),
    .SoftReset              (SoftReset ),

    .cp2af_sRxPort          (cp2af_sRxPort),
    .af2cp_sTxPort          (af2cp_sTxPort), 

    .avm_address            (avm_address),
    .avm_write              (avm_write),
    .avm_read               (avm_read),
    .avm_burstcount         (avm_burstcount),
    .avm_readdata           (avm_readdata),
    .avm_response           (avm_response), 
    .avm_writedata          (avm_writedata),

    .mem_testmode           (mem_testmode),
    .addr_test_status       (addr_test_status), 
    .addr_test_done         (addr_test_done),
    .rdwr_done              (rdwr_done), 
    .rdwr_status            (rdwr_status), 
    .rdwr_reset             (rdwr_reset),
    .mem_bank_select        (mem_bank_select),
    .ready_for_sw_cmd       (ready_for_sw_cmd)
 );

  mem_fsm #(
    .DDR_ADDR_WIDTH         (DDR_ADDR_WIDTH)
  ) fsm (
    .pClk                   (Clk_400 ),
    .pck_cp2af_softReset    (SoftReset ),

     // AVL MM CSR Control Signals
    .avm_address            (avm_address),
    .avm_write              (avm_write),
    .avm_read               (avm_read),
    .avm_burstcount         (avm_burstcount),
    .avm_readdata           (avm_readdata),
    .avm_writedata          (avm_writedata),

    .mem_testmode           (mem_testmode),
    .addr_test_status       (addr_test_status),
    .addr_test_done         (addr_test_done),
    .rdwr_done              (rdwr_done), 
    .rdwr_status            (rdwr_status), 
    .rdwr_reset             (rdwr_reset),
    .ready_for_sw_cmd       (ready_for_sw_cmd),

     //AVL MM Master Interface
    .avs_writedata          ( avs_writedata_r ),      
    .avs_readdata           ( avs_readdata_r ),       
    .avs_address            ( avs_address_r ),        
    .avs_waitrequest        ( avs_waitrequest_r ),    
    .avs_write              ( avs_write_r ), 
    .avs_read               ( avs_read_r ),  
    .avm_response           ( avm_response),
    .avs_byteenable         ( avs_byteenable_r ),  
    .avs_burstcount         ( avs_burstcount_r),
    .avs_response           ( avs_response),
    .avs_readdatavalid      ( avs_readdatavalid_r),
    .avs_writeresponsevalid ( avs_writeresponsevalid_r) 
  );

  always @(posedge Clk_400) begin 
    avs_writedata            <= {448'd0, avs_writedata_r};      
    avs_address              <= avs_address_r;      
    avs_write                <= avs_write_r; 
    avs_read                 <= avs_read_r;  
    avs_byteenable           <= avs_byteenable_r;  
    avs_burstcount           <= avs_burstcount_r;
    avs_waitrequest_r        <= avs_waitrequest; 
    avs_readdata_r           <= avs_readdata[63:0];  
    avs_response_r           <= avs_response;
    avs_readdatavalid_r      <= avs_readdatavalid;
    avs_writeresponsevalid_r <= avs_writeresponsevalid; 
  end 
endmodule
