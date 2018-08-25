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
// baeckler - 5-3-2010

module alt_aeuex_i2c_control
(
	input clk,
	
	input sda_in,
	input scl_in,
	output reg sda_out, sda_oe,
	output reg scl_out, scl_oe,
	
	input cmd_rd, cmd_wr,
	input [7:0] slave_addr,
	input [7:0] mem_addr,
	input [7:0] wr_data,
	
	output reg [7:0] rd_data,
	output reg rd_data_valid,
	output reg ack_failure,
	output reg [3:0] ack_history,
	output reg busy
);

`include "alt_aeuex_log2.iv"

initial busy = 1'b0;
initial rd_data_valid = 1'b0;
initial ack_failure = 1'b0;
initial rd_data = 8'h0;
initial ack_history = 4'h0;

// output clock freq, and system clock freq in Hz
parameter SCL_FREQ = 400000;   // note : using >400K may have legal implications
parameter CLK_FREQ = 50000000;

parameter BIT_CYCLE = CLK_FREQ / SCL_FREQ;
parameter CNTR_BITS = alt_aeuex_log2(BIT_CYCLE-1);

//////////////////////
// bit timer
//////////////////////

localparam [CNTR_BITS-1:0] STEP1 = (BIT_CYCLE[CNTR_BITS-1:0]  >> 2) - 1'b1;
localparam [CNTR_BITS-1:0] STEP2 = (BIT_CYCLE[CNTR_BITS-1:0]  >> 1) - 1'b1;
localparam [CNTR_BITS+1:0] STEP3W = ((BIT_CYCLE[CNTR_BITS+1:0] * 2'd3) >> 2) - 1'b1;
localparam [CNTR_BITS-1:0] STEP3 = STEP3W[CNTR_BITS-1:0];
localparam [CNTR_BITS-1:0] STEP4 = BIT_CYCLE[CNTR_BITS-1:0] - 1'b1;

// synthesis translate_off
initial begin
	$display ("I2C switch times : %d %d %d %d",STEP1,STEP2,STEP3,STEP4);
end
// synthesis translate_on

reg [CNTR_BITS-1:0] bit_cntr = 0;
reg bt0 = 1'b0, bt1 = 1'b0, bt2 = 1'b0, bt3 = 1'b0;

always @(posedge clk) begin
	if (bit_cntr ==	STEP4) bit_cntr <= 0;
	else bit_cntr <= bit_cntr + 1'b1; 
	
	bt1 <= (bit_cntr == STEP1);
	bt2 <= (bit_cntr == STEP2);
	bt3 <= (bit_cntr == STEP3);	
	bt0 <= (bit_cntr == STEP4);	
end



// bt schedule vs clk
//        |---3---|
//        2       4/0   
// ---1---|       |

//////////////////////
// bitstream shifter
//////////////////////

localparam [2:0] CTL_IDLE = 3'b000;

localparam [2:0] CTL_START = 3'b001;
localparam [2:0] CTL_STOP = 3'b010;
localparam [2:0] CTL_GRAB = 3'b011;
localparam [2:0] CTL_CHECK = 3'b100; // look for acknowledge = 0

localparam [2:0] CTL_SEND0 = 3'b110;
localparam [2:0] CTL_SEND1 = 3'b111;


localparam MAX_BITS = 44;

reg [3*MAX_BITS-1:0] bitstream  = 0;
wire [3*MAX_BITS-1:0] shifted_bitstream  = {bitstream[3*(MAX_BITS-1)-1:0],3'b0};
wire [2:0] bit_to_send = bitstream[3*MAX_BITS-1:3*(MAX_BITS-1)];

reg last_ack_bit = 1'b0;
reg [7:0] capture = 8'hff;

always @(posedge clk) begin
	scl_oe <= 1'b1;
	last_ack_bit <= 1'b0;
	
	case (bit_to_send) 
		CTL_IDLE : begin
			sda_out <= 1'b1; 
			sda_oe <= 1'b0;
			scl_out <= 1'b1;
			scl_oe <= 1'b0;							
		end
		CTL_START : begin
			// fall during clock = 1 to start
			if (bt1) begin
				sda_oe <= 1'b1;
				scl_oe <= 1'b1;
				sda_out <= 1'b1;
			//	scl_out <= 1'b0;
			end
			if (bt2) scl_out <= 1'b1;
			if (bt3) sda_out <= 1'b0;
			if (bt0) scl_out <= 1'b0;
		end
		CTL_STOP : begin
			// rise during clock = 1 to stop
			if (bt1) begin
				sda_oe <= 1'b1;
				sda_out <= 1'b0;
			end
			if (bt2) scl_out <= 1'b1;
			if (bt3) sda_out <= 1'b1;						
				
			 // after stop is idle, don't glitch the clock down
			 // if (bt0) scl_out <= 1'b0;
		end
		CTL_GRAB : begin
			sda_oe <= 1'b0;
			if (bt2) scl_out <= 1'b1;
			if (bt3) capture <= {capture[6:0],sda_in};	
			if (bt0) scl_out <= 1'b0;				
		end
		CTL_CHECK : begin
			// look for a 0 bit as an acknowledge
			sda_oe <= 1'b0;
			if (bt2) scl_out <= 1'b1;
			if (bt3) begin
				last_ack_bit <= sda_in;	
				ack_history <= {ack_history[2:0],sda_in};
			end
			if (bt0) scl_out <= 1'b0;				
		end
		CTL_SEND0 : begin
			if (bt1) sda_oe <= 1'b1;
			if (bt1) sda_out <= 1'b0;
			if (bt2) scl_out <= 1'b1;
			if (bt0) scl_out <= 1'b0;	
		end
		CTL_SEND1 : begin
			if (bt1) sda_oe <= 1'b1;
			if (bt1) sda_out <= 1'b1;
			if (bt2) scl_out <= 1'b1;
			if (bt0) scl_out <= 1'b0;	
		end		
		default : begin
			// call it idle
			sda_out <= 1'b1; sda_oe <= 1'b1;
			scl_out <= 1'b1; 
		end
	endcase
end

//////////////////////////////
// read and write schedules
//////////////////////////////

wire [3*7-1:0] ctl_slave_addr = {
	slave_addr[7] ? CTL_SEND1 : CTL_SEND0,
	slave_addr[6] ? CTL_SEND1 : CTL_SEND0,
	slave_addr[5] ? CTL_SEND1 : CTL_SEND0,
	slave_addr[4] ? CTL_SEND1 : CTL_SEND0,
	slave_addr[3] ? CTL_SEND1 : CTL_SEND0,
	slave_addr[2] ? CTL_SEND1 : CTL_SEND0,
	slave_addr[1] ? CTL_SEND1 : CTL_SEND0
	// bit 0 is 1 for read, 0 for write
};

wire [3*8-1:0] ctl_mem_addr = {
	mem_addr[7] ? CTL_SEND1 : CTL_SEND0,
	mem_addr[6] ? CTL_SEND1 : CTL_SEND0,
	mem_addr[5] ? CTL_SEND1 : CTL_SEND0,
	mem_addr[4] ? CTL_SEND1 : CTL_SEND0,
	mem_addr[3] ? CTL_SEND1 : CTL_SEND0,
	mem_addr[2] ? CTL_SEND1 : CTL_SEND0,
	mem_addr[1] ? CTL_SEND1 : CTL_SEND0,
	mem_addr[0] ? CTL_SEND1 : CTL_SEND0
};
	
reg read_pending = 1'b0;

/////////////////////////
// dev_clr sync-reset
/////////////////////////
wire user_mode_sync;
alt_aeuex_user_mode_det dev_clr(
    .ref_clk(clk),
    .user_mode_sync(user_mode_sync)
);

//always @(posedge clk) begin
always @(posedge clk or negedge user_mode_sync) begin
   if (!user_mode_sync) begin
        busy <= 1'b0;
        ack_failure <= 1'b0;
   end
   else begin
	rd_data_valid <= 1'b0;
	
	if (cmd_wr) begin
		read_pending <= 1'b0;
		ack_failure <= 1'b0;
		busy <= 1'b1;
		bitstream <= {
			CTL_IDLE,
			CTL_IDLE,
			CTL_START,
			ctl_slave_addr,
			CTL_SEND0, //write
			CTL_CHECK,
			ctl_mem_addr,
			CTL_CHECK,
			wr_data[7] ? CTL_SEND1 : CTL_SEND0,
			wr_data[6] ? CTL_SEND1 : CTL_SEND0,
			wr_data[5] ? CTL_SEND1 : CTL_SEND0,
			wr_data[4] ? CTL_SEND1 : CTL_SEND0,
			wr_data[3] ? CTL_SEND1 : CTL_SEND0,
			wr_data[2] ? CTL_SEND1 : CTL_SEND0,
			wr_data[1] ? CTL_SEND1 : CTL_SEND0,
			wr_data[0] ? CTL_SEND1 : CTL_SEND0,
			CTL_CHECK,
			CTL_STOP,
			CTL_IDLE			
		};		
	end
	else if (cmd_rd) begin
		read_pending <= 1'b1;
		ack_failure <= 1'b0;
		busy <= 1'b1;
		bitstream <= {
			CTL_IDLE,
			CTL_IDLE,
			CTL_START,
			ctl_slave_addr,
			CTL_SEND0, //write
			CTL_CHECK,
			ctl_mem_addr,
			CTL_CHECK,
			CTL_START,
			ctl_slave_addr,
			CTL_SEND1, //read
			CTL_CHECK,
			{8{CTL_GRAB}},
			CTL_SEND1, // NAK
			CTL_STOP,
			CTL_IDLE			
		};
	end
	else begin
		if (bt0) bitstream <= shifted_bitstream;
		if (last_ack_bit == 1'b1) ack_failure <= 1'b1;
	end
	
	// grab the read data at the proper time when ending a read
	if (bit_to_send == CTL_STOP) begin
		busy <= 1'b0;
		if (read_pending) begin
			rd_data <= capture;
			read_pending <= 1'b0;
			rd_data_valid <= 1'b1;
		end
	end
   end
end

endmodule
