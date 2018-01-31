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
// File          : alt_aeu-100_sfc_rx_csr.v
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

module alt_aeu_40_sfc_rx_csr 
       #(parameter ADDRSIZE = 8 
        ,parameter REVID = 32'h02062015
        ,parameter FCBITS = 2)
        (
         input wire clk       // clk_rx_recover          
        ,input wire clk_mm    // clk_status from crystal 
        ,input wire reset_n 
        ,input wire read 
        ,input wire write 
        ,input wire [ADDRSIZE-1:0]address 
        ,input wire [31:0]writedata 
        ,output wire waitrequest 
        ,output reg readdatavalid 
        ,output reg [31:0]readdata 

        ,input wire [FCBITS-1:0] rxon_frame  //no load
        ,input wire [FCBITS-1:0] rxoff_frame //no load

        ,output wire [FCBITS-1:0]       cfg_enable
        ,output wire                    cfg_fwd_pause_frame
        ,output wire[47:0]              cfg_daddr
        );

 // ___________________________________________________________
 //     Synced signals
 //     - syncR: Signals synced with clk    (clk_rx_recover)
 //     - syncM: Signals synced with clk_mm (clk_status)   
 // ___________________________________________________________

  wire [FCBITS-1:0]         enable_syncR     ; //output 
  wire                      fwd_pframes_syncR; //output
  wire [47:0]               dst_address_syncR; //output
   
 // ___________________________________________________________
 //     local parameters
 // ___________________________________________________________
        localparam 
                  ADDR_REVID     = 8'h00,
                  ADDR_SCRATCH   = 8'h01,
                  ADDR_NAME_0    = 8'h02,
                  ADDR_NAME_1    = 8'h03,
                  ADDR_NAME_2    = 8'h04,
                  ADDR_ENA_RXPFC = 8'h05,
                  ADDR_FWD_CTFRM = 8'h06,
                  ADDR_DADDRL    = 8'h07,
                  ADDR_DADDRH    = 8'h08;
 // ____________________________________________________________
 //
  reg rddly, wrdly;
  wire wredge = write& ~wrdly;
  wire rdedge = read & ~rddly;
  assign waitrequest = (wredge|rdedge); // your design is done with transaction when this goes down

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
  
// ___________________________________________________________________________________________________
//  queue enable 
// ___________________________________________________________________________________________________
   reg[FCBITS-1:0] enable = {FCBITS{1'b1}};
   always @ (posedge clk_mm) begin if (write & address == ADDR_ENA_RXPFC) enable <= writedata; end

   wire [12*8-1:0] ip_name = " 40gSFCRxCSR";

// ___________________________________________________________________________________________________
//  scratch register
// ___________________________________________________________________________________________________
   reg[31:0]  scratch = 32'd0;  
   always @ (posedge clk_mm) begin if (write & address == ADDR_SCRATCH) scratch <= writedata; end
// ___________________________________________________________________________________________________
//  forward rx control frames rather drop in the receive 
// ___________________________________________________________________________________________________
   reg fwd_pframes = 1'b0;
   always @ (posedge clk_mm) begin if (write & address == ADDR_FWD_CTFRM) fwd_pframes <= writedata; end

// ___________________________________________________________________________________________________
//  destination address
// ___________________________________________________________________________________________________
   reg[47:0] dst_address = 48'h0180C2000001; // can be one unicast address
   always @ (posedge clk_mm) if (write & address == ADDR_DADDRL) dst_address[31:0] <= writedata; 
   always @ (posedge clk_mm) if (write & address == ADDR_DADDRH) dst_address[47:32] <= writedata[15:0]; 

// ___________________________________________________________________________________________________
//   syncR signals : synced with clk domain (clk_rx_recover)
// ___________________________________________________________________________________________________
  //wire [FCBITS-1:0]         enable_syncR     ;
  //wire                      fwd_pframes_syncR;
  //wire [47:0]               dst_address_syncR;
   
   sync_regs syncR (
           .clk (clk),
           .din ({enable,       fwd_pframes,       dst_address      }),  //from clk_mm domain
           .dout({enable_syncR, fwd_pframes_syncR, dst_address_syncR})   //to clk domain (clk_rx_recover)
   );
   
   defparam syncR .WIDTH = FCBITS + 1 + 48;
   
// ___________________________________________________________________________________________________
//  output logic (synced with clk_rx_recover)
// ___________________________________________________________________________________________________
  assign cfg_enable             = enable_syncR; 
  assign cfg_fwd_pause_frame    = fwd_pframes_syncR;
  assign cfg_daddr              = dst_address_syncR; 
   
// ___________________________________________________________________________________________________
//  readdata logic
// ___________________________________________________________________________________________________
   always @ (posedge clk_mm or negedge reset_n) 
      begin 
        if (~reset_n) readdata <= 32'hffff_eeee;
        else if (read)
            begin
                case(address)
                    ADDR_SCRATCH   : readdata <= scratch;
                    ADDR_REVID     : readdata <= REVID;
                    ADDR_NAME_0    : readdata <= ip_name[31:0];
                    ADDR_NAME_1    : readdata <= ip_name[63:32] ;
                    ADDR_NAME_2    : readdata <= ip_name[95:64];
                    ADDR_ENA_RXPFC : readdata <= enable;
                    ADDR_FWD_CTFRM : readdata <= fwd_pframes;
                    ADDR_DADDRL    : readdata <= dst_address[31:0];
                    ADDR_DADDRH    : readdata <= {16'd0,dst_address[47:32]};
                    default        : readdata <= 32'hdeadc0de;
                endcase
            end
      end

 endmodule

