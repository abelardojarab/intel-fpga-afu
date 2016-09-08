//synopsys translate off
`timescale 1 ns /1 ns
//synopsys translate on

module				pe_9x9_mem_ctrl_autogen #(
	parameter	DATA_WIDTH			= 32,
    parameter	PE_LATENCY			= 4,
    parameter	DATA_WIDTH_CONTROL	= 1,
    parameter	NUM_WORDS_MEM       = 4096,
    parameter	A_SHIFT_LATENCY     = 4,
    parameter	B_SHIFT_LATENCY		= 4,
    parameter	NUM_ROWS			= 9,
    parameter	NUM_COL				= 9
)
(
	clk,
    rst,
    //	Control Signals for PE
    en_in,
    //	Write Interface
    wr_data_a_mem,
    wr_data_b_mem,
    wr_en_a_mem,
    wr_en_b_mem,
    // Read Memory Control Signals
    sclr,
    workloads_num,	
    //	PE Output Signals
    pe_out_block,
    pe_out_valid,
    feeders_a_full,
    feeders_b_full,
    writes_fifo_full
);

localparam			ADDR_WIDTH		=		$clog2(NUM_WORDS_MEM);
genvar	i,j;

input								clk;
input								rst;
//PE Control Signals

//input	[DATA_WIDTH_CONTROL-1:0]	acc_in [NUM_ROWS-1:0];
input								en_in;//  [NUM_ROWS-1:0];
input			[31:0]				workloads_num;
//Write Interface
input			[511:0]				wr_data_a_mem;//[NUM_ROWS-1:0];
input			[511:0]				wr_data_b_mem;//[NUM_COL-1:0];
input								wr_en_a_mem;//	 [NUM_ROWS-1:0];
input								wr_en_b_mem;//	 [NUM_COL-1:0];

input								writes_fifo_full;

// Read Interface Control Signals
input								sclr;		

// PE Output Signal
//output			[DATA_WIDTH-1:0]	pe_out_block[NUM_ROWS-1:0][NUM_COL-1:0];
output			[DATA_WIDTH-1:0]	pe_out_block[NUM_COL-1:0];
output   							pe_out_valid[NUM_COL-1:0];
output								feeders_a_full;
output								feeders_b_full;

// Register the reset path before passsing it to the SGEMM2 Core
logic 								rst_T;
always @(posedge clk)
	begin
		rst_T	<=	rst;
	end

// Register the workloads_num before passing it to SGEMM2 Core
logic		[DATA_WIDTH-1:0]		workloads_num_T;
always @(posedge clk)
begin
workloads_num_T			<=	workloads_num;

end	
// Instantiate the PE_NUM_ROWS_NUM_COL_MEM	Module

pe_9x9_mem_autogen			#(
	.DATA_WIDTH			(DATA_WIDTH		  	),
    .PE_LATENCY			(PE_LATENCY		    ),
    .DATA_WIDTH_CONTROL	(DATA_WIDTH_CONTROL	),
    .A_SHIFT_LATENCY	(A_SHIFT_LATENCY    ),
    .B_SHIFT_LATENCY 	(B_SHIFT_LATENCY    ),
    .NUM_ROWS			(NUM_ROWS		    ),
    .NUM_COL			(NUM_COL		    ),
    .NUM_WORDS_MEM		(NUM_WORDS_MEM	    )
)PE_ARRAY
(
	.clk			(clk),
    .rst			(rst_T),

    .en_in			(en_in),
    .workloads_num	(workloads_num_T),
    .wr_data_a_mem	(wr_data_a_mem),
    .wr_data_b_mem	(wr_data_b_mem),

    .wr_en_a_mem	(wr_en_a_mem),
    .wr_en_b_mem	(wr_en_b_mem),
    
    .writes_fifo_full(writes_fifo_full),
    //.rd_addr_a_mem	(rd_addr_mem_a),
    //.rd_addr_b_mem	(rd_addr_mem_b),
    .pe_out_block	(pe_out_block),
    .pe_out_valid	(pe_out_valid),
    .feeders_a_full	(feeders_a_full),
    .feeders_b_full	(feeders_b_full)
);
endmodule		
