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


`timescale 1ps/1ps

module alt_e100s10_fc_csr  #(
    parameter SIM_EMULATE = 1'b0,
    parameter SYNOPT_FLOW_CONTROL = 1'b0, 
    parameter SYNOPT_NUMPRIORITY = 8
)(
    input 	      csr_clk ,
    input 	      rx_clk ,
    input 	      tx_clk ,


    input 	      reset ,
    input 	      write_tx_fc ,
    input 	      write_rx_fc ,
    input 	      read_tx_fc ,
    input 	      read_rx_fc ,
    input [7:0]      address ,
    input [31:0]      data_in ,
    output [31:0] data_out_tx_fc ,
    output [31:0] data_out_rx_fc ,
    output        data_valid_tx_fc ,
    output        data_valid_rx_fc ,

    //Flow Control
    output 	      fc_pfc_sel,
    output [SYNOPT_NUMPRIORITY-1:0]      fc_ena_csr,
    output [SYNOPT_NUMPRIORITY*16-1:0]    fc_pause_quanta_csr,
    output [SYNOPT_NUMPRIORITY*16-1:0]   fc_hold_quanta_csr,
    output [SYNOPT_NUMPRIORITY-1:0]      fc_2b_req_mode_sel_csr,
    output [SYNOPT_NUMPRIORITY-1:0]      fc_2b_req_mode_csr_req_sel_csr,
    output [SYNOPT_NUMPRIORITY-1:0]       fc_req0_csr,
    output [SYNOPT_NUMPRIORITY-1:0]       fc_req1_csr,
    output [SYNOPT_NUMPRIORITY-1:0]       fc_rx_pfc_en_csr,  
    output [47:0]     fc_dest_addr,
    output [47:0]     fc_src_addr,
    output 	      fc_tx_off_en,
    output [47:0]     fc_rx_dest_addr    


);
    wire [7:0]      fc_ena;
    wire [127:0]    fc_pause_quanta;
    wire [127:0]   fc_hold_quanta;
    wire [7:0]      fc_2b_req_mode_sel;
    wire [7:0]      fc_2b_req_mode_csr_req_sel;
    wire [7:0]       fc_req0;
    wire [7:0]       fc_req1;
    wire [7:0]       fc_rx_pfc_en; 
    assign fc_ena_csr[SYNOPT_NUMPRIORITY-1:0] =fc_ena[SYNOPT_NUMPRIORITY-1:0] ;
    assign fc_pause_quanta_csr[SYNOPT_NUMPRIORITY*16-1:0] =fc_pause_quanta[SYNOPT_NUMPRIORITY*16-1:0] ;
    assign fc_hold_quanta_csr[SYNOPT_NUMPRIORITY*16-1:0] =fc_hold_quanta[SYNOPT_NUMPRIORITY*16-1:0] ;
    assign fc_2b_req_mode_sel_csr[SYNOPT_NUMPRIORITY-1:0] =fc_2b_req_mode_sel[SYNOPT_NUMPRIORITY-1:0] ;
    assign fc_2b_req_mode_csr_req_sel_csr[SYNOPT_NUMPRIORITY-1:0] =fc_2b_req_mode_csr_req_sel[SYNOPT_NUMPRIORITY-1:0] ;
    assign fc_req0_csr[SYNOPT_NUMPRIORITY-1:0] =fc_req0[SYNOPT_NUMPRIORITY-1:0] ;
    assign fc_req1_csr[SYNOPT_NUMPRIORITY-1:0] =fc_req1[SYNOPT_NUMPRIORITY-1:0] ;
    assign fc_rx_pfc_en_csr[SYNOPT_NUMPRIORITY-1:0] =fc_rx_pfc_en[SYNOPT_NUMPRIORITY-1:0] ; 


wire [7:0] fc_req0_wire;
wire [7:0] fc_req1_wire;
wire [7:0] fc_ena_wire;
wire fc_2b_req_mode_sel_wire;

assign fc_2b_req_mode_sel = {8{fc_2b_req_mode_sel_wire}};

generate 
if (SYNOPT_FLOW_CONTROL == 1) begin
    alt_e100s10_sync2r2 sn8 (
        .din_clk        (csr_clk),
        .din            ({fc_req1_wire[0], fc_req0_wire[0]}),
        .dout_clk       (tx_clk),
        .dout           ({fc_req1[0], fc_req0[0]})
    );
    defparam sn8 .SIM_EMULATE = SIM_EMULATE;
    alt_e100s10_sync2r2 sn9 (
        .din_clk        (csr_clk),
        .din            ({fc_req1_wire[1], fc_req0_wire[1]}),
        .dout_clk       (tx_clk),
        .dout           ({fc_req1[1], fc_req0[1]})
    );
    defparam sn9 .SIM_EMULATE = SIM_EMULATE;
    alt_e100s10_sync2r2 sn10 (
        .din_clk        (csr_clk),
        .din            ({fc_req1_wire[2], fc_req0_wire[2]}),
        .dout_clk       (tx_clk),
        .dout           ({fc_req1[2], fc_req0[2]})
    );
    defparam sn10 .SIM_EMULATE = SIM_EMULATE;
    alt_e100s10_sync2r2 sn11 (
        .din_clk        (csr_clk),
        .din            ({fc_req1_wire[3], fc_req0_wire[3]}),
        .dout_clk       (tx_clk),
        .dout           ({fc_req1[3], fc_req0[3]})
    );
    defparam sn11 .SIM_EMULATE = SIM_EMULATE;
    alt_e100s10_sync2r2 sn12 (
        .din_clk        (csr_clk),
        .din            ({fc_req1_wire[4], fc_req0_wire[4]}),
        .dout_clk       (tx_clk),
        .dout           ({fc_req1[4], fc_req0[4]})
    );
    defparam sn12 .SIM_EMULATE = SIM_EMULATE;
    alt_e100s10_sync2r2 sn13 (
        .din_clk        (csr_clk),
        .din            ({fc_req1_wire[5], fc_req0_wire[5]}),
        .dout_clk       (tx_clk),
        .dout           ({fc_req1[5], fc_req0[5]})
    );
    defparam sn13 .SIM_EMULATE = SIM_EMULATE;
    alt_e100s10_sync2r2 sn14 (
        .din_clk        (csr_clk),
        .din            ({fc_req1_wire[6], fc_req0_wire[6]}),
        .dout_clk       (tx_clk),
        .dout           ({fc_req1[6], fc_req0[6]})
    );
    defparam sn14 .SIM_EMULATE = SIM_EMULATE;
    alt_e100s10_sync2r2 sn15 (
        .din_clk        (csr_clk),
        .din            ({fc_req1_wire[7], fc_req0_wire[7]}),
        .dout_clk       (tx_clk),
        .dout           ({fc_req1[7], fc_req0[7]})
    );
    defparam sn15 .SIM_EMULATE = SIM_EMULATE;
    alt_e100s10_sync2r2 sn16 (
        .din_clk        (csr_clk),
        .din            ({fc_ena_wire[1], fc_ena_wire[0]}),
        .dout_clk       (tx_clk),
        .dout           ({fc_ena[1], fc_ena[0]})
    );
    defparam sn16 .SIM_EMULATE = SIM_EMULATE;
    alt_e100s10_sync2r2 sn17 (
        .din_clk        (csr_clk),
        .din            ({fc_ena_wire[3], fc_ena_wire[2]}),
        .dout_clk       (tx_clk),
        .dout           ({fc_ena[3], fc_ena[2]})
    );
    defparam sn17 .SIM_EMULATE = SIM_EMULATE;
    alt_e100s10_sync2r2 sn18 (
        .din_clk        (csr_clk),
        .din            ({fc_ena_wire[5], fc_ena_wire[4]}),
        .dout_clk       (tx_clk),
        .dout           ({fc_ena[5], fc_ena[4]})
    );
    defparam sn18 .SIM_EMULATE = SIM_EMULATE;
    alt_e100s10_sync2r2 sn19 (
        .din_clk        (csr_clk),
        .din            ({fc_ena_wire[7], fc_ena_wire[6]}),
        .dout_clk       (tx_clk),
        .dout           ({fc_ena[7], fc_ena[6]})
    );
    defparam sn19 .SIM_EMULATE = SIM_EMULATE;
end
else begin
assign fc_ena=8'h0;
assign fc_req0=8'h0;
assign fc_req1=8'h0;
end
endgenerate

alt_e100s10_tx_fc_config_register_map tx_flow_control(
    .PFC_SEL_pfc_sel (fc_pfc_sel),
    .FC_ENA_ena_q0 (fc_ena_wire[0]),
    .FC_ENA_ena_q1 (fc_ena_wire[1]),
    .FC_ENA_ena_q2 (fc_ena_wire[2]),
    .FC_ENA_ena_q3 (fc_ena_wire[3]),
    .FC_ENA_ena_q4 (fc_ena_wire[4]),
    .FC_ENA_ena_q5 (fc_ena_wire[5]),
    .FC_ENA_ena_q6 (fc_ena_wire[6]),
    .FC_ENA_ena_q7 (fc_ena_wire[7]),
    .FC_QUANTA0_pfc_quanta0 (fc_pause_quanta[15:0]),
    .FC_QUANTA1_pfc_quanta1 (fc_pause_quanta[31:16]),
    .FC_QUANTA2_pfc_quanta2 (fc_pause_quanta[47:32]),
    .FC_QUANTA3_pfc_quanta3 (fc_pause_quanta[63:48]),
    .FC_QUANTA4_pfc_quanta4 (fc_pause_quanta[79:64]),
    .FC_QUANTA5_pfc_quanta5 (fc_pause_quanta[95:80]),
    .FC_QUANTA6_pfc_quanta6 (fc_pause_quanta[111:96]),
    .FC_QUANTA7_pfc_quanta7 (fc_pause_quanta[127:112]),
    .FC_REQ_MODE_fc_2b_mode_csr_sel_q0 (fc_2b_req_mode_csr_req_sel[0]),
    .FC_REQ_MODE_fc_2b_mode_csr_sel_q1 (fc_2b_req_mode_csr_req_sel[1]),
    .FC_REQ_MODE_fc_2b_mode_csr_sel_q2 (fc_2b_req_mode_csr_req_sel[2]),
    .FC_REQ_MODE_fc_2b_mode_csr_sel_q3 (fc_2b_req_mode_csr_req_sel[3]),
    .FC_REQ_MODE_fc_2b_mode_csr_sel_q4 (fc_2b_req_mode_csr_req_sel[4]),
    .FC_REQ_MODE_fc_2b_mode_csr_sel_q5 (fc_2b_req_mode_csr_req_sel[5]),
    .FC_REQ_MODE_fc_2b_mode_csr_sel_q6 (fc_2b_req_mode_csr_req_sel[6]),
    .FC_REQ_MODE_fc_2b_mode_csr_sel_q7 (fc_2b_req_mode_csr_req_sel[7]),
    .FC_REQ_MODE_fc_2b_mode_sel (fc_2b_req_mode_sel_wire),
    .FC_XONXOFF_REQ_req0_q0 (fc_req0_wire[0]),
    .FC_XONXOFF_REQ_req0_q1 (fc_req0_wire[1]),
    .FC_XONXOFF_REQ_req0_q2 (fc_req0_wire[2]),
    .FC_XONXOFF_REQ_req0_q3 (fc_req0_wire[3]),
    .FC_XONXOFF_REQ_req0_q4 (fc_req0_wire[4]),
    .FC_XONXOFF_REQ_req0_q5 (fc_req0_wire[5]),
    .FC_XONXOFF_REQ_req0_q6 (fc_req0_wire[6]),
    .FC_XONXOFF_REQ_req0_q7 (fc_req0_wire[7]),
    .FC_XONXOFF_REQ_req1_q0 (fc_req1_wire[0]),
    .FC_XONXOFF_REQ_req1_q1 (fc_req1_wire[1]),
    .FC_XONXOFF_REQ_req1_q2 (fc_req1_wire[2]),
    .FC_XONXOFF_REQ_req1_q3 (fc_req1_wire[3]),
    .FC_XONXOFF_REQ_req1_q4 (fc_req1_wire[4]),
    .FC_XONXOFF_REQ_req1_q5 (fc_req1_wire[5]),
    .FC_XONXOFF_REQ_req1_q6 (fc_req1_wire[6]),
    .FC_XONXOFF_REQ_req1_q7 (fc_req1_wire[7]),
    .FC_DEST_ADDR_LOW_fc_dest_addr (fc_dest_addr[31:0]),
    .FC_DEST_ADDR_HI_fc_dest_addr (fc_dest_addr[47:32]),
    .FC_HOLD_QUANTA0_hold_quanta0 (fc_hold_quanta[15:0]),
    .FC_HOLD_QUANTA1_hold_quanta1 (fc_hold_quanta[31:16]),
    .FC_HOLD_QUANTA2_hold_quanta2 (fc_hold_quanta[47:32]),
    .FC_HOLD_QUANTA3_hold_quanta3 (fc_hold_quanta[63:48]),
    .FC_HOLD_QUANTA4_hold_quanta4 (fc_hold_quanta[79:64]),
    .FC_HOLD_QUANTA5_hold_quanta5 (fc_hold_quanta[95:80]),
    .FC_HOLD_QUANTA6_hold_quanta6 (fc_hold_quanta[111:96]),
    .FC_HOLD_QUANTA7_hold_quanta7 (fc_hold_quanta[127:112]),
    .FC_SRC_ADDR_LOW_fc_src_addr (fc_src_addr[31:0]),
    .FC_SRC_ADDR_HI_fc_src_addr (fc_src_addr[47:32]),
    .FC_TX_OFF_EN_tx_off_en (fc_tx_off_en),
    .clk(csr_clk),
    .reset(reset),
    .writedata(data_in),
    .read(read_tx_fc),
    .write(write_tx_fc),
    .byteenable(4'b1111),
    .readdata(data_out_tx_fc),
    .readdatavalid(data_valid_tx_fc),
    .address(address[7:0])

);


alt_e100s10_rx_fc_config_register_map rx_flow_control(
    .FC_RX_PFC_ENA_rx_pfc_en_q0 (fc_rx_pfc_en[0]),
    .FC_RX_PFC_ENA_rx_pfc_en_q1 (fc_rx_pfc_en[1]),
    .FC_RX_PFC_ENA_rx_pfc_en_q2 (fc_rx_pfc_en[2]),
    .FC_RX_PFC_ENA_rx_pfc_en_q3 (fc_rx_pfc_en[3]),
    .FC_RX_PFC_ENA_rx_pfc_en_q4 (fc_rx_pfc_en[4]),
    .FC_RX_PFC_ENA_rx_pfc_en_q5 (fc_rx_pfc_en[5]),
    .FC_RX_PFC_ENA_rx_pfc_en_q6 (fc_rx_pfc_en[6]),
    .FC_RX_PFC_ENA_rx_pfc_en_q7 (fc_rx_pfc_en[7]),
    .FC_RX_DEST_ADDR_LOW_fc_rx_dest_addr(fc_rx_dest_addr[31:0]),
    .FC_RX_DEST_ADDR_HI_fc_rx_dest_addr(fc_rx_dest_addr[47:32]),     
    .clk(csr_clk),
    .reset(reset),
    .writedata(data_in),
    .read(read_rx_fc),
    .write(write_rx_fc),
    .byteenable(4'b1111),
    .readdata(data_out_rx_fc),
    .readdatavalid(data_valid_rx_fc),
    .address(address[7:0])

);

endmodule



