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


// $Id: //acds/rel/18.1/ip/merlin/altera_merlin_router/altera_merlin_router.sv.terp#1 $
// $Revision: #1 $
// $Date: 2018/07/29 $

// -------------------------------------------------------
// Merlin Router
//
// Asserts the appropriate one-hot encoded channel based on 
// either (a) the address or (b) the dest id. The DECODER_TYPE
// parameter controls this behaviour. 0 means address decoder,
// 1 means dest id decoder.
//
// In the case of (a), it also sets the destination id.
// -------------------------------------------------------

`timescale 1 ns / 1 ns

module address_decode_altera_merlin_router_181_dqij2zy_default_decode
  #(
     parameter DEFAULT_CHANNEL = 0,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 12 
   )
  (output [105 - 100 : 0] default_destination_id,
   output [60-1 : 0] default_wr_channel,
   output [60-1 : 0] default_rd_channel,
   output [60-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[105 - 100 : 0];

  generate
    if (DEFAULT_CHANNEL == -1) begin : no_default_channel_assignment
      assign default_src_channel = '0;
    end
    else begin : default_channel_assignment
      assign default_src_channel = 60'b1 << DEFAULT_CHANNEL;
    end
  endgenerate

  generate
    if (DEFAULT_RD_CHANNEL == -1) begin : no_default_rw_channel_assignment
      assign default_wr_channel = '0;
      assign default_rd_channel = '0;
    end
    else begin : default_rw_channel_assignment
      assign default_wr_channel = 60'b1 << DEFAULT_WR_CHANNEL;
      assign default_rd_channel = 60'b1 << DEFAULT_RD_CHANNEL;
    end
  endgenerate

endmodule


module address_decode_altera_merlin_router_181_dqij2zy
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                       sink_valid,
    input  [128-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output                          src_valid,
    output reg [128-1    : 0] src_data,
    output reg [60-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    // -------------------------------------------------------
    // Local parameters and variables
    // -------------------------------------------------------
    localparam PKT_ADDR_H = 67;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 105;
    localparam PKT_DEST_ID_L = 100;
    localparam PKT_PROTECTION_H = 109;
    localparam PKT_PROTECTION_L = 107;
    localparam ST_DATA_W = 128;
    localparam ST_CHANNEL_W = 60;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 70;
    localparam PKT_TRANS_READ  = 71;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    // -------------------------------------------------------
    // Figure out the number of bits to mask off for each slave span
    // during address decoding
    // -------------------------------------------------------
    localparam PAD0 = log2ceil(64'h8000 - 64'h0); 
    localparam PAD1 = log2ceil(64'ha000 - 64'h8000); 
    localparam PAD2 = log2ceil(64'h10000 - 64'hc000); 
    localparam PAD3 = log2ceil(64'hd420 - 64'hd400); 
    localparam PAD4 = log2ceil(64'hd620 - 64'hd600); 
    localparam PAD5 = log2ceil(64'h18000 - 64'h10000); 
    localparam PAD6 = log2ceil(64'h1a000 - 64'h18000); 
    localparam PAD7 = log2ceil(64'h20000 - 64'h1c000); 
    localparam PAD8 = log2ceil(64'h1d420 - 64'h1d400); 
    localparam PAD9 = log2ceil(64'h1d620 - 64'h1d600); 
    localparam PAD10 = log2ceil(64'h28000 - 64'h20000); 
    localparam PAD11 = log2ceil(64'h2a000 - 64'h28000); 
    localparam PAD12 = log2ceil(64'h30000 - 64'h2c000); 
    localparam PAD13 = log2ceil(64'h2d420 - 64'h2d400); 
    localparam PAD14 = log2ceil(64'h2d620 - 64'h2d600); 
    localparam PAD15 = log2ceil(64'h38000 - 64'h30000); 
    localparam PAD16 = log2ceil(64'h3a000 - 64'h38000); 
    localparam PAD17 = log2ceil(64'h40000 - 64'h3c000); 
    localparam PAD18 = log2ceil(64'h3d420 - 64'h3d400); 
    localparam PAD19 = log2ceil(64'h3d620 - 64'h3d600); 
    localparam PAD20 = log2ceil(64'h48000 - 64'h40000); 
    localparam PAD21 = log2ceil(64'h4a000 - 64'h48000); 
    localparam PAD22 = log2ceil(64'h50000 - 64'h4c000); 
    localparam PAD23 = log2ceil(64'h4d420 - 64'h4d400); 
    localparam PAD24 = log2ceil(64'h4d620 - 64'h4d600); 
    localparam PAD25 = log2ceil(64'h58000 - 64'h50000); 
    localparam PAD26 = log2ceil(64'h5a000 - 64'h58000); 
    localparam PAD27 = log2ceil(64'h60000 - 64'h5c000); 
    localparam PAD28 = log2ceil(64'h5d420 - 64'h5d400); 
    localparam PAD29 = log2ceil(64'h5d620 - 64'h5d600); 
    localparam PAD30 = log2ceil(64'h68000 - 64'h60000); 
    localparam PAD31 = log2ceil(64'h6a000 - 64'h68000); 
    localparam PAD32 = log2ceil(64'h70000 - 64'h6c000); 
    localparam PAD33 = log2ceil(64'h6d420 - 64'h6d400); 
    localparam PAD34 = log2ceil(64'h6d620 - 64'h6d600); 
    localparam PAD35 = log2ceil(64'h78000 - 64'h70000); 
    localparam PAD36 = log2ceil(64'h7a000 - 64'h78000); 
    localparam PAD37 = log2ceil(64'h80000 - 64'h7c000); 
    localparam PAD38 = log2ceil(64'h7d420 - 64'h7d400); 
    localparam PAD39 = log2ceil(64'h7d620 - 64'h7d600); 
    localparam PAD40 = log2ceil(64'h88000 - 64'h80000); 
    localparam PAD41 = log2ceil(64'h8a000 - 64'h88000); 
    localparam PAD42 = log2ceil(64'h90000 - 64'h8c000); 
    localparam PAD43 = log2ceil(64'h8d420 - 64'h8d400); 
    localparam PAD44 = log2ceil(64'h8d620 - 64'h8d600); 
    localparam PAD45 = log2ceil(64'h98000 - 64'h90000); 
    localparam PAD46 = log2ceil(64'h9a000 - 64'h98000); 
    localparam PAD47 = log2ceil(64'ha0000 - 64'h9c000); 
    localparam PAD48 = log2ceil(64'h9d420 - 64'h9d400); 
    localparam PAD49 = log2ceil(64'h9d620 - 64'h9d600); 
    localparam PAD50 = log2ceil(64'ha8000 - 64'ha0000); 
    localparam PAD51 = log2ceil(64'haa000 - 64'ha8000); 
    localparam PAD52 = log2ceil(64'hb0000 - 64'hac000); 
    localparam PAD53 = log2ceil(64'had420 - 64'had400); 
    localparam PAD54 = log2ceil(64'had620 - 64'had600); 
    localparam PAD55 = log2ceil(64'hb8000 - 64'hb0000); 
    localparam PAD56 = log2ceil(64'hba000 - 64'hb8000); 
    localparam PAD57 = log2ceil(64'hc0000 - 64'hbc000); 
    localparam PAD58 = log2ceil(64'hbd420 - 64'hbd400); 
    localparam PAD59 = log2ceil(64'hbd620 - 64'hbd600); 
    // -------------------------------------------------------
    // Work out which address bits are significant based on the
    // address range of the slaves. If the required width is too
    // large or too small, we use the address field width instead.
    // -------------------------------------------------------
    localparam ADDR_RANGE = 64'hc0000;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam RG = RANGE_ADDR_WIDTH-1;
    localparam REAL_ADDRESS_RANGE = OPTIMIZED_ADDR_H - PKT_ADDR_L;

      reg [PKT_ADDR_W-1 : 0] address;
      always @* begin
        address = {PKT_ADDR_W{1'b0}};
        address [REAL_ADDRESS_RANGE:0] = sink_data[OPTIMIZED_ADDR_H : PKT_ADDR_L];
      end   

    // -------------------------------------------------------
    // Pass almost everything through, untouched
    // -------------------------------------------------------
    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;
    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [60-1 : 0] default_src_channel;






    address_decode_altera_merlin_router_181_dqij2zy_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

        // --------------------------------------------------
        // Address Decoder
        // Sets the channel and destination ID based on the address
        // --------------------------------------------------

    // ( 0x0 .. 0x8000 )
    if ( {address[RG:PAD0],{PAD0{1'b0}}} == 20'h0   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000000000000000001;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 12;
    end

    // ( 0x8000 .. 0xa000 )
    if ( {address[RG:PAD1],{PAD1{1'b0}}} == 20'h8000   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000000000000000010;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 24;
    end

    // ( 0xc000 .. 0x10000 )
    if ( {address[RG:PAD2],{PAD2{1'b0}}} == 20'hc000   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000000000000010000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
    end

    // ( 0xd400 .. 0xd420 )
    if ( {address[RG:PAD3],{PAD3{1'b0}}} == 20'hd400   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000000000000001000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 36;
    end

    // ( 0xd600 .. 0xd620 )
    if ( {address[RG:PAD4],{PAD4{1'b0}}} == 20'hd600   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000000000000000100;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 48;
    end

    // ( 0x10000 .. 0x18000 )
    if ( {address[RG:PAD5],{PAD5{1'b0}}} == 20'h10000   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000000000000100000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 15;
    end

    // ( 0x18000 .. 0x1a000 )
    if ( {address[RG:PAD6],{PAD6{1'b0}}} == 20'h18000   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000000000001000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 27;
    end

    // ( 0x1c000 .. 0x20000 )
    if ( {address[RG:PAD7],{PAD7{1'b0}}} == 20'h1c000   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000000001000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 3;
    end

    // ( 0x1d400 .. 0x1d420 )
    if ( {address[RG:PAD8],{PAD8{1'b0}}} == 20'h1d400   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000000000010000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 39;
    end

    // ( 0x1d600 .. 0x1d620 )
    if ( {address[RG:PAD9],{PAD9{1'b0}}} == 20'h1d600   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000000000100000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 51;
    end

    // ( 0x20000 .. 0x28000 )
    if ( {address[RG:PAD10],{PAD10{1'b0}}} == 20'h20000   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000000010000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 16;
    end

    // ( 0x28000 .. 0x2a000 )
    if ( {address[RG:PAD11],{PAD11{1'b0}}} == 20'h28000   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000000100000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 28;
    end

    // ( 0x2c000 .. 0x30000 )
    if ( {address[RG:PAD12],{PAD12{1'b0}}} == 20'h2c000   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000100000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 4;
    end

    // ( 0x2d400 .. 0x2d420 )
    if ( {address[RG:PAD13],{PAD13{1'b0}}} == 20'h2d400   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000001000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 40;
    end

    // ( 0x2d600 .. 0x2d620 )
    if ( {address[RG:PAD14],{PAD14{1'b0}}} == 20'h2d600   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000000010000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 52;
    end

    // ( 0x30000 .. 0x38000 )
    if ( {address[RG:PAD15],{PAD15{1'b0}}} == 20'h30000   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000001000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 17;
    end

    // ( 0x38000 .. 0x3a000 )
    if ( {address[RG:PAD16],{PAD16{1'b0}}} == 20'h38000   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000010000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 29;
    end

    // ( 0x3c000 .. 0x40000 )
    if ( {address[RG:PAD17],{PAD17{1'b0}}} == 20'h3c000   ) begin
            src_channel = 60'b000000000000000000000000000000000000000010000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 5;
    end

    // ( 0x3d400 .. 0x3d420 )
    if ( {address[RG:PAD18],{PAD18{1'b0}}} == 20'h3d400   ) begin
            src_channel = 60'b000000000000000000000000000000000000000000100000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 41;
    end

    // ( 0x3d600 .. 0x3d620 )
    if ( {address[RG:PAD19],{PAD19{1'b0}}} == 20'h3d600   ) begin
            src_channel = 60'b000000000000000000000000000000000000000001000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 53;
    end

    // ( 0x40000 .. 0x48000 )
    if ( {address[RG:PAD20],{PAD20{1'b0}}} == 20'h40000   ) begin
            src_channel = 60'b000000000000000000000000000000000000000100000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 18;
    end

    // ( 0x48000 .. 0x4a000 )
    if ( {address[RG:PAD21],{PAD21{1'b0}}} == 20'h48000   ) begin
            src_channel = 60'b000000000000000000000000000000000000001000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 30;
    end

    // ( 0x4c000 .. 0x50000 )
    if ( {address[RG:PAD22],{PAD22{1'b0}}} == 20'h4c000   ) begin
            src_channel = 60'b000000000000000000000000000000000001000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 6;
    end

    // ( 0x4d400 .. 0x4d420 )
    if ( {address[RG:PAD23],{PAD23{1'b0}}} == 20'h4d400   ) begin
            src_channel = 60'b000000000000000000000000000000000000010000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 42;
    end

    // ( 0x4d600 .. 0x4d620 )
    if ( {address[RG:PAD24],{PAD24{1'b0}}} == 20'h4d600   ) begin
            src_channel = 60'b000000000000000000000000000000000000100000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 54;
    end

    // ( 0x50000 .. 0x58000 )
    if ( {address[RG:PAD25],{PAD25{1'b0}}} == 20'h50000   ) begin
            src_channel = 60'b000000000000000000000000000000000010000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 19;
    end

    // ( 0x58000 .. 0x5a000 )
    if ( {address[RG:PAD26],{PAD26{1'b0}}} == 20'h58000   ) begin
            src_channel = 60'b000000000000000000000000000000000100000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 31;
    end

    // ( 0x5c000 .. 0x60000 )
    if ( {address[RG:PAD27],{PAD27{1'b0}}} == 20'h5c000   ) begin
            src_channel = 60'b000000000000000000000000000000100000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 7;
    end

    // ( 0x5d400 .. 0x5d420 )
    if ( {address[RG:PAD28],{PAD28{1'b0}}} == 20'h5d400   ) begin
            src_channel = 60'b000000000000000000000000000000001000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 43;
    end

    // ( 0x5d600 .. 0x5d620 )
    if ( {address[RG:PAD29],{PAD29{1'b0}}} == 20'h5d600   ) begin
            src_channel = 60'b000000000000000000000000000000010000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 55;
    end

    // ( 0x60000 .. 0x68000 )
    if ( {address[RG:PAD30],{PAD30{1'b0}}} == 20'h60000   ) begin
            src_channel = 60'b000000000000000000000000000001000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 20;
    end

    // ( 0x68000 .. 0x6a000 )
    if ( {address[RG:PAD31],{PAD31{1'b0}}} == 20'h68000   ) begin
            src_channel = 60'b000000000000000000000000000010000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 32;
    end

    // ( 0x6c000 .. 0x70000 )
    if ( {address[RG:PAD32],{PAD32{1'b0}}} == 20'h6c000   ) begin
            src_channel = 60'b000000000000000000000000010000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 8;
    end

    // ( 0x6d400 .. 0x6d420 )
    if ( {address[RG:PAD33],{PAD33{1'b0}}} == 20'h6d400   ) begin
            src_channel = 60'b000000000000000000000000000100000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 44;
    end

    // ( 0x6d600 .. 0x6d620 )
    if ( {address[RG:PAD34],{PAD34{1'b0}}} == 20'h6d600   ) begin
            src_channel = 60'b000000000000000000000000001000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 56;
    end

    // ( 0x70000 .. 0x78000 )
    if ( {address[RG:PAD35],{PAD35{1'b0}}} == 20'h70000   ) begin
            src_channel = 60'b000000000000000000000000100000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 21;
    end

    // ( 0x78000 .. 0x7a000 )
    if ( {address[RG:PAD36],{PAD36{1'b0}}} == 20'h78000   ) begin
            src_channel = 60'b000000000000000000000001000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 33;
    end

    // ( 0x7c000 .. 0x80000 )
    if ( {address[RG:PAD37],{PAD37{1'b0}}} == 20'h7c000   ) begin
            src_channel = 60'b000000000000000000001000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 9;
    end

    // ( 0x7d400 .. 0x7d420 )
    if ( {address[RG:PAD38],{PAD38{1'b0}}} == 20'h7d400   ) begin
            src_channel = 60'b000000000000000000000010000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 45;
    end

    // ( 0x7d600 .. 0x7d620 )
    if ( {address[RG:PAD39],{PAD39{1'b0}}} == 20'h7d600   ) begin
            src_channel = 60'b000000000000000000000100000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 57;
    end

    // ( 0x80000 .. 0x88000 )
    if ( {address[RG:PAD40],{PAD40{1'b0}}} == 20'h80000   ) begin
            src_channel = 60'b000000000000000000010000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 22;
    end

    // ( 0x88000 .. 0x8a000 )
    if ( {address[RG:PAD41],{PAD41{1'b0}}} == 20'h88000   ) begin
            src_channel = 60'b000000000000000000100000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 34;
    end

    // ( 0x8c000 .. 0x90000 )
    if ( {address[RG:PAD42],{PAD42{1'b0}}} == 20'h8c000   ) begin
            src_channel = 60'b000000000000000100000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 10;
    end

    // ( 0x8d400 .. 0x8d420 )
    if ( {address[RG:PAD43],{PAD43{1'b0}}} == 20'h8d400   ) begin
            src_channel = 60'b000000000000000001000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 46;
    end

    // ( 0x8d600 .. 0x8d620 )
    if ( {address[RG:PAD44],{PAD44{1'b0}}} == 20'h8d600   ) begin
            src_channel = 60'b000000000000000010000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 58;
    end

    // ( 0x90000 .. 0x98000 )
    if ( {address[RG:PAD45],{PAD45{1'b0}}} == 20'h90000   ) begin
            src_channel = 60'b000000000000001000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 23;
    end

    // ( 0x98000 .. 0x9a000 )
    if ( {address[RG:PAD46],{PAD46{1'b0}}} == 20'h98000   ) begin
            src_channel = 60'b000000000000010000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 35;
    end

    // ( 0x9c000 .. 0xa0000 )
    if ( {address[RG:PAD47],{PAD47{1'b0}}} == 20'h9c000   ) begin
            src_channel = 60'b000000000010000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 11;
    end

    // ( 0x9d400 .. 0x9d420 )
    if ( {address[RG:PAD48],{PAD48{1'b0}}} == 20'h9d400   ) begin
            src_channel = 60'b000000000000100000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 47;
    end

    // ( 0x9d600 .. 0x9d620 )
    if ( {address[RG:PAD49],{PAD49{1'b0}}} == 20'h9d600   ) begin
            src_channel = 60'b000000000001000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 59;
    end

    // ( 0xa0000 .. 0xa8000 )
    if ( {address[RG:PAD50],{PAD50{1'b0}}} == 20'ha0000   ) begin
            src_channel = 60'b000000000100000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 13;
    end

    // ( 0xa8000 .. 0xaa000 )
    if ( {address[RG:PAD51],{PAD51{1'b0}}} == 20'ha8000   ) begin
            src_channel = 60'b000000001000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 25;
    end

    // ( 0xac000 .. 0xb0000 )
    if ( {address[RG:PAD52],{PAD52{1'b0}}} == 20'hac000   ) begin
            src_channel = 60'b000001000000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 1;
    end

    // ( 0xad400 .. 0xad420 )
    if ( {address[RG:PAD53],{PAD53{1'b0}}} == 20'had400   ) begin
            src_channel = 60'b000000010000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 37;
    end

    // ( 0xad600 .. 0xad620 )
    if ( {address[RG:PAD54],{PAD54{1'b0}}} == 20'had600   ) begin
            src_channel = 60'b000000100000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 49;
    end

    // ( 0xb0000 .. 0xb8000 )
    if ( {address[RG:PAD55],{PAD55{1'b0}}} == 20'hb0000   ) begin
            src_channel = 60'b000010000000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 14;
    end

    // ( 0xb8000 .. 0xba000 )
    if ( {address[RG:PAD56],{PAD56{1'b0}}} == 20'hb8000   ) begin
            src_channel = 60'b000100000000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 26;
    end

    // ( 0xbc000 .. 0xc0000 )
    if ( {address[RG:PAD57],{PAD57{1'b0}}} == 20'hbc000   ) begin
            src_channel = 60'b100000000000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 2;
    end

    // ( 0xbd400 .. 0xbd420 )
    if ( {address[RG:PAD58],{PAD58{1'b0}}} == 20'hbd400   ) begin
            src_channel = 60'b001000000000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 38;
    end

    // ( 0xbd600 .. 0xbd620 )
    if ( {address[RG:PAD59],{PAD59{1'b0}}} == 20'hbd600   ) begin
            src_channel = 60'b010000000000000000000000000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 50;
    end

end


    // --------------------------------------------------
    // Ceil(log2()) function
    // --------------------------------------------------
    function integer log2ceil;
        input reg[65:0] val;
        reg [65:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule


