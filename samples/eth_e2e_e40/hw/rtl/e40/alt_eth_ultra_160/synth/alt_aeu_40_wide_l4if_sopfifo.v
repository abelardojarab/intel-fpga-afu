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
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/ast/alt_aeu_40_wide_l4if_sopfifo.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
// ___________________________________________________________________________
//
///////////////////////////////////////////////////////////////////////////////
//
// Description: fast 5 bit x 4 fifo
//
// Authors:     ishimony
//
///////////////////////////////////////////////////////////////////////////////

// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

// timing optimizations:
// 36: remove read underflow protection, seperate ptr logic

module alt_aeu_40_wide_l4if_sopfifo(
    reset, clock, data, rdreq, wrreq, q, usedw
); // module alt_aeu_40_wide_l4if_sopfifo
parameter WIDTH     = 3;
parameter DEPTH     = 4;
parameter LOG2DEPTH = 2;

input                   reset;
input                   clock;
input   [WIDTH-1:0]     data;
input                   rdreq;
input                   wrreq;
output  [WIDTH-1:0]     q;
output  [LOG2DEPTH-1:0] usedw;

//--- port types
wire                    clock;
wire    [WIDTH-1:0]     data;
wire                    rdreq;
wire                    wrreq;
wire    [WIDTH-1:0]     q;
reg     [LOG2DEPTH-1:0] usedw = 0;

//--- local
reg     [LOG2DEPTH-1:0] wptr  = 0;
reg     [LOG2DEPTH-1:0] rptr  = 0;
//1 reg [WIDTH-1:0]     array [DEPTH-1:0];
reg   [WIDTH*DEPTH-1:0] array = 0;

// register output transparently -- ktaylor 2015-06-01
reg     [WIDTH-1:0]     dout_r = 0;
reg     [LOG2DEPTH-1:0] rptrp1= 1; // rptr plus one

wire dowrite = wrreq & (usedw < DEPTH);

//--- main
always @(posedge clock) begin
    if (dowrite) begin
//1     array[wptr] <= data;
        array[wptr*WIDTH +: WIDTH] <= data;
    end
end
always @(posedge clock or posedge reset) begin
    if (reset) wptr <= 0;
    else if (dowrite) begin
        wptr        <= wptr + 1'b1;
    end
end
always @(posedge clock or posedge reset) begin
    if (reset) begin
        rptr <= 0;
        rptrp1 <= 1;
    end else if (rdreq) begin
        rptr   <= rptrp1;
        rptrp1 <= rptrp1 + 1'b1;
    end
end
always @(posedge clock or posedge reset) begin
    if (reset) usedw <= 0;
    else if (dowrite & !rdreq) begin
        usedw <= usedw + 1'b1; 
    end else if (!dowrite & rdreq) begin
        usedw <= usedw - 1'b1; 
    end
end

// do array lookup one cycle ahead (ktaylor 2015-06-01)
always @(posedge clock) begin
    if(rdreq & dowrite & (rptrp1 == wptr))   dout_r <= data;
    else if(rdreq)                           dout_r <= array[rptrp1*WIDTH +: WIDTH];
    else if(dowrite & (rptr == wptr))        dout_r <= data;
    else                                     dout_r <= array[rptr*WIDTH +: WIDTH];
end

//1 assign q = array[rptr];
assign q = dout_r;

endmodule // alt_aeu_40_wide_l4if_sopfifo

