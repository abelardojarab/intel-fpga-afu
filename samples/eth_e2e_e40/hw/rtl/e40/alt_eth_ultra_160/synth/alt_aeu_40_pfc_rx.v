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


// altera message_off 10036 10236

`timescale 1 ps / 1 ps
module alt_aeu_40_pfc_rx #(
        parameter SYNOPT_ALIGN_FCSEOP = 0,
        parameter SYNOPT_PREAMBLE_PASS = 1,
        parameter TARGET_CHIP = 2,
        parameter NUMPRIORITY = 1,
        parameter REVID = 32'h02062015,
        parameter BASE_RXFC = 1,
        parameter ADDRSIZE = 8,
        parameter WORDS = 4,
        parameter RXERRWIDTH = 6,
        parameter RXSTATUSWIDTH = 3, //RxCtrl
        parameter EMPTYBITS = 5,
        parameter PIPE_INPUTS = 1
)(
        input clk_mm,
        input reset_mm,
        input smm_master_dout,
        output smm_slave_dout,
        
        input clk,
        input reset_n,
        output in_ready,
        input [RXERRWIDTH-1:0]    in_error,
        input in_error_valid,
        input [RXSTATUSWIDTH-1:0] in_status,
        input in_valid,
        input in_eop,
        input in_sop,
        input [EMPTYBITS-1:0]in_empty,
        input [WORDS*64-1:0] in_data,
        
        input out_ready,
        output [RXERRWIDTH-1:0]    out_error,
        output out_error_valid,
        output [RXSTATUSWIDTH-1:0] out_status,
        output out_valid,
        output out_sop,
        output out_eop,
        output[2:0] out_sband,
        output[EMPTYBITS-1:0] out_empty,
        output[WORDS*64-1:0] out_data,
        output[NUMPRIORITY-1:0] out_pause,
        output [NUMPRIORITY-1:0] rxon_frame,
        output [NUMPRIORITY-1:0] rxoff_frame
);
        
        wire drop_this_frame;
        assign out_sband[2] = drop_this_frame;
        
        assign in_ready = out_ready;
        wire [NUMPRIORITY-1:0] cfg_enable;
        wire[47:0] cfg_daddr;
        wire cfg_fwd_pause_frame;
        
        wire read;
        wire write;
        wire readdatavalid;
        wire [07:0]address;
        wire [31:0]writedata;
        wire [31:0]readdata;
/*      
        serif_slave_async #(
                .ADDR_PAGE(BASE_RXFC), 
                .TARGET_CHIP(TARGET_CHIP)
        ) avalon_serial_brdg (
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
        serif_slave #(
                .ADDR_PAGE(BASE_RXFC), 
                .TARGET_CHIP(TARGET_CHIP)
        ) avalon_serial_brdg (
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
        alt_aeu_40_pfc_rx_csr #(
                .REVID(REVID), 
                .ADDRSIZE( 8 ) ,
                .NUMPRIORITY(NUMPRIORITY)
                ) rx_csr (
                .clk(clk),
                .clk_mm (clk_mm),         
                .reset_n(reset_n),
                .read(read),
                .write(write),
                .address(address),
                .readdata(readdata),
                .writedata(writedata),
                .waitrequest(),
                .readdatavalid(readdatavalid),
        
                .rxon_frame(rxon_frame),
                .rxoff_frame(rxoff_frame),
                .cfg_enable(cfg_enable),
                .cfg_daddr(cfg_daddr),
                .cfg_fwd_pause_frame(cfg_fwd_pause_frame)
        );
        
        alt_aeu_40_pfc_rx_ctrl #(
                .WORDS(WORDS),
                .SYNOPT_ALIGN_FCSEOP(SYNOPT_ALIGN_FCSEOP),
                .SYNOPT_PREAMBLE_PASS(SYNOPT_PREAMBLE_PASS),
                .NUMPRIORITY(NUMPRIORITY),
                .PIPE_INPUTS(PIPE_INPUTS),
                .cfg_typlen(16'h8808),
                .cfg_opcode(16'h0101)
        ) rx_ctrl (
                .clk(clk),
                .reset_n(reset_n),
                .cfg_enable(cfg_enable),
                .cfg_daddr(cfg_daddr),
                .cfg_fwd_pause_frame(cfg_fwd_pause_frame),
                
                .in_fcserror(in_error[1]), // FCS error bit
                .in_fcsval(in_error_valid),
                .in_sop(in_sop),
                .in_valid(in_valid),
                .in_data(in_data),
                .rxon_frame(rxon_frame),
                .rxoff_frame(rxoff_frame),
                .rx_out_pause(out_pause),
                .drop_this_frame(drop_this_frame)
        );
        
        alt_aeu_40_pfc_rx_dp #(
                .WORDS(WORDS),
                .EMPTYBITS(EMPTYBITS),
                .SYNOPT_ALIGN_FCSEOP(SYNOPT_ALIGN_FCSEOP),
                .RXERRWIDTH(RXERRWIDTH),
                .RXSTATUSWIDTH(RXSTATUSWIDTH),
                .PIPE_INPUTS(PIPE_INPUTS)
        ) rxdp (
                .clk(clk),
                .reset_n(reset_n),
                .drop_this_frame(drop_this_frame),
                
                .in_eop(in_eop),
                .in_error(in_error),
                .in_status(in_status), // RxCtrl
                .in_error_valid(in_error_valid),
                .in_sop(in_sop),
                .in_valid(in_valid),
                .in_data(in_data),
                .in_empty(in_empty),
                
                .out_sband(out_sband[1:0]),
                .out_eop(out_eop),
                .out_error(out_error),
                .out_error_valid(out_error_valid),
                .out_status(out_status), // RxCtrl
                .out_sop(out_sop),
                .out_valid(out_valid) ,
                .out_data(out_data),
                .out_empty(out_empty));
        
        endmodule
