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


// $Id: $
// $Revision: $
// $Date: $
// $Author: $
//-----------------------------------------------------------------------------

`timescale 1 ps / 1 ps
// baeckler - 02-22-2012
// 32 bit MLAB RAM with strong parity check
// write data has an extra tick of delay in here versus the waddr and wena

module alt_e100s10_mlab_32word_32bit #(
    parameter TARGET_CHIP = 1, // 1 S4, 2 S5
    parameter SIM_EMULATE = 1'b0
)(
    input clk,
    input wena,
    input [4:0] waddr_reg,
    input [31:0] wdata,
    input [4:0] raddr,
    output [31:0] rdata,

    input sclr_parity_err,
    output parity_err
);

//////////////////////////////////
// add parity on the wdata

wire [7:0] wdata_p;
alt_e100s10_dip8_32 ip (
    .d(wdata),
    .p(wdata_p)
);

reg [39:0] wdata_reg = 40'b0 /* synthesis preserve_syn_only */;
always @(posedge clk) begin
    wdata_reg <= {wdata,~wdata_p};
end

//////////////////////////////////
// RAM

wire [39:0] rdata_w;
generate
    if (TARGET_CHIP == 1) begin : s4
        s4mlab m0 (
            .wclk(clk),
            .wena(wena),
            .waddr_reg(waddr_reg),
            .wdata_reg(wdata_reg[19:0]),
            .raddr(raddr),
            .rdata(rdata_w[19:0])
        );
        s4mlab m1 (
            .wclk(clk),
            .wena(wena),
            .waddr_reg(waddr_reg),
            .wdata_reg(wdata_reg[39:20]),
            .raddr(raddr),
            .rdata(rdata_w[39:20])
        );
    end
    else if (TARGET_CHIP == 2) begin : s5
        s5mlab m0 (
            .wclk(clk),
            .wena(wena),
            .waddr_reg(waddr_reg),
            .wdata_reg(wdata_reg[19:0]),
            .raddr(raddr),
            .rdata(rdata_w[19:0])
        );
        s5mlab m1 (
            .wclk(clk),
            .wena(wena),
            .waddr_reg(waddr_reg),
            .wdata_reg(wdata_reg[39:20]),
            .raddr(raddr),
            .rdata(rdata_w[39:20])
        );
    end
    else begin
        //alt_e100s10_a10mlab m0 (
        alt_e100s10_mlab #(
            .SIM_EMULATE    (SIM_EMULATE)
        ) m0 (
            .wclk(clk),
            .wena(wena),
            .waddr_reg(waddr_reg),
            .wdata_reg(wdata_reg[19:0]),
            .raddr(raddr),
            .rdata(rdata_w[19:0])
        );
        //alt_e100s10_a10mlab m1 (
        alt_e100s10_mlab #(
            .SIM_EMULATE    (SIM_EMULATE)
        ) m1 (
            .wclk(clk),
            .wena(wena),
            .waddr_reg(waddr_reg),
            .wdata_reg(wdata_reg[39:20]),
            .raddr(raddr),
            .rdata(rdata_w[39:20])
        );
    end
endgenerate

//////////////////////////////////
// catch the rdata in register

reg [39:0] rdata_r = {40{1'b0}} /* synthesis preserve_syn_only */;
always @(posedge clk) begin
    rdata_r <= rdata_w;
end

// release the data, and keep working on the parity
assign rdata = rdata_r[39:8];

wire [7:0] rdata_p;
alt_e100s10_dip8_32 op (
    .d(rdata_r[39:8]),
    .p(rdata_p)
);

reg [7:0] rdata_chk = 8'h0 /* synthesis preserve_syn_only */;
always @(posedge clk) begin
    rdata_chk <= rdata_p ^ rdata_r[7:0];
end

reg n0=1'b0 /* synthesis preserve_syn_only */;
reg n1=1'b0 /* synthesis preserve_syn_only */;
reg parity_err_r = 1'b1 /* synthesis preserve_syn_only */;

always @(posedge clk) begin
    n0 <= &rdata_chk[3:0];
    n1 <= &rdata_chk[7:4];
    parity_err_r <= sclr_parity_err ? 1'b0 :
            (parity_err_r || !n0 || !n1);
end

assign parity_err = parity_err_r;

endmodule

// BENCHMARK INFO :  5SGXEA7N2F45C2
// BENCHMARK INFO :  Max depth :  1.0 LUTs
// BENCHMARK INFO :  Total registers : 91
// BENCHMARK INFO :  Total pins : 78
// BENCHMARK INFO :  Total virtual pins : 0
// BENCHMARK INFO :  Total block memory bits : 0
// BENCHMARK INFO :  Comb ALUTs :                         ; 20              ;       ;
// BENCHMARK INFO :  ALMs : 49 / 234,720 ( < 1 % )
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.352 ns, From wdata_reg[31], To s5mlab:m1|ml[11].lrm~OBSERVABLEPORTADATAINREGOUT0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.354 ns, From wdata_reg[23], To s5mlab:m1|ml[3].lrm~OBSERVABLEPORTADATAINREGOUT0}
// BENCHMARK INFO :  Worst setup path @ 468.75MHz : 1.271 ns, From wdata_reg[16], To s5mlab:m0|ml[16].lrm~OBSERVABLEPORTADATAINREGOUT0}
