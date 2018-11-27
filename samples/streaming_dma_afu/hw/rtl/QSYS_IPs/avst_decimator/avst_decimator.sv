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

This module recieves a stream of data and removes a programmable number of beats before
forwarding the data.  The number of beats to remove is called the decimation factor so
a value of 0 means no removal, 1 means every other beat is removed, 2 means one beat out
of three is removed, etc....

The module *always* forwards beats with SOP or EOP set so that packet boundaries do notice
get filtered out.  The decimation process is implemented using a modulo counter where
beats are forwarded every time the counter is set to 0 (or SOP/EOP is asserted).  If the
data leaving this module needs to be validated by software, then the host application can
implement the same decimation algorithm (module counter) when checking the results form
correctness.

There is only a single control register exposed by the module for software to access.  The
bitfields are listed below


Bit Offset    Access      Field            Reset Value                                   Description
----------    ------      -----            -----------                                   -----------
    0          R/W        Enable                0             No data is accepted or forwarded while the module is disabled (enable = 0)
  15-1          R        <RSVD0>                0             Reserved, writes to these bits should be 0 and the data read back will be 0
  31-16        R/W     Decimation Factor        0             Number of streaming beats to be removed for every beat forwarded to the streaming source
  47-32        R/W     Decimation Counter       0             When counter is 0 streaming data is forwarded.  This value should only be updated while the module is disabled.  The counter must be set less than Decimation Factor.
  63-48         R        <RSVD0>                0             Reserved, writes to these bits should be 0 and the data read back will be 0



------------------
Author:  JCJB
Date:    11/01/2018
Version: 1.0
------------------

Version 1.0 - Initial version of the module

*/

module avst_decimator #
(
  DATA_WIDTH = 512,
  EMPTY_WIDTH = 6     // log2(DATA_WIDTH/8), will be calculated in hardware .tcl
)
(
  input clk,
  input reset,
  
  input               csr_write,
  input [63:0]        csr_writedata,
  input [7:0]         csr_byteenable,
  input               csr_read,
  output logic [63:0] csr_readdata,
  
  input [DATA_WIDTH-1:0]  snk_data,
  input                   snk_valid,
  output logic            snk_ready,
  input                   snk_sop,
  input                   snk_eop,
  input [EMPTY_WIDTH-1:0] snk_empty,
  
  output logic [DATA_WIDTH-1:0]  src_data,
  output logic                   src_valid,
  input                          src_ready,
  output logic                   src_sop,
  output logic                   src_eop,
  output logic [EMPTY_WIDTH-1:0] src_empty  
);


  logic enable;
  logic [15:0] decimation_factor;
  logic [15:0] decimation_counter;
  logic increment_decimation_counter;
    
  
  
  always @ (posedge clk)
  begin
    if (reset)
    begin
      enable <= 1'b0;
    end
    else if ((csr_write == 1'b1) & (csr_byteenable[0] == 1'b1))
    begin
      enable <= csr_writedata[0];
    end
  end
  
  
  always @ (posedge clk)
  begin
    if (reset)
    begin
      decimation_factor <= 16'h0000;
    end
    else
    begin
      if ((csr_write == 1'b1) & (csr_byteenable[2] == 1'b1))
      begin
        decimation_factor[7:0] <= csr_writedata[23:16];
      end
      if ((csr_write == 1'b1) & (csr_byteenable[3] == 1'b1))
      begin
        decimation_factor[15:8] <= csr_writedata[31:24];
      end
    end
  end
  
  
  always @ (posedge clk)
  begin
    if (reset)
    begin
      decimation_counter <= 16'h0000;
    end
    else if (csr_write == 1'b1)  // loading the counter is higher priority so make sure module is disabled before setting new value
    begin
      if (csr_byteenable[4] == 1'b1)
      begin
        decimation_counter[7:0] <= csr_writedata[39:32];
      end
      if (csr_byteenable[5] == 1'b1)
      begin
        decimation_counter[15:8] <= csr_writedata[47:40];
      end
    end
    else if (increment_decimation_counter)
    begin
      decimation_counter <= (decimation_counter == decimation_factor)? 16'h0000 : decimation_counter + 1'b1;
    end
  end



  
  assign csr_readdata = {16'h0000, decimation_counter, decimation_factor, 15'h0000, enable};
  
  assign src_data = snk_data;
  assign src_sop = snk_sop;
  assign src_eop = snk_eop;
  assign src_empty = snk_empty;
  
  // only allow data to transfer if the module is enabled.  Source filters out beats except when the counter is 0 or the beat is start/end of packet
  assign src_valid = ((decimation_counter == 16'h0000) | snk_sop | snk_eop) & snk_valid & enable;
  assign snk_ready = src_ready & enable;
  
  assign increment_decimation_counter = snk_ready & snk_valid;

endmodule
