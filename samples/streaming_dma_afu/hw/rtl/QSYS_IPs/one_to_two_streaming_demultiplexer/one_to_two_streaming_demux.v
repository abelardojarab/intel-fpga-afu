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

This module is a one-to-two demux with a software programmable select bit.  When
the select bit is set to 0, then the "A" source is wired up to the sink.  When
the select bit is set to 1, then the "B" source is wired up to the sink.  Before
changing the select bit the streaming paths should be quiescent to avoid
splitting the stream to two endpoints.  This logic is very cheap so no need for pipelining
between the sink and sources.

The software accessible CSR slave port has only one 64-bit address.  The select
bit is located at bit offset 0 of this location and supports read/write operations.

------------------
Author:  JCJB
Date:    10/31/2018
Version: 1.0
------------------

Version 1.0 - Initial version of the module

*/

module one_to_two_streaming_demux (
  clk,
  reset,
  
  csr_writedata,
  csr_write,
  csr_byteenable,
  csr_readdata,
  csr_read,  
  
  snk_data,
  snk_sop,
  snk_eop,
  snk_empty,
  snk_valid,
  snk_ready,
  
  src_A_data,
  src_A_sop,
  src_A_eop,
  src_A_empty,
  src_A_valid,
  src_A_ready,
  
  src_B_data,
  src_B_sop,
  src_B_eop,
  src_B_empty,
  src_B_valid,
  src_B_ready
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
   
  input [DATA_WIDTH-1:0]  snk_data;
  input                   snk_sop;
  input                   snk_eop;
  input [EMPTY_WIDTH-1:0] snk_empty;
  input                   snk_valid;
  output wire             snk_ready;
   
  output wire [DATA_WIDTH-1:0]  src_A_data;
  output wire                   src_A_sop;
  output wire                   src_A_eop;
  output wire [EMPTY_WIDTH-1:0] src_A_empty;
  output wire                   src_A_valid;
  input                         src_A_ready;
   
  output wire [DATA_WIDTH-1:0]  src_B_data;
  output wire                   src_B_sop;
  output wire                   src_B_eop;
  output wire [EMPTY_WIDTH-1:0] src_B_empty;
  output wire                   src_B_valid;
  input                         src_B_ready;

  reg select;  // when 0 source A is selected, and when 1 source B is selected


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
  
  
  // sink to source A wiring (it's ok that data, sop, eop, and empty are repeated to both sources, as long as valid only asserts to one port)
  assign src_A_data = snk_data;
  assign src_A_sop = snk_sop;
  assign src_A_eop = snk_eop;
  assign src_A_empty = snk_empty;
  assign src_A_valid = (select == 1'b0) & snk_valid;  // if source A is selected then forward the sink valid to source A's valid


  // sink to source B wiring (it's ok that data, sop, eop, and empty are repeated to both sources, as long as valid only asserts to one port)
  assign src_B_data = snk_data;
  assign src_B_sop = snk_sop;
  assign src_B_eop = snk_eop;
  assign src_B_empty = snk_empty;
  assign src_B_valid = (select == 1'b1) & snk_valid;  // if source B is selected then forward the sink valid to source B's valid


  // src A & B to sink wiring
  assign snk_ready = (select == 1'b0)? src_A_ready : src_B_ready;

endmodule
