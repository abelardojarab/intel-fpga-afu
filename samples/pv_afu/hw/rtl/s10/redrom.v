// baeckler -- 06-02-2017

module redrom (
	input clk,
	input sclr_err,
	output sticky_err
);

/////////////////////////////////////
// ROM block

localparam SCRATCH_MEM_INIT = "redrom.hex";
localparam SCRATCH_MEM_ADDR_WIDTH = 9;

wire [3:0] byte_ena = 4'b1111;
reg [8:0] addr = 9'b0;
wire [31:0] rdata;

altsyncram    scr_ram (
    .byteena_a (byte_ena),
    .clock0 (clk),
    .wren_a (1'b0),
    .address_b (1'b1),
    .data_b (1'b1),
    .wren_b (1'b0),
    .address_a (addr),
    .data_a (32'h0),
    .q_a (rdata),
    .q_b (),
    .aclr0 (1'b0),
    .aclr1 (1'b0),
    .addressstall_a (1'b0),
    .addressstall_b (1'b0),
    .byteena_b (1'b1),
    .clock1 (1'b1),
    .clocken0 (1'b1),
    .clocken1 (1'b1),
    .clocken2 (1'b1),
    .clocken3 (1'b1),
    .eccstatus (),
    .rden_a (1'b1),
    .rden_b (1'b1)
);
defparam
    scr_ram.byte_size = 8,
    scr_ram.clock_enable_input_a = "BYPASS",
    scr_ram.clock_enable_output_a = "BYPASS",
    scr_ram.intended_device_family = "Stratix 10",
    scr_ram.lpm_type = "altsyncram",
    scr_ram.numwords_a = (1 << SCRATCH_MEM_ADDR_WIDTH),
    scr_ram.operation_mode = "SINGLE_PORT",
    scr_ram.outdata_aclr_a = "NONE",
    scr_ram.outdata_reg_a = "CLOCK0",
    scr_ram.power_up_uninitialized = "FALSE",
    scr_ram.init_file = SCRATCH_MEM_INIT,
    scr_ram.ram_block_type = "M20K",
    scr_ram.read_during_write_mode_port_a  = "DONT_CARE",
    scr_ram.widthad_a = SCRATCH_MEM_ADDR_WIDTH,
    scr_ram.width_a = 32,
    scr_ram.width_byteena_a = 4;

always @(posedge clk) begin
	addr <= addr + 1'b1;
end

reg addr_wrap = 1'b0;
reg last_msb = 1'b0;
always @(posedge clk) begin
	last_msb <= addr[8];
	addr_wrap <= last_msb && ~addr[8];
end

reg [31:0] cume = 32'h0;
always @(posedge clk) begin
	if (addr_wrap) cume <= 32'h0;
	else cume <= {cume[30:0],cume[31]} ^ rdata;
end

reg [31:0] capture_cume = 32'h0;
always @(posedge clk) begin
	if (addr_wrap) capture_cume <= cume ^ 32'hedf35c70 ^ {32{1'b1}};	
end

wire good;
intc_and32_t5 a0 (
    .clk(clk),
    .din(capture_cume),
    .dout(good)
);

reg err_r = 1'b0;
always @(posedge clk) begin
	if (sclr_err) err_r <= 1'b0;
	else if (!good) err_r <= 1'b1;
end
assign sticky_err = err_r;

endmodule
