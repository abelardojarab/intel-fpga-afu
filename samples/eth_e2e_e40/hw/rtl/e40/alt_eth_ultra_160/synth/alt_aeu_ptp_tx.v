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


// $Id: //acds/main/ip/ethernet/alt_eth_ultra_100g/rtl/pcs/e100_rx_pcs_4.v#1 $
// $Revision: #1 $
// $Date: 2013/02/27 $
// $Author: rkane $
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module alt_aeu_ptp_tx #(
    parameter SYNOPT_PTP_96B = 1, // ts values are 96 bits not 64
    parameter SYNOPT_TOD_FMT = 0,
    parameter SYNOPT_PTP_1STEP = 1,
    parameter PTP_FP_WIDTH = 16,
    parameter PTP_TS_WIDTH = 96,
    parameter W2_WIDTH = 9,
    parameter W2_WIDTH_FD1 = 9,
    parameter W2_WIDTH_FD2 = 7,
    parameter W2_WIDTH_FD3 = 1,
    parameter MAC_BUS_WIDTH = 20,

    parameter SOP_TO_ADF_DLY = 3,
    parameter ADF_TO_FLD_DLY = 25,
    parameter DEL_CALC_DLY = 12,
    parameter FD_DLY = 47,

    parameter TARGET_CHIP = 2, // 2: stratix v, 5: arria 10
    parameter SYNOPT_CAUI4 = 0,
    parameter SYNOPT_PTP = 1,
    parameter PTP_LATENCY = 42,
    parameter EN_LINK_FAULT = 0,
    parameter WORDS = 4 // 4 for 100G
    )    
   (
    input srst,

    input [19:0] txmclk_period,
    input [18:0] tx_asym_delay,
    input [31:0] ext_lat,
    input [31:0] tx_pma_delay,
    input cust_mode,
    input [95:0] tod_96b_txmac_in,
    input [63:0] tod_64b_txmac_in,
    // all signals at the adapter interface are _adp
    // stored in fifo
    // opoed when sop from MAC comes in
    // egress timestamp related functionality
    input din_sop_adp,
    input ts_out_req_adp,

    input [PTP_FP_WIDTH-1:0] fp_out_req_adp,
    output [160-1:0] ts_exit,
    output ts_exit_valid,
    output [PTP_FP_WIDTH-1:0] fp_out,

    // insert the timestamp   
    input ins_ts_adp,
    input ins_ts_format_adp, // 0 for ptp_v2, 1 for ptp_v1
    input tx_asym_adp,

    input upd_corr_adp,
    input [95:0] ing_ts_96_adp, // ingress timestamp
    input [63:0] ing_ts_64_adp, // ingress timestamp
    input corr_format_adp,

    // checksum related options
    input chk_sum_zero_adp, // set check sum to 0
    input chk_sum_upd_adp, // correct the check sum

    // offsets for the reqd fields
    input [15:0] ts_offset_adp,
    input [15:0] corr_offset_adp,
    input [15:0] chk_sum_zero_offset_adp,
    input [15:0] chk_sum_upd_offset_adp,

    // inputs from mac    
    input din_valid,
    input [WORDS*64-1:0] din_crc, // data to crc and data to malb is different !!!
    input [WORDS*64-1:0] din_mlab,  // data to crc and data to malb is different !!!
    input [MAC_BUS_WIDTH-1:0] mac_in_bus, // other data that needs to be pipelined
    input [WORDS-1:0] din_sops,
    input [WORDS*8-1:0] din_eop_pos,

    output dout_valid,
    output [WORDS*64-1:0] dout_crc,
    output [WORDS*64-1:0] dout_mlab,
    output [MAC_BUS_WIDTH-1:0] mac_out_bus, // other data that needs to be pipelined
    output [WORDS-1:0]    dout_sops,
    output [WORDS*8-1:0]  dout_eop_pos,

    // proprietary interface
    input din_ptp_asm_adp,
    input [95:0] tod_cust_in,
    output [95:0] tod_exit_cust,
    output [95:0] ts_out_cust,
    output ts_out_cust_asm,

    input clk
);

    wire rd_ing_ts_96;
    wire [95:0] ing_ts_96_2calc;
 
    // Latency is 3 cycles
    wire                    ts_out_req_adf;
    wire [PTP_FP_WIDTH-1:0] fp_out_req_adf;
    wire                    ins_ts_adf;
    wire                    ins_ts_format_adf;
    wire                    tx_asym_adf;
    wire                    upd_corr_adf;
    wire [95:0]             ing_ts_96_adf;
    wire [63:0]             ing_ts_64_adf;
    wire                    corr_format_adf;
    wire                    chk_sum_zero_adf;
    wire                    chk_sum_upd_adf;
    wire [15:0]             ts_offset_adf;
    wire [15:0]             corr_offset_adf;
    wire [15:0]             chk_sum_zero_offset_adf;
    wire [15:0]             chk_sum_upd_offset_adf;
    wire                    ptp_asm_adf;
    wire                    cust_if_adf;
 
    wire [4:0]              offset_adj_adf;
    wire                    dout_sop_adf;
    wire                    din_ptp_dbg_adp;
    
    wire [5:0]              calc_ctrl_adf;
    wire [2:0]              extr_adf;
    wire [2:0]              spl_hndl_adf;
    wire                    todi_write_ff;
 
    wire [15:0]             cyc_ahd;
 
    wire                    ts_out_req_valid;
    wire                    ins_ts_valid;
    wire                    ptp_asm_valid;
    wire                    ins_ts_format_one_st;

    // din_sops are 'x' initially
    // to take care of these x's sops are held to 0 for 256 cycles after srst
    generate
        if (SYNOPT_PTP == 1) begin: ptp1
            reg [7:0]                cnt;
            reg [WORDS-1:0]            sop_ands;

            always @(posedge clk) begin
                if (srst) begin
                    sop_ands <= {WORDS{1'b0}};
                    cnt <= 8'd0;
                end
                else begin
                    if (cnt != 8'hff) cnt <= cnt + 8'd1;
                    if (cnt == 8'hff) sop_ands <= {WORDS{1'b1}};
                end // else: !if(srst)
            end // always @ (posedge clk)

            reg [WORDS-1:0] din_sops_modin;

            always @(*) begin
                din_sops_modin = din_sops & sop_ands;
            end

            alt_aeu_cyc_ahd ahd (
                .din_valid(din_valid),
                .cyc_ahd(cyc_ahd),
                .clk(clk)
            );

            defparam ahd.WORDS = WORDS;

            reg [ADF_TO_FLD_DLY-1:0] fld_out_fifo;
            reg [ADF_TO_FLD_DLY-1:0] fld1_out_fifo;
            reg [ADF_TO_FLD_DLY-1:0] fld2_out_fifo;
            reg [ADF_TO_FLD_DLY-1:0] fld3_out_fifo;
            wire todi_write_adf;
           
            alt_aeu_adp_ff adf (
                .srst(srst),
                .din_sop_adp(din_sop_adp),
                .din_sops(din_sops_modin),
                .din_valid(din_valid),
                .ts_out_req_adp(ts_out_req_adp),
                .fp_out_req_adp(fp_out_req_adp),
                .ins_ts_adp(ins_ts_adp),
                .ins_ts_format_adp(ins_ts_format_adp),
                .tx_asym_adp(tx_asym_adp),
                .upd_corr_adp(upd_corr_adp),
                .din_ptp_asm_adp(din_ptp_asm_adp),
                .din_cust_if_adp(upd_corr_adp&cust_mode),
                .ing_ts_96_adp(ing_ts_96_adp),
                .ing_ts_64_adp(ing_ts_64_adp),
                .corr_format_adp(corr_format_adp),
                .chk_sum_zero_adp(chk_sum_zero_adp),
                .chk_sum_upd_adp(chk_sum_upd_adp),
                .ts_offset_adp(ts_offset_adp),
                .corr_offset_adp(corr_offset_adp),
                .chk_sum_zero_offset_adp(chk_sum_zero_offset_adp),
                .chk_sum_upd_offset_adp(chk_sum_upd_offset_adp),
                .ts_out_req_ff(ts_out_req_adf),
                .fp_out_req_ff(fp_out_req_adf),
                .ins_ts_ff(ins_ts_adf),
                .ins_ts_format_ff(ins_ts_format_adf),
                .tx_asym_ff(tx_asym_adf),
                .upd_corr_ff(upd_corr_adf),
                .ing_ts_96_ff(ing_ts_96_adf),
                .ing_ts_64_ff(ing_ts_64_adf),
                .corr_format_ff(corr_format_adf),
                .chk_sum_zero_ff(chk_sum_zero_adf),
                .chk_sum_upd_ff(chk_sum_upd_adf),
                .ptp_asm_ff(ptp_asm_adf),
                .cust_if_ff(cust_if_adf),
                .ts_offset_ff(ts_offset_adf),
                .corr_offset_ff(corr_offset_adf),
                .chk_sum_zero_offset_ff(chk_sum_zero_offset_adf),
                .chk_sum_upd_offset_ff(chk_sum_upd_offset_adf),
                .calc_ctrl_ff(calc_ctrl_adf),
                .extr_ff(extr_adf),
                .spl_hndl_ff(spl_hndl_adf),
                .todi_write_ff(todi_write_adf),
                .dout_sop(dout_sop_adf),
                .offset_adj(offset_adj_adf),
                .din_ptp_dbg_adp(din_ptp_dbg_adp),
                .clk(clk)
            );

            defparam adf.SYNOPT_PTP_96B = SYNOPT_PTP_96B;
            defparam adf.PTP_FP_WIDTH = PTP_FP_WIDTH;
            defparam adf.PTP_TS_WIDTH = PTP_TS_WIDTH;
            defparam adf.TARGET_CHIP = TARGET_CHIP;
            defparam adf.WORDS = WORDS;

            wire [15:0]                ts_offset_out_ofs;
            wire [15:0]                corr_offset_out_ofs;
            wire [15:0]                chk_sum_zero_offset_out_ofs;
            wire [15:0]                chk_sum_upd_offset_out_ofs;

            alt_aeu_adj_offset ofs (
                .srst(srst),
                .offset_adj(offset_adj_adf),
                .ts_offset_in(ts_offset_adf),
                .corr_offset_in(corr_offset_adf),
                .chk_sum_zero_offset_in(chk_sum_zero_offset_adf),
                .chk_sum_upd_offset_in(chk_sum_upd_offset_adf),
                .ts_offset_out(ts_offset_out_ofs),
                .corr_offset_out(corr_offset_out_ofs),
                .chk_sum_zero_offset_out(chk_sum_zero_offset_out_ofs),
                .chk_sum_upd_offset_out(chk_sum_upd_offset_out_ofs),
                .clk(clk)
            );

            // total latency of dt1 and dm1 is 3 cycles including flops at inputs and outputs
            wire [WORDS*64-1:0]        dout_crc_dt1;
            wire [WORDS-1:0]        dout_sops_dt1;
            wire [WORDS*8-1:0]        dout_eop_pos_dt1;
            wire                    dout_valid_dt1;

            wire [6:0]                junk7, junk7_1;
            wire [3:0]                junk4, junk4_1;
            alt_aeu_dly_3_cyc dt1 (
                .clk(clk),
                .din({7'd0,din_valid,din_sops_modin,din_eop_pos,din_crc}),
                .dout({junk7,dout_valid_dt1,dout_sops_dt1,dout_eop_pos_dt1,dout_crc_dt1})
            );

            defparam dt1.WIDTH = 7+1+WORDS+WORDS*8+WORDS*8*8;

            wire [WORDS*64-1:0]        dout_mlab_dm1;

            alt_aeu_dly_3_cyc dm1 (
                .clk(clk),
                .din({4'd0,din_mlab}),
                .dout({junk4,dout_mlab_dm1})
            );

            defparam dm1.WIDTH = 4+WORDS*64;
           
            wire [95:0] nvl_96_fd1_clc;
            wire [63:0] nvl_64_fd1_clc;
            wire [(W2_WIDTH_FD2+1)*8-1:0]   nvl_fd2_clc;
            wire [(W2_WIDTH_FD3+1)*8-1:0]   nvl_fd3_clc;

            always @(posedge clk) begin
                if (srst) begin
                    fld_out_fifo <= {ADF_TO_FLD_DLY{1'b0}};
                    fld1_out_fifo <= {ADF_TO_FLD_DLY{1'b0}};
                    fld2_out_fifo <= {ADF_TO_FLD_DLY{1'b0}};
                    fld3_out_fifo <= {ADF_TO_FLD_DLY{1'b0}};
                end
                else begin
                    fld_out_fifo <= {fld_out_fifo[(ADF_TO_FLD_DLY-2):0],dout_sop_adf&(calc_ctrl_adf[5]|calc_ctrl_adf[4]|calc_ctrl_adf[2]|calc_ctrl_adf[0])};
                    fld1_out_fifo <= {fld1_out_fifo[(ADF_TO_FLD_DLY-2):0],dout_sop_adf & ins_ts_adf};
                    fld2_out_fifo <= {fld2_out_fifo[(ADF_TO_FLD_DLY-2):0],dout_sop_adf & upd_corr_adf};
                    fld3_out_fifo <= {fld3_out_fifo[(ADF_TO_FLD_DLY-2):0],dout_sop_adf&(chk_sum_upd_adf|chk_sum_zero_adf)};
                end
            end

            reg [DEL_CALC_DLY-1:0]                    dly1_calc_fifo;
            reg [DEL_CALC_DLY-1+1:0]                  dly2_calc_fifo;
            reg [DEL_CALC_DLY-1+2:0]                  dly3_calc_fifo;
            always @(posedge clk) begin
                if (srst) begin
                    dly1_calc_fifo <= {DEL_CALC_DLY{1'b0}};
                    dly2_calc_fifo <= {(DEL_CALC_DLY+1){1'b0}};
                    dly3_calc_fifo <= {(DEL_CALC_DLY+2){1'b0}};
                end
                else begin
                    dly1_calc_fifo <= {dly1_calc_fifo[(DEL_CALC_DLY-2):0],fld1_out_fifo[ADF_TO_FLD_DLY-1]};
                    dly2_calc_fifo <= {dly2_calc_fifo[(DEL_CALC_DLY-2+1):0],fld2_out_fifo[ADF_TO_FLD_DLY-1]};
                    dly3_calc_fifo <= {dly3_calc_fifo[(DEL_CALC_DLY-2+2):0],fld3_out_fifo[ADF_TO_FLD_DLY-1]};
                end
            end

            wire old_val_read_fd1;
            wire nvl_valid_fd1_int;
            wire [(W2_WIDTH_FD1+1)*8-1:0] nvl_fd1;
            assign nvl_fd1 = ins_ts_format_one_st ? {nvl_96_fd1_clc[79:16],16'd0} : nvl_96_fd1_clc[95:16];

            wire [(W2_WIDTH_FD1+1)*8-1:0] old_val_fd1;
            wire                      empty_ff_fd1;
            wire                      old_val_valid_fd1;
            wire [WORDS*64-1:0]          dout_fd1;
            wire [WORDS*8-1:0]          dout_mask_fd1;
            wire                      dout_valid_fd1;

            wire cust_if_valid;
            alt_aeu_ptp_fld fd1 (
                .srst(srst),
                .fld(2'b01),
                .din_valid(dout_valid_dt1),
                .din_sop(dout_sop_adf),
                .din_extr(extr_adf[0]),
                .din_spl_hndl(spl_hndl_adf[0]),
                .din_wr_off(~(chk_sum_upd_adf)|cust_if_adf),
                .din_ptp_asm(2'b00),
                .din(dout_crc_dt1),
                .din_offset(ts_offset_adf),
                .din_offset_adj(offset_adj_adf),
  
                .old_val_read(old_val_read_fd1),
                .old_ff_empty(empty_ff_fd1),
                .nvl_valid(nvl_valid_fd1_int & ins_ts_valid & ~(cust_if_valid)),
                .nvl(nvl_fd1),
                .old_val_offset_lsb(),
                .old_val(old_val_fd1),
                .old_val_valid(old_val_valid_fd1),
                .dout(dout_fd1),
                .dout_mask(dout_mask_fd1),
                .dout_valid(dout_valid_fd1),
                .clk(clk)
            );

            defparam fd1.TARGET_CHIP = TARGET_CHIP;
            defparam fd1.W2_WIDTH = W2_WIDTH_FD1;
            defparam fd1.WORDS = WORDS;
            defparam fd1.EXTR_FIFO_DEPTH = 13;
            defparam fd1.FD_DLY = FD_DLY;

            wire [(W2_WIDTH_FD2+1)*8-1:0] old_val_fd2;
            wire [1:0]                     old_ptp_asm_fd2;
            wire                          old_val_valid_fd2;
            wire                      empty_ff_fd2;
            wire [WORDS*64-1:0]          dout_fd2;
            wire [WORDS*8-1:0]          dout_mask_fd2;
            wire                      dout_valid_fd2;

            wire                      old_val_read_fd2;
            wire                      nvl_valid_fd2;
            wire [(W2_WIDTH_FD2+1)*8-1:0] nvl_fd2;

            assign nvl_fd2 = nvl_fd2_clc;
           
            reg [7:0] cust_dly;
            reg          cust_if_accept_reg;
           
            always @(posedge clk) begin
                cust_dly <= {cust_dly[6:0],cust_if_accept_reg};
            end

            reg [63:0] tod_cust_in_reg;
           
            always @(posedge clk) begin
                tod_cust_in_reg <= tod_cust_in[63:0];
            end
                
            alt_aeu_ptp_fld fd2 (
                .srst(srst),
                .fld(2'b10),
                .din_valid(dout_valid_dt1),
                .din_sop(dout_sop_adf),
                .din_extr(extr_adf[1]),
                .din_spl_hndl(spl_hndl_adf[1]),
                .din_wr_off(~(chk_sum_upd_adf|(ins_ts_adf&(~ins_ts_format_adf))|upd_corr_adf)),
                .din_ptp_asm({ptp_asm_adf,cust_if_adf}),
                .din(dout_crc_dt1),
                .din_offset(corr_offset_adf),
                .din_offset_adj(offset_adj_adf),
  
                .old_val_read(old_val_read_fd2),
                .nvl_valid(nvl_valid_fd2),
                .nvl(cust_dly[6]?tod_cust_in_reg:nvl_fd2),
  
                .old_val_offset_lsb(),
                .old_val(old_val_fd2),
                .old_ptp_asm(old_ptp_asm_fd2),
                .old_val_valid(old_val_valid_fd2),
                .old_ff_empty(empty_ff_fd2),
                .dout(dout_fd2),
                .dout_mask(dout_mask_fd2),
                .dout_valid(dout_valid_fd2),
                .clk(clk)
            );

            defparam fd2.TARGET_CHIP = TARGET_CHIP;
            defparam fd2.W2_WIDTH = W2_WIDTH_FD2;
            defparam fd2.WORDS = WORDS;
            defparam fd2.EXTR_FIFO_DEPTH = 14;
            defparam fd2.FD_DLY = FD_DLY+1;
           
            reg [95:0]                      tod_exit_cust_reg;
            reg [95:0]                      ts_out_cust_reg;
            reg                              ts_out_cust_asm_reg;

            always @(posedge clk) begin
                tod_exit_cust_reg <= nvl_96_fd1_clc;
                ts_out_cust_asm_reg <= old_ptp_asm_fd2[1] & nvl_valid_fd1_int; // bit 1 is actual asm flag
                cust_if_accept_reg <= old_ptp_asm_fd2[0] & nvl_valid_fd1_int;
                ts_out_cust_reg <= old_val_fd2;
            end

            assign tod_exit_cust = tod_exit_cust_reg;
            assign ts_out_cust = ts_out_cust_reg;
            assign ts_out_cust_asm = ts_out_cust_asm_reg;

            wire                      old_val_read_fd3;
            wire                      nvl_valid_fd3;
            wire [(W2_WIDTH_FD3+1)*8-1:0] nvl_fd3;
            assign nvl_fd3 = nvl_fd3_clc;
           
            wire                          old_val_lsb_offset_fd3;
            wire [(W2_WIDTH_FD3+1)*8-1:0] old_val_fd3;
            wire                          old_val_valid_fd3;
            wire                      empty_ff_fd3;
            wire [WORDS*64-1:0]          dout_fd3;
            wire [WORDS*8-1:0]          dout_mask_fd3;
            wire                      dout_valid_fd3;

            alt_aeu_ptp_fld fd3 (
                .srst(srst),
                .fld(2'b11),
                .din_valid(dout_valid_dt1),
                .din_sop(dout_sop_adf),
                .din_extr(extr_adf[2]),
                .din_spl_hndl(spl_hndl_adf[2]),
                .din_wr_off(~chk_sum_upd_adf),
                .din_ptp_asm(2'b0),
                .din(dout_crc_dt1),
                .din_offset(chk_sum_upd_offset_adf),
                .din_offset_adj(offset_adj_adf),
  
                .old_val_read(old_val_read_fd3),
                .nvl_valid(nvl_valid_fd3),
                .nvl(nvl_fd3),
                .old_val_offset_lsb(old_val_lsb_offset_fd3),
                .old_val(old_val_fd3),
                .old_val_valid(old_val_valid_fd3),
                .old_ff_empty(empty_ff_fd3),
                .dout(dout_fd3),
                .dout_mask(dout_mask_fd3),
                .dout_valid(dout_valid_fd3),
                .clk(clk)
            );

            defparam fd3.TARGET_CHIP = TARGET_CHIP;
            defparam fd3.W2_WIDTH = W2_WIDTH_FD3;
            defparam fd3.WORDS = WORDS;
            defparam fd3.EXTR_FIFO_DEPTH = 15;
            defparam fd3.FD_DLY = FD_DLY+2;

            // pipe the mac_in_bus through the PTP module, no modifications, match the latency of the rest of the pipe
            wire [MAC_BUS_WIDTH-1:0]  mac_out_bus_mbs;
            alt_aeu_dly_mlab mbs (
                .clk(clk),
                .din(mac_in_bus),
                .dout(mac_out_bus_mbs)
            );

            defparam mbs. LATENCY = PTP_LATENCY; 
            //   defparam mbs. LATENCY = 14;
            defparam mbs. TARGET_CHIP = TARGET_CHIP;
            defparam mbs. WIDTH = MAC_BUS_WIDTH;
            defparam mbs. FRACTURE = 1;

            wire [WORDS*8*8-1:0]      dout_crc_cdl;
            wire                      dout_valid_cdl;
            wire [WORDS-1:0]          dout_sops_cdl;
            wire [WORDS*8-1:0]          dout_eop_pos_cdl;
            alt_aeu_dly_mlab cdl (
                .clk(clk),
                .din({dout_valid_dt1,dout_sops_dt1,dout_eop_pos_dt1,dout_crc_dt1}),
                .dout({dout_valid_cdl,dout_sops_cdl,dout_eop_pos_cdl,dout_crc_cdl})
            );

            defparam cdl. LATENCY = PTP_LATENCY - 6 ; // 100g actual latency 18*2 + 2
            //   defparam cdl. LATENCY = 10; // for 40g
            defparam cdl. TARGET_CHIP = TARGET_CHIP;
            defparam cdl. WIDTH = 4+1+WORDS+WORDS*8+WORDS*8*8; // divisible by fracture i.e. 4
            defparam cdl. FRACTURE = 4;

            wire [WORDS*8*8-1:0]      dout_mlab_mdl;
            alt_aeu_dly_mlab mdl (
                .clk(clk),
                .din(dout_mlab_dm1),
                .dout(dout_mlab_mdl)
            );

            defparam mdl. LATENCY = PTP_LATENCY - 6; // 100g actual latency 18*2 + 2
            //   defparam mdl. LATENCY = 10; // for 40g
            defparam mdl. TARGET_CHIP = TARGET_CHIP;
            defparam mdl. WIDTH = WORDS*8*8;
            defparam mdl. FRACTURE = 4;

            wire                      dout_valid_mod1;
            wire [WORDS*8*8-1:0]      dout_crc_mod1;
            wire [WORDS*8*8-1:0]      dout_mlab_mod1;
            wire [WORDS-1:0]          dout_sops_mod1;
            wire [WORDS*8-1:0]          dout_eop_pos_mod1;
            alt_aeu_fld_mod mod1 (
                .srst(srst),
                .din(dout_fd1),
                .din_valid(dout_valid_cdl),
                .din_crc(dout_crc_cdl),
                .din_mlab(dout_mlab_mdl),
                .din_mask(dout_mask_fd1),
                .din_sops(dout_sops_cdl),
                .din_eop_pos(dout_eop_pos_cdl),
                .dout_valid(dout_valid_mod1),
                .dout_crc(dout_crc_mod1),
                .dout_mlab(dout_mlab_mod1),
                .dout_sops(dout_sops_mod1),
                .dout_eop_pos(dout_eop_pos_mod1),
                .clk(clk)
            );

            defparam mod1.TARGET_CHIP = TARGET_CHIP;
            defparam mod1.WORDS = WORDS;

            wire                      dout_valid_mod2;
            wire [WORDS*8*8-1:0]      dout_crc_mod2;
            wire [WORDS*8*8-1:0]      dout_mlab_mod2;
            wire [WORDS-1:0]          dout_sops_mod2;
            wire [WORDS*8-1:0]          dout_eop_pos_mod2;
            alt_aeu_fld_mod mod2 (
                .srst(srst),
                .din(dout_fd2),
                .din_valid(dout_valid_mod1),
                .din_crc(dout_crc_mod1),
                .din_mlab(dout_mlab_mod1),
                .din_mask(dout_mask_fd2),
                .din_sops(dout_sops_mod1),
                .din_eop_pos(dout_eop_pos_mod1),
                .dout_valid(dout_valid_mod2),
                .dout_crc(dout_crc_mod2),
                .dout_mlab(dout_mlab_mod2),
                .dout_sops(dout_sops_mod2),
                .dout_eop_pos(dout_eop_pos_mod2),
                .clk(clk)
            );

            defparam mod2.TARGET_CHIP = TARGET_CHIP;
            defparam mod2.WORDS = WORDS;

            wire                      dout_valid_mod3;
            wire [WORDS*8*8-1:0]      dout_crc_mod3;
            wire [WORDS*8*8-1:0]      dout_mlab_mod3;
            wire [WORDS-1:0]          dout_sops_mod3;
            wire [WORDS*8-1:0]          dout_eop_pos_mod3;
            alt_aeu_fld_mod mod3 (
                .srst(srst),
                .din(dout_fd3),
                .din_valid(dout_valid_mod2),
                .din_crc(dout_crc_mod2),
                .din_mlab(dout_mlab_mod2),
                .din_mask(dout_mask_fd3),
                .din_sops(dout_sops_mod2),
                .din_eop_pos(dout_eop_pos_mod2),
                .dout_valid(dout_valid_mod3),
                .dout_crc(dout_crc_mod3),
                .dout_mlab(dout_mlab_mod3),
                .dout_sops(dout_sops_mod3),
                .dout_eop_pos(dout_eop_pos_mod3),
                .clk(clk)
            );

            defparam mod3.TARGET_CHIP = TARGET_CHIP;
            defparam mod3.WORDS = WORDS;

            assign dout_crc = dout_crc_mod3;
            assign dout_mlab = dout_mlab_mod3;
            assign dout_sops = dout_sops_mod3;
            assign dout_eop_pos = dout_eop_pos_mod3;
            assign mac_out_bus = mac_out_bus_mbs;
            assign dout_valid = dout_valid_mod3;

            // delay calc block interface

            wire [5:0]                  calc_ctrl_out;
            wire                      calc_fifo_valid;
            wire                      calc_ctrl_fifo_read;
           
            sc_fifo_ptp #(
                .DEVICE_FAMILY       ((TARGET_CHIP == 2) ? "Stratic V" : "Arria 10"),
                .ENABLE_MEM_ECC      (0),
                .REGISTER_ENC_INPUT  (0),
                
                .SYMBOLS_PER_BEAT    (1),
                .BITS_PER_SYMBOL     (6),   //Data width, eg: 96 for TODp FIFO
                .FIFO_DEPTH          (16),            //FIFO Depth
                .CHANNEL_WIDTH       (0),
                .ERROR_WIDTH         (0),
                .USE_PACKETS         (0)
            ) ctr_ff (
                .clk               (clk),                      // clock signal                         
                .reset             (srst),          //active high reset                  
                .in_data           (calc_ctrl_adf),      //data to be written into sc fifo          
                .in_valid          (dout_sop_adf&(calc_ctrl_adf[5]|calc_ctrl_adf[4]|calc_ctrl_adf[2]|calc_ctrl_adf[0])),                    //push sc fifo signal
                .in_ready          (),                                     
                .out_data          (calc_ctrl_out),                              //data to be read out from sc fifo
                .out_valid         (calc_fifo_valid),    //sc fifo not empty signal, 1 indicate not empty   
                .out_ready         (calc_ctrl_fifo_read),                 //pop sc fifo signal
                .in_startofpacket  (1'b0),
                .in_endofpacket    (1'b0),
                .out_startofpacket (),    
                .out_endofpacket   (),    
                .in_empty          (1'b0),
                .out_empty         (),    
                .in_error          (1'b0),
                .out_error         (),    
                .in_channel        (1'b0),
                .out_channel       (),
                .ecc_err_corrected (),
                .ecc_err_fatal     ()
            );

            wire [PTP_FP_WIDTH-1:0]      fp_out_req_one_st;
           
            // fifo to store egress time stamp request
            // when the request is sent out, make sure that packet does not get updated
            // and the output of the fifo with push_ts from calc block
            sc_fifo_ptp #(
                .DEVICE_FAMILY       ((TARGET_CHIP == 2) ? "Stratic V" : "Arria 10"),
                .ENABLE_MEM_ECC      (0),
                .REGISTER_ENC_INPUT  (0),
                
                .SYMBOLS_PER_BEAT    (1),
                .BITS_PER_SYMBOL     (PTP_FP_WIDTH+5),   //Data width, eg: 96 for TODp FIFO
                .FIFO_DEPTH          (16),            //FIFO Depth
                .CHANNEL_WIDTH       (0),
                .ERROR_WIDTH         (0),
                .USE_PACKETS         (0)
            ) one_st (
                .clk               (clk),                      // clock signal                         
                .reset             (srst),          //active high reset                  
                .in_data           ({fp_out_req_adf,ptp_asm_adf,cust_if_adf,ts_out_req_adf,ins_ts_adf,ins_ts_format_adf}),      //data to be written into sc fifo          
                .in_valid          (dout_sop_adf&(ts_out_req_adf|ins_ts_adf)),                    //push sc fifo signal
                .in_ready          (),                                     
                .out_data          ({fp_out_req_one_st,ptp_asm_valid,cust_if_valid,ts_out_req_valid,ins_ts_valid,ins_ts_format_one_st}),     //data to be read out from sc fifo
                .out_valid         (),    //sc fifo not empty signal, 1 indicate not empty   
                .out_ready         (nvl_valid_fd1_int),                 //pop sc fifo signal
                .in_startofpacket  (1'b0),                                 
                .in_endofpacket    (1'b0),                                 
                .out_startofpacket (),                                     
                .out_endofpacket   (),                                     
                .in_empty          (1'b0),                                 
                .out_empty         (),                                     
                .in_error          (1'b0),                                 
                .out_error         (),                                     
                .in_channel        (1'b0),                                 
                .out_channel       (),
                .ecc_err_corrected (),
                .ecc_err_fatal     ()
            );

            wire [PTP_FP_WIDTH-1:0] fp_fpf;

            sc_fifo_ptp #(
                .DEVICE_FAMILY       ((TARGET_CHIP == 2) ? "Stratic V" : "Arria 10"),
                .ENABLE_MEM_ECC      (0),
                .REGISTER_ENC_INPUT  (0),
                
                .SYMBOLS_PER_BEAT    (1),
                .BITS_PER_SYMBOL     (PTP_FP_WIDTH),   //Data width, eg: 96 for TODp FIFO
                .FIFO_DEPTH          (16),            //FIFO Depth
                .CHANNEL_WIDTH       (0),
                .ERROR_WIDTH         (0),
                .USE_PACKETS         (0)
            ) fpf (
                .clk               (clk),                      // clock signal                         
                .reset             (srst),          //active high reset                  
                .in_data           (fp_out_req_adf),
                .in_valid          (dout_sop_adf&ts_out_req_adf),                    //push sc fifo signal
                .in_ready          (),                                     
                .out_data          (fp_fpf),
                .out_valid         (),    //sc fifo not empty signal, 1 indicate not empty   
                .out_ready         (nvl_valid_fd1_int),                 //pop sc fifo signal
                .in_startofpacket  (1'b0),                                 
                .in_endofpacket    (1'b0),                                 
                .out_startofpacket (),                                     
                .out_endofpacket   (),                                     
                .in_empty          (1'b0),                                 
                .out_empty         (),                                     
                .in_error          (1'b0),                                 
                .out_error         (),                                     
                .in_channel        (1'b0),                                 
                .out_channel       (),
                .ecc_err_corrected (),
                .ecc_err_fatal     ()
            );

            reg [31:0] tx_pma_ext_delay;
           
            always @(posedge clk) begin
                tx_pma_ext_delay <= tx_pma_delay + ext_lat;
            end

            wire [15:0] mac_delay;
            wire ing_ts_96_valid;

            assign mac_delay = (WORDS == 4) ? 16'h2c_00 : 16'h2d_00;
    
            wire [21:0]                pcs_delay;
            if (WORDS == 4) begin // 100g
                if (TARGET_CHIP == 2) begin // S5
                    assign               pcs_delay = ((94.629-48-3.201+9.600)*1024/2.56); // 94.629 ns
                end
                else begin
                    if (SYNOPT_CAUI4 == 1) begin
                        assign               pcs_delay = ((104.006-48)*1024/2.56); // 104.006 ns
                    end
                    else begin
                        assign               pcs_delay = ((89.202-48-9.292+11.927)*1024/2.56); //90.141 ns
                    end
                end // else: !if(TARGET_CHIP == 2)
            end // if (WORDS == 4)
            else begin // 40g
                if (TARGET_CHIP == 2) begin // S5
                    assign               pcs_delay = ((107.185-48-3.977+11.927)*1024/3.2); // 107.185 ns
                end
                else begin
                    assign               pcs_delay = ((98.863-48-10.844+14.255)*1024/3.2); // 99.745 ns
                end // else: !if(TARGET_CHIP == 2)
            end // else: !if(WORDS == 4)

            alt_eth_1588_cal #(
                .TIME_OF_DAY_FORMAT(SYNOPT_TOD_FMT),     //0 = 96b timestamp, 1 = 64b timestamp, 2= both 96b+64b timestamp
                .DELAY_SIGN(0)      // Sign of the delay adjustment
                // TX: set this parameter to 0 (unsigned) to add delays to Tod
                // RX: set this parameter to 1 (signed) to subtract the delays from ToD                   
            ) clc (
                // Common clock and Reset
                .clk(clk),
                .rst_n(~srst),
                //ctrl fifo to/from tod_calc block
                .ctrl_extractor_to_calc(calc_ctrl_out),
                .non_empty_ctrl_fifo_extractor_to_calc(calc_fifo_valid),
                .pop_ctrl_fifo_calc_to_extractor(calc_ctrl_fifo_read),
                //todi fifo to/from cf_calc block
                .todi_extractor_to_calc(ing_ts_96_2calc),
                .non_empty_todi_fifo_extractor_to_calc(ing_ts_96_valid),
                .pop_todi_fifo_calc_to_extractor(rd_ing_ts_96), // assign to _64 also
                // todp is fd1
                //todp fifo to/from cf_calc block
                .todp_extractor_to_calc({old_val_fd1,16'd0}),
                .non_empty_todp_fifo_extractor_to_calc(old_val_valid_fd1),
                .pop_todp_fifo_calc_to_extractor(old_val_read_fd1),
                // cf correctin field fd2
                //cf fifo to/from cf_calc block 
                .cf_extractor_to_calc(old_val_fd2),
                .non_empty_cf_fifo_extractor_to_calc(old_val_valid_fd2),
                .pop_cf_fifo_calc_to_extractor(old_val_read_fd2),
                // chka checksum field fd3
                //chka fifo to/from chka_calc block
                .chka_extractor_to_calc({old_val_lsb_offset_fd3,old_val_fd3}),
                .non_empty_chka_fifo_extractor_to_calc(old_val_valid_fd3),
                .pop_chka_fifo_calc_to_extractor(old_val_read_fd3),
                // inpput to fd1
                //tod_calc to inserter
                .push_tod_fifo_calc_to_inserter(nvl_valid_fd1_int),
                .tod_calc_to_inserter_96(nvl_96_fd1_clc),
                .tod_calc_to_inserter_64(nvl_64_fd1_clc),
                // input to fd2
                //cf_calc to inserter
                .push_cf_fifo_calc_to_inserter(nvl_valid_fd2),
                .cf_calc_to_inserter(nvl_fd2_clc),
                // input to fd3
                //chka_calc to inserter
                .push_chka_fifo_calc_to_inserter(nvl_valid_fd3),
                .chka_calc_to_inserter(nvl_fd3_clc),

                // CSR Configuration Input
                .asymmetry_reg(tx_asym_delay),
                .pma_delay_reg(tx_pma_ext_delay),
                .period(txmclk_period),
                //SOP from deterministic latency point in MAC
                .sop_mac_to_calc(fld_out_fifo[ADF_TO_FLD_DLY-1]),
                .path_delay_data(pcs_delay),
                .mac_delay(mac_delay),
                // Inputs from ToD              
                .time_of_day_96b_data(tod_96b_txmac_in),
                .time_of_day_64b_data(tod_64b_txmac_in)
            );

            alt_aeu_ptp_2calc toclc (
                .srst(srst),
                .ing_ts_96_valid(dout_sop_adf&todi_write_adf),
  //              .ing_ts_96_valid(dout_sop_adf&upd_corr_adf),
                .ing_ts_96(ing_ts_96_adf),
  
                .rd_ing_ts_96(rd_ing_ts_96),
                .ing_ts_96_2calc(ing_ts_96_2calc),
                .ing_ts_96_2calc_valid(ing_ts_96_valid),
  
                .clk(clk)
            );

            defparam toclc.TARGET_CHIP = TARGET_CHIP;

            reg [160-1:0] ts_exit_reg;
            reg ts_exit_valid_reg;
            reg [PTP_FP_WIDTH-1:0] fp_out_reg;
            always @(posedge clk) begin
                ts_exit_reg <= {nvl_96_fd1_clc,nvl_64_fd1_clc};
                ts_exit_valid_reg <= nvl_valid_fd1_int & ts_out_req_valid;
                fp_out_reg <= fp_out_req_one_st;
            end

            assign ts_exit = ts_exit_reg;
            assign ts_exit_valid = ts_exit_valid_reg;
            assign fp_out = fp_out_reg;
        end // block: ptp1
        else begin
            assign dout_crc = din_crc;
            assign dout_mlab = din_mlab;
            assign mac_out_bus = mac_in_bus;
            assign dout_sops = din_sops;
            assign dout_eop_pos = din_eop_pos;
            assign dout_valid = din_valid;
            assign tod_exit_cust = 96'd0;
            assign ts_out_cust = 96'd0;
            assign ts_exit = 160'd0;
            assign fp_out = {PTP_FP_WIDTH{1'b0}};
            assign ts_exit_valid = 1'b0;
            assign ts_out_cust_asm = 1'b0;
        end // else: !if(SYNOPT_PTP == 1)
    endgenerate
endmodule // alt_aeu_ptp_tx

