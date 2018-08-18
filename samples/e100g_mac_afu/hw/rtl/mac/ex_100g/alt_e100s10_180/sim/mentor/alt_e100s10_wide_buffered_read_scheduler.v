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


// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/ast/alt_e100s10_wide_buffered_read_scheduler.v#1 $
// $Revision: #1 $
// $Date: 2013/02/27 $
// $Author: pscheidt $
//-----------------------------------------------------------------------------
// baeckler - 06-01-2011
//
// The read_scheduler accumulate wr_num_valid and write to buffer 16 word at a time. 
// Each EOP will be written to buffer which has 1 to (15+8) word. On the buffer
// read side, it tick out 8 word at a time. For regular 16 word, it takes 2 ticks. 
// For EOP, it takes 1~3 ticks. For minimum 64 byte back to back, it will take 1 tick
// For each cycles.

`timescale 1 ps / 1 ps

module alt_e100s10_wide_buffered_read_scheduler #(
	parameter TARGET_CHIP = 2,
	parameter VALID_WIDTH = 4,
	parameter RAM_DEPTH = 1024
)(
	input clk,
	input sclr,
	input [VALID_WIDTH-1:0] wr_num_valid,    // max of 100..
	input [VALID_WIDTH-1:0] wr_eop_position, // 1 for MS word, 2,3... 8.   0 for no EOP
	output wr_overflow,
	output rd_overflow,
	output reg [VALID_WIDTH-1:0] rd_num_valid // read max of 100.. when possible, hit SOP boundaries
);

// State Machine States:
localparam IDLE = 2'b00,
          TICK1 = 2'b01,
          TICK2 = 2'b10,
          TICK3 = 2'b11;
/////////////////////////////////////////////////////////
// write side FIFO buffer
/////////////////////////////////////////////////////////

// helper function to compute LOG base 2
//
// NOTE - This is a somewhat abusive definition of LOG2(v) as the
//   number of bits required to represent "v".  So alt_log2(256) will be
//   9 rather than 8 (256 = 9'b1_0000_0000).  I apologize for any
//   confusion this may cause.
//

function integer alt_log2;
  input integer val;
  begin
	 alt_log2 = 0;
	 while (val > 0) begin
	    val = val >> 1;
		alt_log2 = alt_log2 + 1;
	 end
  end
endfunction

// input registers
reg [VALID_WIDTH-1:0] wr_num_valid_r;
reg [VALID_WIDTH-1:0] wr_eop_position_r;
reg [VALID_WIDTH-1:0] wr_eop_position_r2;
reg [VALID_WIDTH:0]   eop_cnt;
reg [VALID_WIDTH:0]   accum_cnt;

always @(*) begin
		wr_num_valid_r     = wr_num_valid;
		wr_eop_position_r  = wr_eop_position;	
end
   
always @(posedge clk) begin
	if (sclr) begin
		//wr_num_valid_r     <= 0;
		//wr_eop_position_r  <= 0;
		wr_eop_position_r2 <= 0;
      eop_cnt            <= 0;
      accum_cnt          <= 0;
	end
	else begin
		//wr_num_valid_r     <= wr_num_valid;
		//wr_eop_position_r  <= wr_eop_position;	
		wr_eop_position_r2 <= wr_eop_position_r;	
      eop_cnt            <= (|wr_eop_position_r) ? accum_cnt[VALID_WIDTH-1:0] + wr_eop_position_r : { (VALID_WIDTH+1) {1'b0} };
      accum_cnt          <= (|wr_eop_position_r) ? wr_num_valid_r - wr_eop_position_r : accum_cnt[VALID_WIDTH-1:0] + wr_num_valid_r;
	end
end


wire [VALID_WIDTH:0]  chunk_wrdcnt = (|wr_eop_position_r2) ? eop_cnt : 5'd16; 

wire wrfifo_empty, wrfifo_full;
wire [2*VALID_WIDTH-1:0] wrfifo_q;
reg wrfifo_q_valid;
assign wr_overflow = wrfifo_full;
assign rd_overflow = 1'b0;
reg    wrfifo_rdreq;

wire [alt_log2(RAM_DEPTH)-2:0] wrfifo_used;

wire wrfifo_wrreq = accum_cnt[VALID_WIDTH] | (|wr_eop_position_r2);

scfifo_mlab wffo (
                .clk(clk),
                .sclr(sclr),

		.wdata ({(|wr_eop_position_r2), 2'b00, chunk_wrdcnt}),
		.wreq (wrfifo_wrreq),
                .full(wrfifo_full),

		.rdata (wrfifo_q),
		.rreq (wrfifo_rdreq),
		.empty (wrfifo_empty),

		.used (wrfifo_used)
        );
        defparam wffo .TARGET_CHIP = TARGET_CHIP;
        defparam wffo .WIDTH = 2*VALID_WIDTH;
        defparam wffo .PREVENT_OVERFLOW = 1'b0;
        defparam wffo .PREVENT_UNDERFLOW = 1'b0;
        defparam wffo .ADDR_WIDTH = alt_log2(RAM_DEPTH)-1;

wire [VALID_WIDTH:0] buf_chunk_cnt; 
wire buf_eop_flag;
assign buf_chunk_cnt =  wrfifo_q[VALID_WIDTH:0] & {(VALID_WIDTH+1){wrfifo_q_valid}};
assign buf_eop_flag = wrfifo_q[2*VALID_WIDTH-1] & wrfifo_q_valid;

/////////////////////////////////////////////////////////
// Read Fifo state machine 
/////////////////////////////////////////////////////////
reg  [1:0]             next_rd_state;
reg  [1:0]             rd_state;
reg  [VALID_WIDTH-1:0] next_rd_num_valid;
reg  [VALID_WIDTH:0]   next_wd_cnt_left;
reg  [VALID_WIDTH:0]   wd_cnt_left;
reg                    next_last_read;
reg                    last_read;

always @(posedge clk) begin
        if (sclr) begin
                rd_state       <= 0;
                last_read      <= 1'b0;
                rd_num_valid   <= 0;
                wrfifo_q_valid <= 1'b0;
                wd_cnt_left    <= 0;
        end
        else begin
                rd_state       <= next_rd_state;
                last_read      <= next_last_read;
                rd_num_valid   <= next_rd_num_valid;
                wrfifo_q_valid <= wrfifo_rdreq; 
                wd_cnt_left    <= next_wd_cnt_left;
        end
end


always @*
begin
      next_rd_state     = rd_state;
      next_last_read    = 1'b0;
      wrfifo_rdreq      = 1'b0;
      next_rd_num_valid = 0;
      next_wd_cnt_left  = 0;
      case (rd_state)
      IDLE:  begin
               if (!wrfifo_empty) wrfifo_rdreq    = 1'b1; 
               if (!wrfifo_empty) next_rd_state  = TICK1;
      end
      TICK1: begin
               next_wd_cnt_left  = buf_chunk_cnt - {{(VALID_WIDTH-3) {1'b0}},4'd8};
               next_rd_num_valid = 8;
               if (buf_eop_flag) begin    //EOP can have 1~3 ticks
                 if (buf_chunk_cnt[VALID_WIDTH] & (|buf_chunk_cnt[VALID_WIDTH-1:0])) begin   //It needs three ticks
                   next_rd_state     = TICK2;
                 end else if (buf_chunk_cnt[VALID_WIDTH] | (buf_chunk_cnt[VALID_WIDTH-1] & |buf_chunk_cnt[VALID_WIDTH-2:0]) ) begin   //Total two ticks EOP
                   next_rd_state     = TICK2;
                   next_last_read    = 1'b1;
                 end else begin     //one tick EOP
                   next_rd_num_valid = buf_chunk_cnt[VALID_WIDTH-1:0];
                   if (!wrfifo_empty) wrfifo_rdreq   = 1'b1;
                   if (!wrfifo_empty) next_rd_state = TICK1;
                   else               next_rd_state = IDLE;
                 end
               end else begin             //only one more tick needed for 16 word read.
                 next_rd_state     = TICK2; 
                 next_last_read    = 1'b1;
               end
      end
      TICK2: begin
               if (last_read) begin           //Either EOP or regular tick2
                 next_rd_num_valid = wd_cnt_left[VALID_WIDTH-1:0];
                 if (!wrfifo_empty) wrfifo_rdreq   = 1'b1;
                 if (!wrfifo_empty) next_rd_state = TICK1;
                 else               next_rd_state = IDLE;
               end else begin                //One more tick for EOP
                 next_rd_num_valid = 8;
                 next_wd_cnt_left  = wd_cnt_left - {{(VALID_WIDTH-3){1'b0}},4'd8};
                 next_rd_state     = TICK3;
               end
      end
      TICK3: begin                           //Only EOP last tick
               next_rd_num_valid = wd_cnt_left[VALID_WIDTH-1:0];
               if (!wrfifo_empty) wrfifo_rdreq   = 1'b1;
               if (!wrfifo_empty) next_rd_state = TICK1;
               else               next_rd_state = IDLE;
      end
      endcase
end

endmodule
