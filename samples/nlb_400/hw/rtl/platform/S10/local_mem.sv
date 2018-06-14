//
// Take very simple CSR-based commands to read/write one memory location at a
// time.
//
`include "ed_synth_tg_0.v"
`include "altera_emif_avl_tg_defs.sv"
`include "altera_emif_avl_tg_top.sv"
`include "altera_emif_avl_tg_addr_gen.sv"
`include "altera_emif_avl_tg_avl_mm_if.sv"
`include "altera_emif_avl_tg_avl_mm_srw_if.sv"
`include "altera_emif_avl_tg_block_rw_stage.sv"
`include "altera_emif_avl_tg_burst_boundary_addr_gen.sv"
`include "altera_emif_avl_tg_byteenable_stage.sv"
`include "altera_emif_avl_tg_driver_simple.sv"
`include "altera_emif_avl_tg_driver.sv"
`include "altera_emif_avl_tg_driver_fsm.sv"
`include "altera_emif_avl_tg_lfsr.sv"
`include "altera_emif_avl_tg_lfsr_wrapper.sv"
`include "altera_emif_avl_tg_rand_addr_gen.sv"
`include "altera_emif_avl_tg_rand_burstcount_gen.sv"
`include "altera_emif_avl_tg_rand_num_gen.sv"
`include "altera_emif_avl_tg_rand_seq_addr_gen.sv"
`include "altera_emif_avl_tg_read_compare.sv"
`include "altera_emif_avl_tg_reset_sync.sv"
`include "altera_emif_avl_tg_scfifo_wrapper.sv"
`include "altera_emif_avl_tg_seq_addr_gen.sv"
`include "altera_emif_avl_tg_single_rw_stage.sv"
`include "altera_emif_avl_tg_template_addr_gen.sv"
`include "altera_emif_avl_tg_template_stage.sv"
`include "altera_emif_avl_tg_amm_1x_bridge.sv" 

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
    localparam MEM_DATA_WORDS = local_mem_cfg_pkg::LOCAL_MEM_DATA_WIDTH / 64;
    localparam MEM_DATA_SELECT_WIDTH = $clog2(MEM_DATA_WORDS);
   typedef logic [MEM_BANK_IDX_WIDTH-1:0] t_mem_bank_idx;

   typedef logic [ADDR_WIDTH-1:0] t_addr;
   typedef logic [DATA_WIDTH-1:0] t_data;
   typedef logic [BURSTCOUNT_WIDTH-1:0] t_burstcount;
   typedef logic [BYTEEN_WIDTH-1:0] t_byte_en;
    typedef logic [MEM_DATA_SELECT_WIDTH-1:0] t_word_idx;

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
    
   // Pipelined commands for each memory bank
   t_data [NUM_LOCAL_MEM_BANKS-1:0] bank_cr2mem_ctrl;
   t_data [NUM_LOCAL_MEM_BANKS-1:0] bank_cr2mem_address;
   t_data [NUM_LOCAL_MEM_BANKS-1:0] bank_cr2mem_writedata;

   // Wait requests from each memory bank mapped to a vector
   logic [NUM_LOCAL_MEM_BANKS-1:0] mem_waitrequests;

   // Pipelined response from each memory bank
   t_data [NUM_LOCAL_MEM_BANKS-1:0] bank_mem_readdata, csr_mem_readdata_vec;
   logic [NUM_LOCAL_MEM_BANKS-1:0] bank_mem_readdatavalid, csr_mem_readdatavalid_vec;
    
   logic csr_mem_rd_en;
   t_mem_bank_idx csr_mem_rd_bank_idx;
   t_data mem_readdata;
   logic mem_readdatavalid;

   logic [NUM_LOCAL_MEM_BANKS-1:0] mem_wr_en;
   logic [NUM_LOCAL_MEM_BANKS-1:0] mem_rd_en;
   t_addr [NUM_LOCAL_MEM_BANKS-1:0] mem_addr;
   t_data [NUM_LOCAL_MEM_BANKS-1:0] mem_wr_data;
   t_burstcount [NUM_LOCAL_MEM_BANKS-1:0] mem_burstcount;
   t_byte_en [NUM_LOCAL_MEM_BANKS-1:0] mem_wr_byteenable;	 
   t_mem_bank_idx [NUM_LOCAL_MEM_BANKS-1:0] mem_wr_bank_idx;
   t_mem_bank_idx [NUM_LOCAL_MEM_BANKS-1:0] mem_rd_bank_idx;
   t_word_idx [NUM_LOCAL_MEM_BANKS-1:0] mem_rd_word_select;


 
   always @(posedge clk)
   begin
      cr2mem_ctrl_d0      <= cr2mem_ctrl;
      cr2mem_address_d0   <= cr2mem_address;
      cr2mem_writedata_d0 <= cr2mem_writedata;
	
      cr2mem_ctrl_d1      <= cr2mem_ctrl_d0;
      cr2mem_address_d1   <= cr2mem_address_d0;
      cr2mem_writedata_d1 <= cr2mem_writedata_d0;
   end   


   
`ifdef BIST_AFU
    logic csr_bist_ddr4a_enable, csr_bist_ddr4b_enable, csr_bist_ddr4c_enable, csr_bist_ddr4d_enable ;
    assign csr_bist_ddr4a_enable   = cr2mem_ctrl_d1[27];
    assign csr_bist_ddr4b_enable   = cr2mem_ctrl_d1[28];
    assign csr_bist_ddr4c_enable   = cr2mem_ctrl_d1[29];
    assign csr_bist_ddr4d_enable   = cr2mem_ctrl_d1[30];
`endif



   always_ff @(posedge clk)
   begin 
      csr_mem_rd_en <= cr2mem_ctrl_d1[0];

      // Bit 0 indicates reads
      if (cr2mem_ctrl_d1[0])
      begin
         csr_mem_rd_bank_idx <= t_mem_bank_idx'(cr2mem_ctrl_d1[3:2]);
      end

      if (SoftReset)
      begin
         csr_mem_rd_en <= 1'b0;
      end
   end


   genvar b;
   generate 
      for (b=0;b<NUM_LOCAL_MEM_BANKS;b=b+1) 
      begin : mem_pipe
         pipeline #(.WIDTH(DATA_WIDTH), .STAGE(3))  cr2mem_ctrl_pipe       (.clk(clk), .din(cr2mem_ctrl_d1),            .dout(bank_cr2mem_ctrl[b]));
         pipeline #(.WIDTH(DATA_WIDTH), .STAGE(3))  cr2mem_address_pipe    (.clk(clk), .din(cr2mem_address_d1),         .dout(bank_cr2mem_address[b]));
         pipeline #(.WIDTH(DATA_WIDTH), .STAGE(3))  cr2mem_writedata_pipe  (.clk(clk), .din(cr2mem_writedata_d1),       .dout(bank_cr2mem_writedata[b]));
         pipeline #(.WIDTH(DATA_WIDTH), .STAGE(3))  mem_readdata_pipe      (.clk(clk), .din(bank_mem_readdata[b]),      .dout(csr_mem_readdata_vec[b]));
         pipeline #(.WIDTH(1),          .STAGE(3))  mem_readdatavalid_pipe (.clk(clk), .din(bank_mem_readdatavalid[b]), .dout(csr_mem_readdatavalid_vec[b]));
      end
   endgenerate

   //
   // Receive commands
   //
  
   generate
      for (b = 0; b < NUM_LOCAL_MEM_BANKS; b = b + 1)
      begin : bank_mem_cmd
         
         t_data lcl_cr2mem_ctrl;
         t_data lcl_cr2mem_address;
         t_data lcl_cr2mem_writedata;
			
	 always_comb
	 begin
	    lcl_cr2mem_ctrl      = bank_cr2mem_ctrl[b];
	    lcl_cr2mem_address   = bank_cr2mem_address[b];
            lcl_cr2mem_writedata = bank_cr2mem_writedata[b];
	 end

         always_ff @(posedge clk)
         begin 
            // Bit 1 indicates writes
            if (lcl_cr2mem_ctrl[1])
            begin
               mem_wr_en[b]       <= 1'b1;
               mem_wr_bank_idx[b] <= t_mem_bank_idx'(lcl_cr2mem_ctrl[3:2]);
            end
            else if (! mem_waitrequests[b])
            begin
               // If there was a request in the previous cycle it was sent.
               mem_wr_en[b] <= 1'b0;
            end

            // Bit 0 indicates reads
            if (lcl_cr2mem_ctrl[0])
            begin
               mem_rd_en[b]          <= 1'b1;
               mem_rd_bank_idx[b]    <= t_mem_bank_idx'(lcl_cr2mem_ctrl[3:2]);
               mem_rd_word_select[b] <= lcl_cr2mem_ctrl[16+:MEM_DATA_SELECT_WIDTH];
            end
            else if (! mem_waitrequests[b])
            begin
               // If there was a request in the previous cycle it was sent.
               mem_rd_en[b] <= 1'b0;
            end

            if (SoftReset)
            begin
               mem_wr_en[b] <= 1'b0;
               mem_rd_en[b] <= 1'b0;
            end
         end
	 
	      always_comb
         begin
	      // These are held constant in the CSRs
	         mem_addr[b]          = t_addr'(lcl_cr2mem_address);
	         mem_wr_data[b]       = lcl_cr2mem_writedata;
	         mem_burstcount[b]    = lcl_cr2mem_ctrl[26:20];
	         mem_wr_byteenable[b] = {MEM_DATA_WORDS{lcl_cr2mem_ctrl[11:4]}};
	      end

	      always_ff @(posedge clk)
	      begin
	         if (! SoftReset)
	         begin
	            assert(mem_burstcount[b] <= t_burstcount'(1)) else
	               $fatal(2, "Burst count not supported yet!");
	         end
         end
      end
   endgenerate
  
 //BIST_AFU   

`ifdef BIST_AFU  
  wire ddr4a_bist_amm_read, ddr4b_bist_amm_read, ddr4c_bist_amm_read, ddr4d_bist_amm_read;
  wire ddr4a_bist_amm_write, ddr4b_bist_amm_write, ddr4c_bist_amm_write, ddr4d_bist_amm_write; 
  wire [BURSTCOUNT_WIDTH-1:0]  ddr4a_bist_amm_burstcount, ddr4b_bist_amm_burstcount, ddr4c_bist_amm_burstcount, ddr4d_bist_amm_burstcount;
  wire [ADDR_WIDTH-1:0]        ddr4a_bist_amm_address, ddr4b_bist_amm_address, ddr4c_bist_amm_address, ddr4d_bist_amm_address;
  wire [8*BYTEEN_WIDTH-1:0]      ddr4a_bist_amm_byteenable, ddr4b_bist_amm_byteenable, ddr4c_bist_amm_byteenable, ddr4d_bist_amm_byteenable;
  wire [8*DATA_WIDTH-1:0]      ddr4a_bist_amm_writedata, ddr4b_bist_amm_writedata, ddr4c_bist_amm_writedata, ddr4d_bist_amm_writedata;
  wire ddr4a_bist_traffic_gen_pass, ddr4b_bist_traffic_gen_pass, ddr4c_bist_traffic_gen_pass, ddr4d_bist_traffic_gen_pass;
  wire ddr4a_bist_traffic_gen_fail, ddr4b_bist_traffic_gen_fail,  ddr4c_bist_traffic_gen_fail, ddr4d_bist_traffic_gen_fail;
  wire ddr4a_bist_traffic_gen_timeout, ddr4b_bist_traffic_gen_timeout, ddr4c_bist_traffic_gen_timeout, ddr4d_bist_traffic_gen_timeout;
  logic [3:0] ddr4a_fsm_state, ddr4b_fsm_state, ddr4c_fsm_state, ddr4d_fsm_state;

  always_comb 
  begin
    if(csr_bist_ddr4a_enable || csr_bist_ddr4b_enable ||  csr_bist_ddr4c_enable ||  csr_bist_ddr4d_enable ) begin
        mem2cr_status = {29'h0,ddr4d_fsm_state, ddr4c_fsm_state, ddr4b_fsm_state, ddr4a_fsm_state, 
                         ddr4d_bist_traffic_gen_pass, ddr4d_bist_traffic_gen_fail, ddr4d_bist_traffic_gen_timeout, 
                         ddr4c_bist_traffic_gen_pass, ddr4c_bist_traffic_gen_fail, ddr4c_bist_traffic_gen_timeout,
                         ddr4b_bist_traffic_gen_pass, ddr4b_bist_traffic_gen_fail, ddr4b_bist_traffic_gen_timeout,
                         ddr4a_bist_traffic_gen_pass, ddr4a_bist_traffic_gen_fail, ddr4a_bist_traffic_gen_timeout, 
                         /*DDR4b_cmd_fifo_full, DDR4b_read_timeout, DDR4b_write_timeout, 
                         DDR4a_cmd_fifo_full, DDR4a_read_timeout, DDR4a_write_timeout, DDR_data_valid*/7'b0}; 
    end 
    else 
    begin
        mem2cr_status    = t_data'(0);
        mem2cr_status[0] = mem_readdatavalid;
        // Tell the host the number of memory banks
        mem2cr_status[63:56] = NUM_LOCAL_MEM_BANKS;
        mem2cr_readdata      = mem_readdata;
        
        
    end
  end

//DDRa 
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
always @(*) 
begin
  if (csr_bist_ddr4a_enable == 1'b1) 
  begin
    local_mem[0].read            = ddr4a_bist_amm_read;
    local_mem[0].write           = ddr4a_bist_amm_write;
    local_mem[0].address         = ddr4a_bist_amm_address;
    local_mem[0].writedata       = ddr4a_bist_amm_writedata;
    local_mem[0].burstcount      = ddr4a_bist_amm_burstcount;
    local_mem[0].byteenable      = ddr4a_bist_amm_byteenable;
  end
  else 
  begin
    local_mem[0].read            = mem_rd_en[0] && (mem_rd_bank_idx[0] == t_mem_bank_idx'(0));              
    local_mem[0].write           = mem_wr_en[0] && (mem_wr_bank_idx[0] == t_mem_bank_idx'(0));
    local_mem[0].address         = mem_addr[0];
    local_mem[0].writedata       = {MEM_DATA_WORDS{mem_wr_data[0]}};
    local_mem[0].burstcount      = mem_burstcount[0];
    local_mem[0].byteenable      = mem_wr_byteenable[0];
    mem_waitrequests[0]          = local_mem[0].waitrequest;
    bank_mem_readdatavalid[0]    = local_mem[0].readdatavalid;
    bank_mem_readdata[0]         = selectWord(local_mem[0].readdata, mem_rd_word_select);
 end
end

//DDRb
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

always @(*) 
begin
  if (csr_bist_ddr4b_enable == 1'b1) 
  begin
    local_mem[1].read            = ddr4b_bist_amm_read;
    local_mem[1].write           = ddr4b_bist_amm_write;
    local_mem[1].address         = ddr4b_bist_amm_address;
    local_mem[1].writedata       = ddr4b_bist_amm_writedata;
    local_mem[1].burstcount      = ddr4b_bist_amm_burstcount;
    local_mem[1].byteenable      = ddr4b_bist_amm_byteenable;
  end
  else 
  begin
    local_mem[1].read            = mem_rd_en[1] && (mem_rd_bank_idx[1] == t_mem_bank_idx'(1));
    local_mem[1].write           = mem_wr_en[1] && (mem_wr_bank_idx[1] == t_mem_bank_idx'(1));
    local_mem[1].address         = mem_addr[1];
    local_mem[1].writedata       = {MEM_DATA_WORDS{mem_wr_data[1]}};
    local_mem[1].burstcount      = mem_burstcount[1];
    local_mem[1].byteenable      = mem_wr_byteenable[1];
    mem_waitrequests[1]          = local_mem[1].waitrequest;
    bank_mem_readdatavalid[1]    = local_mem[1].readdatavalid;
    bank_mem_readdata[1]         = selectWord(local_mem[1].readdata, mem_rd_word_select);
  end
end

//DDRc
ed_synth_tg_0 ddr4c_bist_tg_0_inst (
  .emif_usr_clk	                (local_mem[2].clk),                    //	input		
  .emif_usr_reset_n	        (~SoftReset && csr_bist_ddr4c_enable), //	input		
  .amm_ready_0	                (~local_mem[2].waitrequest),                //	input		
  .amm_read_0	                (ddr4c_bist_amm_read),                    //	output		
  .amm_write_0	                (ddr4c_bist_amm_write),                   //	output		
  .amm_address_0	        (ddr4c_bist_amm_address),                 //	output	[31:0]	
  .amm_readdata_0	        (local_mem[2].readdata),                   //	input	[511:0]	
  .amm_writedata_0	        (ddr4c_bist_amm_writedata),               //	output	[511:0]	
  .amm_burstcount_0	        (ddr4c_bist_amm_burstcount),              // 	output	[6:0]	
  .amm_byteenable_0	        (ddr4c_bist_amm_byteenable),              //	output	[63:0]	
  .amm_readdatavalid_0	        (local_mem[2].readdatavalid),              //	input		
  .fsm_state                    (ddr4c_fsm_state),
  .traffic_gen_pass_0	        (ddr4c_bist_traffic_gen_pass),            //	output		
  .traffic_gen_fail_0	        (ddr4c_bist_traffic_gen_fail),            //	output		
  .traffic_gen_timeout_0	(ddr4c_bist_traffic_gen_timeout)          //	output		
);

always @(*) 
begin
  if (csr_bist_ddr4c_enable == 1'b1) 
  begin
    local_mem[2].read            = ddr4c_bist_amm_read;
    local_mem[2].write           = ddr4c_bist_amm_write;
    local_mem[2].address         = ddr4c_bist_amm_address;
    local_mem[2].writedata       = ddr4c_bist_amm_writedata;
    local_mem[2].burstcount      = ddr4c_bist_amm_burstcount;
    local_mem[2].byteenable      = ddr4c_bist_amm_byteenable;
  end
  else 
  begin
    local_mem[2].read            = mem_rd_en[2] && (mem_rd_bank_idx[2] == t_mem_bank_idx'(2));
    local_mem[2].write           = mem_wr_en[2] && (mem_wr_bank_idx[2] == t_mem_bank_idx'(2));
    local_mem[2].address         = mem_addr[2];
    local_mem[2].writedata       = {MEM_DATA_WORDS{mem_wr_data[2]}};
    local_mem[2].burstcount      = mem_burstcount[2];
    local_mem[2].byteenable      = mem_wr_byteenable[2];
    mem_waitrequests[2]          = local_mem[2].waitrequest;
    bank_mem_readdatavalid[2]    = local_mem[2].readdatavalid;
    bank_mem_readdata[2]         = selectWord(local_mem[2].readdata, mem_rd_word_select);
  end
end

//DDRd
ed_synth_tg_0 ddr4d_bist_tg_0_inst (
  .emif_usr_clk	                (local_mem[3].clk),                    //	input		
  .emif_usr_reset_n	        (~SoftReset && csr_bist_ddr4b_enable), //	input		
  .amm_ready_0	                (~local_mem[3].waitrequest),                //	input		
  .amm_read_0	                (ddr4d_bist_amm_read),                    //	output		
  .amm_write_0	                (ddr4d_bist_amm_write),                   //	output		
  .amm_address_0	        (ddr4d_bist_amm_address),                 //	output	[31:0]	
  .amm_readdata_0	        (local_mem[3].readdata),                   //	input	[511:0]	
  .amm_writedata_0	        (ddr4d_bist_amm_writedata),               //	output	[511:0]	
  .amm_burstcount_0	        (ddr4d_bist_amm_burstcount),              // 	output	[6:0]	
  .amm_byteenable_0	        (ddr4d_bist_amm_byteenable),              //	output	[63:0]	
  .amm_readdatavalid_0	        (local_mem[3].readdatavalid),              //	input		
  .fsm_state                    (ddr4d_fsm_state),
  .traffic_gen_pass_0	        (ddr4d_bist_traffic_gen_pass),            //	output		
  .traffic_gen_fail_0	        (ddr4d_bist_traffic_gen_fail),            //	output		
  .traffic_gen_timeout_0	(ddr4d_bist_traffic_gen_timeout)          //	output		
);

always @(*) 
begin
  if (csr_bist_ddr4d_enable == 1'b1) 
  begin
    local_mem[3].read            = ddr4d_bist_amm_read;
    local_mem[3].write           = ddr4d_bist_amm_write;
    local_mem[3].address         = ddr4d_bist_amm_address;
    local_mem[3].writedata       = ddr4d_bist_amm_writedata;
    local_mem[3].burstcount      = ddr4d_bist_amm_burstcount;
    local_mem[3].byteenable      = ddr4d_bist_amm_byteenable;
  end
  else 
  begin
    local_mem[3].read            = mem_rd_en[3] && (mem_rd_bank_idx[3] == t_mem_bank_idx'(3));
    local_mem[3].write           = mem_wr_en[3] && (mem_wr_bank_idx[3] == t_mem_bank_idx'(3));
    local_mem[3].address         = mem_addr[3];
    local_mem[3].writedata       = {MEM_DATA_WORDS{mem_wr_data[3]}};
    local_mem[3].burstcount      = mem_burstcount[3];
    local_mem[3].byteenable      = mem_wr_byteenable[3];
    mem_waitrequests[3]          = local_mem[3].waitrequest;
    bank_mem_readdatavalid[3]    = local_mem[3].readdatavalid;
    bank_mem_readdata[3]         = selectWord(local_mem[3].readdata, mem_rd_word_select);
  end
end

`else 
always_comb 
begin
    mem2cr_status    = t_data'(0);
    mem2cr_status[0] = mem_readdatavalid; 
    // Tell the host the number of memory banks
    mem2cr_status[63:56] = NUM_LOCAL_MEM_BANKS;
    mem2cr_readdata      = mem_readdata;
end
`endif
   
   always_ff @(posedge clk)
   begin
      // Indicate a read response arrived. The flag is sticky and will remain
      // set until the next read request.
      if (csr_mem_readdatavalid_vec[csr_mem_rd_bank_idx])
      begin
          mem_readdatavalid <= 1'b1;
          mem_readdata      <= csr_mem_readdata_vec[csr_mem_rd_bank_idx];
      end

      if (SoftReset || csr_mem_rd_en)
      begin
          mem_readdatavalid <= 1'b0;
      end
   end

   
   // Map requests to banks
   
`ifndef BIST_AFU
   generate
      for (b = 0; b < NUM_LOCAL_MEM_BANKS; b = b + 1)
      begin : bank
         always_comb
         begin : m
            local_mem[b].write      = mem_wr_en[b] && (mem_wr_bank_idx[b] == t_mem_bank_idx'(b));
            local_mem[b].read       = mem_rd_en[b] && (mem_rd_bank_idx[b] == t_mem_bank_idx'(b));

            local_mem[b].address    = mem_addr[b];
            local_mem[b].writedata  = {MEM_DATA_WORDS{mem_wr_data[b]}};
            local_mem[b].byteenable = mem_wr_byteenable[b];
            local_mem[b].burstcount = mem_burstcount[b];
 
            mem_waitrequests[b]     = local_mem[b].waitrequest;
         end

         always_comb
         begin
            bank_mem_readdatavalid[b] = local_mem[b].readdatavalid;
            bank_mem_readdata[b]      = selectWord(local_mem[b].readdata, mem_rd_word_select[b]);
         end
      end
   endgenerate

`endif 
endmodule

