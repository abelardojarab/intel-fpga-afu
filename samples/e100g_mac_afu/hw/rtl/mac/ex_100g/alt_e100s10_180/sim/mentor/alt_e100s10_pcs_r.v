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


// S10 100G Slim Width RX-PCS
// Faisal Khan (04/2017)

// +------+    +------+      +------+       +------+       +------+                     +------+     +------+    +------+
// | Hard |66  | Deint| 5x14 |5-way |  5x14 |5-way |  5x14 |      |       +------+      |       |    |      |    | DEC  |->c,d
// |  PCS | -->|      |----> | WA   | ----> | Shift| ----> | CLOS |  5x14 |Reframe|     |       |--> | De-  |--> |      |
// +------+    +------+      +------+       +------+       | N/W  | ----> |   &   | --> |Deskew |    |Scram |    +------+
//                                                   ----> |      |       |  Tag  |     |   &   |    |      |
// -->     ......................................          |      |       +-------+ --> | Output|    |      |-->     
// -->     ......................................    ----> |      |                 --> |  Word |    |      |--> 
// -->     ......................................          |      |                 --> | Sqncr |    |      |--> 
//                                                   ----> +------+                     +------+     +------+
`timescale 1 ps / 1 ps

module alt_e100s10_pcs_r   #(
    parameter SIM_SHORT_AM      = 1'b0, // shorter aligment spacing, to RX lock faster
    parameter SIM_EMULATE       = 1'b0,
    parameter SYNOPT_LINK_FAULT = 1'b0,
    parameter SYNOPT_C4_RSFEC   = 1'b0,
    parameter ENABLE_ANLT       = 1'b0
)( 
    // clocks and resets
    input                   clk,    // pragma clock_port
    input                   reset,  // synchronous reset
    input                   xcvr_sclr,              // not used for now
    output                  rx_pcs_rst_req,
    
    // PMA interface
    input   [4*66-1:0]      din,
    input                   din_valid,  // should always be valid in normal PCS - toggles for AM in RS-FEC mode
    output                  din_req,    // unused for now

    // status
    output                  deskew_locked,
    output                  align_locked,
    output  [19:0]          lanes_word_locked,
    output                  word_locked,
    output                  lanes_ordered,
    output  [20*5-1:0]      dout_tags,              // VL - Physical channel mapping
    output  [19:0]          dout_stky_frm_err,
    output                  hi_ber,                 // functionality not yet implemented
    input		    rfec_align_locked,
    input		    rfec_slip_rst_req,
    input                   enable_rsfec,
    // control from CSR
    input                   purge_fifo,
    input                   frm_err_clr,

    // output to MAC
    output  [4*64-1:0]      dout_d,
    output  [4*8-1:0]       dout_c,
    output                  dout_am

);

reg     [2:0]           reset_1 ;
generate
if (SIM_EMULATE == 1'b1) begin : RI
    initial begin   reset_1 = 3'h0; end
end
endgenerate
genvar i;
wire    [66*4-1:0]  dout_dsk;
wire                align_dsk;
generate
	
if (SYNOPT_C4_RSFEC == 0 || (SYNOPT_C4_RSFEC == 1 && ENABLE_ANLT == 0)) begin : PCS

  wire    [66*4-1:0]  dout_dsk_pcs;
  wire                align_dsk_pcs;



wire    [5*14*4-1:0]    dinv_d, wali_d, shft_d;
wire    [3:0]           dinv_v, wali_v,  wali_ready;
wire    [5*4-1:0]       dinv_hv, wali_hv;
wire    [3*4-1:0]       schd; 
wire    [3:0]           wlock;
wire                    sticky_err_clr;
wire    [19:0]          sticky_err;
wire    [19:0]          locked_lanes;
wire    [3:0]           purge_align;
//wire                    reset_shft;

  always @(posedge clk) begin
    reset_1 <= {3{reset}};
  end

  assign  sticky_err_clr = frm_err_clr;

  for (i=0; i<4; i=i+1) begin : pipe
    
    // de-interleaver
    alt_e100s10_deint deint (
        .clk            (clk),  
        .din            (din[i*66+:66]),
        .reset          (reset_1[0]),
        .din_valid      (din_valid),
        .dout           (dinv_d[5*14*i+:5*14]),
        .dout_valid     (dinv_v[i]),
        .dout_hv        (dinv_hv[5*i+:5]),
        .schd           (schd[3*i+:3])          
    );

    // word locker
    alt_e100s10_walign wa (
        .clk            (clk),
        .reset          (reset_1[1]),
        .schd           (schd[3*i+:3]),
        .din            (dinv_d[5*14*i+:5*14]),
        .din_hv         (dinv_hv[5*i+:5]),
        .din_valid      (dinv_v[i]),

        .sticky_err_clr (sticky_err_clr),
        .lock           (wlock[i]),
        .locked_lanes   (locked_lanes[5*i+:5]),
        .sticky_err     (sticky_err[5*i+:5]),
        .dout           (wali_d[14*5*i+:14*5]),
        .dout_hv        (wali_hv[5*i+:5]),              
        .dout_valid     (wali_v[i]),                
        .ready          (wali_ready[i]),
        .purge_align    (purge_align[i])
    );
    defparam    wa .SIM_EMULATE = SIM_EMULATE;


    // shift register
    alt_e100s10_shft   shft (
        .clk            (clk),
        .din            (wali_d[14*5*i+:14*5]),
        .din_hv         (wali_hv[5*i+:5]),
        .dout           (shft_d[14*5*i+:14*5]),
        .phase          (dinv_hv[5*i+:5])       
    );

end

wire [19:0] lanes_word_locked_pcs;
wire [19:0] dout_stky_frm_err_pcs;

assign  dout_stky_frm_err_pcs = sticky_err;
assign  lanes_word_locked_pcs = locked_lanes ;
// Clos network 
wire    [20*14-1:0] clos_out;
wire    [139:0]     clos_sel;

// can replace 5x1 mux with one stage mux. Will need to change the addressing in xctrl
alt_e100s10_clos20 clos (
    .clk        (clk),
    .sels       (clos_sel),         // from the controller
    .din        (shft_d),
    .dout       (clos_out)
);
defparam    clos .WIDTH = 14;

// checking of the alignment markers - converting back to 66-bits
wire    [66*20-1:0] dout_rf, data_dk;
wire    [19:0]      phase_rfrm;


// checking of the markers

wire    [19:0]      etag_am, etag_am_dsk;
wire    [5*20-1:0]  etag_tnum;
wire    [19:0]      etag_opp;

for (i=0; i<20; i=i+1) begin : etag

    alt_e100s10_reframe   refrm (
        .clk        (clk),
        .din        (clos_out[14*i+:14]),
        .phase      (phase_rfrm[i]),
        .dout       (dout_rf[66*i+:66]),
        .dout_sk    (data_dk[66*i+:66])
    );

    alt_e100s10_etagid tag (
        .clk        (clk),
        .din        (dout_rf[66*i+:66]),
        .dout_opp   (etag_opp[i]),
        .am         (etag_am[i]),
        .am_dsk     (etag_am_dsk[i]),
        .dout_tnum  (etag_tnum[5*i+:5])
    );
    defparam    tag .SIM_EMULATE = SIM_EMULATE;
    defparam    tag .TAGID = i;
end

// deskew, align &  4-word mapper
wire                reset_dsk, purge_deskew;
wire    [2:0]       phase_dsk;
wire                valid_dsk = ~reset_dsk;
wire                predicted_align;
wire                align_locked_pcs;
wire                deskew_locked_pcs;

alt_e100s10_deskew desk (

    .clk                (clk),
    .reset              (reset_dsk),
    .din                (data_dk),
    .in_phase           (phase_dsk),
    .in_valid           (valid_dsk),         // coming from controller
    .am                 (etag_am_dsk),
    .dout               (dout_dsk_pcs),
    .predicted_align    (predicted_align),
    .deskew_locked      (deskew_locked_pcs),
    .align_locked       (align_locked_pcs),
    .align_out          (align_dsk_pcs),
    .purge              (purge_deskew)

);
defparam    desk .SIM_EMULATE = SIM_EMULATE;
defparam    desk .SIM_SHORT_AM = SIM_SHORT_AM;


// PCS Controller. Also encapsulates Clos-N/W Control
wire word_locked_pcs;
wire lanes_ordered_pcs;
wire rx_pcs_rst_req_pcs;
wire [99:0] dout_tags_pcs;

alt_e100s10_pctrl pctrl (
    .clk                (clk),
    .reset              (reset_1[2]),
    .walign_lock        (wlock),
    .word_locked        (word_locked_pcs),     // output
    .lanes_ordered      (lanes_ordered_pcs),
    .deskew_locked      (deskew_locked_pcs),
    .align_locked       (align_locked_pcs),
    .purge_align        (purge_align),     
    .purge_deskew       (purge_deskew),
    .predicted_align    (predicted_align),

    .etag_am            (etag_am),
    .etag_opp           (etag_opp),
    .etag_tnum          (etag_tnum),
    .dout_tags          (dout_tags_pcs),

    .phase_align_in     (dinv_hv[4]),     // input
    .phase_rfrm         (phase_rfrm),
    .clos_sel           (clos_sel),
    .phase_dsk          (phase_dsk),
    .reset_dsk          (reset_dsk),

    .purge_req          (rx_pcs_rst_req_pcs)



);
defparam    pctrl .SIM_EMULATE = SIM_EMULATE;

  /*
  assign align_dsk         = align_dsk_pcs;
  assign dout_dsk          = dout_dsk_pcs; 
  assign align_locked      = align_locked_pcs;
  assign deskew_locked     = deskew_locked_pcs;
  assign word_locked       = word_locked_pcs;
  assign lanes_ordered     = lanes_ordered_pcs;
  assign rx_pcs_rst_req    = rx_pcs_rst_req_pcs;
  assign din_req           = 1'b0;
  assign lanes_word_locked = lanes_word_locked_pcs;
  assign dout_tags         = dout_tags_pcs;
  assign dout_stky_frm_err = dout_stky_frm_err_pcs;
  */
  if (ENABLE_ANLT==0 && SYNOPT_C4_RSFEC == 1 ) begin
    assign align_dsk         = (enable_rsfec == 1) ? ~din_valid        : align_dsk_pcs;
    assign dout_dsk          = (enable_rsfec == 1) ? din               : dout_dsk_pcs; 
    assign align_locked      = (enable_rsfec == 1) ? rfec_align_locked : align_locked_pcs;
    assign deskew_locked     = (enable_rsfec == 1) ? rfec_align_locked : deskew_locked_pcs;
    assign word_locked       = (enable_rsfec == 1) ? rfec_align_locked : word_locked_pcs;
    assign lanes_ordered     = (enable_rsfec == 1) ? rfec_align_locked : lanes_ordered_pcs;
    assign rx_pcs_rst_req    = (enable_rsfec == 1) ? rfec_slip_rst_req : rx_pcs_rst_req_pcs;
    assign din_req           = 1'b0;
    assign lanes_word_locked = (enable_rsfec == 1) ? 20'h0             : lanes_word_locked_pcs;
    assign dout_tags         = (enable_rsfec == 1) ? 100'h0            : dout_tags_pcs;
    assign dout_stky_frm_err = (enable_rsfec == 1) ? 20'b0             : dout_stky_frm_err_pcs;
  end else if (SYNOPT_C4_RSFEC == 0)begin
  	assign align_dsk         = align_dsk_pcs;
    assign dout_dsk          = dout_dsk_pcs; 
    assign align_locked      = align_locked_pcs;
    assign deskew_locked     = deskew_locked_pcs;
    assign word_locked       = word_locked_pcs;
    assign lanes_ordered     = lanes_ordered_pcs;
    assign rx_pcs_rst_req    = rx_pcs_rst_req_pcs;
    assign din_req           = 1'b0;
    assign lanes_word_locked = lanes_word_locked_pcs;
    assign dout_tags         = dout_tags_pcs;
    assign dout_stky_frm_err = dout_stky_frm_err_pcs;
  end else begin
  	assign align_dsk         = ~din_valid;
    assign dout_dsk          = din; 
    assign align_locked      = rfec_align_locked;
    assign deskew_locked     = rfec_align_locked;
    assign word_locked       = rfec_align_locked;
    assign lanes_ordered     = rfec_align_locked;
    assign rx_pcs_rst_req    = rfec_slip_rst_req;
    assign din_req           = 1'b0;
    assign lanes_word_locked = 20'h0;
    assign dout_tags         = 100'h0;
    assign dout_stky_frm_err = 20'b0;
  end	

end
else begin : FEC_PCS
  /*if (ENABLE_ANLT==0 && SYNOPT_C4_RSFEC == 1 ) begin
    assign align_dsk         = (enable_rsfec == 1) ? ~din_valid        : align_dsk_pcs;
    assign dout_dsk          = (enable_rsfec == 1) ? din               : dout_dsk_pcs; 
    assign align_locked      = (enable_rsfec == 1) ? rfec_align_locked : align_locked_pcs;
    assign deskew_locked     = (enable_rsfec == 1) ? rfec_align_locked : deskew_locked_pcs;
    assign word_locked       = (enable_rsfec == 1) ? rfec_align_locked : word_locked_pcs;
    assign lanes_ordered     = (enable_rsfec == 1) ? rfec_align_locked : lanes_ordered_pcs;
    assign rx_pcs_rst_req    = (enable_rsfec == 1) ? rfec_slip_rst_req : rx_pcs_rst_req_pcs;
    assign din_req           = 1'b0;
    assign lanes_word_locked = (enable_rsfec == 1) ? 20'h0             : lanes_word_locked_pcs;
    assign dout_tags         = (enable_rsfec == 1) ? 100'h0            : dout_tags_pcs;
    assign dout_stky_frm_err = (enable_rsfec == 1) ? 20'b0             : dout_stky_frm_err_pcs;
  end else begin*/
  	assign align_dsk         = ~din_valid;
    assign dout_dsk          = din; 
    assign align_locked      = rfec_align_locked;
    assign deskew_locked     = rfec_align_locked;
    assign word_locked       = rfec_align_locked;
    assign lanes_ordered     = rfec_align_locked;
    assign rx_pcs_rst_req    = rfec_slip_rst_req;
    assign din_req           = 1'b0;
    assign lanes_word_locked = 20'h0;
    assign dout_tags         = 100'h0;
    assign dout_stky_frm_err = 20'b0;
  //end	
end
endgenerate

// descramble

wire    [64*4-1:0]  dout_dsc;
wire    [66*4-1:0]  din_dec;
wire    [7:0]       dout_frame_lag;
wire    [64*4-1:0]  data_dsc;

alt_e100s10_unframe uf (
    .clk                (clk),
    .din                (dout_dsk),
    .dout_frame_lag     (dout_frame_lag),
    .dout_data          (data_dsc) 
);

alt_e100s10_descram des (
    .clk                (clk),
    .din_valid          (~align_dsk),
    .din                (data_dsc),
    .dout               (dout_dsc),
    .dout_valid         (dout_valid_dsc)            // unused
);

alt_e100s10_refram rf (
    .din_data           (dout_dsc),
    .din_frame          (dout_frame_lag),
    .dout               (din_dec)
);

// block decode
wire  [4*64-1:0]      dout_d_block_decode;
wire  [4*8-1:0]       dout_c_block_decode;
generate

for (i=0; i<4; i=i+1) begin : deode

    alt_e100s10_ethdec  dec (
        .clk                (clk),
        .din                (din_dec[66*i+:66]),
        .blke               (),                     // debug signal
        .dout_c             (dout_c_block_decode[8*i+:8]),
        .dout_d             (dout_d_block_decode[64*i+:64])
    );
    defparam dec .SIM_EMULATE = SIM_EMULATE;

end

endgenerate

alt_e100s10_delay4w1 d0 (
    .clk                (clk),
    .din                (align_dsk),
    .dout               (dout_am)
);
defparam    d0 .SIM_EMULATE = SIM_EMULATE;

//////////////////////////////////
// Link Fault
// ____________________________________________________________________________
//     High BER detection module. This has been tied to the SYNOPT_LINK_FAULT
//     so this synthesis option must be visible to customer in the GUI
//     for the PHY_ONLY option as well.
// ___________________________________________________________________________
  
localparam BER_INVALID_CNT = 7'd97;       // this is for BER invalid syn header threshold
localparam BER_CYCLE_CNT   = 21'd196313;  // 100GBASE-R: 500us; 40GBASE-R: 1.25ms; // 100G: 500x390.625=196312.5;
//localparam BER_CYCLE_CNT   = 21'd390625;  //this is for 1ms cycles in 390.625 MHZ. 1 clk //40G;

localparam LinkFault_Ordered_Ctrl       =  8'h1,
           LinkFault_Ordered_LocalFault = {8'h0, 8'h0, 8'h0, 8'h0, 8'h1, 8'h0, 8'h0, 8'h9c};
 
generate
   if (SYNOPT_LINK_FAULT) begin //enable link fault function
	// High BER Calculation        
	alt_e100s10_pcs_ber pcs_ber (
		.rstn			(!reset),		// I: Active low Reset, only global reset can clean link status, reset_async_sync, 100MHZ
		.clk			(clk),			// I: Clock
		.bypass_ber		(1'b0),			// I: Bypass BER Monitoring
		.align_status_in	(align_locked),	// I: 
		.data_in_valid		(1'b1),			// I:   
		.rx_blocks		(din_dec),		// I: [NUM_BLOCKS*BLOCK_LEN-1:0]  66x4 bit
		.rxus_timer_window	(BER_CYCLE_CNT),	// I: MDIO for xus timer counter. Timer is 1ms (scaled from 40G timer = 1.25ms, 1.25 x (4/5) )
		.rbit_error_total_cnt	(BER_INVALID_CNT),	// I: MDIO for BER count. 40G/100G is 97.
		.hi_ber			(hi_ber)		// O: Indicates High BER detected
	);
          
	//Replace order sets with Local Fault Ordered set        
	reg  insert_lblock;
	always @(posedge clk) begin insert_lblock <= (~align_locked) | hi_ber; end
      
	assign dout_c = (insert_lblock) ? {4{LinkFault_Ordered_Ctrl}}       : dout_c_block_decode; 
	assign dout_d = (insert_lblock) ? {4{LinkFault_Ordered_LocalFault}} : dout_d_block_decode;
       
   end else begin
	assign hi_ber  = 1'b0; 
	assign dout_c  = dout_c_block_decode; 
	assign dout_d  = dout_d_block_decode;
   end
endgenerate


endmodule



