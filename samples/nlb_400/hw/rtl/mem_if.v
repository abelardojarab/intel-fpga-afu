//
// The AFU JSON adds a clock crossing of local_memory to pClk, making the majority of
// this module unnecessary. It should be rewritten. For now, we just replace DCFIFOs
// with SCFIFOs.
//
`define NO_CLOCK_CROSSING

module mem_if # (
	DATA_WIDTH = 64,
	ADDR_WIDTH = 26,
	BYTEEN_WIDTH = 8,
	BURSTCOUNT_WIDTH = 7
)(
	input wire pClk,
	input wire DDR_USERCLK,
	input wire SoftReset,
	
	input wire write,
	input wire read,
	input wire [DATA_WIDTH-1:0] writedata,
	input wire [ADDR_WIDTH-1:0] address,
	input wire [BYTEEN_WIDTH-1:0] byteenable,
	input wire [BURSTCOUNT_WIDTH-1:0] burstcount,
        input wire [2:0] readdata_sel,
	
	input wire read_ddr_data,	
	output wire ddr_data_ready,
	output wire [DATA_WIDTH-1:0] readdata,
	output wire cmd_fifo_full,
	output wire ddr_write_timeout,
	output wire ddr_read_timeout,	
	
	input wire DDR_waitrequest,	
	input wire DDR_readdatavalid,
	input wire [8*DATA_WIDTH-1:0] DDR_readdata,
	output reg DDR_read,
	output reg DDR_write,
	output wire [ADDR_WIDTH-1:0] DDR_address,
	output wire [DATA_WIDTH-1:0] DDR_writedata,
	output wire [BURSTCOUNT_WIDTH-1:0] DDR_burstcount,
	output wire [BYTEEN_WIDTH-1:0] DDR_byteenable
);

localparam WRITE_CMD = 1'b1;
localparam READ_CMD = 1'b0;
localparam CMD_FIFO_WIDTH = (4 + ADDR_WIDTH + DATA_WIDTH + BYTEEN_WIDTH + BURSTCOUNT_WIDTH);
localparam READ_FIFO_WIDTH = DATA_WIDTH;

// state machine
localparam IDLE = 3'd0;
localparam GET_CMD = 3'd1;
localparam WRITE = 3'd2;
localparam READ =3'd3;
localparam READ_DATA_VALID = 3'd4;

reg [8*DATA_WIDTH-1:0] DDR_readdata_d0 ;
reg                    DDR_readdatavalid_d0;

reg [CMD_FIFO_WIDTH-1:0] afu_cmd_din;
wire [CMD_FIFO_WIDTH-1:0] afu_cmd_dout;
reg [CMD_FIFO_WIDTH-1:0] afu_cmd_dout_q;
reg afu_write, afu_read;
wire afu_cmd_empty, afu_cmd_full;
reg wr_fifo_data_valid;

wire ddr_reset;
wire [DATA_WIDTH-1:0] ddr_readdata_word;
wire [READ_FIFO_WIDTH-1:0] ddr_res_din;
reg [READ_FIFO_WIDTH-1:0] ddr_res_din_T0, ddr_res_din_T1, ddr_res_din_T2;
wire [READ_FIFO_WIDTH-1:0] ddr_res_dout;

wire write_ddr_data;
reg write_ddr_data_T0, write_ddr_data_T1, write_ddr_data_T2;
wire ddr_res_empty, ddr_res_full;

reg [READ_FIFO_WIDTH-1:0] ddr_res_q, ddr_res_q2, ddr_res_q3;
reg [1:0] afu_cmd_ready;
wire ddr_cmd;
wire [2:0] ddr_readdata_sel; 
reg count;
reg [35:0] timeout_counter;
reg write_timeout;
reg read_timeout;
wire ddr_timeout;
reg [2:0] cs, ns;

assign cmd_fifo_full = afu_cmd_full;
assign ddr_data_ready = ~ddr_res_empty;
assign ddr_readdata_word = (ddr_readdata_sel == 3'h0) ? DDR_readdata_d0[0+:DATA_WIDTH]
			     : (ddr_readdata_sel == 3'h1) ? DDR_readdata_d0[1*DATA_WIDTH+:DATA_WIDTH]
			     : (ddr_readdata_sel == 3'h2) ? DDR_readdata_d0[2*DATA_WIDTH+:DATA_WIDTH]
			     : (ddr_readdata_sel == 3'h3) ? DDR_readdata_d0[3*DATA_WIDTH+:DATA_WIDTH]
			     : (ddr_readdata_sel == 3'h4) ? DDR_readdata_d0[4*DATA_WIDTH+:DATA_WIDTH]
			     : (ddr_readdata_sel == 3'h5) ? DDR_readdata_d0[5*DATA_WIDTH+:DATA_WIDTH]
			     : (ddr_readdata_sel == 3'h6) ? DDR_readdata_d0[6*DATA_WIDTH+:DATA_WIDTH]
			     : DDR_readdata_d0[7*DATA_WIDTH+:DATA_WIDTH];
assign readdata = ddr_res_q3;

// DDR readdata and readdatavalid pipeline
always @(posedge DDR_USERCLK) begin
   DDR_readdata_d0 <= DDR_readdata;

   DDR_readdatavalid_d0 <= DDR_readdatavalid;
end

always @(posedge pClk) begin
	if (SoftReset) begin
		afu_write <= 1'd0;
	end else begin
		afu_write <= (write | read) & ~afu_cmd_full;
	end
	afu_cmd_din <= {write, address, writedata, byteenable, burstcount, readdata_sel}; 
end

// Reset synchronizer
`ifdef NO_CLOCK_CROSSING
assign ddr_reset = SoftReset;
`else
resync #(
	 .SYNC_CHAIN_LENGTH(2),
	 .WIDTH(1),		 
	 .INIT_VALUE(1)	 
) ddr_reset_sync (
	 .clk(DDR_USERCLK),
	 .reset(SoftReset),
	 .d(1'b0),
	 .q(ddr_reset)
);
`endif

assign {ddr_cmd, DDR_address, DDR_writedata, DDR_byteenable, DDR_burstcount, ddr_readdata_sel} = afu_cmd_dout_q;

always @(posedge DDR_USERCLK) begin
	if (ddr_reset) begin
		afu_cmd_ready <= 2'h0;		
	end else begin
		afu_cmd_ready <= {afu_cmd_ready[0], afu_read};
	end
end

always @(posedge DDR_USERCLK) begin
	if (ddr_reset) begin
		afu_cmd_dout_q <= {CMD_FIFO_WIDTH{1'b0}};		
	end else begin
		afu_cmd_dout_q <= afu_cmd_dout;		
	end
end

always @(posedge pClk) begin
	ddr_res_q <= ddr_res_dout;
	ddr_res_q2 <= ddr_res_q;
	ddr_res_q3 <= ddr_res_q2;
end

assign ddr_timeout = timeout_counter[35];

always @(posedge DDR_USERCLK) begin
	if (ddr_reset) begin
		timeout_counter <= 36'd0;
	end else if (ddr_timeout || ~count) begin
		timeout_counter <= 36'd0;
	end else if (count) begin
		timeout_counter <= timeout_counter + 36'd1;
	end
end

// sticky response timeout bits
always @(posedge DDR_USERCLK) begin
	if (ddr_reset) begin
		write_timeout <= 1'b0;
		read_timeout <= 1'b0;
	end else if ( (cs == WRITE) && ddr_timeout) begin
		write_timeout <= 1'b1;
	end else if ( (cs == READ_DATA_VALID) && ddr_timeout) begin
		read_timeout <= 1'b1;
	end
end

resync #(
	 .SYNC_CHAIN_LENGTH(2),
	 .WIDTH(2),		 
	 .INIT_VALUE(0),
	 .NO_CUT(0)
) timeout_sync (
	 .clk(pClk),
	 .reset(1'b0),
	 .d({read_timeout, write_timeout}),
	 .q({ddr_read_timeout, ddr_write_timeout})
);

always @(posedge DDR_USERCLK) begin
	if (ddr_reset) 
		cs <= 3'd0;
	else 
		cs <= ns;	
end

always @(*) begin
	ns = cs;
	afu_read = 1'b0;
	DDR_write = 1'b0;
	DDR_read = 1'b0;
	count = 1'b0;
	
	case (cs)
		IDLE: begin	
			if (~afu_cmd_empty) begin
				ns = GET_CMD;		
				afu_read = 1'b1;
			end
		end
		GET_CMD: begin
			if (afu_cmd_ready[1]) begin
				ns = (ddr_cmd == WRITE_CMD) ? WRITE : READ;				
			end
		end
		WRITE: begin
			DDR_write = 1'b1;
			count = 1'b1;
			if (~DDR_waitrequest || ddr_timeout) begin
				ns = IDLE;			
			end
		end
		READ: begin
			DDR_read = 1'b1;
			count = 1'b1;
			if ((~DDR_waitrequest && DDR_readdatavalid_d0) || ddr_timeout) begin
				ns = IDLE;
			end else if (~DDR_waitrequest && ~DDR_readdatavalid_d0) begin
				ns = READ_DATA_VALID;			
			end
		end
		READ_DATA_VALID : begin
			count = 1'b1;
			if (DDR_readdatavalid_d0 || ddr_timeout) begin
				ns = IDLE;			
			end
		end
		default : begin
			ns = IDLE;
		end
	endcase
end

always @(posedge DDR_USERCLK) begin
   if (ddr_reset) begin
	   write_ddr_data_T0 <= 1'b0;
	end else begin
	   write_ddr_data_T0 <= DDR_readdatavalid_d0 && ~ddr_res_full;
	end
	   write_ddr_data_T1 <= write_ddr_data_T0;
		write_ddr_data_T2 <= write_ddr_data_T1;
end
assign write_ddr_data = write_ddr_data_T2;

always @(posedge DDR_USERCLK) begin  
   ddr_res_din_T0 <= ddr_readdata_word;
	ddr_res_din_T1 <= ddr_res_din_T0;
	ddr_res_din_T2 <= ddr_res_din_T1;
end
assign ddr_res_din = ddr_res_din_T2;
	
write_dc_fifo afu_cmd_fifo (
	.data(afu_cmd_din),
	.wrreq(afu_write),
	.rdreq(afu_read),
	.wrclk(pClk),
	.rdclk(DDR_USERCLK),
	.aclr(SoftReset),
	.q(afu_cmd_dout),
	.rdempty(afu_cmd_empty),
	.wrfull(afu_cmd_full)
);

read_dc_fifo afu_res_fifo (
	.data(ddr_res_din),
	.wrreq(write_ddr_data),
	.rdreq(read_ddr_data),
	.wrclk(DDR_USERCLK),
	.rdclk(pClk),
	.aclr(SoftReset),
	.q(ddr_res_dout),
	.rdempty(ddr_res_empty),
	.wrfull(ddr_res_full)
);

endmodule
