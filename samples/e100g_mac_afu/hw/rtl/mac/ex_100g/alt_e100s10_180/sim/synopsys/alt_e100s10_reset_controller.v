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
module alt_e100s10_reset_controller (
    input       rst_clk,
    input       rx_clk,
    input       tx_clk,

    // Asynchronous inputs
    input       csr_rst_in,                 // Triggers CSR reset
    input       xcvr_rx_dig_rst_in,         // Triggers RX digital reset
    input       sys_rst,                    // Resets everything
    input       rx_rst,                     // Reset RX PCS and MAC
    input       tx_rst,                     // Reset TX PCS and MAC
    input       rx_pcs_ready_in,            // Ready signal from RX PCS
    input       rx_ready,                   // rx_ready signal from native phy reset controller
    input [3:0] tx_digitalreset,            // From native phy reset controller
    input       tx_fabric_pll_locked,       // PLL locked signal from TX MAC fPLL
    input       tx_clk_stable,
    input       rx_pcs_pll_locked,          // RX PCS PLL is locked
    input [3:0] tx_dll_lock,
    input [3:0] tx_digitalreset_stat,
    input       tx_data_valid_core,         // one cycle early
    output reg [3:0] tx_data_valid_pma,

    // Inputs synchronous to rst_clk
    input       soft_rx_rst,                // Reset RX PCS and MAC
    input       soft_tx_rst,                // Reset TX PCS and MAC

    // Outputs falling edge synchronous to rst_clk
    output      csr_rst_out,                // Drives CSR reset
    output      xcvr_rx_dig_rst_out,        // Used to trigger rx_digitalreset
    output      native_phy_reset,           // Used to reset native phy reset controller
    output      xcvr_rx_sclr,               // RX transeiver only reset synced on RX clock

    // Outputs falling edge synchronous to rx_clk
    output      rx_pcs_sclr,                 // Used to drive RX PCS reset
    output reg     rx_mac_sclr,                 // Used to drive RX MAC reset, sync reset in rx_clk domain

    // Outputs rising edge synchronous to rx_clk
    output  reg rx_pcs_ready_out,           // RX PCS ready
    output  reg tx_lanes_stable,

    // Outputs falling edge synchronous to tx_clk
    output      tx_pcs_sclr,                 // Used to drive TX PCS reset
    output      tx_mac_sclr                  // Used to drive TX MAC reset
);

    // 
    wire    [3:0]   tx_dll_lock_sync;
    wire    [3:0]   tx_digitalreset_stat_sync;
    alt_e100s10_synchronizer tx_sync(
        .clk        (tx_clk),
        .din        ({tx_dll_lock, tx_digitalreset_stat}),
        .dout       ({tx_dll_lock_sync, tx_digitalreset_stat_sync})
    );
    defparam tx_sync .WIDTH = 8;

    always @(posedge tx_clk) begin
        //tx_data_valid_pma   <=  (tx_dll_lock_sync & tx_digitalreset_stat_sync) | {4{tx_data_valid_core}};
        tx_data_valid_pma   <= tx_dll_lock_sync;
    end

    // CSR reset. Asserted when csr_rst_in is asserted.
    alt_e100s10_reset_synchronizer csr_rst_sync (
        .clk        (rst_clk),
        .aclr       (csr_rst_in),
        .aclr_sync  (csr_rst_out)
    );

    // Assert rx_digitalreset when requested.
    alt_e100s10_reset_synchronizer rx_digital_rst_sync (
        .clk        (rst_clk),
        .aclr       (xcvr_rx_dig_rst_in),
        .aclr_sync  (xcvr_rx_dig_rst_out)
    );

    // Triggers a native phy reset
    wire trigger_phy_reset = sys_rst || csr_rst_in;
    alt_e100s10_reset_synchronizer phy_rst_sync (
        .clk        (rst_clk),
        .aclr       (trigger_phy_reset),
        .aclr_sync  (native_phy_reset)
    );

    alt_e100s10_reset_synchronizer xcvr_rst_sync (
        .clk        (rx_clk),
        .aclr       (trigger_phy_reset),
        .aclr_sync  (xcvr_rx_sclr)
    );




    // Triggers RX PCS reset in event of rx_rst or loss of rx_pcs_pll_locked or
    // rx_digitalreset which is triggered through sys_rst
    wire trigger_rx_pcs_reset = soft_rx_rst || rx_rst || !rx_ready || !rx_pcs_pll_locked;
    alt_e100s10_reset_synchronizer rx_pcs_rst_sync (
        .clk        (rx_clk),
        .aclr       (trigger_rx_pcs_reset),
        .aclr_sync  (rx_pcs_sclr)
    );

// pcs and mac resets
always @(posedge rx_clk) begin
    rx_mac_sclr <= rx_pcs_sclr | ~rx_pcs_ready_in;
end

    // Triggers TX PCS reset in event of tx_rst or
    wire trigger_tx_pcs_reset = tx_rst || soft_tx_rst || (|tx_digitalreset) || !tx_fabric_pll_locked;
    alt_e100s10_reset_synchronizer tx_pcs_rst_sync (
        .clk        (tx_clk),
        .aclr       (trigger_tx_pcs_reset),
        .aclr_sync  (tx_pcs_sclr)
    );

assign tx_mac_sclr = tx_pcs_sclr;

    // RX PCS ready signal indicated by reset controller
    always @(posedge rx_clk or posedge rx_pcs_sclr) begin
        if (rx_pcs_sclr) begin
            rx_pcs_ready_out <= 1'b0;
        end else begin
            rx_pcs_ready_out <= rx_pcs_ready_in;
        end
    end

    // synchronizing tx_clk_stable and tx_rst to rst_clk
    wire    tx_clk_stable_sync;
    wire    tx_rst_sync;
    alt_e100s10_synchronizer rst_clk_sync(
        .clk        (rst_clk),
        .din        ({tx_clk_stable, tx_rst}),
        .dout       ({tx_clk_stable_sync, tx_rst_sync})
    );
    defparam rst_clk_sync .WIDTH = 2;

    always @(posedge rst_clk) begin
        tx_lanes_stable  <=  tx_clk_stable_sync & (~tx_rst_sync) & (~soft_tx_rst);
    end

endmodule
