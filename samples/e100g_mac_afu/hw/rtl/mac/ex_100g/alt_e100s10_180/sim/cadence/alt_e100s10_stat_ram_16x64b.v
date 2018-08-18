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


// $Id: $
// $Revision: $
// $Date: $
// $Author: $
//-----------------------------------------------------------------------------

// baeckler - 02-22-2012
`timescale 1ps / 1ps

// CONFIDENCE
// This has been used in multiple contexts for network statistics
//

module alt_e100s10_stat_ram_16x64b #(
    parameter INC_WIDTH = 4,  // width of integer increment, serviced every cycle
    parameter ACCUM_WIDTH = 8, // accumulator holds up to 32 cycles of increments
    parameter NUM_CHAN = 16,  // no override for this param
    parameter TARGET_CHIP = 5, // 1 S4, 2 S5
    parameter DISABLE_PARITY = 1'b1,
    parameter SIM_EMULATE    = 1'b0
)(
    input clk,
    input sclr, // needs to be held at 1 for ~32 cycles for effect
    input [INC_WIDTH*NUM_CHAN-1:0] incs,

    // read port, 0: 0lo, 1:0hi, 2:1lo, 3:1hi ...
    input [4:0] rd_addr,
    output [31:0] rd_value,
    input shadow_req,
    output shadow_grant,

    input sclr_parity_err,
    output parity_err   // sticky, errors at startup normal
);


genvar i;

//-------------------------------
/*
// linhua: for simulation;
// synthesis translate_off
initial begin
	wait (clk);
	#2000000;
	force sclr = 1'b1;
	#200000;
	release sclr;
end
// synthesis translate_on
*/
//-------------------------------
///////////////////////////////////////////////////////
// 1st layer small accumulators

//reg sclr_local = 1'b0 /* synthesis preserve_syn_only */;
reg [2:0] sclr_local /* synthesis preserve_syn_only */;
always @(posedge clk) begin
    sclr_local <= {3{sclr}};
end

wire [NUM_CHAN*ACCUM_WIDTH-1:0] accum;
reg [NUM_CHAN-1:0] load_accum = {NUM_CHAN{1'b0}};

generate
    for (i=0; i<NUM_CHAN; i=i+1) begin : al
        reg [ACCUM_WIDTH-1:0] local_acc = {ACCUM_WIDTH{1'b0}};
        wire [INC_WIDTH-1:0] local_inc = incs[(i+1)*INC_WIDTH-1:i*INC_WIDTH];
	wire sclr_local_l;
	assign sclr_local_l = (i < (NUM_CHAN>>1)) ? sclr_local[0] : sclr_local[2];

        always @(posedge clk) begin
            if (sclr_local_l) begin
                local_acc <= {ACCUM_WIDTH{1'b0}};
            end
            else begin
                if (load_accum[i]) begin
                    local_acc <= local_inc;
                end
                else begin
                    local_acc <= local_acc + local_inc;
                end
            end
        end
        assign accum[(i+1)*ACCUM_WIDTH-1:i*ACCUM_WIDTH] = local_acc;
    end
endgenerate

///////////////////////////////////////////////////////
// RAM storage

reg [4:0] waddr = 5'b0 /* synthesis preserve_syn_only */;
reg [4:0] raddr = 5'b0 /* synthesis preserve_syn_only */;
wire [31:0] wdata;
wire [31:0] rdata;

// storage word allocation as follows - where they landed in the pipeline
// addr 1: cntr 14 high
// addr 2: cntr 0 low
// addr 3: cntr 15 high
// addr 4: cntr 1 low
// addr 5: cntr 0 high
// addr 6: cntr 2 low
// addr 7: cntr 1 high
// addr 8: cntr 3 low

wire parity_err_main;
alt_e100s10_mlab_32word_32bit rm (
    .clk(clk),
    .wena(1'b1),
    .waddr_reg(waddr),
    .wdata(wdata),
    .raddr(raddr),
    .rdata(rdata),

    .sclr_parity_err(sclr_parity_err),
    .parity_err(parity_err_main)
);
defparam rm .TARGET_CHIP = TARGET_CHIP;
defparam rm .SIM_EMULATE = SIM_EMULATE;

// constantly cycle through the RAM addressing, read, compute and write back
always @(posedge clk) begin
    waddr <= waddr + 1'd1;
    raddr <= waddr + 3'd4; // yes based on waddr, not independent
end

// clear the accumulators at the proper time
generate
    for (i=0; i<NUM_CHAN; i=i+1) begin :la
        always @(posedge clk) begin
            load_accum[i] <= raddr[0] && (raddr[4:1] == ((i-1)&4'hf));
        end
    end
endgenerate

///////////////////////////////////////////////////////
// Select the next accumulator to read

wire [ACCUM_WIDTH-1:0] sel_accum;
alt_e100s10_mx16r mx (
    .clk(clk),
    .din(accum),
    .sel(raddr[4:1]),
    .dout(sel_accum)
);
defparam mx .WIDTH = ACCUM_WIDTH;

///////////////////////////////////////////////////////
// handle the additions, alternating accum and carry

reg [32:0] local_adder;
//wire [32:0] local_adder = sclr_local[1] ? 33'h0 : local_adder_t;
reg [ACCUM_WIDTH-1:0] val_to_add = {ACCUM_WIDTH{1'b0}};

always @(posedge clk) begin
    //local_adder_t <= (rdata + val_to_add);
    local_adder <= sclr_local[1] ? 33'h0 : (rdata + val_to_add);
end

reg [2:0] last_cout = 3'b0;

always @(posedge clk) begin
    last_cout <= {last_cout[1:0],local_adder[32]};
    val_to_add <= raddr[0] ? {ACCUM_WIDTH{1'b0}} | last_cout[0] : sel_accum;
end

assign wdata = local_adder[31:0];

///////////////////////////////////////////////////////
// figure out where it is safe to shadow

// this produces a 4 cycle pulse over an atomic set of view_wdata words
wire exposed_carry = local_adder[32] | (|last_cout) ;

reg shadow_req_r = 1'b0;
always @(posedge clk) begin
    shadow_req_r <= shadow_req;
end

reg shadow_grant_r = 1'b0;
always @(posedge clk) begin
    if (shadow_grant_r) begin
        // release at will
        if (!shadow_req_r) shadow_grant_r <= 1'b0;
    end
    else begin
        // only grant if there are no partially executed carrys
        if (shadow_req_r && !exposed_carry) shadow_grant_r <= 1'b1;
    end
end
assign shadow_grant = shadow_grant_r;

///////////////////////////////////////////////////////
// undo the funny storage addressing for viewing

wire [31:0] view_wdata = wdata;
reg [4:0] view_waddr = 5'h0 /* synthesis preserve_syn_only */;
wire view_wena = !shadow_grant_r;

always @(posedge clk) begin
    case (waddr)
        5'd0 : view_waddr <= 5'd29;
        5'd1 : view_waddr <= 5'd0;
        5'd2 : view_waddr <= 5'd31;
        5'd3 : view_waddr <= 5'd2;
        5'd4 : view_waddr <= 5'd1;
        5'd5 : view_waddr <= 5'd4;
        5'd6 : view_waddr <= 5'd3;
        5'd7 : view_waddr <= 5'd6;
        5'd8 : view_waddr <= 5'd5;
        5'd9 : view_waddr <= 5'd8;
        5'd10 : view_waddr <= 5'd7;
        5'd11 : view_waddr <= 5'd10;
        5'd12 : view_waddr <= 5'd9;
        5'd13 : view_waddr <= 5'd12;
        5'd14 : view_waddr <= 5'd11;
        5'd15 : view_waddr <= 5'd14;
        5'd16 : view_waddr <= 5'd13;
        5'd17 : view_waddr <= 5'd16;
        5'd18 : view_waddr <= 5'd15;
        5'd19 : view_waddr <= 5'd18;
        5'd20 : view_waddr <= 5'd17;
        5'd21 : view_waddr <= 5'd20;
        5'd22 : view_waddr <= 5'd19;
        5'd23 : view_waddr <= 5'd22;
        5'd24 : view_waddr <= 5'd21;
        5'd25 : view_waddr <= 5'd24;
        5'd26 : view_waddr <= 5'd23;
        5'd27 : view_waddr <= 5'd26;
        5'd28 : view_waddr <= 5'd25;
        5'd29 : view_waddr <= 5'd28;
        5'd30 : view_waddr <= 5'd27;
        5'd31 : view_waddr <= 5'd30;
    endcase
end

wire parity_err_view;
alt_e100s10_mlab_32word_32bit vw (
    .clk(clk),
    .wena(view_wena),
    .waddr_reg(view_waddr),
    .wdata(view_wdata),
    .raddr(rd_addr),
    .rdata(rd_value),

    .sclr_parity_err(sclr_parity_err),
    .parity_err(parity_err_view)
);
defparam vw .TARGET_CHIP = TARGET_CHIP;
defparam vw .SIM_EMULATE = SIM_EMULATE;

reg any_parity = 1'b0;
always @(posedge clk) begin
    any_parity <= parity_err_view || parity_err_main;
end
assign parity_err = any_parity;

endmodule


// BENCHMARK INFO :  10AX115R3F40I2SGES
// BENCHMARK INFO :  Quartus II 64-Bit Version 14.0a10s.0 Build 530 07/17/2014 SJ Full Version
// BENCHMARK INFO :  Uses helper file :  alt_stat_ram_16x64b.v
// BENCHMARK INFO :  Uses helper file :  mlab_32word_32bit.v
// BENCHMARK INFO :  Uses helper file :  alt_a10mlab.v
// BENCHMARK INFO :  Uses helper file :  alt_mx16r.v
// BENCHMARK INFO :  Uses helper file :  alt_mx4r.v
// BENCHMARK INFO :  Total registers : 376
// BENCHMARK INFO :  Total pins : 107
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :  366
// BENCHMARK INFO :  ALMs : 243 / 427,200 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.081 ns, From alt_mlab_32word_32bit:vw|alt_a10mlab:m1|ml[18].lrm~reg1, To rd_value[30]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.132 ns, From alt_mlab_32word_32bit:vw|alt_a10mlab:m0|ml[12].lrm~reg1, To rd_value[4]}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 0.094 ns, From alt_mlab_32word_32bit:vw|alt_a10mlab:m0|ml[10].lrm~reg1, To rd_value[2]}
