module		arbitrer_sgemm  #(
parameter		PEND_THRESH		=		1,
parameter		ADDR_LMT		=		20,
parameter		MDATA			=		14
)
(
		clk_16UI,
		Resetb	,
		
		//Write Interface
		ab2re_WrAddr,
		ab2re_WrTID,
		ab2re_WrDin,
		ab2re_WrFence,
		ab2re_WrEn,
		re2ab_WrSent,
		re2ab_WrAlmFull,
		
		//Read Interface
		
		ab2re_RdAddr,
		ab2re_RdTID,
		ab2re_RdEn,
		re2ab_RdSent,
		
		//Rd Interface Control Signals
		re2ab_RdRspValid,
		re2ab_RdRsp,
		re2ab_RdData,
		re2ab_stallRd,
		
		//Wr Interface Control Signals
		re2ab_WrRspValid,
		re2ab_WrRsp,
		
		//Other Control Signals
		
		re2xy_go,
		re2xy_NumBlocks,
		re2xy_NumPartsA,
		re2xy_NumPartsB,		
		re2xy_Cont,
		
		//PE output control signals
		
		ab2re_TestCmp,
		ab2re_ErrorInfo,
		ab2re_ErrorValid,
		pe_reset,
		ab2re_a_b_workspace_sel,
		ab2re_dst_workspace_sel
);
		

input									clk_16UI;
input									Resetb;

//Write Interface
output			[ADDR_LMT-1:0]			ab2re_WrAddr;
output			[15:0]					ab2re_WrTID;
output			[511:0]					ab2re_WrDin;
output									ab2re_WrFence;
output									ab2re_WrEn;
input									re2ab_WrSent;
input									re2ab_WrAlmFull;		
		
//Read Interface		
		
output			[ADDR_LMT-1:0]			ab2re_RdAddr;		
output			[15:0]					ab2re_RdTID;		
output									ab2re_RdEn;
input									re2ab_RdSent;

//Rd Interface Control Signals
input									re2ab_RdRspValid;
input			[15:0]					re2ab_RdRsp;
input			[511:0]					re2ab_RdData;
input									re2ab_stallRd;

//Wr Interface Control Signals
input									re2ab_WrRspValid;
input			[15:0]					re2ab_WrRsp;

//Other Control Signals

input									re2xy_go;
input			[31:0]					re2xy_NumBlocks;
input			[31:0]					re2xy_NumPartsA;
input			[31:0]					re2xy_NumPartsB;
input									re2xy_Cont;


//PE output control signals

output									ab2re_TestCmp;
output			[255:0]					ab2re_ErrorInfo;
output									ab2re_ErrorValid;
input									pe_reset;			// Use this for AFU Reset
output									ab2re_a_b_workspace_sel;
output									ab2re_dst_workspace_sel;
//----------------------------------------------------------------------------
reg 			[ADDR_LMT-1:0]      	ab2re_WrAddr;   
reg 			[15:0]	                ab2re_WrTID;    
reg 			[511:0]             	ab2re_WrDin;    
reg                     				ab2re_WrEn;     
reg                     				ab2re_WrFence;  
reg 			[ADDR_LMT-1:0]      	ab2re_RdAddr;
reg 			[15:0]              	ab2re_RdTID; 
reg                     				ab2re_RdEn;
reg             				        ab2re_TestCmp;   
reg 			[255:0]             	ab2re_ErrorInfo; 
reg                     				ab2re_ErrorValid;
reg										ab2re_a_b_workspace_sel;
reg										ab2re_dst_workspace_sel;

// Internal Signals

wire			[ADDR_LMT-1:0]			l12ab_WrAddr;
wire			[15:0]					l12ab_WrTID;
wire			[511:0]					l12ab_WrDin;
wire									l12ab_WrEn;
wire									l12ab_WrFence;
reg										ab2l1_WrSent;
reg										ab2l1_WrAlmFull;

wire			[ADDR_LMT-1:0]			l12ab_RdAddr;
wire			[15:0]					l12ab_RdTID;
wire									l12ab_RdEn;
reg										ab2l1_RdSent;

wire									re2ab_RdRspValid;

reg										ab2l1_RdRspValid;
reg				[15:0]					ab2l1_RdRsp;
reg				[ADDR_LMT-1:0]			ab2l1_RdRspAddr;
reg				[511:0]					ab2l1_RdData;
reg										ab2l1_stallRd;

reg										ab2l1_WrRspValid;
reg										ab2l1_WrRsp;
reg				[ADDR_LMT-1:0]			ab2l1_WrRspAddr;


wire									re2xy_go;
wire			[31:0]					re2xy_NumBlocks;
wire			[31:0]					re2xy_NumPartsA;
wire			[31:0]					re2xy_NumPartsB;
wire									re2xy_Cont;

wire									l12ab_a_b_workspace_sel;
wire									l12ab_dst_workspace_sel;									
wire									l12ab_TestCmp;		
wire			[255:0]					l12ab_ErrorInfo;
wire									l12ab_ErrorValid;	
wire									pe_reset;

// Local Variables
 reg                     				re2ab_RdRspValid_q, re2ab_RdRspValid_qq;
 reg                     				re2ab_WrRspValid_q, re2ab_WrRspValid_qq;
 reg 			[15:0]              	re2ab_RdRsp_q, re2ab_RdRsp_qq;
 reg 			[15:0]              	re2ab_WrRsp_q, re2ab_WrRsp_qq;
 reg 			[511:0]             	re2ab_RdData_q, re2ab_RdData_qq;
 

wire [ADDR_LMT-1:0]     arbmem_rd_dout;
wire [ADDR_LMT-1:0]     arbmem_wr_dout;   

   



always @(*)
	begin
		
		// Inputs
		//ab2l1_WrSent				=		re2ab_WrSent;
		ab2l1_WrSent       			= 		re2ab_WrSent;
		ab2l1_WrAlmFull    			= 		re2ab_WrAlmFull;
		ab2l1_RdSent       			= 		re2ab_RdSent;
		ab2l1_RdRspValid   			= 		re2ab_RdRspValid_qq;
		ab2l1_RdRsp        			= 		re2ab_RdRsp_qq;
		ab2l1_RdRspAddr    			= 		arbmem_rd_dout;
		ab2l1_RdData       			= 		re2ab_RdData_qq;
		ab2l1_stallRd      			= 		re2ab_stallRd;
		ab2l1_WrRspValid   			= 		re2ab_WrRspValid_qq;
		ab2l1_WrRsp        			= 		re2ab_WrRsp_qq;
		ab2l1_WrRspAddr    			= 		arbmem_wr_dout;
		
		//Output
		
		ab2re_WrAddr       			= 		l12ab_WrAddr;
		ab2re_WrTID        			= 		l12ab_WrTID;
		ab2re_WrDin        			= 		l12ab_WrDin;
		ab2re_WrFence				=		l12ab_WrFence;
		//ab2re_WrFence      			= 		1'b0;
		ab2re_WrEn         			= 		l12ab_WrEn;
		ab2re_RdAddr       			= 		l12ab_RdAddr;
		ab2re_RdTID        			= 		l12ab_RdTID;
		ab2re_RdEn         			= 		l12ab_RdEn;
		ab2re_TestCmp      			= 		l12ab_TestCmp;
		ab2re_ErrorInfo    			= 		l12ab_ErrorInfo;
		ab2re_ErrorValid   			= 		l12ab_ErrorValid;
		ab2re_a_b_workspace_sel		=		l12ab_a_b_workspace_sel;
		ab2re_dst_workspace_sel		=		l12ab_dst_workspace_sel;
	end

// Instantiate Arbitration Memory



nlb_gram_sdp		 #
(
.BUS_SIZE_ADDR	(MDATA),
.BUS_SIZE_DATA	(ADDR_LMT),
.GRAM_MODE		(2'd3)
)arb_rd_mem 
 (
 .clk  (clk_16UI),
 .we   (ab2re_RdEn),        
 .waddr(ab2re_RdTID[MDATA-1:0]),     
 .din  (ab2re_RdAddr),       
 .raddr(re2ab_RdRsp[MDATA-1:0]),     
 .dout (arbmem_rd_dout )
 );     

nlb_gram_sdp 		#
(
.BUS_SIZE_ADDR	(MDATA),
.BUS_SIZE_DATA	(ADDR_LMT),
.GRAM_MODE		(2'd3)
)arb_wr_mem 
(
.clk  (clk_16UI),
.we   (ab2re_WrEn),        
.waddr(ab2re_WrTID[MDATA-1:0]),     
.din  (ab2re_WrAddr),       
.raddr(re2ab_WrRsp[MDATA-1:0]),     
.dout (arbmem_wr_dout )
);

always @(posedge clk_16UI)
     begin
        re2ab_RdData_q          <= re2ab_RdData;
        re2ab_RdRsp_q           <= re2ab_RdRsp;
        re2ab_WrRsp_q           <= re2ab_WrRsp;
        re2ab_RdData_qq         <= re2ab_RdData_q;
        re2ab_RdRsp_qq          <= re2ab_RdRsp_q;
        re2ab_WrRsp_qq          <= re2ab_WrRsp_q;
        if(~pe_reset)
		//  if(pe_reset)
          begin
             re2ab_RdRspValid_q      <= 0;
             re2ab_WrRspValid_q      <= 0;
             re2ab_RdRspValid_qq     <= 0;
             re2ab_WrRspValid_qq     <= 0;
          end
        else
          begin
             re2ab_RdRspValid_q      <= re2ab_RdRspValid;
             re2ab_WrRspValid_q      <= re2ab_WrRspValid;
             re2ab_RdRspValid_qq     <= re2ab_RdRspValid_q;
             re2ab_WrRspValid_qq     <= re2ab_WrRspValid_q;
          end
     end

reg			[ADDR_LMT-1:0]			ab2re_WrAddr_prev;
reg									address_error;	
always @(posedge clk_16UI)
     begin
     if(~pe_reset)
		begin
			ab2re_WrAddr_prev<=0;
			address_error<=0;
		end
     else
		begin
			ab2re_WrAddr_prev<=ab2re_WrAddr;
			if(ab2re_WrEn && (ab2re_WrAddr_prev==ab2re_WrAddr))
				address_error<=1;
			else
				address_error<=0;
		end
     end



sgemm_dp_controller			#
(
.PEND_THRESH	(PEND_THRESH),
.ADDR_LMT		(ADDR_LMT),
.MDATA			(MDATA)
)
(
	.Clk_16UI					(clk_16UI),         
	.Resetb						(Resetb),          
	.l12ab_WrAddr				(l12ab_WrAddr),    
	.l12ab_WrTID				(l12ab_WrTID),     
	.l12ab_WrDin				(l12ab_WrDin),     
	.l12ab_WrEn					(l12ab_WrEn),
	.l12ab_WrFence				(l12ab_WrFence),
	.ab2l1_WrSent				(re2ab_WrSent),    
	.ab2l1_WrAlmFull			(ab2l1_WrAlmFull), 
	.l12ab_RdAddr				(l12ab_RdAddr),    
	.l12ab_RdTID				(l12ab_RdTID),     
	.l12ab_RdEn					(l12ab_RdEn),      
	.ab2l1_RdSent				(ab2l1_RdSent),    
	.ab2l1_RdRspValid			(ab2l1_RdRspValid),
	.ab2l1_RdRsp				(ab2l1_RdRsp),     
	.ab2l1_RdRspAddr			(ab2l1_RdRspAddr), 
	.ab2l1_RdData				(ab2l1_RdData),    
	.ab2l1_stallRd				(ab2l1_stallRd),   
	.ab2l1_WrRspValid			(ab2l1_WrRspValid),
	.ab2l1_WrRsp				(ab2l1_WrRsp),     
	.ab2l1_WrRspAddr			(ab2l1_WrRspAddr), 
	.re2xy_go					(re2xy_go),        
	.re2xy_NumBlocks			(re2xy_NumBlocks),  
	.re2xy_NumPartsA			(re2xy_NumPartsA),
	.re2xy_NumPartsB			(re2xy_NumPartsB), 	  
	.re2xy_Cont					(re2xy_Cont),      
	.l12ab_TestCmp				(l12ab_TestCmp),
	.l12ab_a_b_workspace_sel	(l12ab_a_b_workspace_sel),
	.l12ab_dst_workspace_sel	(l12ab_dst_workspace_sel),
	.l12ab_ErrorInfo			(l12ab_ErrorInfo), 
	.l12ab_ErrorValid			(l12ab_ErrorValid),
	.test_Resetb            	(pe_reset)
);
endmodule		 
