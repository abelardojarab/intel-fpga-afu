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


// CSR Module - black box
`timescale 1ps / 1ps

module alt_e100s10_csr  # (
    parameter SIM_EMULATE = 1'b0,
    parameter SIM_HURRY = 1'b0,
    parameter SYNOPT_C4_RSFEC = 1'b0,
    parameter ENABLE_ANLT     = 1'b0
)(

    output              o_enable_rsfec,
    input               csr_clk      ,
    input               rx_clk       ,
    input               tx_clk       ,
    input               clk_rx_rs    ,
    input               clk_tx_rs    ,
    input               cdr_ref_clk  ,
    
    input               reset        ,
    input               write        ,
    input               read         , 
    input       [15:0]  address      ,
    input       [31:0]  data_in      ,
    output reg  [31:0]  data_out     ,
    output reg          data_valid   ,
    output              waitrequest  ,
    output reg  [7:0]   avmm_addr    ,
    output reg  [31:0]  avmm_din     ,

    // MAC AVMM Signals
    output reg              write_rxmac ,
    output reg              read_rxmac ,
    input  [31:0]           data_out_rxmac ,
    input                   data_valid_rxmac ,
    output reg              write_txmac,
    output reg              read_txmac,
    input  [31:0]           data_out_txmac,
    input                   data_valid_txmac,

    // FLOW CONTROL AVMM Signals
    output reg              write_fc_rx ,
    output reg              read_fc_rx ,
    input  [31:0]           data_out_fc_rx ,
    input                   data_valid_fc_rx ,
    output reg              write_fc_tx,
    output reg              read_fc_tx,
    input  [31:0]           data_out_fc_tx,
    input                   data_valid_fc_tx,

    // MAC stats AVMM Signals
    output reg		write_rx_stats ,
    output reg		read_rx_stats ,
    input  [31:0]	data_out_rx_stats ,
    input		data_valid_rx_stats ,
    output reg		write_tx_stats,
    output reg		read_tx_stats,
    input  [31:0]	data_out_tx_stats,
    input		data_valid_tx_stats,
    
    // RSFEC AVMM Signals 
    output reg              write_tx_rsfec,
    output reg              read_tx_rsfec,
    input  [31:0]           data_out_tx_rsfec,
    input                   data_valid_tx_rsfec,
    output reg              write_rx_rsfec,
    output reg              read_rx_rsfec,
    input  [31:0]           data_out_rx_rsfec,
    input                   data_valid_rx_rsfec,

    // Resets
    output              soft_txp_rst  ,             // on csr_clk
    output              soft_rxp_rst  ,             // on csr_clk
    output              eio_sys_rst   ,             // on csr_clk
    
    // RX Status input
    input   [3:0]       rx_pempty,    
    input   [3:0]       rx_pfull,
    input   [3:0]       rx_empty,
    input   [3:0]       rx_full,
    input   [19:0]      rxpcs_frm_err,
    input   [3:0]       rx_is_lockedtodata,
    input   [19:0]      rx_word_locked,
    input               rx_am_lock,
    input               rx_deskew_locked,
    input               rx_align_locked,
    input               rx_hi_ber,
    input   [20*5-1:0]  rxpcs_dout_tags,
    input               rx_am_lock_fec,
    input               rx_align_status_fec,
    
    //RX strict preamble check
    output cfg_preamble_det_on,
    output cfg_sfd_det_on,    



    // Rx Status and Control Out
    output              rxpcs_frm_err_sclr,         // on rx_clk
    output              rx_fifo_soft_purge ,        // on csr_clk
    output  [3:0]       rx_seriallpbken ,           // on csr_clk
    output              rx_set_locktoref    ,       // on csr_clk
    output              rx_set_locktodata   ,       // on csr_clk

    output [19:0]        rx_word_locked_s ,          // on csr_clk
    output              rx_crc_pt,
    output [5:0]        rx_delay,

    // Tx Status iinput
    input   [3:0]       tx_pempty,
    input   [3:0]       tx_pfull,
    input   [3:0]       tx_empty,
    input   [3:0]       tx_full,
    input   [1:0]       tx_pll_locked,      // ATX PLL
    input               tx_fec_pll_locked,
    input               rx_fec_pll_locked,
    input   [3:0]       tx_digitalreset,
    
    // Tx Status and Control Output
    output              tx_clk_stable,
    output  [7:0]       num_idle_rm,
    output              tx_crc_pt,

    // Stats Vector
    output              tx_vlandet_disable,  
    output              rx_vlandet_disable, 
    output  [15:0]      tx_max_frm_length,
    output  [15:0]      rx_max_frm_length

);
wire enable_rsfec;

reg [2:0] enable_rsfec_r;
generate

if ((SYNOPT_C4_RSFEC == 1) && (ENABLE_ANLT == 0)) begin 
   assign o_enable_rsfec = enable_rsfec_r[2];
   always @ (posedge csr_clk) begin
     if (reset == 1'b1) begin
        enable_rsfec_r <= 3'b111;
     end
     else begin 
       enable_rsfec_r[0] <= enable_rsfec;
       enable_rsfec_r[1] <= enable_rsfec_r[0]; 
       enable_rsfec_r[2] <= enable_rsfec_r[1];
     end
   end
end
else if ((SYNOPT_C4_RSFEC == 1) && (ENABLE_ANLT == 1)) begin 
   assign o_enable_rsfec = 1'b1;
end else begin
	assign o_enable_rsfec = 1'b0;
end
endgenerate



wire rx_fec_pll_locked_s, rx_is_lockedtodata_s;
alt_e100s10_synchronizer sn00 (
    .clk        (csr_clk),
    .din        ({rx_fec_pll_locked, &rx_is_lockedtodata}),
    .dout       ({rx_fec_pll_locked_s, rx_is_lockedtodata_s})
);
defparam sn00 .WIDTH = 2;

reg rx_clk_stable_s;
always @(posedge csr_clk) begin
    rx_clk_stable_s <= rx_fec_pll_locked_s & rx_is_lockedtodata_s;
end


// Address Decoder. To be updated with MAC CSR 

reg                 write_phy,  read_phy;
wire                data_valid_phy;
reg     [31:0]      data_d1;
reg                 read_d1;
wire                valid_rreq;
//reg                 waitreq_in = 1'b0;
reg     [15:0]      address_d1;
reg     [31:0]      data_out_t, data_out_t2;
reg                 data_valid_t, data_valid_t2;
wire    [31:0]      data_out_phy;
reg                 str_reset;
reg		read_default;

//assign          valid_rreq = (read & ~read_d1) | (read & data_valid_t);


always @(posedge csr_clk)   begin

    if (reset == 1)
        str_reset <= 1;
    else 
        str_reset <= 0;

end 


always @(posedge csr_clk) begin
    read_d1     <=  read; 
    address_d1  <=  address;
    data_d1     <=  data_in;
    //waitreq_in  <=  (valid_rreq | waitreq_in) & ~(data_valid_phy | data_valid_txmac | data_valid_rxmac | data_valid_tx_rsfec | data_valid_rx_rsfec | data_valid_tx_stats | data_valid_rx_stats);
    avmm_addr   <=  address[7:0];
    avmm_din    <=  data_in[31:0];
    data_valid_t2  <= data_valid_t;
    data_out_t2    <= data_out_t;
    data_valid  <= reset ? 1'b0 : data_valid_t2;
    data_out    <= data_out_t2;
     if (|address[15:12]) begin
        write_phy   <=  1'b0;
        read_phy    <=  1'b0;
        write_txmac <=  1'b0;
        read_txmac  <=  1'b0;
        write_rxmac <=  1'b0;
        read_rxmac  <=  1'b0;
        write_fc_tx <=  1'b0;
        read_fc_tx  <=  1'b0;
        write_fc_rx <=  1'b0;
        read_fc_rx  <=  1'b0;
        write_tx_stats <=  1'b0;
        read_tx_stats  <=  1'b0;
        write_rx_stats <=  1'b0;
        read_rx_stats  <=  1'b0;
        write_tx_rsfec <=  1'b0;
        read_tx_rsfec  <=  1'b0;
        write_rx_rsfec <=  1'b0;
        read_rx_rsfec  <=  1'b0;
	read_default  <=  valid_rreq;
	data_valid_t  <=  read_default;	//read;
        data_out_t    <=  32'hdeadc0de;
    end else begin
        write_phy   <=  1'b0;
        read_phy    <=  1'b0;
        write_txmac <=  1'b0;
        read_txmac  <=  1'b0;
        write_rxmac <=  1'b0;
        read_rxmac  <=  1'b0;
        write_fc_tx <=  1'b0;
        read_fc_tx  <=  1'b0;
        write_fc_rx <=  1'b0;
        read_fc_rx  <=  1'b0;
        write_tx_stats <=  1'b0;
        read_tx_stats  <=  1'b0;
        write_rx_stats <=  1'b0;
        read_rx_stats  <=  1'b0;
        write_tx_rsfec <=  1'b0;
        read_tx_rsfec  <=  1'b0;
        write_rx_rsfec <=  1'b0;
        read_rx_rsfec  <=  1'b0;
	read_default  <=  1'b0;
        data_valid_t  <=  1'b0;

     casez (address[11:7]) 
        5'b00110:    begin
                        write_phy   <=  write;
                        read_phy    <=  valid_rreq;
                        data_valid_t  <=  data_valid_phy;
                        data_out_t    <=  data_out_phy;

                    end

        5'b0100?:    begin
                        write_txmac   <=  write;
                        read_txmac    <=  valid_rreq;
                        data_valid_t    <=  data_valid_txmac;
                        data_out_t      <=  data_out_txmac;
                    end


        5'b0101?:    begin
                        write_rxmac   <=  write;
                        read_rxmac    <=  valid_rreq;
                        data_valid_t    <=  data_valid_rxmac;
                        data_out_t      <=  data_out_rxmac;
                    end

        5'b0110?:    begin
                        write_fc_tx   <=  write;
                        read_fc_tx    <=  valid_rreq;
                        data_valid_t    <=  data_valid_fc_tx;
                        data_out_t      <=  data_out_fc_tx;
                    end

        5'b0111?:    begin
                        write_fc_rx   <=  write;
                        read_fc_rx    <=  valid_rreq;
                        data_valid_t    <=  data_valid_fc_rx;
                        data_out_t      <=  data_out_fc_rx;
                    end

        5'b1000?:    begin
			write_tx_stats	<=  write;
			read_tx_stats	<=  valid_rreq;
			data_valid_t	<=  data_valid_tx_stats;
			data_out_t	<=  data_out_tx_stats;
                    end

        5'b1001?:    begin
			write_rx_stats	<=  write;
			read_rx_stats	<=  valid_rreq;
			data_valid_t	<=  data_valid_rx_stats;
			data_out_t	<=  data_out_rx_stats;
                    end

        5'b1100?:    begin
                        write_tx_rsfec   <=  write;
                        read_tx_rsfec    <=  valid_rreq;
                        data_valid_t       <=  data_valid_tx_rsfec;
                        data_out_t         <=  data_out_tx_rsfec;
                    end 

        5'b1101?:    begin
                        write_rx_rsfec   <=  write;
                        read_rx_rsfec    <=  valid_rreq;
                        data_valid_t       <=  data_valid_rx_rsfec;
                        data_out_t         <=  data_out_rx_rsfec;
                    end
        default:    begin
                        read_phy    <=  1'b0;
                        write_phy   <=  1'b0;
			read_default  <=  valid_rreq;
                        data_valid_t  <=  read_default;	//read;
                        data_out_t    <=  32'hdeadc0de;
                    end
      endcase
end

end

//----------------------------------
reg	write_d1;
reg	waitreq_wr, waitreq_rd;
reg	valid_wreq_d1, valid_wreq_d2;

assign  valid_rreq = (read & ~read_d1);
wire    valid_wreq = (write & ~write_d1);

always @(posedge csr_clk) begin
  write_d1     <=  write; 
  valid_wreq_d1 <= valid_wreq;
  valid_wreq_d2 <= valid_wreq_d1;
end

always @(posedge csr_clk) begin
  if (reset)			waitreq_wr <= 1'b0;
  else if (valid_wreq)		waitreq_wr <= 1'b1;
  else if (valid_wreq_d2)	waitreq_wr <= 1'b0;
  if (reset)			waitreq_rd <= 1'b0;
  else if (valid_rreq)		waitreq_rd <= 1'b1;
  else if (data_valid_t)	waitreq_rd <= 1'b0;
end

assign  waitrequest = (reset | str_reset) | (valid_wreq | waitreq_wr) | (valid_rreq | waitreq_rd);
//assign  waitrequest = (((valid_rreq | waitreq_in) & ~data_valid_t) | str_reset ); 



wire rx_fifo_soft_purge_w;
wire rxpcs_frm_err_sclr_s;
wire [3:0] txa_online;
wire rx_align_locked_s;
wire rx_deskew_locked_s0, rx_deskew_locked_s;
wire [19:0] rxpcs_frm_err_s;
wire rx_hi_ber_s;
reg rx_deskew_change;



assign txa_online       =   ~tx_digitalreset;
assign tx_clk_stable    =   tx_fec_pll_locked &  tx_pll_locked[0] & tx_pll_locked[1] &  ~tx_digitalreset[0];




alt_e100s10_sync1r2 sn4 (
    .din_clk        (csr_clk),
    .din            (rx_fifo_soft_purge_w),
    .dout_clk       (rx_clk),
    .dout           (rx_fifo_soft_purge)
);


alt_e100s10_sync1r2 sn7 ( 
    .din_clk        (csr_clk),
    .din            (rxpcs_frm_err_sclr_s), 
    .dout_clk       (rx_clk),
    .dout           (rxpcs_frm_err_sclr)
);


//alt_e100s10_sync1r1 st (
//    .din_clk        (rx_clk),
//    .din            (rx_clk_stable),
//    .dout           (rx_clk_stable_s),
//    .dout_clk       (csr_clk)
//);


// Clock Monitors
//                                     000      100        011     010    001
wire [7:0] mon_clocks = {{3'b000}, clk_rx_rs, clk_tx_rs, rx_clk, tx_clk, 1'b0};  
reg [2:0] mon_clock_sel = 3'b000;
wire mon_clock_rate_fresh;
wire [15:0] mon_clock_rate;

alt_e100s10_fmon8 fm0 (
    .clk        (csr_clk),
    .din        (mon_clocks),
    .din_sel    (mon_clock_sel),
    .dout       (mon_clock_rate),
    .dout_fresh (mon_clock_rate_fresh)
);
defparam fm0 .SIM_EMULATE = SIM_EMULATE;
defparam fm0 .SIM_HURRY = SIM_HURRY;

always @(posedge csr_clk) begin
    if (mon_clock_rate_fresh) begin
        if (mon_clock_sel == 3'b100)
            mon_clock_sel   <=  3'b000;
        else
            mon_clock_sel   <=  mon_clock_sel + 1'b1;
    end
end


reg [15:0]  khz_ref_phy_i = 0;
reg [15:0]  khz_tx_io_phy_i = 0;
reg [15:0]  khz_clk_rx_rs_0 = 0;
reg [15:0]  khz_tx_clk_i = 0;
reg [15:0]  khz_rx_clk_i = 0;
reg [15:0]  khz_clk_tx_rs_0 = 0;

always @(posedge csr_clk) begin
    if (mon_clock_rate_fresh) begin
        case (mon_clock_sel)
            3'b000:  khz_clk_rx_rs_0        <=  mon_clock_rate;
            3'b001:  khz_ref_phy_i          <=  mon_clock_rate;
            3'b010:  khz_tx_clk_i           <=  mon_clock_rate;
            3'b011:  khz_rx_clk_i           <=  mon_clock_rate;
            3'b100:  khz_clk_tx_rs_0        <=  mon_clock_rate;
            default: khz_tx_io_phy_i        <=  mon_clock_rate;
            //3'b11:  khz_tx_clk_i       <=  mon_clock_rate;
        endcase
    end
end

wire    [4:0] empty_bus;



wire [19:0]  rxpcs_frm_err_f;
generate
if (SYNOPT_C4_RSFEC == 1) begin 
  assign rxpcs_frm_err_f = (o_enable_rsfec==1) ? 20'b0 : rxpcs_frm_err;
end
else begin 
  assign rxpcs_frm_err_f = rxpcs_frm_err;
end
endgenerate

alt_e100s10_sync20m sn8 ( 
    .din_clk        (rx_clk),
    .din            (rxpcs_frm_err_f), 
    .dout_clk       (csr_clk),
    .dout           (rxpcs_frm_err_s)
);

wire [19:0] rx_word_locked_f;


generate
if (SYNOPT_C4_RSFEC == 1) begin 
  assign rx_word_locked_f = (o_enable_rsfec==1) ? {20{rx_align_status_fec}} : rx_word_locked;
end
else begin 
  assign rx_word_locked_f = rx_word_locked;
end
endgenerate

alt_e100s10_sync20m sn9 ( 
    .din_clk        (rx_clk),
    .din            (rx_word_locked_f), 
    .dout_clk       (csr_clk),
    .dout           (rx_word_locked_s)
);

wire   rx_align_locked_f;
generate
if (SYNOPT_C4_RSFEC == 1) begin 
  assign rx_align_locked_f = (o_enable_rsfec==1) ? rx_align_status_fec : rx_align_locked;
end
else begin 
  assign rx_align_locked_f = rx_align_locked;
end
endgenerate

alt_e100s10_sync1r2 sn10 ( 
    .din_clk        (rx_clk),
    .din            (rx_align_locked_f), 
    .dout_clk       (csr_clk),
    .dout           (rx_align_locked_s)
);

wire    rx_deskew_locked_f;
generate
if (SYNOPT_C4_RSFEC == 1) begin 
  assign  rx_deskew_locked_f = (o_enable_rsfec==1) ? rx_align_status_fec : rx_deskew_locked;
end
else begin 
  assign  rx_deskew_locked_f = rx_deskew_locked;
end
endgenerate

alt_e100s10_sync1r2 sn11 ( 
    .din_clk        (rx_clk),
    .din            (rx_deskew_locked_f), 
    .dout_clk       (csr_clk),
    .dout           (rx_deskew_locked_s0)
);
assign rx_deskew_locked_s = rx_deskew_locked_s0 & rx_clk_stable_s;

wire  rx_hi_ber_f;

generate
if (SYNOPT_C4_RSFEC == 1) begin 
 assign rx_hi_ber_f  = (o_enable_rsfec==1) ? 1'b0  : rx_hi_ber;
end
else begin 
 assign rx_hi_ber_f  = rx_hi_ber;
end
endgenerate

alt_e100s10_sync1r2 sn12 ( 
    .din_clk        (rx_clk),
    .din            (rx_hi_ber_f), 
    .dout_clk       (csr_clk),
    .dout           (rx_hi_ber_s)
);

wire rx_am_lock_f; 
generate
if (SYNOPT_C4_RSFEC == 1) begin 
 assign rx_am_lock_f = (o_enable_rsfec==1) ? rx_am_lock_fec  : rx_am_lock;
end
else begin 
 assign rx_am_lock_f = rx_am_lock;
end
endgenerate

alt_e100s10_sync1r2 sn13 ( 
    .din_clk        (rx_clk),
    .din            (rx_am_lock_f), 
    .dout_clk       (csr_clk),
    .dout           (rx_am_lock_s)
);

// Lanes Deskew Status Change Indication


wire pcs_status = rx_deskew_change |(!rx_deskew_locked_s) ;

always @(posedge csr_clk) begin
     rx_deskew_change <= (!rxpcs_frm_err_sclr_s) & pcs_status ;
end 

reg rx_align_locked_i, rx_deskew_locked_i, rx_am_lock_i;
reg [19:0]   rx_word_locked_i;

always @(posedge csr_clk) begin
    rx_align_locked_i   <=  rx_align_locked_s  & rx_clk_stable_s ;
    rx_deskew_locked_i  <=  rx_deskew_locked_s & rx_clk_stable_s;
    rx_word_locked_i    <=  rx_word_locked_s   & {20{rx_clk_stable_s}};
    rx_am_lock_i        <=  rx_am_lock_s & rx_clk_stable_s;
end



// PHY Registers


reg     [3:0]       eio_flags_csr;
wire    [2:0]       eio_flags_sel;

always @(posedge csr_clk) begin

    case (eio_flags_sel)
        3'b000:     eio_flags_csr   <=   tx_full; 
        3'b001:     eio_flags_csr   <=   tx_empty; 
        3'b010:     eio_flags_csr   <=   tx_pfull; 
        3'b011:     eio_flags_csr   <=   tx_pempty; 
        3'b100:     eio_flags_csr   <=   rx_full; 
        3'b101:     eio_flags_csr   <=   rx_empty; 
        3'b110:     eio_flags_csr   <=   rx_pfull; 
        3'b111:     eio_flags_csr   <=   rx_pempty; 
        default:    eio_flags_csr   <=   2'b00;
    endcase

end



wire [20*5-1:0]      rxpcs_dout_tags_f;
generate
if (SYNOPT_C4_RSFEC == 1) begin 
 assign rxpcs_dout_tags_f  = (o_enable_rsfec==1) ? {100{1'b1}}: rxpcs_dout_tags;
end
else begin 
 assign rxpcs_dout_tags_f  = rxpcs_dout_tags;
end
endgenerate

alt_e100s10_phy_config_register_map     phy (
    
    // Control signals
    .PHY_CONFIG_set_data_lock                   (rx_set_locktodata),
    .PHY_CONFIG_set_ref_lock                    (rx_set_locktoref),
    .PHY_PMA_SLOOP_phy                          (rx_seriallpbken),
    .PHY_PCS_INDIRECT_ADDR_phy                  (eio_flags_sel),
    .PHY_CONFIG_soft_rxp_rst                    (soft_rxp_rst),
    .PHY_CONFIG_soft_txp_rst                    (soft_txp_rst),
    .PHY_CONFIG_eio_sys_rst                     (eio_sys_rst),
    .PHY_RSFEC_enable_rsfec                    (enable_rsfec),
    .PHY_EIO_SFTRESET_phy                       (rx_fifo_soft_purge_w),
    .PHY_SCLR_FRAME_ERROR_phy                   (rxpcs_frm_err_sclr_s),
    .PHY_RX_delay                               (rx_delay),

    // Status signals - input
    .PHY_PCS_INDIRECT_DATA_phy_i                (eio_flags_csr),
    .PHY_EIOFREQ_LOCK_phy_i                     (rx_is_lockedtodata),
    .PHY_TX_COREPLL_LOCKED_rxp_clk_stable_i     (rx_clk_stable_s),
    .PHY_TX_COREPLL_LOCKED_txp_clk_stable_i     (tx_clk_stable) ,
    .PHY_TX_COREPLL_LOCKED_txa_online_i         (txa_online[0]),
    .PHY_FRAME_ERROR_phy_i                      (rxpcs_frm_err_s),
    .PHY_RXPCS_STATUS_fully_aligned_i           (rx_align_locked_i),                     
    .PHY_RXPCS_STATUS_hi_ber_i                  (rx_hi_ber_s),
    
    .LANE_DESKEWED_locked_i                     (rx_deskew_locked_i),
    .LANE_DESKEWED_sticky_bit_i                 (rx_deskew_change),
    .WORD_LOCK_phy_i                            (rx_word_locked_i),
    
    .PHY_REFCLK_KHZ_phy_i                       ({16'h0, khz_ref_phy_i}),
    .PHY_RXCLK_KHZ_phy_i                        ({16'h0, khz_rx_clk_i}),
    .PHY_TXCLK_KHZ_phy_i                        ({16'h0, khz_tx_clk_i}),
    .PHY_CLK_RX_RS_phy_i                        ({16'h0, khz_clk_rx_rs_0}),
    .PHY_CLK_TX_RS_phy_i                        ({16'h0, khz_clk_tx_rs_0}),

        
     // LK : New registers
    . ERR_INJ_phy (),
    . AM_LOCK_phy_i                             (rx_am_lock_i),
    . PCS_VLANE_vlane0_i                        (rxpcs_dout_tags_f[24:0]), // first VL on physical channel-0
    . PCS_VLANE_vlane1_i                        (rxpcs_dout_tags_f[49:25]), // second VL on physical channel-0
    . PCS_VLANE_vlane2_i                        (rxpcs_dout_tags_f[74:50]), // first VL on physical channel-1
    . PCS_VLANE_vlane3_i                        (rxpcs_dout_tags_f[99:75]), // second VL on physical channel-1
   

    //Bus Interface
    .clk                                        (csr_clk),
    .reset                                      (reset),
    .writedata                                  (data_d1), // Update after adding decode logic
    .read                                       (read_phy), // Update after adding decode logic
    .write                                      (write_phy), // Update after adding decode logic
    .byteenable                                 (4'b1111),
    .readdata                                   (data_out_phy), // Update after adding decode logic
    .readdatavalid                              (data_valid_phy), // Update after adding decode logic
    .address                                    (address_d1[6:0])
);







endmodule




