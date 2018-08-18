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
module alt_e100s10_mac #(
    parameter SIM_EMULATE = 0,
    parameter SYNOPT_TXCRC_INS = 1,
    parameter SYNOPT_PREAMBLE_PASS = 0,
    parameter SYNOPT_FLOW_CONTROL = 0,
    parameter SYNOPT_NUMPRIORITY = 1,
    parameter TARGET_CHIP = 5,
    parameter SYNOPT_MAC_STATS_COUNTERS = 1,
    parameter SYNOPT_STRICT_SOP  = 0, // UNH SFD compliance feature                                
     
    parameter WORDS = 4,                   // no override
    parameter RXERRWIDTH = 6,                   // no override
    parameter TXEMPTYBITS = 6,                   // no override
    parameter RXEMPTYBITS = 6,                   // no override
    parameter SYNOPT_AVALON  = 1,
    parameter SYNOPT_ALIGN_FCSEOP = 1,
    parameter REVID = 32'h08092017,
    parameter BASE_TXMAC = 4,
    parameter BASE_RXMAC = 5,
    parameter SYNOPT_LINK_FAULT = 1,
    parameter SYNOPT_AVG_IPG = 12,
    parameter SYNOPT_MAC_DIC = 1,
    parameter SYNOPT_PTP = 0,
    parameter SYNOPT_TOD_FMT = 0,
    parameter PTP_LATENCY = 52,
    parameter PTP_FP_WIDTH = 16 // width of fingerprint, ptp parameter
    )(
    // 100G IO for the Ethernet

    // clocks and 
    input                   rx_clk, 
    input                   tx_clk,
    input                   rx_clk_locked, 
    input                   tx_clk_locked,

    // Resets 
    input                   tx_mac_sclr,
    input                   rx_mac_sclr,
    input                   reset_csr,

    // Avalon TX Interface
    input                   l8_tx_startofpacket,
    input                   l8_tx_endofpacket,
    input                   l8_tx_valid,
    output                  l8_tx_ready,
    input   [TXEMPTYBITS-1:0] l8_tx_empty,
    input   [8*64-1:0]      l8_tx_data,
    input                   l8_tx_error,
    output                  l8_txstatus_valid,
    output  [39:0]          l8_txstatus_data,
    output  [6:0]           l8_txstatus_error,

    // Avalon RX Interface
    output                  l8_rx_startofpacket,
    output                  l8_rx_endofpacket,
    output                  l8_rx_valid,
    output  [RXEMPTYBITS-1:0] l8_rx_empty,   
    output[ 8*64-1:0]       l8_rx_data,
    output                  l8_rxstatus_valid,
    output  [39:0]          l8_rxstatus_data,
    output  [5:0]           l8_rx_error,	// [5]=[0]=unused; [4]=pld_len_err; [3]=oversized; [2]=undersized; [1]=crc err;

    // AVMM Interface
    input                   avmm_clk,             // 100 MHz

    //input                 pcs_slave_din,

    // PCS input/output
    input                 pre_pcs_din_am,
    output [WORDS*64-1:0] pcs_din_d,
    output [WORDS*8-1:0]  pcs_din_c,
    input                 pcs_dout_am,
    input  [WORDS*64-1:0] pcs_dout_d,
    input  [WORDS*8-1:0]  pcs_dout_c,
    output                tx_crc_ins_en,

    // MAC RX
    output                rx_data_out_valid,
    output [WORDS*64-1:0] rx_data_out,  // read bytes left to right
    output [WORDS*8-1:0]  rx_ctl_out,   // read bits left to right
    output [WORDS-1:0]    rx_first_data,// word contains the first non-preamble data of a frame
    output [WORDS*8-1:0]  rx_last_data, // byte contains the last data before FCS
    output                rx_fcs_error,
    output                rx_fcs_valid,
    input                 rx_pcs_fully_aligned,
    output                unidirectional_en,
    output                link_fault_gen_en,
    output                remote_fault_status,
    output                local_fault_status,
    output [WORDS-1:0]    rx_mii_start,

    // Flow Control 
    input  [SYNOPT_NUMPRIORITY-1:0] pause_insert_tx0,
    input  [SYNOPT_NUMPRIORITY-1:0] pause_insert_tx1,
    output [SYNOPT_NUMPRIORITY-1:0] pause_receive_rx,

    //AVMM Signals
    input [7:0]           avmm_address,
    input  [31:0]         avmm_din,
    input                 avmm_mac_tx_write,
    input                 avmm_mac_rx_write,
    input                 avmm_fc_tx_write,
    input                 avmm_fc_rx_write,
    input                 avmm_mac_tx_read,
    input                 avmm_mac_rx_read,
    input                 avmm_fc_tx_read,
    input                 avmm_fc_rx_read,
    output wire [31:0]    avmm_mac_tx_dout,
    output wire [31:0]    avmm_mac_rx_dout,
    output wire [31:0]    avmm_fc_tx_dout,
    output wire [31:0]    avmm_fc_rx_dout,
    output wire           avmm_mac_tx_dval,
    output wire           avmm_mac_rx_dval,
    output wire           avmm_fc_tx_dval,
    output wire           avmm_fc_rx_dval,

    input                 avmm_mac_tx_stats_write,
    input                 avmm_mac_tx_stats_read,
    output wire           avmm_mac_tx_stats_dval,
    output wire [31:0]    avmm_mac_tx_stats_dout,

    input                 avmm_mac_rx_stats_write,
    input                 avmm_mac_rx_stats_read,
    output wire           avmm_mac_rx_stats_dval,
    output wire [31:0]    avmm_mac_rx_stats_dout
 );

localparam MACWORDS         = 4 ;

//----------------------
wire	[41:0]	mac_tx_stats;
wire		mac_tx_stats_valid;
wire	[2:0]	mac_tx_stats_error;		// [2]=pld_len_err; [1]=oversize; [0]=undersize;
wire	[41:0]	mac_rx_stats;
wire		mac_rx_stats_valid;

// To be updated when stats. vector feature is in
assign l8_txstatus_valid = mac_tx_stats_valid;
assign l8_txstatus_data = mac_tx_stats[39:0];
assign l8_txstatus_error = {4'b0, mac_tx_stats_error[2:1], 1'b0};	// [0]=unused; [1]=oversize; [2]=pload length err; [6:3]=unused;

// TX
wire       [WORDS-1:0]     din_sop;
wire       [WORDS-1:0]     din_eop; 
wire       [WORDS-1:0]     din_idle;
wire       [WORDS*3-1:0]   din_eop_empty;
wire       [WORDS*64-1:0]  din;
//wire                       din_req;
wire       [4:0]           din_req; // S10TIM
wire       [WORDS-1:0]     tx_error;

//RX
wire                       dout_valid;
wire       [WORDS*64-1:0]  dout_d;
wire       [WORDS*8-1:0]   dout_c;
wire       [WORDS-1:0]     dout_sop;
wire       [WORDS-1:0]     dout_eop;
wire       [WORDS*3-1:0]   dout_eop_empty;
wire       [WORDS-1:0]     dout_idle;

// Flow control
wire                             fc_sel;
wire                             fc_pfc_sel;
wire [SYNOPT_NUMPRIORITY-1:0]    fc_ena;
wire [SYNOPT_NUMPRIORITY*16-1:0] fc_pause_quanta;
wire [SYNOPT_NUMPRIORITY*16-1:0] fc_hold_quanta;
wire [SYNOPT_NUMPRIORITY-1:0]    fc_2b_req_mode_sel;
wire [SYNOPT_NUMPRIORITY-1:0]    fc_2b_req_mode_csr_req_sel;
wire [SYNOPT_NUMPRIORITY-1:0]    fc_req0;
wire [SYNOPT_NUMPRIORITY-1:0]    fc_req1;
wire [47:0]                      fc_dest_addr;
wire [47:0]                      fc_src_addr;
wire                             fc_tx_off_en;
wire [SYNOPT_NUMPRIORITY-1:0]    fc_rx_pfc_en;
wire [47:0]                      fc_rx_dest_addr;


// Adapter

 // _____________________________________________________________________________      
//      8word to 4word adapter interfacing the custom-st and 
//      the avalon-st interfaces on the two sides of this module
 // _____________________________________________________________________________      


wire [6-1:0]     mac_rx_error;

wire [MACWORDS-1:0]       rsk_out_tx4l_idle_1,rsk_out_tx4l_idle_2;// bytes between EOP and SOP
wire [MACWORDS-1:0]       rsk_out_tx4l_idle_1_inv, rsk_out_tx4l_idle_2_inv;
wire [MACWORDS-1:0]       rsk_out_tx4l_sop_1,rsk_out_tx4l_sop_2; // word contains first data (on leftmost byte)
wire [MACWORDS-1:0]       rsk_out_tx4l_eop_1,rsk_out_tx4l_eop_2; // byte position of last data
wire [MACWORDS-1:0]       rsk_out_tx4l_error_1,rsk_out_tx4l_error_2; 
wire [MACWORDS*64-1:0]    rsk_out_tx4l_data_1,rsk_out_tx4l_data_2;  // data, read left to right
wire [MACWORDS*03-1:0]    rsk_out_tx4l_eop_empty_1,rsk_out_tx4l_eop_empty_2;     // byte position of last data

//wire  rsk_out_tx4l_req_1,rsk_out_tx4l_req_2;
wire  rsk_out_tx4l_req_1;
wire  [4:0] rsk_out_tx4l_req_2; // S10TIM
wire [MACWORDS-1:0]       adp_out_tx4l_sop; // word contains first data (on leftmost byte)
wire [MACWORDS-1:0]       adp_out_tx4l_eop; // byte position of last data
wire [MACWORDS-1:0]       adp_out_tx4l_error;    
wire [MACWORDS-1:0]       adp_out_tx4l_idle;// bytes between EOP and SOP
wire [MACWORDS*64-1:0]    adp_out_tx4l_data;// data, read left to right
wire [MACWORDS*03-1:0]    adp_out_tx4l_eop_empty;        // byte position of last data

wire tx_fc_ready;
wire tx_fc_sop;
wire tx_fc_eop;
wire [8*64-1:0] tx_fc_data;
wire [TXEMPTYBITS-1:0] tx_fc_eop_empty;
wire tx_fc_error;

  reg [1:0] tx_mac_sclr_r0;
  always @(posedge tx_clk) tx_mac_sclr_r0 <= {2{tx_mac_sclr}};

  reg [1:0] rx_mac_sclr_r0;
  always @(posedge rx_clk) rx_mac_sclr_r0 <= {2{rx_mac_sclr}};

genvar i;

generate
if (SYNOPT_AVALON) begin
  localparam ASKWIDTH = MACWORDS*(1+1+1+1+64+3);

// S10TIM: separate for fanout
  reg [1:0] tx_mac_sclr_r2;
  always @(posedge tx_clk) tx_mac_sclr_r2 <= tx_mac_sclr_r0;

  localparam MISCWIDTH = MACWORDS*(1+1+1+1+3);
  alt_e100s10_ack_skid_srst #(.WIDTH(MISCWIDTH))
  ask10 (
      .clk(tx_clk),
      .srst(tx_mac_sclr_r2[0]),
      .ack_i(rsk_out_tx4l_req_2[0]),       
      .dat_i({~rsk_out_tx4l_idle_2, rsk_out_tx4l_eop_2, rsk_out_tx4l_error_2, rsk_out_tx4l_eop_empty_2, rsk_out_tx4l_sop_2}),
      
      .ack_o(din_req[0]), 
      .dat_o({rsk_out_tx4l_idle_1_inv, rsk_out_tx4l_eop_1, rsk_out_tx4l_error_1, rsk_out_tx4l_eop_empty_1, rsk_out_tx4l_sop_1})
      );
      assign rsk_out_tx4l_idle_1 = ~rsk_out_tx4l_idle_1_inv;

      for (i=0; i<MACWORDS; i=i+1) begin : skid1_loop
        alt_e100s10_ack_skid #(.WIDTH(64))
            ask11 (
                    .clk(tx_clk),
                    .ack_i(rsk_out_tx4l_req_2[i+1]),       
                    .dat_i(rsk_out_tx4l_data_2[(i+1)*64-1:i*64]),
      
                    .ack_o(din_req[i+1]), 
                    .dat_o(rsk_out_tx4l_data_1[(i+1)*64-1:i*64])
        );
  end

/////////////////////////////////////////////////////////

// S10TIM: separate for fanout
  alt_e100s10_ack_skid_srst #(.WIDTH(MISCWIDTH))
  ask20 (
      .clk(tx_clk),
      .srst(tx_mac_sclr_r2[1]),
      .ack_i(rsk_out_tx4l_req_1),       
      .dat_i({~adp_out_tx4l_idle, adp_out_tx4l_eop, adp_out_tx4l_error, adp_out_tx4l_eop_empty, adp_out_tx4l_sop}),
      
      .ack_o(rsk_out_tx4l_req_2[0]), 
      .dat_o({rsk_out_tx4l_idle_2_inv, rsk_out_tx4l_eop_2, rsk_out_tx4l_error_2, rsk_out_tx4l_eop_empty_2, rsk_out_tx4l_sop_2})
      );
      assign rsk_out_tx4l_idle_2 = ~rsk_out_tx4l_idle_2_inv;

      for (i=0; i<MACWORDS; i=i+1) begin : skid2_loop
        alt_e100s10_ack_skid #(.WIDTH(64))
            ask21 (
                    .clk(tx_clk),
                    .ack_i(),       
                    .dat_i(adp_out_tx4l_data[(i+1)*64-1:i*64]),
      
                    .ack_o(rsk_out_tx4l_req_2[i+1]), 
                    .dat_o(rsk_out_tx4l_data_2[(i+1)*64-1:i*64])
        );
  end

/////////////////////////////////////////////////////////

alt_e100s10_adapter_4 ast_8w (
        .l8_tx_ready            (tx_fc_ready), //(l8_tx_ready),
        .l8_tx_valid            (1'b1), // (l8_tx_valid),
        .l8_tx_startofpacket    (tx_fc_sop), //(l8_tx_startofpacket),
        .l8_tx_endofpacket      (tx_fc_eop), //(l8_tx_endofpacket),
        .l8_tx_data             (tx_fc_data), //(l8_tx_data),
        .l8_tx_empty            (tx_fc_eop_empty), //(l8_tx_empty),
        .l8_tx_error            (tx_fc_error), //(l8_tx_error),

        .l8_rx_valid            (l8_rx_valid),
        .l8_rx_startofpacket    (l8_rx_startofpacket),
        .l8_rx_endofpacket      (l8_rx_endofpacket),
        .l8_rx_data             (l8_rx_data),
        .l8_rx_empty            (l8_rx_empty),
        .l8_rx_error            (l8_rx_error),
        .l8_rx_status           (l8_rxstatus_data),             // TBD
        .l8_rx_fcs_valid        (l8_rxstatus_valid),             // Remove
        .l8_rx_fcs_error        (),             // not to be used

        .clk_txmac              (tx_clk),
        .tx_srst                (tx_mac_sclr_r0[0]),   //Alvin modified
        .tx4l_ack               (rsk_out_tx4l_req_1),   // rsk backpressure
        .tx4l_idle              (adp_out_tx4l_idle),
        .tx4l_sop               (adp_out_tx4l_sop),
        .tx4l_eop               (adp_out_tx4l_eop),
        .tx4l_d                 (adp_out_tx4l_data),
        .tx4l_eop_empty         (adp_out_tx4l_eop_empty),
        .tx4l_error             (adp_out_tx4l_error),
        
        .clk_rxmac              (rx_clk),          // MAC + PCS clock 
        .rx_srst                (rx_mac_sclr_r0[0]), //Check
        .rx4l_d                 (dout_d),           // 4 lane payload to send
        .rx4l_sop               (dout_sop),         // 4 lane st output                clk_tx_main, //wire?
        .rx4l_idle              (dout_idle),        // 4 lane idle position
        .rx4l_eop               (dout_eop),         // 4 lane end position any byte
        .rx4l_error             (mac_rx_error),         // 
        .rx4l_status            (mac_rx_stats[39:0]),        
        .rx4l_fcs_valid         (mac_rx_stats_valid),	//(rx_fcs_valid),         // Remove?
        .rx4l_valid             (dout_valid),       // 
        .rx4l_eop_empty         (dout_eop_empty)    // 4 lane # of empty bytes
  );
  defparam ast_8w.TARGET_CHIP = TARGET_CHIP;
  defparam ast_8w.SYNOPT_ALIGN_FCSEOP = SYNOPT_ALIGN_FCSEOP;
  defparam ast_8w.RXERRWIDTH = RXERRWIDTH;	//RXERRWIDTH;
  defparam ast_8w.RXSTATUSWIDTH = 40;	//RXSTATUSWIDTH;

end

assign din_sop           = rsk_out_tx4l_sop_1;
assign din_eop           = rsk_out_tx4l_eop_1;
assign din_idle          = rsk_out_tx4l_idle_1;
assign din_eop_empty     = rsk_out_tx4l_eop_empty_1;
assign din               = rsk_out_tx4l_data_1;
assign tx_error          = rsk_out_tx4l_error_1;

endgenerate

// ------------------------------------------------------------------------------------//

//MAC


// switch from PCS  (read bytes right to left) to MAC  (read left to right)
wire [WORDS*64-1:0] pcs_dout_d_rev;
wire [WORDS*8-1:0] pcs_dout_c_rev;
    
reverse_bytes rb0 (.din(pcs_dout_d),.dout(pcs_dout_d_rev));
defparam rb0 .NUM_BYTES = WORDS*8;

reverse_bits rb1 (.din(pcs_dout_c),.dout(pcs_dout_c_rev));
defparam rb1 .WIDTH = WORDS*8;


reg [9:0] rx_mii_in_valid /* synthesis preserve_syn_only */;
reg [64*WORDS-1:0] rx_mii_data_in;
reg [8*WORDS-1:0] rx_mii_ctl_in;

always @(posedge rx_clk) begin
    rx_mii_in_valid <= {10{!pcs_dout_am}};
    rx_mii_data_in <= pcs_dout_d_rev;
    rx_mii_ctl_in <= pcs_dout_c_rev;
end

alt_e100s10_mac_rx_4 #(
    .SIM_EMULATE           (SIM_EMULATE),
    .TARGET_CHIP           (TARGET_CHIP),
    .BASE_RXMAC            (BASE_RXMAC),
    .REVID                 (REVID),
    .SYNOPT_PREAMBLE_PASS  (SYNOPT_PREAMBLE_PASS),
    .SYNOPT_STRICT_SOP     (SYNOPT_STRICT_SOP)
) erx (
    .clk(rx_clk),
    .reset_rx                       (rx_mac_sclr_r0[1]), //Alvin modified
    .reset_csr                      (reset_csr), // global reset, async
    .clk_csr                        (avmm_clk),
    .read                           (avmm_mac_rx_read),
    .write                          (avmm_mac_rx_write),
    .address                        (avmm_address[7:0]),
    .writedata                      (avmm_din),
    .readdata                       (avmm_mac_rx_dout),
    .readdatavalid                  (avmm_mac_rx_dval),

    // raw CGMII stream in
    .mii_in_valid                   (rx_mii_in_valid), // S10TIM Ok 
    .mii_data_in                    (rx_mii_data_in), // read bytes left to right S10TIM : Ok
    .mii_ctl_in                     (rx_mii_ctl_in),  // read bits left to right S10TIM: Ok
    .rx_pcs_fully_aligned           (rx_pcs_fully_aligned),

    // annotated output
    .out_valid                      (rx_data_out_valid),
    .data_out                       (rx_data_out),       // read bytes left to right
    .ctl_out                        (rx_ctl_out),         // read bits left to right
    .first_data                     (rx_first_data),   // word contains the first non-preamble data of a frame
    .last_data                      (rx_last_data),     // byte contains the last data before FCS

    // lagged (N) cycles from the non-zero last_data output

    .rx_fcs_error                   (rx_fcs_error),     // referring to the non-zero last_data
    .rx_fcs_valid                   (rx_fcs_valid),
    .remote_fault_status            (remote_fault_status),
    .local_fault_status             (local_fault_status),
    .dout_valid                     (dout_valid),
    .dout_d                         (dout_d),
    .dout_c                         (dout_c),
    .dout_sop                       (dout_sop),
    .dout_eop                       (dout_eop),
    .dout_eop_empty                 (dout_eop_empty),
    .dout_idle                      (dout_idle),
    .rx_mii_start                   (rx_mii_start),

    .rx_crc_pt                      (rx_crc_pt),
    .rx_error                   (mac_rx_error),
    .rx_stats			(mac_rx_stats),
    .rx_stats_valid		(mac_rx_stats_valid)
);
defparam erx .TARGET_CHIP = TARGET_CHIP;
defparam erx .EN_LINK_FAULT = SYNOPT_LINK_FAULT;
defparam erx .SYNOPT_ALIGN_FCSEOP = SYNOPT_ALIGN_FCSEOP;


// switch from MAC  (read left to right) to PCS (read bytes right to left)
wire [WORDS*64-1:0] pcs_din_d_rev;
wire [WORDS*8-1:0] pcs_din_c_rev;

reverse_bytes rb2 (.din(pcs_din_d_rev),.dout(pcs_din_d));
defparam rb2 .NUM_BYTES = WORDS*8;

reverse_bits rb3 (.din(pcs_din_c_rev),.dout(pcs_din_c));
defparam rb3 .WIDTH = WORDS*8;

alt_e100s10_mac_tx_4 #(
    .SIM_EMULATE           (SIM_EMULATE),
    .TARGET_CHIP           (TARGET_CHIP),
    .BASE_TXMAC            (BASE_TXMAC),
    .REVID                 (REVID),
    .SYNOPT_AVG_IPG        (SYNOPT_AVG_IPG)
) txm (
    .sclr                  (tx_mac_sclr_r0[1]), //Alvin modified
    .clk                   (tx_clk),
    .reset_csr             (reset_csr), 
    .clk_csr                (avmm_clk),
    .read                   (avmm_mac_tx_read),
    .write                  (avmm_mac_tx_write),
    .address                (avmm_address[7:0]),
    .writedata              (avmm_din),
    .readdata               (avmm_mac_tx_dout),
    .readdatavalid          (avmm_mac_tx_dval),
    .din_sop                (din_sop),             // word contains first data (on leftmost byte)
    .din_eop                (din_eop),                 // byte position of last data
    .din_idle               (din_idle),           // bytes between EOP and SOP
    .din_eop_empty          (din_eop_empty), // byte position of last data
    .din                    (din),                     // data, read left to right
    .tx_error               (tx_error),
    .req                    (din_req), 
    .pre_din_am             (pre_pcs_din_am),
    .tx_crc_ins_en          (tx_crc_ins_en), 
    .tod_96b_txmac_in       (96'b0),
    .tod_64b_txmac_in       (64'b0),
    .txmclk_period          (20'b0),
    .tx_asym_delay          (19'b0),
    .tx_pma_delay           (32'b0),
    .cust_mode              (1'b0),
    .ext_lat                (32'b0), 
    .din_ptp_dbg_adp        (1'b0),
    .din_sop_adp            (1'b0),
    .din_ptp_asm_adp        (1'b0),
    .ts_out_cust_asm        (), // output
    .tod_cust_in            (96'b0), // 
    .tod_exit_cust          (), // output
    .ts_out_cust            (), // output

    .ts_out_req_adp         (1'b0),
    .ing_ts_96_adp          (96'b0),
    .ing_ts_64_adp          (64'b0),
    .ins_ts_adp             (1'b0),
    .ins_ts_format_adp      (1'b0),
    .tx_asym_adp            (1'b0),
    .upd_corr_adp           (1'b0),
    .chk_sum_zero_adp       (1'b0),    
    .chk_sum_upd_adp        (1'b0),
    .corr_format_adp        (1'b0),
    .ts_offset_adp          (16'b0),
    .corr_offset_adp        (16'b0),
    .chk_sum_zero_offset_adp(16'b0),
    .chk_sum_upd_offset_adp (16'b0),
    .ts_exit                (), // output
    .ts_exit_valid          (), // output
    .fp_out                 (), // output

    .tx_mii_d               (pcs_din_d_rev),
    .tx_mii_c               (pcs_din_c_rev),
    .tx_mii_valid           (),     // adubey 09.04.2013 warning clean-up
    .o_bus_error            (), // output
    .cfg_unidirectional_en  (unidirectional_en),
    .cfg_en_link_fault_gen  (link_fault_gen_en),
    .remote_fault_status    (remote_fault_status),
    .local_fault_status     (local_fault_status),

    .tx_stats			(mac_tx_stats),
    .tx_stats_valid		(mac_tx_stats_valid),
    .tx_stats_error		(mac_tx_stats_error)
);
defparam txm .TARGET_CHIP = TARGET_CHIP;
defparam txm .EN_PREAMBLE_PASS_THROUGH = SYNOPT_PREAMBLE_PASS;
defparam txm .EN_TX_CRC_INS = SYNOPT_TXCRC_INS;
defparam txm .EN_DIC = SYNOPT_MAC_DIC;
defparam txm .SYNOPT_PTP = SYNOPT_PTP;
defparam txm .SYNOPT_TOD_FMT = SYNOPT_TOD_FMT;
defparam txm .PTP_LATENCY = PTP_LATENCY;
defparam txm .PTP_FP_WIDTH = PTP_FP_WIDTH;
defparam txm .EN_LINK_FAULT = SYNOPT_LINK_FAULT;

//-------------------------------------------
//---status counters---
//-------------------------------------------
generate
  if (SYNOPT_MAC_STATS_COUNTERS) begin: u_stats_counters
	alt_e100s10_stats_counters #(
			.WIDTH          (64),
			.SIM_EMULATE    (SIM_EMULATE)
			) 
	   u_tx_stats_counters (
		.aclr                (reset_csr),
		.stats_clk           (avmm_clk),  // 100 MHz status clk
		.addr                (avmm_address[7:0]),
		.write               (avmm_mac_tx_stats_write),
		.writedata           (avmm_din),
		.read                (avmm_mac_tx_stats_read),
		.data_valid          (avmm_mac_tx_stats_dval),
		.readdata            (avmm_mac_tx_stats_dout),
 
		.mac_clk             (tx_clk),
		.mac_clk_locked      (tx_clk_locked),
		.crc_error           (1'b0),
		.undersized_frame    (1'b0),
		.oversized_frame_in  (mac_tx_stats_error[1]),
		.payload_len_error   (mac_tx_stats_error[2]),
		.valid_in            (mac_tx_stats_valid),
		.status_data_vector  (mac_tx_stats)
	);
 
	alt_e100s10_stats_counters #(
			.WIDTH          (64),
			.SIM_EMULATE    (SIM_EMULATE)
			)
	   u_rx_stats_counters (
		.aclr                (reset_csr),
		.stats_clk           (avmm_clk),  // 100 MHz status clk
		.addr                (avmm_address[7:0]),
		.write               (avmm_mac_rx_stats_write),
		.writedata           (avmm_din),
		.read                (avmm_mac_rx_stats_read),
		.data_valid          (avmm_mac_rx_stats_dval),
		.readdata            (avmm_mac_rx_stats_dout),

		.mac_clk             (rx_clk),
		.mac_clk_locked      (rx_clk_locked),
		.crc_error           (mac_rx_error[1]),	// TBD
		.undersized_frame    (mac_rx_error[2]),
		.oversized_frame_in  (mac_rx_error[3]),
		.payload_len_error   (mac_rx_error[4]),
		.valid_in            (mac_rx_stats_valid),
		.status_data_vector  (mac_rx_stats)
	);
  end else begin
	reg     stats_tx_valid, stats_rx_valid;
	always @ (posedge avmm_clk) begin
		stats_tx_valid <= avmm_mac_tx_stats_read;
		stats_rx_valid <= avmm_mac_rx_stats_read;
	end
	assign avmm_mac_tx_stats_dout   = 32'hdeadc0de;
	assign avmm_mac_rx_stats_dout   = 32'hdeadc0de;
	assign avmm_mac_tx_stats_dval   = stats_tx_valid;
	assign avmm_mac_rx_stats_dval   = stats_rx_valid;
  end
endgenerate


//FC Top
generate
        if (SYNOPT_FLOW_CONTROL) begin: fc_enable
            alt_e100s10_fc_top #(
                .PREAMBLE_PASS        (SYNOPT_PREAMBLE_PASS),
                .NUMPRIORITY          (SYNOPT_NUMPRIORITY),
                .ALLOCATE_4B_CRC      (0),
                .WORDS                (4),
                .WIDTH                (64),
                .TXEMPTYBITS          (TXEMPTYBITS),
                .RXEMPTYBITS          (RXEMPTYBITS),
                .RXERRWIDTH           (RXERRWIDTH)
            ) fc (
                // Clock & Reset
                .clk_tx                (tx_clk),
                .clk_rx                (rx_clk),
                .reset_tx_n            (~tx_mac_sclr),
                .reset_rx_n            (~rx_mac_sclr),

                // Input from CSR
                .cfg_enable            (fc_ena), 
                .cfg_pfc_sel           (fc_pfc_sel), 
                .cfg_pause_quanta      (fc_pause_quanta),
                .cfg_holdoff_quanta    (fc_hold_quanta),
                .cfg_2b_req_mode_sel   (fc_2b_req_mode_sel),
                .cfg_2b_req_mode_csr_req_sel(fc_2b_req_mode_csr_req_sel),
                .cfg_pause_req0        (fc_req0),
                .cfg_pause_req1        (fc_req1),
                .cfg_tx_saddr          (fc_src_addr),
                .cfg_tx_daddr          (fc_dest_addr),
                .cfg_rx_daddr          (fc_rx_dest_addr),
                .cfg_tx_off_en         (fc_tx_off_en),
                .cfg_rx_pfc_en         (fc_rx_pfc_en),
                .cfg_rx_crc_pt         (rx_crc_pt),

                .tx_in_ready           (l8_tx_ready), //(tx_adapter_ready),
                .tx_in_sop             (l8_tx_startofpacket && l8_tx_valid), //(tx_adapter_sop),
                .tx_in_eop             (l8_tx_endofpacket && l8_tx_valid), ////(tx_adapter_eop),
                .tx_in_error           (l8_tx_error), //(tx_adapter_error), // ???
                .tx_in_data            (l8_tx_data), //(tx_adapter_data),
                .tx_in_empty           (l8_tx_empty), //(tx_adapter_eop_empty),

                // to adapter
                .tx_out_ready          (tx_fc_ready),
                .tx_out_sop            (tx_fc_sop),
                .tx_out_eop            (tx_fc_eop),
                .tx_out_error          (tx_fc_error),
                .tx_out_data           (tx_fc_data),
                .tx_out_empty          (tx_fc_eop_empty),
                .tx_out_pfc_frame      (),
                .fc_sel                (fc_sel),

                .rx_data_valid         (1'b1),
                .tx_data_valid         (1'b1),

                .pause_insert_tx0      (pause_insert_tx0),
                .pause_insert_tx1      (pause_insert_tx1),
                .pause_receive_rx      (pause_receive_rx),

                .tx_xoff               (),
                .tx_xon                (),

                .rx_in_data            (l8_rx_data),
                .rx_in_sop             (l8_rx_startofpacket),
                .rx_in_eop             (l8_rx_endofpacket),
                .rx_in_valid           (l8_rx_valid),
                .rx_in_empty           (l8_rx_empty),
                .rx_in_error           (l8_rx_error)
            );
        end else begin

            assign tx_fc_sop = l8_tx_startofpacket && l8_tx_valid;
            assign tx_fc_eop = l8_tx_endofpacket && l8_tx_valid;
            assign tx_fc_data = l8_tx_data;
            assign tx_fc_eop_empty = l8_tx_empty;
            assign tx_fc_error = l8_tx_error;
            assign l8_tx_ready = tx_fc_ready;
            assign pause_receive_rx = 0;
            assign fc_sel = 1'b0;
        end
    endgenerate
//------------------------------------------------------------------//

alt_e100s10_fc_csr  #(
    .SIM_EMULATE        (SIM_EMULATE), 
    .SYNOPT_FLOW_CONTROL(SYNOPT_FLOW_CONTROL), 
    .SYNOPT_NUMPRIORITY (SYNOPT_NUMPRIORITY)
) fc_csr(
    .csr_clk        (avmm_clk),
    .rx_clk         (rx_clk),
    .tx_clk         (tx_clk),

    .reset          (reset_csr),
    .write_tx_fc    (avmm_fc_tx_write),
    .write_rx_fc    (avmm_fc_rx_write),
    .read_tx_fc     (avmm_fc_tx_read),
    .read_rx_fc     (avmm_fc_rx_read),
    .address        (avmm_address[7:0]),
    .data_in        (avmm_din),
    .data_out_tx_fc (avmm_fc_tx_dout),
    .data_out_rx_fc (avmm_fc_rx_dout),
    .data_valid_tx_fc (avmm_fc_tx_dval),
    .data_valid_rx_fc (avmm_fc_rx_dval),

    //Flow Control
    .fc_pfc_sel(fc_pfc_sel),                           
    .fc_ena_csr(fc_ena),                              
    .fc_pause_quanta_csr(fc_pause_quanta),           
    .fc_hold_quanta_csr(fc_hold_quanta),            
    .fc_2b_req_mode_sel_csr(fc_2b_req_mode_sel),    
    .fc_2b_req_mode_csr_req_sel_csr(fc_2b_req_mode_csr_req_sel),
    .fc_req0_csr(fc_req0),                    
    .fc_req1_csr(fc_req1),                   
    .fc_rx_pfc_en_csr(fc_rx_pfc_en),        
    .fc_dest_addr(fc_dest_addr),           
    .fc_src_addr(fc_src_addr),            
    .fc_tx_off_en(fc_tx_off_en),         
    .fc_rx_dest_addr(fc_rx_dest_addr)   


);
endmodule

