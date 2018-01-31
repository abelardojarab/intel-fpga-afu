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

// turn off bogus verilog processor warnings
// altera message_off 10034 10035 10036 10037 10230

`timescale 1 ps / 1 ps
module alt_aeu_40_pfc_tx_csr #(
        parameter CSRADDRSIZE = 8,
        parameter REVID = 32'h02062015,
        parameter NUMPRIORITY = 2
) (
        input clk,      // clk_rx_recover
        input clk_mm,   // clk_status from crystal
        input reset_n,
        input read,
        input write,
        input [CSRADDRSIZE-1:0] address,
        input [31:0] writedata,
        output waitrequest,
        output reg readdatavalid,
        output reg [31:0] readdata,

        input [NUMPRIORITY-1:0] txon_frame,  //no load
        input [NUMPRIORITY-1:0] txoff_frame, //no load

        output [NUMPRIORITY-1:0]         cfg_enaqxin,
        output                          cfg_lholdoff_en,
        output [NUMPRIORITY-1:0]        cfg_qholdoff_en,
        output [16*NUMPRIORITY-1:0]     cfg_pause_quanta,
        output [16-1:0]                 cfg_lholdoff_quanta,
        output [16*NUMPRIORITY-1:0]     cfg_qholdoff_quanta,

        output [47:0]                   cfg_saddr,
        output [47:0]                   cfg_daddr,
        output [NUMPRIORITY-1:0]        cfg_pause_req
);

 // ___________________________________________________________
 //     Synced signals
 //     - syncR: Signals synced with clk    (clk_rx_recover)
 //     - syncM: Signals synced with clk_mm (clk_status)   
 // ___________________________________________________________
   wire [NUMPRIORITY-1:0]    enable_syncR;            //output to cfg_*
   wire [NUMPRIORITY-1:0]    paureq_syncR;            //output to cfg_*
   wire [NUMPRIORITY-1:0]    qholdoff_en_syncR;       //output to cfg_*
   wire                      lholdoff_en_syncR;       //output to cfg_*
   wire [16-1:0]             lholdoff_quanta_syncR;   //output to cfg_*
   wire [47:0]               dst_address_syncR;       //output to cfg_*
   wire [47:0]               src_address_syncR;       //output to cfg_*
   wire [16*NUMPRIORITY-1:0] pause_quanta_syncR;      //output to cfg_*
   wire [16*NUMPRIORITY-1:0] qholdoff_quanta_syncR;   //output to cfg_*

 // ___________________________________________________________
 //     local parameters
 // ___________________________________________________________
        localparam
                  ADDR_REVID    = 8'h00,
                  ADDR_SCRATCH  = 8'h01,
                  ADDR_NAME_0   = 8'h02,
                  ADDR_NAME_1   = 8'h03,
                  ADDR_NAME_2   = 8'h04,

                  ADDR_ENAQXI   = 8'h05, // enable xoff/xon transmit/queue
                  ADDR_PAUREQ   = 8'h06,
                  ADDR_QHOENA   = 8'h07,
                  ADDR_QHOQNT   = 8'h08,
                  ADDR_PAUQNT   = 8'h09,
                  ADDR_PQUNUM   = 8'h0a, // ADDR_TXPAUSE_ENAXOF for 802.3 pause
                  ADDR_LHOENA   = 8'h0b,
                  ADDR_LHOQNT   = 8'h0c,
                  ADDR_DSTADRL  = 8'h0d,
                  ADDR_DSTADRH  = 8'h0e,
                  ADDR_SRCADRL  = 8'h0f,
                  ADDR_SRCADRH  = 8'h10,
                  ADDR_TYPLEN   = 8'h11,
                  ADDR_OPCODE   = 8'h12;
 // ____________________________________________________________
 //
  reg rddly, wrdly;
  wire wredge = write& ~wrdly;
  wire rdedge = read & ~rddly;
  assign waitrequest = (wredge|rdedge); // your design is done with transaction when this goes down

  always@(posedge clk_mm or negedge reset_n) begin
    if(~reset_n) begin
       wrdly <= 1'b0;
       rddly <= 1'b0;
       readdatavalid <= 1'b0;
    end else begin
       wrdly <= write;
       rddly <= read;
       readdatavalid <= rdedge;
    end
  end

// ___________________________________________________________________________________________________  
//  scratch register
// ___________________________________________________________________________________________________   
   reg [31:0]  scratch = 32'd0;
   always @ (posedge clk_mm) begin
      if (write & address == ADDR_SCRATCH) scratch <= writedata; 
   end

// ___________________________________________________________________________________________________   
//  queue enable
// ___________________________________________________________________________________________________   
   reg [NUMPRIORITY-1:0] enable = {NUMPRIORITY{1'b1}};
   always @ (posedge clk_mm) begin
      if (write & address == ADDR_ENAQXI) enable <= writedata;
   end

// ___________________________________________________________________________________________________   
//  pause request
// ___________________________________________________________________________________________________
   reg [NUMPRIORITY-1:0] paureq = {NUMPRIORITY{1'b0}};
   always @ (posedge clk_mm) begin
      if (write & address == ADDR_PAUREQ) paureq <= writedata;
   end

// ___________________________________________________________________________________________________
//  queue holdoff enable
// ___________________________________________________________________________________________________   
   reg [NUMPRIORITY-1:0] qholdoff_en = {NUMPRIORITY{1'b1}};
   always @ (posedge clk_mm) begin
      if (write & address == ADDR_QHOENA) qholdoff_en <= writedata;
   end

// ___________________________________________________________________________________________________   
//  link holdoff enable
// ___________________________________________________________________________________________________   
   reg lholdoff_en = 1'b0;
   always @ (posedge clk_mm) begin
      if (write & address == ADDR_LHOENA) lholdoff_en <= writedata;
   end

// ___________________________________________________________________________________________________
//  link holdoff quanta
// ___________________________________________________________________________________________________
   reg [15:0] lholdoff_quanta = 16'h0fff;
   always @ (posedge clk_mm) begin
      if (write & address == ADDR_LHOQNT) lholdoff_quanta <= writedata;
   end
       
// ___________________________________________________________________________________________________   
//  destination address
// ___________________________________________________________________________________________________
   reg [47:0] dst_address = 48'h0180C2000001; // can be one unicast address
   always @ (posedge clk_mm)
      if (write & address == ADDR_DSTADRL) dst_address[31:0] <= writedata[31:0];
   always @ (posedge clk_mm)
      if (write & address == ADDR_DSTADRH) dst_address[47:32] <= writedata[15:0];

// ___________________________________________________________________________________________________
//  source address
// ___________________________________________________________________________________________________
   reg [47:0] src_address = 48'he100_cbfc_5add;
   always @ (posedge clk_mm)
      if (write & address == ADDR_SRCADRL) src_address[31:0] <= writedata[31:0];
   always @ (posedge clk_mm)
      if (write & address == ADDR_SRCADRH) src_address[47:32] <= writedata[15:0];

// ___________________________________________________________________________________________________
//  queue number
// ___________________________________________________________________________________________________   
   reg [2:0] pqnum = 3'h0;
   always @ (posedge clk_mm) begin
      if (write & address == ADDR_PQUNUM) pqnum <= writedata[2:0];
   end

// ___________________________________________________________________________________________________   
//  queue pause quanta
// ___________________________________________________________________________________________________   
   reg [16*NUMPRIORITY-1:0] pause_quanta = {NUMPRIORITY{16'hffff}};
   genvar i;

   generate for(i = 0; i < NUMPRIORITY; i = i + 1) begin: quanta_lp
   always @ (posedge clk_mm) begin
           if (write && (address == ADDR_PAUQNT) && (i == pqnum)) pause_quanta[16*i + 15:16*i] <= writedata;
      end
   end
   endgenerate

// ___________________________________________________________________________________________________
//  queue holdoff quanta
// ___________________________________________________________________________________________________   
   reg [16*NUMPRIORITY-1:0]  qholdoff_quanta = {NUMPRIORITY{16'hffff}};

   generate for(i = 0; i < NUMPRIORITY; i = i + 1) begin: holdoff_lp
   always @ (posedge clk_mm) begin
           if (write && (address == ADDR_QHOQNT) && (i == pqnum)) qholdoff_quanta[16*i + 15:16*i] <= writedata;
      end
   end
   endgenerate
   
// ___________________________________________________________________________________________________
//   syncR signals : synced with clk domain (clk_rx_recover)
// ___________________________________________________________________________________________________
   
   //wire [NUMPRIORITY-1:0]    enable_syncR;            //output to cfg_*
   //wire [NUMPRIORITY-1:0]    paureq_syncR;            //output to cfg_*
   //wire [NUMPRIORITY-1:0]    qholdoff_en_syncR;       //output to cfg_*
   //wire                      lholdoff_en_syncR;       //output to cfg_*
   //wire [16-1:0]             lholdoff_quanta_syncR;   //output to cfg_*
   //wire [47:0]               dst_address_syncR;       //output to cfg_*
   //wire [47:0]               src_address_syncR;       //output to cfg_*
   //wire [16*NUMPRIORITY-1:0] pause_quanta_syncR;      //output to cfg_*
   //wire [16*NUMPRIORITY-1:0] qholdoff_quanta_syncR;   //output to cfg_*

   sync_regs syncR (
    .clk(clk),
    .din ({enable,       paureq,       qholdoff_en,       lholdoff_en,       lholdoff_quanta,       dst_address,       src_address,       pause_quanta,       qholdoff_quanta      }),//from clk_mm
    .dout({enable_syncR, paureq_syncR, qholdoff_en_syncR, lholdoff_en_syncR, lholdoff_quanta_syncR, dst_address_syncR, src_address_syncR, pause_quanta_syncR, qholdoff_quanta_syncR}) //to clk (clk_rx_recover)
   );
   
   defparam syncR .WIDTH = NUMPRIORITY*3 + 1 + 16 + 48*2 + 16*NUMPRIORITY*2;
   
// ___________________________________________________________________________________________________
//  output logic (synced with clk_rx_recover)
// ___________________________________________________________________________________________________
   assign cfg_enaqxin           = enable_syncR;
   assign cfg_pause_req         = paureq_syncR;
   assign cfg_qholdoff_en       = qholdoff_en_syncR;
   assign cfg_lholdoff_en       = lholdoff_en_syncR;
   assign cfg_lholdoff_quanta   = lholdoff_quanta_syncR;
   assign cfg_daddr             = dst_address_syncR;
   assign cfg_saddr             = src_address_syncR;
   assign cfg_pause_quanta      = pause_quanta_syncR[16*NUMPRIORITY-1:0];
   assign cfg_qholdoff_quanta   = qholdoff_quanta_syncR[16*NUMPRIORITY-1:0];

   reg [15:0] mux_pause_quanta;
   integer j;
   always @(posedge clk_mm) begin
      mux_pause_quanta <= pause_quanta[15:0];
      for (j = 0; j < NUMPRIORITY; j = j + 1) begin
         if (j == pqnum) mux_pause_quanta <= pause_quanta[16*j +: 16]; // Must use array slice indexing
      end
   end

   reg [15:0] mux_qholdoff_quanta;
   always @(posedge clk_mm) begin
      mux_qholdoff_quanta <= pause_quanta[15:0];
      for (j = 0; j < NUMPRIORITY; j = j + 1) begin
         if (j == pqnum) mux_qholdoff_quanta <= qholdoff_quanta[16*j +: 16]; // Must use array slice indexing
      end
   end

// ___________________________________________________________________________________________________   
//  readdata logic
// ___________________________________________________________________________________________________   
   wire [12*8-1:0] ip_name = "40gPFCTxCSR";
   always @ (posedge clk_mm or negedge reset_n) begin
      if (~reset_n) readdata <= 32'hffff_eeee;
      else if (read) begin
         case(address)
            ADDR_SCRATCH: readdata <= scratch;
            ADDR_REVID  : readdata <= REVID;
            ADDR_NAME_0 : readdata <= ip_name[31:0];
            ADDR_NAME_1 : readdata <= ip_name[63:32];
            ADDR_NAME_2 : readdata <= ip_name[95:64];
            ADDR_ENAQXI : readdata <= enable;
            ADDR_DSTADRL: readdata <= dst_address[31:0];
            ADDR_DSTADRH: readdata <= {16'd0,dst_address[47:32]};
            ADDR_SRCADRL: readdata <= src_address[31:0];
            ADDR_SRCADRH: readdata <= {16'd0,src_address[47:32]};
            ADDR_PAUREQ : readdata <= paureq;
            ADDR_LHOENA : readdata <= lholdoff_en;
            ADDR_LHOQNT : readdata <= lholdoff_quanta;
            ADDR_QHOENA : readdata <= qholdoff_en;
            ADDR_PQUNUM : readdata <= pqnum;
            ADDR_QHOQNT : readdata <= {16'd0,mux_qholdoff_quanta};
            ADDR_PAUQNT : readdata <= {16'd0,mux_pause_quanta};
            default: readdata <= 32'hdeadc0de;
         endcase
      end
   end

endmodule
