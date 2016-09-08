// ***************************************************************************
//
//        Copyright (C) 2008-2013 Intel Corporation All Rights Reserved.
//
// Engineer:            Pratik Marolia
// Create Date:         Thu Jul 28 20:31:17 PDT 2011
// Module Name:         test_lpbk1.v
// Project:             NLB AFU 
// Description:         memory copy test
//
// ***************************************************************************
// ---------------------------------------------------------------------------------------------------------------------------------------------------
//                                         Loopback 1- memory copy test
//  ------------------------------------------------------------------------------------------------------------------------------------------------
//
// This is a memory copy test. It copies cache lines from source to destination buffer.
//
//original module name: test_lpbk1
module sgemm_dp_controller #(parameter PEND_THRESH=1, ADDR_LMT=20, MDATA=14)
(

//      ---------------------------global signals-------------------------------------------------
       Clk_16UI               ,        // in    std_logic;  -- Core clock
       Resetb                 ,        // in    std_logic;  -- Use SPARINGLY only for control

       l12ab_WrAddr,                   // [ADDR_LMT-1:0]        arb:               write address
       l12ab_WrTID,                    // [ADDR_LMT-1:0]        arb:               meta data
       l12ab_WrDin,                    // [511:0]               arb:               Cache line data
       l12ab_WrEn,                     //                       arb:               write enable
       l12ab_WrFence,
	   ab2l1_WrSent,                   //                       arb:               write issued
       ab2l1_WrAlmFull,                //                       arb:               write fifo almost full
       
       l12ab_RdAddr,                   // [ADDR_LMT-1:0]        arb:               Reads may yield to writes
       l12ab_RdTID,                    // [15:0]                arb:               meta data
       l12ab_RdEn,                     //                       arb:               read enable
       ab2l1_RdSent,                   //                       arb:               read issued

       ab2l1_RdRspValid,               //                       arb:               read response valid
       ab2l1_RdRsp,                    // [15:0]                arb:               read response header
       ab2l1_RdRspAddr,                // [ADDR_LMT-1:0]        arb:               read response address
       ab2l1_RdData,                   // [511:0]               arb:               read data
       ab2l1_stallRd,                  //                       arb:               stall read requests FOR LPBK1

       ab2l1_WrRspValid,               //                       arb:               write response valid
       ab2l1_WrRsp,                    // [15:0]                arb:               write response header
       ab2l1_WrRspAddr,                // [ADDR_LMT-1:0]        arb:               write response address
       re2xy_go,                       //                       requestor:         start the test
       re2xy_NumBlocks,                 // [31:0]                requestor:         number of cache lines
       re2xy_NumPartsA,                 // [31:0]                requestor:         number of cache lines
       re2xy_NumPartsB,                 // [31:0]                requestor:         number of cache lines
       re2xy_Cont,                     //                       requestor:         continuous mode
		
	   l12ab_a_b_workspace_sel,		   //						arb:			   Select Between A and B workspace	
	   l12ab_dst_workspace_sel,        //						arb:			   Select Between C and LPBK1 workspace
       l12ab_TestCmp,                  //                       arb:               Test completion flag
       l12ab_ErrorInfo,                // [255:0]               arb:               error information
       l12ab_ErrorValid,               //                       arb:               test has detected an error
       test_Resetb                     //                       requestor:         rest the app
	   //Experimental											For quartus			Avoid synthesizing away DSP and RAM
	   //pe_out_block
);
    input                   Clk_16UI;               //                      csi_top:            Clk_16UI
    input                   Resetb;                 //                      csi_top:            system Resetb
    
    output  [ADDR_LMT-1:0]  l12ab_WrAddr;           // [ADDR_LMT-1:0]        arb:               write address
    output  [15:0]          l12ab_WrTID;            // [15:0]                arb:               meta data
    output  [511:0]         l12ab_WrDin;            // [511:0]               arb:               Cache line data
    output                  l12ab_WrEn;             //                       arb:               write enable
    output					l12ab_WrFence;
	input                   ab2l1_WrSent;           //                       arb:               write issued
    input                   ab2l1_WrAlmFull;        //                       arb:               write fifo almost full
           
    output  [ADDR_LMT-1:0]  l12ab_RdAddr;           // [ADDR_LMT-1:0]        arb:               Reads may yield to writes
    output  [15:0]          l12ab_RdTID;            // [15:0]                arb:               meta data
    output                  l12ab_RdEn;             //                       arb:               read enable
    input                   ab2l1_RdSent;           //                       arb:               read issued
    
    input                   ab2l1_RdRspValid;       //                       arb:               read response valid
    input  [15:0]           ab2l1_RdRsp;            // [15:0]                arb:               read response header
    input  [ADDR_LMT-1:0]   ab2l1_RdRspAddr;        // [ADDR_LMT-1:0]        arb:               read response address
    input  [511:0]          ab2l1_RdData;           // [511:0]               arb:               read data
    input                   ab2l1_stallRd;          //                       arb:               stall read requests FOR LPBK1
    
    input                   ab2l1_WrRspValid;       //                       arb:               write response valid
    input  [15:0]           ab2l1_WrRsp;            // [15:0]                arb:               write response header
    input  [ADDR_LMT-1:0]   ab2l1_WrRspAddr;        // [Addr_LMT-1:0]        arb:               write response address
    
    input                   re2xy_go;               //                       requestor:         start of frame recvd
    input  [31:0]           re2xy_NumBlocks;         // [31:0]                requestor:         number of cache lines
    input  [31:0]           re2xy_NumPartsA;         // [31:0]                requestor:         number of cache lines
    input  [31:0]           re2xy_NumPartsB;         // [31:0]                requestor:         number of cache lines
    input                   re2xy_Cont;             //                       requestor:         continuous mode
    
    output                  l12ab_TestCmp;          //                       arb:               Test completion flag
    output [255:0]          l12ab_ErrorInfo;        // [255:0]               arb:               error information
    output                  l12ab_ErrorValid;       //                       arb:               test has detected an error
    input                   test_Resetb;
	output					l12ab_a_b_workspace_sel;
	output					l12ab_dst_workspace_sel;
		
	// Local parameters for PE Systolic Array
	localparam				DATA_WIDTH			= 32;
	localparam				PE_LATENCY			= 1;
	localparam				DATA_WIDTH_CONTROL	= 3;
	localparam				NUM_WORDS_MEM       = 4096;
	localparam				A_SHIFT_LATENCY     = 1;
	localparam				B_SHIFT_LATENCY		= 1;
	localparam				NUM_ROWS			= 10;//1;//10;
	localparam				NUM_COL				= 16;//1;//16;
		
	localparam				CL_WIDTH			= 512;
	localparam				MEM_CHANNEL_DEPTH	= 32;
	
	localparam			ADDR_WIDTH		=		$clog2(NUM_WORDS_MEM);
	localparam			CH_WORDS		=		$clog2(MEM_CHANNEL_DEPTH);
	
	
 // Internal signals for Connecting PE
wire									pe_channel_sel;
reg				[ADDR_LMT-1:0]			ab2pe_WrAddr_in;

// A_MEM Data Channel Control Signals
// Input to PE 
wire									writes_fifo_full;

wire				[CL_WIDTH-1:0]			a_mem_channel_data_in;
wire										a_mem_channel_wr_req;
wire										a_mem_channel_rd_req;
wire										a_mem_channel_flush;
//Output from PE
wire									a_mem_channel_full;
wire									a_mem_channel_empty;
wire									a_mem_channel_almost_full;
wire			[CH_WORDS-1:0]			a_mem_channel_usedw;
//A Mem Addr Channel Control Signals
//Input to PE
wire				[ADDR_LMT-1:0]			a_mem_channel_addr_in;	
wire										a_mem_channel_addr_wr_req;
wire										a_mem_channel_addr_rd_req;	
wire										a_mem_channel_addr_flush;
//Output from PE
wire									a_mem_channel_addr_full;			
wire									a_mem_channel_addr_empty;		
wire									a_mem_channel_addr_almost_full;	
wire				[CH_WORDS-1:0]		a_mem_channel_addr_usedw;		
//B_MEM_Channel Control Signals
//	Input to PE
wire			[CL_WIDTH-1:0]				b_mem_channel_data_in;
wire										b_mem_channel_wr_req;
wire										b_mem_channel_rd_req;
wire										b_mem_channel_flush;
//Output from PE	
wire									b_mem_channel_full;
wire									b_mem_channel_empty;
wire									b_mem_channel_almost_full;
wire			[CH_WORDS-1:0]			b_mem_channel_usedw;
//B Mem Addr Channel Control Signals
//Input to PE
wire				[ADDR_LMT-1:0]			b_mem_channel_addr_in;	
wire										b_mem_channel_addr_wr_req;
wire										b_mem_channel_addr_rd_req;	
wire										b_mem_channel_addr_flush;
//Output from PE                        
wire									b_mem_channel_addr_full;		
wire									b_mem_channel_addr_empty;		
wire									b_mem_channel_addr_almost_full;	
wire				[CH_WORDS-1:0]		b_mem_channel_addr_usedw;		
//Write Interface
// Input to PE systolic Array module.
wire			[ADDR_LMT-1:0]			wr_addr_a_mem;
wire			[ADDR_LMT-1:0]			wr_addr_b_mem;
wire									wr_en_a_mem	 [NUM_ROWS-1:0];
wire									wr_en_b_mem	 [NUM_COL-1:0];
wire									wr_en_a_mem_ctrl;
wire									wr_en_b_mem_ctrl;

genvar	i;
generate
	for(i = 0; i<NUM_ROWS; i = i+1)
		begin:WR_EN_A_MEM
			assign	wr_en_a_mem[i] 	=    wr_en_a_mem_ctrl ;
		end
endgenerate

generate
	for(i = 0; i<NUM_COL; i = i+1)
		begin:WR_EN_B_MEM
			assign	wr_en_b_mem[i] 	=    wr_en_b_mem_ctrl ;
		end
endgenerate
	
// Read Interface Control Signals
// The read interface is not exposed
// A counter basically generates the read address for the PE. To enable Reads, just load the counter
// and its control signals

// Input to the PE systolic Array module
wire									sclr;
//PE Output signals
wire			[DATA_WIDTH-1:0]		pe_out_block [NUM_COL-1:0];//pe_out_block [NUM_ROWS-1:0][NUM_COL-1:0];
wire									pe_out_valid[NUM_COL-1:0];//pe_out_valid[NUM_ROWS-1:0][NUM_COL-1:0];
// Controller Logic
reg										pe_data_channel_sel;	
reg										pe_addr_channel_sel;	
reg										test_Resetb_T;
// Timing Optimization
//{
//Generate the input to test completion flag in this module
// Num_ROWS*1024*re2xy_NumPartsA*re2xy_NumPartsB
wire 			[DATA_WIDTH-1:0]		test_complete_flag1;
logic 		[DATA_WIDTH-1:0]     		num_a_x_num_b;
logic		[DATA_WIDTH-1:0]			num_col_x_num_blocks;
logic		[DATA_WIDTH-1:0]			num_rows_x_num_blocks;

//assign	test_complete_flag1 =(NUM_ROWS*1024)*re2xy_NumPartsA*re2xy_NumPartsB;
assign   num_a_x_num_b       	= 	re2xy_NumPartsA*re2xy_NumPartsB;
assign	 num_col_x_num_blocks	=	NUM_COL*re2xy_NumBlocks;
assign	 num_rows_x_num_blocks	=	NUM_ROWS*re2xy_NumBlocks;
//Register num_a_x_num_b
logic 		[DATA_WIDTH-1:0]		num_a_x_num_b_T;
logic		[DATA_WIDTH-1:0]		num_col_x_num_blocks_T;
logic		[DATA_WIDTH-1:0]		num_rows_x_num_blocks_T;	

//Register Num Blocks coming from requestor
logic		[DATA_WIDTH-1:0]		re2xy_NumBlocks_T;	

always @(posedge Clk_16UI)
begin
	if(!test_Resetb_T)
		begin
			num_a_x_num_b_T			<= 0;
			num_col_x_num_blocks_T	<= 0;
			num_rows_x_num_blocks_T	<= 0;
		end
	else
		begin
			num_a_x_num_b_T			<= num_a_x_num_b;
			num_col_x_num_blocks_T	<= num_col_x_num_blocks;
			num_rows_x_num_blocks_T	<= num_rows_x_num_blocks;
		end
end
assign	test_complete_flag1 = (NUM_ROWS<<10)*num_a_x_num_b_T; // NUM_ROWS<<10 is same as NUM_ROWS*1024
//}		Timing Optimization

//Register test_complete_flag before passing it to Controller
logic 	[DATA_WIDTH-1:0]		test_complete_flag1_T;

always @(posedge Clk_16UI)
begin
	if(!test_Resetb_T)
		begin
			test_complete_flag1_T	<= 0;
		end
	else
		test_complete_flag1_T	<= test_complete_flag1;
end

// Controller

always @(posedge Clk_16UI)
begin
test_Resetb_T		<=	test_Resetb;
re2xy_NumBlocks_T	<=	re2xy_NumBlocks;
end

sgemm_controller						#
(
.CL_WIDTH	(CL_WIDTH),
.ADDR_LMT	(ADDR_LMT),
.ADDR_WIDTH	(ADDR_WIDTH),
.MDATA		(MDATA),
.CH_WORDS	(5),
.NUM_ROWS	(NUM_ROWS),
.NUM_COL	(NUM_COL)
)
SGEMM_CONTROLLER
(
	.Clk_16UI							(Clk_16UI),
	.test_Resetb						(test_Resetb_T),
	.sclr								(sclr),	
	// Inputs from arbiter		        
	.re2xy_go							(re2xy_go),
	.re2xy_NumBlocks					(re2xy_NumBlocks_T),
	.re2xy_NumPartsA					(re2xy_NumPartsA),
	.re2xy_NumPartsB					(re2xy_NumPartsB),	
	.ab2l1_RdSent						(ab2l1_RdSent),
	.ab2l1_stallRd						(ab2l1_stallRd),
	.ab2l1_RdRspAddr					(ab2l1_RdRspAddr),
	.ab2l1_RdData						(ab2l1_RdData),
	.re2xy_Cont							(re2xy_Cont), 
	.ab2l1_RdRspValid					(ab2l1_RdRspValid),
	.ab2l1_RdRsp						(ab2l1_RdRsp),
	.ab2l1_WrRspValid					(ab2l1_WrRspValid),
	.ab2l1_WrSent						(ab2l1_WrSent),	
	.ab2l1_WrAlmFull					(ab2l1_WrAlmFull),
	// Inputs from 2D Systolic          
	//A Mem data channel                
	.a_mem_channel_full					(feeders_a_full),
	.a_mem_channel_data_in				(a_mem_channel_data_in),
	.a_mem_channel_wr_req				(a_mem_channel_wr_req), 
	.a_mem_channel_addr_in				(a_mem_channel_addr_in),
	//B Mem Data channel                
	.b_mem_channel_full					(feeders_b_full),
	.b_mem_channel_data_in				(b_mem_channel_data_in),
	.b_mem_channel_wr_req				(b_mem_channel_wr_req),                                              
	.b_mem_channel_addr_in				(b_mem_channel_addr_in),	
	// PE systolic engine               
	.pe_out_valid						(pe_out_valid),
	.pe_out_block						(pe_out_block),	                                    
                                   
	// Output to Arbiter                
	.l12ab_WrAddr						(l12ab_WrAddr),    
	.l12ab_WrTID						(l12ab_WrTID),     
	.l12ab_WrDin						(l12ab_WrDin),     
	.l12ab_WrEn							(l12ab_WrEn),
	.l12ab_WrFence						(l12ab_WrFence),
	.l12ab_RdAddr						(l12ab_RdAddr),
	.l12ab_RdTID						(l12ab_RdTID),     
	.l12ab_RdEn							(l12ab_RdEn),      
	.l12ab_TestCmp						(l12ab_TestCmp),   
	.l12ab_ErrorInfo					(l12ab_ErrorInfo), 
	.l12ab_ErrorValid					(l12ab_ErrorValid),
	.a_b_workspace_sel				    (l12ab_a_b_workspace_sel),
	.c_dst_workspace_sel				(l12ab_dst_workspace_sel),
	.writes_fifo_full					(writes_fifo_full),
	.test_complete_flag1				(test_complete_flag1),
	.num_rows_x_num_blocks				(num_rows_x_num_blocks_T),
	.num_col_x_num_blocks				(num_col_x_num_blocks_T)
);

// Data path
pe_9x9_mem_ctrl_autogen			#(
.DATA_WIDTH			(32),						
.PE_LATENCY			(1),
.DATA_WIDTH_CONTROL	(3),
.NUM_WORDS_MEM      (NUM_WORDS_MEM), 
.A_SHIFT_LATENCY    (1), 
.B_SHIFT_LATENCY	(1),	
.NUM_ROWS			(NUM_ROWS),
.NUM_COL			(NUM_COL)
)
(
	.clk			(Clk_16UI),
    .rst			(~test_Resetb_T),
    .en_in			(re2xy_go),//en_in
    .sclr			(sclr),
    .workloads_num	(re2xy_NumBlocks_T), 
    .wr_data_a_mem	(a_mem_channel_data_in),
    .wr_data_b_mem	(b_mem_channel_data_in),
    //.wr_addr_a_mem	(a_mem_channel_addr_in[11:0]),						//remove for ordered rd responses
    //.wr_addr_b_mem	(b_mem_channel_addr_in[11:0]),
    .wr_en_a_mem	(a_mem_channel_wr_req),//wr_en_a_mem	),
    .wr_en_b_mem	(b_mem_channel_wr_req),//wr_en_b_mem	),
    
    .writes_fifo_full(writes_fifo_full),

    .pe_out_block	(pe_out_block),
	.pe_out_valid	(pe_out_valid),
	.feeders_a_full	(feeders_a_full),
	.feeders_b_full	(feeders_b_full)
);

endmodule
