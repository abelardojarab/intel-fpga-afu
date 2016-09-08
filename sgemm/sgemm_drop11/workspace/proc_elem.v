`timescale 1 ps / 1 ps
module proc_elem
#(
  parameter DOT			= 8,
  parameter DOT_LATENCY	= 24,
  parameter DATA_WIDTH	= 32,
  parameter MEM_DEPTH	= 1024,
  parameter	PE_LATENCY	= 1,
  parameter WORKLOADS_NUM = -1  //numbers of input feeder workloads -> blocks of A & B for complete C calculations -> from input matrices sizes
)
(
		input 						reset,
		output reg					reset_out,
		input       				clk,    
		
		input   [0:0] 				en,
		output reg					en_out, 
		input    [DATA_WIDTH-1:0] 	c_in,     //from another PE for drain C elements
		input    				  	c_in_valid, 	
		output reg [DATA_WIDTH-1:0] c_out,
		output reg 					c_out_valid,
		input	[31:0]				workloads_num,
		input 						writes_fifo_full,
		output  reg 				writes_fifo_full_out,
				
		input       [DATA_WIDTH-1:0] 	a1_in,    
		input       [DATA_WIDTH-1:0] 	b1_in,     
		input       [DATA_WIDTH-1:0] 	a2_in,    
		input       [DATA_WIDTH-1:0] 	b2_in,     
		input       [DATA_WIDTH-1:0] 	a3_in,    
		input       [DATA_WIDTH-1:0] 	b3_in,     
		input       [DATA_WIDTH-1:0] 	a4_in,    
		input       [DATA_WIDTH-1:0] 	b4_in,     
		input       [DATA_WIDTH-1:0] 	a5_in,    
		input       [DATA_WIDTH-1:0] 	b5_in,     
		input       [DATA_WIDTH-1:0] 	a6_in,    
		input       [DATA_WIDTH-1:0] 	b6_in,     
		input       [DATA_WIDTH-1:0] 	a7_in,    
		input       [DATA_WIDTH-1:0] 	b7_in,     
		input       [DATA_WIDTH-1:0] 	a8_in,    
		input       [DATA_WIDTH-1:0] 	b8_in, 

		output   reg [DATA_WIDTH-1:0] 	a1_out,    
		output   reg [DATA_WIDTH-1:0] 	b1_out,     
		output   reg [DATA_WIDTH-1:0] 	a2_out,    
		output   reg [DATA_WIDTH-1:0] 	b2_out,     
		output   reg [DATA_WIDTH-1:0] 	a3_out,    
		output   reg [DATA_WIDTH-1:0] 	b3_out,     
		output   reg [DATA_WIDTH-1:0] 	a4_out,    
		output   reg [DATA_WIDTH-1:0] 	b4_out,     
		output   reg [DATA_WIDTH-1:0] 	a5_out,    
		output   reg [DATA_WIDTH-1:0] 	b5_out,     
		output   reg [DATA_WIDTH-1:0] 	a6_out,    
		output   reg [DATA_WIDTH-1:0] 	b6_out,     
		output   reg [DATA_WIDTH-1:0] 	a7_out,    
		output   reg [DATA_WIDTH-1:0] 	b7_out,     
		output   reg [DATA_WIDTH-1:0] 	a8_out,    
		output   reg [DATA_WIDTH-1:0] 	b8_out,		

		//control signals
		input		cache_fifo_read,
		input		cache_fifo_write,
		input		results_fifo_write,
		output	reg	cache_fifo_read_out,
		output	reg	cache_fifo_write_out,
		output	reg	results_fifo_write_out
		
	);
// Timing Optimization
// Register the workloads_num signal from the input. 
// Register the reset signal coming from the control unit
logic						reset_T;
logic	[DATA_WIDTH-1:0]	workloads_num_T;
	always @(posedge clk)
		begin
			workloads_num_T			<=	workloads_num;
			reset_T					<=	reset;
		end
 	 always @(posedge clk) 
        reset_out<=reset_T;	
	
	 reg [DATA_WIDTH-1:0] acc_reg;
	 wire [DATA_WIDTH-1:0] dot8_result;
    wire cache_fifo_empty;
    reg cache_fifo_empty_reg;
    
	 always @(posedge clk) 
 	  if(reset_T)
 	    en_out<=1'b0;
      else 
        en_out<=en;
        
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )A1_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(a1_in),
          .data_out   	(a1_out)
      );  
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )A2_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(a2_in),
          .data_out   	(a2_out)
      ); 
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )A3_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(a3_in),
          .data_out   	(a3_out)
      ); 
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )A4_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(a4_in),
          .data_out   	(a4_out)
      ); 
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )A5_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(a5_in),
          .data_out   	(a5_out)
      );  
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )A6_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(a6_in),
          .data_out   	(a6_out)
      ); 
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )A7_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(a7_in),
          .data_out   	(a7_out)
      ); 
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )A8_REGS
      (   .clock		(clk),
          .reset		(rst),
          .data_in		(a8_in),
          .data_out   	(a8_out)
      );	 


     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )B1_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(b1_in),
          .data_out   	(b1_out)
      );  
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )B2_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(b2_in),
          .data_out   	(b2_out)
      ); 
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )B3_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(b3_in),
          .data_out   	(b3_out)
      ); 
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )B4_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(b4_in),
          .data_out   	(b4_out)
      ); 
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )B5_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(b5_in),
          .data_out   	(b5_out)
      );  
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )B6_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(b6_in),
          .data_out   	(b6_out)
      ); 
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )B7_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(b7_in),
          .data_out   	(b7_out)
      ); 
     param_delay	#(.DEPTH(PE_LATENCY),.WIDTH(DATA_WIDTH)
      )B8_REGS
      (   .clock		(clk),
          .reset		(reset_T),
          .data_in		(b8_in),
          .data_out   	(b8_out)
      );



	 always @(posedge clk) 
 	  if(reset_T)
 	    cache_fifo_read_out<=1'b0;
      else if(en )//&& !cache_fifo_empty)
        cache_fifo_read_out<=cache_fifo_read;
      else
        cache_fifo_read_out<=1'b0;  
	 
	 always @(posedge clk) 
 	  if(reset_T)
 	    cache_fifo_write_out<=1'b0;
      else if(en)
        cache_fifo_write_out<=cache_fifo_write;
      else
        cache_fifo_write_out<=1'b0; 
	  
	 always @(posedge clk) 
 	  if(reset_T)
 	    results_fifo_write_out<=1'b0;
      else if(en )//&& (!cache_fifo_write || c_in_valid))
        results_fifo_write_out<=results_fifo_write;
      else
        results_fifo_write_out<=1'b0; 
        
//dsp chain dot8

	dot_8_a10 dot8_chain
	(	.clk     (clk),    
		.en      (en),
		.running_sum(acc_reg),
		.a1		 (a1_in),    
		.b1      (b1_in),      
		.a2		 (a2_in),    
		.b2      (b2_in), 
		.a3		 (a3_in),    
		.b3      (b3_in), 
		.a4		 (a4_in),    
		.b4      (b4_in), 				
		.a5		 (a5_in),    
		.b5      (b5_in),      
		.a6		 (a6_in),    
		.b6      (b6_in), 
		.a7		 (a7_in),    
		.b7      (b7_in), 
		.a8		 (a8_in),    
		.b8      (b8_in),
		.result   (dot8_result)
	);    
	
    reg [DATA_WIDTH-1:0] fifo_in_reg;
    reg [4:0] latency_counter;
    reg [23:0] counter;
    wire [9:0] workload_counter = counter[23:14]; // [13:0] up to 16kcc -> [23:14] workloads counter
    wire [DATA_WIDTH-1:0] fifo_out;
        
    always @(posedge clk) 
 	  if(reset_T)
 	    fifo_in_reg<=32'b0;
      else if(en)
        fifo_in_reg<=dot8_result;    
           
    always @(posedge clk) 
 	  if(reset_T)
 	    latency_counter<=4'b0;
      else if(en && latency_counter<27)
        latency_counter<=latency_counter+4'b1;  
    

     always @(posedge clk) 
 	  if(reset_T)
 	    cache_fifo_empty_reg<=0;
 	  else
 	    cache_fifo_empty_reg<=cache_fifo_empty;      
 
    reg acc_clear;
     always @(posedge clk) 
 	  if(reset_T)
 	    acc_clear<=0;
 	  else if(en && (counter<(1022-DOT_LATENCY) || cache_fifo_empty))
 	    acc_clear<=1;
 	  else if(en)
		acc_clear<=0;
 	      
    
    always @(posedge clk) 
 	  if(reset_T || acc_clear)
 	    acc_reg<=32'b0;  //reg between cache_fifo and dot8(running_sum) 
 	  //else if(en &&  counter<(1023-DOT_LATENCY) || cache_fifo_empty_reg)//99//1012 || cache_fifo_empty_reg)
 	  //  acc_reg<=32'b0;
 	  else if(en)// && (cache_fifo_read ||(!cache_fifo_empty_reg && cache_fifo_empty)))
 	    acc_reg<=fifo_out; 
 
    //always @(posedge clk) 
 	 // if(reset_T)
 	 //   acc_reg<=32'b0;  //reg between cache_fifo and dot8(running_sum) 
 	 // else if(en && counter<(1023-DOT_LATENCY) || cache_fifo_empty_reg)//99//1012 || cache_fifo_empty_reg)
 	 //   acc_reg<=32'b0;
 	 // else if(en && (cache_fifo_read ||(!cache_fifo_empty_reg && cache_fifo_empty)))
 	 //   acc_reg<=fifo_out;    
 	            
    always @(posedge clk) 
 	  if(reset_T)
 	    counter<=24'b0;
 	  //else if(en && workload_counter==WORKLOADS_NUM)					
 	  else if(en && workload_counter==workloads_num_T[9:0])	
 	    counter<=24'b1 ; 
 	  else if(en && latency_counter>(DOT_LATENCY-1))//23)//10)  //16kcc 16*1024
 	    counter<=counter+1'b1;
 	     	                       
    wire [9:0] results_cache_words;
    scfifo  cache_scfifo (
                .aclr (reset_T),
                .clock (clk),
                .data (fifo_in_reg),
                .rdreq (cache_fifo_read && !cache_fifo_empty),
                .wrreq (cache_fifo_write),
                .empty (cache_fifo_empty),
                .full (),
                .q (fifo_out),
                .almost_empty (),
                .almost_full (),
                .sclr (),
                .usedw ());
      defparam
        cache_scfifo.add_ram_output_register  = "ON",
        cache_scfifo.intended_device_family  = "Arria 10",
        cache_scfifo.lpm_hint  = "RAM_BLOCK_TYPE=M20K",
        cache_scfifo.lpm_numwords  = MEM_DEPTH,
        cache_scfifo.lpm_showahead  = "OFF",
        cache_scfifo.lpm_type  = "scfifo",
        cache_scfifo.lpm_width  = 32,
        cache_scfifo.lpm_widthu  = 10,
        cache_scfifo.overflow_checking  = "ON",
        cache_scfifo.underflow_checking  = "ON",
        cache_scfifo.use_eab  = "ON";    
	
	
	//second FIFO for drain C elements
    wire [DATA_WIDTH-1:0] output_elements;  
    wire fifo_out_empty;
    reg c_out_valid_reg;
    //wire results_fifo_read = (cache_fifo_write && !fifo_out_empty) ? 1'b1 : 1'b0;
    wire results_fifo_read = (cache_fifo_write && !fifo_out_empty && !writes_fifo_full) ? 1'b1 : 1'b0;
        
    always @(posedge clk) 
 	  if(reset_T)
 	    c_out<=32'b0;
      else if(en && c_out_valid_reg)
        c_out<=output_elements;
      else   
        c_out<=32'b0;
        
    always @(posedge clk) 
 	  if(reset_T)
 	    c_out_valid_reg<=0;
      else if(en && results_fifo_read)
        c_out_valid_reg<=results_fifo_read;
      else
        c_out_valid_reg<=0;
    //////////////////////////////////////////////////////////////////////////test
    //reg [31:0] test_counter;
    // always @(posedge clk) 
 	//  if(reset)
 	//    test_counter<=0;
 	//  else if(c_out_valid_reg)
 	//    test_counter<=test_counter+1'b1;
    /////////////////////////////////////////////////////////////////////////////
    
    
    always @(posedge clk) 
 	  if(reset_T)
 	    c_out_valid<=0;
 	  else if(en)
 	    c_out_valid<=c_out_valid_reg;
 	  else
 	    c_out_valid<=0;              
    
    reg c_in_valid_reg;
    reg [DATA_WIDTH-1:0] c_in_reg;
    
    always @(posedge clk) 
 	  if(reset_T)
 	    c_in_valid_reg<=0;
 	  else if(en)
 	    c_in_valid_reg<=c_in_valid;
 	  else
 	    c_in_valid_reg<=0;
    
    always @(posedge clk) 
 	  //if(reset)
 	  //  c_in_reg<=32'b0;
 	  //else if(en)
 	    c_in_reg<=c_in;
 	  //else
 	  //  c_in_reg<=32'b0;	
       
    
    wire [DATA_WIDTH-1:0] fifo_results_in = (results_fifo_write==1) ?  fifo_in_reg : c_in_reg;//demux on results fifo(from dot8 or from previous result fifo(from previous PE))
 	wire result_fifo_rd_req = results_fifo_read;//cache_fifo_write && !fifo_out_empty;
 	wire result_fifo_wr_req = results_fifo_write||c_in_valid_reg;
 	wire result_fifo_full;
 	 	wire result_fifo_almost_full;  
 	
 	wire	lost_write =  result_fifo_wr_req && result_fifo_full;
  
 	/////////////////////////////////////////////////////////////////////////////test
 	//reg [31:0] result_fifo_wr_req_cnt;
 	//    always @(posedge clk) 
 	//  if(reset)
 	//    result_fifo_wr_req_cnt<=32'b0;
 	//  else if(result_fifo_wr_req)
 	//    result_fifo_wr_req_cnt<=result_fifo_wr_req_cnt+1'b1;
 	//reg [31:0] result_fifo_rd_req_cnt; 	    
 	//    always @(posedge clk) 
 	//  if(reset)
 	//    result_fifo_rd_req_cnt<=32'b0;
 	//  else if(result_fifo_rd_req)
 	//    result_fifo_rd_req_cnt<=result_fifo_rd_req_cnt+1'b1;
   ////////////////////////////////////////////////////////////////////////////////// 
  	 always @(posedge clk) 
 	  if(reset_T)
 	    writes_fifo_full_out<=1'b0;
      else 
        //writes_fifo_full_out<=writes_fifo_full;
        writes_fifo_full_out<=writes_fifo_full | result_fifo_almost_full;
  
    scfifo  results_scfifo (
                .aclr (reset_T),
                .clock (clk),
                .data (fifo_results_in),
                .rdreq (results_fifo_read),//cache_fifo_write && !fifo_out_empty),
                .wrreq (result_fifo_wr_req),//c_in_valid), //???
                .empty (fifo_out_empty),
                .full (result_fifo_full),
                .q (output_elements),
                .almost_empty (),
                .almost_full (result_fifo_almost_full),
                .sclr (),
                .usedw (results_cache_words));            
      defparam
        results_scfifo.add_ram_output_register  = "ON",
        results_scfifo.intended_device_family  = "Arria 10",
        results_scfifo.almost_full_value  = 1000,//9,
        results_scfifo.lpm_hint  = "RAM_BLOCK_TYPE=M20K",
        results_scfifo.lpm_numwords  = MEM_DEPTH,
        results_scfifo.lpm_showahead  = "OFF",
        results_scfifo.lpm_type  = "scfifo",
        results_scfifo.lpm_width  = 32,
        results_scfifo.lpm_widthu  = 10,
        results_scfifo.overflow_checking  = "ON",
        results_scfifo.underflow_checking  = "ON",
        results_scfifo.use_eab  = "ON";      

endmodule
