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


`timescale 1 ps / 1 ps
// ______________________________________________________________________________
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/mac/alt_aeu_40_mac_tx_2.v#1 $
// $Revision: #1 $
// $Date: 2016/07/07 $
// $Author: yhu $
// ______________________________________________________________________________

// to cut down pins for testing -
// set_global_assignment -name SEARCH_PATH "d:/hsl11"
// set_instance_assignment -name VIRTUAL_PIN ON -to mii_d
// set_instance_assignment -name VIRTUAL_PIN ON -to din

module alt_aeu_40_mac_tx_2 #(
        parameter SYNOPT_PTP = 0,
                parameter PTP_FP_WIDTH = 16, // width of fingerprint, ptp parameter
                parameter PTP_TS_WIDTH = 96, 
        parameter PTP_LATENCY = 52,
                parameter SYNOPT_TOD_FMT = 0,
        parameter SYNOPT_AVG_IPG = 12,
        parameter EN_LINK_FAULT = 0,
        parameter EN_PREAMBLE_PASS_THROUGH = 1,
        parameter EN_TX_CRC_INS = 1,
        parameter EN_DIC = 1,
        parameter SYNOPT_TXSTATS = 1, 
        parameter SYNOPT_TXHPROC = 1, 
        parameter WIDTH = 64,
        parameter WORDS = 2,
        parameter TARGET_CHIP = 2,
        parameter REDUCE_CRC_LAT = 1'b1,  // lower CRC latency (at expense of timing
        parameter BASE_TXMAC = 0,
        parameter BASE_TXSTAT = 1,
        parameter REVID = 32'h04142014,
        parameter ERRORBITWIDTH  = 11,  
        parameter STATSBITWIDTH  = 32   
  )(
    input sclr,  //from ~tx_online
    input clk,
    input [WORDS-1:0] din_sop,          // word contains first data (on leftmost byte)
    input [WORDS-1:0] din_eop,          // byte position of last data
    input [WORDS-1:0] din_error,      
    input [WORDS-1:0] din_idle,         // bytes between EOP and SOP
    input [3*WORDS-1:0] din_eop_empty,  // byte position of last data
    input [WORDS*WIDTH-1:0] din,        // data, read left to right
    output req,
    input  pre_din_am,
    
    output wire [WORDS*WIDTH-1:0] tx_mii_d,
    output wire [8*WORDS-1:0] tx_mii_c,
    output wire tx_mii_valid,
    output o_bus_error,

    input  wire reset_csr,// global reset, async, no domain
    input  wire clk_csr,  // 100 MHz
    output wire serif_slave_dout,
    input  wire serif_slave_din,
    output wire[STATSBITWIDTH-1:0] out_tx_stats,
    output wire[15:0] tx_inc_octetsOK,
    output wire tx_inc_octetsOK_valid,

    output wire tx_crc_ins_en,

    // ptp related inouts -- begin
//    input [95:0] tod_txmac_in,
  input [95:0] tod_96b_txmac_in,
  input [63:0] tod_64b_txmac_in,
   input [19:0]         txmclk_period,
        input [18:0] tx_asym_delay,
        input [31:0] tx_pma_delay,
        input cust_mode,
//    input ptp_v2,
//    input ptp_s2,
    input [31:0] ext_lat,
    input          din_ptp_dbg_adp,
    input din_sop_adp,
//    input din_ptp_adp,
//    input [1:0] din_overwrite_adp,
//    input [15:0] din_offset_adp,
//    input din_zero_tcp_adp,
    input din_ptp_asm_adp,
//    input [15:0] din_zero_offset_adp,
    output ts_out_cust_asm,

    input [95:0] tod_txmclk,
//    input [95:0] latency_ahead,
//    input [95:0] latency_adj,

    input [95:0] tod_cust_in,
    output [95:0] tod_exit_cust,
    output [95:0] ts_out_cust,
    // ptp related inouts -- end

        input ts_out_req_adp,
        input [PTP_FP_WIDTH-1:0] fp_out_req_adp,
        input ins_ts_adp,
        input ins_ts_format_adp,
        input tx_asym_adp,
        input upd_corr_adp,
        input [95:0] ing_ts_96_adp,
        input [63:0] ing_ts_64_adp,
        input corr_format_adp,
        input chk_sum_zero_adp,
        input chk_sum_upd_adp,
        input [15:0] ts_offset_adp,
        input [15:0] corr_offset_adp,
        input [15:0] chk_sum_zero_offset_adp,
        input [15:0] chk_sum_upd_offset_adp,
  output [160-1:0] ts_exit,
  output ts_exit_valid,
  output [PTP_FP_WIDTH-1:0] fp_out,

    output wire cfg_unidirectional_en,
    output wire cfg_en_link_fault_gen,
    input  wire remote_fault_status,
    input  wire local_fault_status
  );

wire [7:0]  num_idle_rm;
wire cfg_tx_crc_ins_en_4debug;
generate 
   if (EN_TX_CRC_INS)  assign tx_crc_ins_en  = cfg_tx_crc_ins_en_4debug;
   else                assign tx_crc_ins_en  = 1'b0;
endgenerate

reg [WORDS*WIDTH-1:0] mii_d = 0;
reg [8*WORDS-1:0]     mii_c = 0;
reg                   mii_valid_reg = 0;

initial mii_d = 0;
initial mii_c = 0;
initial mii_valid_reg = 0;

genvar i, j;

//reg [40:0] am_hist=0;
reg [76:0] am_hist=0;
reg  [5:0] enable = 0;
reg  enable_r = 0;
reg  enable_r2 = 0;
wire [WORDS*WIDTH-1:0] dbuf_d;
reg  [WORDS*WIDTH-1:0] dbuf_q=0;
wire [WORDS-1:0] dbuf_req;
wire [WORDS-1:0] dbuf_full;
wire [WORDS-1:0] dbuf_empty;
wire [WORDS-1:0] tag_is_data;
reg  [WORDS-1:0] tag_is_data_r=0;
reg  [WORDS*WIDTH-1:0] dout_to_mlab=0;
wire [WORDS*WIDTH-1:0] dout_to_mlab_raw;
reg  [WORDS*WIDTH-1:0] dout_to_crc=0;
reg  [WORDS*8-1:0] cout_to_mlab=0;
wire [WORDS*8-1:0] cout_to_mlab_raw;
wire [3*WORDS-1:0] tags, tags_to_preamble, tags_to_gap, tags_to_dic, tags_rev;

generate
    for (i=0; i<WORDS; i=i+1) begin : dbuf

        wire [WIDTH-1:0] local_q;
        wire [15:0] extra_16;
        wire        wreq = req && !din_idle[i];
        wire        rreq = enable[i] &&
                           ((tags[ 5]==1 && tags[ 4:3]==1-i) ||
                            (tags[ 2]==1 && tags[ 1:0]==1-i));

        scfifo_mlab scm (
                .clk(clk),
                .sclr(sclr),

                .wdata({16'h0,din[(i+1)*WIDTH-1:i*WIDTH]}),
                .wreq(wreq),
                .full(), 

                .rdata({extra_16, local_q}),
                .rreq(rreq),
                .empty(),

                .used()
        );
        defparam scm .TARGET_CHIP = TARGET_CHIP;
        defparam scm .WIDTH = 80;
        defparam scm .PREVENT_OVERFLOW = 1'b0;
        defparam scm .PREVENT_UNDERFLOW = 1'b0;
        defparam scm .ADDR_WIDTH = 4;

        assign dbuf_d[(i+1)*WIDTH-1:i*WIDTH] = local_q[WIDTH-1:0];
    end
endgenerate





////////////////////////////////////////////////////
// seperate SOPs to be minimum 10 words
// generate tags for data path
////////////////////////////////////////////////////
reg  [3*WORDS-1:0] tags_r=0;
wire [3*WORDS-1:0] tag_eop_empty, eop_empty_to_preamble, eop_empty_to_gap, eop_empty_to_dic, tag_eop_empty_rev;
wire [3*WORDS-1:0] tag_data_empty, data_empty_to_preamble, data_empty_to_gap, data_empty_to_dic, tag_data_empty_rev;
wire [WORDS-1:0]   tag_sop, sop_to_preamble, sop_to_gap, sop_to_dic, tag_sop_rev;
wire [WORDS-1:0]   eop_to_preamble, eop_to_gap, eop_to_dic, tag_eop_rev;
reg  [WORDS-1:0]   tag_sop_r = 0;
wire [WORDS-1:0]   tag_dsop;
reg [8*WORDS-1:0] tag_eop_pos_r = 0, tag_eop_pos_r2 = 0;

wire [WORDS-1:0]   sop_rev = {din_sop[0] && !din_idle[0] && !din_eop[0], din_sop[1] && !din_idle[1] && !din_eop[1]};
wire [WORDS-1:0]   eop_rev = {din_eop[0] && !din_idle[0] && !din_sop[0], din_eop[1] && !din_idle[1] && !din_sop[1]};
wire [WORDS-1:0]   idle_rev = {din_idle[0], din_idle[1]};
wire [3*WORDS-1:0] eop_empty_rev = {din_eop_empty[2:0], din_eop_empty[5:3]};
wire               wait_req_from_preamble, wait_req_from_gap, wait_req_from_dic;
wire               mii_valid;

///////////////////////////////
// TX Error Insertion logic

wire [WORDS-1:0] tag_eop;
wire [WORDS-1:0] eop = {eop_rev[0], eop_rev[1] }; 
wire error;

alt_aeu_40_tx_error    txer (
    .clk        (clk),
    .sclr       (sclr),
    .din_eop    (eop),
    .din_error  (din_error),
    .req        (req),
    .tag_eop    (tag_eop),
    .enable     (enable[5]),
    .error      (error)
);
defparam    txer .WORDS = WORDS;
defparam    txer .WIDTH = WIDTH;
defparam    txer .TARGET_CHIP = TARGET_CHIP;

///////////////////////////////

ectrl_tag_2  etag2(
        .clk(clk),
        .sclr(sclr),

        .ena(enable[4] && !wait_req_from_preamble && !wait_req_from_gap && !wait_req_from_dic), 
        .req(req),
        .i_sop(sop_rev), // lsbit first, sop marks the preamble word
        .i_eop(eop_rev),
        .i_idle(idle_rev),
        .i_eop_empty(eop_empty_rev),
        .i_bus_error(o_bus_error),

        .o_tags(tags_to_preamble),
                // 111,110,101,100 data words
                // 000 idles
                // 001 padding
        .o_sop(sop_to_preamble), // lsbit first
        .o_eop(eop_to_preamble), // 
        .o_data_empty(data_empty_to_preamble), 
        .o_eop_empty(eop_empty_to_preamble) // modified if necessary for padding
);

defparam etag2 . EN_PREAMBLE_PASS_THROUGH = EN_PREAMBLE_PASS_THROUGH;

generate
   if (EN_PREAMBLE_PASS_THROUGH) begin
      assign tags_to_gap       = tags_to_preamble;
      assign sop_to_gap        = sop_to_preamble;
      assign eop_to_gap        = eop_to_preamble;
      assign data_empty_to_gap = data_empty_to_preamble;
      assign eop_empty_to_gap  = eop_empty_to_preamble;
      assign wait_req_from_preamble = 1'b0;
   end
   else begin
      ectrl_preamble_2 epreamble(
        .clk(clk),
        .sclr(sclr),

        .i_ena(enable[5] && !wait_req_from_dic && !wait_req_from_gap),
        .i_sop(sop_to_preamble), // lsbit first, sop marks the preamble word
        .i_eop(eop_to_preamble),
        .i_eop_empty(eop_empty_to_preamble),
        .i_data_empty(data_empty_to_preamble),
        .i_tags(tags_to_preamble),

        .o_wait_req(wait_req_from_preamble),
        .o_tags(tags_to_gap),
                // 111,110,101,100 data words
                // 000 idles
                // 001 padding
        .o_sop(sop_to_gap), // lsbit first
        .o_eop(eop_to_gap),
        .o_eop_empty(eop_empty_to_gap),
        .o_data_empty(data_empty_to_gap)
      );
   end
   
endgenerate

ectrl_gap_2 #(
       .SYNOPT_AVG_IPG (SYNOPT_AVG_IPG)
) egap (
        .clk(clk),
        .sclr(sclr),

                .tx_crc_ins_en(tx_crc_ins_en),
        .i_ena(enable[4] && !wait_req_from_dic),
        .i_sop(sop_to_gap), // lsbit first, sop marks the preamble word
        .i_eop(eop_to_gap),
        .i_eop_empty(eop_empty_to_gap),
        .i_data_empty(data_empty_to_gap),
        .i_tags(tags_to_gap),

        .o_wait_req(wait_req_from_gap),
        .o_tags(tags_to_dic),
                // 111,110,101,100 data words
                // 000 idles
                // 001 padding
        .o_sop(sop_to_dic), // lsbit first
        .o_eop(eop_to_dic),
        .o_eop_empty(eop_empty_to_dic),
        .o_data_empty(data_empty_to_dic)
);


generate
   if (!EN_DIC) begin
        assign tags_rev = tags_to_dic;
        assign tag_sop_rev = sop_to_dic;
        assign tag_eop_rev = eop_to_dic;
        assign tag_eop_empty_rev = eop_empty_to_dic;
        assign tag_data_empty_rev = data_empty_to_dic;
        assign wait_req_from_dic = 1'b0;
   end
   else begin   
   ectrl_dic_2 #(
      .SYNOPT_AVG_IPG (SYNOPT_AVG_IPG)
) edic(
        .clk(clk),
        .sclr(sclr),

        .num_idle_rm(num_idle_rm),
        .tx_crc_ins_en(tx_crc_ins_en),
        .i_am(pre_din_am),
        .i_ena(enable[4]),
        .i_sop(sop_to_dic), // lsbit first, sop marks the preamble word
        .i_eop(eop_to_dic),
        .i_eop_empty(eop_empty_to_dic),
        .i_data_empty(data_empty_to_dic),
        .i_tags(tags_to_dic),

        .o_wait_req(wait_req_from_dic),
        .o_tags(tags_rev),
                // 111,110,101,100 data words
                // 000 idles
                // 001 padding
        .o_sop(tag_sop_rev), // lsbit first
        .o_eop(tag_eop_rev),
        .o_eop_empty(tag_eop_empty_rev),
        .o_data_empty(tag_data_empty_rev)
   );
   end
endgenerate

assign tag_sop = {tag_sop_rev[0], tag_sop_rev[1]};
assign tag_eop = {tag_eop_rev[0], tag_eop_rev[1]};
assign tags    = {tags_rev[2:0], tags_rev[5:3]};
assign tag_is_data[1:0] = {tags[2*3-1], tags[1*3-1]}; 
assign tag_data_empty = {tag_data_empty_rev[2:0], tag_data_empty_rev[5:3]};
assign tag_eop_empty = {tag_eop_empty_rev[2:0], tag_eop_empty_rev[5:3]};

wire [8*WORDS-1:0] tag_eop_pos;
wire [8*WORDS-1:0] tag_zero_pos;
reg  [8*WORDS-1:0] tag_zero_pos_r=0;
reg [WORDS-1:0]          tag_dsop_r = 0, tag_dsop_r2 = 0;

always @(posedge clk) begin
     if (enable[5]) begin
        tags_r <= tags;
        tag_sop_r <= tag_sop;
        tag_eop_pos_r  <= tag_eop_pos;
        tag_zero_pos_r <= tag_zero_pos;
        tag_is_data_r <= tag_is_data; 
        tag_dsop_r  <= tag_dsop;
     end
end

// dbuf_q may need another pipe. It's ok for now (473 Mhz)
generate
    for (i=0; i<WORDS; i=i+1) begin : dbuf_mux
        //always @(posedge clk) begin
        always @(*) begin
           dbuf_q[(i+1)*WIDTH-1:i*WIDTH] = tags_r[i*3] ? dbuf_d[WIDTH-1:0] : dbuf_d[2*WIDTH-1:1*WIDTH];
/*
           case(tags_r[i*3])
              1'b1: dbuf_q[(i+1)*WIDTH-1:i*WIDTH] = dbuf_d[WIDTH-1:0];
              1'b0: dbuf_q[(i+1)*WIDTH-1:i*WIDTH] = dbuf_d[2*WIDTH-1:1*WIDTH];
              default:dbuf_q[(i+1)*WIDTH-1:i*WIDTH] = dbuf_d[(i+1)*WIDTH-1:i*WIDTH];
           endcase
*/
        end
    end
endgenerate

////////////////////////////////////////////////////////////////////////
// move sop to the next word to skip preamble for CRC engine 
////////////////////////////////////////////////////////////////////////
assign tag_dsop[1] = tag_sop_r[0];
assign tag_dsop[0] = tag_sop[1];

wire [WORDS*8+5-1:0]   tag_eop_pos_ext;
wire [31:0]       tag_crc_pos;
wire [31:0]       tag_term_pos;
wire [31:0]       tag_idle_pos;

////////////////////////////////////////////////////////////////////////
// decode tag_eop_pos, tag_crc_pos, and tag_term_pos
////////////////////////////////////////////////////////////////////////
generate
        for (i=0; i<WORDS; i=i+1) begin : eop_pos32 
            reg  [7:0]      eop_byte=8'h1;
            always @(*) begin
               case(tag_eop_empty[(i+1)*3-1 : i*3])
                  3'h0 : begin eop_byte = 8'b00000001; end
                  3'h1 : begin eop_byte = 8'b00000010; end
                  3'h2 : begin eop_byte = 8'b00000100; end
                  3'h3 : begin eop_byte = 8'b00001000; end
                  3'h4 : begin eop_byte = 8'b00010000; end
                  3'h5 : begin eop_byte = 8'b00100000; end
                  3'h6 : begin eop_byte = 8'b01000000; end
                  3'h7 : begin eop_byte = 8'b10000000; end
               endcase
            end
            assign tag_eop_pos[(i+1)*8-1: i*8] = tag_eop[i] ? eop_byte[7:0] : 8'h0;
        end
endgenerate

generate
        for (i=0; i<WORDS; i=i+1) begin : zero_pos32 
            reg  [7:0]      zero_byte=0;
            always @(*) begin
               case(tag_data_empty[(i+1)*3-1 : i*3])
                  3'h0 : begin zero_byte = 8'b00000000; end
                  3'h1 : begin zero_byte = 8'b00000001; end
                  3'h2 : begin zero_byte = 8'b00000011; end
                  3'h3 : begin zero_byte = 8'b00000111; end
                  3'h4 : begin zero_byte = 8'b00001111; end
                  3'h5 : begin zero_byte = 8'b00011111; end
                  3'h6 : begin zero_byte = 8'b00111111; end
                  3'h7 : begin zero_byte = 8'b01111111; end
               endcase
            end
            assign tag_zero_pos[(i+1)*8-1: i*8] = zero_byte[7:0];
        end
endgenerate


assign tag_eop_pos_ext = {tag_eop_pos_r[4:0], tag_eop_pos[15:0]};
assign tag_term_pos[15:0] = tx_crc_ins_en ? tag_eop_pos_ext[20:5] : tag_eop_pos_ext[16:1];

generate
        for (i=0; i<WORDS; i=i+1) begin : eop_pos_w
           for (j=0; j<8; j=j+1) begin : eop_pos_b
               assign tag_crc_pos[i*8+j] = tx_crc_ins_en ? |tag_eop_pos_ext[i*8+j+4:i*8+j+1] : 1'b0;
           end
        end
endgenerate

////////////////////////////////////////////////////////////////////////
// Assume at least 6 bytes between frames for 
// 4 byte CRC + TERM + IDLE insertion
////////////////////////////////////////////////////////////////////////

localparam SEL_PREAMBLE      = 3'b100;  // 64'hfb555555555555d5 provided from input
localparam SEL_TERM          = 3'b011;  // 8'hfd
localparam SEL_CRC_OR_PAD    = 3'b010;  // 8'h00
localparam SEL_IDLE          = 3'b001;  // 8'h07
localparam SEL_DATA          = 3'b000;  // DATA

localparam PREAMBLE          = 64'hfb555555555555d5; 

reg  [3*WORDS*8-1:0] sel = 0;

generate
        for (i=0; i<WORDS; i=i+1) begin : sel_w
           for (j=0; j<8; j=j+1) begin : sel_b
               always @(posedge clk) begin
                    if (tag_sop[i])                       sel[(i*8+(j+1))*3-1:(i*8+j)*3] <= SEL_PREAMBLE; 
                    else if (tag_crc_pos[i*8+j])          sel[(i*8+(j+1))*3-1:(i*8+j)*3] <= SEL_CRC_OR_PAD;     
                    else if (tag_term_pos[i*8+j])         sel[(i*8+(j+1))*3-1:(i*8+j)*3] <= SEL_TERM;   
                    else if (tags[(i+1)*3-1:i*3]==3'b000) sel[(i*8+(j+1))*3-1:(i*8+j)*3] <= SEL_IDLE;  
                    else if (tag_idle_pos[i*8+j])         sel[(i*8+(j+1))*3-1:(i*8+j)*3] <= SEL_IDLE;   
                    else if (tags[(i+1)*3-1:i*3]==3'b001) sel[(i*8+(j+1))*3-1:(i*8+j)*3] <= SEL_CRC_OR_PAD;
                    else if (tag_zero_pos[i*8+j])         sel[(i*8+(j+1))*3-1:(i*8+j)*3] <= SEL_CRC_OR_PAD;   
                    else                                  sel[(i*8+(j+1))*3-1:(i*8+j)*3] <= SEL_DATA;   
               end
           end
        end
endgenerate


generate 
        for (i=0; i<WORDS; i=i+1) begin : idle_w
               assign tag_idle_pos[i*8+7]= 1'b0;
               assign tag_idle_pos[i*8+6]= tag_term_pos[i*8+7];
               assign tag_idle_pos[i*8+5]= tag_term_pos[i*8+7] || tag_term_pos[i*8+6];
               assign tag_idle_pos[i*8+4]= tag_term_pos[i*8+7] || tag_term_pos[i*8+6] || tag_term_pos[i*8+5];
               assign tag_idle_pos[i*8+3]= tag_term_pos[i*8+7] || tag_term_pos[i*8+6] || tag_term_pos[i*8+5] || tag_term_pos[i*8+4];
               assign tag_idle_pos[i*8+2]= tag_term_pos[i*8+7] || tag_term_pos[i*8+6] || tag_term_pos[i*8+5] || tag_term_pos[i*8+4] ||
                                           tag_term_pos[i*8+3];
               assign tag_idle_pos[i*8+1]= tag_term_pos[i*8+7] || tag_term_pos[i*8+6] || tag_term_pos[i*8+5] || tag_term_pos[i*8+4] ||
                                           tag_term_pos[i*8+3] || tag_term_pos[i*8+2];
               assign tag_idle_pos[i*8+0]= tag_term_pos[i*8+7] || tag_term_pos[i*8+6] || tag_term_pos[i*8+5] || tag_term_pos[i*8+4] ||
                                           tag_term_pos[i*8+3] || tag_term_pos[i*8+2] || tag_term_pos[i*8+1];
         end
endgenerate


wire [7:0] TERM       = 8'hfd;
wire [7:0] IDLE       = 8'h07;
wire [7:0] CRC_OR_PAD = 8'h00;

reg eop_at_0123=0;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// If eop is at the last 4 bytes of the 32 bytes, crc_out result will be used at the flollowing cycle (too).
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk) begin
      eop_at_0123 <= tag_eop_pos_r[3] || tag_eop_pos_r[2] || tag_eop_pos_r[1] || tag_eop_pos_r[0];
end

generate
        for (i=0; i<WORDS; i=i+1) begin : mx5_w
           for (j=0; j<8; j=j+1) begin : mx5_b
                  mx5r mx5_d(
                       .clk(clk),
                       .din({(EN_PREAMBLE_PASS_THROUGH ? dbuf_q[i*WIDTH+(j+1)*8-1:i*WIDTH + j*8] : PREAMBLE[(j+1)*8-1:j*8]),  // PREAMBLE
                             TERM,                                     // TERM
                             CRC_OR_PAD,                               // CRC or PADDING
                             IDLE,                                     // IDLE
                             dbuf_q[i*WIDTH+(j+1)*8-1:i*WIDTH + j*8]   // DATA
                            }), 
                       .sel(sel[(i*8+(j+1))*3-1:(i*8+j)*3]),
                       .dout(dout_to_mlab_raw[i*WIDTH+(j+1)*8-1:i*WIDTH+j*8])
                  );
                  defparam mx5_d . WIDTH = 8;

                  always @(posedge clk) begin
                        dout_to_crc[i*WIDTH+(j+1)*8-1:i*WIDTH+j*8] <= dbuf_q[i*WIDTH+(j+1)*8-1:i*WIDTH + j*8] & {8{~tag_zero_pos_r[i*8+j]}} & {8{tag_is_data_r[i]}};
                  end

                  // This is to fix the CRC error bug found in HW test.
                  // if the garbage data in enable low cycles happen to be 'hfd
                  // and the control to be 1 (for preamble), 
                  // the efd_match signal will go high unexpectedly.
 
                  //wire preamble_mux_c = (j==7);
                  wire preamble_mux_c = (j==7) && enable_r; 
                  mx5r mx5_c(
                       .clk(clk),
                       .din({preamble_mux_c,  // PREAMBLE
                             1'b1,  // TERM
                             1'b0,  // CRC or PADDING
                             1'b1,  // IDLE
                             1'b0   // DATA
                            }), 
                       .sel(sel[(i*8+(j+1))*3-1:(i*8+j)*3]),
                       .dout(cout_to_mlab_raw[i*8+j])
                  );
                  defparam mx5_c . WIDTH = 1;
            end
         end
endgenerate


/////////////////////////
//TX Error Insertion
reg [1:0]   tag_eop_d1 = 2'b00;
reg         tag_error_a = 1'b0;
wire [1:0]  tag_error;

always @(posedge clk) begin
    tag_eop_d1  <= tag_eop ;
    tag_error_a  <= tag_eop_d1[0] & error;
end

assign tag_error = {tag_error_a, tag_eop_d1[1] & error}   ;


generate
    for (i=0; i<WORDS; i=i+1) begin : terr_mux
        always @(*) begin   
            dout_to_mlab[i*WIDTH+:8] = tag_error[i] ? 8'hFE : dout_to_mlab_raw[i*WIDTH+:8] ;
            cout_to_mlab[i*8] = tag_error[i] ? 1'b1 : cout_to_mlab_raw[i*8] ; 
            dout_to_mlab[(i*WIDTH+8)+:56] = dout_to_mlab_raw[(i*WIDTH+8)+:56] ;
            cout_to_mlab[(i*8+1)+:7] = cout_to_mlab_raw[(i*8+1)+:7] ;
        end
    end

endgenerate 



//assign cout_to_mlab = cout_to_mlab_raw & {(WORDS*8){enable_r2}};
//assign cout_to_mlab = cout_to_mlab_raw;

     // ptp instantiation
  
//     defparam etp.TARGET_CHIP = TARGET_CHIP;
//     defparam etp.SYNOPT_PTP = SYNOPT_PTP;
//     defparam etp.PTP_LATENCY = PTP_LATENCY;
//   defparam etp.EN_LINK_FAULT = EN_LINK_FAULT;
//     defparam etp.PTP_FP_WIDTH = PTP_FP_WIDTH;
//     defparam etp.PTP_TS_WIDTH = PTP_TS_WIDTH;
  
     wire [WORDS*64-1:0] dout_crc_ptp;
     wire [WORDS*64-1:0] dout_mlab_ptp_w;
     reg  [WORDS*64-1:0] dout_mlab_ptp=0;
     wire [19:0]               mac_out_bus_ptp; // other data that needs to be pipelined
     wire [WORDS-1:0]    dout_sops_ptp;
     wire [WORDS*8-1:0]  dout_eop_pos_ptp;
     wire              dout_valid_ptp;
  
     wire [19:0]               mac_in_bus;
  
     assign mac_in_bus = {2'b00,cout_to_mlab,eop_at_0123,enable_r2};
  
     wire              enable_r2_ptp;
     wire [WORDS*8-1:0]  cout_to_mlab_ptp;
     wire              eop_at_0123_ptp;
  
//     wire [WORDS*64-1:0] dout_crc_ptx;
//     wire [WORDS*64-1:0] dout_mlab_ptx_w;
//     wire [WORDS*64-1:0]  dout_mlab_ptx;
//     wire [39:0]               mac_out_bus_ptx; // other data that needs to be pipelined
//     wire [WORDS-1:0]    dout_sops_ptx;
//     wire [WORDS*8-1:0]  dout_eop_pos_ptx;
     wire              dout_valid_ptx;

     assign {cout_to_mlab_ptp,eop_at_0123_ptp,enable_r2_ptp} = mac_out_bus_ptp[17:0];
     
  
//     alt_aeu_tx_pkt_40 etp
//       (
//        .arst(sclr),
//         .tod_txmac_in(tod_txmac_in),
//        .ptp_v2(ptp_v2),
//        .ptp_s2(ptp_s2),
//        .ext_lat(ext_lat),
//        .din_valid(enable_r2),
//        .din_crc(dout_to_crc), // data to crc and data to malb is different !!!
//        .din_mlab(dout_to_mlab),  // data to crc and data to malb is different !!!
//        .mac_in_bus(mac_in_bus), // other data that needs to be pipelined
//        .din_sops(tag_dsop_r2),
//        .din_eop_pos(tag_eop_pos_r2),
//        .din_ptp_dbg_adp(din_ptp_dbg_adp),
//        .din_sop_adp(din_sop_adp),
//        .din_ptp_adp(din_ptp_adp),
//        .din_overwrite_adp(din_overwrite_adp),
//        .din_offset_adp(din_offset_adp),
//         .din_zero_tcp_adp(din_zero_tcp_adp),
//         .din_ptp_asm_adp(din_ptp_asm_adp),
//         .din_zero_offset_adp(din_zero_offset_adp),
////         .ts_out_cust_asm(ts_out_cust_asm),
//        .tod_txmclk(tod_txmclk),
// //       .latency_ahead(latency_ahead),
// //       .latency_adj(latency_adj),
//        .dout_crc(dout_crc_ptx),
//        .dout_mlab(dout_mlab_ptx),
//        .mac_out_bus(mac_out_bus_ptx), // other data that needs to be pipelined
//        .dout_sops(dout_sops_ptx),
//        .dout_eop_pos(dout_eop_pos_ptx),
//        .dout_valid(),
//        .tod_cust_in(tod_cust_in),
//        .tod_exit_cust(tod_exit_cust),
////        .ts_out_cust(ts_out_cust),
//        .clk(clk)
//        );
  
   alt_aeu_ptp_tx ptx
         (
          .srst(sclr),
//      .tod_txmac_in(tod_txmac_in),
                   .txmclk_period(txmclk_period),
                   .tx_asym_delay(tx_asym_delay),
                  .ext_lat(ext_lat),
                   .tx_pma_delay(tx_pma_delay),
                  .cust_mode(cust_mode),
         .tod_96b_txmac_in(tod_96b_txmac_in),
         .tod_64b_txmac_in(tod_64b_txmac_in),
          .din_sop_adp(din_sop_adp),
          .ts_exit(ts_exit),
          .ts_exit_valid(ts_exit_valid),
          .fp_out(fp_out),
                   .fp_out_req_adp(fp_out_req_adp),
                   .ts_out_req_adp(ts_out_req_adp),
                   .ing_ts_96_adp(ing_ts_96_adp),
                   .ing_ts_64_adp(ing_ts_64_adp),
                   .ins_ts_adp(ins_ts_adp),
                   .ins_ts_format_adp(ins_ts_format_adp),
                   .tx_asym_adp(tx_asym_adp),
                   .upd_corr_adp(upd_corr_adp),
                   .chk_sum_zero_adp(chk_sum_zero_adp),
                   .chk_sum_upd_adp(chk_sum_upd_adp),
                   .corr_format_adp(corr_format_adp),
                   .ts_offset_adp(ts_offset_adp),
                   .corr_offset_adp(corr_offset_adp),
                   .chk_sum_zero_offset_adp(chk_sum_zero_offset_adp),
                   .chk_sum_upd_offset_adp(chk_sum_upd_offset_adp),
        .tod_exit_cust(tod_exit_cust),
                  .tod_cust_in(tod_cust_in),
                .din_ptp_asm_adp(din_ptp_asm_adp),
          .din_valid(enable_r2),
          .din_crc(dout_to_crc), // data to crc and data to malb is different !!!
          .din_mlab(dout_to_mlab),  // data to crc and data to malb is different !!!
          .mac_in_bus(mac_in_bus), // other data that needs to be pipelined
          .din_sops(tag_dsop_r2),
          .din_eop_pos(tag_eop_pos_r2),

          .dout_valid(dout_valid_ptx),
        .dout_crc(dout_crc_ptp),
        .dout_mlab(dout_mlab_ptp_w),
        .mac_out_bus(mac_out_bus_ptp), // other data that needs to be pipelined
        .dout_sops(dout_sops_ptp),
        .dout_eop_pos(dout_eop_pos_ptp),

      .ts_out_cust_asm(ts_out_cust_asm),
        .ts_out_cust(ts_out_cust),
        .clk(clk)
        );
  
     defparam ptx.TARGET_CHIP = TARGET_CHIP;
     defparam ptx.PTP_FP_WIDTH = PTP_FP_WIDTH;
     defparam ptx.SYNOPT_PTP = SYNOPT_PTP;
     defparam ptx .SYNOPT_TOD_FMT = SYNOPT_TOD_FMT;
     defparam ptx.PTP_LATENCY = PTP_LATENCY;
   defparam ptx.ADF_TO_FLD_DLY = 25;
   defparam ptx.DEL_CALC_DLY = 22;
   defparam ptx.FD_DLY = 48;
     defparam ptx.EN_LINK_FAULT = EN_LINK_FAULT;
     defparam ptx.MAC_BUS_WIDTH = 20;
     defparam ptx.WORDS = 2;


generate
// (TX Error Insertion)
// Logic to re-stamp /E/ in the data-stream if PTP has overwritten the code

    if (SYNOPT_PTP) begin

        wire [1:0] tag_error_ptp;
        alt_aeu_dly_mlab det (
            .clk(clk),
            .din(tag_error),
            .dout(tag_error_ptp)
        );
        defparam det .WIDTH = 2;
        defparam det .LATENCY = PTP_LATENCY; 
        defparam det .TARGET_CHIP = TARGET_CHIP;

    for (i=0; i<WORDS; i=i+1) begin : err_mux_ptp
        always @(*) begin   
            dout_mlab_ptp[i*WIDTH+:8] = tag_error_ptp[i] ? 8'hFE : dout_mlab_ptp_w[i*WIDTH+:8] ;
            dout_mlab_ptp[(i*WIDTH+8)+:56] = dout_mlab_ptp_w[(i*WIDTH+8)+:56] ;
        end
    end


    end else begin
        for (i=0; i<WORDS; i=i+1) begin : terr_mux_ptp
            always @(*) begin   
                dout_mlab_ptp[i*WIDTH+:64] = dout_mlab_ptp_w[i*WIDTH+:64] ;
            end
        end
    end
endgenerate




  //    

///////////////////////////////////////////////////////
// delay tags to line up with dout_to_mlab
///////////////////////////////////////////////////////
always @(posedge clk) begin
     tag_dsop_r2 <= tag_dsop_r;
     tag_eop_pos_r2 <= tag_eop_pos_r;
end

always @(posedge clk) begin
         am_hist <= am_hist << 1 | pre_din_am;
         enable <= {6{!pre_din_am}};
         enable_r <= enable[0];
         enable_r2 <= enable_r;
end


////////////////////////////////////////////
// CRC Insertion Logic
////////////////////////////////////////////
generate
   if (EN_TX_CRC_INS) begin

wire crc_valid;
wire [31:0] crc_out;
reg  [31:0] crc_out_r = 0;
wire [31:0] crc_to_mii;

//////////////////////////////

ecrc_2 fcs (
        .clk(clk),

        .din_valid(enable_r2_ptp),              
        .din(dout_crc_ptp),          
        .din_first_data(dout_sops_ptp),
        .din_last_data(dout_eop_pos_ptp), 
        
        .crc_valid(crc_valid),
        .crc_out(crc_out)       
);
defparam fcs .TARGET_CHIP = TARGET_CHIP;
defparam fcs .REDUCE_LATENCY = REDUCE_CRC_LAT;

always @(posedge clk) crc_out_r <= crc_out;

//always @(negedge clk) begin
//   if (enable_r2_ptp) 
    //$display("%t valid   CRC sop = %h, eop = %h, din = %h", $time, dout_sop_ptp, dout_eop_pos_ptp, dout_mlab_ptp);
//    $display("%t valid   CRC sop = %h, eop = %h, din = %h", $time, dout_sop_ptp_x, dout_eop_pos_ptp_x, dout_mlab_ptp_x);
//   else 
    //$display("%t invalid CRC sop = %h, eop = %h, din = %h", $time, dout_sop_ptp, dout_eop_pos_ptp, dout_mlab_ptp);
//    $display("%t invalid CRC sop = %h, eop = %h, din = %h", $time, dout_sop_ptp_x, dout_eop_pos_ptp_x, dout_mlab_ptp_x);
//   if (crc_valid)
//    $display("%t TX CRC %h", $time, crc_out);
//end

////////////////////////////////////////////////////
// delay data/control to match CRC latency
////////////////////////////////////////////////////

wire [WORDS*WIDTH-1:0] upk_d_mlab;
wire [WORDS*8-1:0] upk_c_mlab;
wire     upk_e_mlab;
reg  [WORDS*WIDTH-1:0] upk_d=0;
reg  [WORDS*8-1:0] upk_c=0;
reg      upk_e=0;

delay_mlab dr0 (
        .clk(clk),
        .din({eop_at_0123_ptp, cout_to_mlab_ptp, dout_mlab_ptp}),
        .dout({upk_e_mlab, upk_c_mlab, upk_d_mlab})
);
defparam dr0 .WIDTH = WORDS*(WIDTH + 8) + 1;
defparam dr0 .LATENCY = REDUCE_CRC_LAT ? 7 : 11; 
defparam dr0 .TARGET_CHIP = TARGET_CHIP;

// replace the last pipe of mlab with f/f for better timing
always @(posedge clk) {upk_e, upk_c, upk_d} <= {upk_e_mlab, upk_c_mlab, upk_d_mlab};




//////////////////////////////////////////////////
// figure out where the FCS is needed
//////////////////////////////////////////////////
reg last_upk_e=0, last2_upk_e=0, last3_upk_e=0;
reg [WORDS*8-1:0] efd_match = 0, last_efd_match = 0;
//generate
        for (i=0; i<8*WORDS; i=i+1) begin : ecmp
                always @(posedge clk) begin
                        efd_match[i] <= (upk_d[(i+1)*8-1:i*8] == TERM) && upk_c[i];
                end
        end
//endgenerate

// four FCS bytes are right before the end delimiter
always @(posedge clk) begin
        last_efd_match <= efd_match;
        last_upk_e <= upk_e;
        last2_upk_e <= last_upk_e;
        last3_upk_e <= last2_upk_e;
end

wire [WORDS*8-1:0] first_fcs = {last_efd_match[11:0],efd_match[15:12]};
wire [WORDS*8-1:0] second_fcs = {last_efd_match[12:0],efd_match[15:13]};
wire [WORDS*8-1:0] third_fcs = {last_efd_match[13:0],efd_match[15:14]};
wire [WORDS*8-1:0] fourth_fcs = {last_efd_match[14:0],efd_match[15]};

//assign crc_to_mii = (first_fcs[31] || second_fcs[31] || third_fcs[31] || fourth_fcs[31]) ? crc_out_r : crc_out; // this is right but timing not good
assign crc_to_mii = last3_upk_e ? crc_out_r : crc_out; // use this one instead 

wire [WORDS*8*3-1:0] src_select /* synthesis keep */;
//generate
        for (i=0; i<8*WORDS; i=i+1) begin : srcs
                assign src_select[(i+1)*3-1:i*3] = 
                        first_fcs[i] ? 3'h4 :
                        second_fcs[i] ? 3'h5 :
                        third_fcs[i] ? 3'h6 :
                        fourth_fcs[i] ? 3'h7 :
                        3'h0;
        end
//endgenerate

reg [WORDS*WIDTH-1:0] last_upk_d = 0, last2_upk_d = 0;
reg [WORDS*8-1:0] last_upk_c = 0, last2_upk_c = 0;

always @(posedge clk) begin
                last2_upk_d <= last_upk_d;
                last2_upk_c <= last_upk_c;
                last_upk_d <= upk_d;
                last_upk_c <= upk_c;
end

wire   next_is_am;
assign next_is_am = SYNOPT_PTP ? !tx_crc_ins_en ? am_hist[2+PTP_LATENCY] : REDUCE_CRC_LAT ? am_hist[12+PTP_LATENCY] : am_hist[16+PTP_LATENCY] :
                                   !tx_crc_ins_en ? am_hist[2]             : REDUCE_CRC_LAT ? am_hist[12]             : am_hist[16];
//assign next_is_am = am_hist[(SYNOPT_PTP == 0)? (REDUCE_CRC_LAT ? 12 : 16) : (REDUCE_CRC_LAT ? 12 + PTP_LATENCY : 16 + PTP_LATENCY)];  // Try 1
//assign next_is_am = am_hist[REDUCE_CRC_LAT ? 12 : 16]; 

////////////////////////////////////////////////////
// Merge CRC result into mii data/control
////////////////////////////////////////////////////

always @(posedge clk) begin
        if (!next_is_am) begin
                mii_c <= last2_upk_c;
                mii_valid_reg <= 1'b1;
    end
    else begin
        mii_c <= 16'hff_ff;
        mii_valid_reg <= 1'b0;
    end
end
      

        for (i=0; i<8*WORDS; i=i+1) begin : cmux
                wire [2:0] local_sel = src_select[(i+1)*3-1:i*3];
                always @(posedge clk) begin
                    if (!next_is_am) begin
                        if (!tx_crc_ins_en) begin
                                mii_d [(i+1)*8-1:i*8] <= dout_mlab_ptp[(i+1)*8-1:i*8];
                        end
                        else if (!local_sel[2]) begin
                                mii_d [(i+1)*8-1:i*8] <= last2_upk_d[(i+1)*8-1:i*8];
                        end
                        else begin
                                case (local_sel[1:0])
                                        2'h3 : mii_d [(i+1)*8-1:i*8] <= crc_to_mii[31:24];
                                        2'h2 : mii_d [(i+1)*8-1:i*8] <= crc_to_mii[23:16];
                                        2'h1 : mii_d [(i+1)*8-1:i*8] <= crc_to_mii[15:8];
                                        2'h0 : mii_d [(i+1)*8-1:i*8] <= crc_to_mii[7:0];
                                endcase

                                // synthesis translate_off
                                //if (!crc_valid) begin // comment out since it's no longer right (not extended)
                                        //$display ("%t Error : TX inserting an invalid CRC", $time);
                                        //$stop();
                                //end
                                // synthesis translate_on
                        end
                     end
                     else mii_d [(i+1)*8-1:i*8] <= IDLE;
                end
        end




                
end
endgenerate

////////////////////////////////////////////
// NO CRC Insertion Logic
////////////////////////////////////////////
generate
   if (!EN_TX_CRC_INS) begin
      wire   next_is_am;
      assign next_is_am = am_hist[2]; 
      always @(posedge clk) begin
        if (!next_is_am) begin
                mii_c <= cout_to_mlab_ptp;
                mii_valid_reg <= 1'b1;
        end
        else begin
                mii_c <= 16'hff_ff;
                mii_valid_reg <= 1'b0;
        end
       end
      
       for (i=0; i<8*2; i=i+1) begin : cmux2
              always @(posedge clk) begin
                  if (!next_is_am) mii_d [(i+1)*8-1:i*8] <= dout_mlab_ptp[(i+1)*8-1:i*8];
                  else             mii_d [(i+1)*8-1:i*8] <= IDLE;
              end
       end
   end
endgenerate

assign mii_valid = mii_valid_reg;

//////////////////////////
// for happy debugging
//////////////////////////

 // _________________________________________________________________
 //     tx csr register module
 // _________________________________________________________________
   localparam CSRADDRSIZE = 8;

   wire serif_stats_dout; 
   wire serif_mac_dout;
   assign serif_slave_dout = serif_mac_dout & serif_stats_dout;

   wire[15:0] cfg_max_fsize;

   wire cfg_pld_length_chk      ;
   wire cfg_pld_length_include_vlan     ;
   wire cfg_cntena_phylink_error        ;
   wire cfg_cntena_oversize_error       ;
   wire cfg_cntena_undersize_error      ;
   wire cfg_cntena_pldlength_error      ;
   wire cfg_cntena_fcs_error            ;


   alt_aeu_40_mac_tx_csr #(
         .BASE                  (BASE_TXMAC)
        ,.REVID                 (REVID)
        ,.ADDRSIZE              (CSRADDRSIZE) 
        ,.TARGET_CHIP           (TARGET_CHIP) 
   ) mactx_csr(
         .clk_tx                (clk)
        ,.reset_tx              (sclr)     //this input has not logic connect to it
        ,.clk_csr               (clk_csr)
        ,.reset_csr             (reset_csr)//this input has not logic connect to it 
        ,.serif_master_din      (serif_slave_din)
        ,.serif_slave_dout      (serif_mac_dout)

        ,.cfg_max_fsize                 (cfg_max_fsize) 
        ,.cfg_pld_length_chk            (cfg_pld_length_chk)
        ,.cfg_pld_length_include_vlan   (cfg_pld_length_include_vlan)       
        ,.cfg_cntena_phylink_error      (cfg_cntena_phylink_error)
        ,.cfg_cntena_oversize_error     (cfg_cntena_oversize_error)
        ,.cfg_cntena_undersize_error    (cfg_cntena_undersize_error)
        ,.cfg_cntena_pldlength_error    (cfg_cntena_pldlength_error)
        ,.cfg_cntena_fcs_error          (cfg_cntena_fcs_error)
        ,.cfg_link_fault_gen_en   (cfg_en_link_fault_gen)
        ,.cfg_link_fault_unidir_en(cfg_unidirectional_en)
        ,.cfg_ipg_col_rem         (num_idle_rm)
        ,.cfg_tx_crc_ins_en_4debug(cfg_tx_crc_ins_en_4debug)
        );


 wire[ERRORBITWIDTH-1:0] out_tx_error;
 wire txdp_valid;                       // word contains first data (on leftmost byte)
 wire [WORDS-1:0] txdp_idle = {WORDS{1'b0}};            // word contains first data (on leftmost byte)
 wire [WORDS-1:0] txdp_sop;             // word contains first data (on leftmost byte)
 wire [WORDS-1:0] txdp_eop;             // byte position of last data
 wire [03*WORDS-1:0] txdp_eop_empty;    // byte position of last data
 wire [WORDS*WIDTH-1:0] txdp_data;      // data, read left to right
 wire [08*WORDS-1:0] txdp_ctrl;         // control bytes

 generate if (SYNOPT_TXSTATS == 1)
     begin:txstats
        // _________________________________________________________________
        //      mii to custom signal decoder
        // _________________________________________________________________

        wire txdp_error;
        
         alt_aeu_40_xlgmii_custom_2 #(
                 .WIDTH         (WIDTH)
                ,.WORDS         (WORDS)
                ,.TARGET_CHIP   (TARGET_CHIP)
          )mii2cus(
                .clk            (clk            )
               ,.reset          (sclr           )
               
               ,.in_mii_d       (tx_mii_d       )
               ,.in_mii_c       (tx_mii_c       )
               ,.in_mii_valid   (tx_mii_valid   )
               
               ,.out_valid      (txdp_valid     )
               ,.out_ctrl       (txdp_ctrl      )
               ,.out_sop        (txdp_sop       ) 
               ,.out_eop        (txdp_eop       )       
               ,.out_error      (txdp_error     )
               ,.out_eop_empty  (txdp_eop_empty )  
               ,.out_data       (txdp_data      )
          );
        
        // _________________________________________________________________
        //      header processor
        // _________________________________________________________________
        
          wire txdp_error_delay;
          delay_mlab dfcs (
              .clk(clk),
              .din(txdp_error),
              .dout(txdp_error_delay)
          );
          defparam dfcs .WIDTH = 1;
          defparam dfcs .LATENCY = 11;
          defparam dfcs .TARGET_CHIP = TARGET_CHIP;
 

          wire out_fcs_error, out_fcs_valid;
          alt_aeu_40_hproc_2  #(                                           //NOTE: there are two alt_aeu_40_hproc_2 instance call in the module. 
                .WORDS                          (WORDS)                    //instance call 1                                                      
               ,.SYNOPT_PREAMBLE_PASS           (1'b1)
               ,.ERRORBITWIDTH                  (ERRORBITWIDTH)
               ,.STATSBITWIDTH                  (STATSBITWIDTH)
          )hdr_proc     (
                .clk                            (clk)
               ,.reset                          (sclr)   //connect to alt_aeu_dform
                                             
               ,.cfg_crc_included               (1'b1)
               ,.cfg_max_frm_length             (cfg_max_fsize)
               ,.cfg_pld_length_chk             (cfg_pld_length_chk)
               ,.cfg_pld_length_include_vlan    (cfg_pld_length_include_vlan)
               ,.cfg_cntena_phylink_error       (cfg_cntena_phylink_error)
               ,.cfg_cntena_oversize_error      (cfg_cntena_oversize_error)
               ,.cfg_cntena_undersize_error     (cfg_cntena_undersize_error)
               ,.cfg_cntena_pldlength_error     (cfg_cntena_pldlength_error)
               ,.cfg_cntena_fcs_error           (cfg_cntena_fcs_error)
        
               ,.in_dp_phyready                 (1'b1)
               ,.in_dp_valid                    (txdp_valid)
               ,.in_dp_ctrl                     (txdp_ctrl)
               ,.in_dp_idle                     (txdp_idle)
               ,.in_dp_sop                      (txdp_sop)
               ,.in_dp_eop                      (txdp_eop)
               ,.in_dp_data                     (txdp_data)
               ,.in_dp_eop_empty                (txdp_eop_empty)
        
               ,.in_dpfcs_error                 (txdp_error_delay)
               ,.in_dpfcs_valid                 (1'b1)
               ,.in_dp_phyerror                 (1'b0) //placeholder
               ,.out_dpfcs_error                (out_fcs_error)
               ,.out_dpfcs_valid                (out_fcs_valid)
        
               ,.out_counts                     (tx_inc_octetsOK)
               ,.out_counts_valid               (tx_inc_octetsOK_valid)
               ,.out_dp_stats                   (out_tx_stats)
               ,.out_dp_error                   (out_tx_error)
               ,.out_rx_ctrl_sfc                ()
               ,.out_rx_ctrl_pfc                ()
               ,.out_rx_ctrl_other              ()
                );
        
        // _________________________________________________________________
        //      the stats collection module
        // _________________________________________________________________
          alt_aeu_40_stats_reg #(
                .BASE                   (BASE_TXSTAT)  
               ,.REVID                  (REVID)
               ,.COUNTWIDTH             (16)  
               ,.NUMCOUNTS              (01) 
               ,.NUMSTATS               (STATSBITWIDTH) 
               ,.TARGET_CHIP            (TARGET_CHIP)  
          ) statsreg    (
                .clk                    (clk)
               ,.reset                  (sclr)       //global reset -> ~tx_online
               ,.in_counts              (tx_inc_octetsOK)
               ,.in_stats               (out_tx_stats)
               ,.clk_csr                (clk_csr)
               ,.reset_csr              (reset_csr)  //this input has not logic connect to it  
               ,.serif_master_dout      (serif_slave_din)
               ,.serif_slave_dout       (serif_stats_dout)
          );
   end else if (SYNOPT_TXHPROC == 1)
      begin: hproc
        assign serif_stats_dout = 1'b1;
        // _________________________________________________________________
        //      mii to custom signal decoder
        // _________________________________________________________________
        
        wire txdp_error;
         alt_aeu_40_xlgmii_custom_2 #(
                 .WIDTH                 (WIDTH)
                ,.WORDS                 (WORDS)
                ,.TARGET_CHIP           (TARGET_CHIP)
          )mii2cus      (
                .clk                    (clk            )
               ,.reset                  (sclr           )
               
               ,.in_mii_d               (tx_mii_d       )
               ,.in_mii_c               (tx_mii_c       )
               ,.in_mii_valid           (tx_mii_valid   )
               
               ,.out_valid              (txdp_valid     )
               ,.out_ctrl               (txdp_ctrl      )
               ,.out_sop                (txdp_sop       ) 
               ,.out_eop                (txdp_eop       )       
               ,.out_error              (txdp_error     )
               ,.out_eop_empty          (txdp_eop_empty )  
               ,.out_data               (txdp_data      )
          );
        // _________________________________________________________________
        //      header processor
        // _________________________________________________________________
          wire txdp_error_delay;
          wire out_fcs_error;
          wire out_fcs_valid;

          delay_mlab dfcs (
              .clk(clk),
              .din(txdp_error),
              .dout(txdp_error_delay)
          );
          defparam dfcs .WIDTH = 1;
          defparam dfcs .LATENCY = 11;
          defparam dfcs .TARGET_CHIP = TARGET_CHIP;
        
          alt_aeu_40_hproc_2  #(                                                      //NOTE: there are two alt_aeu_40_hproc_2 instance call in the module.
                .WORDS                  (WORDS)                                       //instance call 2                                                    
               ,.SYNOPT_PREAMBLE_PASS   (1'b1)
               ,.ERRORBITWIDTH          (ERRORBITWIDTH)
               ,.STATSBITWIDTH          (STATSBITWIDTH)
          )hdr_proc     (
                .clk                    (clk)
               ,.reset                  (sclr)                                       //connect to alt_aeu_dform
                                             
               ,.cfg_crc_included       (1'b1)
               ,.cfg_max_frm_length     (cfg_max_fsize)
               ,.cfg_pld_length_chk             (cfg_pld_length_chk)
               ,.cfg_pld_length_include_vlan    (cfg_pld_length_include_vlan)     
               ,.cfg_cntena_phylink_error       (cfg_cntena_phylink_error)
               ,.cfg_cntena_oversize_error      (cfg_cntena_oversize_error)
               ,.cfg_cntena_undersize_error     (cfg_cntena_undersize_error)
               ,.cfg_cntena_pldlength_error     (cfg_cntena_pldlength_error)
               ,.cfg_cntena_fcs_error           (cfg_cntena_fcs_error)
        
               ,.in_dp_phyready         (1'b1)
               ,.in_dp_valid            (txdp_valid)
               ,.in_dp_ctrl             (txdp_ctrl)
               ,.in_dp_idle             (txdp_idle)
               ,.in_dp_sop              (txdp_sop)
               ,.in_dp_eop              (txdp_eop)
               ,.in_dp_data             (txdp_data)
               ,.in_dp_eop_empty        (txdp_eop_empty)
        
               ,.in_dpfcs_error         (txdp_error_delay)
               ,.in_dpfcs_valid         (1'b1)
               ,.in_dp_phyerror         (1'b0) //placeholder
               ,.out_dpfcs_error        (out_fcs_error)
               ,.out_dpfcs_valid        (out_fcs_valid)
        
               ,.out_counts             (tx_inc_octetsOK)
               ,.out_counts_valid       (tx_inc_octetsOK_valid)
               ,.out_dp_stats           (out_tx_stats)
               ,.out_dp_error           (out_tx_error)
                );
   end else 
      begin
                assign serif_stats_dout = 1'b1;
                assign out_tx_error = 0;
                assign out_tx_stats = 0;
                assign tx_inc_octetsOK = 0;
                assign tx_inc_octetsOK_valid = 0;
     end
 endgenerate

 // _________________________________________________________________
 //     Link Fault Generator Module
 // _________________________________________________________________
 // 
   generate if (EN_LINK_FAULT) 
        begin
                alt_aeu_40_mac_link_fault_gen  mac_link_fault_gen
                (
                .clk                    (clk),
                .reset                  (sclr),  //this input has not logic connect to it
                .cfg_unidirectional_en  (cfg_unidirectional_en),
                .cfg_en_link_fault_gen  (cfg_en_link_fault_gen),
                
                .remote_fault_status    (remote_fault_status),
                .local_fault_status     (local_fault_status),
                .mii_c_in               (mii_c),
                .mii_d_in               (mii_d),
                .mii_valid_in           (mii_valid),
                .mii_c_out              (tx_mii_c),
                .mii_d_out              (tx_mii_d),
                .mii_valid_out          (tx_mii_valid)
                );
        end
   else begin
                assign tx_mii_c = mii_c;
                assign tx_mii_d = mii_d;
                assign tx_mii_valid = mii_valid;
        end
endgenerate



endmodule
