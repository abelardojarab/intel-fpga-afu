`timescale 1 ps / 1 ps
module control_unit
#(
  parameter WORKLOADS_NUM = -1 , //numbers of input feeder workloads -> blocks of A & B for complete C calculations -> from input matrices sizes
								// probably will be implemented as input
  parameter	NUM_ROWS			= -1,
  parameter	NUM_COL				= -1,
  parameter DATA_WIDTH			= -1
)
(
		input reset,
		input       				clk,    
		input   [0:0] 				en,
		input 	loaded_a,
		input	loaded_b,
		input   feeders_a_full,
		input   feeders_b_full,
		input	[31:0] workloads_num,
		//control signals
		output	reg	cache_fifo_read,
		output	reg	cache_fifo_write,
		output	reg	results_fifo_write,
		output  reg read_mem,
		output  reg start_calc//,
		//output		pe_reset[NUM_ROWS-1:0]
		
	);
    
    reg [4:0] latency_counter;
    reg [23:0] counter;
    reg start_calc_reg;
    wire start_calculations; 
	
//Timing Optimization:
//Register the workload num signal
logic		[DATA_WIDTH-1:0]	workloads_num_T;
always @(posedge	clk)
begin
	workloads_num_T			<=	workloads_num;
end

// Timing Optimization:
// Create Fan-outs for the reset signal. Each ROW elements in SGEMM2 Core will gets its own reset signal.
//logic			pe_reset_T[NUM_ROWS-1:0];
//logic			rst_[NUM_ROWS-1:0]
//assign pe_reset	= pe_reset_T;			
//always @(posedge clk)
//begin
//	for( int i =0 ; i<NUM_ROWS; i = i+1)
//		begin
//			pe_reset_T[i]	<= reset;	
//		end
//end

	
	
    wire [9:0] workload_counter = counter[23:14]; // [13:0] up to 16kcc -> [23:14] workloads counter
    //wire results_ready = (counter>(WORKLOADS_NUM*16384-1024)) ? 1'b1 : 1'b0;
    wire results_ready = (counter>(workloads_num_T*16384-1024)) ? 1'b1 : 1'b0;   
    always @(posedge clk) 
 	  if(reset|| !en)
 	    start_calc_reg<=1'b0;
      //else if(en && ((loaded_b && loaded_a)||results_ready))
      else if(en && loaded_b && loaded_a)
        start_calc_reg<=1'b1;
      //else (!en)
		//start_calc_reg<=1'b0;



	param_delay			#(
				.DEPTH(3),				//additional delay for en signal for PEs (waiting for data from feeders 2clks)
				.WIDTH(1)
				) DATA_REG
	(
		.clock		(clk),
	    .reset		(reset),
	    .data_in	(start_calc_reg),
	    .data_out   (start_calculations)
	);
    always @(posedge clk) 
 	  if(reset)
 	    start_calc<=1'b0;
      else 
        start_calc<=start_calculations;
                
    always @(posedge clk) 
 	  if(reset)
 	    latency_counter<=4'b0;
      else if(start_calc && latency_counter<27)//13)
        latency_counter<=latency_counter+1;  
        
    always @(posedge clk) 
 	  if(reset)
 	    counter<=24'b0;
 	  //else if(start_calc && workload_counter==WORKLOADS_NUM)					
 	  else if(start_calc && workload_counter==workloads_num_T)
 	    counter<=24'b1 ; 
 	  else if(start_calc && latency_counter>22)//9)  
 	    begin
			// synthesis translate_off
            if (counter[7:0] == 8'b0 & !results_ready) 
                $display("NEXT INPUT BLOCK CALCULATION --> NUM_BLOCK=%d --> COUNTER= %d",workload_counter,counter);
                        
			// synthesis translate_on
			counter<=counter+1; // up to 16*1024*WORKLOADS_NUM
		end
    always @(posedge clk) 
 	  if(reset)
 	    cache_fifo_read<=1'b0;
      else if(start_calc && counter>997)//1010)
        cache_fifo_read<=1'b1;
      else   
 	    cache_fifo_read<=1'b0;
 	     	    
    always @(posedge clk) 
 	  if(reset)
 	    cache_fifo_write<=1'b0;
      else if(start_calc && latency_counter>23 &&  !results_ready)//&& latency_counter>10 &&  !results_ready)
        cache_fifo_write<=1'b1; 
      else 
 	    cache_fifo_write<=1'b0;      
                 
    always @(posedge clk) 
 	  if(reset)
 	    results_fifo_write<=1'b0;
      else if(start_calc && latency_counter>23 && results_ready)//&& latency_counter>10 && results_ready)
        results_fifo_write<=1'b1;
      else
        results_fifo_write<=1'b0;
                 
    always @(posedge clk) 
 	  if(reset)
 	    read_mem<=1'b0;
 	  else if(loaded_a && loaded_b)
 	    read_mem<=1'b1;          
    //results_fifo_read is determinated in PE based on result fifo_out_write signal    
        
endmodule
