// ***************************************************************************
// Copyright (c) 2013-2017, Intel Corporation All Rights Reserved.
// The source code contained or described herein and all  documents related to
// the  source  code  ("Material")  are  owned by  Intel  Corporation  or  its
// suppliers  or  licensors.    Title  to  the  Material  remains  with  Intel
// Corporation or  its suppliers  and licensors.  The Material  contains trade
// secrets and  proprietary  and  confidential  information  of  Intel or  its
// suppliers and licensors.  The Material is protected  by worldwide copyright
// and trade secret laws and treaty provisions. No part of the Material may be
// copied,    reproduced,    modified,    published,     uploaded,     posted,
// transmitted,  distributed,  or  disclosed  in any way without Intel's prior
// express written permission.
// ***************************************************************************
// TODO future improvements move sticky registers to HSL module implmentation 
module mem_fsm (     
	// ---------------------------global signals-------------------------------------------------
  input	pClk,	// Core clock. CCI interface is synchronous to this clock.
  input	pck_cp2af_softReset, // CCI interface reset. ACTIVE HIGH

  // - AMM Master Signals signals 
	output logic [63:0]     avs_writedata,
  input	 logic [63:0]     avs_readdata,
  output logic [25:0]     avs_address,
  input	 logic	          avs_waitrequest,
  output logic            avs_write,
  output logic            avs_read,
  output logic [63:0]     avs_byteenable,
  output logic [11:0]     avs_burstcount, 

  input                   avs_readdatavalid,
  input [1:0]             avs_response, 
  input                   avs_writeresponsevalid,
  
  // AVL MM CSR Control Signals 
  input [25:0]           avm_address,
  input                  avm_write,
  input                  avm_read,
  input [63:0]           avm_writedata,
  input [11:0]           avm_burstcount,   
  output logic [63:0]    avm_readdata,
  output logic [1:0]     avm_response,

  input                  mem_testmode,
  output logic [4:0]     addr_test_status, 
  output logic           addr_test_done,
  output logic [1:0]     rdwr_done, 
  output logic [4:0]     rdwr_status, 
  input                  rdwr_reset
);
parameter ADDRESS_MAX_BIT = 6;
typedef enum logic[2:0] { IDLE,
                          TEST_WRITE,
                          TEST_READ, 
                          RD_REQ,
                          RD_RSP,
                          WR_REQ,
                          WR_RSP } state_t;

   state_t        state;
   logic [32:0] address;
   assign avs_burstcount = avm_burstcount;
//   assign  avs_burstcount = burst_count;
   logic  [3:0] max_reads = 0;
   logic [10:0] burstcount;
   logic avs_readdatavalid_1 = 0;
   logic [1:0] avs_response_1;
`ifdef SIM_MODE
  assign avs_address = mem_testmode[0]? {'0, address[ADDRESS_MAX_BIT-1:0]}: avm_address;
  assign avs_writedata = (avm_burstcount >1)?burstcount : (mem_testmode[0])? {'0, address[ADDRESS_MAX_BIT-1:0]}: avm_writedata ;// avm_writedata; //{'0, address[ADDRESS_MAX_BIT-1:0]};
`else
  assign avs_address = mem_testmode? {'0, address[ADDRESS_MAX_BIT-1:0]}: avm_address;
  assign avs_writedata = avm_writedata;
`endif

assign avm_response = '0;
always@(posedge pClk) begin
  if(pck_cp2af_softReset) begin
    address        <= '0;
    avs_write      <= '0;
    avs_read       <= 0;
    avs_byteenable <= 64'hffff_ffff_ffff_ffff;
    state          <= IDLE;
    addr_test_done <= '0;
    burstcount     <= 1;
  end
  else begin 
    case(state)
      IDLE: begin 
        if (mem_testmode & ~addr_test_done)begin    
          avs_write <= 1;
          state <= TEST_WRITE;
        end else if (avm_write) begin 
          avs_write <= 1;
          state <= WR_REQ;
        end else if (avm_read) begin 
          avs_read <= 1;
          state <= RD_REQ;
        end 
      end

      TEST_WRITE: begin 
        if (address == {ADDRESS_MAX_BIT{1'b1}}) begin  //) begin //[ADDRESS_MAX_BIT] == {ADDRESS_MAX_BIT-1{1'b1}}) begin 
          state <= TEST_READ;
          avs_write <= 0; 
          avs_read <= 1;
          address <= 0;
        end 
        else if (~avs_waitrequest) begin  
          address <= address + 1;
          avs_write <= 1;
        end 
        else 
          avs_write <= 0;
        end

      TEST_READ: begin 
        if (address == {ADDRESS_MAX_BIT{1'b1}} & ~avs_waitrequest) begin 
          state <= IDLE;
          avs_read <= 0; 
          addr_test_done <= 1;
        end else if (avs_readdatavalid) begin 
          address <= address + 1;
          avs_read <= 1;
        end else 
          avs_read <= 0;
      end

      WR_REQ: begin //AVL MM Posted Write 
        if (avs_burstcount == burstcount ) begin 
          state <= WR_RSP;
          avs_write <= 0; 
          burstcount <= 1;
        end else
          burstcount++;
      end

      WR_RSP: begin // wait for write response  
        state <= IDLE;
      end 

      RD_REQ: begin // AVL MM Read non-posted
        state <= RD_RSP;
        avs_read <= 0; 
      end

      RD_RSP: begin 
        if (avs_readdatavalid) begin 
          if (burstcount == avs_burstcount)
            state <= IDLE;
          else 
            burstcount++;
        end
      end 
    endcase
  end // end else pck_cp2af_softReset
end // posedge pClk
    
always@(posedge pClk) begin 
  avs_readdatavalid_1 <= avs_readdatavalid; 

  if (avs_readdatavalid)
    avm_readdata <= avs_readdata;

  if(pck_cp2af_softReset) 
    addr_test_status <= 0;
  else begin 
    if (avs_readdatavalid & addr_test_done) 
      addr_test_status[1:0] <= 0;//avs_response;
    else if (avs_readdatavalid)
      if (avs_readdatavalid_1 & avm_readdata == avm_writedata)
        if (state == TEST_READ) 
          addr_test_status[2] <= 1;
        if (state == TEST_WRITE) 
          addr_test_status[2] <= 0;
  end 
end

always@(posedge pClk) begin 
  if (rdwr_reset & state != RD_RSP) begin 
    rdwr_status <= '0; 
    rdwr_done   <= '0;
  end 
  else if (state == WR_RSP) begin 
    rdwr_status[1:0] <= 0;//avs_response;
    rdwr_done[0] <= 1;
  end 
  else if (state == RD_RSP & avs_readdatavalid == 1) begin 
    if(avs_burstcount == burstcount)
      rdwr_done[1] <= 1;
      if (~rdwr_status[3])
        rdwr_status[3:2] <= 0;//avs_response;
  end 
end 

always@(posedge pClk) begin
  if (pck_cp2af_softReset) 
    max_reads <= 0;
  else  if (avs_read == 1 & avs_readdatavalid == 0 & ~avs_waitrequest)
    max_reads++;
  else if (avs_readdatavalid == 1 & ((~avs_waitrequest& ~avs_read ) || (avs_waitrequest&avs_read)))
    max_reads <= max_reads - 1;
end

endmodule
