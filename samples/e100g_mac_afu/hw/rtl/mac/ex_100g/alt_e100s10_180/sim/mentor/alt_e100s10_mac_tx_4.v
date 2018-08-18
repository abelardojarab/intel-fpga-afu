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


// $Id: //acds/main/ip/ethernet/alt_e100s10_100g/rtl/mac/alt_e100s10_mac_tx_4.v#27 $
// $Revision: #27 $
// $Date: 2013/10/31 $
// $Author: jilee $
//-----------------------------------------------------------------------------
`timescale 1 ps / 1 ps

// to cut down pins for testing -
// set_instance_assignment -name VIRTUAL_PIN ON -to mii_d
// set_instance_assignment -name VIRTUAL_PIN ON -to din
// set_global_assignment -name SEARCH_PATH ../../hsl12
// set_global_assignment -name SEARCH_PATH ../../rtl/lib
// set_global_assignment -name SEARCH_PATH ../../rtl/mac
// set_global_assignment -name SEARCH_PATH ../../rtl/clones
// set_global_assignment -name SEARCH_PATH ../../rtl/csr

module alt_e100s10_mac_tx_4 #(
        parameter SIM_EMULATE = 0,
        parameter SYNOPT_AVG_IPG = 12,
        parameter SYNOPT_PTP = 0,
                parameter SYNOPT_TOD_FMT = 0,
                parameter PTP_FP_WIDTH = 16, // width of fingerprint, ptp parameter
//              parameter PTP_TS_WIDTH = 96, 
        parameter PTP_LATENCY = 52,
        parameter EN_LINK_FAULT = 0,
        parameter EN_PREAMBLE_PASS_THROUGH = 1,
        parameter EN_TX_CRC_INS = 1,
        parameter EN_DIC = 1,
        parameter WIDTH = 64,
        parameter WORDS = 4,
        parameter TARGET_CHIP = 2,
        parameter REDUCE_CRC_LAT = 1'b1,  // lower CRC latency (at expense of timing
        parameter BASE_TXMAC = 0,
        parameter REVID = 32'h08092017,
        parameter CSRADDRSIZE = 8
)(
    input sclr,     //from ~tx_online
    input clk,
    input [WORDS-1:0] din_sop,        // word contains first data (on leftmost byte)
    input [WORDS-1:0] din_eop,      // byte position of last data
    input [WORDS-1:0] din_idle,     // bytes between EOP and SOP
    input [3*WORDS-1:0] din_eop_empty,  // byte position of last data
    input [WORDS*WIDTH-1:0] din,    // data, read left to right
    input [WORDS-1:0]     tx_error,
    //output req,
    output [4:0] req, // S10TIM
    input  pre_din_am,
    
    output wire [WORDS*WIDTH-1:0] tx_mii_d,
    output wire [8*WORDS-1:0] tx_mii_c,
    output wire tx_mii_valid,
    output wire o_bus_error,

    input  wire reset_csr,// global reset, async, no domain
    input  wire clk_csr,  // 100 MHz

    //output wire serif_slave_dout,
    //input  wire serif_slave_din,
    input  wire               write,
    input  wire               read,
    input  wire [CSRADDRSIZE-1:0]address,
    input  wire [31:0]        writedata,
    output wire [31:0]        readdata,
    output wire               readdatavalid,

    output [41:0]	tx_stats,
    output		tx_stats_valid,
    output [2:0] 	tx_stats_error,

    output wire tx_crc_ins_en,

    // ptp related inouts -- begin
  input [95:0] tod_96b_txmac_in,
  input [63:0] tod_64b_txmac_in,
   input [19:0]         txmclk_period,
        input [18:0] tx_asym_delay,
        input [31:0] tx_pma_delay,
  input cust_mode,
//    input ptp_v2,
//    input ptp_s2,
    input [31:0] ext_lat,
    input din_ptp_dbg_adp,
    input din_sop_adp,
//    input din_ptp_adp,
//    input [1:0] din_overwrite_adp,
//    input [15:0] din_offset_adp,
//         input din_zero_tcp_adp,
         input din_ptp_asm_adp,
//         input [15:0] din_zero_offset_adp,
         output ts_out_cust_asm,

//    input [95:0] latency_ahead,
//    input [95:0] latency_adj,

  input [95:0] tod_cust_in,
  output [95:0] tod_exit_cust,
  output [95:0] ts_out_cust,
    // ptp related inouts -- end

        input ts_out_req_adp,
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
    
    output wire  cfg_unidirectional_en,
    output wire  cfg_en_link_fault_gen,
    output wire  cfg_unidir_en_disable_rf,    
    output wire  cfg_force_rf,                
    input  wire remote_fault_status,
    input  wire local_fault_status
);

   
wire   next_is_am;
wire cfg_tx_crc_ins_en_4debug;
reg [4:0] tx_crc_ins_en_reg /* synthesis preserve_syn_only */;
generate 
   if (EN_TX_CRC_INS)  begin
                //always @(posedge clk) tx_crc_ins_en_reg <= {5{cfg_tx_crc_ins_en_4debug}};
                always @(posedge clk) tx_crc_ins_en_reg <= 5'b11111; // S10TIM Ok
                assign tx_crc_ins_en  = tx_crc_ins_en_reg[4];
        end
   else begin
                assign tx_crc_ins_en  = 1'b0;
        end
endgenerate

reg [WORDS*WIDTH-1:0] mii_d;
reg [8*WORDS-1:0]     mii_c;
reg                   mii_valid_reg;

genvar i, j;

reg [20+PTP_LATENCY:0] am_hist;
reg  [8:0] enable /* synthesis preserve_syn_only */;
reg  enable_r;
reg  enable_r2;
reg  enable_r3; // S10TIM Ok
wire [WORDS*WIDTH-1:0] dbuf_d;
reg  [WORDS*WIDTH-1:0] dbuf_q=0;
wire [WORDS-1:0] dbuf_req;
wire [WORDS-1:0] dbuf_full;
wire [WORDS-1:0] dbuf_empty;
wire [3:0] tag_is_data_d;
reg  [3:0] tag_is_data=0;
reg  [3:0] tag_is_data_r=0;
reg  [3:0] tag_is_data_r2; // S10TIM Ok
wire [WORDS*WIDTH-1:0] dout_to_mlab_w;
reg  [WORDS*WIDTH-1:0] dout_to_mlab=0;
reg  [WORDS*WIDTH-1:0] dout_to_crc=0;
reg  [WORDS*8-1:0] cout_to_mlab=0;
wire [WORDS*8-1:0] cout_to_mlab_w;
wire [3*WORDS-1:0] tags_d, tags_to_preamble, tags_to_gap, tags_to_dic, tags_rev;
reg  [3*WORDS-1:0] tags=0;

generate
    for (i=0; i<WORDS; i=i+1) begin : dbuf

        wire [WIDTH-1:0] local_q;
        wire [15:0] extra_16;
        wire        wreq = req && !din_idle[i];
        reg         rreq_i=0;
        always @(posedge clk)
           if (sclr) rreq_i <= 0; // S10TIM fix
           else if (enable[i])  
             rreq_i <= ((tags_d[11]==1 && tags_d[10:9]==3-i) ||
                        (tags_d[ 8]==1 && tags_d[ 7:6]==3-i) ||
                        (tags_d[ 5]==1 && tags_d[ 4:3]==3-i) ||
                        (tags_d[ 2]==1 && tags_d[ 1:0]==3-i));
        wire rreq = enable[i] && rreq_i;

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
        defparam scm .ADDR_WIDTH = 5;

        assign dbuf_d[(i+1)*WIDTH-1:i*WIDTH] = local_q[WIDTH-1:0];
    end
endgenerate

////////////////////////////////////////////////////
// seperate SOPs to be minimum 10 words
// generate tags for data path
////////////////////////////////////////////////////
reg  [3*WORDS-1:0] tags_r=0;
wire [3*WORDS-1:0] tag_eop_empty_d, eop_empty_to_preamble, eop_empty_to_gap, eop_empty_to_dic, tag_eop_empty_rev;
reg  [3*WORDS-1:0] tag_eop_empty = 4'h0;
wire [3*WORDS-1:0] tag_data_empty_d, data_empty_to_preamble, data_empty_to_gap, data_empty_to_dic, tag_data_empty_rev;
reg  [3*WORDS-1:0] tag_data_empty = 4'h0;
wire [WORDS-1:0]   tag_sop_d, sop_to_preamble, sop_to_gap, sop_to_dic, tag_sop_rev;
reg  [WORDS-1:0]   tag_sop = 4'h0;
wire [WORDS-1:0]   tag_eop_d, eop_to_preamble, eop_to_gap, eop_to_dic, tag_eop_rev;
reg  [WORDS-1:0]   tag_eop = 4'b0000;
reg  [WORDS-1:0]   tag_sop_r = 0;
wire [WORDS-1:0]   tag_dsop;
reg [8*WORDS-1:0] tag_eop_pos_r = 4'h0, tag_eop_pos_r2 = 4'h0;
reg [8*WORDS-1:0] tag_eop_pos_r3; // S10TIM

wire [WORDS-1:0]   sop_rev = {din_sop[0] && !din_idle[0] && !din_eop[0], 
                              din_sop[1] && !din_idle[1] && !din_eop[1], 
                              din_sop[2] && !din_idle[2] && !din_eop[2], 
                              din_sop[3] && !din_idle[3] && !din_eop[3]};
wire [WORDS-1:0]   eop_rev = {din_eop[0] && !din_idle[0] && !din_sop[0], 
                              din_eop[1] && !din_idle[1] && !din_sop[1], 
                              din_eop[2] && !din_idle[2] && !din_sop[2], 
                              din_eop[3] && !din_idle[3] && !din_sop[3]};
wire [WORDS-1:0]   idle_rev = {din_idle[0], din_idle[1], din_idle[2], din_idle[3]};
wire [3*WORDS-1:0] eop_empty_rev = {din_eop_empty[2:0], din_eop_empty[5:3], din_eop_empty[8:6], din_eop_empty[11:9]};
wire               wait_req_from_preamble, wait_req_from_gap, wait_req_from_dic;
wire               mii_valid;


/////////////////////////////////////////
// TX ERROR INSERTION LOGIC

wire [WORDS-1:0]   eop = {eop_rev[0], eop_rev[1], eop_rev[2], eop_rev[3]};
wire error;

alt_e100s10_tx_error    txer (
    .clk        (clk),
    .sclr       (sclr),
    .din_eop    (eop),
    .tx_error   (tx_error),
    .req        (req[0]),
    .tag_eop    (tag_eop_d),
    .enable     (enable[8]),
    .error      (error)
);
defparam    txer .WORDS = WORDS;
defparam    txer .WIDTH = WIDTH;
defparam    txer .TARGET_CHIP = TARGET_CHIP;

/////////////////////////////////////////

ectrl_tag_4_9  etag4(
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
defparam etag4 . EN_PREAMBLE_PASS_THROUGH = EN_PREAMBLE_PASS_THROUGH;

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
      ectrl_preamble_4 epreamble(
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

ectrl_gap_4 #(
        .SYNOPT_AVG_IPG(SYNOPT_AVG_IPG),
        .EN_TX_CRC_INS(EN_TX_CRC_INS) // S10TIM Ok
) egap (
        .clk(clk),
        .sclr(sclr),

        //.tx_crc_ins_en(tx_crc_ins_en_reg[0]), // S10TIM Ok
        .i_ena(enable[6] && !wait_req_from_dic),
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


wire [7:0] num_idle_rm;
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
   ectrl_dic_4 #(
        .SYNOPT_AVG_IPG (SYNOPT_AVG_IPG),
        .EN_TX_CRC_INS(EN_TX_CRC_INS) // S10TIM Ok
   ) edic(
        .clk(clk),
        .sclr(sclr),

        .num_idle_rm(num_idle_rm),
        //.tx_crc_ins_en(tx_crc_ins_en_reg[2]), // S10TIM Ok
        .i_am(pre_din_am),
        .i_ena(enable[7]),
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

assign tag_sop_d = {tag_sop_rev[0], tag_sop_rev[1], tag_sop_rev[2], tag_sop_rev[3]};
assign tag_eop_d = {tag_eop_rev[0], tag_eop_rev[1], tag_eop_rev[2], tag_eop_rev[3]};
assign tags_d    = {tags_rev[2:0], tags_rev[5:3], tags_rev[8:6], tags_rev[11:9]};
assign tag_is_data_d[3:0] = {tags_d[4*3-1], tags_d[3*3-1], tags_d[2*3-1], tags_d[1*3-1]};
assign tag_data_empty_d = {tag_data_empty_rev[2:0], tag_data_empty_rev[5:3], tag_data_empty_rev[8:6], tag_data_empty_rev[11:9]};
assign tag_eop_empty_d = {tag_eop_empty_rev[2:0], tag_eop_empty_rev[5:3], tag_eop_empty_rev[8:6], tag_eop_empty_rev[11:9]};



always @(posedge clk) begin
   if (enable[8]) begin
      tag_sop <= tag_sop_d;
      tag_eop <= tag_eop_d;
      tags <= tags_d;
      tag_is_data <= tag_is_data_d;
      tag_data_empty <= tag_data_empty_d;
      tag_eop_empty <= tag_eop_empty_d;
   end 
end




wire [8*WORDS-1:0] tag_eop_pos;
wire [8*WORDS-1:0] tag_zero_pos;
reg  [8*WORDS-1:0] tag_zero_pos_r=0;
reg  [8*WORDS-1:0] tag_zero_pos_r2; // S10TIM
reg [3:0]          tag_dsop_r = 0, tag_dsop_r2 = 0;
reg [3:0]          tag_dsop_r3; // S10TIM

always @(posedge clk) begin
     if (enable[8]) begin 
        tags_r <= tags;
        tag_sop_r <= tag_sop;
        tag_eop_pos_r  <= tag_eop_pos;
        tag_zero_pos_r <= tag_zero_pos;
        tag_is_data_r <= tag_is_data; 
        tag_dsop_r  <= tag_dsop;
     end 
     tag_zero_pos_r2 <= tag_zero_pos_r; // S10TIM Ok
     tag_is_data_r2 <= tag_is_data_r; // S10TIM Ok
end
/*
generate
    for (i=0; i<WORDS; i=i+1) begin : dbuf_mux
        always @(*) begin
           case(tags_r[(i+1)*3-1:i*3])
              3'b111: dbuf_q[(i+1)*WIDTH-1:i*WIDTH] = dbuf_d[WIDTH-1:0];
              3'b110: dbuf_q[(i+1)*WIDTH-1:i*WIDTH] = dbuf_d[2*WIDTH-1:1*WIDTH];
              3'b101: dbuf_q[(i+1)*WIDTH-1:i*WIDTH] = dbuf_d[3*WIDTH-1:2*WIDTH];
              3'b100: dbuf_q[(i+1)*WIDTH-1:i*WIDTH] = dbuf_d[4*WIDTH-1:3*WIDTH];
              default:dbuf_q[(i+1)*WIDTH-1:i*WIDTH] = dbuf_d[(i+1)*WIDTH-1:i*WIDTH];
           endcase
        end
    end
endgenerate
*/

// S10TIM insert a pipe Ok
generate
    for (i=0; i<WORDS; i=i+1) begin : dbuf_mux
        always @(posedge clk) begin
           case(tags_r[(i+1)*3-1:i*3])
              3'b111: dbuf_q[(i+1)*WIDTH-1:i*WIDTH] <= dbuf_d[WIDTH-1:0];
              3'b110: dbuf_q[(i+1)*WIDTH-1:i*WIDTH] <= dbuf_d[2*WIDTH-1:1*WIDTH];
              3'b101: dbuf_q[(i+1)*WIDTH-1:i*WIDTH] <= dbuf_d[3*WIDTH-1:2*WIDTH];
              3'b100: dbuf_q[(i+1)*WIDTH-1:i*WIDTH] <= dbuf_d[4*WIDTH-1:3*WIDTH];
              default:dbuf_q[(i+1)*WIDTH-1:i*WIDTH] <= dbuf_d[(i+1)*WIDTH-1:i*WIDTH];
           endcase
        end
    end
endgenerate


////////////////////////////////////////////////////////////////////////
// move sop to the next word to skip preamble for CRC engine 
////////////////////////////////////////////////////////////////////////
assign tag_dsop[3] = tag_sop_r[0];
assign tag_dsop[2] = tag_sop[3];
assign tag_dsop[1] = tag_sop[2];
assign tag_dsop[0] = tag_sop[1];

wire [32+5-1:0]   tag_eop_pos_ext;
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


assign tag_eop_pos_ext = {tag_eop_pos_r[4:0], tag_eop_pos[31:0]};
//assign tag_term_pos[31:0] = tx_crc_ins_en_reg[3] ? tag_eop_pos_ext[36:5] : tag_eop_pos_ext[32:1];
assign tag_term_pos[31:0] = EN_TX_CRC_INS ? tag_eop_pos_ext[36:5] : tag_eop_pos_ext[32:1]; // S10TIM  Ok

generate
        for (i=0; i<WORDS; i=i+1) begin : eop_pos_w
           for (j=0; j<8; j=j+1) begin : eop_pos_b
               //assign tag_crc_pos[i*8+j] = tx_crc_ins_en_reg[0] ? |tag_eop_pos_ext[i*8+j+4:i*8+j+1] : 1'b0;
               assign tag_crc_pos[i*8+j] = EN_TX_CRC_INS ? |tag_eop_pos_ext[i*8+j+4:i*8+j+1] : 1'b0; // S10TIM Ok
           end
        end
endgenerate

////////////////////////////////////////////////////////////////////////
// Assume at least 6 bytes between frames for 
// 4 byte CRC + TERM + IDLE insertion
////////////////////////////////////////////////////////////////////////

//localparam SEL_PREAMBLE      = 3'b100;  // 64'hfb555555555555d5 provided from input
localparam SEL_PREAMBLE      = 3'b110;  // 64'hfb555555555555d5 provided from input // S10TIM : for new mx5r in s10 
//localparam SEL_TERM          = 3'b011;  // 8'hfd
localparam SEL_TERM          = 3'b100;  // 8'hfd // S1-TIM : for new mx5r in s10
localparam SEL_CRC_OR_PAD    = 3'b010;  // 8'h00
localparam SEL_IDLE          = 3'b001;  // 8'h07
localparam SEL_DATA          = 3'b000;  // DATA

localparam PREAMBLE          = 64'hfb555555555555d5; 

reg  [3*WORDS*8-1:0] sel = 0;
reg  [3*WORDS*8-1:0] sel_r = 0; // S10TIM Ok
always @(posedge clk) sel_r <= sel; // S10TIM Ok

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
reg eop_at_0123_r; // S10TIM Ok


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// If eop is at the last 4 bytes of the 32 bytes, crc_out result will be used at the flollowing cycle (too).
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
always @(posedge clk) begin
      eop_at_0123 <= tag_eop_pos_r[3] || tag_eop_pos_r[2] || tag_eop_pos_r[1] || tag_eop_pos_r[0];
      eop_at_0123_r <= eop_at_0123; // S10TIM Ok
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
                       //.sel(sel[(i*8+(j+1))*3-1:(i*8+j)*3]),
                       .sel(sel_r[(i*8+(j+1))*3-1:(i*8+j)*3]), // S10TIM Ok
                       .dout(dout_to_mlab_w[i*WIDTH+(j+1)*8-1:i*WIDTH+j*8])
                  );
                  defparam mx5_d . WIDTH = 8;

                  always @(posedge clk) begin
                        //dout_to_crc[i*WIDTH+(j+1)*8-1:i*WIDTH+j*8] <= dbuf_q[i*WIDTH+(j+1)*8-1:i*WIDTH + j*8] & {8{~tag_zero_pos_r[i*8+j]}} & {8{tag_is_data_r[i]}};
                        dout_to_crc[i*WIDTH+(j+1)*8-1:i*WIDTH+j*8] <= dbuf_q[i*WIDTH+(j+1)*8-1:i*WIDTH + j*8] & {8{~tag_zero_pos_r2[i*8+j]}} & {8{tag_is_data_r2[i]}}; // S10TIM Ok
                  end

                  // This is to fix the CRC error bug found in 40G HW test.
                  // if the garbage data in enable low cycles happen to be 'hfd
                  // and the control to be 1 (for preamble),
                  // the efd_match signal will go high unexpectedly.

                  //wire preamble_mux_c = (j==7);
                  //wire preamble_mux_c = (j==7) && enable_r;
                  wire preamble_mux_c = (j==7) && enable_r2; // S10TIM Ok
                  
                  mx5r mx5_c(
                       .clk(clk),
                       .din({preamble_mux_c,  // PREAMBLE
                             1'b1,  // TERM
                             1'b0,  // CRC or PADDING
                             1'b1,  // IDLE
                             1'b0   // DATA
                            }), 
                       //.sel(sel[(i*8+(j+1))*3-1:(i*8+j)*3]),
                       .sel(sel_r[(i*8+(j+1))*3-1:(i*8+j)*3]), // S10TIM Ok
                       .dout(cout_to_mlab_w[i*8+j])
                  );
                  defparam mx5_c . WIDTH = 1;
            end
         end
endgenerate


////////////////////////////////
// TX Error Insertion: Appending /E/ TAG
//

wire [3:0] tag_error;
reg [3:0] tag_eop_d1 = 4'b0000;
reg [3:0] tag_error_a = 4'b0000;

always @(posedge clk) begin
    tag_eop_d1   <=  tag_eop;
    tag_error_a  <= {tag_eop_d1[2:0], 1'b0} & {4{error}} ;
end

assign tag_error = tag_error_a | {3'b0, tag_eop_d1[3] & error} ;
reg [3:0] tag_error_r; // S10TIM Ok
always @(posedge clk) tag_error_r <= tag_error; // S10TIM Ok
// Insert error character 
generate
    for (i=0; i<WORDS; i=i+1) begin : terr_mux
        always @(*) begin   //was at time tag_error_d
            //dout_to_mlab[i*WIDTH+:8] = tag_error[i] ? 8'hFE : dout_to_mlab_w[i*WIDTH+:8] ;
            //cout_to_mlab[i*8] = tag_error[i] ? 1'b1 : cout_to_mlab_w[i*8] ; 
            dout_to_mlab[i*WIDTH+:8] = tag_error_r[i] ? 8'hFE : dout_to_mlab_w[i*WIDTH+:8] ; // S10TIM Ok
            cout_to_mlab[i*8] = tag_error_r[i] ? 1'b1 : cout_to_mlab_w[i*8] ;  // S10TIM Ok
            dout_to_mlab[(i*WIDTH+8)+:56] = dout_to_mlab_w[(i*WIDTH+8)+:56] ;
            cout_to_mlab[(i*8+1)+:7] = cout_to_mlab_w[(i*8+1)+:7] ;
        end
    end

endgenerate 

//////////////////////////////


     // ptp instantiation
  
//     defparam etp.TARGET_CHIP = TARGET_CHIP;
//     defparam etp.SYNOPT_PTP = SYNOPT_PTP;
//     defparam etp.PTP_LATENCY = PTP_LATENCY;
//     defparam etp.EN_LINK_FAULT = EN_LINK_FAULT;
//     defparam etp.PTP_FP_WIDTH = PTP_FP_WIDTH;
//     defparam etp.PTP_TS_WIDTH = PTP_TS_WIDTH;
  
  
     wire [WORDS*64-1:0] dout_crc_ptp;
     wire [WORDS*64-1:0] dout_mlab_ptp_w;
     reg [WORDS*64-1:0]  dout_mlab_ptp=0;
     wire [39:0]               mac_out_bus_ptp; // other data that needs to be pipelined
     //wire [WORDS-1:0]    dout_sops_ptp;
     //wire [WORDS*8-1:0]  dout_eop_pos_ptp;
     reg  [WORDS-1:0]    dout_sops_ptp; // S10TIM Ok
     reg  [WORDS*8-1:0]  dout_eop_pos_ptp; // S10TIM Ok
     wire              dout_valid_ptp;
  
     wire [39:0]               mac_in_bus;
  
     //assign mac_in_bus = {6'd0,cout_to_mlab ,eop_at_0123,enable_r2};
     assign mac_in_bus = {6'd0,cout_to_mlab ,eop_at_0123_r,enable_r3}; // S10TIM Ok
  
     //wire              enable_r2_ptp;
     wire              enable_r3_ptp; // S10TIM Ok
     wire [WORDS*8-1:0]  cout_to_mlab_ptp;
     wire              eop_at_0123_ptp;
     wire [1:0]                junk2;
     wire [3:0]                junk4;
  
//     wire [WORDS*64-1:0] dout_crc_ptx;
//     wire [WORDS*64-1:0] dout_mlab_ptx_w;
//     wire [WORDS*64-1:0]  dout_mlab_ptx;
//     wire [39:0]               mac_out_bus_ptx; // other data that needs to be pipelined
//     wire [WORDS-1:0]    dout_sops_ptx;
//     wire [WORDS*8-1:0]  dout_eop_pos_ptx;
     wire              dout_valid_ptx;

//     assign {junk6,cout_to_mlab_ptp,eop_at_0123_ptp,enable_r2_ptp} = mac_out_bus_ptp;
     assign {cout_to_mlab_ptp,eop_at_0123_ptp,enable_r3_ptp} = mac_out_bus_ptp[WORDS*8+1:0]; // S10TIM Ok
     
  
//     alt_e100s10_tx_pkt_100 etp
//       (
//        .arst(sclr),
//         .tod_txmac_in(tod_96b_txmac_in),
//        .ptp_v2(ptp_v2),
//        .ptp_s2(ptp_s2),
//        .ext_lat(ext_lat),
//        .din_ptp_dbg_adp(din_ptp_dbg_adp),
//        .din_valid(enable_r2),
//        .din_crc(dout_to_crc), // data to crc and data to malb is different !!!
//        .din_mlab(dout_to_mlab),  // data to crc and data to malb is different !!!
//        .mac_in_bus(mac_in_bus), // other data that needs to be pipelined
//        .din_sops(tag_dsop_r2),
//        .din_eop_pos(tag_eop_pos_r2),
//        .din_sop_adp(din_sop_adp),
//        .din_ptp_adp(din_ptp_adp),
//        .din_overwrite_adp(din_overwrite_adp),
//        .din_offset_adp(din_offset_adp),
//        .din_zero_tcp_adp(din_zero_tcp_adp),
//        .din_ptp_asm_adp(din_ptp_asm_adp),
//        .din_zero_offset_adp(din_zero_offset_adp),
////         .ts_out_cust_asm(ts_out_cust_asm),
////       .latency_ahead(latency_ahead),
// //       .latency_adj(latency_adj),
//
//        .dout_crc(dout_crc_ptx),
//        .dout_mlab(dout_mlab_ptx),
//        .mac_out_bus(mac_out_bus_ptx), // other data that needs to be pipelined
//        .dout_sops(dout_sops_ptx),
//        .dout_eop_pos(dout_eop_pos_ptx),
//        .dout_valid(),
//
//        .tod_cust_in(tod_cust_in),
//        .tod_exit_cust(tod_exit_cust),
////        .ts_out_cust(ts_out_cust),
//        .clk(clk)
//        );
   
   //  defparam ptx.TARGET_CHIP = TARGET_CHIP;
    // defparam ptx.SYNOPT_PTP = SYNOPT_PTP;
    // defparam ptx .SYNOPT_TOD_FMT = SYNOPT_TOD_FMT;
    // defparam ptx.PTP_LATENCY = PTP_LATENCY;
   //defparam ptx.ADF_TO_FLD_DLY = 17;
   //defparam ptx.DEL_CALC_DLY = 20;
   //defparam ptx.FD_DLY = 38;
    // defparam ptx.EN_LINK_FAULT = EN_LINK_FAULT;
     //defparam ptx.MAC_BUS_WIDTH = 40;
    // defparam ptx.WORDS = 4;
    // defparam ptx.PTP_FP_WIDTH = PTP_FP_WIDTH;
//     defparam ptx.PTP_TS_WIDTH = PTP_TS_WIDTH;

assign dout_mlab_ptp_w = dout_to_mlab;
assign mac_out_bus_ptp = mac_in_bus;
//assign dout_sops_ptp = tag_dsop_r2;
//assign dout_eop_pos_ptp = tag_eop_pos_r2;
//
// S10TIM: one more pipe Ok
reg [WORDS-1:0]		dout_eops_ptp;
reg [WORDS*3-1:0]	dout_eops_empty;
always @(posedge clk) begin
        dout_sops_ptp <= tag_dsop_r2;
        dout_eop_pos_ptp <= tag_eop_pos_r2;
	dout_eops_ptp <= {|tag_eop_pos_r2[31:24], |tag_eop_pos_r2[23:16], |tag_eop_pos_r2[15:8], |tag_eop_pos_r2[7:0]};
	if (tag_eop_pos_r2[24+7])	dout_eops_empty[11:9] <= 3'h7;
	else if (tag_eop_pos_r2[24+6])	dout_eops_empty[11:9] <= 3'h6;
	else if (tag_eop_pos_r2[24+5])	dout_eops_empty[11:9] <= 3'h5;
	else if (tag_eop_pos_r2[24+4])	dout_eops_empty[11:9] <= 3'h4;
	else if (tag_eop_pos_r2[24+3])	dout_eops_empty[11:9] <= 3'h3;
	else if (tag_eop_pos_r2[24+2])	dout_eops_empty[11:9] <= 3'h2;
	else if (tag_eop_pos_r2[24+1])	dout_eops_empty[11:9] <= 3'h1;
	else				dout_eops_empty[11:9] <= 3'h0;
	if (tag_eop_pos_r2[16+7])	dout_eops_empty[8:6] <= 3'h7;
	else if (tag_eop_pos_r2[16+6])	dout_eops_empty[8:6] <= 3'h6;
	else if (tag_eop_pos_r2[16+5])	dout_eops_empty[8:6] <= 3'h5;
	else if (tag_eop_pos_r2[16+4])	dout_eops_empty[8:6] <= 3'h4;
	else if (tag_eop_pos_r2[16+3])	dout_eops_empty[8:6] <= 3'h3;
	else if (tag_eop_pos_r2[16+2])	dout_eops_empty[8:6] <= 3'h2;
	else if (tag_eop_pos_r2[16+1])	dout_eops_empty[8:6] <= 3'h1;
	else				dout_eops_empty[8:6] <= 3'h0;
	if (tag_eop_pos_r2[8+7])	dout_eops_empty[5:3] <= 3'h7;
	else if (tag_eop_pos_r2[8+6])	dout_eops_empty[5:3] <= 3'h6;
	else if (tag_eop_pos_r2[8+5])	dout_eops_empty[5:3] <= 3'h5;
	else if (tag_eop_pos_r2[8+4])	dout_eops_empty[5:3] <= 3'h4;
	else if (tag_eop_pos_r2[8+3])	dout_eops_empty[5:3] <= 3'h3;
	else if (tag_eop_pos_r2[8+2])	dout_eops_empty[5:3] <= 3'h2;
	else if (tag_eop_pos_r2[8+1])	dout_eops_empty[5:3] <= 3'h1;
	else				dout_eops_empty[5:3] <= 3'h0;
	if (tag_eop_pos_r2[7])		dout_eops_empty[2:0] <= 3'h7;
	else if (tag_eop_pos_r2[6])	dout_eops_empty[2:0] <= 3'h6;
	else if (tag_eop_pos_r2[5])	dout_eops_empty[2:0] <= 3'h5;
	else if (tag_eop_pos_r2[4])	dout_eops_empty[2:0] <= 3'h4;
	else if (tag_eop_pos_r2[3])	dout_eops_empty[2:0] <= 3'h3;
	else if (tag_eop_pos_r2[2])	dout_eops_empty[2:0] <= 3'h2;
	else if (tag_eop_pos_r2[1])	dout_eops_empty[2:0] <= 3'h1;
	else				dout_eops_empty[2:0] <= 3'h0;
end

assign dout_crc_ptp = dout_to_crc;

generate 
    // TX Error Insertion: Re-appending /E/ if overwritten by PTP 
    if (SYNOPT_PTP) begin

        wire [3:0] tag_error_ptp;
        alt_e100s10_dly_mlab det (
            .clk(clk),
            //.din(tag_error),
            .din(tag_error_r), // S10TIM Ok
            .dout(tag_error_ptp)
        );
        defparam det .WIDTH = 4;
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


///////////////////////////////////////////////////////
// delay tags to line up with dout_to_mlab
///////////////////////////////////////////////////////
always @(posedge clk) begin
     tag_dsop_r2 <= tag_dsop_r;
     tag_eop_pos_r2  <= tag_eop_pos_r;
     tag_dsop_r3 <= tag_dsop_r2; // S10TIM Ok
     tag_eop_pos_r3  <= tag_eop_pos_r2; // S10TIM Ok
end

always @(posedge clk) begin
    am_hist <= am_hist << 1 | {20'b0,pre_din_am};
    enable <= {9{!pre_din_am}};
    enable_r <= enable[8];
    enable_r2 <= enable_r;
    enable_r3 <= enable_r2; // S10TIM Ok
end




////////////////////////////////////////////
// CRC Insertion Logic
////////////////////////////////////////////
generate
   if (EN_TX_CRC_INS) begin

wire crc_valid;
wire [31:0] crc_out;
reg  [31:0] crc_out_r = 0;
reg  [31:0] crc_to_mii=0;

ecrc_4 fcs (
        .clk(clk),

        //.din_valid(enable_r2_ptp),              
        .din_valid(enable_r3_ptp),    // S10TIM Ok         
        .din(dout_crc_ptp),          
        .din_first_data(dout_sops_ptp),
        .din_last_data(dout_eop_pos_ptp), 
        
        .crc_valid(crc_valid),
        .crc_out(crc_out)       
);
defparam fcs .TARGET_CHIP = TARGET_CHIP;
defparam fcs .REDUCE_LATENCY = REDUCE_CRC_LAT;

always @(posedge clk) crc_out_r <= crc_out;

////////////////////////////////////////////////////
// delay data/control to match CRC latency
////////////////////////////////////////////////////

wire [4*WIDTH-1:0] upk_d_mlab;
wire [4*8-1:0] upk_c_mlab;
wire     upk_e_mlab;
reg  [4*WIDTH-1:0] upk_d=0;
reg  [4*8-1:0] upk_c=0;
reg      upk_e=0;
wire dr0_null_bits;

delay_mlab dr0 (
        .clk(clk),
        .din({1'b0,eop_at_0123_ptp, cout_to_mlab_ptp, dout_mlab_ptp}),
        .dout({dr0_null_bits,upk_e_mlab, upk_c_mlab, upk_d_mlab})
);
defparam dr0 .WIDTH = WORDS*(WIDTH + 8) + 2;
defparam dr0 .LATENCY = REDUCE_CRC_LAT ? 7 : 11; 
defparam dr0 .TARGET_CHIP = TARGET_CHIP;
defparam dr0 .FRACTURE = 10;

// replace the last pipe of mlab with f/f for better timing
always @(posedge clk) {upk_e, upk_c, upk_d} <= {upk_e_mlab, upk_c_mlab, upk_d_mlab};

     //////////////////////////////////////////////////
     // figure out where the FCS is needed
     //////////////////////////////////////////////////
reg last_upk_e=0, last2_upk_e=0, last3_upk_e=0;
reg [4*8-1:0] efd_match = 0, last_efd_match = 0;
     for (i=0; i<8*4; i=i+1) begin : ecmp
        always @(posedge clk) begin
                efd_match[i] <= (upk_d[(i+1)*8-1:i*8] == TERM) && upk_c[i];
        end
     end

// four FCS bytes are right before the end delimiter
always @(posedge clk) begin
        last_efd_match <= efd_match;
        last_upk_e <= upk_e;
        last2_upk_e <= last_upk_e;
        last3_upk_e <= last2_upk_e;
end

wire [31:0] first_fcs = {last_efd_match[27:0],efd_match[31:28]};
wire [31:0] second_fcs = {last_efd_match[28:0],efd_match[31:29]};
wire [31:0] third_fcs = {last_efd_match[29:0],efd_match[31:30]};
wire [31:0] fourth_fcs = {last_efd_match[30:0],efd_match[31]};

//assign crc_to_mii = (first_fcs[31] || second_fcs[31] || third_fcs[31] || fourth_fcs[31]) ? crc_out_r : crc_out; // this is right but timing not good
//assign crc_to_mii = last3_upk_e ? crc_out_r : crc_out; // use this one instead 

always @(posedge clk) crc_to_mii <= last3_upk_e ? crc_out_r : crc_out;

//wire good_sel = (first_fcs[31] || second_fcs[31] || third_fcs[31] || fourth_fcs[31]);
//assign crc_valid_to_mii = (first_fcs[31] || second_fcs[31] || third_fcs[31] || fourth_fcs[31]) ? crc_valid_r : crc_valid;

//wire [4*8*3-1:0] src_select /* synthesis keep */;
reg  [4*8*3-1:0] src_select=0 /* synthesis keep */;
//generate
        for (i=0; i<8*4; i=i+1) begin : srcs
                always @(posedge clk) src_select[(i+1)*3-1:i*3] <= 
                        first_fcs[i] ? 3'h4 :
                        second_fcs[i] ? 3'h5 :
                        third_fcs[i] ? 3'h6 :
                        fourth_fcs[i] ? 3'h7 :
                        3'h0;
        end
//endgenerate

reg [4*WIDTH-1:0] last_upk_d = 0, last2_upk_d = 0, last3_upk_d=0;
reg [4*8-1:0] last_upk_c = 0, last2_upk_c = 0, last3_upk_c=0;

always @(posedge clk) begin
                last3_upk_d <= last2_upk_d;
                last2_upk_d <= last_upk_d;
                last3_upk_c <= last2_upk_c;
                last2_upk_c <= last_upk_c;
                last_upk_d <= upk_d;
                last_upk_c <= upk_c;
end


//assign next_is_am = !tx_crc_ins_en ? am_hist[2] : REDUCE_CRC_LAT ? am_hist[13] : am_hist[17]; 
//assign next_is_am = SYNOPT_PTP ? !tx_crc_ins_en_reg[1] ? am_hist[2+PTP_LATENCY] : REDUCE_CRC_LAT ? am_hist[13+PTP_LATENCY] : am_hist[17+PTP_LATENCY]:
//                                   !tx_crc_ins_en_reg[1] ? am_hist[2]             : REDUCE_CRC_LAT ? am_hist[13]             : am_hist[17]; 
//assign next_is_am = SYNOPT_PTP ? (EN_TX_CRC_INS==0) ? am_hist[2+PTP_LATENCY] : REDUCE_CRC_LAT ? am_hist[13+PTP_LATENCY] : am_hist[17+PTP_LATENCY]:
//                                   (EN_TX_CRC_INS==0) ? am_hist[2]             : REDUCE_CRC_LAT ? am_hist[13]             : am_hist[17];  // S10TIM Ok
assign next_is_am = SYNOPT_PTP ? (EN_TX_CRC_INS==0) ? am_hist[3+PTP_LATENCY] : REDUCE_CRC_LAT ? am_hist[14+PTP_LATENCY] : am_hist[18+PTP_LATENCY]:
                                   (EN_TX_CRC_INS==0) ? am_hist[3]             : REDUCE_CRC_LAT ? am_hist[14]             : am_hist[18];  // S10TIM

// //assign next_is_am = !tx_crc_ins_en ? am_hist[2] : REDUCE_CRC_LAT ? am_hist[12] : am_hist[16]; 
// assign next_is_am = !tx_crc_ins_en ? am_hist[2] : REDUCE_CRC_LAT ? am_hist[13] : am_hist[17]; 

////////////////////////////////////////////////////
// Merge CRC result into mii data/control
////////////////////////////////////////////////////

always @(posedge clk) begin
        if (!next_is_am) begin
                //mii_c <= tx_crc_ins_en_reg[2] ? last3_upk_c : cout_to_mlab_ptp;
                mii_c <= EN_TX_CRC_INS ? last3_upk_c : cout_to_mlab_ptp; // S10TIM Ok
                mii_valid_reg <= 1'b1;
    end
    else begin
        mii_c <= 32'hff_ff_ff_ff;
        mii_valid_reg <= 1'b0;
    end
end
      
        for (i=0; i<8*4; i=i+1) begin : cmux
                wire [2:0] local_sel = src_select[(i+1)*3-1:i*3];
                always @(posedge clk) begin
                    if (!next_is_am) begin
                        //if (!tx_crc_ins_en_reg[3]) begin
                        if (EN_TX_CRC_INS==0) begin // S10TIM Ok
                                mii_d [(i+1)*8-1:i*8] <= dout_mlab_ptp[(i+1)*8-1:i*8];
                        end
                        else if (!local_sel[2]) begin
                                mii_d [(i+1)*8-1:i*8] <= last3_upk_d[(i+1)*8-1:i*8];
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
      //assign next_is_am = am_hist[2]; 
      assign next_is_am = am_hist[3]; // S10TIM 
      always @(posedge clk) begin
        if (!next_is_am) begin
                mii_c <= cout_to_mlab_ptp;
                mii_valid_reg <= 1'b1;
        end
        else begin
                mii_c <= 32'hff_ff_ff_ff;
                mii_valid_reg <= 1'b0;
        end
       end
      
       for (i=0; i<8*4; i=i+1) begin : cmux2
              always @(posedge clk) begin
                  if (!next_is_am) mii_d [(i+1)*8-1:i*8] <= dout_mlab_ptp[(i+1)*8-1:i*8];
                  else             mii_d [(i+1)*8-1:i*8] <= IDLE;
              end
       end
   end
endgenerate

assign mii_valid = mii_valid_reg;


generate 
   if (EN_LINK_FAULT) begin
////////////////////////////////////////
// Link Fault generator
///////////////////////////////////////
      alt_e100s10_mac_link_fault_gen  mac_link_fault_gen
      (
         .clk(clk),
         .reset(sclr), //this input has not logic connect to it
         .cfg_unidirectional_en(cfg_unidirectional_en),
         .cfg_en_link_fault_gen(cfg_en_link_fault_gen),
         .cfg_unidir_en_disable_rf (cfg_unidir_en_disable_rf),
         .cfg_force_rf             (cfg_force_rf            ),

         .remote_fault_status(remote_fault_status),
         .local_fault_status(local_fault_status),
         .mii_c_in(mii_c),
         .mii_d_in(mii_d),
         .mii_valid_in(mii_valid),
         .mii_c_out(tx_mii_c),
         .mii_d_out(tx_mii_d),
         .mii_valid_out(tx_mii_valid)
      );
   end
   else begin
      assign tx_mii_c = mii_c;
      assign tx_mii_d = mii_d;
      assign tx_mii_valid = mii_valid;
   end
endgenerate





//////////////////////////
// for happy debugging
//////////////////////////

// synthesis translate_off
wire [WIDTH-1:0] din_w0 = din[WIDTH-1:0];
wire [WIDTH-1:0] din_w1 = din[2*WIDTH-1:1*WIDTH];
wire [WIDTH-1:0] din_w2 = din[3*WIDTH-1:2*WIDTH];
wire [WIDTH-1:0] din_w3 = din[4*WIDTH-1:3*WIDTH];

wire [WIDTH-1:0] mii_d_w0 = mii_d[WIDTH-1:0];
wire [WIDTH-1:0] mii_d_w1 = mii_d[2*WIDTH-1:1*WIDTH];
wire [WIDTH-1:0] mii_d_w2 = mii_d[3*WIDTH-2:2*WIDTH];
wire [WIDTH-1:0] mii_d_w3 = mii_d[4*WIDTH-3:3*WIDTH];

wire [WIDTH-1:0] dbuf_q_w0 = dbuf_q[WIDTH-1:0];
wire [WIDTH-1:0] dbuf_q_w1 = dbuf_q[2*WIDTH-1:1*WIDTH];
wire [WIDTH-1:0] dbuf_q_w2 = dbuf_q[3*WIDTH-1:2*WIDTH];
wire [WIDTH-1:0] dbuf_q_w3 = dbuf_q[4*WIDTH-1:3*WIDTH];

wire [WIDTH-1:0] dout_to_mlab_w0 = dout_mlab_ptp[WIDTH-1:0];
wire [WIDTH-1:0] dout_to_mlab_w1 = dout_mlab_ptp[2*WIDTH-1:1*WIDTH];
wire [WIDTH-1:0] dout_to_mlab_w2 = dout_mlab_ptp[3*WIDTH-1:2*WIDTH];
wire [WIDTH-1:0] dout_to_mlab_w3 = dout_mlab_ptp[4*WIDTH-1:3*WIDTH];
// synthesis translate_on

 // _________________________________________________________________
 //     tx csr register module
 // _________________________________________________________________

   //wire serif_stats_dout; 
   //wire serif_mac_dout;
   //assign serif_slave_dout = serif_mac_dout & serif_stats_dout;

   wire [15:0] cfg_max_fsize;

   //wire[17:0] cfg_pld_length_chk      ;
   // wire cfg_pld_length_chk      ;
   wire cfg_pld_length_include_vlan     ;


   alt_e100s10_mac_tx_csr #(
         .BASE                  (BASE_TXMAC)
        ,.REVID                 (REVID)
        ,.ADDRSIZE              (CSRADDRSIZE) 
        ,.TARGET_CHIP           (TARGET_CHIP) 
   ) mactx_csr(
         .clk_tx                (clk)
        ,.reset_tx              (sclr)      //this input has not logic connect to it
        ,.clk_csr               (clk_csr)
        ,.reset_csr             (reset_csr) //this input has not logic connect to it
        //,.serif_master_din    (serif_slave_din)
        //,.serif_slave_dout    (serif_mac_dout)
        ,.write                 (write)
        ,.read                  (read)
        ,.address               (address)
        ,.writedata             (writedata)
        ,.readdata              (readdata)
        ,.readdatavalid         (readdatavalid)

        ,.cfg_max_fsize                 (cfg_max_fsize) 
        ,.cfg_pld_length_include_vlan   (cfg_pld_length_include_vlan)       
        ,.cfg_link_fault_gen_en   (cfg_en_link_fault_gen)
        ,.cfg_link_fault_unidir_en(cfg_unidirectional_en)
        ,.cfg_link_fault_unidir_en_disable_rf  (cfg_unidir_en_disable_rf     )
        ,.cfg_link_fault_force_rf              (cfg_force_rf                 )
        ,.cfg_ipg_col_rem         (num_idle_rm)
        ,.cfg_tx_crc_ins_en_4debug(cfg_tx_crc_ins_en_4debug)
        );

//--------------------------------------
//---tx stats vector---
//--------------------------------------
//---tap at crc generator input port;
alt_e100s10_sv #(       .SIM_EMULATE            (SIM_EMULATE),
                        .SYNOPT_PREAMBLE_PT     (1'b0),	//(EN_PREAMBLE_PASS_THROUGH),
                        .WORDS                  (WORDS) )
   u_tx_stats_vector (
	.clk			(clk),
	.reset			(sclr),

	.cfg_crc_included	(!tx_crc_ins_en),
	.cfg_max_frm_length	(cfg_max_fsize),
	.cfg_vlandet_disable	(cfg_pld_length_include_vlan),	//TBD (cfg_vlandet_disable),
     
	.frm_valid		(enable_r3_ptp),
	.frm_data		(dout_crc_ptp),
	.frm_sop		(dout_sops_ptp),
	.frm_eop		(dout_eops_ptp),
	.frm_eop_empty		(dout_eops_empty),
    
	.stats			(tx_stats),
	.stats_valid		(tx_stats_valid),
	.frm_error		(tx_stats_error)
);

// _________________________________________________________________
endmodule
