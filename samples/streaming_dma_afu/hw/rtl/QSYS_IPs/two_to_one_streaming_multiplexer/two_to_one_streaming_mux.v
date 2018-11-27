// ***************************************************************************
// Copyright (c) 2018, Intel Corporation
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// * Neither the name of Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// ***************************************************************************



/*

This module is a two-to-one mux with a software programmable select bit.  When
the select bit is set to 0, then the "A" sink is wired up to the source.  When
the select bit is set to 1, then the "B" sink is wired up to the source.  Before
changing the select bit the streaming paths should be quiescent to avoid
interleaving two streams together.  Since this is a 2:1 mux there is no pipelining,
if a pipeline stage is needed on the streaming source a streaming pipeline stage
can be added from the Qsys component library.

The software accessible CSR slave port has only one 64-bit address.  The select
bit is located at bit offset 0 of this location and supports read/write operations.

------------------
Author:  JCJB
Date:    10/31/2018
Version: 1.0
------------------

Version 1.0 - Initial version of the module

*/

module two_to_one_streaming_mux (
  clk,
  reset,
  
  csr_writedata,
  csr_write,
  csr_byteenable,
  csr_readdata,
  csr_read,
  
  snk_A_data,
  snk_A_sop,
  snk_A_eop,
  snk_A_empty,
  snk_A_valid,
  snk_A_ready,
  
  snk_B_data,
  snk_B_sop,
  snk_B_eop,
  snk_B_empty,
  snk_B_valid,
  snk_B_ready,
  
  src_data,
  src_sop,
  src_eop,
  src_empty,
  src_valid,
  src_ready  
);

  parameter DATA_WIDTH = 512;  // 16, 32, 64, 128, 256, 512, 1024 are valid settings
  parameter EMPTY_WIDTH = 6;   // log2(DATA_WIDTH/8), this will get calculated in hw.tcl

  input clk;
  input reset;

  // only storing a single select bit so no need for addressing
  input [63:0]       csr_writedata;  // only going to use bit offset 0 as a select bit for the mux
  input              csr_write;
  input [7:0]        csr_byteenable;
  output wire [63:0] csr_readdata;   // only bit offset 0 will be driven non-zero
  input              csr_read;       // not going to use this, including because you cannot have readdata without a read signal
   
  input [DATA_WIDTH-1:0]  snk_A_data;
  input                   snk_A_sop;
  input                   snk_A_eop;
  input [EMPTY_WIDTH-1:0] snk_A_empty;
  input                   snk_A_valid;
  output wire             snk_A_ready;

  // this block will switch to sink B if it issues SOP and will remain on that input until EOP arrives
  input [DATA_WIDTH-1:0]  snk_B_data;
  input                   snk_B_sop;
  input                   snk_B_eop;
  input [EMPTY_WIDTH-1:0] snk_B_empty;
  input                   snk_B_valid;
  output wire             snk_B_ready;
   
  output wire [DATA_WIDTH-1:0]  src_data;
  output wire                   src_sop;
  output wire                   src_eop;
  output wire [EMPTY_WIDTH-1:0] src_empty;
  output wire                   src_valid;
  input                         src_ready;

  reg select;  // when 0 sink A is selected, and when 1 sink B is selected


  always @ (posedge clk)
  begin
    if (reset)
    begin
      select <= 1'b0;  // coming out of reset sink A will be selected
    end
    else if ((csr_write == 1'b1) & (csr_byteenable[0] == 1'b1))  // lowest byte lane being written
    begin
      select <= csr_writedata[0];
    end
  end

  assign csr_readdata = {63'h00000000, select};

  // sink A and B to source wiring
  assign src_data = (select == 1'b0)? snk_A_data : snk_B_data;
  assign src_sop = (select == 1'b0)? snk_A_sop : snk_B_sop;
  assign src_eop = (select == 1'b0)? snk_A_eop : snk_B_eop;
  assign src_empty = (select == 1'b0)? snk_A_empty : snk_B_empty;
  assign src_valid = (select == 1'b0)? snk_A_valid : snk_B_valid;

  // source to sink A and B wiring
  assign snk_A_ready = (select == 1'b0) & src_ready;  // if we are selecting the A input then wire the source ready signal to A's ready signal, otherwise hold A's ready low
  assign snk_B_ready = (select == 1'b1) & src_ready;  // if we are selecting the B input then wire the source ready signal to B's ready signal, otherwise hold B's ready low


endmodule
