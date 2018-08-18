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
module alt_e100s10_pulse_transfer (
    input      clk_in,
    input      pulse_in,
    input      clk_out,
    output reg pulse_out
);

    reg [1:0] in_state;
    reg       data_valid;
    wire      data_ack_sync;
    localparam IN_WAIT_HIGH = 0,
               IN_WAIT_LOW  = 1,
               IN_WAIT_ACK  = 2,
               IN_WAIT_UNACK = 3;

    always @(posedge clk_in) begin
        in_state <= in_state;
        data_valid <= 1'b0;
        case (in_state)
            IN_WAIT_HIGH: begin
                if (pulse_in) in_state <= IN_WAIT_LOW;
            end
            IN_WAIT_LOW: begin
                if (!pulse_in) in_state <= IN_WAIT_ACK;
            end
            IN_WAIT_ACK: begin
                data_valid <= 1'b1;
                if (data_ack_sync) in_state <= IN_WAIT_UNACK;
            end
            IN_WAIT_UNACK: begin
                if (!data_ack_sync) in_state <= IN_WAIT_HIGH;
            end
            default: in_state <= IN_WAIT_HIGH;
        endcase
    end

    reg data_ack;
    alt_e100s10_synchronizer #(.WIDTH(1)) sn_a (
        .clk(clk_in),
        .din(data_ack),
        .dout(data_ack_sync)
    );

    wire data_valid_sync;
    alt_e100s10_synchronizer #(.WIDTH(1)) sn_v (
        .clk(clk_out),
        .din(data_valid),
        .dout(data_valid_sync)
    );

    reg [1:0] out_state;
    localparam OUT_WAIT_VALID   = 0,
               OUT_WAIT_PULSE   = 1,
               OUT_WAIT_UNVALID = 2;

    always @(posedge clk_out) begin
        out_state <= out_state;
        pulse_out <= 1'b0;
        data_ack  <= 1'b0;
        case (out_state)
            OUT_WAIT_VALID: begin
                if (data_valid_sync) out_state <= OUT_WAIT_PULSE;
            end
            OUT_WAIT_PULSE: begin
                data_ack  <= 1'b1;
                pulse_out <= 1'b1;
                out_state <= OUT_WAIT_UNVALID;
            end
            OUT_WAIT_UNVALID: begin
                data_ack  <= 1'b1;
                if (!data_valid_sync) out_state <= OUT_WAIT_VALID;
            end
            default: out_state <= OUT_WAIT_VALID;
        endcase
    end
endmodule
