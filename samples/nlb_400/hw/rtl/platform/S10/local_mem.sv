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

   // Pipelined soft reset for each memory bank
   logic [NUM_LOCAL_MEM_BANKS-1:0] bank_SoftReset;

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


 
   always @(posedge clk) begin
      cr2mem_ctrl_d0      <= cr2mem_ctrl;
      cr2mem_address_d0   <= cr2mem_address;
      cr2mem_writedata_d0 <= cr2mem_writedata;
	
      cr2mem_ctrl_d1      <= cr2mem_ctrl_d0;
      cr2mem_address_d1   <= cr2mem_address_d0;
      cr2mem_writedata_d1 <= cr2mem_writedata_d0;
   end   

genvar b;
   
`ifdef BIST_AFU
    wire [NUM_LOCAL_MEM_BANKS-1:0]                        ddr4_bist_amm_read;
    wire [NUM_LOCAL_MEM_BANKS-1:0]                        ddr4_bist_amm_write;
    wire [NUM_LOCAL_MEM_BANKS-1:0][BURSTCOUNT_WIDTH-1:0]  ddr4_bist_amm_burstcount;
    wire [NUM_LOCAL_MEM_BANKS-1:0][ADDR_WIDTH-1:0]        ddr4_bist_amm_address;
    wire [NUM_LOCAL_MEM_BANKS-1:0][BYTEEN_WIDTH-1:0]      ddr4_bist_amm_byteenable;
    wire [NUM_LOCAL_MEM_BANKS-1:0][MEM_DATA_WORDS*DATA_WIDTH-1:0]      ddr4_bist_amm_writedata;
    wire [NUM_LOCAL_MEM_BANKS-1:0]                        ddr4_bist_traffic_gen_pass;
    wire [NUM_LOCAL_MEM_BANKS-1:0]                        ddr4_bist_traffic_gen_fail;
    wire [NUM_LOCAL_MEM_BANKS-1:0]                        ddr4_bist_traffic_gen_timeout;
    logic [NUM_LOCAL_MEM_BANKS-1:0] [3:0]                 ddr4_fsm_state;
  
    logic [NUM_LOCAL_MEM_BANKS-1:0]       csr_bist_ddr4_enable;
    logic [NUM_LOCAL_MEM_BANKS-1:0]       bank_csr_bist_ddr4_enable;
    logic [NUM_LOCAL_MEM_BANKS-1:0] [3:0] pipe_ddr4_fsm_state;
    logic [NUM_LOCAL_MEM_BANKS-1:0]       pipe_ddr4_bist_traffic_gen_pass;
    logic [NUM_LOCAL_MEM_BANKS-1:0]       pipe_ddr4_bist_traffic_gen_fail;
    logic [NUM_LOCAL_MEM_BANKS-1:0]       pipe_ddr4_bist_traffic_gen_timeout;

    assign csr_bist_ddr4_enable = cr2mem_ctrl_d1[30:27]; 
	 
      generate 
      for (b=0;b<NUM_LOCAL_MEM_BANKS;b=b+1) begin : bist_gen
		   
         assign bank_csr_bist_ddr4_enable[b] = bank_cr2mem_ctrl[b][27]; 
         
         pipeline #(.WIDTH(7), .STAGE(3))  bist_status_pipe (.clk(clk), 
            .din({ ddr4_fsm_state[b],
                   ddr4_bist_traffic_gen_pass[b],
                   ddr4_bist_traffic_gen_fail[b],
                   ddr4_bist_traffic_gen_timeout[b]				      
                  }),
            .dout({ pipe_ddr4_fsm_state[b],
                    pipe_ddr4_bist_traffic_gen_pass[b],
                    pipe_ddr4_bist_traffic_gen_fail[b],
                    pipe_ddr4_bist_traffic_gen_timeout[b]				      
                  })
	 );					  
      end		
   endgenerate	 
`endif

   always_ff @(posedge clk) begin 
      csr_mem_rd_en <= cr2mem_ctrl_d1[0];

      // Bit 0 indicates reads
      if (cr2mem_ctrl_d1[0]) begin
         csr_mem_rd_bank_idx <= t_mem_bank_idx'(cr2mem_ctrl_d1[3:2]);
      end

      if (SoftReset) begin
         csr_mem_rd_en <= 1'b0;
      end
   end


   generate 
      for (b=0;b<NUM_LOCAL_MEM_BANKS;b=b+1) begin : mem_pipe
         pipeline #(.WIDTH(DATA_WIDTH), .STAGE(3))  cr2mem_ctrl_pipe       (.clk(clk), .din(cr2mem_ctrl_d1),            .dout(bank_cr2mem_ctrl[b]));
         pipeline #(.WIDTH(DATA_WIDTH), .STAGE(3))  cr2mem_address_pipe    (.clk(clk), .din(cr2mem_address_d1),         .dout(bank_cr2mem_address[b]));
         pipeline #(.WIDTH(DATA_WIDTH), .STAGE(3))  cr2mem_writedata_pipe  (.clk(clk), .din(cr2mem_writedata_d1),       .dout(bank_cr2mem_writedata[b]));
         pipeline #(.WIDTH(DATA_WIDTH), .STAGE(3))  mem_readdata_pipe      (.clk(clk), .din(bank_mem_readdata[b]),      .dout(csr_mem_readdata_vec[b]));
         pipeline #(.WIDTH(1),          .STAGE(3))  mem_readdatavalid_pipe (.clk(clk), .din(bank_mem_readdatavalid[b]), .dout(csr_mem_readdatavalid_vec[b]));
         pipeline #(.WIDTH(1),          .STAGE(3))  mem_soft_reset_pipe    (.clk(clk), .din(SoftReset),                 .dout(bank_SoftReset[b]));
      end
   endgenerate

   //
   // Receive commands
   //
  
   generate
      for (b = 0; b < NUM_LOCAL_MEM_BANKS; b = b + 1) begin : bank_mem_cmd
         
         t_data lcl_cr2mem_ctrl;
         t_data lcl_cr2mem_address;
         t_data lcl_cr2mem_writedata;
			
	 always_comb begin
	    lcl_cr2mem_ctrl      = bank_cr2mem_ctrl[b];
	    lcl_cr2mem_address   = bank_cr2mem_address[b];
            lcl_cr2mem_writedata = bank_cr2mem_writedata[b];
	 end

         always_ff @(posedge clk) begin 
            // Bit 1 indicates writes
            if (lcl_cr2mem_ctrl[1]) begin
               mem_wr_en[b]       <= 1'b1;
               mem_wr_bank_idx[b] <= t_mem_bank_idx'(lcl_cr2mem_ctrl[3:2]);
            end else if (! mem_waitrequests[b]) begin
               // If there was a request in the previous cycle it was sent.
               mem_wr_en[b] <= 1'b0;
            end

            // Bit 0 indicates reads
            if (lcl_cr2mem_ctrl[0]) begin
               mem_rd_en[b]          <= 1'b1;
               mem_rd_bank_idx[b]    <= t_mem_bank_idx'(lcl_cr2mem_ctrl[3:2]);
               mem_rd_word_select[b] <= lcl_cr2mem_ctrl[16+:MEM_DATA_SELECT_WIDTH];
            end else if (! mem_waitrequests[b]) begin
               // If there was a request in the previous cycle it was sent.
               mem_rd_en[b] <= 1'b0;
            end

            if (bank_SoftReset[b]) begin
               mem_wr_en[b] <= 1'b0;
               mem_rd_en[b] <= 1'b0;
            end
         end
	 
         always_comb begin
	      // These are held constant in the CSRs
	         mem_addr[b]          = t_addr'(lcl_cr2mem_address);
	         mem_wr_data[b]       = lcl_cr2mem_writedata;
	         mem_burstcount[b]    = lcl_cr2mem_ctrl[26:20];
	         mem_wr_byteenable[b] = {MEM_DATA_WORDS{lcl_cr2mem_ctrl[11:4]}};
         end

         always_ff @(posedge clk) begin
            if (!bank_SoftReset[b]) begin
               assert(mem_burstcount[b] <= t_burstcount'(1)) else
	               $fatal(2, "Burst count not supported yet!");
            end
         end
      end
   endgenerate
  
 //BIST_AFU   

`ifdef BIST_AFU  

  always_comb begin
     mem2cr_readdata      = mem_readdata;
	  
     if(|csr_bist_ddr4_enable) begin
        mem2cr_status = { 29'h0,pipe_ddr4_fsm_state, 
                          pipe_ddr4_bist_traffic_gen_pass[3], pipe_ddr4_bist_traffic_gen_fail[3], pipe_ddr4_bist_traffic_gen_timeout[3], 
                          pipe_ddr4_bist_traffic_gen_pass[2], pipe_ddr4_bist_traffic_gen_fail[2], pipe_ddr4_bist_traffic_gen_timeout[2], 
                          pipe_ddr4_bist_traffic_gen_pass[1], pipe_ddr4_bist_traffic_gen_fail[1], pipe_ddr4_bist_traffic_gen_timeout[1], 
                          pipe_ddr4_bist_traffic_gen_pass[0], pipe_ddr4_bist_traffic_gen_fail[0], pipe_ddr4_bist_traffic_gen_timeout[0], 
                          7'b0
								}; 
    end else begin
        mem2cr_status    = t_data'(0);
        mem2cr_status[0] = mem_readdatavalid;
        // Tell the host the number of memory banks
        mem2cr_status[63:56] = NUM_LOCAL_MEM_BANKS;
    end
  end

   generate 
      for (b=0;b<NUM_LOCAL_MEM_BANKS;b=b+1) begin : ddr4_bist_inst
         ed_synth_tg_0 ddr4_bist_tg_0_inst (
				.emif_usr_clk	                  (local_mem[b].clk),
				.emif_usr_reset_n	               (~bank_SoftReset[b] && bank_csr_bist_ddr4_enable[b]),
				.amm_ready_0	                  (~local_mem[b].waitrequest),
				.amm_read_0	                     (ddr4_bist_amm_read[b]),
				.amm_write_0	                  (ddr4_bist_amm_write[b]),
				.amm_address_0	                  (ddr4_bist_amm_address[b]),
				.amm_readdata_0	               (local_mem[b].readdata),
				.amm_writedata_0	               (ddr4_bist_amm_writedata[b]),
				.amm_burstcount_0	               (ddr4_bist_amm_burstcount[b]),
				.amm_byteenable_0	               (ddr4_bist_amm_byteenable[b]),
				.amm_readdatavalid_0	            (local_mem[0].readdatavalid),
				.fsm_state                       (ddr4_fsm_state[b]),
				.traffic_gen_pass_0	            (ddr4_bist_traffic_gen_pass[b]),
				.traffic_gen_fail_0	            (ddr4_bist_traffic_gen_fail[b]),
				.traffic_gen_timeout_0	         (ddr4_bist_traffic_gen_timeout[b])
         );

         //MUX to select BIST Traffic Generator
         always @(*) begin
            mem_waitrequests[b]          = local_mem[b].waitrequest;
            bank_mem_readdatavalid[b]    = local_mem[b].readdatavalid;
            bank_mem_readdata[b]         = selectWord(local_mem[b].readdata, mem_rd_word_select[b]);

            if (bank_csr_bist_ddr4_enable[b]) begin
               local_mem[b].read            = ddr4_bist_amm_read[b];
               local_mem[b].write           = ddr4_bist_amm_write[b];
               local_mem[b].address         = ddr4_bist_amm_address[b];
               local_mem[b].writedata       = ddr4_bist_amm_writedata[b];
               local_mem[b].burstcount      = ddr4_bist_amm_burstcount[b];
               local_mem[b].byteenable      = ddr4_bist_amm_byteenable[b];
            end else begin
               local_mem[b].read            = mem_rd_en[b] && (mem_rd_bank_idx[b] == t_mem_bank_idx'(b));              
               local_mem[b].write           = mem_wr_en[b] && (mem_wr_bank_idx[b] == t_mem_bank_idx'(b));
               local_mem[b].address         = mem_addr[b];
               local_mem[b].writedata       = {MEM_DATA_WORDS{mem_wr_data[b]}};
               local_mem[b].burstcount      = mem_burstcount[b];
               local_mem[b].byteenable      = mem_wr_byteenable[b];			      
            end
         end
      end
   endgenerate
`else 
   always_comb begin
      mem2cr_status    = t_data'(0);
      mem2cr_status[0] = mem_readdatavalid; 
      // Tell the host the number of memory banks
      mem2cr_status[63:56] = NUM_LOCAL_MEM_BANKS;
      mem2cr_readdata      = mem_readdata;
   end
`endif
   
   always_ff @(posedge clk) begin
      // Indicate a read response arrived. The flag is sticky and will remain
      // set until the next read request.
      if (csr_mem_readdatavalid_vec[csr_mem_rd_bank_idx]) begin
          mem_readdatavalid <= 1'b1;
          mem_readdata      <= csr_mem_readdata_vec[csr_mem_rd_bank_idx];
      end

      if (SoftReset || csr_mem_rd_en) begin
          mem_readdatavalid <= 1'b0;
      end
   end
   
// Map requests to banks
   
`ifndef BIST_AFU
   generate
      for (b = 0; b < NUM_LOCAL_MEM_BANKS; b = b + 1) begin : bank
         always_comb begin : m
            local_mem[b].write      = mem_wr_en[b] && (mem_wr_bank_idx[b] == t_mem_bank_idx'(b));
            local_mem[b].read       = mem_rd_en[b] && (mem_rd_bank_idx[b] == t_mem_bank_idx'(b));

            local_mem[b].address    = mem_addr[b];
            local_mem[b].writedata  = {MEM_DATA_WORDS{mem_wr_data[b]}};
            local_mem[b].byteenable = mem_wr_byteenable[b];
            local_mem[b].burstcount = mem_burstcount[b];
 
            mem_waitrequests[b]     = local_mem[b].waitrequest;
         end

         always_comb begin
            bank_mem_readdatavalid[b] = local_mem[b].readdatavalid;
            bank_mem_readdata[b]      = selectWord(local_mem[b].readdata, mem_rd_word_select[b]);
         end
      end
   endgenerate

`endif 
endmodule

