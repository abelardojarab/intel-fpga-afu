//
// Take very simple CSR-based commands to read/write one memory location at a
// time.
//

module local_mem
  #(
    parameter DATA_WIDTH = 64,
    parameter NUM_LOCAL_MEM_BANKS=2,
    parameter ADDR_WIDTH = local_mem_cfg_pkg::LOCAL_MEM_ADDR_WIDTH,
    parameter BYTEEN_WIDTH = local_mem_cfg_pkg::LOCAL_MEM_DATA_N_BYTES,
    parameter BURSTCOUNT_WIDTH = local_mem_cfg_pkg::LOCAL_MEM_BURST_CNT_WIDTH
    )
   (
    input  logic clk,
    input  logic SoftReset,
    output logic [DATA_WIDTH-1:0] mem2cr_readdata,
    output logic [DATA_WIDTH-1:0] mem2cr_status,
    input  logic [DATA_WIDTH-1:0] cr2mem_ctrl,
    input  logic [DATA_WIDTH-1:0] cr2mem_address,
    input  logic [DATA_WIDTH-1:0] cr2mem_writedata,

    // Local memory interface, already moved to domain clk using the AFU JSON configuration
    avalon_mem_if.to_fiu local_mem[NUM_LOCAL_MEM_BANKS]
    );

    localparam MEM_BANK_IDX_WIDTH = $clog2(NUM_LOCAL_MEM_BANKS);
    typedef logic [MEM_BANK_IDX_WIDTH-1:0] t_mem_bank_idx;

    typedef logic [ADDR_WIDTH-1:0] t_addr;
    typedef logic [DATA_WIDTH-1:0] t_data;
    typedef logic [BURSTCOUNT_WIDTH-1:0] t_burstcount;
    typedef logic [BYTEEN_WIDTH-1:0] t_byte_en;
    typedef logic [2:0] t_word_idx;


    // Pick a 64 bit word from a memory line
    typedef logic [(local_mem_cfg_pkg::LOCAL_MEM_DATA_WIDTH / 64)-1:0][63:0] t_mem_data64_vec;
    function automatic t_data selectWord(local_mem_cfg_pkg::t_local_mem_data d,
                                         t_word_idx w);
        t_mem_data64_vec v;
        v = d;
        return t_data'(v[w]);
    endfunction


    //
    // Register commands for timing.
    //
    t_data cr2mem_ctrl_d0, cr2mem_ctrl_d1;
    t_data cr2mem_address_d0, cr2mem_address_d1;
    t_data cr2mem_writedata_d0, cr2mem_writedata_d1;

    always @(posedge clk)
    begin
	cr2mem_ctrl_d0 <= cr2mem_ctrl;
	cr2mem_address_d0 <= cr2mem_address;
	cr2mem_writedata_d0 <= cr2mem_writedata;
	
	cr2mem_ctrl_d1 <= cr2mem_ctrl_d0;
	cr2mem_address_d1 <= cr2mem_address_d0;
	cr2mem_writedata_d1 <= cr2mem_writedata_d0;
    end


    //
    // Receive commands
    //

    logic mem_wr_en;
    t_mem_bank_idx mem_wr_bank_idx;

    logic mem_rd_en;
    t_mem_bank_idx mem_rd_bank_idx;
`ifdef BIST_AFU
    logic csr_bist_ddr4a_enable, csr_bist_ddr4b_enable;
    assign csr_bist_ddr4a_enable   = cr2mem_ctrl_d1[27];
    assign csr_bist_ddr4b_enable   = cr2mem_ctrl_d1[28];
`endif
    t_addr mem_addr;
    t_data mem_wr_data;
    t_burstcount mem_burstcount;
    t_byte_en mem_wr_byteenable;
    t_word_idx mem_rd_word_select;

    // Wait requests from each memory bank mapped to a vector
    logic [NUM_LOCAL_MEM_BANKS-1:0] mem_waitrequests;

    always_ff @(posedge clk)
    begin
        // Bit 1 indicates writes
        if (cr2mem_ctrl_d1[1])
        begin
            mem_wr_en <= 1'b1;
            mem_wr_bank_idx <= t_mem_bank_idx'(cr2mem_ctrl_d1[3:2]);
        end
        else if (! mem_waitrequests[mem_wr_bank_idx])
        begin
            // If there was a request in the previous cycle it was sent.
            mem_wr_en <= 1'b0;
        end

        // Bit 0 indicates reads
        if (cr2mem_ctrl_d1[0])
        begin
            mem_rd_en <= 1'b1;
            mem_rd_bank_idx <= t_mem_bank_idx'(cr2mem_ctrl_d1[3:2]);
            mem_rd_word_select <= cr2mem_ctrl_d1[18:16];
        end
        else if (! mem_waitrequests[mem_rd_bank_idx])
        begin
            // If there was a request in the previous cycle it was sent.
            mem_rd_en <= 1'b0;
        end

        if (SoftReset)
        begin
            mem_wr_en <= 1'b0;
            mem_rd_en <= 1'b0;
	end
    end

    always_comb
    begin
        // These are held constant in the CSRs
        mem_addr = t_addr'(cr2mem_address_d1);
        mem_wr_data = cr2mem_writedata_d1;
        mem_burstcount = cr2mem_ctrl_d1[26:20];
        mem_wr_byteenable = {8{cr2mem_ctrl_d1[11:4]}};
    end

    always_ff @(posedge clk)
    begin
        if (! SoftReset)
        begin
            assert(mem_burstcount <= t_burstcount'(1)) else
              $fatal(2, "Burst count not supported yet!");
        end
    end

    //
    // Respond with state
    //
    t_data mem_readdata;
    t_data [NUM_LOCAL_MEM_BANKS-1:0] mem_readdata_vec;
    logic [NUM_LOCAL_MEM_BANKS-1:0] mem_readdatavalid_vec;
    logic mem_readdatavalid;

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
  logic [3:0] ddr4a_fsm_state, ddr4b_fsm_state;

  always_comb begin
    if(csr_bist_ddr4a_enable || csr_bist_ddr4b_enable) begin
        mem2cr_status = {43'h0,ddr4b_fsm_state, ddr4a_fsm_state, ddr4b_bist_traffic_gen_pass, ddr4b_bist_traffic_gen_fail, ddr4b_bist_traffic_gen_timeout,
                                  ddr4a_bist_traffic_gen_pass, ddr4a_bist_traffic_gen_fail, ddr4a_bist_traffic_gen_timeout, 
                                  /*DDR4b_cmd_fifo_full, DDR4b_read_timeout, DDR4b_write_timeout, 
                                  DDR4a_cmd_fifo_full, DDR4a_read_timeout, DDR4a_write_timeout, DDR_data_valid*/7'b0};
    end else begin
        mem2cr_status = t_data'(0);
        mem2cr_status[0] = mem_readdatavalid;
        // Tell the host the number of memory banks
        mem2cr_status[63:56] = NUM_LOCAL_MEM_BANKS;
        mem2cr_readdata = mem_readdata;
    end
  end

ed_synth_tg_0 ddr4a_bist_tg_0_inst (
  .emif_usr_clk	                (local_mem[0].clk),                    //	input		
  .emif_usr_reset_n	        (~SoftReset && csr_bist_ddr4a_enable), //	input		
  .amm_ready_0	                (~local_mem[0].waitrequest),                //	input		
  .amm_read_0	                (ddr4a_bist_amm_read),                    //	output		
  .amm_write_0	                (ddr4a_bist_amm_write),                   //	output		
  .amm_address_0	        (ddr4a_bist_amm_address),                 //	output	[31:0]	
  .amm_readdata_0	        (local_mem[0].readdata),                   //	input	[511:0]	
  .amm_writedata_0	        (ddr4a_bist_amm_writedata),               //	output	[511:0]	
  .amm_burstcount_0	        (ddr4a_bist_amm_burstcount),              // 	output	[6:0]	
  .amm_byteenable_0	        (ddr4a_bist_amm_byteenable),              //	output	[63:0]	
  .amm_readdatavalid_0	        (local_mem[0].readdatavalid),              //	input		
  .fsm_state                    (ddr4a_fsm_state),
  .traffic_gen_pass_0	        (ddr4a_bist_traffic_gen_pass),            //	output		
  .traffic_gen_fail_0	        (ddr4a_bist_traffic_gen_fail),            //	output		
  .traffic_gen_timeout_0	(ddr4a_bist_traffic_gen_timeout)          //	output		
);

//MUX to select BIST Traffic Generator
always @(*) begin
  if (csr_bist_ddr4a_enable == 1'b1) begin
    local_mem[0].read            = ddr4a_bist_amm_read;
    local_mem[0].write           = ddr4a_bist_amm_write;
    local_mem[0].address         = ddr4a_bist_amm_address;
    local_mem[0].writedata       = ddr4a_bist_amm_writedata;
    local_mem[0].burstcount      = ddr4a_bist_amm_burstcount;
    local_mem[0].byteenable      = ddr4a_bist_amm_byteenable;
  end
  else begin
    local_mem[0].read            = mem_rd_en && (mem_rd_bank_idx == t_mem_bank_idx'(0));
    local_mem[0].write           = mem_wr_en && (mem_wr_bank_idx == t_mem_bank_idx'(0));
    local_mem[0].address         = mem_addr;
    local_mem[0].writedata       = {8{mem_wr_data}};
    local_mem[0].burstcount      = mem_burstcount;
    local_mem[0].byteenable      = mem_wr_byteenable;
    mem_waitrequests[0]          = local_mem[0].waitrequest;
    mem_readdatavalid_vec[0]     = local_mem[0].readdatavalid;
    mem_readdata_vec[0]          = selectWord(local_mem[0].readdata, mem_rd_word_select);
 end
end

ed_synth_tg_0 ddr4b_bist_tg_0_inst (
  .emif_usr_clk	                (local_mem[1].clk),                    //	input		
  .emif_usr_reset_n	        (~SoftReset && csr_bist_ddr4b_enable), //	input		
  .amm_ready_0	                (~local_mem[1].waitrequest),                //	input		
  .amm_read_0	                (ddr4b_bist_amm_read),                    //	output		
  .amm_write_0	                (ddr4b_bist_amm_write),                   //	output		
  .amm_address_0	        (ddr4b_bist_amm_address),                 //	output	[31:0]	
  .amm_readdata_0	        (local_mem[1].readdata),                   //	input	[511:0]	
  .amm_writedata_0	        (ddr4b_bist_amm_writedata),               //	output	[511:0]	
  .amm_burstcount_0	        (ddr4b_bist_amm_burstcount),              // 	output	[6:0]	
  .amm_byteenable_0	        (ddr4b_bist_amm_byteenable),              //	output	[63:0]	
  .amm_readdatavalid_0	        (local_mem[1].readdatavalid),              //	input		
  .fsm_state                    (ddr4b_fsm_state),
  .traffic_gen_pass_0	        (ddr4b_bist_traffic_gen_pass),            //	output		
  .traffic_gen_fail_0	        (ddr4b_bist_traffic_gen_fail),            //	output		
  .traffic_gen_timeout_0	(ddr4b_bist_traffic_gen_timeout)          //	output		
);

always @(*) begin
  if (csr_bist_ddr4b_enable == 1'b1) begin
    local_mem[1].read            = ddr4b_bist_amm_read;
    local_mem[1].write           = ddr4b_bist_amm_write;
    local_mem[1].address         = ddr4b_bist_amm_address;
    local_mem[1].writedata       = ddr4b_bist_amm_writedata;
    local_mem[1].burstcount      = ddr4b_bist_amm_burstcount;
    local_mem[1].byteenable      = ddr4b_bist_amm_byteenable;
  end
  else begin
    local_mem[1].read            = mem_rd_en && (mem_rd_bank_idx == t_mem_bank_idx'(1));
    local_mem[1].write           = mem_wr_en && (mem_wr_bank_idx == t_mem_bank_idx'(1));
    local_mem[1].address         = mem_addr;
    local_mem[1].writedata       = {8{mem_wr_data}};
    local_mem[1].burstcount      = mem_burstcount;
    local_mem[1].byteenable      = mem_wr_byteenable;
    mem_waitrequests[1]          = local_mem[1].waitrequest;
    mem_readdatavalid_vec[1]     = local_mem[1].readdatavalid;
    mem_readdata_vec[1]          = selectWord(local_mem[1].readdata, mem_rd_word_select);
  end
end

`else //BIST_AFU
/*always @(*) begin
    local_mem[0].read            = DDR4a_read_c0;
    local_mem[0].write           = DDR4a_write_c0;
    local_mem[0].address         = DDR4a_address_c0;
    local_mem[0].writedata       = {8{temp_ddr4a_writedata}};
    local_mem[0].burstcount      = local_mem[0]_burstcount_c0;
    local_mem[0].byteenable      = {8{temp_ddr4a_byteenable}};

    local_mem[1].read            = DDR4b_read_c0;
    local_mem[1].write           = DDR4b_write_c0;
    local_mem[1].address         = DDR4b_address_c0;
    local_mem[1].writedata       = {8{temp_ddr4b_writedata}};
    local_mem[1].burstcount      = DDR4b_burstcount_c0;
    local_mem[1].byteenable      = {8{temp_ddr4b_byteenable}};
end*/

  always_comb begin
      mem2cr_status = t_data'(0);
      mem2cr_status[0] = mem_readdatavalid;
      // Tell the host the number of memory banks
      mem2cr_status[63:56] = NUM_LOCAL_MEM_BANKS;
      mem2cr_readdata = mem_readdata;
  end

 //assign mem2cr_status = {57'h0, DDR4b_cmd_fifo_full, DDR4b_read_timeout, DDR4b_write_timeout, DDR4a_cmd_fifo_full, DDR4a_read_timeout, DDR4a_write_timeout, DDR_data_valid}; 
`endif //BIST_AFU

    always_ff @(posedge clk)
    begin
        // Indicate a read response arrived. The flag is sticky and will remain
        // set until the next read request.
        if (mem_readdatavalid_vec[mem_rd_bank_idx])
        begin
            mem_readdatavalid <= 1'b1;
            mem_readdata <= mem_readdata_vec[mem_rd_bank_idx];
        end

        if (SoftReset || mem_rd_en)
        begin
            mem_readdatavalid <= 1'b0;
        end
    end


    //
    // Map requests to banks
    //
/*    genvar b;
    generate
        for (b = 0; b < NUM_LOCAL_MEM_BANKS; b = b + 1)
        begin : bank
            always_comb
            begin : m
                local_mem[b].write = mem_wr_en && (mem_wr_bank_idx == t_mem_bank_idx'(b));
                local_mem[b].read = mem_rd_en && (mem_rd_bank_idx == t_mem_bank_idx'(b));

                local_mem[b].address = mem_addr;
                local_mem[b].writedata = {8{mem_wr_data}};
                local_mem[b].byteenable = mem_wr_byteenable;
                local_mem[b].burstcount = mem_burstcount;

                mem_waitrequests[b] = local_mem[b].waitrequest;
                mem_readdatavalid_vec[b] = local_mem[b].readdatavalid;
                mem_readdata_vec[b] = selectWord(local_mem[b].readdata, mem_rd_word_select);
            end
        end
    endgenerate*/

endmodule

