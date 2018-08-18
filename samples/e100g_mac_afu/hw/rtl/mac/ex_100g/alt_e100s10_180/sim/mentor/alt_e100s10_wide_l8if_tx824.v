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


// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/ast/alt_e100s10_wide_l8if_tx824.v#11 $
// $Revision: #11 $
// $Date: 2013/07/24 $
// $Author: jilee $
//-----------------------------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////
//
// Description: tx 8 lane to 4 lane conversion
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ps / 1ps

module alt_e100s10_wide_l8if_tx824 #(
    parameter TARGET_CHIP = 2,
    parameter WORD_WIDTH = 64,
    parameter NUM_WORDS = 8,
    parameter ADDR_WIDTH = 7 
)(
    srst, clk_txmac, tx8l_d, tx8l_sop, tx8l_eop, tx8l_error, tx8l_eop_pos, tx8l_rdempty,
    tx8l_rdreq, tx4l_d, tx4l_sop, tx4l_idle, tx4l_eop, tx4l_error, tx4l_eop_empty, tx4l_ack
); // module alt_e100s10_wide_l8if_tx824

//--- ports
input               srst;
input               clk_txmac;     // MAC + PCS clock - at least 312.5Mhz

input    [8*64-1:0] tx8l_d;        // 8 lane payload data
input               tx8l_sop;
input               tx8l_eop;
input         [5:0] tx8l_eop_pos;
input               tx8l_rdempty;
input               tx8l_error;
output              tx8l_rdreq;

output   [4*64-1:0] tx4l_d;        // 4 lane payload to send
output      [4-1:0] tx4l_sop;      // 4 lane start position
output      [4-1:0] tx4l_idle;     // 4 lane idle
output      [4-1:0] tx4l_eop;      // 4 lane end of packet
output    [4*3-1:0] tx4l_eop_empty;// 4 lane # of empty bytes at eop word
output      [4-1:0] tx4l_error;
input               tx4l_ack;      // payload is accepted


//--- declare
wire            clk_txmac;
wire [8*64-1:0] tx8l_d;
wire            tx8l_sop;
wire            tx8l_eop;
wire [5:0]      tx8l_eop_pos;
wire            tx8l_rdreq;
wire [4*64-1:0] pre_tx4l_d;
wire [4-1:0]    pre_tx4l_sop;
wire [4-1:0]    pre_tx4l_idle;
wire [4-1:0]    pre_tx4l_eop;
wire [4-1:0]    pre_tx4l_in_error;
wire [4*3-1:0]  pre_tx4l_eop_empty;
wire [4*64-1:0] tx4l_d;
wire [4-1:0]    tx4l_sop;
wire [4-1:0]    tx4l_idle;
wire [4-1:0]    tx4l_eop;
wire [4*3-1:0]    tx4l_eop_empty;
wire [4-1:0]    tx4l_error;
wire            tx4l_ack;
wire            tx4l_valid;
reg  [4*64-1:0] tx4l_d_2fifo;
reg  [4-1:0]    tx4l_sop_2fifo;
reg  [4-1:0]    tx4l_idle_2fifo;
reg  [4-1:0]    tx4l_eop_2fifo;
reg  [4-1:0]    tx4l_error_2fifo;
reg  [4*3-1:0]  tx4l_eop_empty_2fifo;
wire [4:0]      tx824fifo_usedw;

reg  [8*64-1:0] f0;     
reg             f0_sop_b7;
reg		f0_valid;
wire [7:0]      f0_sop; 
reg  [7:0]      f0_idle;
wire [7:0]      f0_eop;
reg  [5:0]      f0_eop_pos;
wire [23:0]     f0_eop_empty;
reg  [63:0]     test_eopbits;
reg  [3:0]      num_wr;
reg             in_pkt;
reg             tx8l_eop_r;
wire            sclk_rst;

reg             in_error;
//--- main

//wire srst;
//alt_e100s10_sync_arst sync_arst (clk_txmac, arst, srst);
reg [4:0] srst_r;
always @(posedge clk_txmac) srst_r <= {5{srst}}; // S10TIM Ok arst is actually sync'ed reset

wire tx8l_sop_x = !tx8l_rdempty && tx8l_sop; // mask out sop when not valid
wire tx8l_eop_x = !tx8l_rdempty && tx8l_eop; // mask out eop when not valid
wire tx8l_valid = tx8l_rdreq & (!tx8l_rdempty || !in_pkt); // force valid when not in pkt

always @(posedge clk_txmac) begin
   if (srst_r[0]) num_wr <= 0;
   else if (tx8l_valid)   num_wr <= tx8l_eop_x ? (4'h8 - tx8l_eop_pos[5:3]) : 4'h8; // IPG
   else              num_wr <= 0;
end

always @(posedge clk_txmac) begin
   if (srst_r[0])                                  in_pkt <= 1'b0;
   else if (tx8l_rdreq & !tx8l_rdempty & tx8l_eop) in_pkt <= 1'b0;
   else if (tx8l_rdreq & !tx8l_rdempty & tx8l_sop) in_pkt <= 1'b1;
end

always @(posedge clk_txmac) begin
      f0           <=  tx8l_d;
      f0_sop_b7    <=  tx8l_sop_x;
      tx8l_eop_r   <=  tx8l_eop_x;
      f0_eop_pos   <=  {6{tx8l_eop_x}} & tx8l_eop_pos;
end

wire [7:0] next_idle;
assign next_idle = {1'b0, (tx8l_eop_pos[5:3]==7), (tx8l_eop_pos[5:3]>=6), (tx8l_eop_pos[5:3]>=5), 
                    (tx8l_eop_pos[5:3]>=4), (tx8l_eop_pos[5:3]>=3), (tx8l_eop_pos[5:3]>=2), tx8l_eop_pos[5:3]!=0};

always @(posedge clk_txmac) begin
   if (!tx8l_valid) begin
      f0_idle <= 8'hff;
   end
   else begin
      case({in_pkt, tx8l_sop_x, tx8l_eop_x})
         3'b000: f0_idle <= 8'hff;
         3'b001: f0_idle <= 8'hff;
         3'b010: f0_idle <= 8'h0;
         3'b011: f0_idle <= next_idle;
         3'b100: f0_idle <= 8'h0;
         3'b101: f0_idle <= next_idle;
         3'b110: f0_idle <= 8'h0;
         3'b111: f0_idle <= next_idle;
         default : f0_idle <= 8'hff;
      endcase
   end
end

assign f0_sop = {f0_sop_b7, 7'h0};

genvar i;
generate
for (i=0; i<8; i=i+1) begin : eop_decode
   assign f0_eop_empty[(i+1)*3-1:i*3] = (f0_eop_pos[5:3] == i)? f0_eop_pos[2:0] : 3'h0;
   assign f0_eop[i] = tx8l_eop_r && (f0_eop_pos[5:3] == i);
end
endgenerate

/////////////////////////////////////////////////
// word addressable storage
/////////////////////////////////////////////////
localparam EXT_WORD_WIDTH = WORD_WIDTH + 1 + 1 + 1 + 3 + 1;
wire [EXT_WORD_WIDTH * NUM_WORDS-1:0] ext_din, ext_dout;
reg  [EXT_WORD_WIDTH * NUM_WORDS-1:0] ext_din_r;
reg [3:0] num_wr_r3, num_wr_r2, num_wr_r;
reg [3:0] num_wr_r3_minus_4, num_wr_r3_minus_4_inv; // S10TIM Ok
reg       num_wr_r3_ge_4; // S10TIM Ok

reg [ADDR_WIDTH-1:0] rd_addr;
reg [ADDR_WIDTH-1:0] holding;
//wire[ADDR_WIDTH:0]   holding_plus_num_wr = holding + num_wr_r3;
reg                  high_holding;

//wire                 go_read = (holding[ADDR_WIDTH-1:0]>=4) && (tx824fifo_usedw<=5'h6);
reg tx824fifo_used_pempty;
always @(posedge clk_txmac) tx824fifo_used_pempty <= (tx824fifo_usedw<=5'ha); // S10TIM Ok
wire                 go_read = (holding[ADDR_WIDTH-1:0]>=4) && tx824fifo_used_pempty; // S10TIM Ok

// embed SOP/EOP in data words
generate
for (i=0; i<NUM_WORDS; i=i+1) begin : pack_din
        assign ext_din[(i+1)*EXT_WORD_WIDTH-1:i*EXT_WORD_WIDTH] =
                        {in_error & f0_eop[i],
                         f0_sop[i],
                         f0_idle[i],
                         f0_eop[i],
                         f0_eop_empty[(i+1)*3-1:i*3],
                         f0[(i+1)*WORD_WIDTH-1:i*WORD_WIDTH]};
end
endgenerate

generate
for (i=0; i<4; i=i+1) begin : pack_dout
        assign {pre_tx4l_in_error[i],
                pre_tx4l_sop[i],
                pre_tx4l_idle[i],
                pre_tx4l_eop[i],
                pre_tx4l_eop_empty[(i+1)*3-1:i*3],
                pre_tx4l_d[(i+1)*WORD_WIDTH-1:i*WORD_WIDTH]} = 
                         ext_dout[(i+4+1)*EXT_WORD_WIDTH-1:(i+4)*EXT_WORD_WIDTH];
end
endgenerate

reg [3:0] word_enable;
reg [3:0] word_enable_1;
reg [3:0] word_enable_2;

wire ram_dout_valid;
always @(posedge clk_txmac) begin
   if (srst_r[0]) begin
      tx4l_sop_2fifo <= 0;
      tx4l_idle_2fifo <= 0;
      tx4l_eop_2fifo  <= 0;
      tx4l_eop_empty_2fifo <=0;
      //tx4l_d_2fifo <= 0;
   end
   else if (ram_dout_valid) begin
      tx4l_error_2fifo  <= word_enable_2 & pre_tx4l_in_error;
      tx4l_sop_2fifo  <= word_enable_2 & pre_tx4l_sop;
      tx4l_idle_2fifo <= word_enable_2 & pre_tx4l_idle;
      tx4l_eop_2fifo  <= word_enable_2 & pre_tx4l_eop;
      tx4l_eop_empty_2fifo <=
                     {{3{word_enable_2[3]}} & pre_tx4l_eop_empty[11: 9], 
                      {3{word_enable_2[2]}} & pre_tx4l_eop_empty[ 8: 6], 
                      {3{word_enable_2[1]}} & pre_tx4l_eop_empty[ 5: 3], 
                      {3{word_enable_2[0]}} & pre_tx4l_eop_empty[ 2: 0]};
      //tx4l_d_2fifo <= pre_tx4l_d;
   end
end

always @(posedge clk_txmac) if (ram_dout_valid) tx4l_d_2fifo <= pre_tx4l_d; // S10TIM Ok

// pipeline the write again - showing some timing pressure here
reg [ADDR_WIDTH:0] wr_addr, wr_addr_r;

always @(posedge clk_txmac) begin
    if(srst_r[1]) begin
        ext_din_r <= 0;
        wr_addr_r <= 0;
    end else begin
        ext_din_r <= ext_din;
        wr_addr_r <= wr_addr;
    end
end

wire [ADDR_WIDTH-1:0] num_read = go_read ? 7'h4 : 7'h0;

always @(*) begin
   if (go_read) word_enable[3:0] = 4'b1111;
   else         word_enable[3:0] = 4'b0000;
end

always @(posedge clk_txmac) begin
   if (srst_r[1]) begin
      word_enable_1 <= 0;
      word_enable_2 <= 0;
   end
   else begin
      word_enable_1 <= word_enable;
      word_enable_2 <= word_enable_1;
   end
end



// storage
alt_e100s10_wide_word_ram_824 wwr (
        .clk     (clk_txmac),
        .srst    (srst),
        .din     (ext_din_r),
        .wr_addr (wr_addr_r[ADDR_WIDTH-1:0]),            // addressing is in words
        .we      (1'b1),
        .dout    (ext_dout),
        .rd_addr (rd_addr[ADDR_WIDTH-1:0])
);
defparam wwr .WORD_WIDTH = EXT_WORD_WIDTH;
defparam wwr .NUM_WORDS = NUM_WORDS;  // barrel shifter mod required to override
defparam wwr .ADDR_WIDTH = ADDR_WIDTH;
defparam wwr .TARGET_CHIP = TARGET_CHIP;

// RAM pointers
reg [1:0] rd_history;
assign ram_dout_valid = rd_history[1];

//wire [7:0] holding_plus_num_wr_diff_num_read = holding_plus_num_wr - num_read;


always @(posedge clk_txmac) begin
        // delay for the write to settle
        if (srst_r[3]) begin
                rd_history <= 2'b00;
                wr_addr <= 0;
                holding <= 0;
                rd_addr <= 0;
        end else begin
                rd_history <= {rd_history[0],go_read};
                wr_addr <= wr_addr + num_wr;
                //holding <= (holding_plus_num_wr > num_read) ? holding_plus_num_wr_diff_num_read [6:0] : 7'b0;

                if (!go_read)                              holding <= holding + num_wr_r3; // S10TIM Ok
                else if (num_wr_r3_ge_4)                   holding <= holding + num_wr_r3_minus_4; // S10TIM Ok
                else if (holding >= num_wr_r3_minus_4_inv) holding <= holding - num_wr_r3_minus_4_inv; // S10TIM Ok
                else                                       holding <= 0; 


                rd_addr <= rd_addr + num_read;
        end
end


always @(posedge clk_txmac) begin
    if(srst_r[3]) begin
        num_wr_r <= 0;
        num_wr_r2 <= 0;
        num_wr_r3 <= 0;
        num_wr_r3_minus_4 <= 0;
        num_wr_r3_minus_4_inv <= 0;
        num_wr_r3_ge_4 <= 0;

        high_holding <= 0;
    end else begin
        // delay for the write to settle
        num_wr_r <= num_wr;
        num_wr_r2 <= num_wr_r;
        num_wr_r3 <= num_wr_r2;
        num_wr_r3_minus_4 <= num_wr_r2 - 3'h4;
        num_wr_r3_minus_4_inv <= 3'h4 - num_wr_r2;
        num_wr_r3_ge_4 <= (num_wr_r2 >=3'h4);
	
        high_holding <= holding >= 40; // ok. 
    end
end

assign tx8l_rdreq = !high_holding;

// output fifo
reg tx824fifo_wrreq;
wire tx824fifo_rdreq;
wire tx824fifo_clock;
wire [4*EXT_WORD_WIDTH-1:0] tx824fifo_data, tx824fifo_q;
wire [299:0]                tx824fifo_q_wide;
assign tx824fifo_q = tx824fifo_q_wide[4*EXT_WORD_WIDTH-1:0];

always @(posedge clk_txmac) tx824fifo_wrreq <= ram_dout_valid;

assign tx824fifo_data = { tx4l_error_2fifo,
                        tx4l_sop_2fifo,
                        tx4l_idle_2fifo,
                        tx4l_eop_2fifo,
                        tx4l_eop_empty_2fifo,
                        tx4l_d_2fifo};

wire tx824fifo_empty_w;
reg tx824fifo_empty;
always @(posedge clk_txmac) tx824fifo_empty <= tx824fifo_empty_w;

        scfifo_mlab tx824fifo (
                .clk(clk_txmac),
                .sclr(srst_r[4]),

                .wdata({16'd0, tx824fifo_data}),
                .wreq(tx824fifo_wrreq),
                .full(),

                .rdata(tx824fifo_q_wide),
                .rreq(tx824fifo_rdreq),
                .empty(tx824fifo_empty_w),

                .used(tx824fifo_usedw)
        );
        defparam tx824fifo .TARGET_CHIP = TARGET_CHIP;
        defparam tx824fifo .WIDTH = 300;
        //defparam tx824fifo .PREVENT_OVERFLOW = 1'b1;
        //defparam tx824fifo .PREVENT_UNDERFLOW = 1'b1;
        defparam tx824fifo .PREVENT_OVERFLOW = 1'b0; // S10TIM Ok
        defparam tx824fifo .PREVENT_UNDERFLOW = 1'b0; // S10TIM Ok
        defparam tx824fifo .ADDR_WIDTH = 5;




assign tx824fifo_rdreq = tx4l_ack & !tx824fifo_empty;

assign tx4l_error = {4{~tx824fifo_empty}} & tx824fifo_q[283:280];

assign tx4l_sop = {4{~tx824fifo_empty}} & tx824fifo_q[279:276];
assign tx4l_idle = {4{tx824fifo_empty}} | tx824fifo_q[275:272];
assign tx4l_eop = {4{~tx824fifo_empty}} & tx824fifo_q[271:268];
assign tx4l_eop_empty = {12{~tx824fifo_empty}} & tx824fifo_q[267:256];
assign tx4l_d = tx824fifo_q[255:0];

// propagate tx error

always @(posedge clk_txmac) begin
   if (srst_r[3])                                                    in_error <= 1'b0;
   else if (tx8l_rdreq & !tx8l_rdempty & tx8l_eop & tx8l_error) in_error <= 1'b1;
   else if (tx8l_rdreq & !tx8l_rdempty & tx8l_sop)              in_error <= 1'b0;


end



endmodule

