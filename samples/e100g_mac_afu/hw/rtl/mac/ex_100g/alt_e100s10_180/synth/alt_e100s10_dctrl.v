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



`timescale 1ps/1ps

// Deskew Controller
// Faisal Khan
// 11/15/2016

module alt_e100s10_dctrl #(
    parameter SIM_EMULATE = 1'b0
) (
    input               clk,  // pragma clock_port
    input               reset,
    input   [19:0]      am,
    input               predicted_align,
    output              perfect_align,
    output  reg [19:0]  fallback = 20'h0,
    output  reg         deskew_locked = 1'b0,
    output              purge
);

// Register the pings falling within a window
wire    [19:0]    am_c2;
alt_e100s10_delay d0 (     // CC-2
    .clk        (clk),
    .din        (am),
    .dout       (am_c2)
);
defparam    d0 .WIDTH = 20;
defparam    d0 .LATENCY = 2;
defparam    d0 .SIM_EMULATE = SIM_EMULATE;

wire any_ping;
alt_e100s10_or20t2 or0 (   //CC-2
    .clk        (clk),
    .din        (am),
    .dout       (any_ping)
);
defparam    or0 .SIM_EMULATE = SIM_EMULATE;

reg recent_ping;
reg recent_ping_d1;
wire recent_ping_pulse=recent_ping & (~recent_ping_d1);
wire last_am;
always @(posedge clk) begin // CC-3
    if (reset )
        recent_ping_d1   <=  1'b0;
    else 
        recent_ping_d1   <=  recent_ping;
end

reg [6:0] ping_cnt;
always @(posedge clk) begin // CC-3
    if (reset )
        ping_cnt   <=  7'h0;
    else if (any_ping & (~perfect_align))
        ping_cnt   <=  7'h1;
    else if (ping_cnt[6]&ping_cnt[4]) //80
        ping_cnt   <=  7'h0;
    else if (ping_cnt!==0) ping_cnt <=ping_cnt +7'h1;
end

always @(posedge clk) begin // CC-3
    if (reset )
        recent_ping   <=  1'b0;
    else if (any_ping & (~perfect_align))
        recent_ping   <=  1'b1;
    else if (ping_cnt[6]&ping_cnt[4])
        recent_ping   <=  1'b0;
end
/*
wire recent_ping;
alt_e100s10_pulse64 ps0 (  // CC-3
    .clk        (clk),
    .din        (any_ping),
    .dout       (recent_ping)
);
defparam ps0 .SIM_EMULATE = SIM_EMULATE;
*/

reg     [19:0]  am_r;
wire    all_am;    // recieved all the AMs
always @(posedge clk) begin // CC-3
    if (reset | all_am)
        am_r   <=  20'h0;
    else if (any_ping )
        am_r   <=  am_r | am_c2;
    else if (!recent_ping)
        am_r    <=  20'h0;
end

alt_e100s10_and20t2  a0(
    .clk        (clk),
    .din        (am_r),
    .dout       (all_am)   // CC-5
);
defparam    a0 .SIM_EMULATE = SIM_EMULATE;
reg all_am_d1;
always @(posedge clk) all_am_d1 <=  all_am;

// Figure out which VLs to push back
assign    last_am = all_am & ~all_am_d1;
/*
reg [19:0]  fallback_i, fallback_c5, fallback_c6;     // CC-4
always @(posedge clk) begin
    if (recent_ping)    fallback_i  <=  fallback_i  | am_r;
    else                fallback_i  <=  20'h0;

    fallback_c5 <=  fallback_i;
    fallback_c6 <=  fallback_c5;

end
*/
reg [19:0]  fallback_c6;     // CC-4
always @(posedge clk) begin
    if (recent_ping_pulse)    fallback_c6  <=   am_r;
    else if (last_am)               fallback_c6  <=  20'h0;

end

always @(posedge clk) begin //CC - 7
    if (reset)	fallback <= 20'h0;
    else if (last_am & !deskew_locked)   
        fallback    <=  fallback_c6;
    else
        fallback    <=  20'h0;
end


//wire    any_flbk;
//alt_e100s10_or20t3 or0 (   //CC-11
//    .clk        (clk),
//    .din        (fallback),
//    .dout       (any_flbk)
//);
//defparam    or0 .SIM_EMULATE = SIM_EMULATE;


///////////////////////////////////
// control

alt_e100s10_and20t2 a1 (   //CC-2
    .clk        (clk),
    .din        (am),
    .dout       (perfect_align)
);
defparam    a1 .SIM_EMULATE = SIM_EMULATE;

//alt_e100s10_delay d2 (    //CC-2
//    .clk        (clk),
//    .din        (predicted_align),
//    .dout       (palign_c2)
//);
//defparam    d2 .WIDTH = 1;
//defparam    d2 .LATENCY = 2;
//defparam    d2 .SIM_EMULATE = SIM_EMULATE;


reg [1:0] de_st = 2'b0 /* synthesis preserve_syn_only dont_replicate */;
reg advance;
reg retreat;
reg am_rcvd, de_slip;
reg [1:0] de_slip_cnt;

always @(posedge clk) advance   <=  (de_st[1] ^ de_st[0]) & perfect_align ;
always @(posedge clk) retreat   <=   ~perfect_align & predicted_align;   
always @(posedge clk) am_rcvd   <=   perfect_align & predicted_align;   
always @(posedge clk) de_slip   <=   (de_slip_cnt == 2'h3) & retreat;

always @(posedge clk) begin
    if (reset)  de_st   <=  2'b0;
    else begin
        case (de_st)
            2'h0 : de_st <= 2'h1;
            2'h1 : begin
                    if (advance)    de_st <= 2'h2;
                    if (purge)      de_st <= 2'h0;
            end
            2'h2 : begin
                 if (retreat) de_st <= 2'h0;
                 if (advance) de_st <= 2'h3;
            end
            2'h3 : begin
                 if (de_slip) de_st <= 2'h0;
                 //if (retreat) de_st <= 2'h1;
                 else         de_st <= 2'h3;
            end
        endcase
    end
end

always @(posedge clk) begin
    deskew_locked <= &de_st;
end

always @(posedge clk) begin
  if (de_st != 2'h3)		de_slip_cnt <= 2'h0;
  else if (am_rcvd)		de_slip_cnt <= 2'h0;
  else if (retreat)		de_slip_cnt <= de_slip_cnt + 1'b1;
end


////////////////////////////
// fallback counter & pcs-self-reset logic
reg [5:0]   cnt;

always @(posedge clk) begin
    if (de_st != 2'b01 ) begin
        cnt <=  5'h0;
    end
    else if (predicted_align) begin
        cnt <=  cnt + 1'b1;
    end
end
assign  purge   = cnt[5];



endmodule
// BENCHMARK INFO : Date : Wed Nov 16 14:13:37 2016
// BENCHMARK INFO : Quartus version : /tools/acdskit/17.0/132/linux64/quartus/bin
// BENCHMARK INFO : benchmark P4 version: 17 
// BENCHMARK INFO : benchmark path: /data/fkhan/work/s100
// BENCHMARK INFO : ; Total registers                              ; 166   ;
// BENCHMARK INFO : Debug: SUTIL:  ** Total registers 167
// BENCHMARK INFO : Debug: SUTIL:  ** Total registers 166
// BENCHMARK INFO : Number of LUT levels: Max 1.0 LUTs   Average 0.68
// BENCHMARK INFO : Number of Fitter seeds : 3
// BENCHMARK INFO : Device: 1SG280LU3F50E2VG
// BENCHMARK INFO : ALM usage: 89
// BENCHMARK INFO : Combinational ALUT usage: 69
// BENCHMARK INFO : Fitter seed 1000: Worst setup slack @ 450 MHz : 0.679 ns, From ps0|dout_r~LAB_RE_X227_Y300_N0_I44_dff_Duplicate_3, To am_r[14] 
// BENCHMARK INFO : Fitter seed 2234: Worst setup slack @ 450 MHz : 0.718 ns, From all_am_d1, To fallback[9]~reg0 
// BENCHMARK INFO : Fitter seed 3468: Worst setup slack @ 450 MHz : 0.821 ns, From ps0|dout_r, To am_r[3] 
// BENCHMARK INFO : Elapsed benchmark time: 3875.9 seconds
