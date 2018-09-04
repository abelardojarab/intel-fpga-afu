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


`timescale 1 ps / 1 ps

module alt_e100s10_packet_client #(

	parameter WORDS = 8,
	parameter WIDTH = 64,
	parameter EMPTY_WIDTH =6,

    parameter STATUS_ADDR_PREFIX    = 6'b0001_00, //0x1000-0x13ff
    parameter FEATURES              = 32'b0,
    parameter SIM_EMULATE           = 0
)(
    input   logic                       i_arst,

    // TX to Ethernet
    input   logic                       i_clk_tx,
    input   logic                       i_tx_ready,
    output  logic                       o_tx_valid,
    output  logic   [511:0]             o_tx_data,
    output  logic                       o_tx_sop,
    output  logic                       o_tx_eop,
    output  logic   [5:0]               o_tx_empty,

    // RX from Ethernet
    input   logic                       i_clk_rx,
    input   logic                       i_rx_sop,
    input   logic                       i_rx_eop,
    input   logic   [5:0]               i_rx_empty,
    input   logic   [511:0]             i_rx_data,
    input   logic                       i_rx_valid,

    // status register bus
    input   logic                       i_clk_status,
    input   logic   [15:0]              i_status_addr,
    input   logic                       i_status_read,
    input   logic                       i_status_write,
    input   logic   [31:0]              i_status_writedata,
    output  logic   [31:0]              o_status_readdata,
    output  logic                       o_status_readdata_valid
);

logic [13:0] start_addr=14'd64;
logic [13:0] end_addr=14'd9600;
logic end_sel=0;
logic ipg_sel=0;
logic [31:0] pkt_num= 32'd10;
logic [1:0] pattern_mode =2'b00;
logic [47:0] DEST_ADDR = 48'h123456780ADD;
logic [47:0] SRC_ADDR = 48'h876543210ADD;

///////////////////////////////////////////////////////////////
// stop and restart the ack
///////////////////////////////////////////////////////////////

    logic           tx_reset;
    logic           mlb_rst = 1'b0;

    logic           mlb_select;
    logic           packet_gen_idle;
    logic           rom_idle;
    logic           tx_src_select;

    logic           tx_valid_int;
    logic           tx_sop_int;
    logic           tx_eop_int;
    logic   [5:0]   tx_empty_int;
    logic   [511:0] tx_data_int;

    logic   [7:0]   packet_gen_start;
    logic           packet_gen_sop;
    logic           packet_gen_eop;
    logic   [63:0]  packet_gen_end;
    logic   [5:0]   packet_gen_empty;
    logic   [511:0] packet_gen_data;
    logic           packet_gen_valid;

    logic           loopback_sop;
    logic           loopback_eop;
    logic   [5:0]   loopback_empty;
    logic   [511:0] loopback_data;
    logic           loopback_valid;

    logic           loopback_sop_r2;
    logic           loopback_eop_r2;
    logic   [5:0]   loopback_empty_r2;
    logic   [511:0] loopback_data_r2;
    logic           loopback_valid_r2;

    logic           status_addr_sel_r = 0;
    logic [5:0]     status_addr_r = 0;

    logic           status_read_r = 0;
    logic           status_write_r = 0;
    logic [31:0]    status_writedata_r = 0;
    logic [31:0]    scratch = 0;

    //assign packet_gen_valid = i_tx_ready;
    always_ff @(posedge i_clk_tx) begin

        if (mlb_select) begin
            tx_valid_int    <= loopback_valid_r2;
            tx_sop_int      <= loopback_sop_r2;
            tx_eop_int      <= loopback_eop_r2;
            tx_empty_int    <= loopback_empty_r2;
            tx_data_int     <= loopback_data_r2;
        end else begin
            tx_valid_int    <= packet_gen_valid;
            tx_sop_int      <= packet_gen_sop;
            tx_eop_int      <= packet_gen_eop;
            tx_empty_int    <= packet_gen_empty;
            tx_data_int     <= packet_gen_data;
        end
    end

    alt_e100s10_reset_synchronizer rstx (
        .aclr       (i_arst),
        .clk        (i_clk_tx),
        .aclr_sync  (tx_reset)
    );

    alt_e100s10_ready_skid #(
        .WIDTH  (1+1+1+6+512)  // sop, eop, empty, data
    ) output_skid (
        .i_clk      (i_clk_tx),
        .i_data     ({tx_valid_int,tx_sop_int, tx_eop_int, tx_empty_int, tx_data_int}),
        .o_ready    (),
        .o_data     ({o_tx_valid, o_tx_sop, o_tx_eop, o_tx_empty, o_tx_data}),
        .i_ready    (i_tx_ready)
    );


    alt_aeuex_packet_client_tx pc (
        .arst                   (arst),
        .tx_pkt_gen_en          (~packet_gen_idle),

	.pattern_mode(pattern_mode),
	.start_addr(start_addr),
	.end_addr(end_addr),
	.pkt_num (pkt_num),
	.end_sel(end_sel),		 
	.ipg_sel(ipg_sel),
	.SRC_ADDR(SRC_ADDR),
	.DEST_ADDR(DEST_ADDR),
		  
        // TX to Ethernet
        .clk_tx                 (i_clk_tx),
        .tx_ack                 (i_tx_ready),
        .tx_data                (packet_gen_data),
        .tx_start               (packet_gen_sop),
        .tx_end_pos             (packet_gen_eop),
	.tx_valid		(packet_gen_valid),
        .tx_empty               (packet_gen_empty)
    );
	 defparam pc.WORDS = WORDS;
    	defparam pc.WIDTH = WIDTH; 


    alt_e100s10_loopback_client #(
        .SIM_EMULATE    (SIM_EMULATE)
    ) mlb (
        .i_arst     (!mlb_select || i_arst || mlb_rst),

        .i_clk_w    (i_clk_rx),
        .i_sop      (i_rx_sop),
        .i_eop      (i_rx_eop),
        .i_valid    (i_rx_valid),
        .i_empty    (i_rx_empty),
        .i_data     (i_rx_data),

        .i_clk_r    (i_clk_tx),
        .o_sop      (loopback_sop),
        .o_eop      (loopback_eop),
        .o_valid    (loopback_valid),
        .o_empty    (loopback_empty),
        .o_data     (loopback_data),
        .i_ready    (i_tx_ready)
    );

    alt_e100s10_ready_skid #(
        .WIDTH  (1+1+1+6+512)  // sop, eop, empty, data
    ) mlb_skid (
        .i_clk      (i_clk_tx),
        .i_data     ({loopback_valid,loopback_sop, loopback_eop, loopback_empty, loopback_data}),
        .o_ready    (),
        .o_data     ({loopback_valid_r2,loopback_sop_r2, loopback_eop_r2, loopback_empty_r2, loopback_data_r2}),
        .i_ready    (i_tx_ready)
    );

    // logic [3:0] tx_ctrls = 4'b0101;
    // logic [3:0] tx_ctrls = 4'b1110;
    logic [3:0] tx_ctrls = 4'b0110;
    alt_e100s10_status_sync #(
        .WIDTH  (4)
    ) ss0 (
        .clk(i_clk_tx),
        .din(tx_ctrls),
        .dout({mlb_select, rom_idle, packet_gen_idle, tx_src_select})
    );


    always_ff @(posedge i_clk_status) begin
        status_addr_r           <= i_status_addr[5:0];
        status_addr_sel_r       <= (i_status_addr[15:6] == {STATUS_ADDR_PREFIX[5:0], 4'b0});

        status_read_r           <= i_status_read;
        status_write_r          <= i_status_write;
        status_writedata_r      <= i_status_writedata;
        o_status_readdata_valid <= 1'b0;
        o_status_readdata       <= o_status_readdata;

        if (status_read_r) begin
            if (status_addr_sel_r) begin
                o_status_readdata_valid <= 1'b1;
                case (status_addr_r)
                    6'h0  : o_status_readdata <= scratch;
                    6'h1  : o_status_readdata <= "CLNT";
                    6'h2  : o_status_readdata <= FEATURES[31:0];

	         6'h8 : o_status_readdata <= {2'b0, end_addr,2'b0,start_addr};				 
                 6'h9 : o_status_readdata <= {16'b0,pkt_num};
		6'h10   : o_status_readdata <= {24'd0,ipg_sel, end_sel, pattern_mode,tx_ctrls};
		6'h11 : o_status_readdata <= DEST_ADDR[31:0];
		6'h12 : o_status_readdata <= {16'h0,DEST_ADDR[47:32]};
		6'h13 : o_status_readdata <= SRC_ADDR[31:0];
		6'h14 : o_status_readdata <= {16'h0,SRC_ADDR[47:32]};
                    6'h16 : o_status_readdata <= {31'h0,mlb_rst};

                    default : o_status_readdata <= 32'h123;
                endcase
            end
            else begin
                // this read is not for my address prefix - ignore it.
            end
        end

        if (status_write_r) begin
            if (status_addr_sel_r) begin
                case (status_addr_r)
                    6'h0  : scratch <= status_writedata_r;
		    
		    6'h8 : {end_addr,start_addr} <= {status_writedata_r[29:16],status_writedata_r[13:0]};	
		    6'h9 : { pkt_num}                 <= status_writedata_r[31:0];
                    6'h10 : { ipg_sel,end_sel, pattern_mode,tx_ctrls}                 <= status_writedata_r[7:0];
		    6'h11 : DEST_ADDR[31:0] <= status_writedata_r[31:0];
		    6'h12 : DEST_ADDR[47:32] <= status_writedata_r[15:0];
		    6'h13 : SRC_ADDR[31:0] <= status_writedata_r[31:0];
		    6'h14 : SRC_ADDR[47:32] <= status_writedata_r[15:0];
                    6'h16 : mlb_rst <= status_writedata_r[0];
                endcase
            end
        end
    end

    function logic  [5:0]   one_hot_to_bin;
        input   logic   [63:0]  oh_in;
        case (1'b1) // synopsys parallel_case
            oh_in[63]   : one_hot_to_bin  = 6'd63;
            oh_in[62]   : one_hot_to_bin  = 6'd62;
            oh_in[61]   : one_hot_to_bin  = 6'd61;
            oh_in[60]   : one_hot_to_bin  = 6'd60;
            oh_in[59]   : one_hot_to_bin  = 6'd59;
            oh_in[58]   : one_hot_to_bin  = 6'd58;
            oh_in[57]   : one_hot_to_bin  = 6'd57;
            oh_in[56]   : one_hot_to_bin  = 6'd56;
            oh_in[55]   : one_hot_to_bin  = 6'd55;
            oh_in[54]   : one_hot_to_bin  = 6'd54;
            oh_in[53]   : one_hot_to_bin  = 6'd53;
            oh_in[52]   : one_hot_to_bin  = 6'd52;
            oh_in[51]   : one_hot_to_bin  = 6'd51;
            oh_in[50]   : one_hot_to_bin  = 6'd50;
            oh_in[49]   : one_hot_to_bin  = 6'd49;
            oh_in[48]   : one_hot_to_bin  = 6'd48;
            oh_in[47]   : one_hot_to_bin  = 6'd47;
            oh_in[46]   : one_hot_to_bin  = 6'd46;
            oh_in[45]   : one_hot_to_bin  = 6'd45;
            oh_in[44]   : one_hot_to_bin  = 6'd44;
            oh_in[43]   : one_hot_to_bin  = 6'd43;
            oh_in[42]   : one_hot_to_bin  = 6'd42;
            oh_in[41]   : one_hot_to_bin  = 6'd41;
            oh_in[40]   : one_hot_to_bin  = 6'd40;
            oh_in[39]   : one_hot_to_bin  = 6'd39;
            oh_in[38]   : one_hot_to_bin  = 6'd38;
            oh_in[37]   : one_hot_to_bin  = 6'd37;
            oh_in[36]   : one_hot_to_bin  = 6'd36;
            oh_in[35]   : one_hot_to_bin  = 6'd35;
            oh_in[34]   : one_hot_to_bin  = 6'd34;
            oh_in[33]   : one_hot_to_bin  = 6'd33;
            oh_in[32]   : one_hot_to_bin  = 6'd32;
            oh_in[31]   : one_hot_to_bin  = 6'd31;
            oh_in[30]   : one_hot_to_bin  = 6'd30;
            oh_in[29]   : one_hot_to_bin  = 6'd29;
            oh_in[28]   : one_hot_to_bin  = 6'd28;
            oh_in[27]   : one_hot_to_bin  = 6'd27;
            oh_in[26]   : one_hot_to_bin  = 6'd26;
            oh_in[25]   : one_hot_to_bin  = 6'd25;
            oh_in[24]   : one_hot_to_bin  = 6'd24;
            oh_in[23]   : one_hot_to_bin  = 6'd23;
            oh_in[22]   : one_hot_to_bin  = 6'd22;
            oh_in[21]   : one_hot_to_bin  = 6'd21;
            oh_in[20]   : one_hot_to_bin  = 6'd20;
            oh_in[19]   : one_hot_to_bin  = 6'd19;
            oh_in[18]   : one_hot_to_bin  = 6'd18;
            oh_in[17]   : one_hot_to_bin  = 6'd17;
            oh_in[16]   : one_hot_to_bin  = 6'd16;
            oh_in[15]   : one_hot_to_bin  = 6'd15;
            oh_in[14]   : one_hot_to_bin  = 6'd14;
            oh_in[13]   : one_hot_to_bin  = 6'd13;
            oh_in[12]   : one_hot_to_bin  = 6'd12;
            oh_in[11]   : one_hot_to_bin  = 6'd11;
            oh_in[10]   : one_hot_to_bin  = 6'd10;
            oh_in[9]   : one_hot_to_bin  = 6'd9;
            oh_in[8]   : one_hot_to_bin  = 6'd8;
            oh_in[7]   : one_hot_to_bin  = 6'd7;
            oh_in[6]   : one_hot_to_bin  = 6'd6;
            oh_in[5]   : one_hot_to_bin  = 6'd5;
            oh_in[4]   : one_hot_to_bin  = 6'd4;
            oh_in[3]   : one_hot_to_bin  = 6'd3;
            oh_in[2]   : one_hot_to_bin  = 6'd2;
            oh_in[1]   : one_hot_to_bin  = 6'd1;
            oh_in[0]   : one_hot_to_bin  = 6'd0;
            default    : one_hot_to_bin  = 6'dx;
        endcase
    endfunction

endmodule
