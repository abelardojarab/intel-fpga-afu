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



// baeckler - 08-26-2010

// FIFO expects that the number of in and out words matches over time
// on powerup, arst, over or underflow it will self purge then back up 
// until wr_almost_empty is false, then resume normal operation

module alt_aeuex_mac_loopback #(
    parameter WORDS = 2,
    parameter WIDTH = 64,
    parameter DEVICE_FAMILY = "Stratix V"
)(
    // no domain
    input arst,
            
    // TX to Ethernet
    input [15:0] high_threshold,
    input [15:0] low_threshold,
    input clk_tx,
    input tx_ack,
    output [WIDTH*WORDS-1:0] tx_data,
    output [WORDS-1:0] tx_start,
    output [WORDS*8-1:0] tx_end_pos,
    output reg underflow,
    
    // RX from Ethernet
    input clk_rx,
    input rx_valid,
    input [WIDTH*WORDS-1:0] rx_data,
    input [WORDS-1:0] rx_start,
    input [WORDS*8-1:0] rx_end_pos,    
    input [7:0] swap_ctrl,
    output reg overflow
);

/////////////////////////////////////
// modify the RX stream if desired



wire rx_valid_i;
wire [WIDTH*WORDS-1:0] rx_data_i;
wire [WORDS-1:0] rx_start_i;
wire [WORDS*8-1:0] rx_end_pos_i;    
wire arst_wr;

generate
    if (WORDS == 5) begin : asp5
        reg [7:0] swap_ctrl_r = 0 /* synthesis preserve_syn_only */;
        always @(posedge clk_rx) begin
            swap_ctrl_r <= swap_ctrl;
        end

        alt_e100_addr_swap asp ( 
            // RX from Ethernet
            .arst(arst_wr),
            .clk_rx(clk_rx),
            // controls
            .swap_ipv4_en(swap_ctrl_r[0]),
            .swap_mac_en(swap_ctrl_r[1]),
            .drop_mcast_intf_en(swap_ctrl_r[2]),
            .drop_mcast_router_en(swap_ctrl_r[3]),
            .drop_mcast_all_en(swap_ctrl_r[4]),
            // input signals
            .rx_valid(rx_valid),
            .rx_data(rx_data),
            .rx_start(rx_start),
            .rx_end_pos(rx_end_pos),    
            // signal after swap
            .rx_valid_swap(rx_valid_i),
            .rx_data_swap(rx_data_i),
            .rx_start_swap(rx_start_i),
            .rx_end_pos_swap(rx_end_pos_i)  
            );
			defparam asp .WORDS = WORDS;
			defparam asp .WIDTH = WIDTH;
    end // block: asp5
    else begin : noswap
		// swap not supported
		assign rx_valid_i = rx_valid;
		assign rx_data_i = rx_data;
		assign rx_start_i = rx_start;
		assign rx_end_pos_i = rx_end_pos;
    end // block: asp8
endgenerate

/////////////////////////
// option to stall the TX out

reg [WIDTH*WORDS-1:0] tx_data_i = 0;
reg [WORDS-1:0] tx_start_i = 0;
reg [WORDS*8-1:0] tx_end_pos_i = 0;

wire tx_ack_i;
reg tx_stall_req = 1'b0;
wire tx_stalled;
wire arst_rd;
wire rd_empty;
reg rd_ena = 1'b0;

alt_aeuex_traffic_break tb (
    .clk(clk_tx),
    .arst(arst_rd),
    
    .din(tx_data_i),
    .din_start(tx_start_i),
    .din_end_pos(tx_end_pos_i),
    .din_ack(tx_ack_i),
    .stall_req(tx_stall_req | rd_empty),
    .flush(~tx_stall_req && rd_ena),
    
    .dout(tx_data),
    .dout_start(tx_start),
    .dout_end_pos(tx_end_pos),
    .dout_ack(tx_ack),
    .stalled(tx_stalled)
);
defparam tb .WIDTH = WIDTH;
defparam tb .WORDS = WORDS;

/////////////////////////
// main FIFO

localparam MEM_WIDTH = WORDS * (WIDTH+8+1);
localparam MEM_ADDR = 10;

wire wrreq, rdreq;
wire [MEM_WIDTH-1:0] wrdata, rddata;
wire [MEM_ADDR-1:0] rdusedw, wrusedw;
wire wr_empty,wr_full;
wire wr_almost_empty = ~wr_full & (wrusedw < low_threshold);

 reg steady_state = 1'b0;

always @(posedge clk_tx) begin
    tx_stall_req <= steady_state & wr_almost_empty;
end

wire clk_wr = clk_rx;
wire clk_rd = clk_tx;

dcfifo    dcfifo_component (
    .wrclk (clk_wr),
    .wrreq (wrreq),
    .data (wrdata),
    .wrusedw (wrusedw),
    .wrfull (wr_full),
    
    .rdclk (clk_rd),
    .rdreq (rdreq),
    .rdempty (rd_empty),
    .q (rddata),
    .rdusedw (rdusedw),
    .aclr (1'b0),
    .rdfull (),
    .wrempty (wr_empty)            
);

defparam
    dcfifo_component.intended_device_family = DEVICE_FAMILY,
    dcfifo_component.lpm_hint = "RAM_BLOCK_TYPE=M20K",
    dcfifo_component.lpm_numwords = (1 << MEM_ADDR),
    dcfifo_component.lpm_showahead = "OFF",
    dcfifo_component.lpm_type = "dcfifo",
    dcfifo_component.lpm_width = MEM_WIDTH,
    dcfifo_component.lpm_widthu = MEM_ADDR,
    dcfifo_component.overflow_checking = "ON",
    dcfifo_component.rdsync_delaypipe = 4,
    dcfifo_component.underflow_checking = "ON",
    dcfifo_component.use_eab = "ON",
    dcfifo_component.wrsync_delaypipe = 4;

 reg wr_ena = 1'b0;

assign rdreq = tx_ack_i & rd_ena & ~rd_empty;

reg rd_empty_d = 1'b1;

always @(posedge clk_tx) begin
    if (tx_ack_i) begin
        rd_empty_d <= rd_empty;
        {tx_data_i,tx_start_i,tx_end_pos_i} <= rd_empty_d ? 0 : rddata;
    end
end

assign wrdata = {rx_data_i,rx_start_i,rx_end_pos_i};
assign wrreq = rx_valid_i & wr_ena;    

// stretch user reset to become internal reset
wire arst_internal;

alt_aeuex_sync_arst sync_arst (
    .clk(clk_wr),
    .arst(arst),
    .sync_arst(arst_internal)
);

///////////
// distribute internal reset to domains



alt_aeuex_sync_arst sync_arst_wr (
    .clk(clk_wr),
    .arst(arst_internal),
    .sync_arst(arst_wr)
);

alt_aeuex_sync_arst sync_arst_rd (
    .clk(clk_rd),
    .arst(arst_internal),
    .sync_arst(arst_rd)
);

/////////
// count write ticks for clock to stabilize

reg wr_max = 1'b0;
reg [5:0] wr_cntr = 0 /* synthesis preserve_syn_only */;
always @(posedge clk_wr or posedge arst_wr) begin
    if (arst_wr) begin
        wr_cntr <= 0;
        wr_max <= 1'b0;
    end
    else begin
        if (&wr_cntr) wr_max <= 1'b1;
        else wr_cntr <= wr_cntr + 1'b1;
    end
end

/////////
// count read ticks for clock to stabilize

reg rd_max = 1'b0;
reg [5:0] rd_cntr = 0 /* synthesis preserve_syn_only */;
always @(posedge clk_rd or posedge arst_rd) begin
    if (arst_rd) begin
        rd_cntr <= 0;
        rd_max <= 1'b0;
    end
    else begin
        if (&rd_cntr) rd_max <= 1'b1;
        else rd_cntr <= rd_cntr + 1'b1;
    end
end

////////////////////////////
// reset helpers


reg [2:0] clocks_stable = 3'b0 /* synthesis preserve_syn_only */;
always @(posedge clk_wr or posedge arst_wr) begin
    if (arst_wr) clocks_stable <= 0;
    else clocks_stable <= {clocks_stable[1:0],rd_max & wr_max};    
end

reg pause_sclr = 1'b0;
reg [3:0] pause_cntr = 0;
reg pause_max = 1'b0;

always @(posedge clk_wr or posedge arst_wr) begin
   if (arst_wr) begin
        pause_cntr <= 0;
        pause_max <= 0;
   end
   else
    if (pause_sclr) begin
        pause_cntr <= 0;
        pause_max <= 0;
    end
    else if (&pause_cntr) pause_max <= 1'b1;
    else pause_cntr <= pause_cntr + 1'b1;
end

reg stall_sclr = 1'b0;
reg [MEM_ADDR:0] stall_cntr = 0;
reg stall_max = 1'b0;

always @(posedge clk_wr or posedge arst_wr) begin
   if (arst_wr) begin
        stall_cntr <= 0;
        stall_max <= 0;
   end
   else
    if (stall_sclr) begin
        stall_cntr <= 0;
        stall_max <= 0;
    end
    else if (&stall_cntr) stall_max <= 1'b1;
    else stall_cntr <= stall_cntr + 1'b1;
end

// move rd ena from write to read domain
reg wrside_rd_ena = 1'b0 /* synthesis preserve_syn_only */;
reg rd_ena0 = 1'b0 /* synthesis preserve_syn_only */;
reg rd_ena1 = 1'b0 /* synthesis preserve_syn_only */;
always @(posedge clk_rd) begin
    rd_ena0 <= wrside_rd_ena;
    rd_ena1 <= rd_ena0;
    rd_ena <= rd_ena1;    
end

/////////////////
// error detect

always @(posedge clk_rd) begin
    underflow <= (rdreq & rd_empty);    
end

always @(posedge clk_wr) begin
    overflow <= (wrreq & wr_full);    
end

wire fifo_error = overflow | underflow /* synthesis keep */;

reg [2:0] fifo_ok = 3'b0 /* synthesis preserve_syn_only */;
always @(posedge clk_wr) begin
    if (fifo_error) fifo_ok <= 0;
    else fifo_ok <= {fifo_ok[1:0],1'b1};    
end

reg stalled_d, stalled_s;

always @(posedge clk_wr or posedge arst_wr) begin
    if (arst_wr) begin
        stalled_d <= 1'b0;
        stalled_s <= 1'b0;
    end
    else begin
        stalled_d <= tx_stalled;
        stalled_s <= stalled_d;
    end
end

///////////////////////
// reset state machine

reg [2:0] rst_state = 3'b0 /* synthesis preserve_syn_only */;
always @(posedge clk_wr or posedge arst_wr) begin
    if (arst_wr) begin
        rst_state <= 2'b00;
        wr_ena <= 1'b0;
        wrside_rd_ena <= 1'b0;    
        pause_sclr <= 1'b0;
    end
    else begin
        wr_ena <= 1'b0;
        pause_sclr <= 1'b1;
        stall_sclr <= 1'b1;
        steady_state <= 1'b0;
        wrside_rd_ena <= 1'b0;    
        case (rst_state) 
            3'h0 : begin
                // wait for the clocks
                if (clocks_stable) rst_state <= 3'h1;
            end
            3'h1 : begin
                // purge
                wrside_rd_ena <= 1'b1;
                if (wr_empty) rst_state <= 3'h2;
            end
            3'h2 : begin
                // disable reading
                rst_state <= 3'h3;
            end
            3'h3 : begin
                // pause
                pause_sclr <= 1'b0;
                if (pause_max) rst_state <= 3'h4;
            end            
            3'h4 : begin
                // enable writing, wait for some data
                wr_ena <= 1'b1;
                if (rx_valid_i) rst_state <= 3'h5;
            end
            3'h5 : begin
                // begin normal operation 
                wr_ena <= 1'b1;
                wrside_rd_ena <= 1'b1;                
                steady_state <= 1'b1;
                if (!fifo_ok[2]) rst_state <= 3'h0;
                else if (stalled_s & !rx_valid_i) rst_state <= 3'h6;
            end
            3'h6 : begin
                // stall timeout
                wr_ena <= 1'b1;
                wrside_rd_ena <= 1'b1;                
                steady_state <= 1'b1;
                stall_sclr <= 1'b0;
                if (!fifo_ok[2]) rst_state <= 3'h0;
                else if (!stalled_s | rx_valid_i) rst_state <= 3'h5;
                else if (stall_max) rst_state <= 3'h7;
            end
            3'h7 : begin
                // stall purge
                wr_ena <= 1'b1;
                wrside_rd_ena <= 1'b1;
                if (!fifo_ok[2]) rst_state <= 3'h0;
                else if (rx_valid_i) rst_state <= 3'h5; // go back to steady state so as not to cut off packets
            end
            default : rst_state <= 3'h0;
        endcase
    end
end

endmodule
