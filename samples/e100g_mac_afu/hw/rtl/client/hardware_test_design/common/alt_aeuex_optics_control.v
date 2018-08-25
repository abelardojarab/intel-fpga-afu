// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



`timescale 1 ps / 1 ps
// baeckler - 02-02-2010

module alt_aeuex_optics_control #(
	parameter STATUS_ADDR_PREFIX = 6'b0010_00, //0x2000-0x23ff
	parameter SCL_FREQ = 50000,   // for I2C - note : using >400K may have legal implications
	parameter CLK_FREQ = 50000000, 
	parameter MDIO_FREQ = 50000,
	parameter MDIO_CLOCK_DIVIDE = CLK_FREQ / MDIO_FREQ
)(

	// status register bus
	input clk_status,
	input [15:0] status_addr,
	input status_read,
	input status_write,
	input [31:0] status_writedata,
	output reg [31:0] status_readdata,
	output reg status_readdata_valid,

	// CFP MDIO controls
	output cfp_mdc,
	input  cfp_mdio_in,
	output cfp_mdio_out,
	output cfp_mdio_oe, // active high
	input  cfp_glb_alrm,
	output [4:0] cfp_prtadr,	
	
	// CFP dedicated controls
	output cfp_mod_lopwr,
	output cfp_mod_rst, // active low
	output cfp_tx_dis,	
	input cfp_mod_abs,
	input cfp_rx_los,		
	input [3:1] cfp_prg_alrm,  // strange numbering from the MSA, sorry
	output [3:1] cfp_prg_cntl,	
	
	// I2C controls
	input xfp_sda_in,
	output xfp_sda_out,
	output xfp_sda_oe,	// active high
	input xfp_scl_in,
	output xfp_scl_out,
	output xfp_scl_oe	// active high
		
);

////////////////////////////////////////////
// the CFP active levels are all willy nilly
//  clean them up and set some defaults
////////////////////////////////////////////

reg [4:0] cfp_ctrls = 5'b11100;

assign cfp_prg_cntl[1] = cfp_ctrls[4]; // IC's enabled
assign cfp_prg_cntl[2] = cfp_ctrls[3]; // regular power
assign cfp_prg_cntl[3] = cfp_ctrls[2]; // regular power
assign cfp_tx_dis = cfp_ctrls[1];  //    TX enabled
assign cfp_mod_lopwr = cfp_ctrls[0];  // TX power enabled
	
reg [6:0] cfp_status;
reg [6:0] sync_cfp_status /* synthesis preserve_syn_only */;

always @(posedge clk_status) begin
	cfp_status[0] <= !cfp_mod_rst;  // reset
	cfp_status[1] <= !cfp_mod_abs;  // module plugged in
	cfp_status[2] <= !cfp_rx_los;   // rx signal detect
	cfp_status[3] <= cfp_prg_alrm[1];  // rx cdr lock
	cfp_status[4] <= cfp_prg_alrm[2];  // high power on
	cfp_status[5] <= cfp_prg_alrm[3];  // module ready
	cfp_status[6] <= !cfp_glb_alrm;    // global alarm
	sync_cfp_status <= cfp_status;
end

////////////////////////////////////////////
// MDIO host
////////////////////////////////////////////

wire [4:0] m_addr1,m_addr2;
wire [15:0] m_rdata;
reg [15:0] m_wdata = 0;
wire m_rdata_valid, m_busy;
reg m_read = 1'b0, m_write = 1'b0, m_write_address = 1'b0, m_read_post_inc = 1'b0;

alt_aeuex_mdio_control mdc (
	.sys_clk(clk_status),
	.addr1(m_addr1),
	.addr2(m_addr2),
	
	// commands
	.read(m_read),
	.read_post_inc(m_read_post_inc),  // read and increment addr
	.write(m_write),
	.write_address(m_write_address), // write wdata as an address
		
	.rdata(m_rdata),
	.rdata_valid(m_rdata_valid),
	.busy(m_busy),			// when busy R/W will be ignored
	.wdata(m_wdata),
		
	// to MDIO peripheral
	.mdio_clk(cfp_mdc),
	.mdio_out(cfp_mdio_out),
	.mdio_oe(cfp_mdio_oe),
	.mdio_in(cfp_mdio_in)		
);
defparam mdc .CLOCK_DIVIDE = MDIO_CLOCK_DIVIDE;

////////////////////////////////////////////
// I2C host
////////////////////////////////////////////

reg sda_in_r = 1'b0 /* synthesis preserve_syn_only */;
reg sda_in_rr = 1'b0 /* synthesis preserve_syn_only */;
reg scl_in_r = 1'b0 /* synthesis preserve_syn_only */;
reg scl_in_rr = 1'b0 /* synthesis preserve_syn_only */;

always @(posedge clk_status) begin
	sda_in_r <= xfp_sda_in;
	sda_in_rr <= sda_in_r;	
	scl_in_r <= xfp_scl_in;
	scl_in_rr <= scl_in_r;	
end

wire [7:0] i_rdata;
reg [7:0] i_wdata = 8'h0;
reg i_read = 1'b0, i_write = 1'b0;
wire [7:0] i_slave_addr, i_mem_addr;
wire i_ack_failure, i_busy;
wire [3:0] i_ack_history;

alt_aeuex_i2c_control i2c
(
	.clk(clk_status),
	
	.sda_in(sda_in_rr),
	.scl_in(scl_in_rr),
	.sda_out(xfp_sda_out),
	.sda_oe(xfp_sda_oe),
	.scl_out(xfp_scl_out),
	.scl_oe(xfp_scl_oe),
	
	.cmd_rd(i_read),
	.cmd_wr(i_write),
	.slave_addr(i_slave_addr),
	.mem_addr(i_mem_addr),
	.wr_data(i_wdata),
	
	.rd_data(i_rdata),
	.rd_data_valid(),
	.ack_failure(i_ack_failure),
	.ack_history(i_ack_history),
	.busy(i_busy)
);
defparam i2c .SCL_FREQ = SCL_FREQ;
defparam i2c .CLK_FREQ = CLK_FREQ;

////////////////////////////////////////////
// Control port
////////////////////////////////////////////

reg status_addr_sel_r = 0;
reg [5:0] status_addr_r = 0;

reg status_read_r = 0, status_write_r = 0;
reg [31:0] status_writedata_r = 0;
reg [31:0] scratch = 0;

// generally prtadr matches addr1 and addr2 is 00001
reg [14:0] mdio_addrs = 15'h1;
assign {cfp_prtadr,m_addr1,m_addr2} = mdio_addrs;

reg [15:0] i2c_addrs = 16'ha000;
assign {i_slave_addr,i_mem_addr} = i2c_addrs;

reg cfp_enabled = 1'b0;
assign cfp_mod_rst = cfp_enabled;

initial status_readdata = 0;
initial status_readdata_valid = 0;
	
always @(posedge clk_status) begin
	status_addr_r <= status_addr[5:0];
	status_addr_sel_r <= (status_addr[15:6] == {STATUS_ADDR_PREFIX[5:0], 4'h0});
	
	status_read_r <= status_read;
	status_write_r <= status_write;
	status_writedata_r <= status_writedata;	
	status_readdata_valid <= 1'b0;

	// commands are self clearing
	m_read <= 1'b0;
	m_write <= 1'b0;
	m_read_post_inc <= 1'b0;
	m_write_address <= 1'b0;
	i_read <= 1'b0;
	i_write <= 1'b0;
	
	if (status_read_r) begin
		if (status_addr_sel_r) begin
			status_readdata_valid <= 1'b1;
			case (status_addr_r)
				6'h0  : status_readdata <= "OPTs";
				6'h1  : status_readdata <= scratch;
				6'h2  : status_readdata <= {31'b0,cfp_enabled};
				6'h3  : status_readdata <= {25'b0,sync_cfp_status};
				6'h4  : status_readdata <= {27'b0,cfp_ctrls};
				
				6'h10 : status_readdata <= {16'b0,m_wdata};
				6'h11 : status_readdata <= {m_busy,15'b0,m_rdata};
				6'h12 : status_readdata <= {17'b0,mdio_addrs};
				6'h13 : status_readdata <= {28'b0,m_write_address,m_write,m_read_post_inc,m_read};
				
				6'h20 : status_readdata <= {24'b0,i_wdata};
				6'h21 : status_readdata <= {i_busy,i_ack_failure,2'b0,i_ack_history,16'b0,i_rdata};
				6'h22 : status_readdata <= {16'b0,i2c_addrs};
				6'h23 : status_readdata <= {30'b0,i_write,i_read};
				
				default : status_readdata <= 32'h123;
			endcase		
		end
		else begin
			// this read is not for my address prefix - ignore it.
		end
	end	
	
	if (status_write_r) begin
		if (status_addr_sel_r) begin
			case (status_addr_r)
				6'h1  : scratch <= status_writedata_r;						
				6'h2  : cfp_enabled <= status_writedata_r[0];
				6'h4  : cfp_ctrls <= status_writedata_r[4:0];
				
				6'h10 : if (!m_busy) m_wdata <= status_writedata_r[15:0];									
				6'h12 : if (!m_busy) mdio_addrs <= status_writedata_r[14:0];									
				6'h13 : if (!m_busy) {m_write_address,m_write,m_read_post_inc,m_read} <= status_writedata_r[3:0];
		
				6'h20 : if (!i_busy) i_wdata <= status_writedata_r[7:0];									
				6'h22 : if (!i_busy) i2c_addrs <= status_writedata_r[15:0];									
				6'h23 : if (!i_busy) {i_write,i_read} <= status_writedata_r[1:0];
							
			endcase
		end
	end				
end

endmodule
