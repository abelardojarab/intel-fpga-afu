// *****************************************************************************
//
//                            INTEL CONFIDENTIAL
//
//           Copyright (C) 2018 Intel Corporation All Rights Reserved.
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
// ecustodi - Feb/2018 Added testbench for modelsim simulation

`timescale 1ns / 100ps
`include "platform_if.vh"

module tb();

logic pClk = 0;
logic pClkDiv2 = 0;
logic pClkDiv4 = 0;
logic uClk_usr = 0;
logic uClk_usrDiv2 = 0;
logic pck_cp2af_softReset = 1;
logic [1:0] pck_cp2af_pwrState = 0;
logic pck_cp2af_error = 0;
	
//always #2.5 pClk = ~pClk;
always #3.2 pClk = ~pClk;
always #5 pClkDiv2 = ~pClkDiv2;
always #10 pClkDiv4 = ~pClkDiv4;

always #3.2 uClk_usrDiv2 = ~uClk_usrDiv2;	// 156.25
always #1.6 uClk_usr = ~uClk_usr; 			// 312.5

//pr_hssi_if hssi();
/*
initial begin
	hssi.f2a_tx_clk = 0;
    hssi.f2a_tx_clkx2 = 0;
    hssi.f2a_tx_locked = 1;
    hssi.f2a_rx_clk_ln0 = 0;
    hssi.f2a_rx_clkx2_ln0 = 0;
    hssi.f2a_rx_locked_ln0 = 1;
    hssi.f2a_rx_clk_ln4 = 0;
    hssi.f2a_rx_locked_ln4 = 1;
    hssi.f2a_tx_cal_busy = 0;
    hssi.f2a_tx_pll_locked = 1;
    hssi.f2a_rx_cal_busy = 0;
    hssi.f2a_rx_is_lockedtoref = 4'hF;
    hssi.f2a_rx_is_lockedtodata = 4'hF;
    hssi.f2a_tx_enh_fifo_full = 0;
    hssi.f2a_tx_enh_fifo_pfull = 0;
    hssi.f2a_tx_enh_fifo_empty = 0;
    hssi.f2a_tx_enh_fifo_pempty = 0;
    hssi.f2a_rx_enh_data_valid = 1;
    hssi.f2a_rx_enh_fifo_full = 0;
    hssi.f2a_rx_enh_fifo_pfull = 0;
    hssi.f2a_rx_enh_fifo_empty = 0;
    hssi.f2a_rx_enh_fifo_pempty = 0;
    hssi.f2a_rx_enh_blk_lock = 1;
    hssi.f2a_rx_enh_highber = 0;
    hssi.f2a_init_done = 1;
    hssi.f2a_prmgmt_ctrl_clk = 0;
    hssi.f2a_prmgmt_cmd = 0;
    hssi.f2a_prmgmt_addr = 0;
    hssi.f2a_prmgmt_din = 0;
    hssi.f2a_prmgmt_freeze = 0;
    hssi.f2a_prmgmt_arst = 1;
    hssi.f2a_prmgmt_ram_ena = 0;
end
*/
genvar x;
/*
always #3.2 hssi.f2a_tx_clk        = ~hssi.f2a_tx_clk;
always #3.2 hssi.f2a_rx_clk_ln0    = ~hssi.f2a_rx_clk_ln0;
always #1.6 hssi.f2a_tx_clkx2      = ~hssi.f2a_tx_clkx2;
always #1.6 hssi.f2a_rx_clkx2_ln0  = ~hssi.f2a_rx_clkx2_ln0;
always #5 hssi.f2a_prmgmt_ctrl_clk = ~hssi.f2a_prmgmt_ctrl_clk;

assign hssi.f2a_rx_parallel_data = hssi.a2f_tx_parallel_data;

generate 
for (x = 0;x<4;x=x+1) begin : gv1
	assign hssi.f2a_rx_control[(x*20)+19:(x*20)] = {2'b0,hssi.a2f_tx_control[(x*18)+17:(x*18)]};
end
endgenerate
*/


t_if_ccip_Rx ccip_rx;
t_if_ccip_Tx ccip_tx;
t_ccip_c0_ReqMmioHdr hdr = 0;
int i = 0;


reg [63:0] test;
reg [63:0] test2;
task mmioread64;
input [15:0] addr;
output [63:0] ret;
begin
	@(posedge pClk);
	hdr.address = addr<<1;
	hdr.length = 2'b10;
	$cast(ccip_rx.c0.hdr,hdr);
	ccip_rx.c0.mmioRdValid = 1;
	@(posedge pClk);
	ccip_rx.c0.mmioRdValid = 0;
	@(posedge pClk);
	@(posedge ccip_tx.c2.mmioRdValid)
	`ifdef DEBUG_MODE
	$display("MMIO READ  (0x%x): 0x%x %f",addr,ccip_tx.c2.data,$time());
	`endif
	ret = ccip_tx.c2.data;
	@(posedge pClk);
end
endtask

task mmiowrite64;
input [15:0] addr;
input [63:0] val;
begin
	@(posedge pClk);
	ccip_rx.c0.mmioWrValid = 1;
	ccip_rx.c0.data = val;
	hdr.address = addr<<1;
	hdr.length = 2'b10;
	$cast(ccip_rx.c0.hdr,hdr);
	`ifdef DEBUG_MODE
	$display("MMIO WRITE (0x%x): 0x%x",addr,val);
	`endif
	@(posedge pClk);
	ccip_rx.c0.mmioWrValid = 0;
	@(posedge pClk);
end
endtask

task prmgread;
input [15:0] addr;
output [31:0] ret;
begin
	@(posedge pClk);
	mmiowrite64(6,64'h20000 | addr);
	mmiowrite64(6,64'h0);
	#200;
	mmioread64(8,ret);
	`ifdef DEBUG_MODE
	$display("PRMG READ  (0x%x): 0x%x",addr,ret);
	`endif
end
endtask

task prmgwrite;
input [15:0] addr;
input [31:0] val;
begin
	@(posedge pClk);
	mmiowrite64(7,val);
	mmiowrite64(6,64'h10000 | addr);
	mmiowrite64(6,64'h0);
	`ifdef DEBUG_MODE
	$display("PRMG WRITE (0x%x): 0x%x",addr,val);
	`endif
end
endtask

task e10read;
input [15:0] addr;
output [31:0] ret;
begin
	@(posedge pClk);
	prmgwrite(2,64'h20000 | addr);
	prmgread(4,ret);
	`ifdef DEBUG_MODE
	$display(" E10 READ  (0x%x): 0x%x",addr,ret);
	`endif
end
endtask

task e10write;
input [15:0] addr;
input [31:0] val;
begin
	@(posedge pClk);
	prmgwrite(3,val);
	prmgwrite(2,64'h10000 | addr);
	`ifdef DEBUG_MODE
	$display(" E10 WRITE (0x%x): 0x%x",addr,val);
	`endif
end
endtask

task e10_tx_stat;
begin
	$display("TX side statistics -- ");
	e10read(16'h1c00+2,test[31:0]);
	e10read(16'h1c00+3,test[63:32]);
	$display("Frames OK:		%d",test);
	e10read(16'h1c00+4,test[31:0]);
	e10read(16'h1c00+5,test[63:32]);
	$display("Frames Err:		%d",test);
	e10read(16'h1c00+6,test[31:0]);
	e10read(16'h1c00+7,test[63:32]);
	$display("Frames CRC:		%d",test);
	e10read(16'h1c00+8,test[31:0]);
	e10read(16'h1c00+9,test[63:32]);
	$display("Bytes OK:		%d",test);
	$display("");
end
endtask

task e10_rx_stat;
begin
	$display("RX side statistics -- ");
	e10read(16'hc00+2,test[31:0]);
	e10read(16'hc00+3,test[63:32]);
	$display("Frames OK:		%d",test);
	e10read(16'hc00+4,test[31:0]);
	e10read(16'hc00+5,test[63:32]);
	$display("Frames Err:		%d",test);
	e10read(16'hc00+6,test[31:0]);
	e10read(16'hc00+7,test[63:32]);
	$display("Frames CRC:		%d",test);
	e10read(16'hc00+8,test[31:0]);
	e10read(16'hc00+9,test[63:32]);
	$display("Bytes OK:		%d",test);
	$display("");
end
endtask

task e10_stat;
begin
	prmgread(6,test[31:0]);
	$display("TxRx loop : %x",test[31:0]);
	prmgread(7,test[31:0]);
	$display("Freq lock : %x",test[31:0]);
	prmgread(8,test[31:0]);
	$display("Word lock : %x",test[31:0]);
	$display("");
	for (i=0;i<4;i=i+1) begin
		$display("*** 10GE port %d\n",i[1:0]);
		prmgwrite(5,i);
		e10_tx_stat();
		e10_rx_stat();
	end
end	
endtask

task e10_pkt_send;
input [1:0] port;
input [31:0] numpkts;
begin
	$display("*** 10GE port %d sending %d packets...",port[1:0],numpkts);
	prmgwrite(5,port);
	e10write(16'h3c00,numpkts);
	e10write(16'h3c0d,150);
	e10write(16'h3c03,1);       // go bit
end	
endtask

logic [3:0] rxstatus = 0;
logic [3:0] txstatus = 0;


generate
    for (x=0; x<4; x=x+1) begin : xn0
		always begin
			@(posedge afu.prz0.lp0[x].eth0.tx_ready_export);
			$display("10G Port %d : TX path is UP!",x[1:0]);
			txstatus[x] = 1;
			@(negedge afu.prz0.lp0[x].eth0.tx_ready_export);
			$display("10G Port %d : TX path is DOWN!",x[1:0]);
			txstatus[x] = 0;
		end
		always begin
			@(posedge afu.prz0.lp0[x].eth0.rx_ready_export);
			$display("10G Port %d : RX path is UP!",x[1:0]);
			rxstatus[x] = 1;
			@(negedge afu.prz0.lp0[x].eth0.rx_ready_export);
			$display("10G Port %d : RX path is DOWN!",x[1:0]);
			rxstatus[x] = 0;
		end
	end
endgenerate

initial begin
	#1000;
	@(posedge pClk);
	$display("####################################");
	$display("###### ETH_E2E_E10 SIM: Start ######");
	$display("####################################");
	$display("Releasing Reset...");
	pck_cp2af_softReset = 0;
	//hssi.f2a_prmgmt_arst = 0;
	//hssi.f2a_prmgmt_ram_ena = 1;

	#500;
	$display("Performing AFU MMIO scratch test...");
	mmiowrite64(9,64'hdeefd00fd11fdaaf);
	mmioread64(9,test);
	assert (test == 64'hdeefd00fd11fdaaf) else begin
		$display("FAILED!");
		$fatal(1,"AFU MMIO scratch test failure (0x%x != 0x%x)",test,64'hdeefd00fd11fdaaf);
	end
	$display("PASSED!");
	
	$display("Performing E2E MMIO scratch test...");
	prmgwrite(0,32'hDAEFCAFE);
	prmgread(0,test[31:0]);
	assert (test[31:0] == 32'hDAEFCAFE) else begin
		$display("FAILED!");
		$fatal(1,"E2E MMIO scratch test failure (0x%x != 0x%x)",test[31:0],32'hDAEFCAFE);
	end
	$display("PASSED!");
	
	$display("Releasing Resets from MACs...");
	prmgwrite(1,32'h0);
	prmgwrite(6,32'hf);
	#10000;
	
	pck_cp2af_softReset = 0;
	//hssi.f2a_prmgmt_arst = 0;
	//hssi.f2a_prmgmt_ram_ena = 1;
	
	$display("");
	$display("Reading out stat counters...");
	$display("");
	
	e10_stat();
	
	$display("Checking current link status...");
	assert ((rxstatus == 4'hf) && (txstatus == 4'hf)) else begin
		$display("FAILED!");
		$fatal(1,"Link status not fully up on all MACs! (0x%x,0x%x)",rxstatus,txstatus);
	end
	$display("Links are GOOD!");
	#5000;
	e10_pkt_send(0,10);
	e10_pkt_send(1,10);
	e10_pkt_send(2,10);
	e10_pkt_send(3,10);
	#10000;
	e10_stat();
	
	for (i=0;i<4;i=i+1) begin
		$display("Comparing port %d packet counts...",i[1:0]);
		prmgwrite(5,i);
		e10read(16'h1c00+2,test[31:0]);
		e10read(16'h1c00+3,test[63:32]);
		e10read(16'hc00+2,test2[31:0]);
		e10read(16'hc00+3,test2[63:32]);
		
		assert (test == test2) else begin
			$display("FAILED!");
			$fatal(1,"Port %d TX Packet Count != Rx Packet Count! (TX: %d, RX: %d)",i[1:0],test,test2);
		end
		$display("Packet counts are GOOD!");
	end
	
	$display("All tests passed!");
	$display("####################################");
	$display("###### ETH_E2E_E10 SIM: End   ######");
	$display("####################################");
	$finish();
end




ccip_std_afu afu (
    // CCI-P Clocks and Resets
    .pClk(pClk),                 // Primary CCI-P interface clock.
    .pClkDiv2(pClkDiv2),             // Aligned, pClk divided by 2.
    .pClkDiv4(pClkDiv4),             // Aligned, pClk divided by 4.
    .uClk_usr(uClk_usr),             // User clock domain. Refer to clock programming guide.
    .uClk_usrDiv2(uClk_usrDiv2),         // Aligned, user clock divided by 2.
    .pck_cp2af_softReset(pck_cp2af_softReset),  // CCI-P ACTIVE HIGH Soft Reset
    .pck_cp2af_pwrState(pck_cp2af_pwrState),   // CCI-P AFU Power State
    .pck_cp2af_error(pck_cp2af_error),      // CCI-P Protocol Error Detected

    // Raw HSSI interface
    //.hssi(hssi),

    // CCI-P structures
    .pck_cp2af_sRx(ccip_rx),        // CCI-P Rx Port
    .pck_af2cp_sTx(ccip_tx)         // CCI-P Tx Port
    );


endmodule
