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


// Copyright 2012 Altera Corporation. All rights reserved.  
// Altera products are protected under numerous U.S. and foreign patents, 
// maskwork rights, copyrights and other intellectual property laws.  
//
// This reference design file, and your use thereof, is subject to and governed
// by the terms and conditions of the applicable Altera Reference Design 
// License Agreement (either as signed by you or found at www.altera.com).  By
// using this reference design file, you indicate your acceptance of such terms
// and conditions between you and Altera Corporation.  In the event that you do
// not agree with such terms and conditions, you may not use the reference 
// design file and please promptly destroy any copies you have made.
//
// This reference design file is being provided on an "as-is" basis and as an 
// accommodation and therefore all warranties, representations or guarantees of 
// any kind (whether express, implied or statutory) including, without 
// limitation, warranties of merchantability, non-infringement, or fitness for
// a particular purpose, are specifically disclaimed.  By making this reference
// design file available, Altera expressly does not recommend, suggest or 
// require that this reference design file be used in combination with any 
// other product not provided by Altera.
/////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps
// baeckler - 08-21-2012

// set_instance_assignment -name VIRTUAL_PIN ON -to dout_d
// set_instance_assignment -name VIRTUAL_PIN ON -to dout_c
// set_instance_assignment -name VIRTUAL_PIN ON -to din

module alt_aeu_40_rx_pcs_2 #(
    parameter TARGET_CHIP = 2,
    parameter SYNOPT_FULL_SKEW = 0,
    parameter EN_LINK_FAULT = 1,
    parameter NUM_VLANE = 4,            // no override
    parameter WORDS = 2,                // no override
    parameter SIM_FAKE_JTAG = 1'b0,
    parameter AM_CNT_BITS = 14,
    parameter EARLY_REQ = 0,            // make the din request earlier for din latency adj
    parameter SIM_EMULATE = 1'b0        // replace components with slow sim models
)(
    input clk,
    input sclr,                         // from ~rx_online   
    input rst_async,                    // global reset, async, no domain, to reset link fault
    input [40*NUM_VLANE-1:0] din,       // lsbit first serial streams
    output [1:0] din_req,               // 2 copies 
    
    input sclr_frm_err,                 // clear the sticky flags
    output [NUM_VLANE-1:0] frm_err_out, // sticky framing flags
    output [NUM_VLANE-1:0] opp_ping_out,
    output reg fully_aligned = 1'b0,           // RX align done
    output wire hi_ber,
            
    output [WORDS*64-1:0] dout_d,
    output [WORDS*8-1:0] dout_c,
    //output reg [5*NUM_VLANE-1:0] wpos, 
    output [9*NUM_VLANE-1:0] dsk_depths,  
    output dout_am,                      // dout is alignment marker, discard    
    
    // debug text terminal
	output reg [7:0] byte_to_jtag,
	input [7:0] byte_from_jtag,
	output reg  byte_to_jtag_valid,
	output reg byte_from_jtag_ack,
	
	input stacker_ram_ena
);

initial byte_to_jtag = 8'h0;
initial byte_to_jtag_valid = 1'b0;
initial byte_from_jtag_ack = 1'b0;

//

localparam WPOS_BITS = SYNOPT_FULL_SKEW ? 9 : 5;
   
//////////////////////////////////////////////
// reordering

reg [4*2*5+5*3*4+4*2*5-1:0] ro_sels = 'b11_10_01_00;    
wire [40*NUM_VLANE-1:0] reordered_din;
/*
e40_clos_4 c4 (
        .clk(clk),
        .sels(ro_sels),
        .din(din),
        .dout(reordered_din)    
);
defparam c4 .WIDTH = 40;
*/
xbar_4 #(.WIDTH(40)) xb0 (
        .clk(clk),
        .sel(ro_sels[7:0]),
        .din(din),
        .dout(reordered_din)
);

//////////////////////////////////////////////
// word alignment

wire [40*NUM_VLANE-1:0] al_din;
wire [40*NUM_VLANE-1:0] pos_din;
reg [6*NUM_VLANE-1:0] bpos = {NUM_VLANE{6'h3f}}; 
reg [WPOS_BITS*NUM_VLANE-1:0] wpos = {NUM_VLANE*WPOS_BITS{1'b0}};

wire ro_din_valid;
delay_regs #(.WIDTH(1),.LATENCY(1 + EARLY_REQ)) dr0 (
        .clk(clk),
        .din(din_req[0]),
        .dout(ro_din_valid)
);

wire al_din_valid;
delay_regs #(.WIDTH(1),.LATENCY(2)) dr1 (
        .clk(clk),
        .din(ro_din_valid),
        .dout(al_din_valid)
);

// synthesis translate_off
/////////////////////////////////////////////
// START debug monitor for 40 bit samples
reg [84:0] history = 0;
reg [7:0] history_held = 0;
reg [65:0] history_out = 0;
reg last_req = 1'b0;

always @(posedge clk) begin
        if (ro_din_valid) begin
                 history = history | (reordered_din[4*40-1:3*40] << history_held);
                 history_held = history_held + 16;
        end
        if (history_held >= 66) begin
                history_out = history[65:0];
                history = history >> 66;
                history_held = history_held - 66;
        end
end
// END debug monitor for 40 bit samples
/////////////////////////////////////////////
// synthesis translate_on

genvar i;
generate
        for (i=0; i<NUM_VLANE; i=i+1) begin : alp
                alt_aeu_40_align_40 al (
                        .clk(clk),
                        .pos(bpos[(i+1)*6-1:i*6]),
                        .din(reordered_din[(i+1)*40-1:i*40]),    // lsbit first
                        .din_valid(ro_din_valid),
                        .dout(al_din[(i+1)*40-1:i*40])  // lsbit first
                );
                
                // al_din is OK
           if (!SYNOPT_FULL_SKEW) begin : gdd1
                delay_dynamic #(.WIDTH(40), .TARGET_CHIP(TARGET_CHIP), .SIM_EMULATE(SIM_EMULATE)) dd (
                        .clk(clk),
                        .delta(wpos[(i+1)*WPOS_BITS-1:i*WPOS_BITS]),
                                // ? avoid delta = 1, r/w collision
                                //  minimum delta=2, latency of 1 tick
                                //  ...
                                //  delta = 1f,      latency of 30 ticks
                                //  delta = 0         latency of 31 ticks
                        .din_valid(al_din_valid),
                        .din_reg(al_din[(i+1)*40-1:i*40]),
                        .dout(pos_din[(i+1)*40-1:i*40])
                );
           end
           else begin : gdd2
                alt_delay_dynamic_m20k #(.WIDTH(40), .ADDR_WIDTH(9)) dd (         
                        .clk(clk),
                        .delta(wpos[(i+1)*WPOS_BITS-1:i*WPOS_BITS]),
                                // Delta = 0 acts like 1025 registers of delay
                                // Delta = 1 acts like 1026 registers of delay
                                // Delta = 2 acts like 3 registers of delay
                                // Delta = 3 acts like 4 registers of delay
                                // Delta = 4 acts like 5 registers of delay
                                // ...
                                // Delta = 511 acts like 512 registers of delay
 
                        .din_valid(al_din_valid),
                        .din(al_din[(i+1)*40-1:i*40]),
                        .dout(pos_din[(i+1)*40-1:i*40])
                );
            end
        end 
endgenerate

//////////////////////////////////////////////
// gearboxes

reg [5:0] cnt = 0;
always @(posedge clk) begin
        if (sclr || cnt == 6'd39) cnt <= 6'h0;
        else cnt <= cnt + 1'b1;
end

wire [WORDS*66-1:0] gb_dout;
wire [WORDS-1:0] local_din_req;
wire [WORDS-1:0] dout_zero;

generate
        for (i=0; i<WORDS; i=i+1) begin : glp
                alt_aeu_40_gb_40_66_x2 #(.TARGET_CHIP(TARGET_CHIP), .PRE_TICKS(3 + EARLY_REQ)) gb (
                        .clk(clk),
                        .cnt(cnt),
                        .din(pos_din[(i+1)*2*40-1:i*2*40]),
                        .din_req(local_din_req[i]),
                        .pre_din_req(din_req[i]),
                        .dout(gb_dout[(i+1)*66-1:i*66]),
                        .dout_zero(dout_zero[i])
                );
        end
endgenerate


//////////////////////////////////////////////
// monitor for framing errors

reg [3:0] dout_sr = 0;
always @(posedge clk) begin
        dout_sr <= {dout_sr[2:0],dout_zero[0]};
end
wire [4:0] gb_dout_phase = {dout_sr,dout_zero[0]};
//wire [4:0] gb_dout_phase_adj3 = {gb_dout_phase[2:0],gb_dout_phase[4:3]};
wire [1:0] gb_dout_phase_adj3 = gb_dout_phase[4:3];
//wire [1:0] gb_dout_phase_adj3 = gb_dout_phase[3:2]; // wrong
//wire [1:0] gb_dout_phase_adj3 = ~gb_dout_phase[1:0];

reg sclr_frm_err_r = 1'b0;
reg [NUM_VLANE-1:0] frm_err = {NUM_VLANE{1'b0}};
generate
        for (i=0; i<WORDS; i=i+1) begin : flp
                wire local_frm_err = ~^gb_dout[i*66+1:i*66];
                always @(posedge clk) begin
                        if (sclr_frm_err_r) begin
                                frm_err [(i+1)*2-1:i*2] <= 2'h0;
                        end
                        else begin
                                frm_err [(i+1)*2-1:i*2] <= 
                                        frm_err [(i+1)*2-1:i*2] | 
                                        ({2{local_frm_err}} & gb_dout_phase[1:0]);
                        end
                end
        end
endgenerate
assign frm_err_out = frm_err;

//////////////////////////////////////////////
// monitor for words that resemble alignment markers (A/~A)

reg [NUM_VLANE-1:0] opposite_ping = {NUM_VLANE{1'b0}};
generate
        for (i=0; i<WORDS; i=i+1) begin : olp
                wire opp_ping;
                wire [65:0] local_gb_dout = gb_dout[(i+1)*66-1:i*66];
                opposite_36 #(.TARGET_CHIP(TARGET_CHIP))op (
                        .clk(clk),
                        .din_a({3'b000,local_gb_dout[33:2],1'b1}),  // restrict to recognizing control words
                        .din_b({3'b111,local_gb_dout[65:34],local_gb_dout[1]}),
                        .opp(opp_ping)
                );
/*
                reg [3:0] am_r; 
                reg       am_r2, am_r3;
                always @(posedge clk) begin
                        am_r[0] <= local_gb_dout[25:2] == 24'h477690;
                        am_r[1] <= local_gb_dout[25:2] == 24'he6c4f0;
                        am_r[2] <= local_gb_dout[25:2] == 24'h9b65c5;
                        am_r[3] <= local_gb_dout[25:2] == 24'h3d79a2;
                        am_r2   <= | am_r;
                        am_r3   <= am_r2;
                end
*/
        
                // adjusted for the dout->opp_ping latency which is 3
                always @(posedge clk) begin
                        //opposite_ping [(i+1)*2-1:i*2] <= {2{opp_ping}}  & {2{am_r3}} & gb_dout_phase_adj3[1:0];
                        opposite_ping [(i+1)*2-1:i*2] <= {2{opp_ping}} & gb_dout_phase_adj3[1:0];
                end
        end
endgenerate
assign opp_ping_out = opposite_ping;

//////////////////////////////////////////////
// lock onto the alignment cycle of vlane 0

wire vlz_lock, vlz_predict,vlz_leading;
alt_aeu_40_interval_timer #(.TARGET_CHIP(TARGET_CHIP), .CNTR_BITS(17), .WRAP_VAL((1 << AM_CNT_BITS) * 2 - 2)) it (
        .clk(clk),
        .suggest_pulse(opposite_ping[0]),
        .locked(vlz_lock),
        .predict_pulse(vlz_predict),
        .lead_pulse(vlz_leading)
);

//////////////////////////////////////////////
// alignment tag capture from the RX gearbox

reg sclr_cap = 1'b0;
reg [1:0] cap_from = 2'b0;
reg [7:0] cap_raddr = 8'b0;
wire [15:0] cap_dout;

// select which of the 4 dout channels to caputre
// pull a few gb bits
reg [4:0] gb_mux = 0;
always @(posedge clk) begin
        case (cap_from) 
                2'b00: gb_mux <= {gb_dout[66*0+9],gb_dout[66*0+8],gb_dout[66*0+6],gb_dout[66*0+5],gb_dout[66*0+4]};
                2'b01: gb_mux <= {gb_dout[66*1+9],gb_dout[66*1+8],gb_dout[66*1+6],gb_dout[66*1+5],gb_dout[66*1+4]};
        endcase
end

// translate selected bits to vlane id
wire [4:0] vlane_num;
alt_aeu_40_vlane_id #(.TARGET_CHIP(TARGET_CHIP))vid (
        .clk(clk),
        .din(gb_mux),
        .vlane(vlane_num[2:0])
);
assign vlane_num[4:3] = 2'b0;

wire [4:0] vlane_num_lag;
delay_regs #(.WIDTH(3),.LATENCY(3)) dr7 (
        .clk(clk),
        .din(vlane_num[2:0]),
        .dout(vlane_num_lag[2:0])
);

assign vlane_num_lag[4:3] = 2'b0;

// select the desired opposite ping set
reg [4:0] op_mux = 5'b0;
always @(posedge clk) begin
        case (cap_from) 
                2'b00: op_mux <= opposite_ping[0*2+1:0*2+0];
                2'b01: op_mux <= opposite_ping[1*2+1:1*2+0];
        endcase
end

reg [5:0] cap_extra = 6'b0 /* synthesis preserve */; 

always @(posedge clk) begin
        cap_extra <= {vlz_predict,5'b0};
        //cap_extra <= {vlz_predict & vlz_lock,5'b0};
end

// this needs to present as a register for the MLab
wire [15:0] cap_mux_reg = {cap_extra,op_mux,vlane_num_lag};

generate 
   if (SYNOPT_FULL_SKEW) begin : gcap1
       capture_m20k #(.TARGET_CHIP(TARGET_CHIP), .WIDTH(16), .ADDR_WIDTH(8)) cap ( 
        .clk(clk),
        .sclr(sclr_cap),
        .trigger(vlz_predict),
        .din_reg(cap_mux_reg),
        
        .raddr(cap_raddr),
        .dout(cap_dout)         
       );
   end
   else begin : gcap2
       alt_aeu_40_capture #(.TARGET_CHIP(TARGET_CHIP)) cap ( 
           .clk(clk),
           .sclr(sclr_cap),
           .trigger(vlz_predict),
           .din_reg(cap_mux_reg),
        
           .raddr(cap_raddr[3:0]),
           .dout(cap_dout)              
       );
   end
endgenerate

//////////////////////////////////////////////
// descramble

wire [WORDS*2-1:0] gb_frame_lag;
wire [WORDS*64-1:0] gb_data;

eth_unframe #(.WORDS(WORDS), .LATENCY(1)) uf (
        .clk(clk),
        .din(gb_dout),
        .dout_frame_lag(gb_frame_lag),
        .dout_data(gb_data)     
);

// figure out when to stop descram for alignment markers
reg vlz_leading_r = 1'b0;
reg dsc_skip = 1'b0;
always @(posedge clk) begin
        vlz_leading_r  <= vlz_leading;
        dsc_skip <= vlz_leading || vlz_leading_r;
end

wire [WORDS*64-1:0] dsc_data;

descrambler_wys #(
		.WIDTH(WORDS*64),
		.TARGET_CHIP(TARGET_CHIP)
)dsc
(
        .clk(clk),
        .skip(dsc_skip),
        .din(gb_data),
        .dout(dsc_data)
);


wire [WORDS*66-1:0] dsc_dout;
eth_reframe #(.WORDS(WORDS)) rf (
        .din_data(dsc_data),
        .din_frame(gb_frame_lag),
        .dout(dsc_dout) 
);

reg dsc_data_am = 1'b0;
always @(posedge clk) begin
        dsc_data_am <= dsc_skip;
end

 // ____________________________________________________________________________
 //     High BER detection module. This has been tied to the LINK_FAULT_EN 
 //     so this synthesis option must be visible to customer in the GUI
 //     for the PHY_ONLY option as well.
 //             -- ajay
 // ____________________________________________________________________________

// reset syncer
wire rst_sync_rxclk; 
aclr_filter reset_syncer_rxclk(
        .aclr     (rst_async), // global reset, async, no domain
        .clk      (clk),     
        .aclr_sync(rst_sync_rxclk)
);
   
reg  insert_lblock = 1'b0;
generate
   if (EN_LINK_FAULT) 
       begin : glf1
          localparam BER_INVALID_CNT = 7'd97;  // this is for BER invalid syn header threshold
          localparam BER_CYCLE_CNT = 21'd390625;  // this is for 500us cycles in 390.625 Mhz
          alt_aeu_40_pcs_ber pcs_ber
                (
                .rstn                   (!rst_sync_rxclk), // Active low Reset, only global reset can clean link status, reset_async_sync, 100MHZ
                .clk                    (clk),             // Clock
                .bypass_ber             (1'b0),            // Bypass BER Monitoring
                .align_status_in        (fully_aligned),
                .data_in_valid          (1'b1),
                .rx_blocks              (dsc_dout),
                .rxus_timer_window      (BER_CYCLE_CNT),   //MDIO for xus timer counter. 40G is 390625. 100G is 156250
                .rbit_error_total_cnt   (BER_INVALID_CNT), // MDIO for BER count. 40G/100G is 97.
                .hi_ber                 (hi_ber)           // Indicates High BER detected
                );

        end
   else begin
                assign hi_ber = 1'b0;
        end
endgenerate

always @(posedge clk) insert_lblock <= (hi_ber || !fully_aligned);

//////////////////////////////////////////////
// block decode

generate
        for (i=0; i<2; i=i+1) begin : dlp
                alt_aeu_40_sane_block_decode #(.TARGET_CHIP(TARGET_CHIP)) ed (
                        .clk(clk), 
                        .insert_lblock(insert_lblock),
                        .block(dsc_dout[(i+1)*66-1:i*66]), // bit 0 first
                        .mii_txc(dout_c[(i+1)*8-1:i*8]),
                        .mii_txd(dout_d[(i+1)*64-1:i*64]) // bit 0 first        
                );
        end
endgenerate

reg ed_am0 = 1'b0;
reg dout_am_r = 1'b0;
always @(posedge clk) begin
        ed_am0 <= dsc_data_am;
        dout_am_r <= ed_am0;
end
assign dout_am = dout_am_r;


//////////////////////////////////////////////
// control processor

wire st_sclr = sclr;

wire [15:0] from_proc;
reg [15:0] to_proc = 0;
wire [11:0] from_addr;
wire from_proc_valid;

generate
    if (SYNOPT_FULL_SKEW) begin: gsta1
        stacker2 #(
		.TARGET_CHIP(TARGET_CHIP),
		.SIM_EMULATE(SIM_EMULATE),
		.RAM_ADDR(13),
		.PROG_NAME("alt_aeu_40_rx_pcs_2_full_skew.hex"),
		.INIT_NAME("alt_aeu_40_rx_pcs_2_full_skew.init")
		)
		st (
            .clk(clk),
            .sclr(st_sclr),
            .main_ram_ena(stacker_ram_ena),
        
            .io_rdata(to_proc),
            .io_wdata(from_proc),
            .io_waddr(from_addr),
            .io_we(from_proc_valid)
        );
    end
    else begin: gsta2
        stacker2 #(
		.TARGET_CHIP(TARGET_CHIP),
		.SIM_EMULATE(SIM_EMULATE),
		.PROG_NAME("alt_aeu_40_rx_pcs_2.hex"),
		.INIT_NAME("alt_aeu_40_rx_pcs_2.init")
		)
		st (
            .clk(clk),
            .sclr(st_sclr),
            .main_ram_ena(stacker_ram_ena),
        
            .io_rdata(to_proc),
            .io_wdata(from_proc),
            .io_waddr(from_addr),
            .io_we(from_proc_valid)
        );
    end
endgenerate

// address map (decimal)
// 1 get key
// 2 emit key
// 4 cpu halt notice

// 8 set wpos[5],bpos[6]  lane 0
// 9 set wpos[5],bpos[6]  lane 1
// ..
// 27 set wpos[5],bpos[6]  lane 19

// 31 wipe out reordering
// 32 set rosel entry layer 0
// 33 set rosel entry layer 1
// 34 set rosel entry layer 2
// 35 set rosel entry layer 3
// 36 set rosel entry layer 4

// 37 set rosel mid layer 0
// 38 set rosel mid layer 1
// 39 set rosel mid layer 2
// 40 set rosel mid layer 3

// 41 set rosel exit layer 0
// 42 set rosel exit layer 1
// 43 set rosel exit layer 2
// 44 set rosel exit layer 3
// 45 set rosel exit layer 4

// 47 clear frm_err
// 48 get frm_err low
// 49 get frm_err high
// 50 get capture dout
// 51 set capture address
// 52 sclr capture
// 53 set cap_from
// 54 set fully_aligned

reg [15:0] from_proc_r = 16'h0;
always @(posedge clk) from_proc_r <= from_proc;

always @(posedge clk) begin
    byte_to_jtag_valid <= 1'b0;
    byte_from_jtag_ack <= 1'b0;
    if (from_proc_valid && from_addr[5:0] == 6'd2) begin
        byte_to_jtag <= from_proc[7:0];
        byte_to_jtag_valid <= 1'b1;
    end
    if (from_proc_valid && from_addr[5:0] == 6'd1) begin
        to_proc <= 16'd0;
        to_proc <= byte_from_jtag;
        byte_from_jtag_ack <= 1'b1;
    end
    
    if (from_proc_valid && from_addr[5:0] == 6'd48) begin
        to_proc <= frm_err[3:0];                
    end
    if (from_proc_valid && from_addr[5:0] == 6'd49) begin
        to_proc <= 0; //frm_err[3:0];                
    end
    if (from_proc_valid && from_addr[5:0] == 6'd50) begin
        to_proc <= cap_dout;                
    end    
end

reg [NUM_VLANE-1:0] load_wb = {NUM_VLANE{1'b0}};
generate
    for (i=0; i<NUM_VLANE; i=i+1) begin : lp
        always @(posedge clk) begin
            load_wb[i] <= (from_proc_valid && from_addr[5:0] == (i+8));
        end
    end
endgenerate

reg [13:0] load_ro = 13'b0;
generate
    for (i=0; i<14; i=i+1) begin : lp0
        always @(posedge clk) begin
            load_ro[i] <= (from_proc_valid && from_addr[5:0] == (i+32));
        end
    end
endgenerate

// word and bit position controls
generate 
    for (i=0; i<NUM_VLANE; i=i+1) begin : lp1
        always @(posedge clk) begin
            if (load_wb[i]) begin
                {wpos[(i+1)*WPOS_BITS-1:i*WPOS_BITS],bpos[(i+1)*6-1:i*6]} <= from_proc_r[WPOS_BITS-1+6:0];
            end
        end
    end
endgenerate

reg wipe_ro_sel = 1'b0;
// lane reordering controls - entry layer
generate
    for (i=0; i<5; i=i+1) begin : lp2
        always @(posedge clk) begin
            if (load_ro[i]) ro_sels[(i+1)*8-1:i*8] <= from_proc_r[7:0];
            if (wipe_ro_sel) ro_sels[(i+1)*8-1:i*8] <= 8'b11100100;
        end
    end
endgenerate

// lane reordering controls - middle layer
generate 
    for (i=5; i<9; i=i+1) begin : lp2b
        always @(posedge clk) begin
            if (load_ro[i]) ro_sels[(i-5+1)*15-1+40:(i-5)*15+40] <= from_proc_r[14:0];
            if (wipe_ro_sel) ro_sels[(i-5+1)*15-1+40:(i-5)*15+40] <= 15'b100011010001000;
        end
    end
endgenerate

// lane reordering controls - exit layer
generate 
    for (i=9; i<14; i=i+1) begin : lp2c
        always @(posedge clk) begin
            if (load_ro[i]) ro_sels[(i-9+1)*8-1+100:(i-9)*8+100] <= from_proc_r[7:0];
            if (wipe_ro_sel) ro_sels[(i-9+1)*8-1+100:(i-9)*8+100] <= 8'b11100100;
        end
    end
endgenerate

// misc controls
reg load_cap_addr = 1'b0;
reg load_cap_from = 1'b0;
reg load_fully_aligned = 1'b0;
reg sclr_frm_err_cpu = 1'b0;

always @(posedge clk) begin
    wipe_ro_sel <= (from_proc_valid && from_addr[5:0] == 6'd31);
    load_cap_addr <= (from_proc_valid && from_addr[5:0] == 6'd51);
    sclr_cap <= (from_proc_valid && from_addr[5:0] == 6'd52);
    load_cap_from <= (from_proc_valid && from_addr[5:0] == 6'd53);
    load_fully_aligned <= (from_proc_valid && from_addr[5:0] == 6'd54);
    sclr_frm_err_cpu <= (from_proc_valid && from_addr[5:0] == 6'd47);

    if (load_cap_from) cap_from <= from_proc_r[1:0];
    //if (load_cap_addr) cap_raddr <= from_proc_r[4:0];
    if (load_cap_addr) cap_raddr <= from_proc_r[7:0]; // SKEW
    if (load_fully_aligned) fully_aligned <= from_proc_r[0];
    if (sclr) fully_aligned <= 1'b0;
    
    sclr_frm_err_r <= sclr_frm_err | sclr_frm_err_cpu;
end

assign dsk_depths = SYNOPT_FULL_SKEW ? wpos[35:0] : {16'b0, wpos[19:0]};

endmodule


// BENCHMARK INFO :  5SGXEA7N2F45C2ES
// BENCHMARK INFO :  Max depth :  2.6 LUTs
// BENCHMARK INFO :  Total registers : 7220
// BENCHMARK INFO :  Total pins : 50
// BENCHMARK INFO :  Total virtual pins : 608
// BENCHMARK INFO :  Total block memory bits : 65,536
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.179 ns, From sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|irsr_reg[0], To sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|tdo}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.228 ns, From sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|virtual_ir_scan_reg, To sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|tdo}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.085 ns, From sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|virtual_ir_scan_reg, To sld_hub:auto_hub|sld_jtag_hub:\jtag_hub_gen:sld_jtag_hub_inst|tdo}

