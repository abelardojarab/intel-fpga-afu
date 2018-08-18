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

// Deskew & Alignment monitor
// Output Sequencer
// Faisal Khan
// 12/20/2016

// CC - VL
// 0 - 0,1,2,3
// 1 - 4,5,6,7
// 2 - 8,9, 10,11
// 3 - 12,13,14,15, 16,17
// 4 - 18,19

module alt_e100s10_deskew #(
    parameter SIM_EMULATE = 1'b0,
    parameter SIM_SHORT_AM      = 1'b0
)(
    input               clk,    // pragma clock_port
    input               reset,
    input   [20*66-1:0] din,
    input   [2:0]       in_phase,
    input               in_valid,
    input   [19:0]      am,

    
    output  [4*66-1:0]  dout,
    output              predicted_align,

    output              deskew_locked,
    output              align_locked,
    output  reg         align_out,
    output              purge
);

genvar i;


///// self reset
reg reset_i = 1'b1;
reg deskew_locked_d1 = 1'b0;
always @(posedge clk) begin
    deskew_locked_d1    <=  deskew_locked;
    reset_i             <=  (deskew_locked_d1 & ~deskew_locked ) | reset;
end


/////////////////////////////////////
// Arranging Data for FIFOs
// multiplexing two VLs
// dmux: (0,4), (1,5), (2,6), (3,7), (8,12), (9,13), (10,14), (11,115), (16,18), (17,19)

wire    [10*66-1:0] dmux;
generate

for (i=0; i<4; i=i+1) begin : p1
    alt_e100s10_mux2w66t1s1 m0 (
        .clk        (clk),
        .din        ({din[(i+4)*66+:66], din[(i)*66+:66]}),
        .sel        (~(in_phase[2] & ~in_phase[1] & ~in_phase[0])),
        .dout       (dmux[i*66+:66])
    );
    defparam    m0 .SIM_EMULATE = SIM_EMULATE;
end

for (i=8; i<12; i=i+1) begin : p2
    alt_e100s10_mux2w66t1s1 m1 (
        .clk        (clk),
        .din        ({din[(i+4)*66+:66], din[(i)*66+:66]}),
        .sel        (~(~in_phase[2] & ~in_phase[1] & in_phase[0])),
        .dout       (dmux[(i-4)*66+:66])
    );
    defparam    m1 .SIM_EMULATE = SIM_EMULATE;
end

for (i=16; i<18; i=i+1) begin : p3
    alt_e100s10_mux2w66t1s1 m2 (
        .clk        (clk),
        .din        ({din[(i+2)*66+:66], din[(i)*66+:66]}),
        .sel        (~(~in_phase[2] & in_phase[1] & ~in_phase[0])),
        .dout       (dmux[(i-8)*66+:66])
    );
    defparam    m2 .SIM_EMULATE = SIM_EMULATE;
end


endgenerate

// Permuting AM input to FIFOs
reg [9:0]   amux;
always @(posedge clk) begin

    case (in_phase)
        3'b000:     amux <=  {6'h0, am[3:0]};
        3'b001:     amux <=  {6'h0, am[7:4] };
        3'b010:     amux <=  {2'h0, am[11:8], 4'h0 };
        3'b011:     amux <=  {am[17:12], 4'h0 };
        3'b100:     amux <=  {am[19:18], 8'h0 };
        default:    amux <=  10'h0;
    endcase
end


/////////////////////////////////////
// Skew adjustment FIFOs

wire    [19:0]  td_flbk;
wire    [66*10-1:0] dout_f;
wire    [9:0]   am_out;


reg valid_03;
reg valid_47;
reg valid_89;
always @(posedge clk) valid_03  <=  in_valid & ~in_phase[1] & ~in_phase[2];
always @(posedge clk) valid_47  <=  in_valid &  in_phase[1] & ~in_phase[2];
always @(posedge clk) valid_89  <=  in_valid &  (in_phase[2] | (in_phase[1] & in_phase[0] ) );

reg [2:0]   phase_w = 3'h0 /* synthesis preserve_syn_only */;
always @(posedge clk) begin
    phase_w[0]   <=  ~in_phase[2] & ~in_phase[1] &  in_phase[0];
    phase_w[1]   <=  ~in_phase[2] &  in_phase[1] &  in_phase[0];
    phase_w[2]   <=   in_phase[2] & ~in_phase[1] & ~in_phase[0];
end

reg     [9:0]   td_sclr = 10'h0; //3FF /* synthesis preserve_syn_only */;
always @(posedge clk)    td_sclr     <=  {10{reset_i}};

generate
for (i=0; i<4; i=i+1) begin : df0

alt_e100s10_twodel67  td03(
    .clk            (clk),
    .din_phase      (phase_w[0]),
    .din_valid      (valid_03),     
    .din_sclr       (td_sclr[i]),
    .din_fallback   (td_flbk[(i*2)+:2]),
    .din            ({dmux[66*i+:66], amux[i]}),
    .dout           ({dout_f[66*i+:66], am_out[i]})
);
defparam td03 .SIM_EMULATE = SIM_EMULATE;

end

for (i=4; i<8; i=i+1) begin : df1

alt_e100s10_twodel67  td47(
    .clk            (clk),
    .din_phase      (phase_w[1]),
    .din_valid      (valid_47),     
    .din_sclr       (td_sclr[i]),
    .din_fallback   (td_flbk[(i*2)+:2]),
    .din            ({dmux[66*i+:66], amux[i]}),
    .dout           ({dout_f[66*i+:66], am_out[i]})
);
defparam td47 .SIM_EMULATE = SIM_EMULATE;

end

for (i=8; i<10; i=i+1) begin : df2

alt_e100s10_twodel67  td89(
    .clk            (clk),
    .din_phase      (phase_w[2]),
    .din_valid      (valid_89),     
    .din_sclr       (td_sclr[i]),
    .din_fallback   (td_flbk[(i*2)+:2]),
    .din            ({dmux[66*i+:66], amux[i]}),
    .dout           ({dout_f[66*i+:66], am_out[i]})
);
defparam td89 .SIM_EMULATE = SIM_EMULATE;

end


endgenerate


/////////////////////////////////////
// Deskew Controller

wire    [19:0]  fallback;
wire    [19:0]  am_ctrl;
wire            perfect_align;
reg     [19:0]  am_i;

alt_e100s10_dctrl dctrl(
    .clk                (clk),  
    .reset              (reset_i),
    .am                 (am_i),
    .predicted_align    (predicted_align),
    .perfect_align      (perfect_align),
    .fallback           (fallback),
    .deskew_locked      (deskew_locked),
    .purge              (purge)
);
defparam    dctrl .SIM_EMULATE = SIM_EMULATE;



// De-permute AM from FIFOs for Controller
reg [2:0]   phase_c2 /* synthesis syn_preserve_syn_only */ ;
reg [2:0]   phase_c2a /* synthesis syn_preserve_syn_only */ ;
reg [2:0]   phase_c2b /* synthesis syn_preserve_syn_only */ ;
always @(posedge clk) begin
    phase_c2    <=  in_phase;
    phase_c2a   <=  in_phase;
    phase_c2b   <=  in_phase;
end


reg [19:0]  am_r;
always @(posedge clk) begin
    case(phase_c2)
        3'b000:     am_r    <=  {16'h0, am_out[3:0] };
        3'b001:     am_r    <=  {am_r[19:8], am_out[3:0], am_r[3:0]};
        3'b010:     am_r    <=  {am_r[19:12], am_out[7:4], am_r[7:0]};
        3'b011:     am_r    <=  {am_r[19:18], am_out[9:4], am_r[11:0]};
        3'b100:     am_r    <=  {am_out[9:8], am_r[17:0]};
        default:    am_r    <=  am_r;
    endcase
end

always @(posedge clk) begin
    if (~phase_c2[2] & ~phase_c2[1] & ~phase_c2[0]) 
        am_i    <=  am_r;
    else
        am_i    <=  20'h0;
end


// Permute Fallback from Controller for FIFOs
generate    
    for (i=0; i<4; i=i+1) begin : prm1
        assign td_flbk[i*2]    =   fallback[i];
        assign td_flbk[i*2+1]  =   fallback[i+4];
    end

    for (i=0; i<4; i=i+1) begin : prm2
        assign td_flbk[(i + 4)*2]    =   fallback[i+8];
        assign td_flbk[(i + 4)*2+1]  =   fallback[i+8+4];
    end


    for (i=0; i<2; i=i+1) begin : prm3
        assign td_flbk[(i+8)*2]    =   fallback[i+16];
        assign td_flbk[(i+8)*2+1]  =   fallback[i+16+2];
    end

endgenerate

//////////////////////////////////
// lock onto alignment period
wire leading_align;
wire align_lock;
generate
    if (SIM_SHORT_AM) begin
        alt_e100s10_alignmon2560e8 am0 (
            .clk(clk),
            .sclr(reset_i),
            .perfect_align(perfect_align),
            .predicted_align(predicted_align),
            .leading_predict(leading_align),
            .locked(align_locked)
        );
        defparam am0 .SIM_EMULATE = SIM_EMULATE;

    end else begin
        alt_e100s10_alignmon81920e8 am1 (
            .clk(clk),
            .sclr(reset_i),
            .perfect_align(perfect_align),
            .predicted_align(predicted_align),
            .leading_predict(leading_align),
            .locked(align_locked)
        );
        defparam am1 .SIM_EMULATE = SIM_EMULATE;

    end
endgenerate


/////////////////////////////////////
// Output Sequencer
//


reg [65:0]  d16, d17;
always @(posedge clk ) begin
  
    if (phase_c2a == 3'b011) begin
        d16 <=  dout_f[8*66+:66];
    end
    if (phase_c2b == 3'b011) begin
        d17 <=  dout_f[9*66+:66];
    end
end

wire    [66*4-1:0]  din0, din1, din2, din3;
assign  din0 = {66'h0, d16, dout_f[4*66+:66], dout_f[0+:66]};
assign  din1 = {66'h0, d17, dout_f[5*66+:66], dout_f[1*66+:66]};            
assign  din2 = {66'h0, dout_f[8*66+:66], dout_f[6*66+:66], dout_f[2*66+:66]};            
assign  din3 = {66'h0, dout_f[9*66+:66], dout_f[7*66+:66], dout_f[3*66+:66]};            

alt_e100s10_mux4w66t1s1 o0 (
    .clk        (clk),
    .din        (din0),
    .sel        (in_phase[2:1]),
    .dout       (dout[0+:66])
);
defparam o0 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_mux4w66t1s1 o1 (
    .clk        (clk),
    .din        (din1),
    .sel        (in_phase[2:1]),
    .dout       (dout[1*66+:66])
);
defparam o1 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_mux4w66t1s1 o2 (
    .clk        (clk),
    .din        (din2),
    .sel        (in_phase[2:1]),
    .dout       (dout[2*66+:66])
);
defparam o2 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_mux4w66t1s1 o3 (
    .clk        (clk),
    .din        (din3),
    .sel        (in_phase[2:1]),
    .dout       (dout[3*66+:66])
);
defparam o3 .SIM_EMULATE = SIM_EMULATE;
 
// output AM pulse

alt_e100s10_pulse4 amp(
    .clk        (clk),
    .din        (leading_align),
    .dout       (align_i)
);
defparam amp .SIM_EMULATE = SIM_EMULATE;

always @(posedge clk) begin
    align_out   <=  align_i | leading_align;
end

endmodule
// BENCHMARK INFO : Date : Thu Dec 29 19:27:32 2016
// BENCHMARK INFO : Quartus version : /tools/acdstest-rtl/17.0/162/linux64/quartus/bin
// BENCHMARK INFO : benchmark P4 version: 17 
// BENCHMARK INFO : benchmark path: /data/fkhan/work/s100
// BENCHMARK INFO : ; Total registers                              ; 4103  ;
// BENCHMARK INFO : ; Total block memory bits                     ; 0                           ;
// BENCHMARK INFO : Debug: SUTIL:  ** Total registers 4144
// BENCHMARK INFO : Debug: SUTIL:  ** Total registers 4103
// BENCHMARK INFO : Number of LUT levels: Max 2.0 LUTs   Average 0.54
// BENCHMARK INFO : Number of Fitter seeds : 3
// BENCHMARK INFO : Device: 1SG280LU3F50I3VG
// BENCHMARK INFO : ALM usage: 2478
// BENCHMARK INFO : Combinational ALUT usage: 1,345
// BENCHMARK INFO : Fitter seed 1000: Worst setup slack @ 450 MHz : 0.199 ns, From phase_c2a[0], To d16[58] 
// BENCHMARK INFO : Fitter seed 2234: Worst setup slack @ 450 MHz : 0.160 ns, From df0[0].td03|dout_r[15], To o0|dout_r[14] 
// BENCHMARK INFO : Fitter seed 3468: Worst setup slack @ 450 MHz : 0.200 ns, From phase_c2a[1], To d16[17] 
// BENCHMARK INFO : Elapsed benchmark time: 2230.3 seconds
