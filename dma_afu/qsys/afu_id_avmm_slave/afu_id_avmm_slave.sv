`define AFU_ID_AVMM_SLAVE_DATA_WIDTH 64
`define AFU_ID_AVMM_SLAVE_ADDR_WIDTH 3

module afu_id_avmm_slave #(
        //uuid: 331db30c-9885-41ea-9081-f88b8f655caa
        parameter AFU_ID_H = 64'h331D_B30C_9885_41EA,
        parameter AFU_ID_L = 64'h9081_F88B_8F65_5CAA,
        parameter CREATE_SCRATCH_REG = 1'b0
	)
	(
	//input avmm_chipselect,
	input avmm_write,
	input avmm_read,
	//input 	[(`AFU_ID_AVMM_SLAVE_DATA_WIDTH/8)-1:0]	avmm_byteenable
	input [`AFU_ID_AVMM_SLAVE_DATA_WIDTH-1:0] avmm_writedata,
	output logic [`AFU_ID_AVMM_SLAVE_DATA_WIDTH-1:0] avmm_readdata,
	
	input [`AFU_ID_AVMM_SLAVE_ADDR_WIDTH-1:0]	avmm_address,
	
	input clk,
	input reset
);

	logic [`AFU_ID_AVMM_SLAVE_DATA_WIDTH-1:0] scratch_reg;

	always@(posedge clk) begin
		avmm_readdata <= '0;
		scratch_reg <= scratch_reg;
		if(reset) begin
			avmm_readdata <= '0;
			scratch_reg <= '0;
		end
		else begin
			// set the registers on MMIO write request
			// these are user-defined AFU registers at offset 0x40 and 0x41
			if(avmm_write && CREATE_SCRATCH_REG) begin
				case(avmm_address)
					4'h5: scratch_reg <= avmm_writedata;
				endcase
			end
			// serve MMIO read requests
			if(avmm_read) begin
				case(avmm_address)
					// AFU header
					4'h0: avmm_readdata <= {
						4'b0001, // Feature type = AFU
						8'b0,    // reserved
						4'b0,    // afu minor revision = 0
						7'b0,    // reserved
						1'b1,    // end of DFH list = 1 
						24'b0,   // next DFH offset = 0
						4'b0,    // afu major revision = 0
						12'b0    // feature ID = 0
					};            
					4'h1: avmm_readdata <= AFU_ID_L; // afu id low
					4'h2: avmm_readdata <= AFU_ID_H; // afu id hi
					4'h3: avmm_readdata <= 64'h0; // next AFU
					4'h4: avmm_readdata <= 64'h0; // reserved
					4'h5: avmm_readdata <= scratch_reg;
					default:  avmm_readdata <= 64'h0;
				endcase
			end
		end
	end

endmodule