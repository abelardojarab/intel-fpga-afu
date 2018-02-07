module local_mem #(
   DATA_WIDTH = 64,
	ADDR_WIDTH = 27,
	BYTEEN_WIDTH = 8,
	BURSTCOUNT_WIDTH = 7
)(
  input  wire          Clk_400,
  input  wire          SoftReset,
  //input wire [DATA_WIDTH-1:0] cr2re_ctl,          
  output wire [DATA_WIDTH-1:0]   mem2cr_readdata,
  output wire [DATA_WIDTH-1:0]   mem2cr_status,
  input wire [DATA_WIDTH-1:0]    cr2mem_ctrl,
  input wire [DATA_WIDTH-1:0]    cr2mem_address,
  input wire [DATA_WIDTH-1:0]    cr2mem_writedata,
  input  wire          DDR4a_USERCLK,
  input  wire          DDR4a_waitrequest,
  input  wire [8*DATA_WIDTH-1:0]  DDR4a_readdata,
  input  wire          DDR4a_readdatavalid,
  output reg  [BURSTCOUNT_WIDTH-1:0]    DDR4a_burstcount /* synthesis preserve */,
  output reg  [8*DATA_WIDTH-1:0]  DDR4a_writedata,
  output reg  [ADDR_WIDTH-1:0]   DDR4a_address,
  output reg           DDR4a_write,
  output reg           DDR4a_read,
  output reg  [DATA_WIDTH-1:0]   DDR4a_byteenable /* synthesis preserve */,
  input  wire          DDR4b_USERCLK,
  input  wire          DDR4b_waitrequest,
  input  wire [8*DATA_WIDTH-1:0]  DDR4b_readdata,
  input  wire          DDR4b_readdatavalid,
  output reg  [BURSTCOUNT_WIDTH-1:0]    DDR4b_burstcount /* synthesis preserve */,
  output reg  [8*DATA_WIDTH-1:0]  DDR4b_writedata,
  output reg  [ADDR_WIDTH-1:0]   DDR4b_address,
  output reg           DDR4b_write,
  output reg           DDR4b_read,
  output reg  [DATA_WIDTH-1:0]   DDR4b_byteenable /* synthesis preserve */
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
`ifdef BIST_AFU
  wire csr_bist_ddr4a_enable;
  wire csr_bist_ddr4b_enable;
`endif
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

//assign mem2cr_status = {57'h0, DDR4b_cmd_fifo_full, DDR4b_read_timeout, DDR4b_write_timeout, DDR4a_cmd_fifo_full, DDR4a_read_timeout, DDR4a_write_timeout, DDR_data_valid};
assign mem2cr_readdata = DDR4_readdata;

/****************/
/* Read csr reg */
/****************/
always @(posedge Clk_400) begin
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
//assign DDR4a_writedata       = {8{temp_ddr4a_writedata}};	
//assign DDR4a_byteenable      = {8{temp_ddr4a_byteenable}};
// DDR4b
assign csr_ddr4b_write       = cr2mem_ctrl_d1[2];
assign csr_ddr4b_read        = cr2mem_ctrl_d1[3];
assign csr_ddr4b_byteenable  = cr2mem_ctrl_d1[11:4];
assign csr_ddr4b_word_select = cr2mem_ctrl_d1[18:16];
assign csr_ddr4b_burstcount  = cr2mem_ctrl_d1[26:20];
`ifdef BIST_AFU 
assign csr_bist_ddr4a_enable   = cr2mem_ctrl_d1[27];
assign csr_bist_ddr4b_enable   = cr2mem_ctrl_d1[28];
`endif
assign csr_ddr4b_address     = cr2mem_address_d1[ADDR_WIDTH-1:0];
assign csr_ddr4b_writedata   = cr2mem_writedata_d1;
//assign DDR4b_writedata       = {8{temp_ddr4b_writedata}};
//assign DDR4b_byteenable      = {8{temp_ddr4b_byteenable}};
        
assign DDR4_readdata = ddr4b_data_select ? temp_ddr4b_readdata : temp_ddr4a_readdata;

// Data is available 3 cycles after start_ddr4a_read|start_ddr4b_read is asserted
always @(posedge Clk_400) begin
        if (SoftReset) begin			
                data_valid_buf <= 3'b0;  
        end else begin
                data_valid_buf <= {data_valid_buf[1:0], (start_ddr4a_read | start_ddr4b_read)};
        end
end

always @(posedge Clk_400) begin
        if (SoftReset) begin			
                DDR_data_valid <= 1'b0;			
        end else if (csr_ddr4a_read | csr_ddr4b_read) begin
                DDR_data_valid <= 1'b0;
        end else if (~DDR_data_valid && data_valid_buf[2]) begin
                DDR_data_valid <= 1'b1;
        end		
end
        
always @(posedge Clk_400) begin
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
always @(posedge Clk_400) begin
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
always @(posedge Clk_400) begin
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

  wire [BURSTCOUNT_WIDTH-1:0] DDR4a_burstcount_c0, DDR4b_burstcount_c0;
  wire [ADDR_WIDTH-1:0]       DDR4a_address_c0, DDR4b_address_c0;
  wire DDR4a_read_c0, DDR4b_read_c0;
  wire DDR4a_write_c0, DDR4b_write_c0;
  //wire DDR4a_waitrequest_c0, DDR4b_waitrequest_c0;

// DDR4a
mem_if #(
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.BYTEEN_WIDTH(BYTEEN_WIDTH),
	.BURSTCOUNT_WIDTH(BURSTCOUNT_WIDTH)
) ddr4a_mem_if (
        .Clk_400            (Clk_400),
        .DDR_USERCLK        (DDR4a_USERCLK),
        .SoftReset          (SoftReset),
        .write              (csr_ddr4a_write),
        .read               (csr_ddr4a_read),
        .writedata          (csr_ddr4a_writedata),
        .address            (csr_ddr4a_address),
        .byteenable         (csr_ddr4a_byteenable),
        .burstcount         (csr_ddr4a_burstcount),
	.readdata_sel       (csr_ddr4a_word_select),
        .read_ddr_data      (start_ddr4a_read),	
        .ddr_data_ready     (ddr4a_readdata_ready),
        .readdata           (temp_ddr4a_readdata),
        .cmd_fifo_full      (DDR4a_cmd_fifo_full),
        .ddr_write_timeout  (DDR4a_write_timeout),
        .ddr_read_timeout   (DDR4a_read_timeout),
        
        .DDR_waitrequest    (DDR4a_waitrequest),	
        .DDR_readdatavalid  (DDR4a_readdatavalid),
        .DDR_readdata       (DDR4a_readdata),
        .DDR_read           (DDR4a_read_c0),
        .DDR_write          (DDR4a_write_c0),
        .DDR_address        (DDR4a_address_c0),
        .DDR_writedata      (temp_ddr4a_writedata),
        .DDR_burstcount     (DDR4a_burstcount_c0),
        .DDR_byteenable     (temp_ddr4a_byteenable)
);		

`ifdef BIST_AFU

  wire ddr4a_bist_amm_read, ddr4b_bist_amm_read;
  wire ddr4a_bist_amm_write, ddr4b_bist_amm_write; 
  wire [BURSTCOUNT_WIDTH-1:0]  ddr4a_bist_amm_burstcount, ddr4b_bist_amm_burstcount;
  wire [ADDR_WIDTH-1:0]        ddr4a_bist_amm_address, ddr4b_bist_amm_address;
  wire [8*BYTEEN_WIDTH-1:0]      ddr4a_bist_amm_byteenable, ddr4b_bist_amm_byteenable;
  wire [8*DATA_WIDTH-1:0]      ddr4a_bist_amm_writedata, ddr4b_bist_amm_writedata;
  wire ddr4a_bist_traffic_gen_pass, ddr4b_bist_traffic_gen_pass;
  wire ddr4a_bist_traffic_gen_fail, ddr4b_bist_traffic_gen_fail;
  wire ddr4a_bist_traffic_gen_timeout, ddr4b_bist_traffic_gen_timeout;

  assign mem2cr_status = {51'h0, ddr4b_bist_traffic_gen_pass, ddr4b_bist_traffic_gen_fail, ddr4b_bist_traffic_gen_timeout,
                                ddr4a_bist_traffic_gen_pass, ddr4a_bist_traffic_gen_fail, ddr4a_bist_traffic_gen_timeout, 
                                DDR4b_cmd_fifo_full, DDR4b_read_timeout, DDR4b_write_timeout, 
                                DDR4a_cmd_fifo_full, DDR4a_read_timeout, DDR4a_write_timeout, DDR_data_valid};

ed_synth_tg_0 ddr4a_bist_tg_0_inst (
  .emif_usr_clk	                (DDR4a_USERCLK),                    //	input		
  .emif_usr_reset_n	        (~SoftReset && csr_bist_ddr4a_enable), //	input		
  .amm_ready_0	                (~DDR4a_waitrequest),                //	input		
  .amm_read_0	                (ddr4a_bist_amm_read),                    //	output		
  .amm_write_0	                (ddr4a_bist_amm_write),                   //	output		
  .amm_address_0	        (ddr4a_bist_amm_address),                 //	output	[31:0]	
  .amm_readdata_0	        (DDR4a_readdata),                   //	input	[511:0]	
  .amm_writedata_0	        (ddr4a_bist_amm_writedata),               //	output	[511:0]	
  .amm_burstcount_0	        (ddr4a_bist_amm_burstcount),              // 	output	[6:0]	
  .amm_byteenable_0	        (ddr4a_bist_amm_byteenable),              //	output	[63:0]	
  .amm_readdatavalid_0	        (DDR4a_readdatavalid),              //	input		
  .traffic_gen_pass_0	        (ddr4a_bist_traffic_gen_pass),            //	output		
  .traffic_gen_fail_0	        (ddr4a_bist_traffic_gen_fail),            //	output		
  .traffic_gen_timeout_0	(ddr4a_bist_traffic_gen_timeout)          //	output		
);

//MUX to select BIST Traffic Generator
always @(*) begin
  if (csr_bist_ddr4a_enable == 1'b1) begin
    DDR4a_read            = ddr4a_bist_amm_read;
    DDR4a_write           = ddr4a_bist_amm_write;
    DDR4a_address         = ddr4a_bist_amm_address;
    DDR4a_writedata       = ddr4a_bist_amm_writedata;
    DDR4a_burstcount      = ddr4a_bist_amm_burstcount;
    DDR4a_byteenable      = ddr4a_bist_amm_byteenable;
    //DDR4a_byteenable      = 64'hffffffffffffffff;
  end
  else begin
    DDR4a_read            = DDR4a_read_c0;
    DDR4a_write           = DDR4a_write_c0;
    DDR4a_address         = DDR4a_address_c0;
    DDR4a_writedata       = {8{temp_ddr4a_writedata}};
    DDR4a_burstcount      = DDR4a_burstcount_c0;
    DDR4a_byteenable      = {8{temp_ddr4a_byteenable}};
  end
end

ed_synth_tg_0 ddr4b_bist_tg_0_inst (
  .emif_usr_clk	                (DDR4b_USERCLK),                    //	input		
  .emif_usr_reset_n	        (~SoftReset && csr_bist_ddr4b_enable), //	input		
  .amm_ready_0	                (~DDR4b_waitrequest),                //	input		
  .amm_read_0	                (ddr4b_bist_amm_read),                    //	output		
  .amm_write_0	                (ddr4b_bist_amm_write),                   //	output		
  .amm_address_0	        (ddr4b_bist_amm_address),                 //	output	[31:0]	
  .amm_readdata_0	        (DDR4b_readdata),                   //	input	[511:0]	
  .amm_writedata_0	        (ddr4b_bist_amm_writedata),               //	output	[511:0]	
  .amm_burstcount_0	        (ddr4b_bist_amm_burstcount),              // 	output	[6:0]	
  .amm_byteenable_0	        (ddr4b_bist_amm_byteenable),              //	output	[63:0]	
  .amm_readdatavalid_0	        (DDR4b_readdatavalid),              //	input		
  .traffic_gen_pass_0	        (ddr4b_bist_traffic_gen_pass),            //	output		
  .traffic_gen_fail_0	        (ddr4b_bist_traffic_gen_fail),            //	output		
  .traffic_gen_timeout_0	(ddr4b_bist_traffic_gen_timeout)          //	output		
);

always @(*) begin
  if (csr_bist_ddr4b_enable == 1'b1) begin
    DDR4b_read            = ddr4b_bist_amm_read;
    DDR4b_write           = ddr4b_bist_amm_write;
    DDR4b_address         = ddr4b_bist_amm_address;
    DDR4b_writedata       = ddr4b_bist_amm_writedata;
    DDR4b_burstcount      = ddr4b_bist_amm_burstcount;
    DDR4b_byteenable      = ddr4b_bist_amm_byteenable;
  end
  else begin
    DDR4b_read            = DDR4b_read_c0;
    DDR4b_write           = DDR4b_write_c0;
    DDR4b_address         = DDR4b_address_c0;
    DDR4b_writedata       = {8{temp_ddr4b_writedata}};
    DDR4b_burstcount      = DDR4b_burstcount_c0;
    DDR4b_byteenable      = {8{temp_ddr4b_byteenable}};
  end
end

`else //BIST_AFU
always @(*) begin
    DDR4a_read            = DDR4a_read_c0;
    DDR4a_write           = DDR4a_write_c0;
    DDR4a_address         = DDR4a_address_c0;
    DDR4a_writedata       = {8{temp_ddr4a_writedata}};
    DDR4a_burstcount      = DDR4a_burstcount_c0;
    DDR4a_byteenable      = {8{temp_ddr4a_byteenable}};

    DDR4b_read            = DDR4b_read_c0;
    DDR4b_write           = DDR4b_write_c0;
    DDR4b_address         = DDR4b_address_c0;
    DDR4b_writedata       = {8{temp_ddr4b_writedata}};
    DDR4b_burstcount      = DDR4b_burstcount_c0;
    DDR4b_byteenable      = {8{temp_ddr4b_byteenable}};
end

 assign mem2cr_status = {57'h0, DDR4b_cmd_fifo_full, DDR4b_read_timeout, DDR4b_write_timeout, DDR4a_cmd_fifo_full, DDR4a_read_timeout, DDR4a_write_timeout, DDR_data_valid}; 
`endif //BIST_AFU

 // DDR4b
mem_if # (
	.DATA_WIDTH(DATA_WIDTH),
	.ADDR_WIDTH(ADDR_WIDTH),
	.BYTEEN_WIDTH(BYTEEN_WIDTH),
	.BURSTCOUNT_WIDTH(BURSTCOUNT_WIDTH)
) ddr4b_mem_if (
        .Clk_400(Clk_400),
        .DDR_USERCLK(DDR4b_USERCLK),
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
        
        .DDR_waitrequest(DDR4b_waitrequest),	
        .DDR_readdatavalid(DDR4b_readdatavalid),
        .DDR_readdata(DDR4b_readdata),
        .DDR_read(DDR4b_read_c0),
        .DDR_write(DDR4b_write_c0),
        .DDR_address(DDR4b_address_c0),
        .DDR_writedata(temp_ddr4b_writedata),
        .DDR_burstcount(DDR4b_burstcount_c0),
        .DDR_byteenable(temp_ddr4b_byteenable)
);			

endmodule

