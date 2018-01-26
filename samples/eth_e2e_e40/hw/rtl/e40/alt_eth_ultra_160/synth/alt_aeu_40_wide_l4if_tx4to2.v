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
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/ast/alt_aeu_40_wide_l4if_tx4to2.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
// ___________________________________________________________________________
//
///////////////////////////////////////////////////////////////////////////////
//
// Description: tx 4 lane to 2 lane conversion
//
// Authors:     ishimony   2010-10-25
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Barrel shifter positions:
//
//         f0                 f1
//
//  |               | |               |
//  | 3 | 2 | 1 | 0 | | 3 | 2 | 1 | 0 |
//  +---+---+---+---+ +---+---+---+---+
//    7   6   5   4     3   2   1   0
//
// o_pos
//  -   .   .   .   .   .     | 1 | 0 |
//                            +---+---+
//
//  0   .   .   .   .     | 1 | 0 |
//                        +---+---+
//
//  1   .   .   .     | 1 | 0 |
//                    +---+---+
//
//  2   .   .   | 1 | | 0 |
//              +---+ +---+
//
//  3   .   | 1 | 0 |
//          +---+---+
//
///////////////////////////////////////////////////////////////////////////////
// Data Path
//
//                 input fifo
//             |                 |
//             |-----------------|
//  clk_txmac  |                 |  rdreq
//  -----------|>                |<--------
//             +-----------------+
//                      |
//                     f0
//                      |
//                      +--------------------------------+
//                      |                                |
//                      v                                |
//             +-----------------+                       |
//             |                 |                       |
//  clk_txmac  |       f1        |                       |
//  -----------|>                |                       v
//             +-----------------+              +-----------------+
//                      |                       |                 |
//                      +-----------------+---->|  control logic  |
//                      |                 |     |                 |
//                      |                 |     +-----------------+
//                      v                 |              |
//             +-----------------+        |              |
//             |                 |        |              |
//  clk_txmac  |       f2        |        |              |
//  -----------|>                |        |              |
//             +-----------------+        |              |
//                      |                 |              |
//                      |                 |              |
//                      |                 |              |
//                      v                 v              |
//                   +-----------------------+           |
//                    \                     /   o_sel    |
//  clk_txmac          \                   /<------------+
//  --------------------\>                /
//                       +-------+-------+
//                               |
//                               v

`timescale 1ps / 1ps

module alt_aeu_40_wide_l4if_tx4to2(
    arst, clk_txmac, tx4l_d, tx4l_sop, tx4l_eop, tx4l_error, tx4l_eop_pos, tx4l_rdempty,
    tx4l_rdreq, tx2l_d, tx2l_sop, tx2l_eop , tx2l_error, tx2l_eop_empty, tx2l_ack
); // module alt_aeu_40_wide_l4if_tx4to2
parameter SIM_LOG_FILE = "";
parameter TARGET_CHIP=5;

//--- ports
input               arst;
input               clk_txmac;     // MAC + PCS clock - at least 312.5Mhz

input    [4*64-1:0] tx4l_d;        // 4 lane payload data
input               tx4l_sop;
input               tx4l_eop;
input               tx4l_error;
input         [4:0] tx4l_eop_pos;
input               tx4l_rdempty;
output              tx4l_rdreq;

output   [2*64-1:0] tx2l_d;        // 2 lane payload to send
output      [2-1:0] tx2l_sop;      // 2 lane start position
output      [2-1:0] tx2l_eop;      // 2 lane end position
output   [2-1:0]    tx2l_error;
output    [2*3-1:0] tx2l_eop_empty;
input               tx2l_ack;      // payload is accepted


localparam TX_OUT_FIFO_READ_WM = 8;
localparam TX_OUT_FIFO_ALMOST_FULL = 28;

wire                clk_txmac;
wire     [4*64-1:0] tx4l_d;
wire                tx4l_sop;
wire                tx4l_eop;
wire          [4:0] tx4l_eop_pos;
wire                tx4l_rdempty;
wire                tx4l_rdreq;
wire     [2*64-1:0] tx2l_d;
wire        [2-1:0] tx2l_sop;
wire         [2-1:0] tx2l_eop;
wire         [2-1:0] tx2l_error;
wire      [2*8-1:0] tx2l_eop_bm;
reg       [2*3-1:0] tx2l_eop_empty;
wire                tx2l_ack;
wire                tx2l_valid;

//--- local
reg  [2*64-1:0] d        = 0;

wire [2*64-1:0] d1;
wire    [2-1:0] sop1;
wire    [4-1:0] eop_pos1;
wire            eop_flag1;

wire [4*64-1:0] f0;             // alt_aeu_40_wide_top fifo entry
wire            f0sop;
wire            f0eop;
wire      [4:0] f0eop_pos;
wire            f0v; //      = 0;   // f0 valid

reg  [4*64-1:0] f1       = 0;   // alt_aeu_40_wide_top-1 fifo entry
reg       [4:0] f1eop_pos;
reg             f1eop    = 0;
reg             f1error  = 0;
// reg             f1sop    = 0;
// reg             f1v      = 0;   // f1 valid

wire            f0_sop;     // start of packet             - f0 pipe stage
wire            f0_eop;     // end of packet flag, ingress - f0 pipe stage
wire      [4:0] f0_eop_pos; // end of packet position      - f0 pipe stage

// wire            f1_sop;     // start of packet             - f0 pipe stage
wire            f1_error;
wire            f1_eop;     // end of packet flag, ingress - f0 pipe stage
wire      [4:0] f1_eop_pos; // end of packet position      - f0 pipe stage

reg  [4*64-1:0] f2       = 0;

reg             pause; //    = 0; // pause state machine because of !tx2l_ack
reg             pause_s; //  = 0;

reg             output_valid  = 0;
reg             output_valid1 = 0;

wire    [135:0] tx4to2fifo_data;
reg             tx4to2fifo_rdreq_r = 0;
wire            tx4to2fifo_rdreq;
reg             wrreq = 0;
wire            tx4to2fifo_wrreq;
wire            tx4to2fifo_empty;
wire            tx4to2fifo_full;
wire    [135:0] tx4to2fifo_q;
wire      [4:0] tx4to2fifo_usedw;

reg       [7:0] tx4to2fifo_eop_count = 0; // count number of eop in fifo

reg       [1:0] v_pos       = 0; // next output mux position (starting lane)
reg             v_sop       = 0;
reg       [1:0] v_sop_pos   = 0;
reg             v_eop       = 0;
reg             v_eop0      = 0;
reg             v_eop1      = 0;
reg       [3:0] v_eop_pos   = 0;
reg             v_pop       = 1;
reg       [3:0] v_sel       = 4'b1111;


reg       [1:0] o_pos       = 0; // output mux position (starting lane)
reg             o_sop       = 0;
reg             o1_sop      = 0;
reg       [1:0] o_sop_pos   = 0;
reg       [1:0] o1_sop_pos  = 0;
reg             o_eop       = 0;
reg             o1_eop      = 0;
reg             o_eop0      = 0;
// reg             o_eop1      = 0;
reg       [3:0] o_eop_pos   = 0;
reg       [3:0] o1_eop_pos  = 0;
// reg             o_pop       = 1;
reg       [3:0] o_sel       = 4'b1111;

reg       [1:0] f0_eop_pos_b = 0; // eop_pos in bytes
reg       [1:0] f1_eop_pos_b = 0; // eop_pos in bytes



// debug
// reg       [5:0] max_tx4to2fifo_usedw_dbg = 0;

//--- functions
function [127:0] alt_aeu_40_wide_little_endian2avalon_128;
input [127:0] a;

begin
    alt_aeu_40_wide_little_endian2avalon_128 = {a[  7: 0],  a[ 15:  8], a[ 23: 16], a[ 31: 24],
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

//---
function [15:0] alt_aeu_40_wide_decode4to16;
input [3:0] select;

reg   [3:0] select;

begin
    case (select)
         0:      alt_aeu_40_wide_decode4to16 = 16'b0000000000000001;
         1:      alt_aeu_40_wide_decode4to16 = 16'b0000000000000010;
         2:      alt_aeu_40_wide_decode4to16 = 16'b0000000000000100;
         3:      alt_aeu_40_wide_decode4to16 = 16'b0000000000001000;
         4:      alt_aeu_40_wide_decode4to16 = 16'b0000000000010000;
         5:      alt_aeu_40_wide_decode4to16 = 16'b0000000000100000;
         6:      alt_aeu_40_wide_decode4to16 = 16'b0000000001000000;
         7:      alt_aeu_40_wide_decode4to16 = 16'b0000000010000000;
         8:      alt_aeu_40_wide_decode4to16 = 16'b0000000100000000;
         9:      alt_aeu_40_wide_decode4to16 = 16'b0000001000000000;
        10:      alt_aeu_40_wide_decode4to16 = 16'b0000010000000000;
        11:      alt_aeu_40_wide_decode4to16 = 16'b0000100000000000;
        12:      alt_aeu_40_wide_decode4to16 = 16'b0001000000000000;
        13:      alt_aeu_40_wide_decode4to16 = 16'b0010000000000000;
        14:      alt_aeu_40_wide_decode4to16 = 16'b0100000000000000;
        15:      alt_aeu_40_wide_decode4to16 = 16'b1000000000000000;
    endcase // case (select)
end
endfunction

//--- main

wire reset;
alt_aeu_40_sync_arst sync_arst_txmac (clk_txmac, arst, reset);

// f0, f1: input fifo extension. f0 connected directly to the fifo's output
wire f0error;
assign f0         =  tx4l_d;
assign f0sop      =  tx4l_sop;
assign f0eop      =  tx4l_eop;
assign f0error    =  tx4l_error;
assign f0eop_pos  =  tx4l_eop_pos;


// Entry f0 valid
//    set  : read request + fifo not empty
//    clear: if not set condition and sop, avoid duplicate sop indications/
//always @(posedge clk_txmac or posedge reset) begin
//    if (reset) f0v <= 0;
//    else if (!pause) begin
//        if (tx4l_rdreq)
//        //if (tx4l_rdreq && !tx4l_rdempty)
//            f0v <= 1;
//        else if (tx4l_rdempty & !pause & v_pop)
//            f0v <= 0;
//    end
//end

// simplified f0 valid, based on tx_valid for no-dcfifo case. Gates eop and sop when invalid.
assign f0v = !tx4l_rdempty;

always @(posedge clk_txmac or posedge reset) begin
    if (reset) begin
        f1        <= 0;
        f1eop_pos <= 0;

        // f1v       <= 0;
        // f1sop     <= 0;
        f1eop     <= 0;
        f1error   <= 0;
    end

    else if (!pause & v_pop) begin
        f1        <= f0;
        f1eop_pos <= f0eop_pos;

        // f1v       <= f0v;
        // f1sop     <= f0sop & f0v;
        f1eop     <= f0eop & f0v;
        f1error   <= f0error & f0v;
    end
end

// input conditioning - assuming single sop/line
wire f0_error;
assign f0_sop        = f0sop & f0v;
assign f0_eop        = f0eop & f0v;
assign f0_error      = f0error & f0v;
assign f0_eop_pos    = f0eop_pos;

// assign f1_sop        = f1sop;
assign f1_eop        = f1eop & !o_eop0;
assign f1_error      = f1error & !o_eop0;
assign f1_eop_pos    = f1eop_pos;

// main
always @(*) begin
    v_pop = 1;
    case (o_pos)
        0: v_pop = ((f1_eop_pos[4:3] < 2)&(f1_eop_pos[4:3] > 0)) ? f1_eop : 1'b0;
        1: v_pop = ((f1_eop_pos[4:3] < 3)&(f1_eop_pos[4:3] > 1)) ? f1_eop : 1'b0;
        2: v_pop = 1'b1;
        3: v_pop = 1'b1;
    endcase
end

wire [4:0] v_eop_pos_tmp1 = f1_eop_pos - 5'h08;
wire [4:0] v_eop_pos_tmp2 = f1_eop_pos - 5'h10;
wire [4:0] v_eop_pos_tmp3 = f1_eop ? (f1_eop_pos - 5'h18) : (f0_eop_pos + 5'h08);
reg v_pack_input;
reg o_pack_input;
always @(*) begin
// no protection is provided for illegal inputs
    f0_eop_pos_b = f0_eop_pos[4:3];
    f1_eop_pos_b = f1_eop_pos[4:3];

    v_eop  = 0;
    v_eop0 = 0;
    v_eop1 = 0;
    case (o_pos)
        0: v_eop1 = ((f1_eop_pos_b <  3) && (f1_eop_pos_b > 0)) ? f1_eop : 1'b0;
        1: v_eop1 =                         (f1_eop_pos_b > 1)  ? f1_eop : 1'b0;
        2: begin
            v_eop1 = (f1_eop_pos_b > 2) ? f1_eop : 1'b0;
            v_eop0 = (f0_eop_pos_b < 1) ? f0_eop : 1'b0;
        end
        3: begin
            v_eop1 = 0;
            v_eop0 = (f0_eop_pos_b < 2) ? f0_eop : 1'b0;
        end
    endcase
    v_eop = v_eop0 | v_eop1;

    v_eop_pos = 0;
    case (o_pos)
        0: v_eop_pos = v_eop_pos_tmp1[3:0];  
        1: v_eop_pos = v_eop_pos_tmp2[3:0];  
        2: v_eop_pos = v_eop_pos_tmp3[3:0];        
        3: v_eop_pos = f0_eop_pos[3:0];
    endcase // case (o_pos)

    v_sop = 0;
    if (!v_eop) begin
        case (o_pos)
            2: v_sop = f0_sop;
            3: v_sop = f0_sop;
            default: ;
        endcase
    end else begin
        case (o_pos)
            0: case (v_eop_pos[3])
                   0: v_sop = f0_sop;
                   default: ;
               endcase
            1: case (v_eop_pos[3])
                   0: v_sop = f0_sop;
                   default: ;
               endcase
            2: v_sop = f0_sop;
            3: v_sop = f0_sop;
            default: ;
        endcase // case (o_pos)
    end

    v_sop_pos =  {1'b0, 1'b0};
    if (!v_eop) begin
        case (o_pos)
            2: v_sop_pos = {f0_sop, 1'b0  };
            3: v_sop_pos = {1'b0,   f0_sop};
            default: ;
        endcase
    end else begin
        case (o_pos)
            0: case (v_eop_pos[3])
                   0: v_sop_pos  = {f0_sop, 1'b0};
                   default: ;
               endcase
            1: case (v_eop_pos[3])
                   0: v_sop_pos  = {f0_sop, 1'b0};
                   default: ;
               endcase
            2: v_sop_pos  = {f0_sop, 1'b0};
            3: v_sop_pos =  {f0_sop};
            default: ;
        endcase // case (o_pos)
    end

    v_sel =  4'b1111;                         // 6'o54
    if (!(output_valid | v_sop)) begin
        v_sel = 4'b1111;                      // 6'o54
    end else if (!v_eop) begin
        case (o_pos)
            0: v_sel      = 4'b0000;          // 6'o21
            1: v_sel      = 4'b0101;          // 6'o32
            2: v_sel      = 4'b1010;          // 6'o43
            3: v_sel      = 4'b1111;          // 6'o54
        endcase
    end else begin
        case (o_pos)
            0: case (v_eop_pos[3])
                   0: v_sel      = 4'b1000;   // 6'o41
                   1: v_sel      = 4'b0000;   // 6'o21
               endcase
            1: case (v_eop_pos[3])
                   0: v_sel      = 4'b1001;   // 6'o42
                   1: v_sel      = 4'b0101;   // 6'o32
               endcase
            2: v_sel      = 4'b1010;          // 6'o43
            3: v_sel      = 4'b1111;          // 6'o54
        endcase // case (o_pos)
    end
    
    v_pack_input = 1'b0; 
    if (tx4l_sop && !tx4l_eop && (f1eop_pos < 5'h8) && f1eop && (o_pos == 2'b11) && (o_sel == 4'hf)) v_pack_input = 1'b1;

    v_pos = 3;
    if (!(output_valid | v_sop)) begin
        v_pos = 2'b11;
    end else if (v_pack_input) begin
    	v_pos = 2'b10;
    end else if (!v_eop) begin
        case (o_pos)
            0: v_pos = 2;
            1: v_pos = 3;
            2: v_pos = 0;
            3: v_pos = 1;
        endcase
    end else begin
        case (o_pos)
            0: case (v_eop_pos[3])
                   0: v_pos = 0;
                   1: v_pos = 3;
               endcase
            1: case (v_eop_pos[3])
                   0: v_pos = 0;
                   1: v_pos = 3;
               endcase
            2: case (v_eop_pos[3])
                   0: v_pos = 0;
                   1: v_pos = 3;
               endcase
            3: case (v_eop_pos[3])
                   0: v_pos = 3;
                   1: v_pos = 3;
               endcase
        endcase // case (o_pos)
    end
end

always @(posedge clk_txmac or posedge reset) begin
    if (reset) begin
        o_pos       <= 0;
        o_sop       <= 0;
        o_sop_pos   <= 0;
        o_eop       <= 0;
        o_eop_pos   <= 0;
        // o_pop       <= 0;
        o_eop0      <= 0;
        o_sel       <= 4'b1111;
	o_pack_input <= 0;

        o1_sop      <= 0;
        o1_sop_pos  <= 0;
        o1_eop      <= 0;
        o1_eop_pos  <= 0;
    end
    else if (!pause) begin
        o_pos       <= v_pos;
        o_sop       <= v_sop;
        o_sop_pos   <= v_sop_pos;
        o_eop       <= v_eop;
        o_eop_pos   <= v_eop_pos;
        // o_pop       <= v_pop;
        o_eop0      <= v_eop0;
        o_sel       <= v_sel;
	    o_pack_input <= v_pack_input;
        o1_sop      <= o_sop;
        o1_sop_pos  <= o_sop_pos;
        o1_eop      <= o_eop;
        o1_eop_pos  <= o_eop_pos;
		
		// Move the SOP up a position during a pack condition
		if (v_pack_input) begin
			o_sop       <= 0;
			o_sop_pos   <= 0;
			o1_sop      <= 1'b1;
			o1_sop_pos  <= 2'b10;
			
		end
    end
end



///////////////////////////////////
// logic for TX Error Propagation
//

reg e_eop, e_eop0, e_eop1;
always @(*) begin

    e_eop  = 0;
    e_eop0 = 0;
    e_eop1 = 0;
    case (o_pos)
        0: e_eop1 = ((f1_eop_pos_b <  3) && (f1_eop_pos_b > 0)) ? f1_error : 1'b0;
        1: e_eop1 =                         (f1_eop_pos_b > 1)  ? f1_error : 1'b0;
        2: begin
            e_eop1 = (f1_eop_pos_b > 2) ? f1_error : 1'b0;
            e_eop0 = (f0_eop_pos_b < 1) ? f0_error : 1'b0;
        end
        3: begin
            e_eop1 = 0;
            e_eop0 = (f0_eop_pos_b < 2) ? f0_error : 1'b0;
        end
    endcase
    e_eop = e_eop0 | e_eop1;

end

reg o_error, tx_error;
always @(posedge clk_txmac) begin
    if (!pause)  begin
        o_error     <=  e_eop;
        tx_error    <=  o_error;
    end
end



//////////////


always @(posedge clk_txmac or posedge reset) begin
    if (reset) begin
        output_valid <= 0;
        output_valid1 <= 0;
    end
    else if (!pause) begin
        if (v_sop)
            output_valid <= 1;
        else if (v_eop)
            output_valid <= 0;
        output_valid1 <= output_valid;
    end
end // always @ (posedge clk_txmac)



always @(posedge clk_txmac) begin
    if (!pause) 
        f2 <= f1;
end

    
// barrel shifter
always @(posedge clk_txmac) begin
    if (!pause) begin
        case (o_sel[1:0])
            0: d[0*64 +: 64] <= f2[1*64 +: 64];
            1: d[0*64 +: 64] <= f2[2*64 +: 64];
            2: d[0*64 +: 64] <= f2[3*64 +: 64];
            3: d[0*64 +: 64] <= f1[0*64 +: 64];
            default: $display("*** Error: o_sel0=%d", o_sel[1:0]);
        endcase
        case (o_sel[3:2])
            0: d[1*64 +: 64] <= f2[2*64 +: 64];
            1: d[1*64 +: 64] <= f2[3*64 +: 64];
            2: d[1*64 +: 64] <= f1[0*64 +: 64];
            3: d[1*64 +: 64] <= f1[1*64 +: 64];
            default: $display("*** Error: o_sel1=%d", o_sel[3:2]);
        endcase
	if (v_pack_input == 1'b1) d[1*64 +: 64] <= f0[0*64 +: 64];
	if (o_pack_input == 1'b1) begin
		d[0*64 +: 64] <= f1[1*64 +: 64];
		d[1*64 +: 64] <= f1[2*64 +: 64];
	end
    end // if (!pause)
end // always @ (posedge clk_txmac

//assign tx4l_rdreq    = !tx4l_rdempty & !pause & v_pop;
assign tx4l_rdreq    = !pause & v_pop;

// pause
always @(posedge clk_txmac or posedge reset) begin
	if(reset) begin
		pause_s <= 1'b1;
		pause <= 1'b1;
	end else begin
		pause_s <= pause;
		pause   <= (tx4to2fifo_usedw > TX_OUT_FIFO_ALMOST_FULL) ? 1'b1 : 1'b0;
	end
end

// output fifo
wire tx4to2fifo_clock = clk_txmac;
assign tx4to2fifo_data = {tx_error,
                          o1_sop_pos,
                          o1_eop,
                          o1_eop_pos,
                          d};

// assign tx2l_valid = output_valid & !pause_s;
//2assign tx4to2fifo_wrreq = (output_valid | output_valid1) & !pause_s;
always @(posedge clk_txmac or posedge reset) begin
    if (reset) wrreq <= 0;
    else if (!pause)
        wrreq <= (output_valid | output_valid1);
end
assign tx4to2fifo_wrreq = wrreq & !pause_s;

// if needed an output register can be added to this fifo
alt_aeu_40_wide_l4if_tx4to2fifo alt_aeu_40_wide_l4if_tx4to2fifo(
    .aclr         (arst),                      // i
    .clock        (tx4to2fifo_clock),          // i
    .data         (tx4to2fifo_data),           // i
    .rdreq        (tx4to2fifo_rdreq),          // i
    .wrreq        (tx4to2fifo_wrreq),          // i
    .empty        (tx4to2fifo_empty),          // o
    .full         (tx4to2fifo_full),           // o
    .q            (tx4to2fifo_q),              // o
    .usedw        (tx4to2fifo_usedw)           // o
); // module alt_aeu_40_wide_l4if_tx4to2fifo

// read from fifo - make sure a packet is consecutive
always @(posedge clk_txmac or posedge reset) begin
    if (reset) 
        tx4to2fifo_eop_count <= 0;
    else if      ( (o1_eop & !o1_sop & tx4to2fifo_wrreq) &
        !(eop_flag1 & !(|sop1) & tx4to2fifo_rdreq & tx2l_valid))
        tx4to2fifo_eop_count <= tx4to2fifo_eop_count + 1'b1;
    else if (!(o1_eop  & !o1_sop & tx4to2fifo_wrreq) &
        (eop_flag1 & !(|sop1) & tx4to2fifo_rdreq  & tx2l_valid))
        tx4to2fifo_eop_count <= tx4to2fifo_eop_count - 1'b1;
end

// read when:
// - there is an end of packet in the fifo
// - the fifo has more than TX_OUT_FIFO_READ_WM entries
// stop reading when:
// - fifo is empty
// - last end of packet left the fifo

always @(posedge clk_txmac or posedge reset) begin
    if (reset) 
        tx4to2fifo_rdreq_r <= 0;
    else if ((tx4to2fifo_eop_count > 0) |
        (tx4to2fifo_usedw > TX_OUT_FIFO_READ_WM)) begin
        tx4to2fifo_rdreq_r <= 1;
    end else if ((tx4to2fifo_usedw == 0) |
                 (eop_flag1 & !(|sop1) & tx4to2fifo_rdreq)) begin
        tx4to2fifo_rdreq_r <= 0;
    end
end
assign tx4to2fifo_rdreq = tx4to2fifo_rdreq_r & tx2l_ack & !tx4to2fifo_empty;
// Even though the fifo is not empty the empty flag is asserted - checking
// fifo level instead
assign tx2l_valid      = (tx4to2fifo_usedw > 0) ? tx4to2fifo_rdreq : 1'b0;

wire tx_error1;
assign tx_error1       = tx4to2fifo_q[135];
assign sop1            = tx4to2fifo_q[134:133];
assign eop_flag1       = tx4to2fifo_q[132];
assign eop_pos1        = tx4to2fifo_q[131:128];
assign d1              = tx4to2fifo_q[127:0];

// map little endian to avalon-like mapping
assign tx2l_d          = alt_aeu_40_wide_little_endian2avalon_128(d1);
assign tx2l_sop        = alt_aeu_40_wide_swap2 ({2{tx2l_valid}} & sop1);
assign tx2l_eop_bm     = alt_aeu_40_wide_swap16({16{(eop_flag1 & tx2l_valid)}} &
                                alt_aeu_40_wide_decode4to16(eop_pos1));

assign tx2l_eop[0]        = |tx2l_eop_bm[7:0];
assign tx2l_eop[1]        = |tx2l_eop_bm[15:8];

assign tx2l_error[0]      = |tx2l_eop_bm[7:0]  & tx_error1;
assign tx2l_error[1]      = |tx2l_eop_bm[15:8] & tx_error1;

always @(*) begin
	case(tx2l_eop_bm)		
		16'h0001: tx2l_eop_empty = 6'b000000;
		16'h0002: tx2l_eop_empty = 6'b000001;
		16'h0004: tx2l_eop_empty = 6'b000010;
		16'h0008: tx2l_eop_empty = 6'b000011;
		16'h0010: tx2l_eop_empty = 6'b000100;
		16'h0020: tx2l_eop_empty = 6'b000101;
		16'h0040: tx2l_eop_empty = 6'b000110;
		16'h0080: tx2l_eop_empty = 6'b000111;
		16'h0100: tx2l_eop_empty = 6'b000000;
		16'h0200: tx2l_eop_empty = 6'b001000;
		16'h0400: tx2l_eop_empty = 6'b010000;
		16'h0800: tx2l_eop_empty = 6'b011000;
		16'h1000: tx2l_eop_empty = 6'b100000;
		16'h2000: tx2l_eop_empty = 6'b101000;
		16'h4000: tx2l_eop_empty = 6'b110000;
		16'h8000: tx2l_eop_empty = 6'b111000;
		default tx2l_eop_empty = 6'b000000;
	endcase
end


endmodule
