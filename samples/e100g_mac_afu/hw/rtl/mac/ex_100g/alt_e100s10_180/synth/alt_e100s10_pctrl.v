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


// 100G RX-PCS Controller
// Faisal (03/2017)


`timescale 1 ps / 1 ps

module alt_e100s10_pctrl #(
    parameter   SIM_EMULATE = 1'b0
)(
    input                   clk           ,     
    input                   reset         ,     
    input   [3:0]           walign_lock    ,     
    input                   deskew_locked , 
    input                   align_locked   ,
    input   [3:0]           purge_align   ,     
    input                   purge_deskew  ,     
    input                   predicted_align,

    input   [19:0]          etag_am       ,     
    input   [19:0]          etag_opp      ,     
    input   [20*5-1:0]      etag_tnum     ,     
    output  reg [20*5-1:0]  dout_tags     ,

    input                   phase_align_in,         // last cycle for high-value at shifter   
    output  reg [19:0]      phase_rfrm    ,     // delay 3 cycles from phase_align_in for reframer to know it is low cycle
    output  [139:0]         clos_sel      ,     
    output  reg [2:0]       phase_dsk    = 3'h0 ,     
    output                  reset_dsk     ,     
    output  reg             word_locked   ,
    output                  lanes_ordered ,

    output  reg             purge_req          
);

// PCS Reset Request
reg purge_xctrl;
always @(posedge clk) begin
    purge_req   <=  (|purge_align) | purge_deskew | purge_xctrl ;
end

genvar i;
generate

    for (i = 0; i <20; i = i + 1) begin : dtags
        always @(posedge clk) begin
            if (reset)
                dout_tags[5*i+:5]   <=  5'h1f;
            if (etag_opp[i] & ~lanes_ordered)
                dout_tags[5*i+:5]   <=  etag_tnum[5*i+:5];
        end
    end

endgenerate


//////////////////////////////////////////////
///////  Clos Network controller   //////////
//////////////////////////////////////////////
//reg     reset_xctrl;
wire    xctrl_rst_pulse;
wire [2:0]    xctrl_done;
alt_e100s10_xctrl xctrl_inst (
    .clk            (clk), 
    .reset          (xctrl_rst_pulse), 

    .vtag           (etag_tnum),
    .vt_valid       (etag_opp),

    .sel            (clos_sel),
    .done           (xctrl_done[2:0])
);
defparam    xctrl_inst  .VLANES = 20;
defparam    xctrl_inst  .SIM_EMULATE = SIM_EMULATE;



//////////////////////////////////////////////
//////  Clos Network Reset Control   /////////
//////////////////////////////////////////////


/////////////////////////
// monitoring of AMs
// AMs detection status at either side of re-order

reg pred_align_d1, pred_align_d2;
always @(posedge clk) begin
    pred_align_d1 <=  predicted_align;
    pred_align_d2 <=  pred_align_d1;
end


wire    etag_am_ar;
alt_e100s10_alnchk e_am (
    .clk        (clk),
    .clr        (pred_align_d1),
    .reset      (reset),
    .etag       (etag_am),
    .all_recd   (etag_am_ar)
);
defparam    e_am .SIM_EMULATE = SIM_EMULATE;


reg [2:0]       state = 3'h0;
localparam  RESET     = 3'b001;
localparam  WAIT      = 3'b010;
localparam  EVALUATE  = 3'b100;

reg  [2:0]          cntr_pstlock;
wire [9:0]          cntr_prelck_l;  
reg                 pre_lock_reset;
wire                post_lock_reset;
wire                active_shrt, active_long;

//////////////////////
// pre-lock count logic - watchdog to reset re-order if it looks stuck
// Hybrid Short/Long approach 
// Initially employs smaller watchdog that checks 4/128 alignment intervals 
// (each with 81920/2560 cycles in hardware/simulation),
// and does xctrl-reset if alignment is not achieved.
// Four short xctrl-resets without a PCS reset activates longer watchdog
// Long interval waits for 2^10 alignment intervals. If alignment still is not
// achieved, it sends PCS reset request.

reg prec_clr, prec_inc;
always @(posedge clk)   prec_inc    <=  pred_align_d1 & (~xctrl_done[0]);
always @(posedge clk)   prec_clr    <=  xctrl_done[0] | reset;

wire prelck_rst_s;
generate
if (SIM_EMULATE) begin : plk

    reg [6:0] cntr_prelck_s;
    always @(posedge clk) begin
        if (prec_clr)                     cntr_prelck_s    <= 7'h0;
        else if (prec_inc & active_shrt)  cntr_prelck_s    <= cntr_prelck_s + 1'b1;
    end
    assign  prelck_rst_s   = cntr_prelck_s[6];
    
end else begin
    reg [2:0] cntr_prelck_s;
    always @(posedge clk) begin
        if (prec_clr)                     cntr_prelck_s    <= 3'h0;
        else if (prec_inc & active_shrt)  cntr_prelck_s    <= cntr_prelck_s + 1'b1;
    end
    assign  prelck_rst_s   = cntr_prelck_s[2];
end
endgenerate


reg     [2:0]   shrt_rst_cnt;
always @(posedge clk) begin
    if (reset)              shrt_rst_cnt <=  3'h0;
    else if (prelck_rst_s)  shrt_rst_cnt <= shrt_rst_cnt + 1'b1;
end

assign active_shrt  = ~shrt_rst_cnt[2];
assign active_long  =  shrt_rst_cnt[2];


alt_e100s10_cnt10ic pre0 (
    .clk        (clk),
    .inc        (prec_inc),
    .sclr       (active_shrt),
    .dout       (cntr_prelck_l)
);
defparam pre0 .SIM_EMULATE = SIM_EMULATE;
assign prelck_rst_l = cntr_prelck_l[9];

always @(posedge clk) begin
    pre_lock_reset  <= ( prelck_rst_s & active_shrt ) ;
    purge_xctrl     <= ( prelck_rst_l & active_long ) ;
end



//////////////////////
// post-lock count logic - checking 4 missing AMs after re-order

reg postc_clr;
always @(posedge clk) postc_clr     <=  (state == RESET) | ((state == EVALUATE)  & etag_am_ar) ;

reg postc_inc;
always @(posedge clk) postc_inc     <=  (state == EVALUATE) & ~etag_am_ar & xctrl_done[0] ;

always @(posedge clk) begin
    if (postc_clr)      cntr_pstlock  <=  3'h0;
    else if (postc_inc) cntr_pstlock  <=  cntr_pstlock + 1'b1;
end
assign post_lock_reset  = cntr_pstlock[2];


/////////////////////////////
// State machine to evaluate reset state for Clos controller

always @(posedge clk) begin

    if (reset)
        state   <=  RESET;
    else begin
        case (state)
            RESET:          begin
                               if (word_locked)
                                state   <=  WAIT;

                            end


            WAIT:           begin
                                if (!word_locked)
                                    state   <=  RESET;
                                else if (pred_align_d2)
                                    state   <=  EVALUATE;

                            end

            EVALUATE:       begin
                               if (post_lock_reset)
                                    state   <=  RESET;
                                else if (pre_lock_reset)
                                    state   <=  RESET;
                                else
                                    state   <=  WAIT;
                            end

        endcase
    end

end

// extending reset pulse
wire xctrl_rst;
assign xctrl_rst = (state == RESET);
alt_e100s10_pulse16 rpulse (
    .clk        (clk),
    .din        (xctrl_rst),
    .dout       (xctrl_rst_pulse)
);
defparam    rpulse .SIM_EMULATE = SIM_EMULATE;


always @(posedge clk) word_locked <= &walign_lock;

// Evaluates if lane-ordering is correct, and announces lock
reg [2:0]   cntr_lock_eval = 3'h0;
reg         cle_clr, cle_incr;
always @(posedge clk) cle_clr  <=  (state == RESET) ;
always @(posedge clk) cle_incr <=  (state == EVALUATE ) & (xctrl_done[1] & etag_am_ar) & ~cntr_lock_eval[2];
always @(posedge clk) begin
    if (cle_clr)           cntr_lock_eval  <=  3'h0;
    else if (cle_incr)     cntr_lock_eval  <=  cntr_lock_eval + 1'b1;
end
assign  lanes_ordered =  cntr_lock_eval[2];
assign  reset_dsk     = ~cntr_lock_eval[2];

//////////////////////
// generating load and 10/14 shift phase for reframer 


reg [2:0] phase_rfrm_shft;
always @(posedge clk) begin
    phase_rfrm_shft <=  {phase_rfrm_shft[1:0], phase_align_in};
    phase_rfrm      <= {20{phase_rfrm_shft[2]}};
end

//////////////////////
// generating incoming VL sequence phase for deskew

always @(posedge clk) begin
    if (phase_rfrm[0])
        phase_dsk   <=  3'h4;
    else if (phase_dsk == 3'h4)
        phase_dsk   <=  3'h0;
    else
        phase_dsk   <=  phase_dsk + 1'b1;
end

endmodule


//1,0,0,0,0,1
//x,1,2,3,4,5
//x,1,2,3,4,0
