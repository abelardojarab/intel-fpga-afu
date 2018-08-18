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
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module alt_e100s10_sync_read #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
) (
    input                       master_rst,
    input                       master_clk,
    input   [ADDR_WIDTH-1:0]    master_address,
    input                       master_read,
    output  [DATA_WIDTH-1:0]    master_data,
    output reg                  master_wait,
    output reg                  master_valid,

    input                       slave_clk,
    input                       clk_locked_sync,
    //input                       slave_clk_locked,
    output  [ADDR_WIDTH-1:0]    slave_address,
    input   [DATA_WIDTH-1:0]    slave_data
);

    localparam  MASTER_IDLE             = 2'd0,
                MASTER_WAIT_GRANT_HIGH  = 2'd1,
                MASTER_WAIT_GRANT_LOW   = 2'd2,
                MASTER_DATA_VALID       = 2'd3;

    reg [1:0]   master_state, master_state_next;

    reg [DATA_WIDTH-1:0]    master_data_reg;

    reg         master_request;
    wire        master_request_sync;

    wire        slave_grant;
    wire        slave_grant_sync;

    //wire        clk_locked_sync;
    reg [3:0]   timer;
    reg         slave_clk_rdy;

    // Master state machine
    always @(posedge master_clk) begin
        if (master_rst) begin
            master_state <= MASTER_IDLE;
        end else begin
            master_state <= master_state_next;
        end
    end

    always @(*) begin
        master_state_next   = master_state;
        case (master_state)
            MASTER_IDLE             : begin
                if (master_read) master_state_next = MASTER_WAIT_GRANT_HIGH;
            end
            MASTER_WAIT_GRANT_HIGH  : begin
                if (!slave_clk_rdy) begin    // No MAC clk. Go strait to valid to prevent avmm lockup
                    master_state_next = MASTER_DATA_VALID;
                end else if (slave_grant_sync) begin
                    master_state_next = MASTER_WAIT_GRANT_LOW;
                end
            end
            MASTER_WAIT_GRANT_LOW   : begin
                if (!slave_grant_sync || !slave_clk_rdy) begin
                    master_state_next = MASTER_DATA_VALID;
                end
            end
            MASTER_DATA_VALID       : begin
                master_state_next = MASTER_IDLE;
            end
        endcase
    end

    // Request generation
    always @(posedge master_clk) begin
        case (master_state)
            MASTER_WAIT_GRANT_HIGH  : master_request <= 1'b1;
            default                 : master_request <= 1'b0;
        endcase
    end

    // Wait and valid generation
    always @(posedge master_clk) begin
        master_valid    <= 1'b0;
        master_wait     <= 1'b1;
        case (master_state)
            MASTER_WAIT_GRANT_HIGH  : begin
                if (!slave_clk_rdy) begin
                    master_wait <= 1'b0;
                end
            end
            MASTER_WAIT_GRANT_LOW   : begin
                if (!slave_grant_sync || !slave_clk_rdy) begin
                    master_wait <= 1'b0;
                end
            end
            MASTER_DATA_VALID       : begin
                master_valid    <= 1'b1;
            end
        endcase
    end

    // Slave clock locked ready timer.
    always @(posedge master_clk) begin
        if (master_rst) begin
            timer           <= 1'b0;
            slave_clk_rdy   <= 1'b0;
        end else begin
            if (clk_locked_sync) begin
                if (timer == 4'd15) begin
                    timer           <= timer;
                    slave_clk_rdy   <= 1'b1;
                end else begin
                    timer           <= timer + 1'b1;
                    slave_clk_rdy   <= 1'b0;
                end
            end else begin
                timer           <= 1'b0;
                slave_clk_rdy   <= 1'b0;
            end
        end
    end

    // Latch up data on rising edge of request
    reg master_request_sync_reg;
    always @(posedge slave_clk) begin
        master_request_sync_reg <= master_request_sync;
        if ((master_request_sync_reg == 1'b0) && (master_request_sync == 1'b1)) begin
            master_data_reg <= slave_data;
        end
    end
    assign slave_grant = master_request_sync;

    alt_e100s10_synchronizer #(.WIDTH (1)) sync_r (
        .clk    (slave_clk),
        .din    (master_request),
        .dout   (master_request_sync)
    );

    alt_e100s10_synchronizer #(.WIDTH (1)) sync_g (
        .clk    (master_clk),
        .din    (slave_grant),
        .dout   (slave_grant_sync)
    );
/*
    alt_e100s10_synchronizer #(.WIDTH (1)) sync_l (
        .clk    (master_clk),
        .din    (slave_clk_locked),
        .dout   (clk_locked_sync)
    );
*/
    assign master_data = master_data_reg;
    assign slave_address = master_address;  // Synchronization handled by handshake protocol
endmodule
