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


//-----------------------------------------------------------------------------
// File          : tx_csr.v
// Author        : Ajay Dubey
//-----------------------------------------------------------------------------
// Copyright 2011 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera
// turn off bogus verilog processor warnings
// altera message_off 10034 10035 10036 10037 10230

module alt_aeu_40_sfc_tx_csr 
       #(parameter CSRADDRSIZE = 8 
        ,parameter REVID = 32'h02062015
        ,parameter FCBITS = 2)
        (
         input wire clk     // clk_rx_recover          
        ,input wire clk_mm  // clk_status from crystal 
        ,input wire reset_n 
        ,input wire read 
        ,input wire write 
        ,input wire [CSRADDRSIZE-1:0]address 
        ,input wire [31:0]writedata 
        ,output reg readdatavalid 
        ,output reg [31:0]readdata 

        ,input wire [FCBITS-1:0] txon_frame  //no load
        ,input wire [FCBITS-1:0] txoff_frame //no load

        ,output wire                    cfg_enable_txoff
        ,output wire[FCBITS-1:0]        cfg_enable_txins
        ,output wire [16*FCBITS-1:0]    cfg_pause_quanta
        ,output wire [FCBITS-1:0]       cfg_qholdoff_en
        ,output wire [16*FCBITS-1:0]    cfg_qholdoff_quanta
        ,output wire [FCBITS-1:0]       cfg_paureq 
        );
 // ___________________________________________________________
 //     Synced signals
 //     - syncR: Signals synced with clk    (clk_rx_recover)
 //     - syncM: Signals synced with clk_mm (clk_status)   
 // ___________________________________________________________
   wire                  enable_txoff_syncR;    //output to cfg_*
   wire [FCBITS-1:0]     enable_txins_syncR;    //output to cfg_*
   wire [FCBITS-1:0]     paureq_syncR;          //output to cfg_*  
   wire [FCBITS-1:0]     qholdoff_en_syncR;     //output to cfg_*
   wire [16*FCBITS-1:0]  pause_quanta_syncR;    //output to cfg_*
   wire [16*FCBITS-1:0]  qholdoff_quanta_syncR; //output to cfg_*
   
 // ___________________________________________________________
 //     local parameters
 // ___________________________________________________________
        localparam 
                 ADDR_REVID          = 8'h00,
                 ADDR_SCRATCH        = 8'h01,
                 ADDR_NAME_0         = 8'h02,
                 ADDR_NAME_1         = 8'h03,
                 ADDR_NAME_2         = 8'h04,

                 ADDR_TXPAUSE_ENAXIN = 8'h05,
                 ADDR_TXPAUSE_PTXREQ = 8'h06,
                 ADDR_TXPAUSE_QHOENA = 8'h07,
                 ADDR_TXPAUSE_QHOQNT = 8'h08,
                 ADDR_TXPAUSE_PQUANT = 8'h09,
                 ADDR_TXPAUSE_ENAXOF = 8'h0a;
 // ____________________________________________________________
 //
  reg rddly, wrdly;
  wire wredge = write& ~wrdly;
  wire rdedge = read & ~rddly;

  always@(posedge clk_mm or negedge reset_n)
  begin
    if(~reset_n) 
       begin 
            wrdly <= 1'b0; 
            rddly <= 1'b0; 
            readdatavalid <= 1'b0;
       end 
    else 
       begin 
            wrdly <= write; 
            rddly <= read; 
            readdatavalid <= rdedge;
       end 
  end
  
   wire [12*8-1:0] ip_name = " 40gSFCTxCSR";
// ___________________________________________________________________________________________________
//  scratch register
// ___________________________________________________________________________________________________
   reg[31:0]  scratch = 32'd0;  
   always @ (posedge clk_mm) begin if (write & address == ADDR_SCRATCH) scratch <= writedata; end
// ___________________________________________________________________________________________________
//  enable pause insertion
// ___________________________________________________________________________________________________
   reg[FCBITS-1:0] enable_txins = {FCBITS{1'b1}};
   always @ (posedge clk_mm) begin if (write & address == ADDR_TXPAUSE_ENAXIN) enable_txins <= writedata; end

// ___________________________________________________________________________________________________
//  enable transmit off (ieee 802.3 pause frame)
// ___________________________________________________________________________________________________
   reg enable_txoff = 1'b0;
   always @ (posedge clk_mm) begin if (write & address == ADDR_TXPAUSE_ENAXOF) enable_txoff <= writedata; end
// ___________________________________________________________________________________________________
//  pause request 
// ___________________________________________________________________________________________________
   reg[FCBITS-1:0] paureq = {FCBITS{1'b0}};
   always @ (posedge clk_mm) begin if (write & address == ADDR_TXPAUSE_PTXREQ) paureq <= writedata; end

// ___________________________________________________________________________________________________
//  holdoff enable 
// ___________________________________________________________________________________________________
   reg[FCBITS-1:0] qholdoff_en = {FCBITS{1'b1}};
   always @ (posedge clk_mm) begin if (write & address == ADDR_TXPAUSE_QHOENA) qholdoff_en <= writedata; end

// ___________________________________________________________________________________________________
//  holdoff quanta 
// ___________________________________________________________________________________________________
   reg[16*FCBITS-1:0] qholdoff_quanta = {FCBITS{16'hffff}};
   always @ (posedge clk_mm) begin if (write & address == ADDR_TXPAUSE_QHOQNT) qholdoff_quanta[15:0] <= writedata; end

// ___________________________________________________________________________________________________
//  pause quanta 
// ___________________________________________________________________________________________________
   reg [16*FCBITS-1:0] pause_quanta = {FCBITS{16'hffff}};
   always @ (posedge clk_mm) begin if (write & address == ADDR_TXPAUSE_PQUANT) pause_quanta[15:0] <= writedata; end


// ___________________________________________________________________________________________________
//   syncR signals : synced with clk domain (clk_rx_recover)
// ___________________________________________________________________________________________________
   //wire                     enable_txoff_syncR;    //output to cfg_*
   //wire [FCBITS-1:0]        enable_txins_syncR;    //output to cfg_*
   //wire [FCBITS-1:0]        qholdoff_en_syncR;     //output to cfg_*
   //wire [FCBITS-1:0]        paureq_syncR;          //output to cfg_*  
   //wire [16*FCBITS-1:0]     pause_quanta_syncR;    //output to cfg_*
   //wire [16*FCBITS-1:0]     qholdoff_quanta_syncR; //output to cfg_*   
   

   sync_regs syncR (
    .clk (clk),
    .din ({enable_txoff,       enable_txins,       qholdoff_en,       paureq,       pause_quanta,       qholdoff_quanta      }),//from clk_mm
    .dout({enable_txoff_syncR, enable_txins_syncR, qholdoff_en_syncR, paureq_syncR, pause_quanta_syncR, qholdoff_quanta_syncR}) //to clk (clk_rx_recover)                 
   );
   
   defparam syncR .WIDTH = 1 + FCBITS*3 + 16*FCBITS*2 ;
   
// ___________________________________________________________________________________________________
//  output logic (synced with clk_rx_recover)
// ___________________________________________________________________________________________________
   assign cfg_enable_txins         = enable_txins_syncR;
   assign cfg_enable_txoff         = enable_txoff_syncR;
   assign cfg_paureq               = paureq_syncR;
   assign cfg_qholdoff_en          = qholdoff_en_syncR;
   assign cfg_qholdoff_quanta      = qholdoff_quanta_syncR;
   assign cfg_pause_quanta         = pause_quanta_syncR;    


// ___________________________________________________________________________________________________
//  readdata logic
// ___________________________________________________________________________________________________
   always @ (posedge clk_mm or negedge reset_n) 
      begin 
        if (~reset_n) readdata <= 32'hffff_eeee;
        else if (read)
            begin
                case(address)
                    ADDR_SCRATCH        : readdata <= scratch;
                    ADDR_REVID          : readdata <= REVID;
                    ADDR_NAME_0         : readdata <= ip_name[31:0];
                    ADDR_NAME_1         : readdata <= ip_name[63:32] ;
                    ADDR_NAME_2         : readdata <= ip_name[95:64];
                    ADDR_TXPAUSE_ENAXIN : readdata <= enable_txins;
                    ADDR_TXPAUSE_ENAXOF : readdata <= enable_txoff;
                    ADDR_TXPAUSE_PTXREQ : readdata <= paureq;
                    ADDR_TXPAUSE_QHOENA : readdata <= qholdoff_en;
                    ADDR_TXPAUSE_QHOQNT : readdata <= qholdoff_quanta[15:0];
                    ADDR_TXPAUSE_PQUANT : readdata <= {16'd0,pause_quanta[15:0]};
                    default             : readdata <= 32'hdeadc0de;
                endcase
            end
      end

 endmodule
