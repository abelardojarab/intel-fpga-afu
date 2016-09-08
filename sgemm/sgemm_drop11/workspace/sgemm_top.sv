// ***************************************************************************
//
//        Copyright (C) 2008-2012 Intel Corporation All Rights Reserved.
//
// Engineer:            Pratik Marolia
// Create Date:         Tue Feb 21 17:18:22 PDT 2012
// Edited on:           Thurs Oct 29 11:28:01 PDT 2015
// Module Name:         nlb_lpbk.v
// Project:             NLB_400 AFU
//                      Compliant with CCI-P spec v0.58
// Description:         top level wrapper for NLB, it instantiates requestor
//                      & arbiter
// ***************************************************************************
//
// Change Log
// Date             Comments
// 7/2/2014         Supports extended 64KB CSR space. Remapped all NLB CSRs
//
// ---------------------------------------------------------------------------------------------------------------------------------------------------
//                                         NLB - Native Loopback test
//  ------------------------------------------------------------------------------------------------------------------------------------------------
//
// This is a reference CCI-S AFU implementation compatible with CCI specification v2.10
// The purpose of this design is to generate different memory access patterns for validation.
// The test can also be used to measure following performance metrics:
// Bandwidth: 100% Read, 100% Write, 50% Read + 50% Write
// Latency: Read, Write
//
//   Block Diagram:
//
//   +------------------------------------------------------------------+                       
//   |    +----------+           +---------+      +------------+        |                           
//   |    |          |  Wr       |         |<---->| Test_lpbk1 |        |                           
//  CCI-S |Requestor |<--------->| Arbiter |<--+  +------------+        |                            
// <----->|          |  Rd       |/Selector|<+ |  +------------+        |                       
//   |    |          |<--------->|         | | +->|Test_rdwr   |        |                       
//   |    +----------+           +---------+ |    +------------+        |                       
//   |                                    /\ |    +------------+        |               
//   |                                    |  +--->| Test_lpbk2 |        |
//   |                                    |       +------------+        |
//   |                                    |       +------------+        |                       
//   |                                    ------->| Test_lpbk3 |        |
//   |                                    |       +------------+        |
//   |                                    |       +------------+        |                       
//   |                                    ------->| Test_SW1   |        |
//   | nlb_lpbk                                   +------------+        |
//   +------------------------------------------------------------------+
//
//
//  NLB Revision and feature tracking
//-------------------------------------------------------------------------------------------
//      Rev     CCI spec        Comments
//-------------------------------------------------------------------------------------------
//      1.0     0.9             Uses proprietary memory mapped CSR read mapping
//      1.1     2.0             Device Status Memory Compliant
//      1.2     CCI-P v0.58     Updates to CCI-P spec
//
// CSR Address Map
//------------------------------------------------------------------------------------------
// Byte Address       Attribute         Name                 Width   Comments
//     'h0000          RO                DFH                 64b     AFU Device Feature Header
//     'h0008          RO                AFU_ID_L            64b     AFU ID low 64b
//     'h0010          RO                AFU_ID_H            64b     AFU ID high 64b
//     'h0018          RsvdZ             CSR_DFH_RSVD0       64b     Mandatory Reserved 0
//     'h0020          RO                CSR_DFH_RSVD1       64b     Mandatory Reserved 1
//     'h0100          RW                CSR_SCRATCHPAD0     64b     Scratchpad register 0
//     'h0108          RW                CSR_SCRATCHPAD0     64b     Scratchpad register 2
//     'h0110          RW                CSR_AFU_DSM_BASEL   32b     Lower 32-bits of AFU DSM base address. The lower 6-bbits are 4x00 since the address is cache aligned.
//     'h0114          RW                CSR_AFU_DSM_BASEH   32b     Upper 32-bits of AFU DSM base address.
//     'h0120:         RW                CSR_SRC_ADDR        64b     Start physical address for source buffer. All read requests are targetted to this region.
//     'h0128:         RW                CSR_DST_ADDR        64b     Start physical address for destination buffer. All write requests are targetted to this region.
//     'h0130:         RW                CSR_NUM_LINES       32b     Number of cache lines
//     'h0138:         RW                CSR_CTL             32b     Controls test flow, start, stop, force completion
//     'h0140:         RW                CSR_CFG             32b     Configures test parameters
//     'h0148:         RW                CSR_INACT_THRESH    32b     inactivity threshold limit
//     'h0150          RW                CSR_INTERRUPT0      32b     SW allocates Interrupt APIC ID & Vector to device
//     
//
// DSM Offeset Map
// ***CCIP v0.6*** Note DSM is NOT mandatory. User can still define a workspace and use it for DSM.
//------------------------------------------------------------------------------------------
//      Byte Offset   Attribute         Name                  Comments
//      0x40          RO                DSM_STATUS            test status and error register
//
//
// 1 Cacheline = 64B i.e 2^6 Bytes
// Let N be the number of cachelines in the source & destination buffers. Then select CSR_SRC_ADDR & CSR_DEST_ADDR to be 2^(N+6) aligned.
// CSR_NUM_LINES should be less than or equal to N.
//
// CSR_SRC_ADDR:
// [63:N]   RW   2^(N+6)MB aligned address points to the start of read buffer
// [N-1:0]  RW   'h0
//
// CSR_DST_ADDR:
// [63:N]   RW   2^(N+6)MB aligned address points to the start of write buffer
// [N-1:0]  RW   'h0
//
// CSR_NUM_LINES:
// [31:N]   RW   'h0
// [N-1:0]  RW    # cache lines to be read/written to. This threshold may be different for each test AFU. IMPORTANT- Ensure that source and destination buffers 
//              are large enough to accomodate the N cache lines.
//
// Let's assume N=14, then CSR_SRC_ADDR and CSR_DST_ADDR will accept a 2^20, i.e. 1MB aligned addresses.
//
// CSR_SRC_ADDR:
// [31:14]  RW    1MB aligned address
// [13:0]   RW   'h0
//
// CSR_DST_ADDR:
// [31:14]  RW    1MB aligned address
// [13:0]   RW   'h0
//
// CSR_NUM_LINES:
// [31:16]  RW    'h0
// [15:0]   RW    # cache lines to be read/written to. This threshold may be different for each test AFU. IMPORTANT- Ensure that source and destination buffers 
//              are large enough to accomodate the # cache lines.
//
// CSR_CTL:
// [31:3]   RW    Rsvd
// [2]      RW    Force test completion. Writes test completion flag and other performance counters to csr_stat. It appears to be like a normal test completion.
// [1]      RW    Starts test execution.
// [0]      RW    Active low test Reset. All configuration parameters change to reset defaults.
//
//
// CSR_CFG:
// [29]     RW    cr_interrupt_testmode - used to test interrupt. Generates an interrupt at end of each test.
// [28]     RW    cr_interrupt_on_error - send an interrupt when error detected
// [27:20]  RW    cr_test_cfg  -may be used to configure the behavior of each test mode
// [13:12]  RW    cr_chsel     -select virtual channel
// [10:9]   RW    cr_rdsel     -configure read request type. 0- RdLine_S, 1- RdLine_I, 2- RdLine_O, 3- Mixed mode
// [8]      RW    cr_delay_en  -enable random delay insertion between requests
// [4:2]    RW    cr_mode      -configures test mode
// [1]      RW    cr_cont      - 1- test rollsover to start address after it reaches the CSR_NUM_LINES count. Such a test terminates only on an error.
//                               0- test terminates, updated the status csr when CSR_NUM_LINES count is reached.
// [0]      RW    cr_wrthru_en -switch between WrLine_I & WrLine_M  request types. 
//                              0- WrLine_M
//                              1- WrLine_I
//
// CSR_INACT_THRESHOLD:
// [31:0]   RW  inactivity threshold limit. The idea is to detect longer duration of stalls during a test run. Inactivity counter will count number of consecutive idle cycles,
//              i.e. no requests are sent and no responses are received. If the inactivity count > CSR_INACT_THRESHOLD then it sets the inact_timeout signal. The inactivity counter
//              is activated only after test is started by writing 1 to CSR_CTL[1].
//
// CSR_INTERRUPT0:
// [23:16]  RW    vector      - Interrupt Vector # for the device
// [15:0]   RW    apic id     - Interrupt APIC ID for the device 
//
// DSM_STATUS:
// [511:256] RO  Error dump from Test Mode
// [255:224] RO  end overhead
// [223:192] RO  start overhead
// [191:160] RO  Number of writes
// [159:128] RO  Number of reads
// [127:64]  RO  Number of clocks
// [63:32]   RO  test error register
// [31:0]    RO  test completion flag
//
// High Level Test flow:
//---------------------------------------------------------------
// 1.   SW Reads DFH at AFU offset 0x0
// 2.   SW REad AFU ID at offset 0x8 & 0x10
// 3.   SW initalizes Device Status Memory (DSM) to zero.
// 4.   SW writes DSM BASE address to AFU. CSR Write(DSM_BASE_H), CSR Write(DSM_BASE_L)
// 5.   SW prepares source & destination memory buffer- this is test specific.
// 4.   SW CSR Write(CSR_CTL)=3'h1. This brings the test out of reset and puts it in configuration mode. Configuration is allowed only when CSR_CTL[0]=1 & CSR_CTL[1]=0.
// 5.   SW configures the test parameters, i.e. src/dest address, csr_cfg, num lines etc. 
// 6.   SW CSR Write(CSR_CTL)=3'h3. AFU begins test execution.
// 7.   Test completion:
//      a. HW completes- When the test completes or detects an error, the HW AFU writes to DSM_STATUS. SW is polling on DSM_STATUS[31:0]==1.
//      b. SW forced completion- The SW forces a test completion, CSR Write(CSR_CTL)=3'h7. HW AFU writes to DSM_STATUS.
//      The test completion method used depends on the test mode. Some test configuration have no defined end state. When using continuous mode, you must use 7.b. 
//                              
// Test modes:
//---------------------------------------------------------------
//      Test Mode       Encoding- CSR_CFG[4:2]        #cache line threshold- CSR_NUM_LINES[N-1:0]       #cache line threshold for N=14
//      --------------------------------------------------------------------------------------------------------------------------------------
// 1.     LPBK1         3'b000                          2^N                                             14'h3fff
// 2.     READ          3'b001                          2^N                                             14'h3fff
// 3.     WRITE         3'b010                          2^N                                             14'h3fff
// 4.     TRPUT         3'b011                          2^N                                             14'h3fff
// 5.     LPBK2         3'b101                          smaller of 2^N or 14'h80                        14'h80
// 6.     LPBK3         3'b110                          smaller of 2^(N-16) or 14'h80                   14'h10
// 7.     SW1           3'b111                          2^N                                             14'h3ffe
//
// 1. LPBK1:
// This is a memory copy test. AFU copies CSR_NUM_LINES from source buffer to destination buffer. On test completion, the software compares the source and destination buffers.
//
// 2. READ:
// This is a read only test with NO data checking. AFU reads CSR_NUM_LINES starting from CSR_SRC_ADDR. This test is used to stress the read path and 
// measure 100% read bandwidth or latency.
//
// 3. WRITE:
// This is a write only test with NO data checking. AFU writes CSR_NUM_LINES starting from CSR_DST_ADDR location. This test is used to stress the write path and
// measure 100% write bandwidth or latency.
// 
// 4. TRPUT:
// This test combines the read and write streams. There is NO data checking and no dependency between read & writes. It reads CSR_NUM_LINES starting from CSR_SRC_ADDR location and 
// writes CSR_NUM_LINES to CSR_DST_ADDR. It is also used to measure 50% Read + 50% Write bandwdith.
//
// 5. LPBK2: -- DEFEATURED --
// This is a cache coherency test, both CPU and Test are fighting for the same set of cache lines. 
// Upper Limit on # cache lines (CSR_NUM_LINES) = 128
// For this test set CSR_SRC_ADDR= CSR_DST_ADDR, because to test coherency we would like to read and write same set of addresses.
// This test will read CSR_NUM_LINES starting from CSR_SRC_ADDR but it will write to only half of those cache lines.
//
// A. Lets classify the cache lines into two sets, ones that can be owned by FPGA and ones that can be owned by CPU.
// cacheline address[0] = 1- Line is owned by FPGA
// cacheline address[0] = 0- Line is owned by CPU
//
// B. Also lets divide the cache data into two fields: deterministic and random data fields.
// Determinitistic data fields: data[31:0] = data[256+31:256]
// Random data fields: data[255:32] & data [511:288]
//
// C. Rules of the game:
//   1. Both agents, FPGA and CPU can read all cache lines.
//   2. A cache line can only be written by its owner as determined by section A above. The agent must write the cache line address to deterministic data fields. The random data
//      fields can ofcourse be random.
//   3. Reading owned lines - An agent reading owned lines must check the deterministic data fields and full or part of the random fields.
//      Reading not owned lines - An agent reading these lines, must only check the deterministic data fields.
//      If error is detected then set the errorvalid signal and send out the error report. Look at the test modules for details on error report.
//
// This test must be used in cont mode. The test ends only when it detects an error or it is stopped using csr_ctl.
//
// 6. LPBK3: -- DEFEATURED--
// This test is identical to LPBK2 test with two exceptions:
// 1. This test uses only those cache lines that maps to set 0 only. For example, if CSR_SRC_ADDR='hf000 and CSR_NUM_LINES='h4 then it will select cache lines:
//   'hf000 + 'h0*'h400 = 'hf000
//   'hf000 + 'h1*'h400 = 'hf400
//   'hf000 + 'h2*'h400 = 'hf800
//   'hf000 + 'h3*'h400 = 'hfc00
//
// *Note that you select large enough memory space to accomodate CSR_NUM_LINES.
// 2. The ownership classification is based of address bit [10] instead of address bit[0] in lpbk2.
//   cacheline address[10] = 1- Line is owned by FPGA
//   cacheline address[10] = 0- Line is owned by CPU
// 
// The test rules and other constraints are same as LPBK2. 
//
// 7. SW1:
// This test measures the full round trip data movement latency between CPU & FPGA. 
// The test can be configured to use different 4 different CPU to FPGA messaging methods- 
//      a. polling from AFU
//      b. UMsg without Data
//      c. UMsg with Data
//      d. CSR Write
// test flow:
// 1. Wait on test_go
// 2. Start timer. Write N cache lines. WrData= {16{32'h0000_0001}}
// 3. Write Fence.
// 4. FPGA -> CPU Message. Write to address N+1. WrData = {{14{32'h0000_0000}},{64{1'b1}}}
// 5. CPU -> FPGA Message. Configure one of the following methods:
//   a. Poll on Addr N+1. Expected Data [63:32]==32'hffff_ffff
//   b. CSR write to Address 0xB00. Data= Dont Care
//   c. UMsg Mode 0 (with data). UMsg ID = 0
//   d. UMsgH Mode 1 (without data). UMsg ID = 0
// 7. Read N cache lines. Wait for all read completions.
// 6. Stop timer Send test completion.
//


import ccip_if_pkg::*;
module sgemm_top #(parameter TXHDR_WIDTH=61, RXHDR_WIDTH=18, DATA_WIDTH =512)
(
                
       // ---------------------------global signals-------------------------------------------------
       Clk_16UI,                         //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
       SoftReset_n,                      //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset.
       SystemReset_n,                    //                    std_logic:           System Reset signal. To be used for sticy CSRs & HSSI interface only
       // ---------------------------IF signals between CCI and AFU  --------------------------------
       ci2cf_sRxPort,
       cf2ci_sTxPort
);


   input                        Clk_16UI;             //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
   input                        SoftReset_n;          //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset.
   input                        SystemReset_n;        //                    std_logic:           System Reset signal. To be used for sticy CSRs & HSSI interface only

   input  t_if_ccip_Rx          ci2cf_sRxPort;
   output t_if_ccip_Tx          cf2ci_sTxPort;

   localparam      PEND_THRESH = 7;
   localparam      ADDR_LMT    = 20;
   localparam      MDATA       = 'd11;
   //--------------------------------------------------------
   // Test Modes
   //--------------------------------------------------------
   localparam              M_LPBK1         = 3'b000;
   localparam              M_READ          = 3'b001;
   localparam              M_WRITE         = 3'b010;
   localparam              M_TRPUT         = 3'b011;
   localparam              M_LPBK2         = 3'b101;
   localparam              M_LPBK3         = 3'b110;
   //--------------------------------------------------------
   
   wire                         Clk_16UI;
   wire                         SoftReset_n;

   t_if_ccip_Tx                 cf2ci_sTxPort_c;

  
   wire [ADDR_LMT-1:0]          ab2re_WrAddr;
   wire [15:0]                  ab2re_WrTID;
   wire [DATA_WIDTH -1:0]       ab2re_WrDin;
   wire                         ab2re_WrFence;
   wire                         ab2re_WrEn;
   wire                         re2ab_WrSent;
   wire                         re2ab_WrAlmFull;
   wire [ADDR_LMT-1:0]          ab2re_RdAddr;
   wire [15:0]                  ab2re_RdTID;
   wire                         ab2re_RdEn;
   wire                         re2ab_RdSent;
   wire                         re2ab_RdRspValid;
   wire                         re2ab_UMsgValid;
   wire                         re2ab_CfgValid;
   wire [15:0]                  re2ab_RdRsp;
   wire [DATA_WIDTH -1:0]       re2ab_RdData;
   wire                         re2ab_stallRd;
   wire                         re2ab_WrRspValid;
   wire [15:0]                  re2ab_WrRsp;
   wire                         re2xy_go;
   wire [31:0]                  re2xy_src_addr;
   wire [31:0]                  re2xy_dst_addr;
   wire [31:0]                  re2xy_NumLines;
   wire                         re2xy_Cont;
   wire [7:0]                   re2xy_test_cfg;
   wire [2:0]                   re2ab_Mode;
   wire                         ab2re_TestCmp;
   wire [255:0]                 ab2re_ErrorInfo;
   wire                         ab2re_ErrorValid;
   
   wire                         test_SoftReset_n;
   wire  [63:0]                 cr2re_src_address;
   wire  [63:0]                 cr2re_dst_address;
   wire  [31:0]                 cr2re_num_lines;
   wire  [31:0]                 cr2re_inact_thresh;
   wire  [31:0]                 cr2re_interrupt0;
   wire  [31:0]                 cr2re_cfg;
   wire  [31:0]                 cr2re_ctl;
   wire  [63:0]                 cr2re_dsm_base;
   wire                         cr2re_dsm_base_valid;
   wire                         re2cr_wrlock_n;
   wire                         cr2s1_csr_write;

   reg                          SoftReset_qn=0;
   always @(posedge Clk_16UI)
   begin
       SoftReset_qn <= SoftReset_n;
   end
requestor #(.PEND_THRESH(PEND_THRESH),
            .ADDR_LMT   (ADDR_LMT),
            .TXHDR_WIDTH(TXHDR_WIDTH),
            .RXHDR_WIDTH(RXHDR_WIDTH),
            .DATA_WIDTH (DATA_WIDTH )
            )
inst_requestor(
//      ---------------------------global signals-------------------------------------------------
       Clk_16UI               ,        //                       in    std_logic;  -- Core clock
       SoftReset_qn                 ,        //                       in    std_logic;  -- Use SPARINGLY only for control
//      ---------------------------CCI IF signals between CCI and requestor  ---------------------
       cf2ci_sTxPort_c,
       ci2cf_sRxPort,

       cr2re_src_address,
       cr2re_dst_address,
       cr2re_num_lines,
       cr2re_inact_thresh,
       cr2re_interrupt0,
       cr2re_cfg,
       cr2re_ctl,
       cr2re_dsm_base,
       cr2re_dsm_base_valid,

       ab2re_WrAddr,                   // [ADDR_LMT-1:0]        arbiter:        Writes are guaranteed to be accepted
       ab2re_WrTID,                    // [15:0]                arbiter:        meta data
       ab2re_WrDin,                    // [DATA_WIDTH -1:0]     arbiter:        Cache line data
       ab2re_WrFence,                  //                       arbiter:        write fence
       ab2re_WrEn,                     //                       arbiter:        write enable
       re2ab_WrSent,                   //                       arbiter:        write issued
       re2ab_WrAlmFull,                //                       arbiter:        write fifo almost full
       
       ab2re_RdAddr,                   // [ADDR_LMT-1:0]        arbiter:        Reads may yield to writes
       ab2re_RdTID,                    // [15:0]                arbiter:        meta data
       ab2re_RdEn,                     //                       arbiter:        read enable
       re2ab_RdSent,                   //                       arbiter:        read issued

       re2ab_RdRspValid,               //                       arbiter:        read response valid
       re2ab_UMsgValid,                //                       arbiter:        UMsg valid
       re2ab_CfgValid,                 //                       arbiter:        Cfg Valid
       re2ab_RdRsp,                    // [ADDR_LMT-1:0]        arbiter:        read response header
       re2ab_RdData,                   // [DATA_WIDTH -1:0]     arbiter:        read data
       re2ab_stallRd,                  //                       arbiter:        stall read requests FOR LPBK1

       re2ab_WrRspValid,               //                       arbiter:        write response valid
       re2ab_WrRsp,                    // [ADDR_LMT-1:0]        arbiter:        write response header
       re2xy_go,                       //                       requestor:      start the test
       re2xy_NumLines,                 // [31:0]                requestor:      number of cache lines
       re2xy_Cont,                     //                       requestor:      continuous mode
       re2xy_src_addr,                 // [31:0]                requestor:      src address
       re2xy_dst_addr,                 // [31:0]                requestor:      destination address
       re2xy_test_cfg,                 // [7:0]                 requestor:      8-bit test cfg register.
       re2ab_Mode,                     // [2:0]                 requestor:      test mode
       
       ab2re_TestCmp,                  //                       arbiter:        Test completion flag
       ab2re_ErrorInfo,                // [255:0]               arbiter:        error information
       ab2re_ErrorValid,               //                       arbiter:        test has detected an error
       test_SoftReset_n,               //                       requestor:      rest the app
       re2cr_wrlock_n                  //                       requestor:      when low, block csr writes
);


/*
arbitrer_sgemm				#(
.PEND_THRESH	(PEND_THRESH),
.ADDR_LMT		(ADDR_LMT),
.MDATA   		(MDATA)
)
ARBITER_INST
(		.clk_16UI						(Clk_16UI),
		.Resetb							(SoftReset_qn),
		//Write Interface	            
		.ab2re_WrAddr					(ab2re_WrAddr),
		.ab2re_WrTID					(ab2re_WrTID),
		.ab2re_WrDin					(ab2re_WrDin),
		.ab2re_WrFence					(ab2re_WrFence),
		.ab2re_WrEn						(ab2re_WrEn),
		.re2ab_WrSent					(re2ab_WrSent),
		.re2ab_WrAlmFull				(re2ab_WrAlmFull),
		//Read Interface	            			                            
		.ab2re_RdAddr					(ab2re_RdAddr),
		.ab2re_RdTID					(ab2re_RdTID),
		.ab2re_RdEn						(ab2re_RdEn),
		.re2ab_RdSent					(re2ab_RdSent),
		//Rd Interface Control Signals  
		.re2ab_RdRspValid				(re2ab_RdRspValid),
		.re2ab_RdRsp					(re2ab_RdRsp),
		.re2ab_RdData					(re2ab_RdData),
		.re2ab_stallRd					(re2ab_stallRd),
		//Wr Interface Control Signals  
		.re2ab_WrRspValid				(re2ab_WrRspValid),
		.re2ab_WrRsp					(re2ab_WrRsp),
		//Other Control Signals	        
		.re2xy_go						(re2xy_go),
		.re2xy_NumLines					(re2xy_NumLines),
		.re2xy_Cont						(re2xy_Cont),		                                
		//PE output control signals     		                                
		.ab2re_TestCmp					(ab2re_TestCmp),
		.ab2re_ErrorInfo				(ab2re_ErrorInfo),
		.ab2re_ErrorValid				(ab2re_ErrorValid),
		.pe_reset                       (cr2s1_csr_write)
);
*/
wire l12ab_a_b_workspace_sel;
wire  l12ab_dst_workspace_sel;
sgemm_dp_controller			#
(
.PEND_THRESH	(PEND_THRESH),
.ADDR_LMT		(ADDR_LMT),
.MDATA			(MDATA)
)
(	.Clk_16UI					(clk_16UI),         
	.Resetb						(SoftReset_qn),//(Resetb),          
	.l12ab_WrAddr				(ab2re_WrAddr),//(l12ab_WrAddr),    
	.l12ab_WrTID				(ab2re_WrTID),//(l12ab_WrTID),     
	.l12ab_WrDin				(ab2re_WrDin),//(l12ab_WrDin),     
	.l12ab_WrEn					(ab2re_WrEn),//(l12ab_WrEn),
	.l12ab_WrFence				(ab2re_WrFence),//(l12ab_WrFence),
	.ab2l1_WrSent				(re2ab_WrSent),//(re2ab_WrSent),    
	.ab2l1_WrAlmFull			(re2ab_WrAlmFull),//(ab2l1_WrAlmFull), 
	.l12ab_RdAddr				(ab2re_RdAddr),//(l12ab_RdAddr),    
	.l12ab_RdTID				(ab2re_RdTID),//(l12ab_RdTID),     
	.l12ab_RdEn					(ab2re_RdEn),//(l12ab_RdEn),      
	.ab2l1_RdSent				(re2ab_RdSent),//(ab2l1_RdSent),    
	.ab2l1_RdRspValid			(re2ab_RdRspValid),//(ab2l1_RdRspValid),
	.ab2l1_RdRsp				(re2ab_RdRsp),//(ab2l1_RdRsp),     
	.ab2l1_RdRspAddr			(),//(ab2l1_RdRspAddr), 
	.ab2l1_RdData				(re2ab_RdData),//(ab2l1_RdData),    
	.ab2l1_stallRd				(re2ab_stallRd),//(ab2l1_stallRd),   
	.ab2l1_WrRspValid			(re2ab_WrRspValid),//(ab2l1_WrRspValid),
	.ab2l1_WrRsp				(re2ab_WrRsp),//(ab2l1_WrRsp),     
	.ab2l1_WrRspAddr			(),//(ab2l1_WrRspAddr), 
	.re2xy_go					(re2xy_go),        
	.re2xy_NumLines				(re2xy_NumLines),  
	.re2xy_Cont					(re2xy_Cont),      
	.l12ab_TestCmp				(ab2re_TestCmp),//(l12ab_TestCmp),
	.l12ab_a_b_workspace_sel	(l12ab_a_b_workspace_sel),//(l12ab_a_b_workspace_sel),
	.l12ab_dst_workspace_sel	(l12ab_dst_workspace_sel),//(l12ab_dst_workspace_sel),
	.l12ab_ErrorInfo			(ab2re_ErrorInfo),//(l12ab_ErrorInfo), 
	.l12ab_ErrorValid			(ab2re_ErrorInfo),//(l12ab_ErrorValid),
	.test_Resetb            	(cr2s1_csr_write)//(pe_reset)
);


logic [31:0]                cr2cf_CfgHeader;
logic                       cr2cf_CfgWrEn;
logic                       cr2cf_CfgRdEn;
logic [63:0]                cr2cf_CfgDin; 
logic [63:0]                cf2cr_CfgDout;
logic                       cf2cr_CfgDout_v;
logic [8:0]                 cf2cr_CfgHeader;
 
always_comb
begin
    cr2cf_CfgHeader     = ci2cf_sRxPort.C0Hdr;
    cr2cf_CfgWrEn       = ci2cf_sRxPort.C0MmioWrValid;
    cr2cf_CfgRdEn       = ci2cf_sRxPort.C0MmioRdValid;
    cr2cf_CfgDin        = ci2cf_sRxPort.C0Data[CCIP_MMIODATA_WIDTH-1:0];

    cf2ci_sTxPort                  = cf2ci_sTxPort_c;
    // Override the C2 channel
    cf2ci_sTxPort.C2Hdr            = cf2cr_CfgHeader;
    cf2ci_sTxPort.C2Data           = cf2cr_CfgDout;
    cf2ci_sTxPort.C2MmioRdValid    = cf2cr_CfgDout_v;
end

sgemm_csr # (.CCIP_VERSION_NUMBER(CCIP_VERSION_NUMBER))
inst_sgemm_csr (
    Clk_16UI,                       //                              clk_pll:    16UI clock
    SystemReset_n,                  //                              rst:        active low system reset
    SoftReset_qn,                   //                              rst:        active low soft reset
    re2cr_wrlock_n,
    // * CFG interface
    cr2cf_CfgHeader,
    cr2cf_CfgDin,  
    cr2cf_CfgWrEn,
    cr2cf_CfgRdEn,

    cf2cr_CfgHeader,  
    cf2cr_CfgDout,   
    cf2cr_CfgDout_v,

    cr2re_src_address,
	cr2re_src_address_b,
    cr2re_dst_address,
    cr2re_num_lines,
    cr2re_inact_thresh,
    cr2re_interrupt0,
    cr2re_cfg,
    cr2re_ctl,
    cr2re_dsm_base,
    cr2re_dsm_base_valid,
    cr2s1_csr_write
);


endmodule
