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
// Module Name:         afu.sv 
// Project:             Hello AFU 
// Modified:            PSG - ADAPT
// Description:         Hello AFU supports MMIO Writes and Reads for the DCP 0.5 Release. 
//                      
// Hello_AFU is provided as as starting point for developing AFUs with the dcp_0.5 release for MMIO 
// Writes and Reads. 
//
// It is strongly recommended: 
// - register all AFU inputs and outputs 
// - output registers should be initialized with a reset 
// - Host Writes and Reads must be sent on Virtual Channel (VC): VH0 - PCIe0 link
// - MMIO addressing must be QuardWord Aligned (Quadword = 8 bytes)
// - AFU_ID must be re-generated for new AFUs. 
//
// Please see the CCI-P specification for more information about the CCI-P interfaces.
// AFU template provides 4 AFU CSR registers required by the CCI-P protocol(see 
// specification for more information) and a scratch register to issue MMIO Writes and Reads. 
//
// Scratch_Reg[63:0] @ Byte Address 0x0080 is provided to test MMIO Reads and Writes to the AFU. 
//
// Please see the Avalon MM specification with respect to the Quartus 16.0 Release for more information. 
// Avalon MM Interface for dcp_0.5: 
// - operates with respect to 400 MHz clock 
// - only single bursts are currently supported
// - No response status is supported
// - No support for posted writes
// - Recommended to use lower [63:0] of data bus
`default_nettype none
import ccip_if_pkg::*;
module avlmm_config_afu (     
	// ---------------------------global signals-------------------------------------------------
        input	Clk_400,	  //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
        input	SoftReset,	  //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH
	// ---------------------------IF signals between CCI and AFU  --------------------------------
	input	t_if_ccip_Rx    cp2af_sRxPort,
	output	t_if_ccip_Tx	af2cp_sTxPort,

        // --------------------------- AMM signals 
	output	logic [511:0]    avs_writedata,     	//          .writedata
	input	logic [63:0]    avs_readdata,     	//          .readdata
	output	logic [25:0]    avs_address,       	//          .address
	input	logic	        avs_waitrequest,   	//          .waitrequest
	output	logic           avs_write,        	//          .write
	output	logic           avs_read,         	//          .read
	output	logic [63:0]    avs_byteenable,   	//          .byteenable
        output  logic [11:0]    avs_burstcount,
	input			avs_readdatavalid,     	//          .readdatavalid
        input                   avs_writeresponsevalid, 
        input         [1:0]     avs_response,

   output logic mem_bank_select
);

   wire [63:0] avm_writedata, avm_readdata;
   wire mem_testmode;
   wire  [4:0] addr_test_status;
   wire [25:0] avm_address;
   wire [11:0] avm_burstcount;
   wire [1:0]  avm_response;
   wire        addr_test_done; 
   wire  [1:0] rdwr_done;  
   wire  [4:0] rdwr_status; 
   wire        rdwr_reset;
   logic [63:0]    avs_writedata_r;     	//          .writedata
   logic [63:0]    avs_readdata_r;     	//          .readdata
   logic [25:0]    avs_address_r;       	//          .address
   logic	   avs_waitrequest_r;   	//          .waitrequest
   logic           avs_write_r;        	//          .write
   logic           avs_read_r;         	//          .read
   logic [63:0]    avs_byteenable_r;   	//          .byteenable
   logic [11:0]    avs_burstcount_r;
   logic           avs_writeresponsevalid_r; 
   logic           avs_readdatavalid_r;     	//          .readdatavalid
   logic  [1:0]    avs_response_r; 
   wire            avm_read;
   wire            avm_write;
   
   mem_csr csr(
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
      .mem_bank_select        (mem_bank_select)
 );

  mem_fsm fsm (
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
     //if (~avs_waitrequest) begin 
         avs_writedata          <= {448'd0, avs_writedata_r};      
         avs_address            <= avs_address_r;      
         avs_write              <= avs_write_r; 
         avs_read               <= avs_read_r;  
         avs_byteenable         <= avs_byteenable_r;  
         avs_burstcount         <= avs_burstcount_r;
      //end 
      avs_waitrequest_r       <= avs_waitrequest; 
      avs_readdata_r          <= avs_readdata[63:0];  
      avs_response_r          <= avs_response;
      avs_readdatavalid_r      <= avs_readdatavalid;
      avs_writeresponsevalid_r <= avs_writeresponsevalid; 
  end 
endmodule
