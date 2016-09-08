`timescale 1 ps / 1 ps
module feeders_a
#(
  parameter WORKLOADS_NUM = 2,  //numbers of input feeder workloads -> blocks of A & B for complete C calculations -> from input matrices sizes
  parameter NUM_ROWS=2								
)
(
		input reset,
		input       				clk,    
		//input   [0:0] 				en,
	
		input						wr_en,
		input	[511:0] 			data_in,
		input						rd_en,
(* maxfan=256 *)	output reg [(NUM_ROWS*256)-1:0] data_out,
		output reg					a_loaded,
		output reg					feeders_a_full
	);
    

    reg [11:0]  wr_counter;
    reg [13:0]  rd_counter;
    reg		    wr_shadow;
    reg 		rd_shadow;	
    wire [8:0]  wr_address = {wr_shadow,wr_counter[7:0]};
    wire [9:0]  rd_address  = {rd_shadow,rd_counter[13:5]};
    wire [3:0]  sel = wr_counter[11:8];
	reg  [9:0] 	wr_completed;
	reg  [9:0]  rd_completed;	

// Timing Optimization
logic				reset_T_a_feeders[NUM_ROWS-1:0];
always @(posedge clk)
begin
	for(int i = 0; i<NUM_ROWS; i=i+1)
		begin
			reset_T_a_feeders[i]	<=	reset;
		end
end	
    //for test
    reg [31:0] clock_counter;
    always @(posedge clk) 
 	  if(reset)
		clock_counter<=0;
	  else
		clock_counter<=clock_counter+1'b1;   
    //
        
    always @(posedge clk) 
 	  if(reset)
 	     begin
 	        wr_counter		<=12'b0;
 	        wr_shadow		<=1'b0;
 	        wr_completed 	<=10'b0;
 	     end   
 	  else if(wr_en && sel==(NUM_ROWS-1) && &wr_counter[7:0])
 	     begin					
 	        wr_shadow<= ~wr_shadow;//second higher part of memory
 	        wr_counter 		<= 12'b0;
 	        wr_completed	<= wr_completed +1'b1;
 	     end   
 	  else if(wr_en)  
 	       wr_counter<=wr_counter+1'b1; 

     always @(posedge clk) 
 	  if(reset)
 	     begin
 	        rd_counter		<=12'b0;
 	     end 
 	  else if(rd_en )
 	     begin
 	        rd_counter <= rd_counter +1'b1;
 	     end

 	     
     always @(posedge clk) 
 	  if(reset)// ||rd_completed==WORKLOADS_NUM )
 	     begin
 	        rd_completed <= 10'b0;
 	        rd_shadow <= 1'b0;
		 end
	  else if (&rd_counter)
		 begin
		 	rd_completed<=rd_completed + 1'b1;
		 	rd_shadow <= ~rd_shadow;
		 end
 	 
 	 wire start_rd_en = ~|rd_counter[4:0] && rd_en; //one 8's is used per 32cc
     
     always @(posedge clk) 
 	   if(reset)
 	       a_loaded		<=1'b0;
 	   else if(wr_completed>rd_completed)
		   a_loaded		<=1'b1;
	   else
	       a_loaded		<=1'b0;	   		

     always @(posedge clk) 
 	   if(reset)
 	       feeders_a_full		<=1'b0;
 	   else if((wr_completed-rd_completed)==1 && sel==(NUM_ROWS-1) && &wr_counter[7:0])
		   feeders_a_full		<=1'b1;
	   else if(wr_completed-rd_completed<2) //musi szybciej zmienic sie na 0!!!!!!!!!!!!!!!!
	       feeders_a_full		<=1'b0;	

	 reg [511:0] input_data[NUM_ROWS-1:0];
	 reg [8:0] 	input_wr_addr[NUM_ROWS-1:0];
	 reg  [3:0]	 input_sel[NUM_ROWS-1:0];
	 reg		 input_wr_en[NUM_ROWS-1:0];	
	 wire       mem_wr_en[NUM_ROWS-1:0];	
	 reg		output_rd_en[NUM_ROWS-1:0];
	 reg  [9:0]	output_rd_address[NUM_ROWS-1:0];
	 	

genvar i;

generate
	for( i=0; i< NUM_ROWS ;i = i+1)
		begin: OUTPUT_RD_EN										
			if(i==0)
				always @(posedge clk) 
 	              if(reset_T_a_feeders[i])
		             output_rd_en[i]<=1'b0;
	              else
	                 output_rd_en[i]<=start_rd_en;
			else
				always @(posedge clk) 
 	              if(reset_T_a_feeders[i])
		             output_rd_en[i]<=1'b0;
	              else
	                 output_rd_en[i]<=output_rd_en[i-1];	 			
		end

	for( i=0; i< NUM_ROWS ;i = i+1)
		begin: OUTPUT_RD_ADDR										
			if(i==0)
				always @(posedge clk) 
 	              if(reset_T_a_feeders[i])
		             output_rd_address[i]<=10'b0;
	              else
	                 output_rd_address[i]<=rd_address;
			else
				always @(posedge clk) 
 	              if(reset_T_a_feeders[i])
		             output_rd_address[i]<=10'b0;
	              else
	                 output_rd_address[i]<=output_rd_address[i-1];	 			
		end

	for( i=0; i< NUM_ROWS ;i = i+1)
		begin: INPUT_DATA_REG										
			if(i==0)
				always @(posedge clk) 
 	              if(reset_T_a_feeders[i])
		             input_data[i]<=512'b0;
	              else
	                 input_data[i]<=data_in;
			else
				always @(posedge clk) 
 	              if(reset_T_a_feeders[i])
		             input_data[i]<=512'b0;
	              else
	                 input_data[i]<=input_data[i-1];	 			
		end
	
	for( i=0; i< NUM_ROWS ;i = i+1)
		begin: INPUT_ADDR_REG									
			if(i==0)
				always @(posedge clk) 
 	              if(reset_T_a_feeders[i])
		             input_wr_addr[i]<=9'b0;
	              else
	                 input_wr_addr[i]<=wr_address;				
			else
				always @(posedge clk) 
 	              if(reset_T_a_feeders[i])
		             input_wr_addr[i]<=9'b0;
	              else
	                 input_wr_addr[i]<=input_wr_addr[i-1];											
		end
		
	for( i=0; i< NUM_ROWS ;i = i+1)
		begin: INPUT_SEL_REG
			if(i==0)
				always @(posedge clk) 
 	              if(reset_T_a_feeders[i])
		             input_sel[i]<=3'b0;
	              else
	                 input_sel[i]<=sel;					
			else
				always @(posedge clk) 
 	              if(reset_T_a_feeders[i])
		             input_sel[i]<=3'b0;
	              else
	                 input_sel[i]<=input_sel[i-1];				
		end
	
		for( i=0; i< NUM_ROWS ;i = i+1)
		begin: INPUT_WR_EN
			if(i==0)
				always @(posedge clk) 
 	              if(reset_T_a_feeders[i])
		             input_wr_en[i]<=1'b0;
	              else
	                 input_wr_en[i]<=wr_en;					
			else	
				always @(posedge clk) 
 	              if(reset_T_a_feeders[i])
		             input_wr_en[i]<=1'b0;
	              else
	                 input_wr_en[i]<=input_wr_en[i-1];				
		end
	
	for( i=0; i< NUM_ROWS ;i = i+1)
	   begin: MEM_WR_E
		assign mem_wr_en[i] = (input_wr_en[i] && input_sel[i]==i)?  1 : 0;
       end	

	wire [255:0] data_out_from_mem[NUM_ROWS-1:0];
		
	for( i=0; i< NUM_ROWS ;i = i+1)
		begin: A_MEM
			
			//assign data_out[((i+1)*256-1):(i*256)]= data_out_from_mem[i];
			always @(posedge clk) 
 	            if(reset_T_a_feeders[i])
		           data_out[((i+1)*256-1):(i*256)]<=1'b0;
	            else
	               data_out[((i+1)*256-1):(i*256)]<=data_out_from_mem[i];
			
			feeder_ram_512_256		A_MEMORY
			(
				.data      (input_data[i]),      //  ram_input.datain
				.wraddress (input_wr_addr[i]), //           .wraddress
				.rdaddress (output_rd_address[i]), //           .rdaddress
				.wren      (mem_wr_en[i]),      //           .wren
				.clock     (clk),     //           .clock
				.rden      (output_rd_en[i]),      //           .rden
				.q         (data_out_from_mem[i])//[((i+1)*256-1):(i*256)])          // ram_output.dataout
			);
		end
		
		
endgenerate	


       
endmodule
