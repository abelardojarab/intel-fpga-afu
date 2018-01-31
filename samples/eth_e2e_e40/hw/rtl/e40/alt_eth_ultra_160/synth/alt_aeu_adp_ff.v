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

module alt_aeu_adp_ff #(
    parameter SYNOPT_PTP_96B = 1, // ts values are 96 bits not 64
    parameter SYNOPT_PTP_1STEP = 1,
    parameter PTP_FP_WIDTH = 16,
    parameter PTP_TS_WIDTH = 96,

    parameter TARGET_CHIP = 2, // 2: stratix v, 5: arria 10
    parameter SYNOPT_CAUI4 = 0,
    parameter SYNOPT_PTP = 1,
    parameter EN_LINK_FAULT = 0,
    parameter WORDS = 4 // 4 for 100G
)
(
    input srst,

    input din_sop_adp, // sop from adapter, actually after pause, qualified with valid

    input [WORDS-1:0] din_sops, // din_sops from MAC, sop can be in any word
    input din_valid, // from MAC

    input [PTP_FP_WIDTH-1:0] fp_out_req_adp,
    input ts_out_req_adp,
    input [95:0] ing_ts_96_adp,
    input [63:0] ing_ts_64_adp,
    input ins_ts_adp,
    input ins_ts_format_adp,
    input tx_asym_adp,
    input upd_corr_adp,
    input corr_format_adp,
    input chk_sum_zero_adp,
    input chk_sum_upd_adp,
    input [15:0] ts_offset_adp,
    input [15:0] corr_offset_adp,
    input [15:0] chk_sum_zero_offset_adp,
    input [15:0] chk_sum_upd_offset_adp,
    input din_ptp_asm_adp,
    input din_cust_if_adp,

    output reg [PTP_FP_WIDTH-1:0] fp_out_req_ff,
    output reg ts_out_req_ff,
    output reg [95:0]               ing_ts_96_ff,
    output reg [63:0]               ing_ts_64_ff,
    output reg                       ins_ts_ff,
    output reg                       ins_ts_format_ff,
    output reg                       tx_asym_ff,
    output reg                       upd_corr_ff,
    output reg                       corr_format_ff,
    output reg                       chk_sum_zero_ff,
    output reg                       chk_sum_upd_ff,
    output reg [15:0]               ts_offset_ff,
    output reg [15:0]               corr_offset_ff,
    output reg [15:0]               chk_sum_zero_offset_ff,
    output reg [15:0]               chk_sum_upd_offset_ff,
    output reg ptp_asm_ff,
    output reg cust_if_ff,
    output reg [5:0] calc_ctrl_ff,
    output reg [2:0] extr_ff,
    output reg [2:0] spl_hndl_ff,
    output reg         todi_write_ff,

    output reg                       dout_sop,
    output reg [4:0]               offset_adj,
    input         din_ptp_dbg_adp,

    input clk
);

    localparam ADP_WORD_WIDTH = 1+PTP_FP_WIDTH+4+96+64+3+16+16+16+16+1+6+3+4+1;

    wire                           ptp_dbg_out;  // used for verification only
    wire [ADP_WORD_WIDTH-1:0]       adp_inp;
    wire [ADP_WORD_WIDTH-1:0]       adp_out_fifo;
    reg [ADP_WORD_WIDTH-1:0]       adp_out_fifo_reg;

    reg [ADP_WORD_WIDTH-1:0]       adp_inp_reg;
    reg                               adp_sop_reg_1,adp_sop_reg_0 /* synthesis preserve */;

    // synthesis translate_off
    reg [15:0]                       ptp_pkt_cnt;
       
    always @(posedge clk) begin
        if (srst)
            ptp_pkt_cnt <= 16'd0;
        else
            if (din_sop_adp & ins_ts_adp) begin
                ptp_pkt_cnt <= ptp_pkt_cnt + 16'd1;
                $display ("pkt_cnt = %d, offset = %d", ptp_pkt_cnt, ts_offset_adp);
            end
    end

    // synthesis translate_on

    reg [PTP_FP_WIDTH-1:0] fp_out_req_adp_reg;
    reg                       ts_out_req_adp_reg;
    reg [95:0]               ing_ts_96_adp_reg;
    reg [63:0]               ing_ts_64_adp_reg;
    reg                       ins_ts_adp_reg;
    reg                       ins_ts_format_adp_reg;
    reg                       tx_asym_adp_reg;
    reg                       upd_corr_adp_reg;
    reg                       corr_format_adp_reg;
    reg                       chk_sum_zero_adp_reg;
    reg                       chk_sum_upd_adp_reg;
    reg [15:0]               ts_offset_adp_reg;
    reg [15:0]               corr_offset_adp_reg;
    reg [15:0]               chk_sum_zero_offset_adp_reg;
    reg [15:0]               chk_sum_upd_offset_adp_reg;
    reg                       din_ptp_asm_adp_reg;
    reg                       din_cust_if_adp_reg;
    reg                       din_sop_adp_reg;

    // synthesis translate_off
    reg                       din_ptp_dbg_adp_reg;
    // synthesis translate_on

    always @(posedge clk) begin
        fp_out_req_adp_reg <= fp_out_req_adp;
        ts_out_req_adp_reg <= ts_out_req_adp;
        ing_ts_96_adp_reg <= ing_ts_96_adp;
        ing_ts_64_adp_reg <= ing_ts_64_adp;
        ins_ts_adp_reg <= ins_ts_adp;
        ins_ts_format_adp_reg <= ins_ts_format_adp;
        tx_asym_adp_reg <= tx_asym_adp;
        upd_corr_adp_reg <= upd_corr_adp;
        corr_format_adp_reg <= corr_format_adp;
        chk_sum_zero_adp_reg <= chk_sum_zero_adp;
        chk_sum_upd_adp_reg <= chk_sum_upd_adp;
        ts_offset_adp_reg <= ts_offset_adp;
        corr_offset_adp_reg <= corr_offset_adp;
        chk_sum_zero_offset_adp_reg <= chk_sum_zero_offset_adp;
        chk_sum_upd_offset_adp_reg <= chk_sum_upd_offset_adp;
        din_ptp_asm_adp_reg <= din_ptp_asm_adp;
        din_cust_if_adp_reg <= din_cust_if_adp;

        din_sop_adp_reg <= din_sop_adp;

        // synthesis translate_off
        din_ptp_dbg_adp_reg <= din_ptp_dbg_adp;
        // synthesis translate_on
    end

    wire [5:0] calc_ctrl_adp;
    wire [2:0] extr_adp;
    wire [2:0] spl_hndl_adp;
    wire       todi_write_adp;

    assign calc_ctrl_adp = {tx_asym_adp_reg,(ts_out_req_adp_reg|ins_ts_adp_reg),ins_ts_format_adp_reg,(upd_corr_adp_reg|(ins_ts_adp_reg&(~ins_ts_format_adp_reg))),
                            corr_format_adp_reg,(chk_sum_upd_adp_reg)};
    assign extr_adp = {(chk_sum_upd_adp_reg|chk_sum_zero_adp_reg),
                       (upd_corr_adp_reg|(ins_ts_adp_reg&(~ins_ts_format_adp_reg))|tx_asym_adp_reg|din_ptp_asm_adp_reg),
                       (ins_ts_adp_reg)};

    assign spl_hndl_adp = {chk_sum_zero_adp_reg,1'b0,ins_ts_adp_reg&ins_ts_format_adp_reg};
    assign todi_write_adp = upd_corr_adp_reg;
    assign adp_inp = 
                    {
                     ts_out_req_adp_reg,
                     fp_out_req_adp_reg,
                     ins_ts_adp_reg,
                     ins_ts_format_adp_reg,
                     tx_asym_adp_reg,
                     (upd_corr_adp_reg|(ins_ts_adp_reg&(~ins_ts_format_adp_reg))|((~ins_ts_adp_reg)&(tx_asym_adp_reg))),
                     (corr_format_adp_reg ? ing_ts_64_adp_reg:ing_ts_96_adp_reg),
                     64'd0,
                     corr_format_adp_reg,
                     chk_sum_zero_adp_reg,
                     chk_sum_upd_adp_reg,
                     ts_offset_adp_reg,
                     corr_offset_adp_reg,
                     chk_sum_zero_offset_adp_reg,
                     (chk_sum_zero_adp_reg?chk_sum_zero_offset_adp_reg:chk_sum_upd_offset_adp_reg),
                     din_ptp_asm_adp_reg,
                     din_cust_if_adp_reg,
                     calc_ctrl_adp,
                     extr_adp,
                     spl_hndl_adp,
                     todi_write_adp};

    always @(posedge clk) begin
        adp_inp_reg <= adp_inp;
    end

    always @(posedge clk) begin
        if (srst) begin
            adp_sop_reg_1 <= 1'b0;
            adp_sop_reg_0 <= 1'b0;
        end else begin
            adp_sop_reg_1 <= din_sop_adp_reg;
            adp_sop_reg_0 <= din_sop_adp_reg;
        end
    end

    reg din_sop_d1 /* synthesis preserve */;
    reg din_sop_d2;
    reg din_sop_d1_cp1 /* synthesis preserve */;
    reg din_sop_d1_cp2 /* synthesis preserve */;
    
    always @(posedge clk) begin
        if (srst) begin
            din_sop_d1 <= 1'b0;
            din_sop_d1_cp1 <= 1'b0;
            din_sop_d1_cp2 <= 1'b0;
            din_sop_d2 <= 1'b0;
            dout_sop <= 1'b0;
        end else begin
            din_sop_d1 <= (|din_sops) & din_valid;
            din_sop_d1_cp1 <= (|din_sops) & din_valid;
            din_sop_d1_cp2 <= (|din_sops) & din_valid;
            din_sop_d2 <= din_sop_d1;
            dout_sop <= din_sop_d2;
        end // else: !if(srst)
    end

    reg [WORDS-1:0] din_sops_d1;
    reg [WORDS-1:0] din_sops_d2;

    generate
        if (WORDS == 4) begin: w4   
            always @(posedge clk) begin
                din_sops_d1 <= din_sops;
                din_sops_d2 <= din_sops_d1;
                case (din_sops_d2) // synthesis parallel_case
                    4'b0100: offset_adj <= 5'd8;
                    4'b0010: offset_adj <= 5'd16;
                    4'b0001: offset_adj <= 5'd24;
                    default: offset_adj <= 5'd0;
                endcase // case (din_sops_d1)
            end // always @ (posedge clk)
        end else begin:w2 // block: w4
            always @(posedge clk) begin
                din_sops_d1 <= din_sops;
                din_sops_d2 <= din_sops_d1;
                if (din_sops_d2 == 2'b01)
                    offset_adj <= 5'd8;
                else
                    offset_adj <= 5'd0;
            end // always @ (posedge clk)
        end
    endgenerate

    wire full_pof;
    wire empty_pof;
   
    generate
        if (TARGET_CHIP == 2) begin: s5
            scfifo_s5m20k pofs5_1 (
                .clk(clk),
                .sclr(srst),
                .wrreq(adp_sop_reg_1),
                .data(adp_inp_reg[99:0]),
                .full(full_pof),
                .rdreq(din_sop_d1_cp1),
                .q(adp_out_fifo[99:0]),
                .empty(empty_pof),
                .usedw()
            );
            defparam pofs5_1.WIDTH = 100;
            defparam pofs5_1.ADDR_WIDTH = 8;

            scfifo_s5m20k pofs5_0 (
                .clk(clk),
                .sclr(srst),
                .wrreq(adp_sop_reg_0),
                .data(adp_inp_reg[ADP_WORD_WIDTH-1:100]),
                .full(full_pof),
                .rdreq(din_sop_d1_cp2),
                .q(adp_out_fifo[ADP_WORD_WIDTH-1:100]),
                .empty(empty_pof),
                .usedw()
            );
            defparam pofs5_0.WIDTH = ADP_WORD_WIDTH-100;
            defparam pofs5_0.ADDR_WIDTH = 8;

            // synthesis translate_off
            assign ptp_dbg_out = din_ptp_dbg_adp_reg & din_sop_adp_reg;
            // synthesis translate_on
        end else begin: a10 // block: s5
            scfifo_a10m20k pofa10_1 (
                .clk(clk),
                .sclr(srst),
                .wrreq(adp_sop_reg_1),
                .data(adp_inp_reg[99:0]),
                .full(full_pof),
                .rdreq(din_sop_d1_cp1),
                .q(adp_out_fifo[99:0]),
                .empty(empty_pof),
                .usedw()
            );
            defparam pofa10_1.WIDTH = 100;
            defparam pofa10_1.ADDR_WIDTH = 8;
            scfifo_a10m20k pofa10_0 (
                .clk(clk),
                .sclr(srst),
                .wrreq(adp_sop_reg_0),
                .data(adp_inp_reg[ADP_WORD_WIDTH-1:100]),
                .full(full_pof),
                .rdreq(din_sop_d1_cp2),
                .q(adp_out_fifo[ADP_WORD_WIDTH-1:100]),
                .empty(empty_pof),
                .usedw()
            );
            defparam pofa10_0.WIDTH = ADP_WORD_WIDTH-100;
            defparam pofa10_0.ADDR_WIDTH = 8;
            // synthesis translate_off
            assign ptp_dbg_out = din_ptp_dbg_adp_reg & din_sop_adp_reg;
            // synthesis translate_on
        end // else: !if(TARGET_CHIP == 2)
    endgenerate

   // flop outputs of m20k
    always @(posedge clk) begin
        adp_out_fifo_reg[99:0] <= adp_out_fifo[99:0];
        adp_out_fifo_reg[ADP_WORD_WIDTH-1:100] <= adp_out_fifo[ADP_WORD_WIDTH-1:100];
    end

    // flop outputs one more time -:)
    always @(posedge clk) begin
        {
         ts_out_req_ff,
         fp_out_req_ff,
         ins_ts_ff,
         ins_ts_format_ff,
         tx_asym_ff,
         upd_corr_ff,
         ing_ts_96_ff,
         ing_ts_64_ff,
         corr_format_ff,
         chk_sum_zero_ff,
         chk_sum_upd_ff,
         ts_offset_ff,
         corr_offset_ff,
         chk_sum_zero_offset_ff,
         chk_sum_upd_offset_ff,
         ptp_asm_ff,
         cust_if_ff,
         calc_ctrl_ff,
         extr_ff,
         spl_hndl_ff,
         todi_write_ff} <= adp_out_fifo_reg;
    end // always @ (posedge clk)
endmodule // alt_aeu_ptp_tx
