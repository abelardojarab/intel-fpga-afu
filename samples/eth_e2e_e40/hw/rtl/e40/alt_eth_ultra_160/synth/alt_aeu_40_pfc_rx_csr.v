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
module alt_aeu_40_pfc_rx_csr #(
        parameter ADDRSIZE = 8,
        parameter REVID = 32'h02062015,
        parameter NUMPRIORITY = 2
) (
        input clk,    // clk_rx_recover          
        input clk_mm, // clk_status from crystal 
        input reset_n,
        input read,
        input write,
        input [ADDRSIZE-1:0]address,
        input [31:0]writedata,
        output waitrequest,
        output  reg readdatavalid,
        output  reg [31:0]readdata,
        
        input [NUMPRIORITY-1:0] rxon_frame,
        input [NUMPRIORITY-1:0] rxoff_frame,
        
        output [NUMPRIORITY-1:0] cfg_enable,
        output                   cfg_fwd_pause_frame,
        output[47:0]             cfg_daddr
);


        // ___________________________________________________________
        //     Synced signals
        //     - syncR: Signals synced with clk    (clk_rx_recover)
        //     - syncM: Signals synced with clk_mm (clk_status)   
        // ___________________________________________________________
        
         wire [NUMPRIORITY-1:0]    enable_syncR     ; //output 
         wire                      fwd_pframes_syncR; //output
         wire [47:0]               dst_address_syncR; //output
         wire                      clr_count_syncR  ; //for counter  
         wire [32*NUMPRIORITY-1:0] count_rxof_syncM ;   
         wire [32*NUMPRIORITY-1:0] count_rxon_syncM ;    

        // ___________________________________________________________
        //     local parameters
        // ___________________________________________________________
               localparam
                       ADDR_REVID      = 8'h00,
                       ADDR_SCRATCH    = 8'h01,
                       ADDR_NAME_0     = 8'h02,
                       ADDR_NAME_1     = 8'h03,
                       ADDR_NAME_2     = 8'h04,
                       ADDR_ENA_RXPFC  = 8'h05,
                       ADDR_FWD_CTFRM  = 8'h06,
                       ADDR_DADDRL     = 8'h07,
                       ADDR_DADDRH     = 8'h08,
                       ADDR_CRXXON     = 8'h09,
                       ADDR_CRXXOF     = 8'h0a,
                       ADDR_CLR_RXCNT  = 8'h0b ;
          
        // ____________________________________________________________
        //
        reg rddly, wrdly;
        wire wredge = write & ~wrdly;
        wire rdedge = read  & ~rddly;
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
        reg[31:0]  scratch = 32'd0;
        always @ (posedge clk_mm) begin 
                if (write & address == ADDR_SCRATCH) 
                        scratch <= writedata; 
                end
        // ___________________________________________________________________________________________________
        //  queue enable
        // ___________________________________________________________________________________________________
        reg[NUMPRIORITY-1:0] enable = {NUMPRIORITY{1'b1}};
        always @ (posedge clk_mm) begin 
                if (write & address == ADDR_ENA_RXPFC) 
                        enable <= writedata[NUMPRIORITY-1:0]; 
        end

        // ___________________________________________________________________________________________________
        //  forward rx control frames rather drop in the receive
        // ___________________________________________________________________________________________________
        reg fwd_pframes = 1'b0;
        always @ (posedge clk_mm) begin 
                if (write & address == ADDR_FWD_CTFRM) 
                        fwd_pframes <= writedata[0]; 
        end

        // ___________________________________________________________________________________________________
        //  destination address
        // ___________________________________________________________________________________________________
        reg[47:0] dst_address = 48'h0180C2000001; // can be one unicast address
        always @ (posedge clk_mm) 
                if (write & address == ADDR_DADDRL) 
                        dst_address[31:0] <= writedata[31:0];
        always @ (posedge clk_mm) 
                if (write & address == ADDR_DADDRH) 
                        dst_address[47:32] <= writedata[15:0];
        // ___________________________________________________________________________________________________
        //  clear rx counters
        // ___________________________________________________________________________________________________
        reg clr_count = 1'b0;
        always @ (posedge clk_mm) begin
        if (write & address == ADDR_CLR_RXCNT) 
                clr_count <= writedata[0];
        else if (clr_count) 
                clr_count <= 1'b0;
        end

        // ___________________________________________________________________________________________________ 
        //  counter: in clk domain for faster calcuation (clk freq > clk_mm freq)
        // ___________________________________________________________________________________________________
        genvar i;
        wire [32*NUMPRIORITY-1:0] count_rxof;
        wire [32*NUMPRIORITY-1:0] count_rxon;
        
        generate
                for (i=0; i<NUMPRIORITY; i=i+1) begin: cntr
                        alt_aeu_40_pfc_rx_counter cntxof (.reset_n(reset_n), .clk(clk), .ena(rxoff_frame[i]), .clr(clr_count_syncR) ,.count(count_rxof[32*(i+1)-1:32*i]));
                        alt_aeu_40_pfc_rx_counter cntxon (.reset_n(reset_n), .clk(clk), .ena(rxon_frame[i] ), .clr(clr_count_syncR) ,.count(count_rxon[32*(i+1)-1:32*i]));
                end
        endgenerate

        // ___________________________________________________________________________________________________
        //   syncM signals : synced with clk_mm domain (clk_status)
        // ___________________________________________________________________________________________________
           
           //wire [32*NUMPRIORITY-1:0] count_rxof_syncM;  
           //wire [32*NUMPRIORITY-1:0] count_rxon_syncM;  
           sync_regs syncM (
                   .clk (clk_mm),
                   .din ({count_rxof,       count_rxon      }), //from clk (clk_rx_recover)
                   .dout({count_rxof_syncM, count_rxon_syncM})  //to clk_mm (clk_status)
           );
           
           defparam syncM .WIDTH = 32*NUMPRIORITY*2;
        
        // ___________________________________________________________________________________________________
        //   syncR signals : synced with clk domain (clk_rx_recover)
        // ___________________________________________________________________________________________________
           
         //wire                   clr_count_syncR  ;//sync input for counter  
         //wire                   fwd_pframes_syncR;//output
         //wire [47:0]            dst_address_syncR;//output
         //wire [NUMPRIORITY-1:0] enable_syncR     ;//output
           
           sync_regs syncR (
                   .clk (clk),
                   .din ({clr_count,       fwd_pframes,       dst_address,       enable    }),   //from clk_mm domain
                   .dout({clr_count_syncR, fwd_pframes_syncR, dst_address_syncR, enable_syncR})  //to clk domain (clk_rx_recover)
           );
           
           defparam syncR .WIDTH = 1 + 1 + 48 + NUMPRIORITY;
   
       // ___________________________________________________________________________________________________
       //  output logic (synced with clk_rx_recover)
       // ___________________________________________________________________________________________________
         assign cfg_enable             = enable_syncR; 
         assign cfg_fwd_pause_frame    = fwd_pframes_syncR;
         assign cfg_daddr              = dst_address_syncR; 

        // ___________________________________________________________________________________________________
        //  readdata logic
        // ___________________________________________________________________________________________________
        wire [12*8-1:0] ip_name = "40gPFCRxCSR";
        always @ (posedge clk_mm or negedge reset_n) begin
                if (~reset_n) readdata <= 32'hffff_eeee;
                else if (read) begin
                        case(address)
                                ADDR_SCRATCH    : readdata <= scratch;
                                ADDR_REVID      : readdata <= REVID;
                                ADDR_NAME_0     : readdata <= ip_name[31:0];
                                ADDR_NAME_1     : readdata <= ip_name[63:32];
                                ADDR_NAME_2     : readdata <= ip_name[95:64];
                                ADDR_ENA_RXPFC  : readdata <= {{(32-NUMPRIORITY){1'b0}},enable};
                                ADDR_FWD_CTFRM  : readdata <= {31'd0,fwd_pframes};
                                ADDR_DADDRL     : readdata <= dst_address[31:0];
                                ADDR_DADDRH     : readdata <= {16'd0,dst_address[47:32]};
                                ADDR_CRXXON     : readdata <= count_rxon_syncM;
                                ADDR_CRXXOF     : readdata <= count_rxof_syncM;
                                ADDR_CLR_RXCNT  : readdata <= {31'd0, clr_count};
                                default         : readdata <= 32'hdeadc0de;
                        endcase
                end
        end
        
endmodule
        
        module counter (input wire reset_n, input wire clk, input wire ena, input wire clr, output reg[31:0] count);
        always @ (posedge clk or negedge reset_n)
        begin
        if (~reset_n) count <= 32'd0; else if (clr) count <= 32'd0;
        else if (ena) count <= count+1;
        end
endmodule
