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



`timescale 1 ps / 1 ps

module alt_e100s10 (
    input clk50,
    input cpu_resetn,

    // QSFP
    output wire  qsfp_lowpwr,   // LPMode
    output wire  qsfp_rstn,   // ResetL

    // 10G IO
    input wire clk_ref_r,
    input wire [3:0] rx_serial,
    output wire [3:0] tx_serial,
    output wire [9:0]             user_io,
    output wire [7:0]             user_led
);


    assign qsfp_rstn = 1'b1;
    assign qsfp_lowpwr = 1'b0;
    assign user_led = 8'b0;


    localparam DEVICE_FAMILY = "Stratix 10";
    localparam WORDS = 8;
    localparam WIDTH = 64;
    localparam SOP_ON_LANE0 = 1'b1;
    localparam SIM_NO_TEMP_SENSE = 1'b0;


    /////////////////////////
    // dev_clr sync-reset
    /////////////////////////

    wire user_mode_sync, arst, iopll_locked, clk100;
    alt_aeuex_user_mode_det dev_clr( .ref_clk(clk100), .user_mode_sync(user_mode_sync));

    wire source_reset;
    assign arst = ~user_mode_sync | ~cpu_resetn | ~iopll_locked | source_reset;

    wire [15:0] status_addr;
    wire        status_read,status_write,status_readdata_valid_eth;
    wire [31:0] status_readdata_eth, status_writedata;
    wire        clk_status = clk100;
    wire        clk_txmac;    // MAC + PCS clock - at least 312.5Mhz
    wire        clk_rxmac;    // MAC + PCS clock - at least 312.5Mhz

wire [15:0] khz_clk_rx_rs;
wire [15:0] khz_clk_tx_rs;
wire [15:0]   khz_rx_clk_i;
wire [15:0]   khz_tx_clk_i;
wire clk_rx_rs;
wire clk_tx_rs;
wire [7:0]    prescale;
wire          khz_all;

    // input domain (from user logic toward pins)
    wire                   clk_din = clk_txmac;    //clk320;  // nominal 312
    wire [WORDS*WIDTH-1:0] din;               // payload to send, left to right
    wire       [WORDS-1:0] din_start;         // start pos, first of every 8 bytes
    wire     [WORDS*8-1:0] din_end_pos;       // end position, any byte
    wire                   din_ack;           // payload is accepted

    // output domain (from pins toward user logic)
    wire                   clk_dout = clk_rxmac;    //clk320; // nominal 312
    wire    [WORDS*64-1:0] dout_d;            // 5 word out stream, left to right
    wire       [WORDS-1:0] dout_first_data;
    wire     [WORDS*8-1:0] dout_last_data;
    wire                   dout_valid;

    wire    [511:0] l8_tx_data;
    wire      [5:0] l8_tx_empty;
    wire            l8_tx_endofpacket;
    wire            l8_tx_ready;
    wire            l8_tx_startofpacket;
    wire            l8_tx_valid;
    wire    [511:0] l8_rx_data;
    wire      [5:0] l8_rx_empty;
    wire            l8_rx_endofpacket;
    wire            l8_rx_startofpacket;
    wire            l8_rx_valid;
    wire      [5:0] l8_rx_error;

    //--- functions
 //   `include "common/alt_aeuex_wide_l8if_functions.iv"

   // assign l8_tx_valid         = 1'b1;


 wire serial_clk_1;
    wire pll_locked_1;
    wire serial_clk_2;
    wire pll_locked_2;


    wire [1:0] pll_locked;

    atx_pll_s100 atx1 (
        .pll_refclk0(clk_ref_r),          // pll_refclk0.clk
        .tx_serial_clk_gxt(serial_clk_1),
        .pll_locked(pll_locked_1),      // pll_locked.pll_locked
        .pll_cal_busy()                 // pll_cal_busy.pll_cal_busy
    );
    
    atx_pll_s100 atx2 (
         .pll_refclk0(clk_ref_r),          // pll_refclk0.clk
        .tx_serial_clk_gxt(serial_clk_2),
        .pll_locked(pll_locked_2),      // pll_locked.pll_locked
        .pll_cal_busy()                 // pll_cal_busy.pll_cal_busy
    );

    assign pll_locked = {pll_locked_1, pll_locked_2};


    alt_e100s10_sys_pll u0 (
        .rst        (~cpu_resetn),  // reset.reset
        .refclk     (clk50),        // refclk.clk
        .locked     (iopll_locked), // locked.export
        .outclk_0   (clk100)        // outclk0.clk
    );




    // map reconfig registers to 0x4000-0x7FFF

    wire        reco_waitrequest;
    wire        reco_readdata_valid;
    wire [31:0] reco_readdata;

    wire        stat_waitrequest;
    wire [31:0] stat_readdata;
    wire        select_waitrequest; 

    reg        status_read_r;
    reg        status_write_r;
    reg [31:0] status_writedata_r;
    reg [15:0] status_addr_r;
  
    always @(posedge clk_status) begin
        if (arst) begin
            status_read_r      <= 0;
            status_write_r     <= 0;
            status_writedata_r <= 32'b0;
            status_addr_r      <= 16'b0;
        end
        else if( !select_waitrequest || status_read || status_write ) begin
             status_read_r      <= status_read;
            status_write_r     <= status_write;
            status_writedata_r <= status_writedata;
            status_addr_r      <= status_addr;
        end
    end
   
    assign select_waitrequest       = ((status_addr_r >= 16'h4000) && (status_addr_r <= 16'h7FFF)) ? reco_waitrequest :
                                      ((status_addr_r >= 16'h0)    && (status_addr_r <= 16'hDFF))  ? stat_waitrequest :
                                      1'b0;

    wire        reco_cs             = ((status_addr_r >= 16'h4000) && (status_addr_r <= 16'h7FFF));
    wire        reco_read           = status_read_r && reco_cs;
    wire        reco_write          = status_write_r && reco_cs;
    wire [12:0] reco_addr           = status_addr_r[12:0]; 
    assign      reco_readdata_valid = reco_read && !reco_waitrequest;
 
    wire        stat_cs             = ((status_addr_r >= 16'h0) && (status_addr_r <= 16'hDFF));
    wire        stat_read           = status_read_r  && stat_cs;
    wire        stat_write          = status_write_r && stat_cs;
    wire [15:0] stat_addr           = status_addr_r[15:0]; 
    wire        stat_readdata_valid;



    wire tx_lanes_stable;
    wire rx_pcs_ready;
    ex_100g ex_100g_inst (
        .clk_ref(clk_ref_r),
        .csr_rst_n(~arst),
        .tx_rst_n(1'b1),
        .rx_rst_n(1'b1),
        .clk_status(clk_status),
        .status_write(stat_write),
        .status_read(stat_read),
        .status_addr(stat_addr),
        .status_writedata(status_writedata_r[31:0]),
        .status_readdata(stat_readdata),
        .status_readdata_valid(stat_readdata_valid),
        .status_waitrequest(stat_waitrequest),

        //.clk_tx_rs_frompll(clk_tx_rs_frompll),                //in
        //.txfec_pll_locked_frompll(txfec_pll_locked_frompll),  //in

        .clk_txmac(clk_txmac),
        .l8_tx_startofpacket(l8_tx_startofpacket),
        .l8_tx_endofpacket(l8_tx_endofpacket),
        .l8_tx_valid(l8_tx_valid),
        .l8_tx_ready(l8_tx_ready),
        .l8_tx_empty(l8_tx_empty),
        .l8_tx_data(l8_tx_data),
        .l8_tx_error(1'b0),
        .clk_rxmac(clk_rxmac),
        .l8_rx_error(l8_rx_error),
        .l8_rx_valid(l8_rx_valid),
        .l8_rx_startofpacket(l8_rx_startofpacket),
        .l8_rx_endofpacket(l8_rx_endofpacket),
        .l8_rx_empty(l8_rx_empty),
        .l8_rx_data(l8_rx_data),

        .tx_serial(tx_serial),
        .rx_serial(rx_serial),

        .reconfig_clk(clk_status),
        .reconfig_reset(arst),
        .reconfig_write(reco_write),
        .reconfig_read(reco_read),
        .reconfig_address(reco_addr),
        .reconfig_writedata(status_writedata_r[31:0]),
        .reconfig_readdata(reco_readdata[31:0]),
        .reconfig_waitrequest(reco_waitrequest),

        .tx_lanes_stable(tx_lanes_stable),
        .rx_pcs_ready(rx_pcs_ready),
        .rx_block_lock(rx_block_lock),
        .rx_am_lock(rx_am_lock),
        .l8_txstatus_valid(),
        .l8_txstatus_data(),
        .l8_txstatus_error(),
        .l8_rxstatus_valid(),
        .l8_rxstatus_data(),
        .tx_serial_clk         ({serial_clk_2,serial_clk_1}),

        .tx_pll_locked         (pll_locked)
    );

    // _______________________________________
    // generate and check some simple data transfers
    // _____________________________________________________________

    wire [31:0] status_readdata_pc;
    wire status_readdata_valid_pc;

    alt_e100s10_packet_client pc (
        .i_arst                     (arst),

        .i_clk_tx                   (clk_txmac),
        .i_tx_ready                 (l8_tx_ready),
        .o_tx_valid                 (l8_tx_valid),
        .o_tx_data                  (l8_tx_data),
        .o_tx_sop                   (l8_tx_startofpacket),
        .o_tx_eop                   (l8_tx_endofpacket),
        .o_tx_empty                 (l8_tx_empty),

        .i_clk_rx                   (clk_rxmac),
        .i_rx_sop                   (l8_rx_startofpacket),
        .i_rx_eop                   (l8_rx_endofpacket),
        .i_rx_empty                 (l8_rx_empty),
        .i_rx_data                  (l8_rx_data),
        .i_rx_valid                 (l8_rx_valid),

        .i_clk_status               (clk_status),
        .i_status_addr              (status_addr),
        .i_status_read              (status_read),
        .i_status_write             (status_write),
        .i_status_writedata         (status_writedata),
        .o_status_readdata          (status_readdata_pc),
        .o_status_readdata_valid    (status_readdata_valid_pc)
    );

    // _____________________________________________________________
    // merge status bus
    // _____________________________________________________________

    wire [31:0] status_readdata;
    wire status_readdata_valid, status_waitrequest;

    alt_aeuex_avalon_mm_read_combine #(
        .NUM_CLIENTS         (3),
        .TIMEOUT             (11)
    ) arc (
        .clk                 (clk_status),
        .arst                (arst),
        .host_read           (status_read),
        .host_readdata       (status_readdata),
        .host_readdata_valid (status_readdata_valid),
        .host_waitrequest    (status_waitrequest),


        .client_readdata_valid    ({stat_readdata_valid, status_readdata_valid_pc, reco_readdata_valid}),
        .client_readdata          ({stat_readdata      , status_readdata_pc      , reco_readdata})

    );

    // _______________________________________________________________________________________________________________ 
    // jtag_avalon 
    // _______________________________________________________________________________________________________________
    wire [31:0] av_addr;
    assign status_addr = av_addr[17:2];
    wire [3:0] byteenable;

    alt_e100s10_jtag_avalon jtag_master (
        .clk_clk                (clk_status),
        .clk_reset_reset        (arst),
        .master_address         (av_addr),
        .master_readdata        (status_readdata),
        .master_read            (status_read),
        .master_write           (status_write),
        .master_writedata       (status_writedata),
        .master_waitrequest     (status_waitrequest),
        .master_readdatavalid   (status_readdata_valid),
        .master_byteenable      (byteenable),
        .master_reset_reset     ()
    );
    // ___________________________________________________________

    // Sources and probes instance

    reg [5:0] clk50_cnt = 6'b0;
    reg [5:0] clk100_cnt = 6'b0;
    reg [5:0] clk_txmac_cnt = 6'b0;
    reg [5:0] clk_rxmac_cnt = 6'b0;
    reg [5:0] clk_rx_rs_cnt = 6'b0;
    reg [5:0] clk_tx_rs_cnt = 6'b0;
    reg       l8_rx_startofpacketD=0;
    reg       l8_rx_endofpacketD=0;
    reg       l8_tx_startofpacketD=0;
    reg       l8_tx_endofpacketD=0;
    reg       l8_rx_errorD=0;
    reg [5:0] tx_sop_cnt = 6'b0;
    reg [5:0] tx_eop_cnt = 6'b0;
    reg [5:0] rx_sop_cnt = 6'b0;
    reg [5:0] rx_eop_cnt = 6'b0;
    reg [5:0] rx_err_cnt = 6'b0;


    always @(posedge clk_txmac) begin
        if (rx_block_lock ) begin
        tx_sop_cnt <= 6'h0;
        tx_eop_cnt <= 6'h0;
        end 
        else begin
        l8_tx_startofpacketD <= l8_tx_startofpacket&l8_tx_ready;
        l8_tx_endofpacketD    <= l8_tx_endofpacket &l8_tx_ready;
        tx_sop_cnt <= l8_tx_startofpacketD ? tx_sop_cnt + 6'd1 : tx_sop_cnt;
        tx_eop_cnt <= l8_tx_endofpacketD   ? tx_eop_cnt + 6'd1 : tx_eop_cnt;
        end
    end

    always @(posedge clk_rxmac) begin
        if (rx_block_lock ) begin
        rx_sop_cnt <= 6'h0;
        rx_eop_cnt <= 6'h0;   
        rx_err_cnt <= 6'h0;
        end 
        else begin
        l8_rx_startofpacketD <= l8_rx_startofpacket&&l8_rx_valid;
        l8_rx_endofpacketD   <= l8_rx_endofpacket &&l8_rx_valid;
        l8_rx_errorD         <= l8_rx_error && l8_rx_valid;
        rx_sop_cnt <= l8_rx_startofpacketD ? rx_sop_cnt + 6'd1 : rx_sop_cnt;
        rx_eop_cnt <= l8_rx_endofpacketD   ? rx_eop_cnt + 6'd1 : rx_eop_cnt;
        rx_err_cnt <= l8_rx_errorD   ? rx_err_cnt + 6'd1 : rx_err_cnt;
        end
    end

    wire  all_rx_seop_cnt_all = (|rx_sop_cnt) | (|rx_eop_cnt) | (|rx_err_cnt);
    wire  all_tx_seop_cnt_all = (|tx_sop_cnt) | (|tx_eop_cnt);

    always @(posedge clk_rxmac) begin
	clk_rxmac_cnt <= clk_rxmac_cnt + 6'd1;
    end

    always @(posedge clk_txmac) begin
	clk_txmac_cnt <= clk_txmac_cnt + 6'd1;
    end

    always @(posedge clk50) begin
	clk50_cnt <= clk50_cnt + 6'd1;
    end

    always @(posedge clk100) begin
	clk100_cnt <= clk100_cnt + 6'd1;
    end

    always @(posedge clk_rx_rs) begin
	clk_rx_rs_cnt <=  clk_rx_rs_cnt + 6'd1;
    end
    always @(posedge clk_tx_rs) begin
	clk_tx_rs_cnt <=  clk_tx_rs_cnt + 6'd1;
    end


    wire [7:0] system_status;
    assign system_status[0] = arst;

    assign system_status[1] = clk_txmac_cnt[5];
    assign system_status[2] = clk50_cnt[3];
    assign system_status[3] = clk_rxmac_cnt[5];

    assign system_status[4] = tx_lanes_stable;
    assign system_status[5] = rx_block_lock;
    assign system_status[6] = rx_am_lock;
    assign system_status[7] = rx_pcs_ready;	 
	 

assign user_io[0]= clk_txmac_cnt[5];
assign user_io[1]= clk_rxmac_cnt[5];
assign user_io[2]= clk_rx_rs_cnt[5];
assign user_io[3]= clk_tx_rs_cnt[5];
assign user_io[4]= rx_sop_cnt[5]; 
assign user_io[5]= rx_eop_cnt[5];
assign user_io[6]= tx_sop_cnt[5];
assign user_io[7]= tx_eop_cnt[5];
assign user_io[8]= prescale[4];
assign user_io[9]= khz_all;


    probe8 prb (
       .source  (source_reset),
       .probe   (system_status)
    );
endmodule


