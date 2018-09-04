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


module  alt_e100s10_fecpll #(
   parameter SIM_EMULATE = 1'b0,
   parameter RX_PLL_TYPE       = "FPLL",
   parameter TX_PLL_TYPE       = "FPLL",
   parameter TX_IOPLL_REFCLK   = 1,
   parameter TX_PLL_LOCAT      = 0
   )(
   input         clk_ref,       // 644/322 mhz
   input         avmm_clk,      //

   input         clk_rx,        // rx xcvr input clock -- 390.625mhz
   input         clk_tx,        // tx xcvr input clock -- 390.625mhz
   output        clk_rx_rs,  // rx pll output clock -- 312.5mhz
   output        clk_tx_rs,  // tx pll output clock -- 312.5mhz

   output        rxfec_pll_locked, //rx fpll lock
   output        txfec_pll_locked, //tx fpll lock

   input         pma_reset,     //
   input         tx_pll_reset,  //

   input         txfec_pll_locked_frompll, //from outside of IP
   input         clk_tx_rs_frompll,        //outside of IP

   output        pll_recal_done, //40G: this one AND with rx_pcs_pll_locked then send to Pcs rx_set_locktoref
   output        rx_set_locktoref_e100, //40G send to pma's rx_set_locktoref
   input         rx_set_locktoref,      //from csr's out
   input [3:0]   rx_is_lockedtoref,
   input [3:0]   rx_is_lockedtodata

   );


// clean up the rcfg_** between 3 blocks
//---------------------------------------------
//------------- RX PCS Clock -- Start ---------
//---------------------------------------------
//-------------------------------------------------------------------------------------
// ----------------- Cascding and Calibration details----------------------------------
// on RX side CDR PLL is cascaded to either IOPLL or FPLL
// Here are the details of cascading and the solution we are using for cascading
// In S10 40G Ethernet on RX side we have CDR->PLL cascading, PLL can be IOPLL or FPLL.
// The complication is cascading where refclk of downgrade PLL is coming from CDR, 
// which is not stable after powerup so we need to recalibrate the PLL after powerup. 
// Remember in S10 we do need recalibration of IOPLL which was not the case for A10 IOPLL
// | --------|   |------------------| 
// |  CDR PLL|==>|refclk  IOPLL/FPLL|==> 312.5 Mhz clock (rx_coreclkin and core logic)
// |---------| 	 |------------------|
//   
// refclk in case of CDR->IOPLL cascading is rx_clkout (div33 clockout) = 156.25 Mhz
// refclk in case of CDR->FPLL  cascading is rx_pma_iqtxrxclkout (div40 clk) = 257.8125 Mhz    
// alt_e100s10_pll_recal.sv implements the recalibration logic
// Recalibration will kicked off at the assertion of either csr_rst_n or 
// soft_csr_rst (aka sys_rst/eio_sys_rst)
// In the logic below pma_reset is used pma_reset is native_phy_reset coming from the reset controller 
// and is asserted when csr_rst_n or sys_rst is asserted.  
// Recalibration sequence will be 
// Initially put CDR in locktoref mode by setting rx_set_locktoref to "1"
// wait CDR to lock to locktoref
// for stable locktoref wait for 20us
// Then start IOPLL/FPLL recalibration
// once recal is done switch CDR to auto mode
// Recalibration done is indicated by pll_recal_done
// Recal happens only once 
//-------------------------------------------------------------------------------------
// Need to connect with input for RX PLL: rx_is_lockedtoref, rx_clkout, avmm_clk, pma_reset, rx_is_lockedtodata
// 			input for TX PLL: txfec_pll_locked
// Need to connect with output for RX PLL: clk_rx_rs(from fpll and iopll)
// Need to connect with output for TX PLL: clk_tx_rs(from fpll)
// temp fix and will connect to the pma
   localparam CNTWIDTH = SIM_EMULATE ? 3: 9;  

   wire         int_rx_is_lockedtoref;
   wire         sync_rx_is_lockedtoref;   
   wire         sync_rx_is_lockedtodata;
   
   reg [CNTWIDTH-1:0] cnt_lock;
   reg          cnt_max;

   wire         rx_is_lockedtodata_stat = (cnt_max) ? 1'b1 : 1'b0;
   wire         recal_busy;
   wire         fpll_cal_busy;
   wire         rcfg_write;    // AVMM write
   wire         rcfg_read;     // AVMM read
   wire [10:0]  rcfg_address;  // AVMM address
   wire [31:0]  rcfg_wrdata;   // AVMM write data
   wire [31:0]  rcfg_rddata;   // AVMM read data
   wire         rcfg_wtrqst;   // AVMM wait request
  // wire [10:0]  reconfig_from_iopll; // reconfig_from_pll fro IOPLL
  // wire [29:0]  reconfig_to_iopll;//   reconfig_to_pll to IOPLL   
   wire 	rx_pll_reset;
   wire         clk_ref_tx;


   
   assign int_rx_is_lockedtoref = &rx_is_lockedtoref;

      // synchronize rx_is_lockedtoref wrt avmm_clk
   alt_e100s10_status_sync 
     #(.WIDTH(1))
   locktoref_sync (
    .clk  (avmm_clk),
    .din  (int_rx_is_lockedtoref),
    .dout (sync_rx_is_lockedtoref)
   );

 // Generate rx_is_lockedtodata_stat signal
 // if rx_is_lockedtodata is "1" for 4 us for L-tile and 5us for H-tile 
 // that indicates stable rx_lockedtodata
 // generate rx_is_lockedtodata_stat signal
 // with cnt_lock = 9 and mgmt_clk = 100 mhz (10ns) = 10 *512 = 5.12us
   
  // synchronize rx_is_lockedtodata wrt avmm_clk
  //wire rx_is_lockedtodata =0; //alvin added and waiting the connection from  top
  alt_e100s10_status_sync 
    #(.WIDTH(1))
  locktodata_sync (
		   .clk  (avmm_clk),
		   .din  (&rx_is_lockedtodata),
		   .dout (sync_rx_is_lockedtodata)
		   );

   // Counter for counting 5us for rx_lockedtodata
   always @(posedge avmm_clk or posedge pma_reset)
     begin
	if (pma_reset) 
	  begin
	     cnt_max  <= 1'b0;
	     cnt_lock <= {CNTWIDTH{1'b0}};
	  end
	else
	  begin
	     cnt_max <= (&cnt_lock);
	     if (~sync_rx_is_lockedtodata)      
	       cnt_lock <= {CNTWIDTH{1'b0}};
	     else if (&cnt_lock)  
	       cnt_lock <= cnt_lock;
	       else
	       cnt_lock <= cnt_lock + 1'b1;
	  end // else: !if(mgmt_reset)
     end // always @ (posedge mgmt_clk or posedge mgmt_reset)
   
   
   assign recal_busy = (RX_PLL_TYPE == "IOPLL") ? 1'b0 : fpll_cal_busy;
//   assign recal_busy = /*(RX_PLL_TYPE == "IOPLL") ?*/ 1'b0 ;//: fpll_cal_busy;

	     
//========================================
//========== Recalibration ===============
//========================================
// PLL recalibration module to recalibrate IOPLL/FPLL
   alt_e100s10_pll_recal  recal_fecrxpll (
	.mgmt_clk  (avmm_clk),			//in
        .mgmt_reset(pma_reset),			//in

        .cal_busy    (recal_busy),		//in -- from fecrxpll

        .rx_is_lockedtoref (sync_rx_is_lockedtoref),//in, from rx_is_locktoref(of pma/xcvr)
        .rx_set_locktoref_core (rx_set_locktoref),  //in, from csr's out
        .rx_set_locktoref (rx_set_locktoref_e100),  //out, to xcvr

        .recal_is_done      (pll_recal_done),	//out

        .rcfg_write(rcfg_write),		//out
        .rcfg_read (rcfg_read),			//out
        .rcfg_address(rcfg_address[10:0]),		//out
        .rcfg_wrdata (rcfg_wrdata[31:0]),		//out
        .rcfg_rddata (0/*rcfg_rddata[31:0]*/),	//in, temp to assign 0 to avoid iopll's clk no output.
        .rcfg_wtrqst (rcfg_wtrqst)		//in
        );
   
// IOPLL or FPLL as RX PLL
generate
       if (RX_PLL_TYPE == "FPLL") begin : RXFPLL_INST
 	 // Instantiate FPLL instance, for CDR->FPLL cascade need to use rx_pma_iqtsrx_clkout port
//========================================
//========== fPLL ========================
//========================================
/*
ct1_cmu_fpll_refclk_select_pld_adapt   fecrxpll_refclk_sel_adapt
(
    // Input Ports
    .AVMMCLK( avmm_clk ),
    .CORE_REFCLK( clk_rx ),
    .EXTSWITCH(  ),
    .INT_PLLCLKSEL(  ),
    .STA_CLK( ),
    .TX_RX_CORE_REFCLK( ),
    
    // Output Ports
    .INT_CORE_REFCLK( clk_rx_refclk_sel_adapt ),
    .INT_EXTSWITCH(  ),
    .INT_TX_RX_CORE_REFCLK(  ),
    .PLLCLKSEL(  )
);
defparam fecrxpll_refclk_sel_adapt.silicon_rev = "14nm5";
*/
wire clk_rx_refclk_sel_adapt = clk_rx;

     altera_xcvr_fpll_s10_rx fecrxpll 
 	   (           
 		       .outclk_div1 (clk_rx_rs), 			//out -- 312.5 mhz
 		       .pll_cal_busy (fpll_cal_busy),		//out -- to recal_fecrxpll
 		       .pll_locked (rxfec_pll_locked),		//out -- 	
 		       .pll_refclk0( clk_rx_refclk_sel_adapt ), //in  -- 390.625 mhz
 
                       .reconfig_write0(rcfg_write),		//in -- from recal_fecrxpll
                       .reconfig_read0 (rcfg_read),		//in -- from recal_fecrxpll
                       .reconfig_address0    (rcfg_address),	//in -- from recal_fecrxpll
                       .reconfig_writedata0  (rcfg_wrdata),	//in -- from recal_fecrxpll
                       .reconfig_readdata0   (rcfg_rddata),	//out-- to recal_fecrxpll
                       .reconfig_waitrequest0(rcfg_wtrqst),	//out-- to recal_fecrxpll
 
 		       .reconfig_clk0  (avmm_clk),		//in --
                       .reconfig_reset0(pma_reset)		//in --		      
 		       );
       end // block: FPLL_INST
//========================================
//========== IO PLL ======================
//========================================
       else begin : RXIOPLL_INST
	 assign rx_pll_reset = (pll_recal_done) ? ~rx_is_lockedtodata_stat : ~&rx_is_lockedtoref;
         
    alt_e100s10ex_iopll_rx fecrxpll 
      (
       .rst        (rx_pll_reset),				//in
       .refclk     (clk_rx),              			//in  -- 390.625mhz from pma/xcvr
       .locked     (rxfec_pll_locked),				//out
       .outclk_0   (clk_rx_rs),                			//out -- 312.5mhz
	.permit_cal (~rx_pll_reset)
       //.reconfig_from_pll (reconfig_from_iopll),		//out [10:0] -- to iopll_reconfig
       //.reconfig_to_pll (reconfig_to_iopll)			//in [29:0] -- from iopll_reconfig
	
       );
	 
    s10_iopll_reconfig  iopll_reconfig
      (
       .mgmt_waitrequest(rcfg_wtrqst),			//out -- to fecrxpll
       .mgmt_write(rcfg_write),				//in
       .mgmt_read(rcfg_read),				//in
       .mgmt_writedata(rcfg_wrdata[7:0]),			//in
       .mgmt_readdata(),					//out
       .mgmt_address(rcfg_address[9:0]),			//in
       .reconfig_from_pll(11'b0),		//in [10:0]
       .reconfig_to_pll(), 		//out [29:0]

       .mgmt_clk(avmm_clk),				//in
       .mgmt_reset(pma_reset)				//in
      );
//========================================
//========================================
//========================================
	 
      end // block: IOPLL_inst
endgenerate
//------------------------------------------
//------------- TX FEC PLL  ----------------
//------------------------------------------
//fPLL
generate
          wire   txfec_fpll_locked;
          wire   txfec_iopll_locked;
          assign clk_ref_tx  = (TX_IOPLL_REFCLK == 1) ? clk_tx : clk_ref;
          assign txfec_pll_locked  = (TX_PLL_TYPE == "FPLL") ? txfec_fpll_locked : txfec_iopll_locked;
if (TX_PLL_LOCAT == 0) begin : TXPLL_IN
     if (TX_PLL_TYPE == "FPLL") begin : TXFPLL_INST
        begin        : tx_pll_gen
            altera_xcvr_fpll_s10_tx fectxpll (
                .pll_refclk0    (clk_ref),				//in  -- 644.53125 or 322.265625mhz
                .outclk_div1    (clk_tx_rs),				//out -- 312.5mhz
                .pll_locked     (txfec_fpll_locked),
                .pll_cal_busy   (/* Unconnected */)
            );
            assign txfec_iopll_locked =0;
        end //tx_fpll_gen
     end //block: TXFPLL_INST
  //IOPLL
     else begin : TXIOPLL_INST
        begin        : tx_iopll_gen
            alt_e100s10ex_iopll_tx fectxpll (
               .rst        (tx_pll_reset),				//in
               .refclk     (clk_ref_tx),         	   		//in  -- 390.625/644.53125/322.265625mhz from refclk
               .locked     (txfec_iopll_locked),		 	//out
               .outclk_0   (clk_tx_rs)               			//out -- 312.5mhz
               //.reconfig_from_pll (reconfig_from_iopll),		//out [10:0] -- to iopll_reconfig
               //.reconfig_to_pll (reconfig_to_iopll)			//in [29:0] -- from iopll_reconfig
               );
            assign txfec_fpll_locked =0;
        end //tx_iopll_gen
     end //block: TXIOPLL_INST
  end else begin
          assign txfec_fpll_locked =txfec_pll_locked_frompll;
          assign txfec_iopll_locked =0;
          assign clk_tx_rs =clk_tx_rs_frompll;
  end
endgenerate

endmodule
