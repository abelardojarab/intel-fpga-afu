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


// (C) 2001-2015 Altera Corporation. All rights reserved.
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


`timescale 1 ps / 1 ps
// baeckler - 06-21-2010

module alt_aeuex_packet_client2_100 #(
	parameter WORDS = 2,
	parameter WIDTH = 64,
	parameter STATUS_ADDR_PREFIX = 6'b0001_00, //0x1000-0x13ff
	parameter SIM_NO_TEMP_SENSE  = 1'b0,
	parameter DEVICE_FAMILY = "Stratix V",
	parameter FEATURES = 32'b0,
    parameter SOP_ON_LANE0       = 1'b0
)(
	input arst,
	
	// TX to Ethernet
	input clk_tx,
	input tx_ack,
	output [WIDTH*WORDS-1:0] tx_data,
	output [WORDS-1:0] tx_start,
	output [WORDS*8-1:0] tx_end_pos,
   output 	   tx_ptp,
   output [15:0] 	   tx_ptp_offset,
   output [1:0] 	   tx_ptp_overwrite,
   output 	   tx_ptp_zero_tcp,
   output [15:0] 	   tx_ptp_tcp_offset,
	
	
	// RX from Ethernet
	input clk_rx,
	input rx_valid,
	input [WIDTH*WORDS-1:0] rx_data,
	input [WORDS-1:0] rx_start,
	input [WORDS*8-1:0] rx_end_pos,
  input [95:0] rx_tod,
  output reg sel_gen_not_rom = 0,
	
	// status register bus
	input clk_status,
	input [15:0] status_addr,
	input status_read,
	input status_write,
	input [31:0] status_writedata,
	output reg [31:0] status_readdata,
	output reg status_readdata_valid
	
);

///////////////////////////////////////////////////////////////
// stop and restart the ack
///////////////////////////////////////////////////////////////

wire tx_ack_internal;
reg [WIDTH*WORDS-1:0] tx_data_internal = 0;
reg [WORDS-1:0] tx_start_internal = 0;
reg [WORDS*8-1:0] tx_end_pos_internal = 0;
reg 	   tx_ptp_internal = 0;
reg [15:0] 	   tx_ptp_offset_internal = 0;
reg [1:0] 	   tx_ptp_overwrite_internal = 0;
reg 	   tx_ptp_zero_tcp_internal = 0;
reg [15:0] 	   tx_ptp_tcp_offset_internal = 0;

alt_aeuex_ack_skid ask 
(
	.clk(clk_tx),
	
	// from the internal TX sources
	.dat_i({tx_valid_internal, tx_start_internal,tx_end_pos_internal,tx_data_internal,
		tx_ptp_internal,tx_ptp_offset_internal,tx_ptp_overwrite_internal,tx_ptp_zero_tcp_internal,tx_ptp_tcp_offset_internal}),
	.ack_i(tx_ack_internal),
	
	// to the alt_e100_top level pins, feeding the transmitter
	.dat_o({tx_valid, tx_start,tx_end_pos,tx_data,
		tx_ptp,tx_ptp_offset,tx_ptp_overwrite,tx_ptp_zero_tcp,tx_ptp_tcp_offset}),
	.ack_o(tx_ack)	
);
defparam ask .WIDTH = WORDS * (WIDTH + 8 + 1) + 1 +  16 + 2 + 1 + 16;


///////////////////////////////////////////////////////////////
// mac loop option
///////////////////////////////////////////////////////////////

wire [WIDTH*WORDS-1:0] mlb_tx_data;
wire [WORDS-1:0] mlb_tx_start;
wire [WORDS*8-1:0] mlb_tx_end_pos;
wire mlb_underflow, mlb_overflow;
wire mlb_select;
wire [7:0] swap_ctrl_sync;
wire [15:0] high_threshold_sync;
wire [15:0] low_threshold_sync;

reg mlb_rst = 0;

alt_aeuex_mac_loopback mlb (
	// no domain
	.arst(arst | mlb_rst),
		
	// TX to Ethernet
	.high_threshold(high_threshold_sync),
	.low_threshold(low_threshold_sync),
	.clk_tx(clk_tx),
	.tx_ack(tx_ack_internal),
	.tx_data(mlb_tx_data),
	.tx_start(mlb_tx_start),
	.tx_end_pos(mlb_tx_end_pos),
	.underflow(mlb_underflow),
	
	// RX from Ethernet
	.clk_rx(clk_rx),
	.rx_valid(rx_valid),
	.rx_data(rx_data),
	.rx_start(rx_start),
	.rx_end_pos(rx_end_pos),	
	.swap_ctrl(swap_ctrl_sync),
	.overflow(mlb_overflow)
);
defparam mlb .DEVICE_FAMILY = DEVICE_FAMILY;
defparam mlb .WORDS = WORDS;
defparam mlb .WIDTH = WIDTH;

reg [7:0] swap_ctrls = 8'h0;
alt_aeuex_status_sync ss7 (
	.clk(clk_rx),
	.din(swap_ctrls),
	.dout(swap_ctrl_sync)
);
defparam ss7 .WIDTH = 8;

reg [15:0] high_threshold = (WORDS <= 4) ? 16'h500 : 16'h280;
alt_aeuex_status_sync ss8 (
	.clk(clk_rx),
	.din(high_threshold),
	.dout(high_threshold_sync)
);
defparam ss8 .WIDTH = 16;

reg [15:0] low_threshold = (WORDS <= 4) ? 16'h200 : 16'h100;
alt_aeuex_status_sync ss9 (
	.clk(clk_rx),
	.din(low_threshold),
	.dout(low_threshold_sync)
);
defparam ss9 .WIDTH = 16;

///////////////////////////////////////////////////////////////
// Packet generator
///////////////////////////////////////////////////////////////

wire sample_rom_idle;
wire packet_gen_idle;
wire tx_src_select;

//wire [5*64-1:0] din_tr,din_ps;	// regular left to right
//wire [5-1:0] din_start_tr,din_start_ps;  // first of any 8 bytes
//wire [5*8-1:0] din_end_pos_tr,din_end_pos_ps; // any byte

wire [WIDTH*WORDS-1:0] din_tr,din_ps,din_ps2;	// regular left to right
wire [WORDS-1:0] din_start_tr,din_start_ps,din_start_ps2;  // first of any 8 bytes
wire [WORDS*8-1:0] din_end_pos_tr,din_end_pos_ps,din_end_pos_ps2; // any byte

generate
    if (WORDS == 2) begin : rom40
		alt_aeuex_sample_tx_rom_2 txr (
			.clk(clk_tx),
			.ena(tx_ack_internal),
			.idle(sample_rom_idle),
			
			.dout_start(din_start_tr),
			.dout_endpos(din_end_pos_tr),
			.dout(din_tr)
		);
		defparam txr .DEVICE_FAMILY = DEVICE_FAMILY;
    end else if (WORDS == 5) begin : rom100
		alt_e100_sample_tx_rom_2 txr (
			.clk(clk_tx),
			.ena(tx_ack_internal),
			.idle(sample_rom_idle),
			
			.dout_start(din_start_tr),
			.dout_endpos(din_end_pos_tr),
			.dout(din_tr)
		);
		defparam txr .DEVICE_FAMILY = DEVICE_FAMILY;
    end else begin : norom
		assign din_start_tr   = 0;
		assign din_end_pos_tr = 0;
		assign din_tr         = 0;
    end
endgenerate

alt_aeuex_packet_gen ps (
	.clk(clk_tx),
	.ena(tx_ack_internal),
	.idle(packet_gen_idle),
		
	.sop(din_start_ps),
	.eop(din_end_pos_ps),
	.dout(din_ps),
	.sernum()
);
defparam ps  .WORDS = WORDS;
defparam ps  .WIDTH = WIDTH;
defparam ps  .SOP_ON_LANE0 = SOP_ON_LANE0;

   wire [15:0] 	   cnt_out_ps2;
   wire  	   din_ptp_ps2;
   wire [15:0] 	   din_ptp_offset_ps2;
   wire [1:0] 	   din_ptp_overwrite_ps2;
   wire  	   din_ptp_zero_tcp_ps2;
   wire [15:0] 	   din_ptp_tcp_offset_ps2;
   
   alt_aeuex_packet_gen2_100 ps2 (
			     .clk(clk_tx),
			     .ena(tx_ack_internal),
			     .idle(packet_gen_idle),
      
			     .sop(din_start_ps2),
			     .eop(din_end_pos_ps2),
			     .dout(din_ps2),
			     .ptp(din_ptp_ps2),
			     .ptp_offset(din_ptp_offset_ps2),
			     .ptp_overwrite(din_ptp_overwrite_ps2),
			     .ptp_zero_tcp(din_ptp_zero_tcp_ps2),
			     .ptp_tcp_offset(din_ptp_tcp_offset_ps2),
			     .cnt_out(cnt_out_ps2),
			     .sernum()
			     );
defparam ps2  .WORDS = WORDS;
defparam ps2  .WIDTH = WIDTH;
defparam ps2  .SOP_ON_LANE0 = SOP_ON_LANE0;

//////////////////////////////////////
// PTP Capture Module
//////////////////////////////////////

   wire [95:0] rx_tod_cpm;
   wire [95:0] ts_in_pkt_cpm;
   reg        rst_wraddr=0;
   reg [8:0]  raddr=0;
   wire [8:0]  wraddr;
   
   alt_aeuex_ptp_captr_100 pcp
     (
      .arst(arst),
      .clk(clk_rx),
      .rst_wraddr(rst_wraddr),
      .raddr(raddr),
    .l8_rx_data			(rx_data),
    .l8_rx_empty		(rx_end_pos),
    .l8_rx_startofpacket	(rx_start[WORDS-1]),
//    .l8_rx_endofpacket		(rx_end_pos),
    .l8_rx_endofpacket		(1'b0),
    .l8_rx_error		(rx_error),
    .l8_rx_valid		(rx_valid),
      .wraddr_reg(wraddr),
      .rx_tod(rx_tod),
      .rx_tod_cpm_reg(rx_tod_cpm),
      .ts_in_pkt_cpm_reg(ts_in_pkt_cpm)
      );

// TX output muxing
always @(posedge clk_tx) begin
	if (tx_ack_internal) begin
//		tx_start_internal <= mlb_seloooooooect ? mlb_tx_start :
//					tx_src_select ? din_start_ps : din_start_tr;
//		tx_end_pos_internal <= mlb_select ? mlb_tx_end_pos :
//					tx_src_select ? din_end_pos_ps : din_end_pos_tr;
//		tx_data_internal <= mlb_select ? mlb_tx_data :
//						tx_src_select ? din_ps : din_tr;	
		tx_start_internal   <= mlb_select ? mlb_tx_start  : tx_src_select ? din_start_ps2 : din_start_tr;
		tx_end_pos_internal <= mlb_select ? mlb_tx_end_pos: tx_src_select ? din_end_pos_ps2 : din_end_pos_tr;
		tx_data_internal    <= mlb_select ? mlb_tx_data   : tx_src_select ? din_ps2 : din_tr;	
	   tx_ptp_internal     <= mlb_select ? 1'b0          : tx_src_select ? din_ptp_ps2 : 1'b0;
	   tx_ptp_offset_internal     <= mlb_select ? 16'd0          : tx_src_select ? din_ptp_offset_ps2 : 16'd0;
	   tx_ptp_overwrite_internal     <= mlb_select ? 2'b0          : tx_src_select ? din_ptp_overwrite_ps2 : 2'b0;
	   tx_ptp_zero_tcp_internal     <= mlb_select ? 1'b0          : tx_src_select ? din_ptp_zero_tcp_ps2 : 1'b0;
	   tx_ptp_tcp_offset_internal     <= mlb_select ? 16'd0          : tx_src_select ? din_ptp_tcp_offset_ps2 : 16'd0;
	end
end


reg [3:0] tx_ctrls = 4'b0111;
//reg [3:0] tx_ctrls = 4'b1110;
alt_aeuex_status_sync ss0 (
	.clk(clk_tx),
	.din(tx_ctrls),
	.dout({mlb_select,sample_rom_idle,packet_gen_idle,tx_src_select})
);
defparam ss0 .WIDTH = 4;


///////////////////////////////////////////////////////////////
// Packet checker
///////////////////////////////////////////////////////////////

wire clr_cntrs;
wire [31:0] bad_term_cnt;
wire [31:0] bad_serial_cnt;
wire [31:0] bad_dest_cnt;
wire [WORDS*16-1:0] rx_sernum;

alt_aeuex_packet_gen_sanity_check psc (
	.clk(clk_rx),
	.clr_cntrs(clr_cntrs),
			
	.sop(rx_start),
	.eop(rx_end_pos),
	.din(rx_data),
	.din_valid(rx_valid),
	
	.bad_term_cnt(bad_term_cnt),
	.bad_serial_cnt(bad_serial_cnt),
	.bad_dest_cnt(bad_dest_cnt),
	
	.sernum(rx_sernum)
);
defparam psc .WORDS = WORDS;
defparam psc .WIDTH = WIDTH;

reg [1:0] rx_ctrls = 2'b01;
wire pause_cntrs = rx_ctrls[1];
alt_aeuex_status_sync ss1 (
	.clk(clk_rx),
	.din(rx_ctrls[0]),
	.dout(clr_cntrs)
);
defparam ss1 .WIDTH = 1;

wire [31:0] sync_bad_term_cnt, sync_bad_serial_cnt, sync_bad_dest_cnt;

alt_aeuex_status_cntr_sync scs0 (
	.clk_in(clk_rx),
	.din(bad_term_cnt),
	.clk_out(clk_status),
	.pause(pause_cntrs),
	.dout(sync_bad_term_cnt)
);
defparam scs0 .WIDTH = 32;

alt_aeuex_status_cntr_sync scs1 (
	.clk_in(clk_rx),
	.din(bad_serial_cnt),
	.clk_out(clk_status),
	.pause(pause_cntrs),
	.dout(sync_bad_serial_cnt)
);
defparam scs1 .WIDTH = 32;

alt_aeuex_status_cntr_sync scs2 (
	.clk_in(clk_rx),
	.din(bad_dest_cnt),
	.clk_out(clk_status),
	.pause(pause_cntrs),
	.dout(sync_bad_dest_cnt)
);
defparam scs2 .WIDTH = 32;

wire [WORDS*16-1:0] sync_rx_sernum;
genvar i;
generate
	for (i=0; i<WORDS; i=i+1) begin : ws
		alt_aeuex_status_cntr_sync scs3 (
			.clk_in(clk_rx),
			.din(rx_sernum[(i+1)*16-1:i*16]),
			.clk_out(clk_status),
			.pause(pause_cntrs),
			.dout(sync_rx_sernum[(i+1)*16-1:i*16])
		);
		defparam scs3 .WIDTH = 16;
	end
endgenerate

//////////////////////////////////////////
// Temperature probe
//////////////////////////////////////////

wire [7:0] degrees_f;

generate
    if (SIM_NO_TEMP_SENSE) begin
        assign degrees_f = 8'd100;
    end
    else if(DEVICE_FAMILY == "Arria 10") begin
        alt_aeuex_a10_temp_sense ts (
            .clk(clk_status),
            .degrees_c(),
            .degrees_f(degrees_f)
        );
    end
    else begin
        alt_aeuex_temp_sense ts (
            .clk(clk_status), 
            .arst(1'b0),
            .degrees_c(),
            .degrees_f(degrees_f),
            .degrees_f_bcd(),
            .fresh_sample(),
            .failed_sample()
        );
		defparam ts .DEVICE_FAMILY = DEVICE_FAMILY;
    end
endgenerate

////////////////////////////////////////////
// Control port
////////////////////////////////////////////

reg status_addr_sel_r = 0;
reg [5:0] status_addr_r = 0;

reg status_read_r = 0, status_write_r = 0;
reg [31:0] status_writedata_r = 0;
reg [31:0] scratch = 0;

initial status_readdata = 0;
initial status_readdata_valid = 0;

reg mlb_error_sclr;

alt_aeuex_sticky_flag of (
    .flag(mlb_overflow), .flag_clk(clk_rx),
        .sys_clk(clk_status), .sys_sclr(mlb_error_sclr), .sys_flag(mlb_overflow_s));

alt_aeuex_sticky_flag uf (
    .flag(mlb_underflow), .flag_clk(clk_tx),
        .sys_clk(clk_status), .sys_sclr(mlb_error_sclr), .sys_flag(mlb_underflow_s));

always @(posedge clk_status) begin
	status_addr_r <= status_addr[5:0];
	status_addr_sel_r <= (status_addr[15:6] == {STATUS_ADDR_PREFIX[5:0], 4'b0});
	
	status_read_r <= status_read;
	status_write_r <= status_write;
	status_writedata_r <= status_writedata;	
	status_readdata_valid <= 1'b0;
	mlb_error_sclr <= 1'b0;

	if (status_read_r) begin
		if (status_addr_sel_r) begin
			status_readdata_valid <= 1'b1;
			case (status_addr_r)
				6'h0 : status_readdata <= scratch;
				6'h1 : status_readdata <= "CLNT";
				6'h2 : status_readdata <= FEATURES[31:0];
				
                6'h6 : status_readdata <= {24'h0, degrees_f};
				
				6'h8 : status_readdata <= sync_bad_term_cnt;
				6'h9 : status_readdata <= sync_bad_serial_cnt;
				6'ha : status_readdata <= sync_bad_dest_cnt;
				
				6'hb : status_readdata <= sync_rx_sernum[31:0];
				6'hc : status_readdata <= sync_rx_sernum[((WORDS >= 4) ? 4 : 2)*16-1 -: 32];
				6'hd : status_readdata <= {16'h0,sync_rx_sernum[((WORDS >= 5) ? 5 : 1)*16-1 -: 16]};
				
				6'h10 : status_readdata <= {28'b0,tx_ctrls};
				6'h11 : status_readdata <= {30'b0,rx_ctrls};
				6'h12 : status_readdata <= {24'h0,swap_ctrls};
				6'h13 : status_readdata <= {16'h0,high_threshold};
				6'h14 : status_readdata <= {16'h0,low_threshold};
				6'h15 : begin
						status_readdata <= {30'h0,mlb_overflow_s, mlb_underflow_s};
						mlb_error_sclr <= 1'b1;
					end

				6'h16 : status_readdata <= {31'h0,mlb_rst};
			        8'h1d : status_readdata <= {16'd0,cnt_out_ps2};
			        8'h1e : status_readdata <= {23'd0,raddr};
			        8'h1f : status_readdata <= {31'd0,rst_wraddr};
			  8'h20: status_readdata <= {23'd0,wraddr};
			  8'h21: status_readdata <= rx_tod_cpm[95:64];
			  8'h22: status_readdata <= rx_tod_cpm[63:32];
			  8'h23: status_readdata <= rx_tod_cpm[31:0];
			  8'h24: status_readdata <= ts_in_pkt_cpm[95:64];
			  8'h25: status_readdata <= ts_in_pkt_cpm[63:32];
			  8'h26: status_readdata <= ts_in_pkt_cpm[31:0];
			  
				
				default : status_readdata <= 32'h123;
			endcase		
		end
		else begin
			// this read is not for my address prefix - ignore it.
		end
	end	
	
	if (status_write_r) begin
		if (status_addr_sel_r) begin
			case (status_addr_r)
				6'h0 : scratch <= status_writedata_r;						
				
				6'h10 : tx_ctrls <= status_writedata_r[3:0];									
				6'h11 : rx_ctrls <= status_writedata_r[1:0];									
				6'h12 : swap_ctrls <= status_writedata_r[7:0];									
				6'h13 : high_threshold <= status_writedata_r[15:0];									
				6'h14 : low_threshold <= status_writedata_r[15:0];									
				6'h15 : mlb_error_sclr <= status_writedata_r[2];		

				6'h16 : mlb_rst <= status_writedata_r[0];				
			  8'h1e : raddr <= status_writedata[8:0];
			  8'h1f : rst_wraddr <= status_writedata[0];
			endcase
		end
	end				
end

endmodule // alt_aeuex_packet_client2_100

