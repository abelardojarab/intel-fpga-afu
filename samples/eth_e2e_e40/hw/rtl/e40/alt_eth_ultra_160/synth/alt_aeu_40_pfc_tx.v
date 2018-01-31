// (C) 2001-2016 Altera Corporation. All rights reserved.
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


// (C) 2001-2014 Altera Corporation. All rights reserved.
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
 module alt_aeu_40_pfc_tx #(
        parameter TARGET_CHIP = 2,
        parameter WORDS = 4,
        parameter DWIDTH = WORDS * 64,
        parameter DBGWIDTH = 1,
        parameter EMPTYBITS = 5,
        parameter REVID = 32'h02062015,
        parameter BASE_TXFC = 0,
        parameter NUMPRIORITY = 2,
        parameter PREAMBLE_PASS = 1
)(
        input clk_mm,
        input reset_mm,
        input smm_master_dout,
        output smm_slave_dout,

        // input data-path interface
        input clk,
        input reset_n,
        output in_ready,
        input in_valid,
        input in_error,
        input in_sop,
        input in_eop,
        input [DWIDTH-1:0] in_data,
        input [EMPTYBITS-1:0] in_empty,
        
        // output data-path interface
        input out_ready,                        // stall input pipe
        output out_valid,
        output out_sop,
        output out_eop,
        output out_error,
        output [DWIDTH-1:0] out_data,
        output [EMPTYBITS-1:0] out_empty,
        output [DBGWIDTH-1:0] out_debug,
        
        output[NUMPRIORITY-1:0] txon_frame,
        output[NUMPRIORITY-1:0] txoff_frame,
        input[NUMPRIORITY-1:0] in_pause_req
        );

    //assign out_error = in_error; // dummy ports

      localparam FSMPDEPTH = 2;
      localparam ODEPTH = 2;
      localparam PDEPTH = 2;
      localparam PFC_CYCLES  = 3'd2;

      wire pkt_end;
      wire sel_in_pkt;
      wire sel_pfc_pkt;
      wire sel_store_pkt;
      wire out_pfc_valid;

      wire idp_valid;
      wire idp_sop;
      wire idp_eop;
      wire [DWIDTH-1:0] idp_data;
      wire [EMPTYBITS-1:0] idp_empty;

      wire[8*64-1:0] out_pfc_data; // Always 8 words wide, even for 4-word Avalon interface
      wire[EMPTYBITS-1:0] out_pfc_empty;

     wire[NUMPRIORITY-1:0] cfg_enable_txins;
     wire[16*NUMPRIORITY-1:0] cfg_pause_quanta;

     wire cfg_lholdoff_en;
     wire[16-1:0] cfg_lholdoff_quanta;

     wire[NUMPRIORITY-1:0] cfg_qholdoff_en;
     wire[16*NUMPRIORITY-1:0] cfg_qholdoff_quanta;

     wire[47:0] cfg_saddr;
     wire[47:0] cfg_daddr;
     wire[NUMPRIORITY-1:0] cfg_pause_req;
     
     wire ctrl_ready, odp_ready;
     wire codp_ready = ctrl_ready & odp_ready;

     wire idp_error;

     wire out_debug_odp; assign out_debug = {out_debug_odp};
        alt_aeu_40_pfc_tx_idp #(
                .DWIDTH(DWIDTH),
                .EMPTYBITS(EMPTYBITS),
                .PDEPTH(PDEPTH),
                .FSMPDEPTH(FSMPDEPTH),
                .ODEPTH(ODEPTH)
        ) aeu_40_pfc_txidp (
                .clk(clk),
                .rst_n(reset_n),
                                                           
                .pkt_end(pkt_end),
                                                           
                .in_ready(in_ready),
                .in_valid(in_valid),
                .in_sop(in_sop),
                .in_eop(in_eop),
                .in_error (in_error),
                .in_data(in_data),
                .in_empty(in_empty),
                                                           
                .out_ready(codp_ready),         // stall input pipe
                .out_valid(idp_valid),                  // output val
                .out_sop(idp_sop),
                .out_eop(idp_eop),
                .out_error(idp_error),
                .out_data(idp_data),
                .out_empty(idp_empty)
     );

        alt_aeu_40_pfc_tx_ctrl #(
                .cfg_opcode(16'h0101),
                .cfg_typlen(16'h8808),
                .WORDS(WORDS),
                .EMPTYBITS(EMPTYBITS),
                .NUMPRIORITY(NUMPRIORITY),
                .PREAMBLE_PASS(PREAMBLE_PASS)
    )pfc_tx_ctrl (
                .clk(clk),
                .reset_n(reset_n),
                .cfg_saddr(cfg_saddr),
                .cfg_daddr(cfg_daddr),
                .cfg_pause_req(cfg_pause_req),
                .cfg_enable_txins(cfg_enable_txins),
                .cfg_pause_quanta(cfg_pause_quanta[NUMPRIORITY*16-1:0]),

                .cfg_lholdoff_en(cfg_lholdoff_en),
                .cfg_lholdoff_quanta(cfg_lholdoff_quanta[15:0]),
                .cfg_qholdoff_en(cfg_qholdoff_en[NUMPRIORITY-1:0]),
                .cfg_qholdoff_quanta(cfg_qholdoff_quanta[16*NUMPRIORITY-1:0]),
        
                .in_pause_req(in_pause_req[NUMPRIORITY-1:0]),
                .txon_frame(txon_frame[NUMPRIORITY-1:0]),
                .txoff_frame(txoff_frame[NUMPRIORITY-1:0]),
        
                .out_ready(odp_ready),
                .in_ready(ctrl_ready),
        
                .pkt_end(pkt_end),
                .sel_in_pkt(sel_in_pkt),
                .sel_pfc_pkt(sel_pfc_pkt),
                .sel_store_pkt(sel_store_pkt),
                .out_pfc_valid(out_pfc_valid),
                .out_pfc_empty(out_pfc_empty),
                .out_pfc_data(out_pfc_data)
        );



        alt_aeu_40_pfc_tx_odp #(
                .WORDS(WORDS) ,
                .DWIDTH(DWIDTH) ,
                .EMPTYBITS(EMPTYBITS)
        ) pfc_txodp (
                .clk(clk),
                
                .sel_in_pkt(sel_in_pkt),                // insert pfc frame
                .sel_pfc_pkt(sel_pfc_pkt),
                .sel_store_pkt(sel_store_pkt),
                
                .in_ready(odp_ready),                   // input ready
                .in_valid(idp_valid),                   // input val
                .in_sop(idp_sop),
                .in_eop(idp_eop),
                .in_error(idp_error),
                .in_data(idp_data),
                .in_empty(idp_empty),
                .in_pfc_valid(out_pfc_valid),
                .in_pfc_empty(out_pfc_empty),
                .in_pfc_data(out_pfc_data),
                
                .out_ready(out_ready),          // stall input pipe
                .out_valid(out_valid),                  // output val
                .out_sop(out_sop),
                .out_eop(out_eop),
                .out_error(out_error),
                .out_data(out_data),
                .out_empty(out_empty),
                .out_debug(out_debug_odp)
     );

     wire read;
     wire write;
     wire readdatavalid;
     wire [07:0]address;
     wire [31:0]writedata;
     wire [31:0]readdata;
/*
     serif_slave_async #(.ADDR_PAGE(BASE_TXFC), .TARGET_CHIP(TARGET_CHIP))

        avalon_serial_brdg (
                .aclr(reset_mm),
                .sclk(clk_mm),
                .din(smm_master_dout),
                .dout(smm_slave_dout),
                .bclk(clk),
                .wr(write),
                .rd(read),
                .addr(address),
                .wdata(writedata),
                .rdata(readdata),
                .rdata_valid(readdatavalid)
        );

 */
     serif_slave #(.ADDR_PAGE(BASE_TXFC), .TARGET_CHIP(TARGET_CHIP))

        avalon_serial_brdg (
                .clk(clk_mm),
                .din(smm_master_dout),
                .dout(smm_slave_dout),

                .wr(write),
                .rd(read),
                .addr(address),
                .wdata(writedata),
                .rdata(readdata),
                .rdata_valid(readdatavalid)
        );   
 
 
    alt_aeu_40_pfc_tx_csr #(
                .REVID(REVID), 
                .CSRADDRSIZE(8),  
                .NUMPRIORITY(NUMPRIORITY)
) pfc_tx_csr    (
                .clk(clk),
                .clk_mm(clk_mm), 
                .reset_n(reset_n),
                .read(read),
                .write(write),
                .address(address),
                .writedata(writedata),
                .waitrequest(),
                .readdatavalid(readdatavalid),
                .readdata(readdata),
                                        
                .cfg_enaqxin(cfg_enable_txins),
                .cfg_lholdoff_en(cfg_lholdoff_en),
                .cfg_qholdoff_en(cfg_qholdoff_en),
                .txon_frame(txon_frame),
                .txoff_frame(txoff_frame),
                .cfg_pause_quanta(cfg_pause_quanta),
                .cfg_lholdoff_quanta(cfg_lholdoff_quanta),
                .cfg_qholdoff_quanta(cfg_qholdoff_quanta),
                                        
                .cfg_saddr(cfg_saddr),
                .cfg_daddr(cfg_daddr),
                .cfg_pause_req(cfg_pause_req)
                );

 endmodule
