module local_mem
  #(
    parameter DATA_WIDTH = 64,
    parameter NUM_LOCAL_MEM_BANKS=2,
    parameter ADDR_WIDTH = local_mem_cfg_pkg::LOCAL_MEM_ADDR_WIDTH,
    parameter BYTEEN_WIDTH = local_mem_cfg_pkg::LOCAL_MEM_DATA_N_BYTES,
    parameter BURSTCOUNT_WIDTH = local_mem_cfg_pkg::LOCAL_MEM_BURST_CNT_WIDTH
    )
(
  input  wire          pClk,
  input  wire          SoftReset,
  output wire [DATA_WIDTH-1:0]   mem2cr_readdata,
  output wire [DATA_WIDTH-1:0]   mem2cr_status,
  input wire [DATA_WIDTH-1:0]    cr2mem_ctrl,
  input wire [DATA_WIDTH-1:0]    cr2mem_address,
  input wire [DATA_WIDTH-1:0]    cr2mem_writedata,

  // Local memory interface
  avalon_mem_if.to_fiu local_mem[NUM_LOCAL_MEM_BANKS]
);

reg [DATA_WIDTH-1:0]    cr2mem_ctrl_d0, cr2mem_ctrl_d1;
reg [DATA_WIDTH-1:0]    cr2mem_address_d0, cr2mem_address_d1;
reg [DATA_WIDTH-1:0]    cr2mem_writedata_d0, cr2mem_writedata_d1;

wire DDR4a_cmd_fifo_full;
reg DDR4a_read_timeout;
reg DDR4a_write_timeout;
wire DDR4b_cmd_fifo_full;
reg DDR4b_read_timeout;
reg DDR4b_write_timeout;
reg DDR_data_valid;
wire  [DATA_WIDTH-1:0] DDR4_readdata;
reg [2:0] data_valid_buf;
reg ddr4b_data_select;

// DDR4a
wire csr_ddr4a_write;
wire csr_ddr4a_read;	
wire [ADDR_WIDTH-1:0] csr_ddr4a_address;
wire [DATA_WIDTH-1:0] csr_ddr4a_writedata;
wire [BURSTCOUNT_WIDTH-1:0]  csr_ddr4a_burstcount;
wire [BYTEEN_WIDTH-1:0] csr_ddr4a_byteenable;
wire [2:0] csr_ddr4a_word_select;
wire [DATA_WIDTH-1:0] ddr4a_readdata_word;
wire [DATA_WIDTH-1:0] temp_ddr4a_readdata;
wire [DATA_WIDTH-1:0] temp_ddr4a_writedata;
wire [BYTEEN_WIDTH-1:0] temp_ddr4a_byteenable;
wire ddr4a_readdata_ready;
reg start_ddr4a_read;
reg read_ddr4a_data;
	
// DDR4b
wire csr_ddr4b_write;
wire csr_ddr4b_read;	
wire [ADDR_WIDTH-1:0] csr_ddr4b_address;
wire [DATA_WIDTH-1:0] csr_ddr4b_writedata;
wire [BURSTCOUNT_WIDTH-1:0]  csr_ddr4b_burstcount;
wire [BYTEEN_WIDTH-1:0] csr_ddr4b_byteenable;
wire [2:0] csr_ddr4b_word_select;
wire [DATA_WIDTH-1:0] temp_ddr4b_readdata;
wire [DATA_WIDTH-1:0] temp_ddr4b_writedata;
wire [BYTEEN_WIDTH-1:0] temp_ddr4b_byteenable;
wire ddr4b_readdata_ready;
reg start_ddr4b_read;
reg read_ddr4b_data;		

assign mem2cr_status = {57'h0, DDR4b_cmd_fifo_full, DDR4b_read_timeout, DDR4b_write_timeout, DDR4a_cmd_fifo_full, DDR4a_read_timeout, DDR4a_write_timeout, DDR_data_valid};
assign mem2cr_readdata = DDR4_readdata;

/****************/
/* Read csr reg */
/****************/
always @(posedge pClk) begin
	cr2mem_ctrl_d0 <= cr2mem_ctrl;
	cr2mem_address_d0 <= cr2mem_address;
	cr2mem_writedata_d0 <= cr2mem_writedata;
	
	cr2mem_ctrl_d1 <= cr2mem_ctrl_d0;
	cr2mem_address_d1 <= cr2mem_address_d0;
	cr2mem_writedata_d1 <= cr2mem_writedata_d0;
end

// DDR4a
assign csr_ddr4a_write       = cr2mem_ctrl_d1[0];
assign csr_ddr4a_read        = cr2mem_ctrl_d1[1];
assign csr_ddr4a_byteenable  = cr2mem_ctrl_d1[11:4];
assign csr_ddr4a_word_select = cr2mem_ctrl_d1[18:16];
assign csr_ddr4a_burstcount  = cr2mem_ctrl_d1[26:20];	
assign csr_ddr4a_address     = cr2mem_address_d1[ADDR_WIDTH-1:0];
assign csr_ddr4a_writedata   = cr2mem_writedata_d1;
assign local_mem[0].writedata  = {8{temp_ddr4a_writedata}};	
assign local_mem[0].byteenable = {8{temp_ddr4a_byteenable}};
// DDR4b
assign csr_ddr4b_write       = cr2mem_ctrl_d1[2];
assign csr_ddr4b_read        = cr2mem_ctrl_d1[3];
assign csr_ddr4b_byteenable  = cr2mem_ctrl_d1[11:4];
assign csr_ddr4b_word_select = cr2mem_ctrl_d1[18:16];
assign csr_ddr4b_burstcount  = cr2mem_ctrl_d1[26:20];
assign csr_ddr4b_address     = cr2mem_address_d1[ADDR_WIDTH-1:0];
assign csr_ddr4b_writedata   = cr2mem_writedata_d1;
assign local_mem[1].writedata  = {8{temp_ddr4b_writedata}};
assign local_mem[1].byteenable = {8{temp_ddr4b_byteenable}};

assign DDR4_readdata = ddr4b_data_select ? temp_ddr4b_readdata : temp_ddr4a_readdata;

// Data is available 3 cycles after start_ddr4a_read|start_ddr4b_read is asserted
always @(posedge pClk) begin
        if (SoftReset) begin			
                data_valid_buf <= 3'b0;
        end else begin
                data_valid_buf <= {data_valid_buf[1:0], (start_ddr4a_read | start_ddr4b_read)};
        end
end

always @(posedge pClk) begin
        if (SoftReset) begin			
                DDR_data_valid <= 1'b0;			
        end else if (csr_ddr4a_read | csr_ddr4b_read) begin
                DDR_data_valid <= 1'b0;
        end else if (~DDR_data_valid && data_valid_buf[2]) begin
                DDR_data_valid <= 1'b1;
        end		
end

always @(posedge pClk) begin
        if (SoftReset) begin
                ddr4b_data_select <= 1'b0;
        end else if (csr_ddr4a_read | csr_ddr4b_read) begin			
                ddr4b_data_select <= csr_ddr4b_read;		
        end
end	

/*****************/
/* Wait for read */
/*****************/
// DDR4a
always @(posedge pClk) begin
        if (SoftReset) begin			
                read_ddr4a_data <= 1'b0;
                start_ddr4a_read <= 1'b0;
        end else if (csr_ddr4a_read) begin
                read_ddr4a_data <= 1'b1;		
        end else if (read_ddr4a_data) begin
                if (ddr4a_readdata_ready) begin
                        start_ddr4a_read <= 1'b1;
                        read_ddr4a_data <= 1'b0;
                end
        end else begin
                start_ddr4a_read <= 1'b0;
                read_ddr4a_data <= 1'b0;
        end
end

// DDR4b
always @(posedge pClk) begin
        if (SoftReset) begin
                start_ddr4b_read <= 1'b0;
                read_ddr4b_data <= 1'b0;
        end else if (csr_ddr4b_read) begin
                read_ddr4b_data <= 1'b1;		
        end else if (read_ddr4b_data) begin
                if (ddr4b_readdata_ready) begin
                        start_ddr4b_read <= 1'b1;
                        read_ddr4b_data <= 1'b0;
                end
        end else begin
                start_ddr4b_read <= 1'b0;
                read_ddr4b_data <= 1'b0;
        end
end

/****************************/
/* Clock crossing interface */
/****************************/
// DDR4a
mem_if #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.BYTEEN_WIDTH(BYTEEN_WIDTH),
	.BURSTCOUNT_WIDTH(BURSTCOUNT_WIDTH)
) ddr4a_mem_if (
        .pClk(pClk),
        .DDR_USERCLK(local_mem[0].clk),
        .SoftReset(SoftReset),
        .write(csr_ddr4a_write),
        .read(csr_ddr4a_read),
        .writedata(csr_ddr4a_writedata),
        .address(csr_ddr4a_address),
        .byteenable(csr_ddr4a_byteenable),
        .burstcount(csr_ddr4a_burstcount),
	.readdata_sel(csr_ddr4a_word_select),
        .read_ddr_data(start_ddr4a_read),	
        .ddr_data_ready(ddr4a_readdata_ready),
        .readdata(temp_ddr4a_readdata),
        .cmd_fifo_full(DDR4a_cmd_fifo_full),
        .ddr_write_timeout(DDR4a_write_timeout),
        .ddr_read_timeout(DDR4a_read_timeout),

        .DDR_waitrequest(local_mem[0].waitrequest),	
        .DDR_readdatavalid(local_mem[0].readdatavalid),
        .DDR_readdata(local_mem[0].readdata),
        .DDR_read(local_mem[0].read),
        .DDR_write(local_mem[0].write),
        .DDR_address(local_mem[0].address),
        .DDR_writedata(temp_ddr4a_writedata),
        .DDR_burstcount(local_mem[0].burstcount),
        .DDR_byteenable(temp_ddr4a_byteenable)
);		

// DDR4b
mem_if # (
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.BYTEEN_WIDTH(BYTEEN_WIDTH),
	.BURSTCOUNT_WIDTH(BURSTCOUNT_WIDTH)
) ddr4b_mem_if (
        .pClk(pClk),
        .DDR_USERCLK(local_mem[0].clk),
        .SoftReset(SoftReset),
        .write(csr_ddr4b_write),
        .read(csr_ddr4b_read),
        .writedata(csr_ddr4b_writedata),
        .address(csr_ddr4b_address),
        .byteenable(csr_ddr4b_byteenable),
        .burstcount(csr_ddr4b_burstcount),
	.readdata_sel(csr_ddr4b_word_select),
        .read_ddr_data(start_ddr4b_read),	
        .ddr_data_ready(ddr4b_readdata_ready),
        .readdata(temp_ddr4b_readdata),
        .cmd_fifo_full(DDR4b_cmd_fifo_full),
        .ddr_write_timeout(DDR4b_write_timeout),
        .ddr_read_timeout(DDR4b_read_timeout),

        .DDR_waitrequest(local_mem[1].waitrequest),	
        .DDR_readdatavalid(local_mem[1].readdatavalid),
        .DDR_readdata(local_mem[1].readdata),
        .DDR_read(local_mem[1].read),
        .DDR_write(local_mem[1].write),
        .DDR_address(local_mem[1].address),
        .DDR_writedata(temp_ddr4b_writedata),
        .DDR_burstcount(local_mem[1].burstcount),
        .DDR_byteenable(temp_ddr4b_byteenable)
);			

endmodule

