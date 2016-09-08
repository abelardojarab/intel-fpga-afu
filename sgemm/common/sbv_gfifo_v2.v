// ***************************************************************************
//                               INTEL CONFIDENTIAL
//
//        Copyright (C) 2008-2011 Intel Corporation All Rights Reserved.
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
// Engineer:            Pratik Marolia
// Create Date:         Fri Jul 29 14:45:20 PDT 2011
// Module Name:         sbv_gfifo_v2.v
// Project:             NLB AFU 
// Description:
//
// ***************************************************************************

//-----------------------------------------------------------------
//  (C) Copyright Intel Corporation, 2008.  All Rights Reserved.
//-----------------------------------------------------------------
//
//  
//---------------------------------------------------------------------------------------------------------------------------------------------------
//                                        sbv_gfifo_v2 with Read Store & Read-Write forwarding
//---------------------------------------------------------------------------------------------------------------------------------------------------
// 22-4-2010 : Renamed cci_hdr_fifo into sb_gfifo
// 26-4-2011 : Derived sbv_gfifo from sb_gfifo.
//	       The read engine in the fifo presents valid data on output ports. When data out is used, rdack should be asserted.
//	       This is different from a traditional fifo where the fifo pops out a new data in response to a rden in the previous Clk.
//	       Instead this fifo presents the valid data on output port & expects a rdack in the same Clk when data is consumed.
// 27-6-2012 : Redesigned the sbv_gfifo to have registered outputs. The design consists of BRAM based fifo with 2 register stages in front
//             of it. The second register stage is required to hide the BRAM write to read latency of 1. 
// 10-10-2014: Edited the fifo with output register stage. Validated in JKT environment. Stratix 5 max frequency = 579MHz
// Write  to Read latency = 1
//
//
// Full thresh          - value should be less than/ euqual to 2**DEPTH_BASE2. If # entries more than threshold than fifo_almFull is set
//
//

`include "vendor_defines.vh"
module sbv_gfifo_v2    #(parameter DATA_WIDTH      =51,
                      DEPTH_BASE2     =3, 
                      FULL_THRESH     =0,          // fifo_almFull will be asserted if there are more entries than FULL_THRESH
                      GRAM_STYLE       =`GRAM_AUTO) // GRAM_AUTO, GRAM_BLCK, GRAM_DIST
                (
                Resetb,            //Active low reset
                Clk,               //global clock
                fifo_din,          //Data input to the FIFO tail
                fifo_wen,          //Write to the tail
                fifo_rdack,        //Read ack, pop the next entry
                                   //--------------------- Output  ------------------
                fifo_dout,         //FIFO read data out     
                fifo_dout_v,       //FIFO data out is valid 
                fifo_empty,        //FIFO is empty
                fifo_full,         //FIFO is full
                fifo_count,        //Number of entries in the FIFO
                fifo_almFull       //fifo_count > FULL_THRESH
                ); 

input                    Resetb;           // Active low reset
input                    Clk;              // global clock    
input  [DATA_WIDTH-1:0]  fifo_din;         // FIFO write data in
input                    fifo_wen;         // FIFO write enable
input                    fifo_rdack;       // Read ack, pop the next entry

output [DATA_WIDTH-1:0]  fifo_dout;        // FIFO read data out
output                   fifo_dout_v;      // FIFO data out is valid 
output                   fifo_empty;       // set when FIFO is empty
output                   fifo_full;        // set if Fifo full
output [DEPTH_BASE2-1:0] fifo_count;       // Number of entries in the fifo
output                   fifo_almFull;
//------------------------------------------------------------------------------------
(* `NO_RETIMING *) reg     [DATA_WIDTH-1:0] dram [1:0];
(* `NO_RETIMING *) reg    [1:0]            dram_v /* synthesis maxfan=256 */;
reg                     bram_rdout_v;
reg     bram_wen, bram_ren, bram_full, bram_empty;
reg     [DATA_WIDTH-1:0]        bram_wdin;
wire    [DATA_WIDTH-1:0]        bram_rdout;
reg     [DEPTH_BASE2-1:0]       bram_waddr, bram_raddr, bram_raddr_next;
reg     [DEPTH_BASE2-1:0]       bram_raddr_d;
(* `NO_RETIMING *) reg     [DEPTH_BASE2:0]         bram_count;


wire                    fifo_dout_v     = dram_v[1];
wire [DATA_WIDTH-1:0]   fifo_dout       = dram[1];
wire                    fifo_full       = bram_count[DEPTH_BASE2];
reg                     fifo_almFull;
wire [DEPTH_BASE2-1:0]  fifo_count      = bram_count[DEPTH_BASE2-1:0];
reg                     fifo_empty;

// Data out shift register
// Shifts in data from either fifo_din or gram_rdata
always @(posedge Clk)
begin

        // dram_v[1] state machine
        // fifo_rdack implies dram_v[1]==1
(* parallel_case *) casez({dram_v[1], dram_v[0], bram_rdout_v, fifo_rdack})
            4'b0???:     dram[1]    <= fifo_din;
            4'b1001:     dram[1]    <= fifo_din;
            4'b11?1:     dram[1]    <= dram[0];
            4'b1011:     dram[1]    <= bram_rdout;
        endcase

        case(dram_v[1])
            1'b0:begin
                if(fifo_wen)
                    dram_v[1] <= 1'b1;
            end
            1'b1:begin
                if(fifo_rdack && ~dram_v[0] && ~bram_rdout_v && ~fifo_wen)
                    dram_v[1]   <= 1'b0;
            end
        endcase

        // dram_v[0] state machine
        
        if(fifo_wen)
            dram[0]     <= fifo_din;

        if(bram_raddr_d==bram_waddr && fifo_wen )
            dram_v[0]    <= 1'b1;
        else
            dram_v[0]   <= 1'b0;

        if(!Resetb)
        begin
                dram_v <= 0;
        end
end

always @(*)
begin
        bram_wen  = fifo_wen;
        bram_ren  = fifo_rdack;
        bram_wdin = fifo_din;
        bram_full = bram_count[DEPTH_BASE2];
        fifo_empty = bram_empty;
        bram_raddr_d = bram_ren ? bram_raddr_next
                                : bram_raddr;
end

always @(posedge Clk)
begin
        if(bram_wen & ~bram_full)
                bram_waddr <= bram_waddr + 1'b1;
        if(bram_ren & ~bram_empty)
        begin
                bram_raddr <= bram_raddr + 1'b1;
                bram_raddr_next <= bram_raddr+2'h2;
        end

        bram_count      <= bram_count + (~bram_full & bram_wen) - (~bram_empty & bram_ren);
        
        case(bram_empty)
                1'b0: if(bram_count==1'b1 && ~bram_wen && bram_ren)
                        bram_empty      <= 1'b1;
                1'b1: if(bram_wen)
                        bram_empty      <= 1'b0;
        endcase
        
        case(bram_rdout_v)
            1'b0:
                if(bram_count==1'b1 && bram_wen && ~bram_ren)
                    bram_rdout_v    <= 1'b1;
            1'b1:
                if(bram_count==2'h2 && ~bram_wen && bram_ren)
                    bram_rdout_v    <= 1'b0;
        endcase
       
//        fifo_count  <= fifo_count + (~fifo_full & fifo_wen) - (~fifo_empty & fifo_rdack);
      
//        case(fifo_empty)
//                1'b0: fifo_empty  <= bram_empty & ~dram_v[0] & fifo_rdack & ~fifo_wen;
//                1'b1: fifo_empty  <= ~fifo_wen;
//        endcase
      
        if(!Resetb)
        begin
                bram_waddr      <= 0;
                bram_raddr      <= 1'b1;
                bram_raddr_next <= 2'h2;
                bram_count      <= 0;
                bram_empty      <= 1'b1;
                bram_rdout_v    <= 0;
//                fifo_count      <= 0;
//                fifo_empty      <= 1;
        end
end

// generate programmable full only when required
generate if (FULL_THRESH>0)
begin : GEN_ENABLE_fifo_almFull
        always @(posedge Clk)
        begin
                if (!Resetb)
                        fifo_almFull <= 0;
                        else 
                        begin
                                casex ({(fifo_rdack && ~fifo_empty), (fifo_wen && ~fifo_full)})
                                2'b10:        fifo_almFull       <= (bram_count-1'b1) >= FULL_THRESH;
                                2'b01:        fifo_almFull       <= (bram_count+1'b1) >= FULL_THRESH;
                                default:      fifo_almFull       <= fifo_almFull;
                                endcase
                        end
        end
end
endgenerate

//------------------------------------------------------------------------------------
// instantiate gram with mode 1

gram_sdp #(.BUS_SIZE_ADDR(DEPTH_BASE2), 
          .BUS_SIZE_DATA (DATA_WIDTH),
          .GRAM_MODE     (1), 
          .GRAM_STYLE     (GRAM_STYLE)) 
inst_gram_sdp (
          .clk  (Clk),
          .we   (bram_wen),
          .waddr(bram_waddr),
          .din  (bram_wdin),
          .raddr(bram_raddr_d),
          .dout (bram_rdout)
        );

//---------------------------------------------------------------------------------------------------------------------
//              Error Logic
//---------------------------------------------------------------------------------------------------------------------
reg fifo_overflow, fifo_underflow;
always @(posedge Clk)
begin
        if(fifo_empty & ~fifo_wen & fifo_rdack)
        begin
            fifo_underflow <= 1'b1;
            //synthesis translate_off
            $display("%m ERROR: fifo fifo_underflow detected");
            //synthesis translate_on
        end
                
        if(fifo_full & fifo_wen & ~fifo_rdack)
        begin
            fifo_overflow <= 1'b1;
            //synthesis translate_off
            $display("%m ERROR: fifo fifo_overflow detected");
            //synthesis translate_on
        end
        if(!Resetb)
        begin
            fifo_underflow <= 0;
            fifo_overflow <= 0;
        end

end
endmodule 


