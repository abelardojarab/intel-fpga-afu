module		sgemm_controller		#
(
parameter		CL_WIDTH	= 512,
parameter		ADDR_LMT    = 20,
parameter		ADDR_WIDTH  = 12,
parameter		MDATA		= 14,
parameter		CH_WORDS	= -1,
parameter		NUM_ROWS	= 9,
parameter		NUM_COL 	= 9,
parameter		DATA_WIDTH	= 32
)
(
	Clk_16UI,
	test_Resetb,
	// Inputs from arbiter
	re2xy_go,
	re2xy_NumBlocks,
	re2xy_NumPartsA,
	re2xy_NumPartsB,
	ab2l1_RdSent,
	ab2l1_stallRd,
	ab2l1_RdRspAddr,
	ab2l1_RdData,
	ab2l1_RdRspValid,
	ab2l1_RdRsp,
	ab2l1_WrRspValid,
	ab2l1_WrSent,
	ab2l1_WrAlmFull,	
	re2xy_Cont, //from csr cfg
	// Inputs from 2D Systolic Array
	//A Mem data channel
	a_mem_channel_full,	
	//B Mem Data channel
	b_mem_channel_full,	
	// PE systolic engine
	pe_out_block,
	pe_out_valid,
	// Outputs to 2D Systolic Array
	//A Mem Channel
	a_mem_channel_data_in,
	a_mem_channel_wr_req,	
	// A Mem Addr Channel
	a_mem_channel_addr_in,	
	// B Mem Channel
	b_mem_channel_data_in,
	b_mem_channel_wr_req,	
	// B Mem Addr Channel
	b_mem_channel_addr_in,
	// PE Systolic Engine
	sclr,
	// Output to Arbiter
	l12ab_WrAddr,    
	l12ab_WrTID,     
	l12ab_WrDin,     
	l12ab_WrEn,
    l12ab_WrFence,	
	l12ab_RdAddr,
    l12ab_RdTID,     
    l12ab_RdEn,      
    l12ab_TestCmp,   
    l12ab_ErrorInfo, 
    l12ab_ErrorValid,
	a_b_workspace_sel,
	c_dst_workspace_sel,
	writes_fifo_full,
    test_complete_flag1,
	num_rows_x_num_blocks,
	num_col_x_num_blocks
);

input										Clk_16UI;
input										test_Resetb;
// Inputs from arbiter
input										re2xy_go;
input			[31:0]						re2xy_NumBlocks;
input			[31:0]						re2xy_NumPartsA;
input			[31:0]						re2xy_NumPartsB;
input										ab2l1_RdSent;
input										ab2l1_stallRd;
input			[ADDR_LMT-1:0]				ab2l1_RdRspAddr;
input			[CL_WIDTH-1:0]				ab2l1_RdData;
input										ab2l1_RdRspValid;
input  			[15:0]           			ab2l1_RdRsp;
input                   					ab2l1_WrRspValid;
input                   					ab2l1_WrSent;
input										ab2l1_WrAlmFull;

input										re2xy_Cont;
// Inputs from 2D Systolic A
//A Mem data channel
input										a_mem_channel_full;
//B Mem Data channel
input										b_mem_channel_full;
// PE systolic engine
input										pe_out_valid [NUM_COL-1:0];
input			[DATA_WIDTH-1:0]			pe_out_block [NUM_COL-1:0];
input			[DATA_WIDTH-1:0]			test_complete_flag1;
input			[DATA_WIDTH-1:0]			num_rows_x_num_blocks;
input			[DATA_WIDTH-1:0]			num_col_x_num_blocks;

// Outputs to 2D Systolic Ar
//A Mem Data Channel
output			[CL_WIDTH-1:0]				a_mem_channel_data_in;
output										a_mem_channel_wr_req;
output			[ADDR_LMT-1:0]				a_mem_channel_addr_in;

// B Mem Channel
output			[CL_WIDTH-1:0]				b_mem_channel_data_in;
output										b_mem_channel_wr_req;
output			[ADDR_LMT-1:0]				b_mem_channel_addr_in;
// PE Systolic Engine
output										sclr;
// Output to Arbiter
output			[ADDR_LMT-1:0]				l12ab_WrAddr;    
output			[15:0]						l12ab_WrTID;     
output			[511:0]						l12ab_WrDin;     
output										l12ab_WrEn;
output										l12ab_WrFence;      
output			[ADDR_LMT-1:0]				l12ab_RdAddr;    
output			[15:0]						l12ab_RdTID;     
output										l12ab_RdEn;      
output										l12ab_TestCmp;   
output			[255:0]						l12ab_ErrorInfo; 
output										l12ab_ErrorValid;
output										a_b_workspace_sel;
output										c_dst_workspace_sel;

output										writes_fifo_full;
//-------------------------------------------------------------------------------------------------------
// All outputs  of Controller are Registerd
reg			[CL_WIDTH-1:0]				a_mem_channel_data_in;
reg										a_mem_channel_wr_req;
reg			[ADDR_LMT-1:0]				a_mem_channel_addr_in;
// B Mem Channel
reg			[CL_WIDTH-1:0]				b_mem_channel_data_in;
reg										b_mem_channel_wr_req;
reg			[ADDR_LMT-1:0]				b_mem_channel_addr_in;
// PE Systolic Engine
reg										writes_fifo_full;
reg										sclr;
reg										sload;
reg										cnt_en;
reg			[ADDR_WIDTH-1:0]			load_data;
reg										rd_en;
reg										acc_in;
reg										en_in;
// Output to Arbiter
reg			[ADDR_LMT-1:0]				l12ab_WrAddr;    
reg			[15:0]						l12ab_WrTID;     
reg			[511:0]						l12ab_WrDin;     
reg										l12ab_WrEn;
reg										l12ab_WrFence;      
reg			[ADDR_LMT-1:0]				l12ab_RdAddr;    
//reg			[ADDR_LMT-1:0]				A_RdAddr_offset;  //offset for different workloads
//reg			[ADDR_LMT-1:0]				B_RdAddr_offset;  //offset for different workloads
reg			[15:0]						l12ab_RdTID;     
reg										l12ab_RdEn;      
reg										l12ab_TestCmp;   
reg			[255:0]						l12ab_ErrorInfo; 
reg										l12ab_ErrorValid;
reg										a_b_workspace_sel;		// This should go to Requestor
reg										c_dst_workspace_sel;	// This should go to Requestor
reg                     				ab2l1_WrSent_x;
//--------------------------------------------------------------------------------------------------------
// Internal registers
reg			[2:0]						read_fsm;
reg			[2:0]						write_fsm;
reg			[2:0]						pe_dmu_fsm;
reg			[1:0]						pe_out_write_sys_mem_fsm;

reg			[15:0]						Num_Read_req;
reg			[15:0]						Num_Write_req;
reg     	[15:0]          			Num_Write_rsp;

reg			[15:0]						num_el_2_a_mem;
reg			[15:0]						num_el_2_b_mem;

reg										switch_workspace;

reg										pe_addr_channel_sel;		

reg     [11:0]           				rd_mdata, rd_mdata_next; // limit max mdata to 8 bits or 256 requests
//reg     [2**12-1:0]      				rd_mdata_pend;   //2**7       // bitvector to track used mdata values
reg     [MDATA-1:0]     				wr_mdata;
//reg                     				rd_mdata_avail;         // is the next rd madata free and available	

reg		[15:0]							num_workspace_switch;
reg		[15:0]							num_workload_A;
reg		[15:0]							num_workload_B;
reg		[15:0]							num_block_C;
//reg										read_lines_done;

wire		[15:0]						a_mem_write_count;
wire		[15:0]						b_mem_write_count;

reg			[15:0]						num_elements_to_pe;
reg			[15:0]						num_elements_processed_by_pe;
reg										pe_out_gather_go;
reg			[15:0]						pe_gather_done;
reg			[3:0]						pe_write_fifo_el_count;
reg										pe_out_write_to_sys_mem_go;
reg										pe_out_write_to_sys_mem_done;
reg										pe_out_write_to_sys_mem_wr_en;

reg			[ADDR_LMT-1:0]				pe_out_wr_addr;
logic		[ADDR_LMT-1:0]				wr_addr_offset;
reg										pe_out_wr_addr_gen;

// STATE_PE_OUT_WRITE_FIFO_IDLE: This FSM will bascially write the values in pe_out_result into the output fifo.
reg										pe_write_fifo_fsm_go;

reg										pe_out_valid_reg	[NUM_ROWS-1:0][NUM_COL-1:0];
reg			[DATA_WIDTH-1:0]			pe_out_result		[NUM_ROWS-1:0][NUM_COL-1:0];
// PE OUTPUT FIFO Control Signals
reg										pe_write_fifo_rd_req;
reg										pe_write_fifo_rd_req_q;
reg										pe_write_fifo_wr_req;
reg										pe_write_fifo_empty_q;
//reg			[CL_WIDTH-1:0]			pe_write_fifo_out;
wire			[CL_WIDTH-1:0]			pe_write_fifo_out;
wire		[4:0]						pe_wite_fifo_usedw;		
wire									pe_write_fifo_full;		
wire									pe_write_fifo_empty;		
wire									pe_write_fifo_almost_full;

// Timing optimization for SGEMM_Controller
logic 		[ADDR_LMT-1:0]				rd_address_a_offset;
logic 		[ADDR_LMT-1:0]				rd_address_a_offset_test;
logic		[ADDR_LMT-1:0]				rd_address_a_offset_part1;
logic		[ADDR_LMT-1:0]				rd_address_a_offset_part2;
logic		[ADDR_LMT-1:0]				rd_address_b_offset;
logic		[ADDR_LMT-1:0]				rd_address_b_offset_part1;
logic		[ADDR_LMT-1:0]				rd_address_b_offset_part2;
logic		[ADDR_LMT-1:0]				rd_address_b_offset_test;
logic									a_wrkld_rd_req_send_param;
logic									b_wrkld_rd_req_send_param;

logic		[11:0]						num_rows_x_block_size;
logic		[12:0]						num_col_x_block_size;

localparam	BLOCK_SIZE = 256;

logic	[31:0]						PartsA;
logic	[31:0]						PartsB;

assign 	PartsA		=		re2xy_NumPartsA-1'b1;
assign 	PartsB		=		re2xy_NumPartsB-1'b1;

assign	num_rows_x_block_size 			= 			NUM_ROWS * BLOCK_SIZE;
assign	num_col_x_block_size    		=			NUM_COL * BLOCK_SIZE;
assign	rd_address_a_offset_part2		=			((num_workload_B * num_col_x_num_blocks)<<8);
assign	rd_address_a_offset_part1		=			(num_workspace_switch[15:1]<<8)*NUM_COL;
assign	rd_address_a_offset				=			rd_address_a_offset_part1 + (rd_address_a_offset_part2);
assign	rd_address_a_offset_test 		= 	        (num_workspace_switch[15:1]<<8)*NUM_COL+((num_workload_B*NUM_COL*re2xy_NumBlocks)<<8);
														
assign	rd_address_b_offset_part2		=			((num_workload_A* num_rows_x_num_blocks)<<8);
assign	rd_address_b_offset_part1		=			(num_workspace_switch[15:1]<<8)*NUM_ROWS;
assign	rd_address_b_offset				=			rd_address_b_offset_part1 + rd_address_b_offset_part2;
assign	rd_address_b_offset_test		=			(num_workspace_switch[15:1]<<8)*NUM_ROWS+((num_workload_A*NUM_ROWS*re2xy_NumBlocks)<<8);
		
assign 	wr_addr_offset 					= 			(NUM_ROWS*num_block_C)<<10;

//Note: As of 2/2/2016, Vtp and ROB is not supported in BDX-P. Hence Read Response are unordered. It is possible for data hazard
//Scenario: Read from two workspaces. After sending read request for all the lines in workspace 1, we try to read all the elements from
// workspace 2. Since the response of unordered, it is possible that few response from workspace 2 comes before pending responses from workspace 1
//In that case, workspace 2 data might be loaded into workspace 1 internal memory. To overcome that issue, we can wait for all responses to arrive from
//workspace 1 before sending read request to workspace 2.
//PERFORMANCE might be affected by this. But once Vtp and ROB are suppprted, we can remove the no_data_harzard logic. 
reg										no_data_hazard;											
//-----------------------------------------------------------------------------------------------------------
// Read FSM	State Encoding
localparam	[2:0]						STATE_READ_IDLE						=		0;
localparam	[2:0]						STATE_READ_SEND_REQ					=		1;	
localparam	[2:0]						STATE_READ_CALC_OFFSET_1			=		3;
localparam	[2:0]						STATE_READ_CALC_OFFSET_2			=		4;
localparam	[2:0]						STATE_READ_CALC_OFFSET_DONE			=		5;																	
localparam	[2:0]						STATE_READ_CHANGE_WORKLOAD			=		6;
localparam	[2:0]						STATE_READ_CHANGE_WORKLOAD2			=		7;
// Write FSM State Encoding	
localparam	[2:0]						STATE_WRITE_IDLE					=		0;
localparam	[2:0]						STATE_WRITE_SEND_REQ				=		1;
localparam	[2:0]						STATE_WRITE_PE_OUT_CHECK_START		=		2;
localparam	[2:0]						STATE_WRITE_PE_OUT_START			=		3;
localparam	[2:0]						STATE_WRITE_PE_OUT_END				=		4;
// PE Input Data management FSM Unit State Encoding//	
localparam	[2:0]						STATE_DMU_IDLE						=		0;		
localparam	[2:0]						STATE_FILL_A_MEM_CHANNEL			=		1;
localparam	[2:0]						STATE_FILL_B_MEM_CHANNEL			=		2;
//PE Output Write to System Memory//
localparam	[1:0]						STATE_PE_OUT_WRITE_SYS_MEM_IDLE		=		0;
localparam	[1:0]						STATE_PE_OUT_WRITE_SYS_MEM_SEND_REQ =		1;
localparam	[1:0]						STATE_PE_OUT_WRITE_SYS_MEM_WAIT		=		2;
localparam	[1:0]						STATE_PE_OUT_WRITE_SYS_MEM_DONE		=		3;


always @(posedge	Clk_16UI)
begin
pe_out_valid_reg	<=	 pe_out_valid_reg; 
end
// Timing Optimization
logic		[ADDR_LMT-1:0]		rd_address_a_offset_T;
logic		[ADDR_LMT-1:0]		rd_address_b_offset_T;
always @(posedge 	Clk_16UI)
begin
rd_address_a_offset_T		<=	rd_address_a_offset;
rd_address_b_offset_T		<=	rd_address_b_offset;
end

//To Do: Add one more state in the read fsm to calculate the read offset address. 
//Reason: Calculating the offset requires a DSP operation and it might take more than 1 cycle.

logic		[ADDR_LMT-1:0]		rd_addr_a_ofst_part1;
logic		[ADDR_LMT-1:0]		rd_addr_a_ofst_part2;
logic		[ADDR_LMT-1:0]		rd_addr_b_ofst_part1;
logic		[ADDR_LMT-1:0]		rd_addr_b_ofst_part2;

always	@(posedge	Clk_16UI)
begin
		//STATE_READ_FSM
		case(read_fsm)		/* synthesis parallel_case */
			STATE_READ_IDLE:
				begin
					rd_addr_a_ofst_part1		<=		0;	
					rd_addr_a_ofst_part2		<=		0;
					rd_addr_b_ofst_part1		<=		0;
					rd_addr_b_ofst_part2		<=		0;
					read_fsm					<=		STATE_READ_CALC_OFFSET_1;
				end
			STATE_READ_CALC_OFFSET_1:
				begin
						//rd_addr_a_ofst_part1			<=			(num_workspace_switch[15:1]<<8)*NUM_COL;
						//rd_addr_b_ofst_part1			<=			(num_workspace_switch[15:1]<<8)*NUM_ROWS;
						rd_addr_a_ofst_part1			<=			rd_address_a_offset_part1;
						rd_addr_b_ofst_part1			<=			rd_address_b_offset_part1;
						read_fsm						<=			STATE_READ_CALC_OFFSET_2;
				end	
			STATE_READ_CALC_OFFSET_2:
				begin
						//rd_addr_a_ofst_part2			<=			((num_workload_B*NUM_COL*re2xy_NumBlocks)<<8);
						//rd_addr_a_ofst_part2			<=			((num_workload_B*num_col_x_block_size)<<8);
						//rd_addr_b_ofst_part2			<=			((num_workload_A*num_rows_x_block_size)<<8);
						rd_addr_a_ofst_part2			<=			rd_address_a_offset_part2;
						rd_addr_b_ofst_part2			<=			rd_address_b_offset_part2;													//rd_address_a_offset_part2; **********************************
						read_fsm						<=			STATE_READ_CALC_OFFSET_DONE;
				end
				
			STATE_READ_CALC_OFFSET_DONE:
				begin
					if(num_workspace_switch[0]) //B reads
						//l12ab_RdAddr					<=			(num_workspace_switch[15:1]<<8)*NUM_COL;// 0; (num_worksoace/2*256*mem in feeder)
						//l12ab_RdAddr					<=			(num_workspace_switch[15:1]<<8)*NUM_COL+((num_workload_B*NUM_COL*re2xy_NumBlocks)<<8);//with offset
						//l12ab_RdAddr					<=			rd_address_a_offset_T;
						//rd_addr_a_ofst_part1			<=			(num_workspace_switch[15:1]<<8)*NUM_COL;
						//rd_addr_b_ofst_part1			<=			(num_workspace_switch[15:1]<<8)*NUM_ROWS;
						l12ab_RdAddr					<=			rd_addr_a_ofst_part1 + rd_addr_a_ofst_part2;
					else	//A reads
						//l12ab_RdAddr					<=			(num_workspace_switch[15:1]<<8)*NUM_ROWS;			
						//l12ab_RdAddr					<=			(num_workspace_switch[15:1]<<8)*NUM_ROWS+((num_workload_A*NUM_ROWS*re2xy_NumBlocks)<<8);//with offset	
						//l12ab_RdAddr					<=			rd_address_b_offset_T;
						l12ab_RdAddr					<=			rd_addr_b_ofst_part1 + rd_addr_b_ofst_part2;
					Num_Read_req					<=				16'h1;		
					rd_mdata						<=				0;
					if(re2xy_go)
						begin							
							//if(num_workspace_switch <2*re2xy_NumBlocks)//16'h2) //2*re2xy_NumBlocks
							if(num_workload_A<re2xy_NumPartsA && num_workload_B<re2xy_NumPartsB)//16'h2) //2*re2xy_NumBlocks
								begin									
									if(!(a_mem_channel_full && b_mem_channel_full))
										read_fsm<=STATE_READ_SEND_REQ;
									else
										read_fsm<=read_fsm;
								end								
							else
								read_fsm		<=				2'h2; //default								
						end
				
				end
			STATE_READ_SEND_REQ:
				begin


					if(ab2l1_RdSent)
						begin
							l12ab_RdAddr			<=				l12ab_RdAddr	 +  1'b1;
							Num_Read_req			<=				Num_Read_req	 +	1'b1;
							if(Num_Read_req	== num_rows_x_block_size & !num_workspace_switch[0])//NUM_ROWS*256 & !num_workspace_switch[0])//num_rows_x_block_size)
								begin
									a_b_workspace_sel	 <=		1'b1;
									read_fsm			<=		STATE_READ_IDLE;
									num_workspace_switch <=		num_workspace_switch + 1'b1;
								end
							if(Num_Read_req	== num_col_x_block_size  & num_workspace_switch[0])
								begin
									a_b_workspace_sel	 <=		1'b0;
									read_fsm			<=		STATE_READ_CHANGE_WORKLOAD;
									num_workspace_switch <=		num_workspace_switch + 1'b1;
								end									
								
						end


				end

			STATE_READ_CHANGE_WORKLOAD:
				begin								
									if(num_workspace_switch==(re2xy_NumBlocks[15:0]<<1))  //last part B of last workload
										begin 
											num_workspace_switch	<=	16'b0;
											//if(num_workload_A<re2xy_NumPartsA-1'b1)
											if(num_workload_A<PartsA)
													num_workload_A	<=	num_workload_A+1'b1;
											else	 
												begin
													num_workload_A	<=	16'b0;
													num_workload_B	<=	num_workload_B+1'b1;
												end
											
											//if(num_workload_A+1'b1==re2xy_NumPartsA && num_workload_B+1'b1==re2xy_NumPartsB)
											if(num_workload_A==PartsA && num_workload_B==PartsB)
												read_fsm	<=	2'h2;  //end of reads
											else
												read_fsm	<=				STATE_READ_IDLE;	//default
										end		
									else
										read_fsm	<=				STATE_READ_IDLE;	//default								
				end

			default :
				read_fsm<=read_fsm;
		endcase		
		
		
		
		ab2l1_WrSent_x			<=			1'b1;
		/////////////////////////	Write FSM 
		case(write_fsm)		/* synthesis parallel_case */
			STATE_WRITE_IDLE:
				begin
							write_fsm				<=		STATE_WRITE_SEND_REQ;
				end
			STATE_WRITE_SEND_REQ:
				begin
							write_fsm			<=		STATE_WRITE_PE_OUT_CHECK_START;     //default
				end
			STATE_WRITE_PE_OUT_CHECK_START:
				begin
					if(!pe_write_fifo_empty)// && !pe_write_fifo_almost_full)
						begin
							pe_out_write_to_sys_mem_go	<= 1'b1;
							c_dst_workspace_sel			<=	1'b1;
							write_fsm					<=	STATE_WRITE_PE_OUT_START;
						end
					else
						write_fsm		<=	write_fsm;
				end
			STATE_WRITE_PE_OUT_START:
				begin

					pe_out_write_to_sys_mem_go	<= 1'b0;
					if(pe_out_write_to_sys_mem_done)
						write_fsm	<=	STATE_WRITE_PE_OUT_END;
					else
						write_fsm	<=	write_fsm;
				end
			STATE_WRITE_PE_OUT_END:
				begin				
					write_fsm					<=		STATE_WRITE_IDLE;
					pe_out_write_to_sys_mem_go	<=		1'b0;
				end
			default:
					write_fsm		<=			write_fsm;
		endcase
		
		// PE DMU
		case(pe_dmu_fsm)	/* synthesis parallel_case */  //for read response valid
			STATE_DMU_IDLE:
				begin
				a_mem_channel_wr_req		<=	1'b0;	
				a_mem_channel_data_in		<=	0;
				b_mem_channel_wr_req		<=	1'b0;	
				b_mem_channel_data_in		<=	0;
				num_el_2_a_mem				<=	0;
				num_el_2_b_mem				<=	0;
				
				if(re2xy_go)
							pe_dmu_fsm 		<= 	STATE_FILL_A_MEM_CHANNEL;
				else
					pe_dmu_fsm				<=	pe_dmu_fsm;
				end
			// Fill A Memory in FPGA
			STATE_FILL_A_MEM_CHANNEL:
				begin					

					//if(ab2l1_RdRspValid && num_el_2_a_mem==NUM_ROWS*256)
					if(ab2l1_RdRspValid && num_el_2_a_mem==num_rows_x_block_size)
						begin
							b_mem_channel_wr_req			<=	1'b1;
							b_mem_channel_data_in			<=	ab2l1_RdData;
							b_mem_channel_addr_in			<=	ab2l1_RdRspAddr;
							pe_dmu_fsm						<=	STATE_FILL_B_MEM_CHANNEL;
							num_el_2_a_mem					<=	1'b0;
							num_el_2_b_mem					<=	1'b1;
							a_mem_channel_wr_req			<=	1'b0;
						    a_mem_channel_data_in			<=	0;
						    a_mem_channel_addr_in			<=	0;
						end
					else if(ab2l1_RdRspValid)
						begin
							a_mem_channel_wr_req			<=	1'b1;
							a_mem_channel_data_in			<=	ab2l1_RdData;
							a_mem_channel_addr_in			<=	ab2l1_RdRspAddr;
							num_el_2_a_mem					<=	num_el_2_a_mem + 1;
							b_mem_channel_wr_req			<=	1'b0;
							b_mem_channel_data_in			<=	0;
							b_mem_channel_addr_in			<=	0;
						end
					else
						begin
						    a_mem_channel_wr_req			<=	1'b0;
						    a_mem_channel_data_in			<=	0;
						    a_mem_channel_addr_in			<=	0;
							//if(num_el_2_a_mem == NUM_ROWS*256)
							if(num_el_2_a_mem == num_rows_x_block_size)
							begin
								pe_dmu_fsm					<=	STATE_FILL_B_MEM_CHANNEL;
								num_el_2_a_mem				<=	0;
							end
							b_mem_channel_wr_req			<=	1'b0;
							b_mem_channel_data_in			<=	0;
							b_mem_channel_addr_in			<=	0;						
						end

				end
			STATE_FILL_B_MEM_CHANNEL:
				begin
					
					if(ab2l1_RdRspValid && num_el_2_b_mem == NUM_COL*256)
					//if(ab2l1_RdRspValid && num_el_2_b_mem == num_col_x_block_size)
					
						begin
							a_mem_channel_wr_req			<=	1'b1;
							a_mem_channel_data_in			<=	ab2l1_RdData;
							a_mem_channel_addr_in			<=	ab2l1_RdRspAddr;
							pe_dmu_fsm						<=	STATE_FILL_A_MEM_CHANNEL;
							num_el_2_a_mem					<=	1'b1;
							num_el_2_b_mem					<=	1'b0;
							b_mem_channel_wr_req			<=	1'b0;
							b_mem_channel_data_in			<=	0;
							b_mem_channel_addr_in			<=	0;
						end	
					else if(ab2l1_RdRspValid)
						begin
							b_mem_channel_wr_req			<=	1'b1;
							b_mem_channel_data_in			<=	ab2l1_RdData;
							b_mem_channel_addr_in			<=	ab2l1_RdRspAddr;
							num_el_2_b_mem					<=	num_el_2_b_mem +1;
							a_mem_channel_wr_req			<=	1'b0;	
							a_mem_channel_data_in			<=	0;
						end				
					else
						begin
						b_mem_channel_wr_req				<=	1'b0;
						b_mem_channel_data_in				<=	0;
						b_mem_channel_addr_in				<=	0;
						a_mem_channel_wr_req				<=	1'b0;	
						a_mem_channel_data_in				<=	0;
						//if(num_el_2_b_mem == NUM_COL*256)
						if(num_el_2_b_mem == num_col_x_block_size)
						
							begin
								pe_dmu_fsm					<=	STATE_FILL_A_MEM_CHANNEL;
								num_el_2_b_mem				<=	1'b0;							
							end
						end
				end
			default:
					pe_dmu_fsm		<=			pe_dmu_fsm;
		endcase
/////////////////////////////////////////////////////////////	
		case(pe_out_write_sys_mem_fsm) /*synthesis parallel_case */
		STATE_PE_OUT_WRITE_SYS_MEM_IDLE	:
			begin
				pe_out_wr_addr					<=		wr_addr_offset;//0;
				pe_out_write_to_sys_mem_done	<=		0;
				pe_out_wr_addr_gen				<=		0;
				
				pe_out_write_to_sys_mem_wr_en	<= 		0;
				if(pe_out_write_to_sys_mem_go)
					begin
					pe_out_write_sys_mem_fsm	<= STATE_PE_OUT_WRITE_SYS_MEM_SEND_REQ;
					pe_write_fifo_rd_req	<=	1'b1;
					end
				else
					pe_out_write_sys_mem_fsm	<= pe_out_write_sys_mem_fsm;			
			end
		STATE_PE_OUT_WRITE_SYS_MEM_SEND_REQ:
			begin
			pe_out_wr_addr_gen				<= 1'b1;
			pe_out_write_to_sys_mem_wr_en	<= 1'b1;

				if(!pe_out_valid[0] && pe_write_fifo_empty)
					pe_out_write_sys_mem_fsm	<= STATE_PE_OUT_WRITE_SYS_MEM_DONE;
				else if(ab2l1_WrAlmFull)
					begin
						pe_out_write_to_sys_mem_wr_en	<= 1'b0;
						pe_write_fifo_rd_req			<= 1'b0;
						pe_out_write_sys_mem_fsm		<= STATE_PE_OUT_WRITE_SYS_MEM_WAIT;
					end
				else
					pe_out_write_sys_mem_fsm	<= pe_out_write_sys_mem_fsm;						
			end
		STATE_PE_OUT_WRITE_SYS_MEM_WAIT:
			begin
				if(!ab2l1_WrAlmFull)
					begin
						pe_out_write_to_sys_mem_wr_en	<= 1'b1;
						pe_write_fifo_rd_req			<= 1'b1;						
						pe_out_write_sys_mem_fsm		<= STATE_PE_OUT_WRITE_SYS_MEM_SEND_REQ;
					end
				else
					pe_out_write_sys_mem_fsm	<= pe_out_write_sys_mem_fsm;
			
			end	
		STATE_PE_OUT_WRITE_SYS_MEM_DONE:
			begin
				pe_out_write_sys_mem_fsm		<= 	STATE_PE_OUT_WRITE_SYS_MEM_IDLE;
				pe_write_fifo_rd_req			<=	0;
				pe_out_write_to_sys_mem_done	<=	1'b1;
				pe_out_write_to_sys_mem_wr_en	<= 	0;
				num_block_C						<=  num_block_C +1'b1;				
			end
		endcase
/////////////////////////////////////

		 if(l12ab_RdEn && ab2l1_RdSent)
		 begin
			//if((num_workspace_switch==0 && rd_mdata==NUM_ROWS*256-1)||(num_workspace_switch==1 && rd_mdata==NUM_COL*256-1)) //change for shadow/higher part
			if((num_workspace_switch==0 && rd_mdata==num_rows_x_block_size-1)||(num_workspace_switch==1 && rd_mdata==num_rows_x_block_size-1)) //change for shadow/higher part
			
				rd_mdata<=0;
			else
				rd_mdata<= rd_mdata+1'b1;	
		 end

		//WrTID Generation Logic
		if(l12ab_WrEn && ab2l1_WrSent_x)
                    wr_mdata   					<= wr_mdata + 1'b1;		
		//Write Response Count
		if(ab2l1_WrRspValid)
		begin
			//if((NUM_ROWS*1024)==Num_Write_rsp)
			//	Num_Write_rsp<= 16'b1;			
			//else
				Num_Write_rsp<= Num_Write_rsp+1'b1;
		end
		
		//if((NUM_ROWS*1024)==Num_Write_rsp && num_workload_A==0 && num_workload_B==re2xy_NumPartsB)
		//if((NUM_ROWS*1024)*re2xy_NumPartsA*re2xy_NumPartsB==Num_Write_rsp && (num_workload_B>0 ||num_workload_A>0))
		  if(test_complete_flag1==Num_Write_rsp && (num_workload_B>0 ||num_workload_A>0))
		//  if((NUM_ROWS*1024)*re2xy_NumPartsA*2==Num_Write_rsp && (num_workload_B>0 ||num_workload_A>0)) 	
			l12ab_TestCmp				<=	1'b1;		
		//if(write_fsm ==STATE_WRITE_PE_OUT_END)
		//	l12ab_TestCmp				<=	1'b1;
		
		// Error Generation Logic
		if(l12ab_WrEn && ab2l1_WrSent==0)
           begin
              // WrFSM assumption is broken
               $display ("%m LPBK1 test WrEn asserted, but request Not accepted by requestor");
               l12ab_ErrorValid <= 1'b1;
               l12ab_ErrorInfo  <= 1'b1;
           end

		if(!test_Resetb)
			begin
		        l12ab_WrAddr            		<= 		0;
		        l12ab_WrEn						<=		0;
		        l12ab_RdAddr            		<= 		0;
		        //A_RdAddr_offset            		<= 		0;
		        //B_RdAddr_offset            		<= 		0;		        
		        l12ab_TestCmp           		<= 		0;
		        l12ab_ErrorInfo         		<= 		0;
				l12ab_WrFence					<=		0;
		        l12ab_ErrorValid        		<= 		0;
		        read_fsm                		<= 		0;
		        write_fsm               		<= 		0;
				pe_dmu_fsm						<=		0;
				pe_out_write_sys_mem_fsm		<=		0;
		        rd_mdata                		<= 		0;

		        wr_mdata                		<= 		0;
		        Num_Read_req            		<= 		16'h1;   
		        Num_Write_req           		<= 		16'h1;  
				Num_Write_rsp           		<= 		0;					

				a_mem_channel_wr_req			<=		0;	
				a_mem_channel_addr_in			<=		0;
				b_mem_channel_wr_req			<=		0;
				b_mem_channel_addr_in			<=		0;
				
				//pe_data_channel_sel				<=		0;
				pe_addr_channel_sel				<=		0;

				num_workspace_switch			<=		0;
				num_workload_A					<=		0;
				num_workload_B					<=		0;
				num_block_C						<=		0;				
				a_b_workspace_sel				<=		0;
				c_dst_workspace_sel				<=		0;
				num_el_2_a_mem					<=		0;
				num_el_2_b_mem					<=		0;
				no_data_hazard					<=		1;
				num_elements_to_pe				<=		0;
				num_elements_processed_by_pe	<=		0;
				pe_out_gather_go				<=		0;
				pe_gather_done					<=		0;
				pe_out_write_to_sys_mem_go		<=		0;
				pe_out_wr_addr_gen				<=		0;
				pe_out_write_to_sys_mem_done	<=		0;
				pe_out_write_to_sys_mem_wr_en   <=      0;				
				sclr							<=		1;
				pe_write_fifo_el_count			<=		0;
				pe_write_fifo_fsm_go			<=		0;
				pe_write_fifo_rd_req			<=		0;
				pe_write_fifo_rd_req_q			<=		0;
				pe_write_fifo_wr_req			<=		0;
				
				pe_write_fifo_empty_q			<=		0;		
				writes_fifo_full				<=		1'b0;
				
			end
		else
			begin
				pe_write_fifo_rd_req_q	<= pe_write_fifo_rd_req;				
				writes_fifo_full		<= pe_write_fifo_almost_full;// full or almost_full
				pe_write_fifo_wr_req	<= pe_out_valid[0];
				pe_write_fifo_empty_q	<= pe_write_fifo_empty;
				
				l12ab_WrEn 				<= pe_write_fifo_rd_req_q & !pe_write_fifo_empty_q;
				
				
				l12ab_WrAddr			<= pe_out_wr_addr;
				l12ab_WrDin				<= pe_write_fifo_out;
				if(pe_write_fifo_rd_req_q)
					pe_out_wr_addr			<= pe_out_wr_addr+1'b1; 
			end
			
end

always @(*)
begin
        l12ab_WrTID 						= 		0;
        l12ab_RdTID 						= 		0;
        l12ab_WrTID[MDATA-1:0] 				= 		wr_mdata;
        l12ab_RdTID[MDATA-1:0] 				= 		rd_mdata;
		
        //l12ab_RdEn = (read_fsm  ==2'h1) & !ab2l1_stallRd;// & rd_mdata_avail;  //error for 3th input block - writes for full feeder
        l12ab_RdEn = (read_fsm  ==2'h1) & !ab2l1_stallRd & ((!num_workspace_switch[0] & !a_mem_channel_full) | (num_workspace_switch[0] & !b_mem_channel_full));

        //l12ab_WrEn =  pe_write_fifo_rd_req;
		//l12ab_WrEn =  (write_fsm == STATE_WRITE_SEND_REQ || pe_out_write_to_sys_mem_wr_en==1'b1);
		//l12ab_WrEn = (write_fsm ==2'h1);
end

genvar k;
wire [511:0] write_data;
generate
	for(k=0; k<16; k=k+1)
		begin: WRITE_CL	
			if (k<NUM_COL)	
				assign 	write_data[(k+1)*32-1:k*32] = pe_out_block[k];// b_from_feeders[((k*256)+((l+1)*32-1)):((k*256)+(l*32))];			  
			else		
				assign 	write_data[(k+1)*32-1:k*32] = 32'h00000000;
		end
endgenerate
// Instantiate Write FIFO
pe_out_fifo		PE_OUT_FIFO
(
	//.data			({448'b0,pe_out_block[1],pe_out_block[0]}),//pe_write_fifo_reg),      
	.data			(write_data),      
    .wrreq			(pe_out_valid[0]),
    .rdreq			(pe_write_fifo_rd_req),     
    .clock			(Clk_16UI),     
    .q				(pe_write_fifo_out),         
    .usedw			(pe_wite_fifo_usedw),     
    .full			(pe_write_fifo_full),      
    .empty			(pe_write_fifo_empty),     
    .almost_full	(pe_write_fifo_almost_full)
);
endmodule
