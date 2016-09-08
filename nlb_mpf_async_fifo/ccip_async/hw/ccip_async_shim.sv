import ccip_if_pkg::*;

module ccip_async_shim
  #(
    parameter DEBUG_ENABLE = 0,
    parameter ENABLE_EXTRA_PIPELINE = 1
    )
   (
    // Blue Bitstream Interface
    input logic  bb_softreset,
    input logic  bb_clk,
    output 	 t_if_ccip_Tx bb_tx,
    input 	 t_if_ccip_Rx bb_rx,
    // AFU interface
    output logic afu_softreset,
    input logic  afu_clk,
    input 	 t_if_ccip_Tx afu_tx,
    output 	 t_if_ccip_Rx afu_rx
    );

   localparam TX0_REQ_TOTAL_WIDTH = 1 + $bits(t_ccip_c0_ReqMemHdr) ;
   localparam TX1_REQ_TOTAL_WIDTH = 1 + $bits(t_ccip_c1_ReqMemHdr) + CCIP_CLDATA_WIDTH;
   localparam TX2_REQ_TOTAL_WIDTH = 1 + $bits(t_ccip_c2_RspMmioHdr) + CCIP_MMIODATA_WIDTH;
   localparam RX0_RSP_TOTAL_WIDTH = 3 + $bits(t_ccip_c0_RspMemHdr) + CCIP_CLDATA_WIDTH;
   localparam RX1_RSP_TOTAL_WIDTH = 1 + $bits(t_ccip_c1_RspMemHdr);

   localparam COUNTER_WIDTH = 9;


   /*
    * Reset synchronizer
    */
   logic 	      softreset_T1;
   logic 	      softreset_T2;

   always @(posedge afu_clk) begin
      softreset_T1 <= bb_softreset;
      softreset_T2 <= softreset_T1;
      afu_softreset <= softreset_T2;
   end

   /*
    * C0Tx Channel
    */
   logic [TX0_REQ_TOTAL_WIDTH-1:0] c0tx_dout;
   logic 			   c0tx_rdreq;
   logic 			   c0tx_rdempty;
   logic 			   c0tx_rdempty_q;
   logic [COUNTER_WIDTH-1:0] 	   c0tx_cnt;
   logic 			   c0tx_valid;

   c0tx_afifo c0tx_afifo
     (
      .data    ( {afu_tx.c0.hdr, afu_tx.c0.valid} ),
      .wrreq   ( afu_tx.c0.valid ),
      .rdreq   ( c0tx_rdreq ),
      .wrclk   ( afu_clk ),
      .rdclk   ( bb_clk ),
      .aclr    ( bb_softreset ),
      .q       ( c0tx_dout ),
      .rdusedw ( ),
      .wrusedw ( c0tx_cnt ),
      .rdfull  ( ),
      .rdempty ( c0tx_rdempty ),
      .wrfull  ( ),
      .wrempty ( )
      );
   
   always @(posedge bb_clk) begin
      c0tx_valid <= c0tx_rdreq & ~c0tx_rdempty;
   end

   // Extra pipeline register to ease timing pressure -- disable as needed
   generate
      if (ENABLE_EXTRA_PIPELINE == 1) begin
	 always @(posedge bb_clk) begin
	    c0tx_rdempty_q <= c0tx_rdempty;
	 end
      end
      else begin
	 always @(*) begin
	    c0tx_rdempty_q <= c0tx_rdempty;
	 end
      end
   endgenerate
   
      
   always @(posedge bb_clk) begin
      c0tx_rdreq <= ~bb_rx.c0TxAlmFull & ~c0tx_rdempty_q;
   end

   always @(posedge bb_clk) begin
      if (c0tx_valid) begin
	 {bb_tx.c0.hdr, bb_tx.c0.valid} <= c0tx_dout;
      end
      else begin
	 {bb_tx.c0.hdr, bb_tx.c0.valid} <= 0;
      end
   end

   always @(posedge afu_clk) begin
      afu_rx.c0TxAlmFull <= c0tx_cnt[COUNTER_WIDTH-2];
   end


   /*
    * C1Tx Channel
    */
   logic [TX1_REQ_TOTAL_WIDTH-1:0] c1tx_dout;
   logic 			   c1tx_rdreq;
   logic 			   c1tx_rdempty;
   logic 			   c1tx_rdempty_q;
   logic [COUNTER_WIDTH-1:0] 	   c1tx_cnt;
   logic 			   c1tx_valid;

   c1tx_afifo c1tx_afifo
     (
      .data    ( {afu_tx.c1.hdr, afu_tx.c1.data, afu_tx.c1.valid} ),
      .wrreq   ( afu_tx.c1.valid ),
      .rdreq   ( c1tx_rdreq ),
      .wrclk   ( afu_clk ),
      .rdclk   ( bb_clk ),
      .aclr    ( bb_softreset ),
      .q       ( c1tx_dout ),
      .rdusedw ( ),
      .wrusedw ( c1tx_cnt ),
      .rdfull  ( ),
      .rdempty ( c1tx_rdempty ),
      .wrfull  ( ),
      .wrempty ( )
      );

   always @(posedge bb_clk) begin
      c1tx_valid <= c1tx_rdreq & ~c1tx_rdempty;
   end

   // Extra pipeline register to ease timing pressure -- disable as needed
   generate
      if (ENABLE_EXTRA_PIPELINE == 1) begin
	 always @(posedge bb_clk) begin
	    c1tx_rdempty_q <= c1tx_rdempty;
	 end
      end
      else begin
	 always @(*) begin
	    c1tx_rdempty_q <= c1tx_rdempty;
	 end
      end
   endgenerate  
   
   always @(posedge bb_clk) begin
      c1tx_rdreq <= ~bb_rx.c1TxAlmFull & ~c1tx_rdempty_q;
   end

   always @(posedge bb_clk) begin
      if (c1tx_valid) begin
	 {bb_tx.c1.hdr, bb_tx.c1.data, bb_tx.c1.valid} <= c1tx_dout;
      end
      else begin
	 {bb_tx.c1.hdr, bb_tx.c1.data, bb_tx.c1.valid} <= 0;
      end
   end

   always @(posedge afu_clk) begin
      afu_rx.c1TxAlmFull <= c1tx_cnt[COUNTER_WIDTH-2];
   end


   /*
    * C2Tx Channel
    */
   logic [TX2_REQ_TOTAL_WIDTH-1:0] c2tx_dout;
   logic 			   c2tx_rdreq;
   logic 			   c2tx_rdempty;
   logic 			   c2tx_valid;

   c2tx_afifo c2tx_afifo
     (
      .data    ( {afu_tx.c2.hdr, afu_tx.c2.mmioRdValid, afu_tx.c2.data} ),
      .wrreq   ( afu_tx.c2.mmioRdValid ),
      .rdreq   ( c2tx_rdreq ),
      .wrclk   ( afu_clk ),
      .rdclk   ( bb_clk ),
      .aclr    ( bb_softreset ),
      .q       ( c2tx_dout ),
      .rdusedw (),
      .wrusedw (),
      .rdfull  (),
      .rdempty ( c2tx_rdempty ),
      .wrfull  (),
      .wrempty ()
      );

   always @(posedge bb_clk) begin
      c2tx_valid <= c2tx_rdreq & ~c2tx_rdempty;
   end

   always @(posedge bb_clk) begin
      c2tx_rdreq <= ~c2tx_rdempty;
   end

   always @(posedge bb_clk) begin
      if (c2tx_valid) begin
	 {bb_tx.c2.hdr, bb_tx.c2.mmioRdValid, bb_tx.c2.data} <= c2tx_dout;
      end
      else begin
	 {bb_tx.c2.hdr, bb_tx.c2.mmioRdValid, bb_tx.c2.data} <= 0;
      end
   end


   /*
    * C0Rx Channel
    */
   logic [RX0_RSP_TOTAL_WIDTH-1:0] c0rx_dout;
   logic 			   c0rx_valid;   
   logic 			   c0rx_rdreq;
   logic 			   c0rx_rdempty;  
   
   c0rx_afifo c0rx_afifo
     (
      .data    ( {bb_rx.c0.hdr, bb_rx.c0.data, bb_rx.c0.rspValid, bb_rx.c0.mmioRdValid, bb_rx.c0.mmioWrValid} ),
      .wrreq   ( bb_rx.c0.rspValid | bb_rx.c0.mmioRdValid |  bb_rx.c0.mmioWrValid ),
      .rdreq   ( c0rx_rdreq ),
      .wrclk   ( bb_clk ),
      .rdclk   ( afu_clk ),
      .aclr    ( bb_softreset ),
      .q       ( c0rx_dout ),
      .rdusedw (),
      .wrusedw (),
      .rdfull  (),
      .rdempty ( c0rx_rdempty ),
      .wrfull  (),
      .wrempty ()
      );

   always @(posedge afu_clk) begin
      c0rx_valid <= c0rx_rdreq & ~c0rx_rdempty;      
   end

   always @(posedge afu_clk) begin
      c0rx_rdreq <= ~c0rx_rdempty;      
   end

   always @(posedge afu_clk) begin
      if (c0rx_valid) begin
	 {afu_rx.c0.hdr, afu_rx.c0.data, afu_rx.c0.rspValid, afu_rx.c0.mmioRdValid, afu_rx.c0.mmioWrValid} <= c0rx_dout;	 
      end
      else begin
	 {afu_rx.c0.hdr, afu_rx.c0.data, afu_rx.c0.rspValid, afu_rx.c0.mmioRdValid, afu_rx.c0.mmioWrValid} <= 0;	 
      end
   end
   
   
   /*
    * C1Rx Channel
    */
   logic [RX1_RSP_TOTAL_WIDTH-1:0] c1rx_dout;
   logic 			   c1rx_valid;   
   logic 			   c1rx_rdreq;
   logic 			   c1rx_rdempty;


   c1rx_afifo c1rx_afifo
     (
      .data    ( {bb_rx.c1.hdr, bb_rx.c1.rspValid} ),
      .wrreq   ( bb_rx.c1.rspValid ),
      .rdreq   ( c1rx_rdreq ),
      .wrclk   ( bb_clk ),
      .rdclk   ( afu_clk ),
      .aclr    ( bb_softreset ),
      .q       ( c1rx_dout ),
      .rdusedw (),
      .wrusedw (),
      .rdfull  (),
      .rdempty ( c1rx_rdempty ),
      .wrfull  (),
      .wrempty ()
      );


   always @(posedge afu_clk) begin
      c1rx_valid <= c1rx_rdreq & ~c1rx_rdempty;      
   end

   always @(posedge afu_clk) begin
      c1rx_rdreq <= ~c1rx_rdempty;      
   end
   
   always @(posedge afu_clk) begin
      if (c1rx_valid) begin
	 {afu_rx.c1.hdr, afu_rx.c1.rspValid} <= c1rx_dout;	 
      end
      else begin
	 {afu_rx.c1.hdr, afu_rx.c1.rspValid} <= 0;	 
      end
   end

   /*
    * Interface counts
    * - This block is enabled when DEBUG_ENABLE = 1, else disabled
    */ 
   generate
      if (DEBUG_ENABLE == 1) begin
	 // Counts
	  logic [31:0] afu_c0tx_cnt;
	 logic [31:0] afu_c1tx_cnt;
	  logic [31:0] afu_c2tx_cnt;
	 logic [31:0] afu_c0rx_cnt;
	 logic [31:0] afu_c1rx_cnt;	 	 
	 logic [31:0] bb_c0tx_cnt;
	 logic [31:0] bb_c1tx_cnt;
	 logic [31:0] bb_c2tx_cnt;
	 logic [31:0] bb_c0rx_cnt;
         logic [31:0] bb_c1rx_cnt;

	 // afu_if counts
	 always @(posedge afu_clk) begin
	    if (afu_softreset) begin
	       afu_c0tx_cnt <= 0;
	       afu_c1tx_cnt <= 0;
	       afu_c2tx_cnt <= 0;
	       afu_c0rx_cnt <= 0;
	       afu_c1rx_cnt <= 0;
	    end
	    else begin
	       if (afu_tx.c0.valid)       
		 afu_c0tx_cnt <= afu_c0tx_cnt + 1;
	       if (afu_tx.c1.valid)       
		 afu_c1tx_cnt <= afu_c1tx_cnt + 1;
	       if (afu_tx.c2.mmioRdValid) 
		 afu_c2tx_cnt <= afu_c2tx_cnt + 1;
	       if (afu_rx.c0.rspValid|afu_rx.c0.mmioRdValid|afu_rx.c0.mmioWrValid)
		 afu_c0rx_cnt <= afu_c0rx_cnt + 1;
	       if (afu_rx.c1.rspValid)
		 afu_c1rx_cnt <= afu_c1rx_cnt + 1;	       
	    end
	 end

	 // bb_if counts
	 always @(posedge bb_clk) begin
	    if (bb_softreset) begin
	       bb_c0tx_cnt <= 0;
	       bb_c1tx_cnt <= 0;
	       bb_c2tx_cnt <= 0;
	       bb_c0rx_cnt <= 0;
	       bb_c1rx_cnt <= 0;
	    end
	    else begin
	       if (bb_tx.c0.valid)       
		 bb_c0tx_cnt <= bb_c0tx_cnt + 1;
	       if (bb_tx.c1.valid)       
		 bb_c1tx_cnt <= bb_c1tx_cnt + 1;
	       if (bb_tx.c2.mmioRdValid) 
		 bb_c2tx_cnt <= bb_c2tx_cnt + 1;
	       if (bb_rx.c0.rspValid|bb_rx.c0.mmioRdValid|bb_rx.c0.mmioWrValid)
		 bb_c0rx_cnt <= bb_c0rx_cnt + 1;
	       if (bb_rx.c1.rspValid)
		 bb_c1rx_cnt <= bb_c1rx_cnt + 1;	       
	    end
	 end
	 
      end
   endgenerate
   

endmodule
