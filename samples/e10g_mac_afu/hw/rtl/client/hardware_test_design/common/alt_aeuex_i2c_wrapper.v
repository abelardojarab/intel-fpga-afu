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

module alt_aeuex_i2c_wrapper (
	input clk,
	
	input sda_in,
	input scl_in,
	output reg sda_out, sda_oe,
	output reg scl_out, scl_oe,
	
	input cmd_rd, cmd_wr,
	input [7:0] slave_addr,
	input [7:0] mem_addr,
	input [7:0] wr_data,
	
	output wire [7:0] rd_data,
	output wire rd_data_valid,
	output wire ack_failure,
	output wire [3:0] ack_history,
	output wire busy
);

// output clock freq, and system clock freq in Hz
parameter SCL_FREQ = 400000;   // note : using >400K may have legal implications
parameter CLK_FREQ = 50000000;

reg sda_in_i, scl_in_i;
wire sda_out_i, scl_out_i;
wire sda_oe_i, scl_oe_i;
wire [6:0] i2c_addr;

assign i2c_addr = slave_addr[7:1];

always @(*) begin
    if (i2c_addr == 7'h50) begin
        sda_in_i = scl_in;
        sda_out = scl_out_i;
        sda_oe = scl_oe_i;
        scl_in_i = sda_in;
        scl_out = sda_out_i;
        scl_oe = sda_oe_i;
    end
    else begin
        sda_in_i = sda_in;
        sda_out = sda_out_i;
        sda_oe = sda_oe_i;
        scl_in_i = scl_in;
        scl_out = scl_out_i;
        scl_oe = scl_oe_i;
    end
end

alt_aeuex_i2c_control i2c
(
	.clk(clk),
	
	.sda_in(sda_in_i),
	.scl_in(scl_in_i),
	.sda_out(sda_out_i),
	.sda_oe(sda_oe_i),
	.scl_out(scl_out_i),
	.scl_oe(scl_oe_i),
	
	.cmd_rd(cmd_rd),
	.cmd_wr(cmd_wr),
	.slave_addr(slave_addr),
	.mem_addr(mem_addr),
	.wr_data(wr_data),
	
	.rd_data(rd_data),
	.rd_data_valid(rd_data_valid),
	.ack_failure(ack_failure),
	.ack_history(ack_history),
	.busy(busy)
);
defparam i2c .SCL_FREQ = SCL_FREQ;
defparam i2c .CLK_FREQ = CLK_FREQ;

endmodule
