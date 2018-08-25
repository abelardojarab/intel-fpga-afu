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


// (C) 2001-2017 Intel Corporation. All rights reserved.
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


// (C) 2001-2017 Intel Corporation. All rights reserved.
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


// (C) 2001-2017 Intel Corporation. All rights reserved.
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


// (C) 2001-2016 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



`timescale 1 ps / 1 ps

module alt_e100_packet_client #(
	parameter WORDS = 8,
	parameter WIDTH = 64,
	parameter EMPTY_WIDTH =6,
	parameter STATUS_ADDR_PREFIX = 6'b0001_00, //0x1000-0x13ff
	parameter SIM_NO_TEMP_SENSE  = 1'b1,
	parameter DEVICE_FAMILY = "Arria 10"
)(
	input arst,
	
	// TX to Ethernet
	input clk_tx,
	output tx_valid,
	input tx_ack,
	output [WIDTH*WORDS-1:0] tx_data,
	output tx_start,
	output tx_end,
	output [EMPTY_WIDTH-1:0] tx_empty,

	input  tx_lanes_stable,

	// RX from Ethernet
	input clk_rx,
	input rx_valid,
	input [WIDTH*WORDS-1:0] rx_data,
	input rx_start,
	input rx_end,
	input [EMPTY_WIDTH-1:0] rx_empty,
	input [5:0] rx_error,

	input rx_block_lock,
	input rx_am_lock,
	input rx_pcs_ready,
	
	// status register bus
	input clk_status,
	input [15:0] status_addr,
	input status_read,
	input status_write,
	input [31:0] status_writedata,
	output reg [31:0] status_readdata,
	output reg status_readdata_valid
	
);
reg [3:0] tx_ctrl = 4'hf;
reg [13:0] start_addr=14'd64;
reg [13:0] end_addr=14'd9600;
reg end_sel=0;
reg ipg_sel=0;
reg [15:0] pkt_num= 16'd10;
reg [1:0] pattern_mode =2'b00;

///////////////////////////////////////////////////////////////
// Packet generator
///////////////////////////////////////////////////////////////

    wire rst_tx_syncn;
    reset_synchronizer rs_tx (
        .clk            (clk_tx),
        .resetn         (~arst),
        .resetn_sync    (rst_tx_syncn)
    );
    wire [WIDTH*WORDS-1:0]  tx_data_pkt_gen;
    wire                    tx_valid_pkt_gen;
    wire [EMPTY_WIDTH-1:0]    tx_empty_pkt_gen;
    wire                    tx_end_pkt_gen;
    wire                    tx_start_pkt_gen;

    wire gen_enable = ~tx_ctrl[1];
    wire gen_enable_sync;
    alt_e100s10_delay #(
      
        .WIDTH  (1)
    ) gen_enable_synchronizer_tx (
        .clk    (clk_tx),
        .din    (gen_enable),
        .dout   (gen_enable_sync)
    );

    wire       din_start;         // start pos, first of every 8 bytes
    wire     din_end_pos;       // end position, any byte
    assign tx_end_pkt_gen   = din_end_pos;
    assign tx_start_pkt_gen = din_start;

    alt_aeuex_packet_client_tx pc (
        .arst                   (arst),
        .tx_pkt_gen_en          (gen_enable),

	.pattern_mode(pattern_mode),
	.start_addr(start_addr),
	.end_addr(end_addr),
	.pkt_num (pkt_num),
	.end_sel(end_sel),		 
	.ipg_sel(ipg_sel),
		  
        // TX to Ethernet
        .clk_tx                 (clk_tx),
        .tx_ack                 (tx_ack),
        .tx_data                (tx_data_pkt_gen),
        .tx_start               (din_start),
        .tx_end_pos             (din_end_pos),
			.tx_valid		(tx_valid_pkt_gen),
        .tx_empty               (tx_empty_pkt_gen)
    );
	 defparam pc.WORDS = WORDS;
    defparam pc.WIDTH = WIDTH; 


    ///////////////////////////////////////////////////////////////
    // Client loopback
    ///////////////////////////////////////////////////////////////
    wire client_loop_en = tx_ctrl[3];
    wire client_loop_en_sync_rx;
    alt_e100s10_delay #(
   
        .WIDTH  (1)
    ) loop_enable_synchronizer_rx (
        .clk    (clk_rx),
        .din    (client_loop_en),
        .dout   (client_loop_en_sync_rx)
    );
    // Packet fifo input mux
    wire [WIDTH*WORDS-1:0] rx_data_loop  = client_loop_en_sync_rx ? rx_data  : {WIDTH*WORDS{1'b0}};
    wire                   rx_start_loop = client_loop_en_sync_rx ? rx_start : 1'b0;
    wire                   rx_end_loop   = client_loop_en_sync_rx ? rx_end   : 1'b0;
    wire [EMPTY_WIDTH-1:0]   rx_empty_loop = client_loop_en_sync_rx ? rx_empty : 3'd0;
    wire                   rx_valid_loop = client_loop_en_sync_rx ? rx_valid : 1'b0;
    wire [WIDTH*WORDS-1:0] tx_data_loop;
    wire                   tx_valid_loop;
    wire [EMPTY_WIDTH-1:0]   tx_empty_loop;
    wire                   tx_end_loop;
    wire                   tx_start_loop;
    wire                   block_dropped;
    /*
	 packet_fifo #(
        .WIDTH      (WIDTH*WORDS)
    ) client_loop (
        .async_reset         (arst),
        .clk_in              (clk_rx),
        .din                 (rx_data_loop),
        .sop_in              (rx_start_loop),
        .eop_in              (rx_end_loop),
        .empty_in            (rx_empty_loop),
        .valid_in            (rx_valid_loop),
        .full                (),
        .block_dropped       (block_dropped),
        .clk_out             (clk_tx),
        .dout                (tx_data_loop),
        .sop_out             (tx_start_loop),
        .eop_out             (tx_end_loop),
        .empty_out           (tx_empty_loop),
        .valid_out           (tx_valid_loop),
        .accepted            (tx_ack)
    );
	 */
    wire client_loop_en_sync_tx;
    alt_e100s10_delay #(
       
        .WIDTH  (1)
    ) loop_enable_synchronizer_tx (
        .clk    (clk_tx),
        .din    (client_loop_en),
        .dout   (client_loop_en_sync_tx)
    );
    // TX traffic mux. Switches between client loopback and packet generator
    assign tx_data  = client_loop_en_sync_tx ? tx_data_loop  : tx_data_pkt_gen;
    assign tx_valid = client_loop_en_sync_tx ? tx_valid_loop : tx_valid_pkt_gen;
    assign tx_empty = client_loop_en_sync_tx ? tx_empty_loop : tx_empty_pkt_gen;
    assign tx_end   = client_loop_en_sync_tx ? tx_end_loop   : tx_end_pkt_gen;
    assign tx_start = client_loop_en_sync_tx ? tx_start_loop : tx_start_pkt_gen;
    // Count of dropped blocks
    wire [31:0] dropped_block_count;
    reg clear_dropped_counter=1'b0;
    stats_counter #(
        .WIDTH      (32),
        .HS_WIDTH   (5)
    ) dropped_counter (
        .csr_clk    (clk_status),
        .csr_clear  (clear_dropped_counter),
        .count      (dropped_block_count),
        .incr_clk   (clk_rx),
        .incr_count (block_dropped)
);

///////////////////////////////////////////////////////////////
// Packet checker
///////////////////////////////////////////////////////////////

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
wire [31:0] rx_status = {{29{1'b0}}, rx_block_lock, rx_am_lock, rx_pcs_ready};

reg reset_cnt = 1'b0;

reg [31:0] tx_pkt_cnt;
reg reset_tx_cnt_r;
reg reset_tx_cnt_s;
always @(posedge clk_tx) begin
   reset_tx_cnt_r <= reset_cnt;
   reset_tx_cnt_s <= reset_tx_cnt_r;
end

always @(posedge clk_tx) begin
   if (reset_tx_cnt_s) begin
      tx_pkt_cnt <= 'h0;
   end else if (tx_valid & tx_end & tx_ack) begin
      tx_pkt_cnt <= tx_pkt_cnt + 32'h1;
   end
end

reg [31:0] rx_pkt_cnt;
reg [31:0] rx_err_cnt;

reg reset_rx_cnt_r;
reg reset_rx_cnt_s;
always @(posedge clk_rx) begin
   reset_rx_cnt_r <= reset_cnt;
   reset_rx_cnt_s <= reset_rx_cnt_r;
end

always @(posedge clk_rx) begin
   if (reset_rx_cnt_s) begin
      rx_pkt_cnt <= 'h0;
   end else if (rx_valid & rx_end) begin
      rx_pkt_cnt <= rx_pkt_cnt + 32'h1;
   end
end

always @(posedge clk_rx) begin
   if (reset_rx_cnt_s) begin
      rx_err_cnt <= 'h0;
   end else if (rx_valid & rx_end & rx_error[1]) begin
      rx_err_cnt <= rx_err_cnt + 32'h1;
   end
end

initial status_readdata = 0;
initial status_readdata_valid = 0;

always @(posedge clk_status) begin
	status_addr_r <= status_addr[5:0];
	status_addr_sel_r <= (status_addr[15:6] == {STATUS_ADDR_PREFIX[5:0], 4'b0});
	
	status_read_r <= status_read;
	status_write_r <= status_write;
	status_writedata_r <= status_writedata;	
	status_readdata_valid <= 1'b0;

	if (status_read_r) begin
		if (status_addr_sel_r) begin
			status_readdata_valid <= 1'b1;
			case (status_addr_r)
				6'h0 : status_readdata <= scratch;
				6'h1 : status_readdata <= "CLNT";
                //6'h2 : status_readdata <= tx_ctrl;
                6'h3 : status_readdata <= rx_status;
                6'h4 : status_readdata <= tx_pkt_cnt;
                6'h5 : status_readdata <= rx_pkt_cnt;
                6'h6 : status_readdata <= rx_err_cnt;
                6'h7 : status_readdata <= {{30{1'b0}}, clear_dropped_counter,reset_cnt};
	                6'h8 : status_readdata <= {2'b0, end_addr,2'b0,start_addr};				 
                //6'h7 : status_readdata <= {24'h0, degrees_f};
					 6'h9 : status_readdata <= {16'b0,pkt_num};
		6'h10   : status_readdata <= {24'd0,ipg_sel, end_sel, pattern_mode,tx_ctrl};
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
				//6'h2 : tx_ctrl <= status_writedata_r;						
				6'h7 : {clear_dropped_counter,reset_cnt} <= status_writedata_r[1:0];			
					6'h8 : {end_addr,start_addr} <= {status_writedata_r[29:16],status_writedata_r[13:0]};	
				6'h9 : { pkt_num}                 <= status_writedata_r[15:0];		
					
                    6'h10 : { ipg_sel,end_sel, pattern_mode,tx_ctrl}                 <= status_writedata_r[7:0];						
			endcase
		end
	end				
end

endmodule


