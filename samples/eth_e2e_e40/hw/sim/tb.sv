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
	
always #2.5 pClk = ~pClk;
always #5 pClkDiv2 = ~pClkDiv2;
always #10 pClkDiv4 = ~pClkDiv4;

pr_hssi_if hssi();

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
	hssi.f2a_rx_control = 0;
	hssi.f2a_rx_parallel_data = 512'h0;
end

logic [511:0] virtfifo[$];

always #1.6 hssi.f2a_tx_clk        = ~hssi.f2a_tx_clk;
always #1.6 hssi.f2a_rx_clk_ln0    = ~hssi.f2a_rx_clk_ln0;
always #1.6 hssi.f2a_tx_clkx2      = ~hssi.f2a_tx_clkx2;
always #1.6 hssi.f2a_rx_clkx2_ln0  = ~hssi.f2a_rx_clkx2_ln0;
always #5 hssi.f2a_prmgmt_ctrl_clk = ~hssi.f2a_prmgmt_ctrl_clk;

always @(posedge hssi.f2a_tx_clk) begin
	if (hssi.a2f_tx_enh_data_valid[0]) virtfifo.push_back(hssi.a2f_tx_parallel_data);
	if (hssi.a2f_rx_enh_fifo_rd_en[0] && (virtfifo.size() > 0)) virtfifo.pop_front();	
end
always @(*) begin
	hssi.f2a_rx_parallel_data = (virtfifo.size() > 0) ? virtfifo[0] : 512'h0;
end

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
	#400;
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
	#400;
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
	#500;
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

task e40read;
input [15:0] addr;
output [31:0] ret;
begin
	@(posedge pClk);
	prmgwrite(2,64'h20000 | addr);
	prmgread(4,ret);
	`ifdef DEBUG_MODE
	$display(" E40 READ  (0x%x): 0x%x",addr,ret);
	`endif
end
endtask

task e40write;
input [15:0] addr;
input [31:0] val;
begin
	@(posedge pClk);
	prmgwrite(3,val);
	prmgwrite(2,64'h10000 | addr);
	`ifdef DEBUG_MODE
	$display(" E40 WRITE (0x%x): 0x%x",addr,val);
	`endif
end
endtask

task e40trafread;
input [15:0] addr;
output [31:0] ret;
begin
	@(posedge pClk);
	prmgwrite(16'ha,64'h20000 | addr);
	prmgread(16'hc,ret);
	`ifdef DEBUG_MODE
	$display(" E40 trafREAD  (0x%x): 0x%x",addr,ret);
	`endif
end
endtask

task e40trafwrite;
input [15:0] addr;
input [31:0] val;
begin
	@(posedge pClk);
	prmgwrite(16'hb,val);
	prmgwrite(16'ha,64'h10000 | addr);
	`ifdef DEBUG_MODE
	$display(" E40 trafWRITE (0x%x): 0x%x",addr,val);
	`endif
end
endtask

task e40_stat;
begin
	$display("************************");
	$display("** A10 40GbE port 0");
	$display("************************");
	$display("");
	$display("Packet Stats");
	e40write(16'h945,4); // shadow on
	e40read(16'h837,test[63:32]);
	e40read(16'h836,test[31:0]);
	$display( "TX packets : %d" ,test);
	e40read(16'h817,test[63:32]);
	e40read(16'h816,test[31:0]);
	$display( "TX 64b     : %d" ,test);
	
	e40read(16'h937,test[63:32]);
	e40read(16'h936,test[31:0]);
	$display( "RX packets : %d" ,test);
	e40read(16'h935,test[63:32]);
	e40read(16'h934,test[31:0]);
	$display( "RX runts   : %d" ,test);
	e40read(16'h907,test[63:32]);
	e40read(16'h906,test[31:0]);
	$display( "RX CRC err : %d" ,test);
	e40write(16'h945,0); // shadow off
	$display("************************");
end	
endtask

task e40_pkt_send;
input [31:0] numpkts;
begin

	$display("Sending %d 1500-byte packets...", numpkts );
	e40trafwrite(16'h4,numpkts);
	e40trafwrite(16'h5,1500);
	e40trafwrite(16'h6,0);
	e40trafwrite(16'h7,1);
	e40trafwrite(16'h7,0);

end	
endtask

initial begin
	#1000;
	@(posedge pClk);
	$display("####################################");
	$display("###### ETH_E2E_E40 SIM: Start ######");
	$display("####################################");
	$display("Releasing Reset...");
	pck_cp2af_softReset = 0;
	hssi.f2a_prmgmt_arst = 0;
	hssi.f2a_prmgmt_ram_ena = 1;
	#500;
	prmgwrite(1,32'h0); // release e40 arst
	#2000;
	$display("Waiting for RX PCS alignment...");
	@(posedge afu.prz0.alt_eth_ultra_0.rx_pcs_ready);
	#2000;
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
	$display("Performing E40 MMIO scratch test...");
	e40write(16'h301,32'hDAEFCAFE);
	e40read(16'h301,test[31:0]);
	assert (test[31:0] == 32'hDAEFCAFE) else begin
		$display("FAILED!");
		$fatal(1,"E2E MMIO scratch test failure (0x%x != 0x%x)",test[31:0],32'hDAEFCAFE);
	end
	$display("PASSED!");
	
	$display("Printing packet stats...");
	e40_stat();
	e40_pkt_send(10);
	#10000;
	$display("Printing packet stats...");
	e40_stat();
	$display("Comparing port 0 packet counts...");
	e40write(16'h945,4); // shadow on
	e40read(16'h837,test[63:32]);
	e40read(16'h836,test[31:0]);
	e40read(16'h937,test2[63:32]);
	e40read(16'h936,test2[31:0]);
	e40write(16'h945,0); // shadow off
	assert (test == test2) else begin
		$display("FAILED!");
		$fatal(1,"Port 0 TX Packet Count != Rx Packet Count! (TX: %d, RX: %d)",test,test2);
	end
	$display("Packet counts are GOOD!");
	$display("All tests passed!");
	$display("####################################");
	$display("###### ETH_E2E_E40 SIM: End   ######");
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
    .hssi(hssi),

    // CCI-P structures
    .pck_cp2af_sRx(ccip_rx),        // CCI-P Rx Port
    .pck_af2cp_sTx(ccip_tx)         // CCI-P Tx Port
    );
defparam afu.prz0.alt_eth_ultra_0.SYNOPT_FULL_SKEW = 0;
defparam afu.prz0.alt_eth_ultra_0.AM_CNT_BITS      = 6;
defparam afu.prz0.alt_eth_ultra_0.RST_CNTR         = 6;
defparam afu.prz0.alt_eth_ultra_0.CREATE_TX_SKEW   = 1'b0;

/////////////////////////////////////////////////////////////////////////
// FASTSIM mode defparams - Run a full simulation before using this mode.
/////////////////////////////////////////////////////////////////////////
//defparam afu.prz0.alt_eth_ultra_0.FASTSIM 	       = 1;
//defparam afu.prz0.alt_eth_ultra_0.FORCE_RO_SELS    = 140'he4e4e4e4e48d111a223444688e4e4e4e4e4;
//defparam afu.prz0.alt_eth_ultra_0.FORCE_BPOS       = 24'h965965;
//defparam afu.prz0.alt_eth_ultra_0.FORCE_WPOS       = 20'h18c63;
////////////////////////////////////////////////////////////////////////

int timer = 0;
always begin
	#10000;
	timer = timer + 1;
	if (!afu.prz0.alt_eth_ultra_0.rx_pcs_ready) $display("%d microseconds have passed...",timer*10);
end

always begin
	@(posedge afu.prz0.alt_eth_ultra_0.tx_lanes_stable);
	$display("Transmit lanes stable");
	@(negedge afu.prz0.alt_eth_ultra_0.tx_lanes_stable);
	$display("Transmit lanes lost stability");
end

initial begin
	#2000;
	if (afu.prz0.alt_eth_ultra_0.FASTSIM) begin
		$display("");
		$display("NOTE: FASTSIM is enabled with simulation specific alignment parameters.");
		$display("NOTE: If these are the default parameters they may not work and will");
		$display("NOTE: cause RX errors. Perform a full sim to get correct parameters.");
		$display("NOTE: The RX PCS should fully align within 50 microseconds.");
		$display("");
	end else begin
		$display("");
		$display("NOTE: FASTSIM is NOT enabled");
		$display("NOTE: The RX PCS may take +300 microseconds to fully align.");
		$display("NOTE: Once alignment takes place, record the alignment parameters (ro_sels,bpos,wpos)");
		$display("NOTE: to be used in FASTSIM mode in a later simulation. These parameters");
		$display("NOTE: are environment specific, The default values may not work.");
		$display("");
	end
end

always begin
	@(posedge afu.prz0.alt_eth_ultra_0.rx_pcs_ready);
	$display("Recieve PCS fully aligned");
	$display("");
	$display("FASTSIM alignment parameters:");
    $display("RO_SELS: %x",afu.prz0.alt_eth_ultra_0.rpcs.ro_sels);
    $display("BPOS: %x",afu.prz0.alt_eth_ultra_0.rpcs.bpos);  
    $display("WPOS: %x",afu.prz0.alt_eth_ultra_0.rpcs.wpos);   
	$display("NOTE: use the parameters above for FASTSIM mode");
	$display("NOTE: by editing tb.sv and uncommenting and");
	$display("NOTE: modifying the corresponding defparams.");
	$display("");
	@(negedge afu.prz0.alt_eth_ultra_0.rx_pcs_ready);
	$display("Recieve PCS lost alignment");
end

endmodule
