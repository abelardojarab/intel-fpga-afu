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



// S10 100G word alignment 
// monitor and control logic
// Faisal Khan
// 10/29/2016

`timescale 1ps/1ps
module alt_e100s10_wamon #(
    parameter   SIM_EMULATE = 1'b0
) (
    input               clk,
    input               reset,
    input               sticky_err_clr,
    input   [5*2-1:0]   din,
    input               any_valid, // any valid - should always be 1
    input   [2:0]       schd, // din_hv is a function of schd
    output  reg [7*5-1:0]   delay,
    output  reg         walock,
    output  reg [4:0]   locked_lanes,
    output  reg [4:0]   sticky_err,
    output              ready,
    output  reg         purge_align

);

reg in_valid, in_valid_c2, in_valid_c3;
always @(posedge clk) begin // CC-1,2, 3
    in_valid    <=  any_valid;
    in_valid_c2 <=  in_valid;
    in_valid_c3 <=  in_valid_c2;
end

reg wena, wena_c2 ;   // CC-1-6
wire reset_pulse;
reg [3:0] wena_d;
always @(posedge clk) begin 
    wena    <=  any_valid ;
    wena_c2 <=  wena   | reset | reset_pulse;
    wena_d  <=  {wena_d[2:0], wena_c2};
end

reg [2:0] waddr, waddr_c2, waddr_c3, waddr_c4, waddr_c5, waddr_c6;  
always @(posedge clk) begin //CC-2
    if (reset | waddr[2])  begin
        waddr   <=  3'h0;
    end else if (wena_d[3] | reset_pulse) begin
        waddr   <=  waddr + 1'b1;
    end
    waddr_c2    <=  waddr;
    waddr_c3    <=  waddr_c2;
    waddr_c4    <=  waddr_c3;
    waddr_c5    <=  waddr_c4;
    waddr_c6    <=  waddr_c5;

end


// count the window of 1024
wire [9:0] tcnt;
reg inc_tcnt = 1'b0;
alt_e100s10_cnt10ic ct0 (  // Regenerate this   
    .clk(clk),
    .sclr(reset),
    .inc(inc_tcnt),
    .dout(tcnt)
);
defparam ct0 .SIM_EMULATE = SIM_EMULATE;

wire tcnt_ping;
alt_e100s10_and11t2 c0 (   
    .clk(clk),
    .din({1'b1,tcnt}),
    .dout(tcnt_ping)
);
defparam c0 .SIM_EMULATE = SIM_EMULATE;


reg [1:0] hdr;
always @(posedge clk) begin //CC-1
    if (any_valid) begin        // 2 stages? 
        case(schd) 
            3'b000: begin hdr <=  din[1:0]; inc_tcnt <= 1'b0; end
            3'b001: begin hdr <=  din[3:2]; inc_tcnt <= 1'b0; end
            3'b010: begin hdr <=  din[5:4]; inc_tcnt <= 1'b1; end   
            3'b011: begin hdr <=  din[7:6]; inc_tcnt <= 1'b0; end
            3'b100: begin hdr <=  din[9:8]; inc_tcnt <= 1'b0;  end
           default: begin hdr <=  din[1:0]; inc_tcnt <= 1'b0; end
        endcase
    end
end

wire    skip_check;
wire    rd_lock_status, rd_lock_status_w;
reg din_error;
always @(posedge clk) din_error <= (~^hdr) & in_valid; // CC-2

reg slip;
always @(posedge clk) begin 
    if (~skip_check & ~rd_lock_status_w) slip  <=  din_error ;  // CC-3
    else slip <= 1'b0;
end

reg din_error_c3;
always @(posedge clk) din_error_c3 <= din_error;    // CC-3


wire    [6:0]   rd_cnt;
wire    [1:0]   skip_status;
reg     [6:0]   rd_cnt_c4;
wire            rd_stky_err;
reg             stky_err, stky_err_c5;
reg     [6:0]   good_err_cnt;           // stores good/error count based on (pre/post lock) context 



reg     inc_cnt, clr_cnt_0, clr_cnt_1;
wire    lock_acquired  = (~rd_lock_status & rd_cnt[6] & ~slip);
wire    lock_lost      = (rd_lock_status & rd_cnt[6] & din_error_c3);
wire    unlocked_error = (~rd_lock_status & slip);
wire    window_reset   = (rd_lock_status & tcnt_ping);
always @(posedge clk) begin // CC-4
    inc_cnt   <= (~rd_lock_status & ~slip) | (rd_lock_status & din_error_c3);
    clr_cnt_0 <= lock_acquired | window_reset;       
    clr_cnt_1 <= lock_lost | unlocked_error | reset;
    rd_cnt_c4 <= rd_cnt;
end

always @(posedge clk) begin  // CC-5 
    if (clr_cnt_0)
        good_err_cnt    <=  6'h0;
    else if (clr_cnt_1)
        good_err_cnt    <=  6'h1;
    else if (inc_cnt)
        good_err_cnt    <=  rd_cnt_c4 + 1'b1;
    else 
        good_err_cnt    <=  rd_cnt_c4; 
end


// sticky error generation logic
// internally clear stky error on acquiring lock 
reg [1:0]  stky_clr_cnt;
reg        stky_clr_pulse, sticky_err_clr_int;
reg wlock_i ;

always @(posedge clk)   sticky_err_clr_int  <=  (wlock_i & ~walock & inc_tcnt) | sticky_err_clr | reset;

always @(posedge clk) begin
    if (sticky_err_clr_int) begin
        stky_clr_cnt    <=  2'h0;
        stky_clr_pulse  <=  1'b1;
    end else if (stky_clr_cnt != 2'b11 & wena) begin
        stky_clr_cnt <= stky_clr_cnt + 1'b1;
        stky_clr_pulse  <=  1'b1;
    end else 
        stky_clr_pulse  <=  1'b0;
end


always @(posedge clk) begin // CC-4 
    stky_err    <= (din_error_c3 | rd_stky_err) & (~sticky_err_clr_int & ~stky_clr_pulse);
end


reg lock_status, lock_status_c5;
always @(posedge clk) begin // CC-4 from CC-3
    
    if (~rd_lock_status & rd_cnt[6] & ~slip & in_valid_c3) 
        lock_status <=  1'b1 ;
    else if (rd_lock_status & rd_cnt[6] & din_error_c3 & in_valid_c3 | reset_pulse)
        lock_status <=  1'b0;
    else
        lock_status <=  rd_lock_status;

end

reg [4:0]   lock_status_w;
always @(posedge clk) begin
    if (reset)
        lock_status_w    <=  4'h0;
    else
        lock_status_w   <=  {lock_status_w[3:0], lock_status};
end

always  @(posedge clk) begin
    if (inc_tcnt)
        locked_lanes    <=  lock_status_w;
end

always @(posedge clk) begin
    if (reset)
        wlock_i <=  1'b0;
    else if (inc_tcnt)
        wlock_i <=  lock_status;
    else
        wlock_i <=  wlock_i & lock_status;
end

initial walock = 1'b0;
always @(posedge clk) begin
    if (inc_tcnt)    walock  <=  wlock_i;
end

// output shift generation logic
wire [3:0]  rd_bitshifts;
wire [2:0]  rd_wdelay;
reg  [3:0]  bitshifts ;
reg  [3:0]  bitshifts_c5;
reg  [2:0]  wd_delay ;
reg  [2:0]  wd_delay_c5;
wire        shift_max;
reg  [1:0]  skip_c4;
always @(posedge clk) begin // CC-4 from CC-3
    if (rd_bitshifts == 4'd12 & shift_max & slip) begin
        bitshifts    <=  4'd0;
        wd_delay     <=  rd_wdelay + 1'b1;
        skip_c4      <=  2'b11;
    end else if (rd_bitshifts == 4'd13 & slip) begin
        bitshifts    <=  4'd0;
        wd_delay     <=  rd_wdelay + 1'b1;
        skip_c4      <=  2'b11;
    end else if (slip) begin
        bitshifts    <=  rd_bitshifts + 1'b1;
        wd_delay     <=  rd_wdelay;
        skip_c4      <=  2'b11;
    end
    else begin
        bitshifts    <=  rd_bitshifts;
        wd_delay     <=  rd_wdelay;
        skip_c4      <=  {1'b0, skip_status[1]};
    end
 end

initial delay = {5{3'h2, 4'h0}}; 
always @(posedge clk) begin // CC-5 from CC-4
    case (schd) // aligned with new schedule
        3'b000: delay[1*7+:7] <=  {wd_delay, bitshifts};
        3'b001: delay[2*7+:7] <=  {wd_delay, bitshifts};
        3'b010: delay[3*7+:7] <=  {wd_delay, bitshifts};
        3'b011: delay[4*7+:7] <=  {wd_delay, bitshifts};
        3'b100: delay[0*7+:7] <=  {wd_delay, bitshifts};
        default:delay[34:0]   <=  {5{3'h0, 4'h0}};
    endcase
end


reg shift_max_w; // max shifts occurred for this vl
// since we are processing in pieline - the first VL pass is 14-bits
reg shift_max_c5;
always @(posedge clk) begin
    if (rd_wdelay == 3'h0)
        shift_max_w <=  1'b0;
    else 
        shift_max_w <=  1'b1;
end


// Context memory
reg [19:0] wdata;
wire [19:0] rdata_w;
alt_e100s10_mlab cntxt (
    .wclk       (clk),
    .wena       (wena_d[3]),
    .waddr_reg  ({1'b0, waddr_c6}),
    .wdata_reg  (wdata),
    .raddr      ({1'b0, waddr_c2}),
    .rdata      (rdata_w) // CC-2
);
defparam cntxt .WIDTH = 20;
defparam cntxt .ADDR_WIDTH = 4;
defparam cntxt .SIM_EMULATE = SIM_EMULATE;

reg [19:0]  rdata;
always @(posedge clk) begin   // CC-2, 3 
    rdata <=  rdata_w;
end

assign  skip_check  = rdata_w[8];
assign  rd_lock_status_w  = rdata_w[0];
assign  rd_lock_status = rdata[0];  
assign  rd_cnt  = rdata[1+:7];
assign  skip_status = rdata[9:8];
assign  rd_stky_err = rdata[10];
assign  rd_bitshifts = rdata[11+:4];
assign  shift_max   = rdata[15];
assign  rd_wdelay  = rdata[16+:3];

alt_e100s10_pulse4 p1 (
    .clk    (clk),
    .din    (reset),
    .dout   (reset_pulse)
);
defparam p1 .SIM_EMULATE = SIM_EMULATE; 

reg reset_pulse_d1, reset_pulse_d2;
always @(posedge clk) reset_pulse_d1  <=  reset_pulse;
always @(posedge clk) reset_pulse_d2  <=  reset_pulse_d1;

reg [1:0] skip_c5;
always @(posedge clk) begin

    bitshifts_c5    <=  bitshifts;
    wd_delay_c5     <=  wd_delay;
    shift_max_c5    <=  shift_max_w;
    lock_status_c5  <=  lock_status;
    stky_err_c5     <=  stky_err;
    skip_c5         <=  skip_c4;
end


// Watch-dog logic
reg         tcnt_ping_d1;
reg [1:0]   iterations;
always @(posedge clk) begin
    tcnt_ping_d1    <=  tcnt_ping;
    if (reset)     
        iterations  <=  2'b00;
    else if (tcnt_ping & ~tcnt_ping_d1 & ~walock)
        iterations  <= iterations + 1'b1;
end
always @(posedge clk) purge_align   <=  &iterations;


// {lock status, error count, skip, sticky error, bitshifts, shift_max}
// 3+1+4+1+1+8+1
always @(posedge clk) begin // CC-6 from CC-4
    if (reset | reset_pulse_d2) 
        wdata   <=  {1'b0, 3'h0, 6'h0, 2'b11, 8'h0};
    else
        wdata   <=  {1'b0, wd_delay_c5, shift_max_c5, bitshifts_c5, stky_err_c5, skip_c5, good_err_cnt, lock_status_c5};
end


// output assignments
reg [4:0] sticky_err_r; 
always @(posedge clk) begin if(any_valid)  sticky_err_r <=  { stky_err, sticky_err_r[4:1] }; end
always @(posedge clk)  begin if (reset_pulse_d2) sticky_err <= 5'h0; 
else if (inc_tcnt) sticky_err  <=  sticky_err_r; 
end

assign  ready = ~reset_pulse_d2;

endmodule
