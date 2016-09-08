`define SIM_MODE
import ccip_if_pkg::*;

module nlb_lpbk #(parameter TXHDR_WIDTH=61, RXHDR_WIDTH=18, DATA_WIDTH =512,
                  parameter MPF_DFH_MMIO_ADDR = 0)
(                
       // ---------------------------global signals-------------------------------------------------
       Clk_400,                         //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
       SoftReset,                        //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH
       // ---------------------------IF signals between CCI and AFU  --------------------------------
       cp2af_sRxPort,
       af2cp_sTxPort
);
   input                        Clk_400;             //              in    std_logic;           Core clock. CCI interface is synchronous to this clock.
   input                        SoftReset;            //              in    std_logic;           CCI interface reset. The Accelerator IP must use this Reset. ACTIVE HIGH
   input  t_if_ccip_Rx          cp2af_sRxPort;
   output t_if_ccip_Tx          af2cp_sTxPort;

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
   
   wire                         Clk_400;
   wire                         SoftReset;

   t_if_ccip_Tx                 af2cp_sTxPort_c;
  
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
   wire [31:0]                  re2xy_NumBlocks;
   wire [31:0]                  re2xy_NumPartsA;
   wire [31:0]                  re2xy_NumPartsB;   
   wire                         re2xy_Cont;
   wire [7:0]                   re2xy_test_cfg;
   wire [2:0]                   re2ab_Mode;
   wire                         ab2re_TestCmp;
   wire [255:0]                 ab2re_ErrorInfo;
   wire                         ab2re_ErrorValid;  
   wire                         test_SoftReset;
   wire  [63:0]                 cr2re_src_address;
   wire	 [63:0]					cr2re_src_address_b;
   wire  [63:0]                 cr2re_dst_address;
   wire	 [63:0]					cr2re_dst_address_c;
   wire  [31:0]                 cr2re_num_blocks;
   wire  [31:0]                 cr2re_num_parts_a;
   wire  [31:0]                 cr2re_num_parts_b;
   wire  [31:0]                 cr2re_inact_thresh;
   wire  [31:0]                 cr2re_interrupt0;
   wire  [31:0]                 cr2re_cfg;
   wire  [31:0]                 cr2re_ctl;
   wire  [63:0]                 cr2re_dsm_base;
   wire                         cr2re_dsm_base_valid;
   wire                         re2cr_wrlock_n;
   wire                         cr2s1_csr_write;
   
   logic                        ab2re_RdSop;
   logic [1:0]                  ab2re_WrLen;
   logic [1:0]                  ab2re_RdLen;
   logic                        ab2re_WrSop;                                
   logic                        re2ab_RdRspFormat;
   logic [1:0]                  re2ab_RdRspCLnum;
   logic                        re2ab_WrRspFormat;
   logic [1:0]                  re2ab_WrRspCLnum;
   logic [1:0]                  re2xy_multiCL_len;
	
   reg                          SoftReset_q=1'b1;
   always @(posedge Clk_400)
   begin
       SoftReset_q <= SoftReset;
   end

requestor			 #
(
	.PEND_THRESH(PEND_THRESH),
	.ADDR_LMT   (ADDR_LMT),
	.TXHDR_WIDTH(TXHDR_WIDTH),
	.RXHDR_WIDTH(RXHDR_WIDTH),
	.DATA_WIDTH (DATA_WIDTH )
)
inst_requestor(
	.Clk_400               		(Clk_400),
	.SoftReset                 	(SoftReset_q),
	
	.af2cp_sTxPort				(af2cp_sTxPort_c),
	.cp2af_sRxPort              (cp2af_sRxPort),
	
	.cr2re_src_address			(cr2re_src_address),
	.cr2re_dst_address			(cr2re_dst_address),
	.cr2re_dst_address_c		(cr2re_dst_address_c),
	.cr2re_src_address_b		(cr2re_src_address_b),
	.cr2re_num_blocks			(cr2re_num_blocks),
	.cr2re_num_parts_a			(cr2re_num_parts_a),
	.cr2re_num_parts_b			(cr2re_num_parts_b),	
	.cr2re_inact_thresh			(cr2re_inact_thresh),
	.cr2re_interrupt0			(cr2re_interrupt0),
	.cr2re_cfg					(cr2re_cfg),
	.cr2re_ctl					(cr2re_ctl),
	.cr2re_dsm_base				(cr2re_dsm_base),
	.cr2re_dsm_base_valid		(cr2re_dsm_base_valid),
	
	.ab2re_WrAddr				(ab2re_WrAddr),           
	.ab2re_WrTID				(ab2re_WrTID),            
	.ab2re_WrDin				(ab2re_WrDin),            
	.ab2re_WrFence				(ab2re_WrFence),          
	.ab2re_WrEn					(ab2re_WrEn),             
	.re2ab_WrSent				(re2ab_WrSent),           
	.re2ab_WrAlmFull			(re2ab_WrAlmFull),        
	
	.ab2re_RdAddr				(ab2re_RdAddr),           
	.ab2re_RdTID				(ab2re_RdTID),            
	.ab2re_RdEn					(ab2re_RdEn),             
	.re2ab_RdSent				(re2ab_RdSent),           
	
	.re2ab_RdRspValid			(re2ab_RdRspValid),       
	.re2ab_UMsgValid			(re2ab_UMsgValid),        
	.re2ab_CfgValid				(re2ab_CfgValid),         
	.re2ab_RdRsp				(re2ab_RdRsp),            
	.re2ab_RdData				(re2ab_RdData),           
	.re2ab_stallRd				(re2ab_stallRd),          
	
	.re2ab_WrRspValid			(re2ab_WrRspValid),       
	.re2ab_WrRsp				(re2ab_WrRsp),            
	.re2xy_go					(re2xy_go),               
	.re2xy_NumBlocks				(re2xy_NumBlocks),
	.re2xy_NumPartsA				(re2xy_NumPartsA),
	.re2xy_NumPartsB				(re2xy_NumPartsB),  
	.re2xy_Cont					(re2xy_Cont),             
	.re2xy_src_addr				(re2xy_src_addr),         
	.re2xy_dst_addr				(re2xy_dst_addr),         
	.re2xy_test_cfg				(re2xy_test_cfg),         
	.re2ab_Mode					(re2ab_Mode),             
	
	.ab2re_a_b_workspace_sel	(ab2re_a_b_workspace_sel),
	.ab2re_dst_workspace_sel	(ab2re_dst_workspace_sel),
	.ab2re_TestCmp				(ab2re_TestCmp),          
	.ab2re_ErrorInfo			(ab2re_ErrorInfo),        
	.ab2re_ErrorValid			(ab2re_ErrorValid),       
	.test_Reset_n				(test_SoftReset),            
	.re2cr_wrlock_n             (re2cr_wrlock_n),
	
	.re2ab_RdRspFormat			(),
	.re2ab_RdRspCLnum			(),
	.re2ab_WrRspFormat			(),
	.re2ab_WrRspCLnum			(),
	
	.re2xy_multiCL_len			()
);

reg								test_SoftReset_T;
always @(posedge Clk_400)
begin
	test_SoftReset_T <=	test_SoftReset;
end

//////////////
arbitrer_sgemm		#
(
.PEND_THRESH (PEND_THRESH),	
.ADDR_LMT	 (ADDR_LMT),	
.MDATA		 (MDATA)
)
(
	.clk_16UI						(Clk_400),
	.Resetb							(SoftReset_q),			
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
	.re2xy_NumBlocks				(re2xy_NumBlocks),
	.re2xy_NumPartsA				(re2xy_NumPartsA),
	.re2xy_NumPartsB				(re2xy_NumPartsB),	
	.re2xy_Cont						(re2xy_Cont),	
	//PE output control signals
	.ab2re_a_b_workspace_sel		(ab2re_a_b_workspace_sel),
	.ab2re_dst_workspace_sel		(ab2re_dst_workspace_sel),
	.ab2re_TestCmp					(ab2re_TestCmp),		
	.ab2re_ErrorInfo				(ab2re_ErrorInfo),
	.ab2re_ErrorValid				(ab2re_ErrorValid),
	.pe_reset						(test_SoftReset)	
);

////////////////////
t_ccip_c0_ReqMmioHdr       cp2cr_MmioHdr;
logic                       cp2cr_MmioWrEn;
logic                       cp2cr_MmioRdEn;
t_ccip_mmioData             cp2cr_MmioDin; 
t_ccip_mmioData             cr2cp_MmioDout;//cr2af_MmioDout;
logic                       cr2cp_MmioDout_v;//cr2af_MmioDout_v;
t_ccip_c2_RspMmioHdr        cr2cp_MmioHdr;//cr2af_MmioHdr;
 
always_comb
begin
    cp2cr_MmioHdr        = t_ccip_c0_ReqMmioHdr'(cp2af_sRxPort.c0.hdr);
    cp2cr_MmioWrEn       = cp2af_sRxPort.c0.mmioWrValid;
    cp2cr_MmioRdEn       = cp2af_sRxPort.c0.mmioRdValid;
    cp2cr_MmioDin        = cp2af_sRxPort.c0.data[CCIP_MMIODATA_WIDTH-1:0];

    af2cp_sTxPort                  = af2cp_sTxPort_c;
    // Override the C2 channel
    //af2cp_sTxPort.c2.hdr           = cr2af_MmioHdr;
    //af2cp_sTxPort.c2.data          = cr2af_MmioDout;
    //af2cp_sTxPort.c2.mmioRdValid   = cr2af_MmioDout_v;
    af2cp_sTxPort.c2.hdr           = cr2cp_MmioHdr;
    af2cp_sTxPort.c2.data          = cr2cp_MmioDout;
    af2cp_sTxPort.c2.mmioRdValid   = cr2cp_MmioDout_v;
end

sgemm_csr # (.CCIP_VERSION_NUMBER(CCIP_VERSION_NUMBER),
 .MPF_DFH_MMIO_ADDR(MPF_DFH_MMIO_ADDR)
)
inst_sgemm_csr (
 Clk_400,                       //                              clk_pll:    16UI clock   
 SoftReset_q,                      //                              rst:        ACTIVE HIGH soft reset   
 re2cr_wrlock_n,   
 // MMIO Requests from CCI-P   
 cp2cr_MmioHdr,                // [31:0]                       CSR Request Hdr    
 cp2cr_MmioDin,                   // [63:0]                       CSR read data   
 cp2cr_MmioWrEn,                  //                              CSR write strobe   
 cp2cr_MmioRdEn,                  //                              CSR read strobe   
 // MMIO Responses to CCI-P   
 cr2cp_MmioHdr,                // [11:0]                       CSR Response Hdr
 cr2cp_MmioDout,                  // [63:0]           c0tx*            CSR read data   
 cr2cp_MmioDout_v,                //                              CSR read data valid   
 // connections to requestor   
 cr2re_src_address,
 cr2re_src_address_b,   
 cr2re_dst_address,	
 cr2re_dst_address_c,   
 cr2re_num_blocks,	
 cr2re_num_parts_a,
 cr2re_num_parts_b,
 cr2re_inact_thresh,   
 cr2re_interrupt0,   
 cr2re_cfg,   
 cr2re_ctl,   
 cr2re_dsm_base,   
 cr2re_dsm_base_valid,   
 cr2s1_csr_write   
);

endmodule
