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
    parameter NUM_LN = 4   // no override
)(
	pr_hssi_if.to_fiu hssi,

    // JTX: add signals removed from HSSI interface
    input clk,
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

localparam NUM_ETH = 4;

reg [31:0] scratch = {GBS_ID, GBS_VER};
reg [31:0] prmgmt_dout_r = 32'h0;

reg [NUM_ETH-1:0] sloop;
//assign hssi.a2f_rx_seriallpbken[NUM_ETH-1:0] = sloop;

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
	/*
	if (hssi.f2a_prmgmt_cmd != 16'b0)
    begin
        prmgmt_cmd  <= hssi.f2a_prmgmt_cmd;
        prmgmt_addr <= hssi.f2a_prmgmt_addr;
        prmgmt_din  <= hssi.f2a_prmgmt_din;
    end
	*/
    if (eth_ctrl_addr[17] | eth_ctrl_addr[16])
    begin
        prmgmt_cmd  <= eth_ctrl_addr[31:16];
        prmgmt_addr <= eth_ctrl_addr[15: 0];
        prmgmt_din  <= eth_wr_data;
    end

end


assign eth_rd_data   = prmgmt_dout_r;
assign csr_init_done = 1'b1;

/*
////////////////////////////////////////////////////////////////////////////////
// PRMGMT registers for I2C controllers
////////////////////////////////////////////////////////////////////////////////

reg  [15:0] i2c_ctrl_wdata_r;
reg  [15:0] i2c_stat_rdata  ;
wire [15:0] i2c_stat_rdata_0;
wire [15:0] i2c_stat_rdata_1;
reg  [ 1:0] i2c_inst_sel_r  ;
*/

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
reg [1:0] port_sel = 2'b0;

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
        wire err_ins = 1'b0;

        // JTX: loopback XGMII
        /*
        assign xgmii_rx_control = hssi.f2a_rx_control [(i*20)+7:(i*20)];
        assign xgmii_rx_data = hssi.f2a_rx_parallel_data [(i*128)+63:(i*128)];
        assign hssi.a2f_tx_control [(i+1)*18-1:(i*18)] = {9'b0,err_ins,xgmii_tx_control};
        assign hssi.a2f_tx_parallel_data [(i+1)*128-1:(i*128)] = {64'b0,xgmii_tx_data};
        */
        assign xgmii_rx_control = xgmii_tx_control;
        assign xgmii_rx_data    = xgmii_tx_data;

        reg         csr_read = 1'b0;
        reg         csr_write = 1'b0;
        reg [31:0]    csr_writedata = 32'h0 /* synthesis preserve */;
        reg [15:0]    csr_address = 32'h0 /* synthesis preserve */;
        wire [31:0]    csr_readdata;
        wire         csr_waitrequest;

        altera_eth_10g_mac_base_r eth0 (
            .csr_clk(clk),
            .csr_rst_n(~csr_rst),
            .tx_rst_n(~tx_rst),
            .rx_rst_n(~rx_rst),

            // TODO JTX: clk with 2*freq
            .tx_clk_312(),
            .rx_clk_312(),
            .tx_clk_156(clk),
            .rx_clk_156(clk),

            .iopll_locked(~reset),

            // serdes controls
            .tx_analogreset(),
            .tx_digitalreset(),
            .rx_analogreset(),
            .rx_digitalreset(),
            .tx_cal_busy(reset),
            .rx_cal_busy(reset),
            .rx_is_lockedtodata(reset),
            .atx_pll_locked(reset),
            .tx_ready_export(),
            .rx_ready_export(),

            // serdes data pipe
            .xgmii_tx_valid(~reset),
            .xgmii_tx_control(xgmii_tx_control),
            .xgmii_tx_data(xgmii_tx_data),
            .xgmii_rx_control(xgmii_rx_control),
            .xgmii_rx_data(xgmii_rx_data),
            .xgmii_rx_valid(~reset),

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
                if (status_read && (port_sel == i[1:0])) csr_read <= 1'b1;
                if (csr_read & ~csr_waitrequest) csr_read <= 1'b0;
            end
            if (csr_read) csr_readdata_r <= csr_readdata;
        end

        always @(posedge clk) begin
            if (reset) csr_write <= 1'b0;
            else begin
                if (status_write && (port_sel == i[1:0])) csr_write <= 1'b1;
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
alt_mux4w32t1s1 mx0 (
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
        //4'h7 : prmgmt_dout_r <= {hssi.f2a_rx_enh_blk_lock, hssi.f2a_rx_is_lockedtodata};

        //4'h8 : prmgmt_dout_r <= 32'h0 | {i2c_inst_sel_r,i2c_ctrl_wdata_r};
        //4'h9 : prmgmt_dout_r <= 32'h0 | i2c_stat_rdata;
        
        //4'hd : prmgmt_dout_r <= 32'h0 | {hssi.a2f_prmgmt_fatal_err, hssi.f2a_init_done};

        default : prmgmt_dout_r <= 32'h0;
    endcase
end
//assign hssi.a2f_prmgmt_dout = prmgmt_dout_r;

always @(posedge clk or posedge reset) begin
    status_read <= 1'b0;
    status_write <= 1'b0;

    if (prmgmt_cmd[0]) begin
        case (prmgmt_addr[3:0])
            4'h0 : scratch <= prmgmt_din;
            4'h1 : {csr_rst,rx_rst,tx_rst} <= prmgmt_din[2:0];

            4'h2 : {status_read,status_write,status_addr} <= prmgmt_din[17:0];
            4'h3 : status_writedata <= prmgmt_din;
            4'h5 : port_sel <= prmgmt_din[1:0];

            4'h6 : sloop <= prmgmt_din[NUM_ETH-1:0];
            
            //4'h8 : {i2c_inst_sel_r,i2c_ctrl_wdata_r} <= prmgmt_din[17:0];

            //4'hd : hssi.a2f_prmgmt_fatal_err <= prmgmt_din[1];
        endcase
    end
    /*
    // This is the Configuration Trigger for I2C controllers
    if (i2c_ctrl_wdata_r[8]) 
        i2c_ctrl_wdata_r[8] <= 1'b0;
    */
    if (reset) begin
    //if (hssi.f2a_prmgmt_arst) begin
        scratch <= {GBS_ID, GBS_VER};
        //hssi.a2f_prmgmt_fatal_err <= 1'b0;
        status_read <= 1'b0;
        status_write <= 1'b0;
        sloop <= 'b0;
        //i2c_ctrl_wdata_r <= 'b0;
    end
end
/*
assign hssi.a2f_init_start = csr_init_start;

////////////////////////////////////////////////////////////////////////////////
// I2C instances access decoding
////////////////////////////////////////////////////////////////////////////////

wire cfg_trigger_0 = i2c_ctrl_wdata_r[8] & (i2c_inst_sel_r == 2'h0);
wire cfg_trigger_1 = i2c_ctrl_wdata_r[8] & (i2c_inst_sel_r == 2'h1);

always @(*)
begin
    case (i2c_inst_sel_r)
        2'h0 :  i2c_stat_rdata = i2c_stat_rdata_0;
        2'h1 :  i2c_stat_rdata = i2c_stat_rdata_1;
        default i2c_stat_rdata = 'b0;
    endcase
end

////////////////////////////////////////////////////////////////////////////////
// I2C (SMBUS) instance 0
////////////////////////////////////////////////////////////////////////////////

i2c_contrl inst_i2c_contrl_0 
(
    .clk		(hssi.f2a_prmgmt_ctrl_clk),
    .reset_n	(~hssi.f2a_prmgmt_arst  ),
    .i2c_wdata	(i2c_ctrl_wdata_r[ 7:0] ),
    .i2c_control(i2c_ctrl_wdata_r[15:8] ),
    .i2c_rdata	(i2c_stat_rdata_0[ 7:0] ),
    .i2c_status	(i2c_stat_rdata_0[15:8] ),
    .cfg_trigger(cfg_trigger_0          ),
    .i2c_sda_i	(b2g_I2C0_sda           ),
    .i2c_sda_o	(g2b_I2C0_sda           ),
    .i2c_sda_e	(oen_I2C0_sda           ),
    .i2c_sclk	(g2b_I2C0_scl           )
);

assign oen_I2C0_scl  = 1'b1;    // always enabled because it is a master

assign g2b_I2C0_rstn = 1'b0;
assign oen_I2C0_rstn = 1'b0;

////////////////////////////////////////////////////////////////////////////////
// I2C (SMBUS) instance 1
////////////////////////////////////////////////////////////////////////////////

i2c_contrl inst_i2c_contrl_1 
(
    .clk		(hssi.f2a_prmgmt_ctrl_clk),
    .reset_n	(~hssi.f2a_prmgmt_arst  ),
    .i2c_wdata	(i2c_ctrl_wdata_r[ 7:0] ),
    .i2c_control(i2c_ctrl_wdata_r[15:8] ),
    .i2c_rdata	(i2c_stat_rdata_1[ 7:0] ),
    .i2c_status	(i2c_stat_rdata_1[15:8] ),
    .cfg_trigger(cfg_trigger_1          ),
    .i2c_sda_i	(b2g_I2C1_sda           ),
    .i2c_sda_o	(g2b_I2C1_sda           ),
    .i2c_sda_e	(oen_I2C1_sda           ),
    .i2c_sclk	(g2b_I2C1_scl           )
);

assign oen_I2C1_scl  = 1'b1;    // always enabled because it is a master

assign g2b_I2C1_rstn = 1'b0;
assign oen_I2C1_rstn = 1'b0;

////////////////////////////////////////////////////////////////////////////////
// GPIOs (not used for Retimer Card)
////////////////////////////////////////////////////////////////////////////////

assign oen_GPIO_a = 5'b0;
assign oen_GPIO_b = 5'b0;


////////////////////////////////////
// drive the unused channels into a civilized state


generate
for (i=4; i<NUM_LN; i=i+1) begin : unused_ln
    assign hssi.a2f_tx_analogreset[i] = 1'b1;
    assign hssi.a2f_tx_digitalreset[i] = 1'b1;
    assign hssi.a2f_rx_analogreset[i] = 1'b1;
    assign hssi.a2f_rx_digitalreset[i] = 1'b1;
    assign hssi.a2f_rx_seriallpbken[i] = 1'b1;
    assign hssi.a2f_rx_set_locktodata[i] = 1'b0;
    assign hssi.a2f_rx_set_locktoref[i] = 1'b0;
    assign hssi.a2f_tx_enh_data_valid[i] = 1'b0;
    assign hssi.a2f_rx_enh_fifo_rd_en[i] = 1'b0;

    assign hssi.a2f_tx_parallel_data[(i+1)*128-1:i*128] = 128'h0;
    assign hssi.a2f_tx_control[(i+1)*18-1:i*18] = 18'h0;
end
endgenerate
*/

endmodule
