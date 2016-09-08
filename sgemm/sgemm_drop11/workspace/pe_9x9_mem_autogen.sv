//synopsys translate off
`timescale 1 ns /1 ns
//synopsys translate on
module		pe_9x9_mem_autogen #(
	parameter	DATA_WIDTH			= 32,
    parameter	PE_LATENCY			= 1,
    parameter	DATA_WIDTH_CONTROL	= 3,
    parameter	A_SHIFT_LATENCY		= 1,
    parameter	B_SHIFT_LATENCY 	= 1,
	parameter	NUM_ROWS			= 2,
	parameter	NUM_COL				= 2,
	parameter	NUM_WORDS_MEM		= 4096,
	parameter	DOT					= 8
)
(
	clk,
	rst,
	//PE Control signals
	en_in,
	workloads_num,
	//Write Interface
	wr_data_a_mem,
	wr_data_b_mem,
	//wr_addr_a_mem,  //without VTP
	//wr_addr_b_mem,	
	wr_en_a_mem,
	wr_en_b_mem,
	
	writes_fifo_full,
	//PE output signal
	pe_out_block,
	pe_out_valid,
	feeders_a_full,
	feeders_b_full
);
localparam			ADDR_WIDTH 		=	$clog2(NUM_WORDS_MEM);

input								clk;
input								rst;
//PE Control Signals
input 			[31:0]				workloads_num;
//input	[DATA_WIDTH_CONTROL-1:0]	acc_in [NUM_ROWS-1:0];
input								en_in;//  [NUM_ROWS-1:0];

//Write Interface
input			[511:0]	wr_data_a_mem;//[NUM_ROWS-1:0];
input			[511:0]	wr_data_b_mem;//[NUM_COL-1:0];
//input			[11:0]	wr_addr_a_mem;
//input			[11:0]	wr_addr_b_mem;
input								wr_en_a_mem;//	 [NUM_ROWS-1:0];
input								wr_en_b_mem;//	 [NUM_COL-1:0];

input								writes_fifo_full;

// PE Output Signal

output			[DATA_WIDTH-1:0]	pe_out_block[NUM_COL-1:0];
output   							pe_out_valid[NUM_COL-1:0];

output								feeders_a_full;
output  	 						feeders_b_full;

// Internal Wires
wire			[DATA_WIDTH-1:0]	a_mem_out[NUM_ROWS-1:0];
wire			[DATA_WIDTH-1:0]	b_mem_out[NUM_COL-1:0];

// Wires for FOR GEN

wire			[DATA_WIDTH-1:0]	pe_out [NUM_ROWS-1:0][NUM_COL-1:0];
wire								pe_valid [NUM_ROWS-1:0][NUM_COL-1:0];
wire			[DATA_WIDTH-1:0]	pe_out_block_from_SA [NUM_COL-1:0];
wire	    						pe_out_valid_from_SA [NUM_COL-1:0];



wire			[DATA_WIDTH-1:0]	a_in   [DOT-1:0][NUM_ROWS:0][NUM_COL:0];
wire			[DATA_WIDTH-1:0]	b_in   [DOT-1:0][NUM_ROWS:0][NUM_COL:0];

wire	[DATA_WIDTH_CONTROL-1:0]	acc	   [NUM_ROWS:0][NUM_COL:0];
wire								en	   [NUM_ROWS:0][NUM_COL:0];
wire								reset_sa	   [NUM_ROWS:0][NUM_COL:0];
wire								writes_fifo_full_in [NUM_ROWS:0][NUM_COL:0];

genvar k,l,i,j;

//Instantiate control unit
wire cache_fifo_write;
wire cache_fifo_read;
wire results_fifo_write;
wire memory_read;
wire mem_a_loaded;
wire mem_b_loaded;
//wire feeders_a_full;
//wire feeders_b_full;
wire start_calc;


//Register the workload num before passing it to SGEMM2 core
logic		[DATA_WIDTH-1:0]	workloads_num_T;
always @(posedge clk)
begin
	workloads_num_T		<= workloads_num;
end
//Register the input reset signal before passing it to Control unit/Feeders
logic						reset_T;
always @(posedge clk) 
        reset_T<=rst;

control_unit 				#
(
	.NUM_ROWS   (NUM_ROWS),
    .NUM_COL	(NUM_COL),
	.DATA_WIDTH	(DATA_WIDTH)
) CU
	(
		.clk     				(clk),    
		.reset   				(rst),
		.en						(en_in),//[0][0]),
		.loaded_a				(mem_a_loaded),
		.loaded_b				(mem_b_loaded),
		.workloads_num			(workloads_num_T), 
		.cache_fifo_write		(cache_fifo_write),	
		.cache_fifo_read	 	(cache_fifo_read),
		.results_fifo_write   	(results_fifo_write),
		.read_mem				(memory_read),
		.feeders_a_full			(feeders_a_full),
		.feeders_b_full			(feeders_b_full),
		.start_calc				(start_calc)//,
		//.pe_reset				(pe_reset_cu)
	); 
//Timing optimization

// Assignments for RST Signal

assign reset_sa[0][0]= reset_T;
generate
	for(k=1; k<NUM_ROWS; k=k+1)
	begin: RST_SIGNAL				
      param_delay			#(
      .DEPTH(PE_LATENCY),
      .WIDTH(1)

      )RST_FOR_ROWS
      (
	      .clock		(clk),
          .reset		(rst),
          .data_in	(reset_sa[k-1][0]),
          .data_out   (reset_sa[k][0])
      );
	end
endgenerate

// Assignments for EN Signal

assign en[0][0]= start_calc;
generate
	for(k=1; k<NUM_ROWS; k=k+1)
	begin: EN_SIGNAL				//delay for SA rows
      param_delay			#(
      .DEPTH(PE_LATENCY),
      .WIDTH(1)

      )EN_SHIFT_FOR_ROWS
      (
	      .clock		(clk),
          .reset		(reset_T),
          .data_in	(en[k-1][0]),
          .data_out   (en[k][0])
      );
	end
endgenerate

assign		acc[0][0] = {results_fifo_write,cache_fifo_read,cache_fifo_write}; //from Control Unit
generate
	for(k=1; k<NUM_ROWS; k=k+1)
	begin: PE_CONTROL_SIGNALS				//delay for SA rows
      param_delay			#(
      .DEPTH(PE_LATENCY),
      .WIDTH(DATA_WIDTH_CONTROL)

      )CS_SHIFT_FOR_ROWS
      (
	      .clock		(clk),
          .reset		(reset_T),
          .data_in	(acc[k-1][0]),
          .data_out   (acc[k][0])
      );
	end
endgenerate

// Instantiate Delay element for PE_OUT
assign pe_out_block[NUM_COL-1]=pe_out_block_from_SA[NUM_COL-1];
generate
	for(k=0; k<NUM_COL-1; k=k+1)
	begin: PE_OUT_REGS				//delay for SA rows
      param_delay			#(
      .DEPTH(NUM_COL-k-1),
      .WIDTH(DATA_WIDTH)

      )EN_SHIFT_FOR_ROWS
      (
	      .clock		(clk),
          .reset		(reset_T),
          .data_in	(pe_out_block_from_SA[k]),
          .data_out   (pe_out_block[k])
      );
	
	end
endgenerate
assign pe_out_valid[NUM_COL-1]=pe_out_valid_from_SA[NUM_COL-1];
generate
	for(k=0; k<NUM_COL-1; k=k+1)
	begin: PE_OUT_VALID_REGS				//delay for SA rows
      param_delay			#(
      .DEPTH(NUM_COL-k-1),
      .WIDTH(1)

      )EN_SHIFT_FOR_ROWS
      (
	      .clock		(clk),
          .reset		(reset_T),
          .data_in	(pe_out_valid_from_SA[k]),
          .data_out   (pe_out_valid[k])
      );
	end
endgenerate

//A feeders_a
wire [(NUM_ROWS*256)-1:0] a_from_feeders;

feeders_a #(
	.NUM_ROWS(NUM_ROWS)
)
A_FEEDERS
(
		.reset(reset_T),
		.clk(clk),    
//		.en(),
		.wr_en(wr_en_a_mem),
		.data_in(wr_data_a_mem),
//		.wr_addr_in(wr_addr_a_mem),
		.rd_en(memory_read),
		.data_out(a_from_feeders),
		.a_loaded(mem_a_loaded),
		.feeders_a_full(feeders_a_full)
	);
// Assignment for A_Memory-> A_IN

generate 

	for( k=0; k<NUM_ROWS; k=k+1)
		begin: A_IN_REGS
		  for( l=0; l<DOT; l=l+1)
			begin:A_R	 
				assign	a_in[l][k][0] = a_from_feeders[((k*256)+((l+1)*32-1)):((k*256)+(l*32))];
			end      	
		end
endgenerate

wire [(NUM_COL*256)-1:0] b_from_feeders;   
feeders_b #(
	.NUM_COL(NUM_COL)
)
B_FEEDERS
(
		.reset(reset_T),
		.clk(clk),    
//		.en(),
		.wr_en(wr_en_b_mem),
		.data_in(wr_data_b_mem),
//		.wr_addr_in(wr_addr_b_mem),
		.rd_en(memory_read),
		.data_out(b_from_feeders),
		.b_loaded(mem_b_loaded),
		.feeders_b_full(feeders_b_full)
	);
// Assignment for B_Memory -> B_IN
generate
	for(k=0; k<NUM_COL; k=k+1)
		begin: B_IN
			for( l=0; l<DOT; l=l+1)
				begin :B_R
					assign 	b_in[l][0][k] = b_from_feeders[((k*256)+((l+1)*32-1)):((k*256)+(l*32))];			  
				end
		end
endgenerate


// latency for writes_fifo_full for first row
//assign writes_fifo_full_in[0][NUM_COL-1]=writes_fifo_full;
assign writes_fifo_full_in[0][0]=writes_fifo_full;						//danger - the difference between writes_fifo _full - writes_fifo_almost_full > NUM_COL because of additional latency regiser for pe_out_valid
generate
	for(k=1; k<NUM_COL; k=k+1)
		begin: REGS_FIFO_FULL
      param_delay			#(
      .DEPTH(k),
      .WIDTH(1)

      )W_FIFO_FULL_SHIFT_FOR_COL
      (
	      .clock		(clk),
          .reset		(reset_T),
          .data_in	(writes_fifo_full),
          .data_out   (writes_fifo_full_in[0][k])
      );			

		end
endgenerate


// PE will be generated in NUM_ROWS X NUM_COL

generate
	for(i=0 ;i< NUM_ROWS;i=i+1)
		begin : ROWS_DOT8
			for(j=0;j<NUM_COL;j=j+1)
				begin: COL_DOT8			
					if (i==0)
						begin:	PE_DOT8_1_ROW
						    proc_elem 
						    #(
								.DATA_WIDTH			(DATA_WIDTH		  	),
								.PE_LATENCY			(PE_LATENCY		    )
							)	 PE
							(
								.clk     		(clk),    
								//.reset   		(rst),//reset_for_pe[i]),// rst), 
								//.reset   		(pe_reset_cu_T[i]),
								.reset     		(reset_sa[i][j]),
								.reset_out		(reset_sa[i][j+1]),								
								.en      		(en[i][j]),
								.en_out			(en[i][j+1]),
								.workloads_num	(workloads_num_T),
								//.writes_fifo_full(writes_fifo_full),
								.writes_fifo_full(writes_fifo_full_in[0][j]),
																
								.a1_in		 	(a_in[0][i][j]),    
								.b1_in      	(b_in[0][i][j]),      
								.a2_in		 	(a_in[1][i][j]),    
								.b2_in      	(b_in[1][i][j]), 
								.a3_in		 	(a_in[2][i][j]),    
								.b3_in      	(b_in[2][i][j]), 
								.a4_in		 	(a_in[3][i][j]),    
								.b4_in      	(b_in[3][i][j]), 				
								.a5_in		 	(a_in[4][i][j]),    
								.b5_in      	(b_in[4][i][j]),      
								.a6_in		 	(a_in[5][i][j]),    
								.b6_in      	(b_in[5][i][j]), 
								.a7_in		 	(a_in[6][i][j]),    
								.b7_in      	(b_in[6][i][j]), 								
								.a8_in		 	(a_in[7][i][j]),    
								.b8_in      	(b_in[7][i][j]),
								
								.a1_out		 	(a_in[0][i][j+1]),    
								.b1_out      	(b_in[0][i+1][j]),      
								.a2_out		 	(a_in[1][i][j+1]),    
								.b2_out      	(b_in[1][i+1][j]), 
								.a3_out		 	(a_in[2][i][j+1]),    
								.b3_out      	(b_in[2][i+1][j]), 
								.a4_out		 	(a_in[3][i][j+1]),    
								.b4_out      	(b_in[3][i+1][j]), 				
								.a5_out		 	(a_in[4][i][j+1]),    
								.b5_out      	(b_in[4][i+1][j]),      
								.a6_out		 	(a_in[5][i][j+1]),    
								.b6_out      	(b_in[5][i+1][j]), 
								.a7_out		 	(a_in[6][i][j+1]),    
								.b7_out      	(b_in[6][i+1][j]), 
								.a8_out		 	(a_in[7][i][j+1]),    
								.b8_out      	(b_in[7][i+1][j]),
								.c_in	 		(pe_out[i+1][j]),
								.c_in_valid		(pe_valid[i+1][j]),	
								//.c_out   		(pe_out_block[j]),    
								//.c_out_valid 	(pe_out_valid[j]),
								.c_out   		(pe_out_block_from_SA[j]),    
								.c_out_valid 	(pe_out_valid_from_SA[j]),								
								.cache_fifo_read    (acc[i][j][1]),
								.cache_fifo_write	(acc[i][j][0]),
								.results_fifo_write	(acc[i][j][2]),
								.cache_fifo_read_out    (acc[i][j+1][1]),
								.cache_fifo_write_out	(acc[i][j+1][0]),
								.results_fifo_write_out	(acc[i][j+1][2]),
								.writes_fifo_full_out (writes_fifo_full_in[i+1][j])
							); 
						
						end
					else if (i==NUM_ROWS-1)
						begin:	PE_DOT8_LAST_ROW
						    proc_elem  
						    #(
								.DATA_WIDTH			(DATA_WIDTH		  	),
								.PE_LATENCY			(PE_LATENCY		    )
							)	PE

							(
								.clk     		(clk),    
								//.reset   		(rst),//reset_for_pe[i]),// rst), 
								//.reset   		(pe_reset_cu_T[i]),
								.reset     		(reset_sa[i][j]),
								.reset_out		(reset_sa[i][j+1]),								
								.en      		(en[i][j]),
								.en_out			(en[i][j+1]),
								.workloads_num	(workloads_num_T),
								.writes_fifo_full(writes_fifo_full_in[i][j]),
								
								.a1_in		 	(a_in[0][i][j]),    
								.b1_in      	(b_in[0][i][j]),      
								.a2_in		 	(a_in[1][i][j]),    
								.b2_in      	(b_in[1][i][j]), 
								.a3_in		 	(a_in[2][i][j]),    
								.b3_in      	(b_in[2][i][j]), 
								.a4_in		 	(a_in[3][i][j]),    
								.b4_in      	(b_in[3][i][j]), 				
								.a5_in		 	(a_in[4][i][j]),    
								.b5_in      	(b_in[4][i][j]),      
								.a6_in		 	(a_in[5][i][j]),    
								.b6_in      	(b_in[5][i][j]), 
								.a7_in		 	(a_in[6][i][j]),    
								.b7_in      	(b_in[6][i][j]), 								
								.a8_in		 	(a_in[7][i][j]),    
								.b8_in      	(b_in[7][i][j]),
								
								.a1_out		 	(a_in[0][i][j+1]),    
								.b1_out      	(b_in[0][i+1][j]),      
								.a2_out		 	(a_in[1][i][j+1]),    
								.b2_out      	(b_in[1][i+1][j]), 
								.a3_out		 	(a_in[2][i][j+1]),    
								.b3_out      	(b_in[2][i+1][j]), 
								.a4_out		 	(a_in[3][i][j+1]),    
								.b4_out      	(b_in[3][i+1][j]), 				
								.a5_out		 	(a_in[4][i][j+1]),    
								.b5_out      	(b_in[4][i+1][j]),      
								.a6_out		 	(a_in[5][i][j+1]),    
								.b6_out      	(b_in[5][i+1][j]), 
								.a7_out		 	(a_in[6][i][j+1]),    
								.b7_out      	(b_in[6][i+1][j]), 
								.a8_out		 	(a_in[7][i][j+1]),    
								.b8_out      	(b_in[7][i+1][j]),
								.c_in	 		(32'h00000000),
								.c_in_valid		(1'b0),	
								.c_out   		(pe_out[i][j]),    
								.c_out_valid 	(pe_valid[i][j]),
								
								.cache_fifo_read    (acc[i][j][1]),
								.cache_fifo_write	(acc[i][j][0]),
								.results_fifo_write	(acc[i][j][2]),
								.cache_fifo_read_out    (acc[i][j+1][1]),
								.cache_fifo_write_out	(acc[i][j+1][0]),
								.results_fifo_write_out	(acc[i][j+1][2])
							); 
						
						end
					
					else
						begin :PE_DOT8_REST
						    proc_elem  
						    #(
								.DATA_WIDTH			(DATA_WIDTH		  	),
								.PE_LATENCY			(PE_LATENCY		    )
							)	PE

							(
								.clk     		(clk),    
								//.reset   		(rst),//reset_for_pe[i]),// rst), 
								//.reset   		(pe_reset_cu_T[i]),
								.reset     		(reset_sa[i][j]),
								.reset_out		(reset_sa[i][j+1]),								
								.en      		(en[i][j]),
								.en_out			(en[i][j+1]),
								.workloads_num	(workloads_num_T),
								.writes_fifo_full(writes_fifo_full_in[i][j]),
																
								.a1_in		 	(a_in[0][i][j]),    
								.b1_in      	(b_in[0][i][j]),      
								.a2_in		 	(a_in[1][i][j]),    
								.b2_in      	(b_in[1][i][j]), 
								.a3_in		 	(a_in[2][i][j]),    
								.b3_in      	(b_in[2][i][j]), 
								.a4_in		 	(a_in[3][i][j]),    
								.b4_in      	(b_in[3][i][j]), 				
								.a5_in		 	(a_in[4][i][j]),    
								.b5_in      	(b_in[4][i][j]),      
								.a6_in		 	(a_in[5][i][j]),    
								.b6_in      	(b_in[5][i][j]), 
								.a7_in		 	(a_in[6][i][j]),    
								.b7_in      	(b_in[6][i][j]), 								
								.a8_in		 	(a_in[7][i][j]),    
								.b8_in      	(b_in[7][i][j]),
								
								.a1_out		 	(a_in[0][i][j+1]),    
								.b1_out      	(b_in[0][i+1][j]),      
								.a2_out		 	(a_in[1][i][j+1]),    
								.b2_out      	(b_in[1][i+1][j]), 
								.a3_out		 	(a_in[2][i][j+1]),    
								.b3_out      	(b_in[2][i+1][j]), 
								.a4_out		 	(a_in[3][i][j+1]),    
								.b4_out      	(b_in[3][i+1][j]), 				
								.a5_out		 	(a_in[4][i][j+1]),    
								.b5_out      	(b_in[4][i+1][j]),      
								.a6_out		 	(a_in[5][i][j+1]),    
								.b6_out      	(b_in[5][i+1][j]), 
								.a7_out		 	(a_in[6][i][j+1]),    
								.b7_out      	(b_in[6][i+1][j]), 
								.a8_out		 	(a_in[7][i][j+1]),    
								.b8_out      	(b_in[7][i+1][j]),
								.c_in	 		(pe_out[i+1][j]),
								.c_in_valid		(pe_valid[i+1][j]),	
								.c_out   		(pe_out[i][j]),    
								.c_out_valid 	(pe_valid[i][j]),
								
								.cache_fifo_read    (acc[i][j][1]),
								.cache_fifo_write	(acc[i][j][0]),
								.results_fifo_write	(acc[i][j][2]),
								.cache_fifo_read_out    (acc[i][j+1][1]),
								.cache_fifo_write_out	(acc[i][j+1][0]),
								.results_fifo_write_out	(acc[i][j+1][2]),
								.writes_fifo_full_out (writes_fifo_full_in[i+1][j])
							); 
						end
					
				end
		end
endgenerate


endmodule
