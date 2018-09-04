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


`timescale 1ps / 1ps
module alt_e100s10_eth_4 #(
    parameter SIM_SHORT_AM = 1'b0,
    parameter SIM_EMULATE = 1'b0,

    parameter PHY_REFCLK = 1,
    parameter SYNOPT_FLOW_CONTROL = 0,
    parameter SYNOPT_NUMPRIORITY = 1,
    parameter SYNOPT_TXCRC_INS = 1,
    parameter SYNOPT_PREAMBLE_PASS = 1,
    parameter TARGET_CHIP = 2,
    parameter SYNOPT_MAC_STATS_COUNTERS = 1,
    parameter SYNOPT_STRICT_SOP  = 0, // UNH SFD compliance feature                                
     
    parameter WORDS = 4,                   // no override
    parameter RXERRWIDTH  = 6,
    parameter SYNOPT_AVALON  = 1,
    parameter SYNOPT_ALIGN_FCSEOP = 0,
    parameter REVID = 32'h08092017,
    parameter BASE_PHY = 1,
    parameter BASE_TXMAC = 4,
    parameter BASE_RXMAC = 5,
    parameter BASE_TXSTAT = 6,
    parameter BASE_RXSTAT = 7,
    parameter BASE_TXFEC = 12,
    parameter BASE_RXFEC = 13,
    parameter ADDRSIZE   = 8,
    parameter ERRORBITWIDTH  = 11,
    parameter SYNOPT_LINK_FAULT = 0,
    parameter SYNOPT_AVG_IPG = 12,
    parameter SYNOPT_MAC_DIC = 1,
    parameter SYNOPT_PTP = 0,
    parameter SYNOPT_TOD_FMT = 0,
    parameter PTP_LATENCY = 52,
    parameter PTP_FP_WIDTH = 16, // width of fingerprint, ptp parameter

    parameter PMA_WORD_SIZE     = 66,
    parameter FEC_AM_BITS       = 14,   //for simulation purpose, to make am bit space short 
    parameter EXT_TX_PLL        = 1'b0, // whether to use external fpll for TX core clocks
    parameter RX_PLL_TYPE       = "FPLL",
    parameter TX_PLL_TYPE       = "FPLL",
    parameter SYNOPT_C4_RSFEC   = 1,
	 parameter ENABLE_ANLT       = 0
    )(
    // 100G IO for the Ethernet

    // Clocks
    input                   rx_clk, 
    input                   tx_clk,
    input                   clk_rx_rs, 
    input                   clk_tx_rs, 
    input                   clk_ref, 	    //644/322mhz

    // Resets & Status
    input                   csr_rst_n     ,
    input                   tx_rst        ,
    input                   rx_rst        ,
    input  [3:0]            rx_pma_ready  ,
    input  [3:0]            tx_pma_ready  ,         // Tx XCVRs are out of reset
    output                  rx_digitalreset_req, 
    output                  native_phy_reset,
    input  [3:0]            tx_dll_lock   ,
    input  [3:0]            tx_digitalreset_stat,

    
    input                   fec_tx_pll_locked ,
    input                   fec_rx_pll_locked ,
    output                  tx_lanes_stable,
    output                  enable_rsfec,
	 input  [263:0]          tx_data_kr,
	 input                   kr_mode,
    //  PMA I/O
    input  [WORDS*66-1:0]   rx_data_in, 
    input  [3:0]            rx_data_valid,  // read enable will get generated externally
    output [3:0]            rx_bitslip,   
    output [4*66-1:0]       tx_data_out, 
    output [3:0]            tx_data_valid,


    // Avalon TX Interface
    input                   l8_tx_startofpacket,
    input                   l8_tx_endofpacket,
    input                   l8_tx_valid,
    output                  l8_tx_ready,
    input   [5:0]           l8_tx_empty,
    input   [8*64-1:0]      l8_tx_data,
    input                   l8_tx_error,
    output                  l8_txstatus_valid,
    output  [39:0]          l8_txstatus_data,
    output  [6:0]           l8_txstatus_error,


    // Avalon RX Interface
    output                  l8_rx_startofpacket,
    output                  l8_rx_endofpacket,
    output                  l8_rx_valid,
    output  [5:0]           l8_rx_empty,   
    output[ 8*64-1:0]       l8_rx_data,
    output                  l8_rxstatus_valid,
    output  [39:0]          l8_rxstatus_data,
    output  [5:0]           l8_rx_error,

    // AVMM Interface
    input                   avmm_clk,             // 100 MHz
    input                   avmm_reset,           // global reset, async    -- check 
    input   [15:0]          status_addr,
    input                   status_read,
    input                   status_write,
    output wire[31:0]       status_readdata,
    output wire             status_readdata_valid,
    input   [31:0]          status_writedata,
    output wire             status_waitrequest,

    // CSR: TX Status In
    input   [3:0]           tx_pempty,
    input   [3:0]           tx_pfull,
    input   [3:0]           tx_empty,
    input   [3:0]           tx_full,
    input   [1:0]           tx_pll_locked,
    
    //CSR: RX Status In 
    input   [3:0]           rx_pempty,    
    input   [3:0]           rx_pfull,
    input   [3:0]           rx_empty,
    input   [3:0]           rx_full,
    input   [3:0]           rx_is_lockedtodata,
    
    //CSR: RX Status and Control Out
    output  [3:0]           rx_seriallpbken,
    output                  rx_set_locktoref,
    output                  rx_set_locktodata,
    output                  rx_pcs_ready,
    output                  rx_block_lock,
    output                  rx_am_lock,

    // MAC RX
    output                rx_data_out_valid,
    output [WORDS*64-1:0] rx_data_out,  // read bytes left to right
    output [WORDS*8-1:0]  rx_ctl_out,   // read bits left to right
    output [WORDS-1:0]    rx_first_data,// word contains the first non-preamble data of a frame
    output [WORDS*8-1:0]  rx_last_data, // byte contains the last data before FCS
    output                rx_fcs_error,
    output                rx_fcs_valid,
    output                unidirectional_en,
    output                link_fault_gen_en,
    output                remote_fault_status,
    output                local_fault_status,
    output [WORDS-1:0]    rx_mii_start,
    output                o_hi_ber,

    // Flow Control 
    input  [SYNOPT_NUMPRIORITY-1:0] pause_insert_tx0,
    input  [SYNOPT_NUMPRIORITY-1:0] pause_insert_tx1,
    output [SYNOPT_NUMPRIORITY-1:0] pause_receive_rx
 );




// ?
wire	   [WORDS*66-1:0]  caui4_rs_din;
wire	   [WORDS*66+1:0]  caui4_rs_dout;

wire        csr_reset;
wire [7:0]                 avmm_addr;
wire [32-1:0]              avmm_din;
wire [32-1:0]              avmm_rs_rx_dout;
wire                       avmm_rs_rx_dval;
wire                       avmm_rs_rx_write;
wire                       avmm_rs_rx_read;

wire [32-1:0]              avmm_rs_tx_dout;
wire                       avmm_rs_tx_dval;
wire                       avmm_rs_tx_write;
wire                       avmm_rs_tx_read;

wire [32-1:0]              avmm_mac_rx_dout;
wire                       avmm_mac_rx_dval;
wire                       avmm_mac_rx_write;
wire                       avmm_mac_rx_read;

wire [32-1:0]              avmm_mac_tx_dout;
wire                       avmm_mac_tx_dval;
wire                       avmm_mac_tx_write;
wire                       avmm_mac_tx_read;

wire [32-1:0]              avmm_fc_tx_dout;
wire                       avmm_fc_tx_dval;
wire                       avmm_fc_tx_write;
wire                       avmm_fc_tx_read;

wire [32-1:0]              avmm_fc_rx_dout;
wire                       avmm_fc_rx_dval;
wire                       avmm_fc_rx_write;
wire                       avmm_fc_rx_read;

wire [32-1:0]              avmm_mac_tx_stats_dout;
wire                       avmm_mac_tx_stats_dval;
wire                       avmm_mac_tx_stats_write;
wire                       avmm_mac_tx_stats_read;
wire [32-1:0]              avmm_mac_rx_stats_dout;
wire                       avmm_mac_rx_stats_dval;
wire                       avmm_mac_rx_stats_write;
wire                       avmm_mac_rx_stats_read;

wire                       rx_pcs_sclr, rx_mac_sclr, tx_pcs_sclr, tx_mac_sclr;


wire			rfec_slip_rst_req;
wire                      tpcs_dout_valid;
wire                      rxpcs_fully_aligned;
wire                      rfec_align_status;
wire                      rx_am_lock_pcs;
wire                      rfec_amps_lock_all;
wire                      rx_block_lock_pcs;
wire                      tpcs_dout_valid_inv = !tpcs_dout_valid;

// signals that need confirmation by Alvin
//wire                      tpcs_dout_valid_0     = (SYNOPT_C4_RSFEC==1) ? (!tx_pcs_sclr): tpcs_dout_valid;
//wire                      rxpcs_fully_aligned_0 = (SYNOPT_C4_RSFEC==1) ? (rfec_align_status): rxpcs_fully_aligned;
//assign                    rx_am_lock            = (SYNOPT_C4_RSFEC==1) ? (rfec_amps_lock_all): rx_am_lock_pcs;
//assign                    rx_block_lock         = (SYNOPT_C4_RSFEC==1) ? (rfec_amps_lock_all): rx_block_lock_pcs;

wire                      tpcs_dout_valid_0     = (enable_rsfec==1) ? (!tx_pcs_sclr): tpcs_dout_valid;
wire                      rxpcs_fully_aligned_0 = (enable_rsfec==1) ? (rfec_align_status): rxpcs_fully_aligned;
assign                    rx_am_lock            = (enable_rsfec==1) ? (rfec_amps_lock_all): rx_am_lock_pcs;
assign                    rx_block_lock         = (enable_rsfec==1) ? (rfec_amps_lock_all): rx_block_lock_pcs;

wire [WORDS*66-1:0]       rx_data_in_0; 
wire                 rx_data_valid_0; 
  
wire    [66*4-1:0]        tpcs_dout;



// -------------------------------------------//
// =================  FEC  ================== //
// -------------------------------------------//
genvar i;
generate
if (SYNOPT_C4_RSFEC==1) begin : WITH_FEC

wire [3:0]    rx_bitslip_rsfec;
wire          rfec_slip_rst_req_rsfec;
wire          rfec_align_status_rsfec;
wire          rfec_amps_lock_all_rsfec;
wire [32-1:0] avmm_rs_rx_dout_rsfec;
wire          avmm_rs_rx_dval_rsfec;

//  +++++++++++  RX FEC +++++++++++  //
alt_e100s10_rs_rx  #(
       .BASE                   (BASE_RXFEC),	
       .PMA_WORD_SIZE          (PMA_WORD_SIZE),	
       .FEC_AM_BITS            (FEC_AM_BITS)
)rx_rsfec  (
       .arst                   (rx_pcs_sclr),	           
       .l0_din_pma             (rx_data_in[4*66-1: 3*66]), 
       .l1_din_pma             (rx_data_in[3*66-1: 2*66]),
       .l2_din_pma             (rx_data_in[2*66-1: 1*66]),
       .l3_din_pma             (rx_data_in[1*66-1: 0*66]),
       .lanes_valid_in_pma     (rx_data_valid),            
//	// to pcs
       .mrg_data_mgr           (caui4_rs_dout[4*66-1:0]),  
       .mrg_data_cp1_mgr       (),                        
       .amcode_start_out_mgr   (caui4_rs_dout[4*66]),      
       .mrg_valid_out_mgr      (caui4_rs_dout[4*66+1]),    

       .slip                   (rx_bitslip_rsfec[3:0]),          
       .slip_rst_req 		(rfec_slip_rst_req_rsfec),    
       .align_status           (rfec_align_status_rsfec),             
       .amps_lock_all          (rfec_amps_lock_all_rsfec), 

        //csr interface
       .clk_csr                (avmm_clk),	
       .csr_reset              (csr_reset),    
       //.reset_slv              (avmm_reset),    
       .csr_write              (avmm_rs_rx_write),
       .csr_read               (avmm_rs_rx_read),
       .csr_address            ({8'h0, avmm_addr}),
       .csr_din                (avmm_din[32-1:0]),
       .csr_dout               (avmm_rs_rx_dout_rsfec[32-1:0]),
       .csr_dval               (avmm_rs_rx_dval_rsfec),

       .clk                    (rx_clk),    
       .clk_rs                 (clk_rx_rs), 
       .clk_pma                (rx_clk)

);

//assign    rx_data_in_0    = caui4_rs_dout[4*66-1:0];
//assign    rx_data_valid_0 = caui4_rs_dout[4*66+1] & !caui4_rs_dout[4*66];

wire [4*66-1:0]       tx_data_out_rsfec;
wire [32-1:0]         avmm_rs_tx_dout_rsfec;
wire                  avmm_rs_tx_dval_rsfec;

//  +++++++++++  RX FEC +++++++++++  //
alt_e100s10_rs_tx  #(
       .BASE                    (BASE_TXFEC),	
       .PMA_WORD_SIZE           (PMA_WORD_SIZE),	
       .FEC_AM_BITS             (FEC_AM_BITS)
)tx_rsfec  (
      .arst         (tx_pcs_sclr),		//reset contoller
       //   from tx pcs
      .tcd_valid_in         (tpcs_dout_valid),
      .tcd_data_in          (tpcs_dout),            
      .am_start_in          (tpcs_dout_valid_inv),  
      .l3_dout_evl          (),
      .l2_dout_evl          (),
      .l1_dout_evl          (),
      .l0_dout_evl          (),
      .am_start_out_evl     (),
      .lanes_valid_out_evl  (),

      //to serdes
      .l3_dout_pma          (tx_data_out_rsfec[4*66-1: 3*66]),
      .l2_dout_pma          (tx_data_out_rsfec[3*66-1: 2*66]),
      .l1_dout_pma          (tx_data_out_rsfec[2*66-1: 1*66]),
      .l0_dout_pma          (tx_data_out_rsfec[1*66-1: 0]),
      .lanes_valid_out_pma  (),

      //csr interface
      .clk_csr            (avmm_clk),
      .csr_reset          (csr_reset),    
      //.reset_slv          (avmm_reset),
      .csr_write          (avmm_rs_tx_write),
      .csr_read           (avmm_rs_tx_read),
      .csr_address        ({8'h0, avmm_addr}),
      .csr_din            (avmm_din[32-1:0]),
      .csr_dout           (avmm_rs_tx_dout_rsfec[32-1:0]),
      .csr_dval           (avmm_rs_tx_dval_rsfec),

      .clk                (tx_clk),
      .clk_rs             (clk_tx_rs), 	
      .clk_pma            (tx_clk)
    );

assign    rx_data_in_0         = (enable_rsfec == 1) ? caui4_rs_dout[4*66-1:0]                      : rx_data_in;
assign    rx_data_valid_0      = (enable_rsfec == 1) ? caui4_rs_dout[4*66+1] & !caui4_rs_dout[4*66] : &rx_data_valid[3:0];
assign    rx_bitslip           = (enable_rsfec == 1) ? rx_bitslip_rsfec                             : 4'h0; 
assign    rfec_slip_rst_req    = (enable_rsfec == 1) ? rfec_slip_rst_req_rsfec                      : 1'h0; 
assign    rfec_align_status    = (enable_rsfec == 1) ? rfec_align_status_rsfec                      : 1'b0;
assign    rfec_amps_lock_all   = (enable_rsfec == 1) ? rfec_amps_lock_all_rsfec                     : 1'b0;
//assign    tx_data_out          = (enable_rsfec == 1) ? tx_data_out_rsfec                            : tpcs_dout;


reg	rs_tx_dval, rs_rx_dval;
always @ (posedge avmm_clk) begin
	rs_tx_dval <= avmm_rs_tx_read;
	rs_rx_dval <= avmm_rs_rx_read;
end

assign    avmm_rs_tx_dout   = (enable_rsfec == 1) ? avmm_rs_tx_dout_rsfec : 32'hdeadc0de;
assign    avmm_rs_rx_dout   = (enable_rsfec == 1) ? avmm_rs_rx_dout_rsfec : 32'hdeadc0de;
assign    avmm_rs_tx_dval   = (enable_rsfec == 1) ? avmm_rs_tx_dval_rsfec : rs_tx_dval;
assign    avmm_rs_rx_dval   = (enable_rsfec == 1) ? avmm_rs_rx_dval_rsfec : rs_rx_dval;

	wire [263:0] data_in;
	
	assign data_in = (SYNOPT_C4_RSFEC == 1) ? tx_data_out_rsfec : tpcs_dout;
	
	if (ENABLE_ANLT == 1) begin: WITH_KR 	
  alt_e100s10_data_grp_mx_pipe  #(
    .SIM_EMULATE(SIM_EMULATE),
    .SEL_SIZE(1),
    .ENABLE_ANLT(ENABLE_ANLT)
  ) grp_66x4_tx_inst (
    .clk_in     (tx_clk),
    .data_0     (data_in),	
    .data_1     (),
    .data_2     (tx_data_kr),
    .data_out   (tx_data_out),
    .sel        (kr_mode)
  );
  
end else begin: NO_KR
  alt_e100s10_data_grp_mx_pipe  #(
    .SIM_EMULATE(SIM_EMULATE),
    .SEL_SIZE(1),
    .ENABLE_ANLT(ENABLE_ANLT)
  ) grp_66x4_tx_inst (
    .clk_in      (tx_clk),
    .data_0      (tx_data_out_rsfec),	
    .data_1      (tpcs_dout),
    .data_2      (),
    .data_out    (tx_data_out),
    .sel         (enable_rsfec)
  );
end
end 

else begin : NO_FEC

assign    rx_data_in_0        = rx_data_in;
assign    rx_data_valid_0     = &rx_data_valid[3:0];
assign    rx_bitslip          = 4'h0; 
assign    rfec_slip_rst_req   = 1'h0; 
assign    rfec_align_status   = 1'b0;
assign    rfec_amps_lock_all  = 1'b0;
//assign    tx_data_out         = tpcs_dout;

reg	rs_tx_dval, rs_rx_dval;
always @ (posedge avmm_clk) begin
	rs_tx_dval <= avmm_rs_tx_read;
	rs_rx_dval <= avmm_rs_rx_read;
end

assign    avmm_rs_tx_dout   = 32'hdeadc0de;
assign    avmm_rs_rx_dout   = 32'hdeadc0de;
assign    avmm_rs_tx_dval   = rs_tx_dval;
assign    avmm_rs_rx_dval   = rs_rx_dval;

	if (ENABLE_ANLT == 1) begin: WITH_KR 	
  alt_e100s10_data_grp_mx_pipe  #(
    .SIM_EMULATE(SIM_EMULATE),
    .SEL_SIZE(1),
    .ENABLE_ANLT(ENABLE_ANLT)
  ) grp_66x4_tx_inst (
    .clk_in     (tx_clk),
    .data_0     (tpcs_dout),	
    .data_1     (),
    .data_2     (tx_data_kr),
    .data_out   (tx_data_out),
    .sel        (kr_mode)
  );
  
end else begin: NO_KR
  assign    tx_data_out         = tpcs_dout;
end
end


	



endgenerate 

// -------------------------------------------//
// =================  PCS  ================== //
// -------------------------------------------//


// Alignment Marker generation block
wire                    tx_crc_ins_en, tx_am_mac, tx_am_pcs;
alt_e100s10_am am (
    .clk                (tx_clk),
    .sclr               (tx_mac_sclr),
    .enable_rsfec       (enable_rsfec),
    .tx_crc_ins_en      (tx_crc_ins_en),
    .tx_am_mac          (tx_am_mac),            
    .tx_am_pcs          (tx_am_pcs) 
);
defparam    am .SIM_EMULATE = SIM_EMULATE;
defparam    am .SIM_SHORT_AM = SIM_SHORT_AM;
defparam    am .SYNOPT_C4_RSFEC = SYNOPT_C4_RSFEC;
defparam    am .SYNOPT_LINK_FAULT = SYNOPT_LINK_FAULT;


//  +++++++++++  TX PCS +++++++++++  //
wire    [WORDS*8-1:0]   pcs_din_c;
wire    [WORDS*64-1:0]  pcs_din_d;

alt_e100s10_pcs_t #(
    .SIM_SHORT_AM       (SIM_SHORT_AM),
    .SIM_EMULATE        (SIM_EMULATE),
    .SYNOPT_C4_RSFEC    (SYNOPT_C4_RSFEC),   // need to fix this - Faisal
    .ENABLE_ANLT        (ENABLE_ANLT)
) tpcs  (
    .clk                (tx_clk),
    .reset              (tx_pcs_sclr),
    .din_d              (pcs_din_d),
    .din_c              (pcs_din_c),
    .din_am             (tx_am_pcs),
    .dout               (tpcs_dout),
    .enable_rsfec       (enable_rsfec),
    .dout_valid         (tpcs_dout_valid)

);


//  +++++++++++  RX PCS +++++++++++  //
wire                    xcvr_rx_sclr;
wire                    rpcs_rst_req;
wire [19:0]             rxpcs_frm_err;
wire [19:0]             rxpcs_dout_word_locked;
wire [20*5-1:0]         rxpcs_dout_tags;
wire                    rxpcs_dout_deskew_locked, hi_ber, rxpcs_frm_err_sclr, rx_fifo_soft_purge;
wire [4*64-1:0]         pcs_dout_d;
wire [4*8-1:0]          pcs_dout_c;
wire                    pcs_dout_am;
  
alt_e100s10_pcs_r  #(
    .SIM_SHORT_AM       (SIM_SHORT_AM),
    .SIM_EMULATE        (SIM_EMULATE),
    .SYNOPT_LINK_FAULT  (SYNOPT_LINK_FAULT),
    .SYNOPT_C4_RSFEC    (SYNOPT_C4_RSFEC),   // need to fix this - Faisal
    .ENABLE_ANLT        (ENABLE_ANLT)
) rpcs  (

    .clk                (rx_clk),
    .reset              (rx_pcs_sclr),
    .xcvr_sclr          (xcvr_rx_sclr),
    .rx_pcs_rst_req     (rpcs_rst_req),
    .enable_rsfec       (enable_rsfec),
    .din                (rx_data_in_0),	        //either from rxfec or pma
    .din_valid          (rx_data_valid_0),	//either from rxfec or pma
    .din_req            (),
    .deskew_locked      (rxpcs_dout_deskew_locked),  
    .align_locked       (rxpcs_fully_aligned),       
    .rfec_align_locked   (rfec_align_status),       
    .rfec_slip_rst_req   (rfec_slip_rst_req),       
    .lanes_word_locked  (rxpcs_dout_word_locked),    
    .word_locked        (rx_block_lock_pcs),                     
    .lanes_ordered      (rx_am_lock_pcs),            
    .dout_tags          (rxpcs_dout_tags),                     
    .dout_stky_frm_err  (rxpcs_frm_err),             
    .hi_ber             (hi_ber),                    
    .purge_fifo         (rx_fifo_soft_purge), 
    .frm_err_clr        (rxpcs_frm_err_sclr), 
    .dout_d             (pcs_dout_d),
    .dout_c             (pcs_dout_c),
    .dout_am            (pcs_dout_am)
);

//KR support
assign o_hi_ber = hi_ber;

// -------------------------------------------//
// =================  CSR  ================== //
// -------------------------------------------//
wire        eio_sys_rst, soft_rx_rst, soft_tx_rst;
wire [5:0]  delay;

// MAC - CSR 
wire       [15:0]         tx_max_frm_length;
wire       [7:0]          num_idle_rm;
wire       [15:0]         rx_max_frm_length;
wire                      tx_clk_stable;

alt_e100s10_csr #(
.SYNOPT_C4_RSFEC(SYNOPT_C4_RSFEC),
.ENABLE_ANLT(ENABLE_ANLT)
) csr   (
    .o_enable_rsfec         (enable_rsfec),
 // Clocks
    .csr_clk                (avmm_clk),
    .tx_clk                 (tx_clk),
    .rx_clk                 (rx_clk),
    .clk_rx_rs              (clk_rx_rs),
    .clk_tx_rs              (clk_tx_rs),
    .cdr_ref_clk            (clk_ref),
    
    // AVMMM Interface
    .reset                  (csr_reset),
    .write                  (status_write),
    .read                   (status_read),
    .address                (status_addr),
    .data_in                (status_writedata),
    .data_out               (status_readdata),
    .data_valid             (status_readdata_valid),
    .waitrequest            (status_waitrequest),
    .avmm_din               (avmm_din),
    .avmm_addr              (avmm_addr),

    // MAC AVMM Signals 
    .write_rxmac            (avmm_mac_rx_write),
    .read_rxmac             (avmm_mac_rx_read),
    .data_out_rxmac         (avmm_mac_rx_dout),
    .data_valid_rxmac       (avmm_mac_rx_dval),
    .write_txmac            (avmm_mac_tx_write),
    .read_txmac             (avmm_mac_tx_read),
    .data_out_txmac         (avmm_mac_tx_dout),
    .data_valid_txmac       (avmm_mac_tx_dval),
    .write_fc_tx            (avmm_fc_tx_write),
    .read_fc_tx             (avmm_fc_tx_read),
    .data_out_fc_tx         (avmm_fc_tx_dout),
    .data_valid_fc_tx       (avmm_fc_tx_dval),
    .write_fc_rx            (avmm_fc_rx_write),
    .read_fc_rx             (avmm_fc_rx_read),
    .data_out_fc_rx         (avmm_fc_rx_dout),
    .data_valid_fc_rx       (avmm_fc_rx_dval),
    
    // MAC Stats AVMM Signals 
    .write_rx_stats            (avmm_mac_rx_stats_write),
    .read_rx_stats             (avmm_mac_rx_stats_read),
    .data_out_rx_stats         (avmm_mac_rx_stats_dout),
    .data_valid_rx_stats       (avmm_mac_rx_stats_dval),
    .write_tx_stats            (avmm_mac_tx_stats_write),
    .read_tx_stats             (avmm_mac_tx_stats_read),
    .data_out_tx_stats         (avmm_mac_tx_stats_dout),
    .data_valid_tx_stats       (avmm_mac_tx_stats_dval),
    
    //RSFEC AVMM Signals 
    .write_tx_rsfec         (avmm_rs_tx_write),
    .read_tx_rsfec          (avmm_rs_tx_read),
    .data_out_tx_rsfec      (avmm_rs_tx_dout),
    .data_valid_tx_rsfec    (avmm_rs_tx_dval),
    .write_rx_rsfec         (avmm_rs_rx_write),
    .read_rx_rsfec          (avmm_rs_rx_read),
    .data_out_rx_rsfec      (avmm_rs_rx_dout),
    .data_valid_rx_rsfec    (avmm_rs_rx_dval),



    // Reset outputs
    .soft_txp_rst           (soft_tx_rst),
    .soft_rxp_rst           (soft_rx_rst),
    .eio_sys_rst            (eio_sys_rst),

   
    // RX status in
    .rx_pempty              (rx_pempty),
    .rx_pfull               (rx_pfull),
    .rx_empty               (rx_empty),
    .rx_full                (rx_full),
    .rxpcs_frm_err          (rxpcs_frm_err), 
    .rx_is_lockedtodata     (rx_is_lockedtodata),
    .rx_word_locked         (rxpcs_dout_word_locked),
    .rx_am_lock             (rx_am_lock_pcs),
    .rx_deskew_locked       (rxpcs_dout_deskew_locked),
    .rx_align_locked        (rxpcs_fully_aligned),
    .rx_hi_ber              (hi_ber), 
    .rxpcs_dout_tags        (rxpcs_dout_tags),
    .rx_am_lock_fec         (rfec_amps_lock_all),
    .rx_align_status_fec    (rfec_align_status),

     //RX strict preamble check 
    .cfg_sfd_det_on         (cfg_sfd_det_on),
    .cfg_preamble_det_on    (cfg_preamble_det_on),  

    // RX Status and Control Out
    .rxpcs_frm_err_sclr     (rxpcs_frm_err_sclr),
    .rx_fifo_soft_purge     (rx_fifo_soft_purge),
    .rx_seriallpbken        (rx_seriallpbken),
    .rx_set_locktoref       (rx_set_locktoref),
    .rx_set_locktodata      (rx_set_locktodata),
    .rx_word_locked_s       (),
    .rx_crc_pt              (rx_crc_pt),
    .rx_delay               (delay),

    // TX status in
    .tx_pempty              (tx_pempty),
    .tx_pfull               (tx_pfull),
    .tx_empty               (tx_empty),
    .tx_full                (tx_full),
    .tx_pll_locked          (tx_pll_locked),    
    .tx_fec_pll_locked      (fec_tx_pll_locked),
    .rx_fec_pll_locked      (fec_rx_pll_locked),
    .tx_digitalreset        (~tx_pma_ready),    

    // TX Status and Control Out
    .tx_clk_stable          (tx_clk_stable),
    .tx_crc_pt              (tx_crc_pt),
    .num_idle_rm            (num_idle_rm),

    // Statistics Vector
    .tx_vlandet_disable     (tx_cfg_vlandet_disable),
    .rx_vlandet_disable     (rx_cfg_vlandet_disable),
    .tx_max_frm_length      (tx_max_frm_length),
    .rx_max_frm_length      (rx_max_frm_length)

);

defparam    csr .SIM_HURRY = SIM_SHORT_AM;
defparam    csr .SYNOPT_C4_RSFEC = SYNOPT_C4_RSFEC;
defparam    csr .SIM_EMULATE = SIM_EMULATE;



// -------------------------------------------//
// =================  MAC  ================== //
// -------------------------------------------//
reg tx_clk_locked, rx_clk_locked;
always @ (posedge tx_clk)	tx_clk_locked <= tx_clk_stable;
always @ (posedge rx_clk)	rx_clk_locked <= &rx_is_lockedtodata;

alt_e100s10_mac #(
    .SIM_EMULATE            (SIM_EMULATE),
    .SYNOPT_FLOW_CONTROL    (SYNOPT_FLOW_CONTROL),
    .SYNOPT_NUMPRIORITY     (SYNOPT_NUMPRIORITY),
    .SYNOPT_TXCRC_INS       (SYNOPT_TXCRC_INS),
    .SYNOPT_PREAMBLE_PASS   (SYNOPT_PREAMBLE_PASS),
    .TARGET_CHIP            (TARGET_CHIP),
    .SYNOPT_MAC_STATS_COUNTERS     (SYNOPT_MAC_STATS_COUNTERS),
    .SYNOPT_STRICT_SOP      (SYNOPT_STRICT_SOP), // UNH SFD compliance feature                                
     
    .WORDS                  (WORDS),                   // no override
    .SYNOPT_AVALON          (SYNOPT_AVALON),
    .SYNOPT_ALIGN_FCSEOP    (SYNOPT_ALIGN_FCSEOP),
    .REVID                  (REVID),
    .BASE_TXMAC             (BASE_TXMAC),
    .BASE_RXMAC             (BASE_RXMAC),
    .SYNOPT_LINK_FAULT      (SYNOPT_LINK_FAULT),
    .SYNOPT_AVG_IPG         (SYNOPT_AVG_IPG),
    .SYNOPT_MAC_DIC         (SYNOPT_MAC_DIC),
    .SYNOPT_PTP             (SYNOPT_PTP),
    .SYNOPT_TOD_FMT         (SYNOPT_TOD_FMT),
    .PTP_LATENCY            (PTP_LATENCY),
    .PTP_FP_WIDTH           (PTP_FP_WIDTH) // width of fingerprint, ptp parameter
) alt_e100s10_mac(
    // 100G IO for the Ethernet

    // clocks and 
    .rx_clk                 (rx_clk), 
    .tx_clk                 (tx_clk),
    .rx_clk_locked		(rx_clk_locked), 
    .tx_clk_locked		(tx_clk_locked),

    // Resets 
    .tx_mac_sclr            (tx_mac_sclr),
    .rx_mac_sclr            (rx_mac_sclr),
    .reset_csr              (csr_reset), 

    // Avalon TX Interface
    .l8_tx_startofpacket    (l8_tx_startofpacket),
    .l8_tx_endofpacket      (l8_tx_endofpacket),
    .l8_tx_valid            (l8_tx_valid),
    .l8_tx_ready            (l8_tx_ready),
    .l8_tx_empty            (l8_tx_empty),
    .l8_tx_data             (l8_tx_data),
    .l8_tx_error            (l8_tx_error),
    .l8_txstatus_valid      (l8_txstatus_valid),
    .l8_txstatus_data       (l8_txstatus_data),
    .l8_txstatus_error      (l8_txstatus_error),

    // Avalon RX Interface
    .l8_rx_startofpacket    (l8_rx_startofpacket),
    .l8_rx_endofpacket      (l8_rx_endofpacket),
    .l8_rx_valid            (l8_rx_valid),
    .l8_rx_empty            (l8_rx_empty),   
    .l8_rx_data             (l8_rx_data),
    .l8_rxstatus_valid      (l8_rxstatus_valid),
    .l8_rxstatus_data       (l8_rxstatus_data),
    .l8_rx_error            (l8_rx_error),

    // AVMM Interface
    .avmm_clk               (avmm_clk),             // 100 MHz

    // PCS input/output
    .pre_pcs_din_am         (tx_am_mac),
    .pcs_din_d              (pcs_din_d),
    .pcs_din_c              (pcs_din_c),
    .pcs_dout_am            (pcs_dout_am),
    .pcs_dout_d             (pcs_dout_d),
    .pcs_dout_c             (pcs_dout_c),
    .tx_crc_ins_en          (tx_crc_ins_en),  

    // MAC RX
    .rx_data_out_valid      (rx_data_out_valid),
    .rx_data_out            (rx_data_out),  // read bytes left to right
    .rx_ctl_out             (rx_ctl_out),   // read bits left to right
    .rx_first_data          (rx_first_data),// word contains the first non-preamble data of a frame
    .rx_last_data           (rx_last_data), // byte contains the last data before FCS
    .rx_fcs_error           (rx_fcs_error),
    .rx_fcs_valid           (rx_fcs_valid),
    .rx_pcs_fully_aligned   (rxpcs_fully_aligned_0),
    .unidirectional_en      (unidirectional_en),
    .link_fault_gen_en      (link_fault_gen_en),
    .remote_fault_status    (remote_fault_status),
    .local_fault_status     (local_fault_status),
    .rx_mii_start           (rx_mii_start),

    // Flow Control
    .pause_insert_tx0      (pause_insert_tx0),
    .pause_insert_tx1      (pause_insert_tx1),
    .pause_receive_rx      (pause_receive_rx),

    //AVMM Signals

    .avmm_address               (avmm_addr),
    .avmm_din                   (avmm_din[32-1:0]),
    .avmm_mac_tx_write          (avmm_mac_tx_write),
    .avmm_mac_rx_write          (avmm_mac_rx_write),
    .avmm_mac_tx_read           (avmm_mac_tx_read),
    .avmm_mac_rx_read           (avmm_mac_rx_read),
    .avmm_mac_tx_dout           (avmm_mac_tx_dout),
    .avmm_mac_rx_dout           (avmm_mac_rx_dout),
    .avmm_mac_tx_dval           (avmm_mac_tx_dval),
    .avmm_mac_rx_dval           (avmm_mac_rx_dval),

    .avmm_fc_tx_write          (avmm_fc_tx_write),
    .avmm_fc_tx_read           (avmm_fc_tx_read),
    .avmm_fc_tx_dout           (avmm_fc_tx_dout),
    .avmm_fc_tx_dval           (avmm_fc_tx_dval),
    .avmm_fc_rx_write          (avmm_fc_rx_write),
    .avmm_fc_rx_read           (avmm_fc_rx_read),
    .avmm_fc_rx_dout           (avmm_fc_rx_dout),
    .avmm_fc_rx_dval           (avmm_fc_rx_dval),

    .avmm_mac_tx_stats_write          (avmm_mac_tx_stats_write),
    .avmm_mac_rx_stats_write          (avmm_mac_rx_stats_write),
    .avmm_mac_tx_stats_read           (avmm_mac_tx_stats_read),
    .avmm_mac_rx_stats_read           (avmm_mac_rx_stats_read),
    .avmm_mac_tx_stats_dout           (avmm_mac_tx_stats_dout),
    .avmm_mac_rx_stats_dout           (avmm_mac_rx_stats_dout),
    .avmm_mac_tx_stats_dval           (avmm_mac_tx_stats_dval),
    .avmm_mac_rx_stats_dval           (avmm_mac_rx_stats_dval)
 );


// -------------------------------------------//
// ========== IP Reset Controller =========== //
// -------------------------------------------//

alt_e100s10_reset_controller reset_controler (
    .rst_clk                (avmm_clk),
    .rx_clk                 (rx_clk),
    .tx_clk                 (tx_clk),
    .csr_rst_in             (~csr_rst_n),   
    .xcvr_rx_dig_rst_in     (rpcs_rst_req),
    .tx_fabric_pll_locked   (fec_tx_pll_locked),
    .tx_clk_stable          (tx_clk_stable),
    .sys_rst                (eio_sys_rst),      
    .rx_rst                 (rx_rst),
    .tx_rst                 (tx_rst),
    .rx_pcs_ready_in        (rxpcs_fully_aligned_0),
    .rx_ready               (&rx_pma_ready),
    .soft_rx_rst            (soft_rx_rst),
    .soft_tx_rst            (soft_tx_rst),
    .csr_rst_out            (csr_reset),          // needs connection to MAC and RS-FEC
    .xcvr_rx_dig_rst_out    (rx_digitalreset_req),
    .native_phy_reset       (native_phy_reset),
    .xcvr_rx_sclr           (xcvr_rx_sclr),
    .rx_pcs_pll_locked      (fec_rx_pll_locked),
    .rx_pcs_sclr            (rx_pcs_sclr),
    .rx_mac_sclr            (rx_mac_sclr),
    .rx_pcs_ready_out       (rx_pcs_ready),
    .tx_lanes_stable        (tx_lanes_stable),
    .tx_pcs_sclr            (tx_pcs_sclr),
    .tx_mac_sclr            (tx_mac_sclr),
    .tx_digitalreset        (~tx_pma_ready),
    .tx_digitalreset_stat   (tx_digitalreset_stat),
    .tx_dll_lock            (tx_dll_lock),
    .tx_data_valid_core     (tpcs_dout_valid_0),
    .tx_data_valid_pma      (tx_data_valid)
);


endmodule

