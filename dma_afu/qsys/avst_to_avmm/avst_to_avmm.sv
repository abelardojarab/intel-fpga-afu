module avst_to_avmm #(
	parameter AVMM_ADDR_WIDTH = 18,
	parameter AVMM_DATA_WIDTH = 64
	)
	(
	input clk,
	input reset,
	
	input [AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+1-1:0] in_data,
    input in_valid,
    output logic in_ready,
             
    output logic 	[AVMM_DATA_WIDTH-1:0] out_data,
    output logic out_valid,
    input out_ready,
	
	input		avmm_waitrequest,
	input	[AVMM_DATA_WIDTH-1:0]	avmm_readdata,
	input		avmm_readdatavalid,
	output logic 	[0:0]	avmm_burstcount,
	output logic 	[AVMM_DATA_WIDTH-1:0]	avmm_writedata,
	output logic 	[AVMM_ADDR_WIDTH-1:0]	avmm_address,
	output logic 		avmm_write,
	output logic 		avmm_read,
	output logic 	[(AVMM_DATA_WIDTH/8)-1:0]	avmm_byteenable
);

	localparam INPUT_AVST_WIDTH = AVMM_ADDR_WIDTH+AVMM_DATA_WIDTH+1;
	localparam AVMM_BYTE_ENABLE_WIDTH=(AVMM_DATA_WIDTH/8);

	typedef struct packed { 
		logic is_read;
		logic [AVMM_ADDR_WIDTH-1:0] addr;
		logic [AVMM_DATA_WIDTH-1:0] write_data;
    } t_avst_input; 
    
    t_avst_input avst_input_data;
    assign avst_input_data = in_data;
    
    logic has_input_data;
    t_avst_input avst_input_data_reg;
    
    wire will_use_input_data = (avmm_waitrequest == 1'b0 && has_input_data == 1'b1);
    
	always@(posedge clk) begin
		avmm_burstcount <= 1'b1;
		avmm_write <= '0;
		avmm_read <= '0;
		avmm_byteenable <= {AVMM_BYTE_ENABLE_WIDTH{1'b1}};
		avmm_writedata <= '0;
		avmm_address <= '0;
		in_ready <= '0;
		out_data <= '0;
		out_valid <= '0;
		has_input_data <= has_input_data;
		avst_input_data_reg <= avst_input_data_reg;
			
		if(reset) begin
			avmm_burstcount <= 1'b1;
			avmm_write <= '0;
			avmm_read <= '0;
			avmm_byteenable <= {AVMM_BYTE_ENABLE_WIDTH{1'b1}};
			avmm_writedata <= '0;
			avmm_address <= '0;
			
			in_ready <= '0;
			out_data <= '0;
			out_valid <= '0;
			
			has_input_data <= '0;
			avst_input_data_reg <= '0;
		end
		else begin
			in_ready <= ~has_input_data || will_use_input_data;
			has_input_data <= will_use_input_data ? 0 : has_input_data;
			if(in_valid == 1'b1 && in_ready == 1'b1) begin
				avst_input_data_reg <= avst_input_data;
				has_input_data <= 1'b1;
			end
			
			if(avmm_waitrequest == 1'b0 && has_input_data == 1'b1) begin
				//in_ready <= 1'b1;
				//mmio write
				if(avst_input_data_reg.is_read == 1'b0) begin
					avmm_address <= avst_input_data_reg.addr;
					avmm_writedata <= avst_input_data_reg.write_data;
					avmm_write <= 1'b1;
					$display("DCP_DEBUG: wr avmm=%x\n", avmm_address);
				end
				
				//mmio read
				if(avst_input_data_reg.is_read == 1'b1) begin
					  avmm_address <= avst_input_data_reg.addr;
					  avmm_read <= 1'b1;
					  $display("DCP_DEBUG: rd avmm=%x\n", avmm_address);
				end
			end
			
			//handle read response
			if(avmm_readdatavalid == 1'b1) begin
				out_data <= avmm_readdata;
				out_valid <= 1'b1;
				$display("DCP_DEBUG: rd resp avmm data=%x\n", avmm_readdata);
			end
		end
	end

endmodule