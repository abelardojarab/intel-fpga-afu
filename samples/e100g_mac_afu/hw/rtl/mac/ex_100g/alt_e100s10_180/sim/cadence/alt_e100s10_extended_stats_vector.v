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


`timescale 1ns / 1ns
// Module to derive extended stats vector from
// MAC stats vector.
// Latency = 4 cycles

module alt_e100s10_extended_stats_vector (
    input clk,
    input [41:0] status_data_vector,
    input crc_error,                     // Calculated CRC doesn't match CRC field
    input undersized_frame,              // frame size < 64b
    input oversized_frame_in,            // frame size > max frame size
    input payload_len_error,             // frame size < size field
    input valid_in,

    output fragmented_frame,             // undersized and CRC error
    output jabbered_frame,               // oversized and CRC error
    output crc_errored_frame,            // CRC error and frame_len >= 64b
    output fcs_errored_frame,            // CRC error only
    output invalid_sop,            // there are more than one sop in one data (256 bit)
    output invalid_eop,            // there are more than one eop in one data (256 bit)

    output frame_len_64b,
    output frame_len_65to127b,
    output frame_len_128to255b,
    output frame_len_256to511b,
    output frame_len_512to1023b,
    output frame_len_1024to1518b,
    output frame_len_1519tomax,
    output frame_oversized,

    output mcast_data_err,               // multicast   & CRC error & data
    output bcast_data_err,               // broadcast   & CRC error & data
    output ucast_data_err,               // unicastcast & CRC error & data
    output mcast_ctrl_err,               // multicast   & CRC error & control
    output bcast_ctrl_err,               // broadcast   & CRC error & control
    output ucast_ctrl_err,               // unicastcast & CRC error & control
    output pause_err,                    // pause       & CRC error

    output mcast_data_ok,                // multicast   & CRC ok & data
    output bcast_data_ok,                // broadcast   & CRC ok & data
    output ucast_data_ok,                // unicastcast & CRC ok & data
    output mcast_ctrl_ok,                // multicast   & CRC ok & control
    output bcast_ctrl_ok,                // broadcast   & CRC ok & control
    output ucast_ctrl_ok,                // unicastcast & CRC ok & control
    output pause_ok,                     // pause       & CRC ok

    output runt,                         // undersized with/without CRC error;	//hua; undersized & CRC error
    output error,                        // Any error
    output [15:0] octetsOK_payload,  // Payload octets not in error
    output [15:0] octetsOK_frame,    // Frame octets not in error

    output valid_out
);

    wire [15:0] payload_len      = status_data_vector [15:0];
    wire [15:0] frame_len        = status_data_vector [31:16];
    // wire        stacked_vlan     = status_data_vector [32]; // Unused
    // wire        vlan_frame       = status_data_vector [33]; // Unused
    wire        control_frame    = status_data_vector [34];
    wire        pause            = status_data_vector [35];
    wire        broadcast        = status_data_vector [36];
    wire        multicast        = status_data_vector [37];
    wire        unicast          = status_data_vector [38];
    // wire        pfc_frame        = status_data_vector [39]; // Unused
    assign        invalid_sop    = status_data_vector [40];
    assign        invalid_eop    = status_data_vector [41];
    wire [3:0]  error_signals    = {crc_error,
                                    undersized_frame,
                                    oversized_frame_in,
                                    payload_len_error};

    // jabbered_frame,          // oversized and CRC error
    reg jabbered_int;
    always @(posedge clk) begin
        jabbered_int <= crc_error && oversized_frame_in;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) d_jab (
        .clk(clk),
        .din (jabbered_int),
        .dout(jabbered_frame)
    );

    // crc_errored_frame,       // CRC error and frame_len >= 64b
    reg crc_error_int;
    always @(posedge clk) begin
        crc_error_int <= crc_error && !undersized_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) d_crc (
        .clk(clk),
        .din (crc_error_int),
        .dout(crc_errored_frame)
    );

    // fcs_errored_frame,       // CRC error only
    alt_e100s10_delay_regs #(
	.LATENCY(4), .WIDTH(1)
    ) d_fcs (
        .clk(clk),
        .din (crc_error),
        .dout(fcs_errored_frame)
    );

    // frame_len_64b,
    wire frame_len_64b_int;
    alt_e100s10_frame_64b f64 (
        .clk     (clk),
        .size    (frame_len),
        .size64  (frame_len_64b_int)
    );

    alt_e100s10_delay_regs #( .LATENCY(2), .WIDTH(1) ) d_64 (
        .clk(clk),
        .din (frame_len_64b_int),
        .dout(frame_len_64b)
    );

    // frame_len_65to127b,
    alt_e100s10_frame_65to127b f65to127 (
        .clk            (clk),
        .size           (frame_len),
        .size65to127    (frame_len_65to127b)
    );

    // frame_len_128to255b,
    wire frame_len_128to255b_int;
    alt_e100s10_frame_128to255b f128to255 (
        .clk            (clk),
        .size           (frame_len),
        .size128to255   (frame_len_128to255b_int)
    );

    alt_e100s10_delay_regs #( .LATENCY(2), .WIDTH(1) ) d_128_255 (
        .clk(clk),
        .din (frame_len_128to255b_int),
        .dout(frame_len_128to255b)
    );

    // frame_len_256to511b,
    wire frame_len_256to511b_int;
    alt_e100s10_frame_256to511b f256to511 (
        .clk            (clk),
        .size           (frame_len),
        .size256to511   (frame_len_256to511b_int)
    );

    alt_e100s10_delay_regs #( .LATENCY(2), .WIDTH(1) ) d_256_511 (
        .clk(clk),
        .din (frame_len_256to511b_int),
        .dout(frame_len_256to511b)
    );

    // frame_len_512to1023b,
    wire frame_len_512to1023b_int;
    alt_e100s10_frame_512to1023b f512to1023 (
        .clk            (clk),
        .size           (frame_len),
        .size512to1023  (frame_len_512to1023b_int)
    );

    alt_e100s10_delay_regs #( .LATENCY(2), .WIDTH(1) ) d_512_1023 (
        .clk(clk),
        .din (frame_len_512to1023b_int),
        .dout(frame_len_512to1023b)
    );

    // frame_len_1024to1518b,
    alt_e100s10_frame_1024to1518b f1024to1518 (
        .clk            (clk),
        .size           (frame_len),
        .size1024to1518b(frame_len_1024to1518b)
    );

    // frame_len_1519tomax,
    alt_e100s10_frame_1519tomax f1519max (
        .clk            (clk),
        .size           (frame_len),
        .oversized      (oversized_frame_in),
        .size_1519tomax (frame_len_1519tomax)
    );

    // frame_oversized,
    alt_e100s10_delay_regs #( .LATENCY(4), .WIDTH(1) ) dr_os (
        .clk(clk),
        .din (oversized_frame_in),
        .dout(frame_oversized)
    );

    // mcast_data_err,           // multicast   & CRC err & data
    reg mcast_data_err_int;
    always @(posedge clk) begin
        mcast_data_err_int <= multicast && crc_error && !control_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_mc_data_err (
        .clk(clk),
        .din (mcast_data_err_int),
        .dout(mcast_data_err)
    );


    // bcast_data_err,           // broadcast   & CRC err & data
    reg bcast_data_err_int;
    always @(posedge clk) begin
        bcast_data_err_int <= broadcast && crc_error && !control_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_bc_data_err (
        .clk(clk),
        .din (bcast_data_err_int),
        .dout(bcast_data_err)
    );

    // ucast_data_err,           // unicastcast & CRC err & data
    reg ucast_data_err_int;
    always @(posedge clk) begin
        ucast_data_err_int <= unicast && crc_error && !control_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_uc_data_err (
        .clk(clk),
        .din (ucast_data_err_int),
        .dout(ucast_data_err)
    );

    // mcast_ctrl_err,           // multicast   & CRC err & control
    reg mcast_ctrl_err_int;
    always @(posedge clk) begin
        mcast_ctrl_err_int <= multicast && crc_error && control_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_mc_ctrl_err (
        .clk(clk),
        .din (mcast_ctrl_err_int),
        .dout(mcast_ctrl_err)
    );


    // bcast_ctrl_err,           // broadcast   & CRC err & control
    reg bcast_ctrl_err_int;
    always @(posedge clk) begin
        bcast_ctrl_err_int <= broadcast && crc_error && control_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_bc_ctrl_err (
        .clk(clk),
        .din (bcast_ctrl_err_int),
        .dout(bcast_ctrl_err)
    );

    // ucast_ctrl_err,           // unicastcast & CRC err & control
    reg ucast_ctrl_err_int;
    always @(posedge clk) begin
        ucast_ctrl_err_int <= unicast && crc_error && control_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_uc_ctrl_err (
        .clk(clk),
        .din (ucast_ctrl_err_int),
        .dout(ucast_ctrl_err)
    );

    // pause_err,               // pause       & CRC error
    reg pause_err_int;
    always @(posedge clk) pause_err_int <= pause && crc_error;
    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_pause_err (
        .clk(clk),
        .din(pause_err_int), .dout(pause_err)
    );

    // mcast_data_ok,           // multicast   & CRC ok & data
    reg mcast_data_ok_int;
    always @(posedge clk) begin
        mcast_data_ok_int <= multicast && !crc_error && !control_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_mc_data_ok (
        .clk(clk),
        .din (mcast_data_ok_int),
        .dout(mcast_data_ok)
    );


    // bcast_data_ok,           // broadcast   & CRC ok & data
    reg bcast_data_ok_int;
    always @(posedge clk) begin
        bcast_data_ok_int <= broadcast && !crc_error && !control_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_bc_data_ok (
        .clk(clk),
        .din (bcast_data_ok_int),
        .dout(bcast_data_ok)
    );

    // ucast_data_ok,           // unicastcast & CRC ok & data
    reg ucast_data_ok_int;
    always @(posedge clk) begin
        ucast_data_ok_int <= unicast && !crc_error && !control_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_uc_data_ok (
        .clk(clk),
        .din (ucast_data_ok_int),
        .dout(ucast_data_ok)
    );

    // mcast_ctrl_ok,           // multicast   & CRC ok & control
    reg mcast_ctrl_ok_int;
    always @(posedge clk) begin
        mcast_ctrl_ok_int <= multicast && !crc_error && control_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_mc_ctrl_ok (
        .clk(clk),
        .din (mcast_ctrl_ok_int),
        .dout(mcast_ctrl_ok)
    );


    // bcast_ctrl_ok,           // broadcast   & CRC ok & control
    reg bcast_ctrl_ok_int;
    always @(posedge clk) begin
        bcast_ctrl_ok_int <= broadcast && !crc_error && control_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_bc_ctrl_ok (
        .clk(clk),
        .din (bcast_ctrl_ok_int),
        .dout(bcast_ctrl_ok)
    );

    // ucast_ctrl_ok,           // unicastcast & CRC ok & control
    reg ucast_ctrl_ok_int;
    always @(posedge clk) begin
        ucast_ctrl_ok_int <= unicast && !crc_error && control_frame;
    end

    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_uc_ctrl_ok (
        .clk(clk),
        .din (ucast_ctrl_ok_int),
        .dout(ucast_ctrl_ok)
    );

    // pause_ok,                // pause       & CRC ok
    reg pause_ok_int;
    always @(posedge clk) pause_ok_int <= pause && !crc_error;
    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_pause_ok (
        .clk(clk),
        .din(pause_ok_int), .dout(pause_ok)
    );

    // runt,                    // all undersized; with/without CRC error;    //hua; // undersized & CRC error
    reg runt_int;
    always @(posedge clk) runt_int <= undersized_frame;		//hua; && crc_error;
    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_runt (
        .clk(clk),
        .din(runt_int),    .dout(runt)
    );

    // error
    reg error_int;
    always @(posedge clk) error_int <= (error_signals != 4'b0000);
    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_err (
        .clk(clk),
        .din(error_int),    .dout(error)
    );

    // Valid signal
    alt_e100s10_delay_regs #( .LATENCY(4), .WIDTH(1) ) dr_valid (
        .clk(clk),
        .din(valid_in),     .dout(valid_out)
    );

    // Fragmented frames
    reg fragmented_frame_int;
    always @(posedge clk) begin
        fragmented_frame_int <= (undersized_frame && crc_error);
    end
    alt_e100s10_delay_regs #( .LATENCY(3), .WIDTH(1) ) dr_ff (
        .clk(clk),
        .din(fragmented_frame_int),
        .dout(fragmented_frame)
    );

    // payload octetsOK
    wire [15:0] octetsOK_payload_int;
    alt_e100s10_octets_ok oop (
        .clk                (clk),
        .payload_size       (payload_len),
        .fcs_error          (crc_error),
        .undersized         (undersized_frame),
        .oversized          (oversized_frame_in),
        .payload_len_error  (payload_len_error),
        .octetsOK           (octetsOK_payload_int)
    );
    alt_e100s10_delay_regs #( .WIDTH(16), .LATENCY(2) ) dr_oop (
        .clk(clk),
        .din(octetsOK_payload_int),
        .dout(octetsOK_payload)
    );

    // frame octetsOK
    wire [15:0] octetsOK_frame_int;
    alt_e100s10_octets_ok oof (
        .clk                (clk),
        .payload_size       (frame_len),
        .fcs_error          (crc_error),
        .undersized         (undersized_frame),
        .oversized          (oversized_frame_in),
        .payload_len_error  (payload_len_error),
        .octetsOK           (octetsOK_frame_int)
    );
    alt_e100s10_delay_regs #( .WIDTH(16), .LATENCY(2) ) dr_oof (
        .clk(clk),
        .din(octetsOK_frame_int),
        .dout(octetsOK_frame)
    );
endmodule

//-----------------------------------------------
// 2 cycle delay
module alt_e100s10_frame_64b (
    input           clk,
    input  [15:0]   size,
    output reg      size64
);
 
    // 64 = 0x40 = 0b 0000 0000 0100 0000
    reg upper_test, mid_test, lower_test;
    always @(posedge clk) begin
        upper_test <= (size[15:11] == 5'b00000 );
        mid_test   <= (size[10:6]  == 5'b00001 );
        lower_test <= (size[5:0]   == 6'b000000);
        size64 <= (upper_test && mid_test && lower_test);
    end
endmodule

//-----------------------------------------------
// 2 cycle delay
module alt_e100s10_frame_65to127b (
    input           clk,
    input  [15:0]   size,
    output reg      size65to127
);
 
    wire gte65;
    alt_e100s10_gte_with_const_16b #(
        .CONST_VAL(65)
    ) gte65_0 (
        .clk(clk),
        .din(size),
        .gte(gte65)
    );
 
    wire lte127;
    alt_e100s10_lte_with_const_16b #(
        .CONST_VAL(127)
    ) lte127_0 (
        .clk(clk),
        .din(size),
        .lte(lte127)
    );
 
    always @(posedge clk) begin
        size65to127 <= lte127 && gte65;
    end
endmodule


//-----------------------------------------------
// 2 cycle delay
module alt_e100s10_frame_128to255b (
    input           clk,
    input  [15:0]   size,
    output reg      size128to255
);
 
    // 128 = 0x80 = 0b 0000 0000 1000 0000
    // 255 = 0xFF = 0b 0000 0000 1111 1111
 
    reg upper_test, lower_test;
    always @(posedge clk) begin
        upper_test    <= (size[15:11] == 5'b00000);
        lower_test    <= (size[10:7]  == 4'b0001);
        size128to255  <= upper_test && lower_test;
    end
endmodule

//-----------------------------------------------
// 2 cycle delay
module alt_e100s10_frame_256to511b (
    input           clk,
    input  [15:0]   size,
    output reg      size256to511
);
 
    // 256 = 0x100 = 0b 0000 0001 0000 0000
    // 511 = 0x1FF = 0b 0000 0001 1111 1111
 
    reg upper_test, lower_test;
    always @(posedge clk) begin
        upper_test    <= (size[15:12] == 4'b0000);
        lower_test    <= (size[11:8]  == 4'b0001);
        size256to511  <= upper_test && lower_test;
    end
endmodule

//-----------------------------------------------
// 2 cycle delay
module alt_e100s10_frame_512to1023b (
    input clk,
    input [15:0] size,
    output reg size512to1023
);
 
    // 512  = 0x200 = 0b 0000 0010 0000 0000
    // 1023 = 0x3FF = 0b 0000 0011 1111 1111
 
    reg upper_test, lower_test;
    always @(posedge clk) begin
        upper_test    <= (size[15:12] == 4'b0000);
        lower_test    <= (size[11:9]  == 3'b001);
        size512to1023 <= upper_test && lower_test;
    end
endmodule

//-----------------------------------------------
// 4 cycle delay
module alt_e100s10_frame_1024to1518b (
    input           clk,
    input  [15:0]   size,
    output reg      size1024to1518b
);
 
    wire gte1024;
    alt_e100s10_gte_with_const_16b #(
        .CONST_VAL(1024)
    ) gte1024_0 (
        .clk(clk),
        .din(size),
        .gte(gte1024)
    );
 
    wire lte1518;
    alt_e100s10_lte_with_const_16b #(
        .CONST_VAL(1518)
    ) lte1518_0 (
        .clk(clk),
        .din(size),
        .lte(lte1518)
    );
 
    always @(posedge clk) begin
        size1024to1518b <= lte1518 && gte1024;
    end
endmodule

//-----------------------------------------------
// 4 cycle delay
module alt_e100s10_frame_1519tomax (
    input           clk,
    input  [15:0]   size,
    input           oversized,
    output reg      size_1519tomax
);
 
    wire size_gte_1519;
    alt_e100s10_gte_with_const_16b #(
        .CONST_VAL(1519)
    ) gte1519 (
        .clk(clk),
        .din(size),
        .gte(size_gte_1519)
    );
 
    wire oversized_delay;
    alt_e100s10_delay_regs #(
        .LATENCY(3), .WIDTH(1)
    ) dr_os (
        .clk(clk),
        .din(oversized),
        .dout(oversized_delay)
    );
 
    always @(posedge clk) begin
        size_1519tomax <= (size_gte_1519 && !oversized_delay);
    end
endmodule

//-----------------------------------------------
// 2 cycle delay
module alt_e100s10_octets_ok (
    input clk,
    input [15:0] payload_size,
    input fcs_error,
    input undersized,
    input oversized,
    input payload_len_error,
    output reg [15:0] octetsOK
);
 
    reg [15:0] payload_size_delay;
    reg        frameOK;
    always @(posedge clk) begin
        payload_size_delay <= payload_size;
        frameOK            <= !(fcs_error || undersized || oversized || payload_len_error);
        octetsOK           <= frameOK ? payload_size_delay : 16'd0;
    end
endmodule
