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

    always_comb
    begin
        mem2cr_status = t_data'(0);
        mem2cr_status[0] = mem_readdatavalid;
        // Tell the host the number of memory banks
        mem2cr_status[63:56] = NUM_LOCAL_MEM_BANKS;

        mem2cr_readdata = mem_readdata;
    end

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
    genvar b;
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
    endgenerate

endmodule

