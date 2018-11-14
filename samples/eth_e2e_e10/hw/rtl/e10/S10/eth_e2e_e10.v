// *****************************************************************************
//
//                            INTEL CONFIDENTIAL
//
//           Copyright (C) 2017 Intel Corporation All Rights Reserved.
//
// The source code contained or described herein and all  documents related to
// the  source  code  ("Material")  are  owned  by  Intel  Corporation  or its
// suppliers  or  licensors.    Title  to  the  Material  remains  with  Intel
// Corporation or  its suppliers  and licensors.  The Material  contains trade
// secrets  and  proprietary  and  confidential  information  of  Intel or its
// suppliers and licensors.  The Material is protected  by worldwide copyright
// and trade secret laws and treaty provisions. No part of the Material may be
// used,   copied,   reproduced,   modified,   published,   uploaded,  posted,
// transmitted,  distributed,  or  disclosed  in any way without Intel's prior
// express written permission.
//
// No license under any patent,  copyright, trade secret or other intellectual
// property  right  is  granted  to  or  conferred  upon  you by disclosure or
// delivery  of  the  Materials, either expressly, by implication, inducement,
// estoppel or otherwise.  Any license under such intellectual property rights
// must be express and approved by Intel in writing.
//
// *****************************************************************************
// baeckler - 05-11-2016
// maguirre - Apr/2017
//          - Edited for ETH E2E validation project
// ecustodi - Feb/2018 modifications for DCP testing

module eth_e2e_e10 #(
    parameter NUM_HSSI_RAW_PR_IFCS = 1,
    parameter NUM_LN = 4
)(
	pr_hssi_if.to_fiu   hssi[NUM_HSSI_RAW_PR_IFCS],

    input clk,      // 100MHz
    input reset,

    // ETH CSR ports
    input  [31:0] eth_ctrl_addr,
    input  [31:0] eth_wr_data, 
    output [31:0] eth_rd_data,   
    input         csr_init_start,
    output        csr_init_done
);

localparam [23:0] GBS_ID = "E2E";
localparam [7:0] GBS_VER = 8'h10;

localparam NUM_ETH = NUM_HSSI_RAW_PR_IFCS*NUM_LN;

reg [31:0] scratch = {GBS_ID, GBS_VER};
reg [31:0] prmgmt_dout_r = 32'h0;

reg [NUM_ETH-1:0] sloop;

////////////////////////////////////////////////////////////////////////////////
// MUX for HSSI PR MGMT bus access 
////////////////////////////////////////////////////////////////////////////////

reg  [15:0] prmgmt_cmd;
reg  [15:0] prmgmt_addr;   
reg  [31:0] prmgmt_din;   

always @(posedge clk)
begin
    // RD/WR request from AFU CSR
	prmgmt_cmd <= 16'b0;

    if (eth_ctrl_addr[17] | eth_ctrl_addr[16])
    begin
        prmgmt_cmd  <= eth_ctrl_addr[31:16];
        prmgmt_addr <= eth_ctrl_addr[15: 0];
        prmgmt_din  <= eth_wr_data;
    end
end

assign eth_rd_data   = prmgmt_dout_r;
assign csr_init_done = 1'b1;


////////////////////////////////////////////////////////////////////////////////
// PRMGMT registers for I2C controllers
////////////////////////////////////////////////////////////////////////////////

reg  [15:0] i2c_ctrl_wdata_r;
reg  [15:0] i2c_stat_rdata  ;
wire [15:0] i2c_stat_rdata_0;
wire [15:0] i2c_stat_rdata_1;
reg  [ 1:0] i2c_inst_sel_r  ;


////////////////////////////////////////////////////////////////////////////////
// MAC signals
////////////////////////////////////////////////////////////////////////////////

reg  [0:0] status_write = 0 /* synthesis preserve */;
reg  [0:0] status_read = 0 /* synthesis preserve */;
reg  [15:0] status_addr = 0 /* synthesis preserve */;
reg  [31:0] status_writedata = 0 /* synthesis preserve */;

wire  [31:0] status_readdata ;
wire  [0:0] status_readdata_valid;
wire  [0:0] status_waitrequest;
wire  [0:0] status_read_timeout;

reg csr_rst = 1'b1;
reg rx_rst = 1'b1;
reg tx_rst = 1'b1;
wire [NUM_ETH-1:0] tx_ready_export;
wire [NUM_ETH-1:0] rx_ready_export;
reg [2:0] port_sel = 3'b0;

wire [NUM_ETH*32-1:0] all_csr_rdata;

////////////////////////////////////
// Ethernet MAC 
////////////////////////////////////

genvar i;
generate
    for (i=0; i<NUM_ETH; i=i+1) begin : lp0
        wire [7:0]     xgmii_tx_control;
        wire [63:0]    xgmii_tx_data;
        wire [7:0]     xgmii_rx_control;
        wire [63:0]    xgmii_rx_data;
        wire           rx_enh_data_valid;
        wire           tx_enh_data_valid;
        wire err_ins = 1'b0;

        if (!sloop[i])
        begin
            // TODO: hssi[0] if lanes 0-3, hssi[1] if lanes 4-7
            assign xgmii_rx_control[3:0] = hssi[0].f2a_rx_parallel_data [(i*80)+35:(i*80)+32];
            assign xgmii_rx_control[7:4] = hssi[0].f2a_rx_parallel_data [(i*80)+77:(i*80)+72];     // 9th and 10th bits unused
            assign xgmii_rx_data[31:0] = hssi[0].f2a_rx_parallel_data [(i*80)+31:(i*80)];
            assign xgmii_rx_data[63:32] = hssi[0].f2a_rx_parallel_data [(i*80)+71:(i*80)+40];
            assign rx_enh_data_valid = hssi[0].f2a_rx_parallel_data [(i*80)+36];
            assign hssi[0].a2f_tx_parallel_data [(i*80)+35:(i*80)+32] = xgmii_tx_control[3:0];
            assign hssi[0].a2f_tx_parallel_data [(i*80)+77:(i*80)+72] = xgmii_tx_control[7:4];     // 9th bit unused
            assign hssi[0].a2f_tx_parallel_data [(i*80)+31:(i*80)] = xgmii_tx_data[31:0];
            assign hssi[0].a2f_tx_parallel_data [(i*80)+71:(i*80)+40] = xgmii_tx_data[63:32];
            assign hssi[0].a2f_tx_parallel_data [(i*80)+36] = tx_enh_data_valid;
        end else begin
             assign xgmii_rx_control = xgmii_tx_control;
             assign xgmii_rx_data    = xgmii_tx_data;
             assign rx_enh_data_valid = tx_enh_data_valid;
        end

        reg         csr_read = 1'b0;
        reg         csr_write = 1'b0;
        reg [31:0]    csr_writedata = 32'h0 /* synthesis preserve */;
        reg [15:0]    csr_address = 32'h0 /* synthesis preserve */;
        wire [31:0]    csr_readdata;
        wire         csr_waitrequest;

        altera_eth_10g_mac_base_r eth0 (
            .csr_clk(clk),
            .csr_rst_n(!csr_rst),
            .tx_rst_n(!tx_rst),
            .rx_rst_n(!rx_rst),

            .tx_clk_312(hssi[0].f2a_tx_parallel_clk_x2[0]),
            .rx_clk_312(hssi[0].f2a_rx_parallel_clk_x2[0]),
            .tx_clk_156(hssi[0].f2a_tx_parallel_clk_x1[0]),
            .rx_clk_156(hssi[0].f2a_rx_parallel_clk_x1[0]),

            // serdes data pipe
            .xgmii_tx_valid(tx_enh_data_valid),
            .xgmii_tx_control(xgmii_tx_control),
            .xgmii_tx_data(xgmii_tx_data),
            .xgmii_rx_control(xgmii_rx_control),
            .xgmii_rx_data(xgmii_rx_data),
            .xgmii_rx_valid(rx_enh_data_valid),

            // csr interface
            .csr_read(csr_read),
            .csr_write(csr_write),
            .csr_writedata(csr_writedata),
            .csr_readdata(csr_readdata),
            .csr_address(csr_address),
            .csr_waitrequest(csr_waitrequest)
        );

        reg [31:0] csr_readdata_r = 32'h0;
        always @(posedge clk) begin
            if (reset) csr_read <= 1'b0;
            else begin
                if (status_read && (port_sel == i[2:0])) csr_read <= 1'b1;
                if (csr_read & ~csr_waitrequest) csr_read <= 1'b0;
            end
            if (csr_read) csr_readdata_r <= csr_readdata;
        end

        always @(posedge clk) begin
            if (reset) csr_write <= 1'b0;
            else begin
                if (status_write && (port_sel == i[2:0])) csr_write <= 1'b1;
                if (csr_write & ~csr_waitrequest) csr_write <= 1'b0;
            end
        end

        assign all_csr_rdata [(i+1)*32-1:i*32] = csr_readdata_r;

        always @(posedge clk) begin
            csr_address <= status_addr;
            csr_writedata <= status_writedata;
        end
    end

endgenerate


wire [31:0] status_readdata_r;
intc_mux8_t1_w32 mx0 (
    .clk(clk),
    .din(all_csr_rdata),
    .sel(port_sel),
    .dout(status_readdata_r)
);

////////////////////////////////////////////////////////////////////////////////
// hook up to the management port
////////////////////////////////////////////////////////////////////////////////

always @(posedge clk) begin
    case (prmgmt_addr[3:0])
        4'h0 : prmgmt_dout_r <= 32'h0 | scratch;
        4'h1 : prmgmt_dout_r <= 32'h0 | {csr_rst,rx_rst,tx_rst};
        4'h2 : prmgmt_dout_r <= 32'h0 | {status_read,status_write,status_addr};
        4'h3 : prmgmt_dout_r <= status_writedata;
        4'h4 : prmgmt_dout_r <= status_readdata_r;
        4'h5 : prmgmt_dout_r <= 32'h0 | port_sel;
        4'h6 : prmgmt_dout_r <= 32'h0 | sloop;
        /*4'h7 : prmgmt_dout_r <= {hssi.f2a_rx_enh_blk_lock, hssi.f2a_rx_is_lockedtodata};
        4'h8 : prmgmt_dout_r <= 32'h0 | {i2c_inst_sel_r,i2c_ctrl_wdata_r};
        4'h9 : prmgmt_dout_r <= 32'h0 | i2c_stat_rdata;
        4'hd : prmgmt_dout_r <= 32'h0 | {hssi.a2f_prmgmt_fatal_err, hssi.f2a_init_done};
        */
        default : prmgmt_dout_r <= 32'h0;
    endcase
end

always @(posedge clk) begin
    status_read <= 1'b0;
    status_write <= 1'b0;

    if (prmgmt_cmd[0]) begin
        case (prmgmt_addr[3:0])
            4'h0 : scratch <= prmgmt_din;
            4'h1 : {csr_rst,rx_rst,tx_rst} <= prmgmt_din[2:0];
            4'h2 : {status_read,status_write,status_addr} <= prmgmt_din[17:0];
            4'h3 : status_writedata <= prmgmt_din;
            4'h5 : port_sel <= prmgmt_din[2:0];
            4'h6 : sloop <= prmgmt_din[NUM_ETH-1:0];
            //4'h8 : {i2c_inst_sel_r,i2c_ctrl_wdata_r} <= prmgmt_din[17:0];
            //4'hd : hssi.a2f_prmgmt_fatal_err <= prmgmt_din[1];
        endcase
    end

    if (reset) begin
        scratch <= {GBS_ID, GBS_VER};
        status_read <= 1'b0;
        status_write <= 1'b0;
        sloop <= 'b0;
    end
end

////////////////////////////////////
// drive the unused channels into a civilized state

/*
generate
for (i=4; i<NUM_LN; i=i+1) begin : unused_ln
    assign hssi[0].a2f_rx_bitslip[i] = 1'b0;       // TODO
    assign hssi[0].a2f_rx_fifo_rd_en[i] = 1'b0;    // TODO
    assign hssi[0].a2f_tx_parallel_data[(i+1)*80-1:i*80] = 80'h0;
end
endgenerate
*/

endmodule
