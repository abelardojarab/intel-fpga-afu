// (C) 2001-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



// ___________________________________________________________________________
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/ast/alt_aeu_40_wide_l4if_rx2to4.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
// ___________________________________________________________________________
//
///////////////////////////////////////////////////////////////////////////////
//
// Description: rx 2 lane to 4 lane conversion
//
// Authors:     ishimony   2010-10-25
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1ps / 1ps

module alt_aeu_40_wide_l4if_rx2to4 #(
    parameter RXSIDEBANDWIDTH = 9
)(
    arst, clk_rxmac, rx4l_d, rx4l_sop, rx4l_eop, rx4l_empty, rx4l_sideband,
    rx4l_fcs_valid,
    rx4l_wrfull, rx4l_wrreq, rx2l_d, rx2l_sop,rx2l_eop, rx2l_eop_empty, rx2l_valid,
    rx2l_sideband, rx2l_fcs_valid, rx2l_ready
);

//--- ports
input               arst;          // Async Reset
input               clk_rxmac;     // MAC + PCS clock - at least 312.5Mhz

output      [255:0] rx4l_d;        // 4 lane payload data
output              rx4l_sop;
output              rx4l_eop;
output        [4:0] rx4l_empty;
output  [RXSIDEBANDWIDTH-1:0] rx4l_sideband;
output              rx4l_fcs_valid;
input               rx4l_wrfull;
output              rx4l_wrreq;

input       [127:0] rx2l_d;        // 2 lane payload to send
input       [2-1:0] rx2l_sop;      // 2 lane start position
input       [2-1:0] rx2l_eop;      // 2 lane end position
input        [2*3-1:0] rx2l_eop_empty;   
input               rx2l_valid;    // payload is accepted
input [RXSIDEBANDWIDTH-1:0] rx2l_sideband;
input               rx2l_fcs_valid;
output              rx2l_ready;

//--- port type
wire                clk_rxmac;     // MAC + PCS clock - at least 312.5Mhz
wire        [255:0] rx4l_d;        // 4 lane payload data
wire                rx4l_sop;
wire                rx4l_eop;
wire          [4:0] rx4l_empty;
wire                rx4l_wrfull;
reg                 rx4l_wrreq = 0;
wire        [127:0] rx2l_d;        // 2 lane payload to send
wire          [1:0] rx2l_sop;      // 2 lane start position
wire          [1:0] rx2l_eop;      // 2 lane end position
wire         [2*3-1:0] rx2l_eop_empty;   // 2 lane end position, any byte, bit map
reg         [15:0] rx2l_eop_bm;   // 2 lane end position, any byte, bit map
wire                rx2l_valid;    // payload is accepted
wire                rx2l_ready;

//--- local

wire        [127:0] le_d;        // little endian 2 lane payload to send
wire          [1:0] le_sop;      // little endian 2 lane start position
wire          [3:0] le_eop;      // little endian 2 lane end position, any byte
wire                le_eop_f;    // eop flag

wire        [127:0] rxi_q_d;
wire          [1:0] rxi_q_sop;
wire          [3:0] rxi_q_eop;
wire                rxi_q_eop_f;
wire                rxi_q_fcs_valid;
wire [RXSIDEBANDWIDTH-1:0] rxi_q_sideband;

reg         [255:0] rxo_d       = 0; // output latch
reg                 sop_now     = 0; // send sop now
reg                 sop_now_f   = 0; // fast sop_now
reg                 sop_next    = 0; // send sop next cycle
reg                 sop_delayed = 0; // 
reg           [4:0] rxo_eop_n   = 0; // encoded rxo_eop (end of packet)
reg                 rxo_eop_v   = 0; // rxo_eop is valid
reg                 rxo_fcs_valid = 0;
reg   [RXSIDEBANDWIDTH-1:0] rxo_sideband = 0;
//reg                 block_eop   = 0;

// rx2to4 input fifo
wire                rxi_clock;        // fifo input
wire        [135+RXSIDEBANDWIDTH:0] rxi_data;         // fifo input
wire                rxi_rdreq;        // fifo input
wire                rxi_wrreq;        // fifo input
wire                rxi_empty;        // fifo output
wire                rxi_almost_full;  // fifo output
wire                rxi_full;         // fifo output
wire        [135+RXSIDEBANDWIDTH:0] rxi_q;            // fifo output
wire          [4:0] rxi_usedw;        // fifo output

reg                 rxi_in_packet   = 0;
reg                 ring_in_packet  = 0;
reg                 rxo_no_packet   = 1;
reg                 rxo_no_packet_f = 0;

reg         [127:0] r_d      [3:0];   // unit: bit   register ring

// flat ring - helps concise high level notation
wire    [6*128-1:0] flat_d;      // unit: bit 
wire     [6*16-1:0] flat_eop;    // unit: byte

reg           [1:0] r_lwrptr      = 0; // unit: 2 lanes write pointer
reg           [2:0] r_wrptr       = 0; // unit: lanes   write pointer
reg           [2:0] r_rdptr       = 0; // unit: lane    read pointer
// reg           [2:0] r_rdptr_s     = 0; // sampled r_rdptr
wire          [2:0] r_level;      // unit: lane    number of valid lanes
reg           [2:0] r_level_inc   = 0; // unit: lane
reg           [2:0] r_level_dec   = 0; // unit: lane
reg           [2:0] r_level_r     = 0; // r_level     registered
reg           [2:0] r_level_inc_r = 0; // r_level_inc registered
reg           [2:0] r_level_dec_r = 0; // r_level_dec registered
wire                r_wr;         // write into ring
wire                r_rd;         // read from ring
reg                 r_rd_s = 0;       // sampled r_rd
wire                r_pseudo_wr;  // extra write to clear an eop from the ring

wire               sopfifo_clock;
wire         [2:0] sopfifo_data;
// reg                sopfifo_rdreq = 0;
wire               sopfifo_rdreq_f;
wire               sopfifo_wrreq;
wire               sopfifo_empty;
wire         [2:0] sopfifo_q;
wire         [1:0] sopfifo_usedw;

wire               eopfifo_clock;
wire         [5:0] eopfifo_data;
// reg                eopfifo_rdreq = 0;
wire               eopfifo_rdreq_f;
wire               eopfifo_wrreq;
wire               eopfifo_empty;
wire         [5:0] eopfifo_q;
wire               eopfifo_fcs_valid;
wire  [RXSIDEBANDWIDTH-1:0] eopfifo_sideband;
wire         [1:0] eopfifo_usedw;

// reg           [4:0] dbg_rdptr = 0;       // unit: lane    read pointer
 wire                dbg_rdptr_error;     // dbg_rdptr != r_rdptr
wire                dbg_rxo_eop_error;   // 

wire [31:0] tmp1;
reg [31:0] tmp2;

//--- functions

//---
function  alt_aeu_40_wide_encode2to1;
input [1:0] in;

reg         out;
integer     i;

begin
    out = 0;
    for (i = 0; i < 2; i = i + 1) begin
        if (in[i])   out = out | i[0];
    end
    alt_aeu_40_wide_encode2to1 = out;
end
endfunction

//---
function [3:0] alt_aeu_40_wide_encode16to4;
input [15:0] in;

reg    [3:0] out;
integer      j;

begin
    out = 0;
    for (j = 0; j < 16; j = j + 1) begin
        if (in[j])   out = out | j[3:0];
    end
    alt_aeu_40_wide_encode16to4 = out;
end
endfunction

//---
function [127:0] alt_aeu_40_wide_little_endian2avalon_128;
input [127:0] a;

begin
    alt_aeu_40_wide_little_endian2avalon_128 = {a[  7: 0], a[ 15:  8], a[ 23: 16], a[ 31: 24],
                                a[ 39: 32], a[ 47: 40], a[ 55: 48], a[ 63: 56],
                                a[ 71: 64], a[ 79: 72], a[ 87: 80], a[ 95: 88],
                                a[103: 96], a[111:104], a[119:112], a[127:120]
                               };
end
endfunction 

//---
function [1:0] alt_aeu_40_wide_swap2;
input [1:0] a;

begin
    alt_aeu_40_wide_swap2  = {a[0], a[1]};
end
endfunction

//---
function [15:0] alt_aeu_40_wide_swap16;
input [15:0] a;

begin
    alt_aeu_40_wide_swap16 = {a[ 0], a[ 1], a[ 2], a[ 3], a[ 4], a[ 5], a[ 6], a[ 7],
              a[ 8], a[ 9], a[10], a[11], a[12], a[13], a[14], a[15]};
end
endfunction

// ((b-a) % 8) > 3
function delta_gt_3;
input [3:0] a;
input [3:0] b;
begin
    if (b >= a)
        delta_gt_3 = ((b - a) > 3)     ? 1'b1 : 1'b0; 
    else
        delta_gt_3 = ((8 + b - a) > 3) ? 1'b1 : 1'b0;
end
endfunction

// ((b-a) % 20)
function [4:0] bma_mod20;
input [4:0] a;
input [4:0] b;
begin
    if (b >= a) 
        bma_mod20 = b - a;
    else
        bma_mod20 = 5'd20 + b - a;
end
endfunction

// plus4mod8 = (r + 4) % 8;
function [3:0] plus4mod8;
input [3:0] r;

begin
    case (r)
         0: plus4mod8 = 4;
         1: plus4mod8 = 5;
         2: plus4mod8 = 6;
         3: plus4mod8 = 7;
         4: plus4mod8 = 0;
         5: plus4mod8 = 1;
         6: plus4mod8 = 2;
         7: plus4mod8 = 3;
         default: plus4mod8 = 0;
    endcase
end
endfunction

//--- main


always @(*) begin
        if (rx2l_eop[0]) begin
                case (rx2l_eop_empty[2:0])
                        3'b000: rx2l_eop_bm[7:0] = 8'b00000001;
                        3'b001: rx2l_eop_bm[7:0] = 8'b00000010;
                        3'b010: rx2l_eop_bm[7:0] = 8'b00000100;
                        3'b011: rx2l_eop_bm[7:0] = 8'b00001000;
                        3'b100: rx2l_eop_bm[7:0] = 8'b00010000;
                        3'b101: rx2l_eop_bm[7:0] = 8'b00100000;
                        3'b110: rx2l_eop_bm[7:0] = 8'b01000000;
                        3'b111: rx2l_eop_bm[7:0] = 8'b10000000;
                        default: rx2l_eop_bm[7:0] = 8'b0;
                endcase
        end
        else rx2l_eop_bm[7:0] = 8'b0;   
        if (rx2l_eop[1]) begin
                case (rx2l_eop_empty[5:3])
                        3'b000: rx2l_eop_bm[15:8] = 8'b00000001;
                        3'b001: rx2l_eop_bm[15:8] = 8'b00000010;
                        3'b010: rx2l_eop_bm[15:8] = 8'b00000100;
                        3'b011: rx2l_eop_bm[15:8] = 8'b00001000;
                        3'b100: rx2l_eop_bm[15:8] = 8'b00010000;
                        3'b101: rx2l_eop_bm[15:8] = 8'b00100000;
                        3'b110: rx2l_eop_bm[15:8] = 8'b01000000;
                        3'b111: rx2l_eop_bm[15:8] = 8'b10000000;
                        default: rx2l_eop_bm[15:8] = 8'b0;
                endcase
        end
        else rx2l_eop_bm[15:8] = 8'b0;
end

//--- map avalon-like mapping to little endian
assign le_d     = alt_aeu_40_wide_little_endian2avalon_128(rx2l_d);
assign le_sop   = alt_aeu_40_wide_swap2(rx2l_sop);
assign le_eop   = alt_aeu_40_wide_encode16to4(alt_aeu_40_wide_swap16(rx2l_eop_bm));
assign le_eop_f = |rx2l_eop;

//--- input fifo
assign rxi_clock  = clk_rxmac;
assign rxi_data   = {rx2l_sideband, rx2l_fcs_valid,
                     le_eop_f, le_eop,
                     le_sop,
                     le_d};
assign rx2l_ready = !rxi_almost_full;

// avoid writing junk data into fifo (this logic should not be here...)
always @(posedge clk_rxmac or posedge arst) begin
   if (arst) rxi_in_packet <= 0;
   else begin
    if ( (|le_sop) & !le_eop_f)
        rxi_in_packet <= 1;
    else if (!(|le_sop) & le_eop_f)
        rxi_in_packet <= 0;
   end
end

assign rxi_wrreq = rx2l_valid & rx2l_ready & (rxi_in_packet | (|le_sop));
assign rxi_rdreq = r_wr;

alt_aeu_40_wide_l4if_rx2to4fifo rxi(
    .aclr          (arst),            // i
    .clock         (rxi_clock),       // i
    .data          (rxi_data),        // i
    .rdreq         (rxi_rdreq),       // i
    .wrreq         (rxi_wrreq),       // i
    .empty         (rxi_empty),       // o
    .almost_full   (rxi_almost_full), // o
    .full          (rxi_full),        // o
    .q             (rxi_q),           // o
    .usedw         (rxi_usedw)        // o
);

//--- data path
assign  rxi_q_d     = rxi_q[127:  0];
assign  rxi_q_sop   = rxi_q[129:128] & {2{!rxi_empty}};
assign  rxi_q_eop   = rxi_q[133:130] & {4{!rxi_empty}};
assign  rxi_q_eop_f = rxi_q[134] & !rxi_empty;
assign  rxi_q_fcs_valid = rxi_q[135] & !rxi_empty;
assign  rxi_q_sideband = rxi_q[136+RXSIDEBANDWIDTH-1:136] & {RXSIDEBANDWIDTH{!rxi_empty}};

// ring
always @(posedge clk_rxmac) begin
    if (r_wr) begin
        r_d[r_lwrptr] <= rxi_q_d;
    end
end

// sop fifo
alt_aeu_40_wide_l4if_sopfifo alt_aeu_40_wide_l4if_sopfifo(
    .reset  (arst),         // i
    .clock  (sopfifo_clock), // i
    .data   (sopfifo_data),  // i
    .rdreq  (sopfifo_rdreq_f), // i
    .wrreq  (sopfifo_wrreq), // i
    .q      (sopfifo_q),     // o
    .usedw  (sopfifo_usedw)  // o
);
defparam alt_aeu_40_wide_l4if_sopfifo.WIDTH     = 3;
defparam alt_aeu_40_wide_l4if_sopfifo.DEPTH     = 4;
defparam alt_aeu_40_wide_l4if_sopfifo.LOG2DEPTH = 2;

assign sopfifo_clock = clk_rxmac;
assign sopfifo_data  = {r_lwrptr,1'b0} + alt_aeu_40_wide_encode2to1(rxi_q_sop);
assign sopfifo_wrreq = r_wr & (|rxi_q_sop);
assign sopfifo_empty = (sopfifo_usedw == 0) ? 1'b1 : 1'b0;

// eop fifo
alt_aeu_40_wide_l4if_sopfifo l4if_eopfifo(
    .reset  (arst),         // i
    .clock  (eopfifo_clock), // i
    .data   (eopfifo_data),  // i
    .rdreq  (eopfifo_rdreq_f), // i
    .wrreq  (eopfifo_wrreq), // i
    .q      (eopfifo_q),     // o
    .usedw  (eopfifo_usedw)  // o
);
defparam l4if_eopfifo.WIDTH     = 6;
defparam l4if_eopfifo.DEPTH     = 4;
defparam l4if_eopfifo.LOG2DEPTH = 2;

alt_aeu_40_wide_l4if_sopfifo l4if_eopfifo1(
    .reset  (arst),         // i
    .clock  (eopfifo_clock), // i
    .data   ({rxi_q_fcs_valid, rxi_q_sideband}),  // i
    .rdreq  (eopfifo_rdreq_f), // i
    .wrreq  (eopfifo_wrreq), // i
    .q      ({eopfifo_fcs_valid, eopfifo_sideband}),     // o
    .usedw  ()  // o
);
defparam l4if_eopfifo1.WIDTH     = 1+RXSIDEBANDWIDTH; /*for fcs_valid and sideband*/
defparam l4if_eopfifo1.DEPTH     = 4;
defparam l4if_eopfifo1.LOG2DEPTH = 2;

assign eopfifo_clock = clk_rxmac;
assign eopfifo_data  = {r_lwrptr,4'b0} + rxi_q_eop;
assign eopfifo_wrreq = r_wr & rxi_q_eop_f;
assign eopfifo_empty = (eopfifo_usedw == 0) ? 1'b1 : 1'b0;

// read from ring: high level implementation
assign flat_d   = {r_d[1], r_d[0], r_d[3], r_d[2], r_d[1], r_d[0]};
assign tmp1 = eopfifo_q - {r_rdptr, 3'b000};
wire [7:0] tmp1_pos;
assign tmp1_pos = tmp1[7:0] + 8'd64;
always @(posedge clk_rxmac) begin
//  rxo_d   <= flat_d  [{r_rdptr, 6'b000000} +: 256];
    if (r_rd & !rxo_no_packet_f) begin
        case (r_rdptr)
            0: rxo_d <= flat_d[   0 +: 256];
            1: rxo_d <= flat_d[  64 +: 256];
            2: rxo_d <= flat_d[ 128 +: 256];
            3: rxo_d <= flat_d[ 192 +: 256];
            4: rxo_d <= flat_d[ 256 +: 256];
            5: rxo_d <= flat_d[ 320 +: 256];
            6: rxo_d <= flat_d[ 384 +: 256];
            7: rxo_d <= flat_d[ 448 +: 256];
        endcase // case (r_rdptr)

        rxo_fcs_valid <= !eopfifo_empty & eopfifo_fcs_valid;
        rxo_sideband <= eopfifo_sideband;
                
        if (!eopfifo_empty & !delta_gt_3(r_rdptr, eopfifo_q[5:3])) begin
            rxo_eop_v <= 1;
        end else begin
            rxo_eop_v <= 0;
        end

        if (tmp1 >= 0)  rxo_eop_n <= tmp1[4:0];
        else           rxo_eop_n <= tmp1_pos[4:0];
    end
end

//--- write into ring
assign r_wr        = (r_level < 16) ? !rxi_empty : 1'b0;

// in_packet at ring output
always @(posedge clk_rxmac or posedge arst) begin
    if (arst) ring_in_packet <= 0;
    else begin
      if      (|rxi_q_sop)
        ring_in_packet <= 1;
      else if (rxi_q_eop_f)
        ring_in_packet <= 0;
    end
end

// pseudo write into ring - in case of eop and level less then a full line
//2assign r_pseudo_wr = 
//2       ((r_level > 0) & (r_level < 8) & !eopfifo_empty & !r_wr) ? 1 : 0;
assign r_pseudo_wr = 
       ((r_level > 0) & (r_level < 4) & !eopfifo_empty & !r_wr) ? 
                     !ring_in_packet : 1'b0;

wire [31:0] r_wrptr_tmp = (r_wrptr + 2'b10) % 8;
always @(posedge clk_rxmac or posedge arst) begin
//1 if (r_wr) begin
    if (arst) begin
        r_lwrptr <= 0;
        r_wrptr  <= 0;
    end
    else begin
       if (r_wr | r_pseudo_wr) begin
          r_lwrptr <= r_lwrptr + 1'b1;
          r_wrptr  <= r_wrptr_tmp [2:0] ;
       end
    end
end

// read from ring
assign r_rd = (r_level > 3) ? 1'b1 : 1'b0;
wire [3:0] r_rdptr_tmp = plus4mod8(r_rdptr);

wire [4:0] tmp2_pos;
assign tmp2_pos = tmp2[4:0] + 5'd8;


always @(*) begin
    if (r_wr | r_pseudo_wr) r_level_inc  = 2;
    else                    r_level_inc  = 0;

    tmp2 = sopfifo_q - r_rdptr;
    
    if (r_rd) begin
        if (!sopfifo_empty) begin
            if (tmp2 == 0)     r_level_dec = 3'h4;
            else if (tmp2 > 0) r_level_dec = tmp2[2:0];
                 else r_level_dec = tmp2_pos [2:0];
            if (r_level_dec > 4) r_level_dec = 3'h4;
        end else begin
            r_level_dec = 3'h4;
        end
    end else begin
        r_level_dec = 0;
    end
end

always @(posedge clk_rxmac or posedge arst) begin
   if (arst) begin
      r_rdptr <= 0;
      // block_eop <= 0;
      sop_now <= 0;
      sop_next <= 0;
      // sopfifo_rdreq <= 0;
      // eopfifo_rdreq <= 0;
    
      r_level_inc_r <= 0;
      r_level_dec_r <= 0;
      r_level_r     <= 0;
    
      sop_delayed   <= 0;
   end
   else begin
    
    if (r_rd) begin
        if (sopfifo_empty | delta_gt_3(r_rdptr, sopfifo_q)) begin
            r_rdptr     <= r_rdptr_tmp[2:0];
            // block_eop   <= 0;
            sop_now     <= 0;
            sop_next    <= 0;
        end else begin
            if (!sopfifo_empty & (r_rdptr == sopfifo_q)) begin
                r_rdptr     <= r_rdptr_tmp[2:0];
                // block_eop   <= 0;
                sop_now     <= 1;
                sop_next    <= 0;
            end else begin
                r_rdptr     <= sopfifo_q;
                sop_now     <= 0;
                sop_next    <= 1;
            end
        end
    end
    
    // sopfifo_rdreq <= sopfifo_rdreq_f;
    // eopfifo_rdreq <= eopfifo_rdreq_f;
    
    r_level_inc_r <= r_level_inc;
    r_level_dec_r <= r_level_dec;
    r_level_r     <= r_level;
    
    sop_delayed   <= sop_next;
   end
end // always @ (posedge clk_rxmac)
assign r_level = r_level_r + r_level_inc_r - r_level_dec_r;

assign sopfifo_rdreq_f = (r_rd & 
                         !sopfifo_empty & 
                         !delta_gt_3(r_rdptr, sopfifo_q)) ? 1'b1 : 1'b0;

assign eopfifo_rdreq_f = (r_rd & 
                         !eopfifo_empty & 
                         !delta_gt_3(r_rdptr, eopfifo_q[5:3]) &
                         // this next line holds off on popping the eop in the case we need to make a rdptr sop adjustment (sop_next)
                         !(rxo_no_packet_f & !sopfifo_empty & (r_rdptr != sopfifo_q) & !delta_gt_3(r_rdptr, sopfifo_q))) ? 1'b1 : 1'b0;

// assign dbg_rdptr_error = (r_rdptr != dbg_rdptr) ? 1 : 0;

always @(*) begin
    rxo_no_packet_f = rxo_no_packet;
    sop_now_f       = (!sopfifo_empty & (r_rdptr == sopfifo_q)) ? 1'b1 : 1'b0;
    
    if (r_rd & (sop_now_f | sop_next))
        rxo_no_packet_f = 1'b0;
    else if (r_rd_s & rxo_eop_v)
        rxo_no_packet_f = 1'b1;
end

// avoid writing junk data into fifo
always @(posedge clk_rxmac) begin
    rxo_no_packet <= rxo_no_packet_f;
    r_rd_s        <= r_rd;
    
// make sure wrreq active only during a packet
    rx4l_wrreq <= r_rd & !rxo_no_packet_f;
end

assign rx4l_d     = rxo_d;
assign rx4l_sop   = sop_now | sop_delayed;
assign rx4l_eop   = rxo_eop_v;
wire [5:0] rx4l_empty_tmp = 6'd31 - rxo_eop_n;
assign rx4l_empty = rx4l_empty_tmp[4:0];
assign rx4l_fcs_valid = rxo_fcs_valid;
assign rx4l_sideband = rxo_sideband;


endmodule
