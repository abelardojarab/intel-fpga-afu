// ***************************************************************************
// Copyright (c) 2013-2016, Intel Corporation
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
// Module Name:         test_lpbk1.v
// Project:             NLB AFU 
// Description:         memory copy test
//
// ***************************************************************************
// ---------------------------------------------------------------------------------------------------------------------------------------------------
//                                         Loopback 1- memory copy test
//  ------------------------------------------------------------------------------------------------------------------------------------------------
//
// This is a memory copy test. It copies cache lines from source to destination buffer.
//

module test_lpbk1 #(parameter PEND_THRESH=1, ADDR_LMT=20, MDATA=14)
(

//      ---------------------------global signals-------------------------------------------------
       Clk_400               ,        // in    std_logic;  -- Core clock

       l12ab_WrAddr,                   // [ADDR_LMT-1:0]        arb:               write address
       l12ab_WrTID,                    // [ADDR_LMT-1:0]        arb:               meta data
       l12ab_WrDin,                    // [511:0]               arb:               Cache line data
       l12ab_WrEn,                     //                       arb:               write enable
       ab2l1_WrSent,                   //                       arb:               write issued
       ab2l1_WrAlmFull,                //                       arb:               write fifo almost full
       
       l12ab_RdAddr,                   // [ADDR_LMT-1:0]        arb:               Reads may yield to writes
       l12ab_RdTID,                    // [15:0]                arb:               meta data
       l12ab_RdEn,                     //                       arb:               read enable
       ab2l1_RdSent,                   //                       arb:               read issued

       ab2l1_RdRspValid_T0,            //                       arb:               read response valid
       ab2l1_RdRsp_T0,                 // [15:0]                arb:               read response header
       ab2l1_RdRspAddr_T0,             // [ADDR_LMT-1:0]        arb:               read response address
       ab2l1_RdData_T0,                // [511:0]               arb:               read data
       ab2l1_stallRd,                  //                       arb:               stall read requests FOR LPBK1

       ab2l1_WrRspValid_T0,            //                       arb:               write response valid
       ab2l1_WrRsp_T0,                 // [15:0]                arb:               write response header
       ab2l1_WrRspAddr_T0,             // [ADDR_LMT-1:0]        arb:               write response address
       re2xy_go,                       //                       requestor:         start the test
       re2xy_NumLines,                 // [31:0]                requestor:         number of cache lines
       re2xy_Cont,                     //                       requestor:         continuous mode

       l12ab_TestCmp,                  //                       arb:               Test completion flag
       l12ab_ErrorInfo,                // [255:0]               arb:               error information
       l12ab_ErrorValid,               //                       arb:               test has detected an error
       test_Resetb,                    //                       requestor:         rest the app
     
       l12ab_RdLen,
       l12ab_RdSop,
       l12ab_WrLen,
       l12ab_WrSop,
        
       ab2l1_RdRspFormat,
       ab2l1_RdRspCLnum_T0,
       ab2l1_WrRspFormat_T0,
       ab2l1_WrRspCLnum_T0,
       re2xy_multiCL_len
);
    input                   Clk_400;               //                      csi_top:            Clk_400
    
    output  [ADDR_LMT-1:0]  l12ab_WrAddr;           // [ADDR_LMT-1:0]        arb:               write address
    output  [15:0]          l12ab_WrTID;            // [15:0]                arb:               meta data
    output  [511:0]         l12ab_WrDin;            // [511:0]               arb:               Cache line data
    output                  l12ab_WrEn;             //                       arb:               write enable
    input                   ab2l1_WrSent;           //                       arb:               write issued
    input                   ab2l1_WrAlmFull;        //                       arb:               write fifo almost full
           
    output  [ADDR_LMT-1:0]  l12ab_RdAddr;           // [ADDR_LMT-1:0]        arb:               Reads may yield to writes
    output  [15:0]          l12ab_RdTID;            // [15:0]                arb:               meta data
    output                  l12ab_RdEn;             //                       arb:               read enable
    input                   ab2l1_RdSent;           //                       arb:               read issued
    
    input                   ab2l1_RdRspValid_T0;    //                       arb:               read response valid
    input  [15:0]           ab2l1_RdRsp_T0;         // [15:0]                arb:               read response header
    input  [ADDR_LMT-1:0]   ab2l1_RdRspAddr_T0;     // [ADDR_LMT-1:0]        arb:               read response address
    input  [511:0]          ab2l1_RdData_T0;        // [511:0]               arb:               read data
    input                   ab2l1_stallRd;          //                       arb:               stall read requests FOR LPBK1
    
    input                   ab2l1_WrRspValid_T0;    //                       arb:               write response valid
    input  [15:0]           ab2l1_WrRsp_T0;         // [15:0]                arb:               write response header
    input  [ADDR_LMT-1:0]   ab2l1_WrRspAddr_T0;     // [Addr_LMT-1:0]        arb:               write response address
    
    input                   re2xy_go;               //                       requestor:         start of frame recvd
    input  [31:0]           re2xy_NumLines;         // [31:0]                requestor:         number of cache lines
    input                   re2xy_Cont;             //                       requestor:         continuous mode
    
    output                  l12ab_TestCmp;          //                       arb:               Test completion flag
    output [255:0]          l12ab_ErrorInfo;        // [255:0]               arb:               error information
    output                  l12ab_ErrorValid;       //                       arb:               test has detected an error
    input                   test_Resetb;
  
    output [1:0]            l12ab_RdLen;
    output                  l12ab_RdSop;
    output [1:0]            l12ab_WrLen;
    output                  l12ab_WrSop;
  
    input                   ab2l1_RdRspFormat;
    input  [1:0]            ab2l1_RdRspCLnum_T0;
    input                   ab2l1_WrRspFormat_T0;
    input  [1:0]            ab2l1_WrRspCLnum_T0;

    input  [1:0]            re2xy_multiCL_len;
  
    //------------------------------------------------------------------------------------------------------------------------
    
    reg     [ADDR_LMT-1:0]  l12ab_WrAddr;           // [ADDR_LMT-1:0]        arb:               Writes are guaranteed to be accepted
    reg     [15:0]          l12ab_WrTID;            // [15:0]                arb:               meta data
    reg     [511:0]         l12ab_WrDin;            // [511:0]               arb:               Cache line data
    reg                     l12ab_WrEn;             //                       arb:               write enable
    reg     [ADDR_LMT-1:0]  l12ab_RdAddr;           // [ADDR_LMT-1:0]        arb:               Reads may yield to writes
    reg     [15:0]          l12ab_RdTID;            // [15:0]                arb:               meta data
    reg                     l12ab_RdEn;             //                       arb:               read enable
    reg                     l12ab_TestCmp;          //                       arb:               Test completion flag
    reg    [255:0]          l12ab_ErrorInfo;        // [255:0]               arb:               error information
    reg                     l12ab_ErrorValid;       //                       arb:               test has detected an error
    
    reg     [MDATA-1:0]     wr_mdata;
    reg     [1:0]           read_fsm;
    reg                     write_fsm, write_fsm_q;
    reg     [19:0]          Num_Read_req;
    reg     [19:0]          Num_Write_req;
    reg     [19:0]          Num_Write_rsp;
    reg     [1:0]           l12ab_RdLen;
    reg                     l12ab_RdSop;
    reg     [1:0]           l12ab_WrLen;              
    reg                     l12ab_WrSop;
    
    // ----------------------------------------------------------------------------
    // Duplicate registers with high routing congestion to relax timing 
    // -----------------------------------------------------------------------------
    (* maxfan=2   *) reg   [6:0]       rd_mdata, rd_mdata_next; // limit max mdata to 8 bits or 256 requests
    (* maxfan=1   *) reg   [2**7-1:0]  rd_mdata_pend;           // bitvector to track used mdata values
    (* maxfan=1   *) reg               rd_mdata_avail;          // is the next rd madata free and available
    (* maxfan=32  *) logic [8:0]       memwr_addr;
    (* maxfan=1   *) logic [3:0]       RdRsp_vector_bank[0:15][0:7];
    (* maxfan=1   *) logic [15:0]      ab2l1_RdRsp;
    (* maxfan=1   *) logic [6:0]       ab2l1_RdRsp_q;
    
    // ------------------------------------------------------
    // RAM to store RdRsp Data and Address
    // ------------------------------------------------------
    logic [533:0] rdrsp_mem_in;
    logic [533:0] wrreq_mem_out;
    logic [533:0] wrreq_mem_out_q;
    logic [8:0]   memrd_addr;
    logic         memwr_en;
    
    // 2 cycle Read latency  
    // 2 cycle Rd2Wr latency
    // Unknown data returned if same address is read, written 
    lpbk1_RdRspRAM2PORT rdrsp_mem (
      .data      (rdrsp_mem_in),    //  ram_input.datain
      .wraddress (memwr_addr),      //           .wraddress
      .rdaddress (memrd_addr),      //           .rdaddress
      .wren      (memwr_en),        //           .wren
      .clock     (Clk_400),         //           .clock
      .q         (wrreq_mem_out)    // ram_output.dataout
    );
    // ------------------------------------------------------
    logic                Wr_go, Wr_go_q;
    logic                ram_rdValid;
    logic                ram_rdValid_q;
    logic                ram_rdValid_qq;
    logic                ram_rdValid_qqq;
    logic                wrsop;
    logic                wrsop_q;
    logic                wrsop_qq;
    logic                wrsop_qqq;
    logic [7:0]          i;
    logic [6:0]          WrReq_tid, WrReq_tid_q;
    logic [6:0]          WrReq_tid_mCL;
    logic [1:0]          CL_ID;
    logic [1:0]          wrCLnum;
    logic [1:0]          wrCLnum_q;
    logic [1:0]          wrCLnum_qq;
    logic [1:0]          wrCLnum_qqq;
    logic [2:0]          multiCL_num;
    logic                ab2l1_RdRspValid_q;
    logic                RdRsp_vector_bank_Ready[0:15] [0:7];
    logic [1:0]          ab2l1_RdRspCLnum;
    logic [ADDR_LMT-1:0] ab2l1_RdRspAddr;  
    logic [511:0]        ab2l1_RdData;       
    logic                ab2l1_RdRspValid;
    
    logic [3:0]          RdRsp_is_Ready;
    logic [3:0]          new_RdRsp_tracker;
    logic [3:0]          new_RdRsp_tracker_q;
    logic [3:0]          old_RdRsp_tracker;
    logic                b2b_RdRsp;
      
    logic [15:0]         ab2l1_WrRsp;
    logic [1:0]          ab2l1_WrRspCLnum;
    logic [ADDR_LMT-1:0] ab2l1_WrRspAddr;
    logic                ab2l1_WrRspFormat;
    logic                ab2l1_WrRspValid; 
     
    // Timing fix: Registering WrRsp inputs - Adds 1 additional cycle bw last WrRsp to completion 
    always@(posedge Clk_400)
    begin
      ab2l1_WrRsp        <= ab2l1_WrRsp_T0;
      ab2l1_WrRspCLnum   <= ab2l1_WrRspCLnum_T0;
      ab2l1_WrRspAddr    <= ab2l1_WrRspAddr_T0;
      ab2l1_WrRspFormat  <= ab2l1_WrRspFormat_T0; 
      ab2l1_WrRspValid   <= ab2l1_WrRspValid_T0;
    end 
    
    // Timing fix: Registering RdRsp inputs - Adds 1 additional cycle bw RdRsp to WrReq
    always@(posedge Clk_400)
    begin
      ab2l1_RdRsp        <= ab2l1_RdRsp_T0;
      ab2l1_RdRspCLnum   <= ab2l1_RdRspCLnum_T0;
      ab2l1_RdRspAddr    <= ab2l1_RdRspAddr_T0;
      ab2l1_RdData       <= ab2l1_RdData_T0;
      ab2l1_RdRspValid   <= ab2l1_RdRspValid_T0;  
            
      if (ab2l1_RdRspValid_T0 && ab2l1_RdRspValid && ab2l1_RdRsp_T0[6:0] == ab2l1_RdRsp[6:0])
      begin
        b2b_RdRsp        <= 1;
      end

      else
      begin
        b2b_RdRsp        <= 0;
      end      
    end
  
    always @(posedge Clk_400)
    begin
      memwr_en                          <= 0; 
      memwr_addr                        <= {ab2l1_RdRsp[6:0],ab2l1_RdRspCLnum[1:0]}; 
      rdrsp_mem_in                      <= {ab2l1_RdData[511:0],ab2l1_RdRspAddr[19:0],ab2l1_RdRspCLnum[1:0]}; 
      
      // Store RdResponses in RAM
      if(ab2l1_RdRspValid)
      begin
        memwr_en                        <= 1;
      end
      
      // One-hot RdRsp-Tracker
      begin
        if (!test_Resetb)
        begin
          RdRsp_is_Ready                <= 4'b0000;
          new_RdRsp_tracker             <= 4'b0000;
          new_RdRsp_tracker_q           <= 4'b0000;
          old_RdRsp_tracker             <= 4'b0000;
        end
        
        else
        begin
          // Static Update based on multi CL length
          case (re2xy_multiCL_len)
            2'b00  :  RdRsp_is_Ready    <= 4'b0001;
            2'b01  :  RdRsp_is_Ready    <= 4'b0011;
            2'b11  :  RdRsp_is_Ready    <= 4'b1111;
            default:  RdRsp_is_Ready    <= 4'b0001;
          endcase
          
          // Update vector based on current CL RdRsp
          case (ab2l1_RdRspCLnum_T0)
            2'b00  :  new_RdRsp_tracker <= 4'b0001;
            2'b01  :  new_RdRsp_tracker <= 4'b0010;
            2'b10  :  new_RdRsp_tracker <= 4'b0100;
            2'b11  :  new_RdRsp_tracker <= 4'b1000;
          endcase
          
          new_RdRsp_tracker_q           <= new_RdRsp_tracker;        
        end   
      end
      
      // 2 cycles to update numRdRsp vector
      begin  
        // Register Read Responses
        ab2l1_RdRspValid_q                       <= ab2l1_RdRspValid;
        ab2l1_RdRsp_q                            <= ab2l1_RdRsp;
              
        // It takes 2 cycles to update RdRsp vector RF        
        // If there are 2 successive RspValids to the same entry in RdRsp vector,
        // Forwarding current cycle response while updating RdRsp vector for prev response
        // 1st cycle - READ from RF
        // 2nd cycle - MODIFY + WRITE to RF
        // If there is rsp valid to same entry in 2nd cycle --> MODIFY includes forwarded value.
        // If all RdRsp required for initiating a write is received, Updating Ready vector is overlapped with MODIFY + WRITE
               
        if (ab2l1_RdRspValid)
        begin
          if (b2b_RdRsp)
          begin
            old_RdRsp_tracker                    <= (RdRsp_vector_bank[ab2l1_RdRsp_q[6:3]][ab2l1_RdRsp_q[2:0]][3:0]) | new_RdRsp_tracker_q;    
          end
         
          // Response Received, Read current count from RdRsp vector
          else 
          begin
            old_RdRsp_tracker                    <= RdRsp_vector_bank[ab2l1_RdRsp[6:3]][ab2l1_RdRsp[2:0]][3:0];      
          end
        end
        
        // Update RdRsp vector
        if (ab2l1_RdRspValid_q)
        begin
          RdRsp_vector_bank[ab2l1_RdRsp_q[6:3]][ab2l1_RdRsp_q[2:0]][3:0] <= new_RdRsp_tracker_q | old_RdRsp_tracker;
          if ((new_RdRsp_tracker_q | old_RdRsp_tracker) == RdRsp_is_Ready) 
          begin
            RdRsp_vector_bank_Ready[ab2l1_RdRsp_q[6:3]][ab2l1_RdRsp_q[2:0]]    <= 1;
          end
        end            
      end
       
      // Compute next Write Request number and update Write go
      begin
        Wr_go                                                    <= RdRsp_vector_bank_Ready[WrReq_tid[6:3]][WrReq_tid[2:0]];
        if (Wr_go && !write_fsm)
        begin    
          // Store TID for mCL requests and update TID
          WrReq_tid_mCL                                          <= WrReq_tid[6:0]; 
          WrReq_tid[6:0]                                         <= WrReq_tid[6:0] + 1'h1;
        
          // Clear RdRsp vectors 
          RdRsp_vector_bank[WrReq_tid[6:3]][WrReq_tid[2:0]][3:0] <= 4'h0;
          RdRsp_vector_bank_Ready[WrReq_tid[6:3]][WrReq_tid[2:0]]<= 1'h0;
        end
        
        // Make corresponding Rd mdata available in next clk
        Wr_go_q                                                  <= Wr_go;
        write_fsm_q                                              <= write_fsm;
        WrReq_tid_q                                              <= WrReq_tid;
        if (Wr_go_q & !write_fsm_q)
        begin
          rd_mdata_pend[{WrReq_tid_q[6:3],WrReq_tid_q[2:0]}]     <= 1'b0;
        end
        
      end
          
      // FSM to send mem write requests 
      // Requestor Stores Tx Writes in a FIFO
      // TxFIFO is sized in such a way that writes are guaranteed to be accepted
      // So, ab2l1_WrSent = 0 when WrEn=1 is an error condition
      case (write_fsm)   /* synthesis parallel_case */
      1'h0:
        begin
        if (Wr_go)
        begin
          // Read first CL of 'num_multi_CL' memWrite requests from RAM
          write_fsm                        <= 1'h1;
          CL_ID                            <= CL_ID + 1'b1;
          memrd_addr                       <= {WrReq_tid[6:0], CL_ID};
          ram_rdValid                      <= 1;
          wrsop                            <= 1;
          wrCLnum                          <= re2xy_multiCL_len[1:0];
        end
        end
      
      1'h1:
        begin
          if (|wrCLnum[1:0])
          begin
          // Read remaining CLs of 're2xy_multiCL_len' memWrite requests from RAM
          write_fsm                        <= 1'h1;
          CL_ID                            <= CL_ID + 1'b1;
          memrd_addr                       <= {WrReq_tid_mCL[6:0], CL_ID};
          ram_rdValid                      <= 1;
          wrsop                            <= 0;
          wrCLnum                          <= wrCLnum - 1'b1;
          end  
                          
          else
          begin         
          // Goto next set of multiCL requests 
          // One cycle bubble between each set of multi CL writes. 
          // TODO: optimize 
          write_fsm                        <= 1'h0;
          CL_ID                            <= 0;
          ram_rdValid                      <= 0;
          wrsop                            <= 1;
          wrCLnum                          <= re2xy_multiCL_len[1:0];
          end
        end
      
      default:
      begin
        write_fsm                            <= write_fsm;
      end
      endcase  

      // Pipeline WrReq parameters till RAM output is valid
      ram_rdValid_q                            <= ram_rdValid;
      ram_rdValid_qq                           <= ram_rdValid_q;
      ram_rdValid_qqq                          <= ram_rdValid_qq;
      
      wrsop_q                                  <= wrsop;
      wrsop_qq                                 <= wrsop_q;
      wrsop_qqq                                <= wrsop_qq;
      
      wrCLnum_q                                <= wrCLnum;
      wrCLnum_qq                               <= wrCLnum_q;
      wrCLnum_qqq                              <= wrCLnum_qq;
      
      wrreq_mem_out_q                          <= wrreq_mem_out;
      
      // send Multi CL Write Requests 
      l12ab_WrEn                               <= (ram_rdValid_qqq == 1'b1); 
      l12ab_WrAddr                             <= wrreq_mem_out_q[21:2] + wrreq_mem_out_q[1:0] ;
      l12ab_WrDin                              <= wrreq_mem_out_q[533:22];
      l12ab_WrTID[15:0]                        <= wrreq_mem_out_q[17:2];
      l12ab_WrSop                              <= wrsop_qqq;
      l12ab_WrLen                              <= wrCLnum_qqq;
        
      // Track Num Write requests
      if (l12ab_WrEn)
      begin
        Num_Write_req                          <= Num_Write_req   + 1'b1;
      end    
        
      // Track Num Write responses
      if(ab2l1_WrRspValid && ab2l1_WrRspFormat)   // Packed write response
      begin
        Num_Write_rsp                          <= Num_Write_rsp + 1'b1 + ab2l1_WrRspCLnum; 
      end
      
      else if (ab2l1_WrRspValid)                  // unpacked write response
      begin
        Num_Write_rsp                          <= Num_Write_rsp + 1'b1;   
      end
      
      // Meta data locked when RdSent
      if(l12ab_RdEn && ab2l1_RdSent)
      begin
        rd_mdata_pend[rd_mdata]                <= 1'b1;
      end
    
      if (!test_Resetb)
      begin
        Wr_go                                  <= 0;
        memwr_en                               <= 0;  
      
        for (i=0; i[7]!=1; i=i+1'b1)
        begin
        RdRsp_vector_bank[i[6:3]][i[2:0]]      <= 0;
        RdRsp_vector_bank_Ready[i[6:3]][i[2:0]]<= 0;
        end
      
        multiCL_num                            <= 1;
        rd_mdata_pend                          <= 0;
        write_fsm                              <= 1'h0;
        WrReq_tid                              <= 0;
        WrReq_tid_mCL                          <= 0;
        CL_ID                                  <= 0;
        ram_rdValid                            <= 0;
        wrsop                                  <= 1;
        wrCLnum                                <= 0;
        l12ab_WrEn                             <= 0;
        l12ab_WrSop                            <= 1;
        l12ab_WrLen                            <= 0;
        Num_Write_req                          <= 20'h1;
        Num_Write_rsp                          <= 0;
      end 
    end
  
    always @(posedge Clk_400)
    begin
            //Read FSM
            case(read_fsm)  /* synthesis parallel_case */
            2'h0:   
            begin  // Wait for re2xy_go
              l12ab_RdAddr                       <= 0;
              l12ab_RdLen                        <= re2xy_multiCL_len; 
              l12ab_RdSop                        <= 1'b1;
              Num_Read_req                       <= 20'h0 + re2xy_multiCL_len + 1'b1;       // Default is 1 req; implies single CL 
              
              if(re2xy_go)
                if(re2xy_NumLines!=0)
                  read_fsm                       <= 2'h1;
                else    
                  read_fsm                       <= 2'h2;
            end
            
            2'h1:   
            begin  // Send read requests
              if(ab2l1_RdSent)        
              begin   
                l12ab_RdAddr                     <= l12ab_RdAddr + re2xy_multiCL_len + 1'b1; // multiCL_len = {0/1/2/3}
                l12ab_RdLen                      <= l12ab_RdLen;                             // All reqs are uniform. Based on test cfg
                l12ab_RdSop                      <= 1'b1;                                    // All reqs are uniform. Based on test cfg
                Num_Read_req                     <= Num_Read_req + re2xy_multiCL_len + 1'b1; // final count will be same as re2xy_NumLines   
                                                                 
                if(Num_Read_req == re2xy_NumLines)
                if(re2xy_Cont)    read_fsm       <= 2'h0;
                else              read_fsm       <= 2'h2;
              end // ab2l1_RdSent
            end
            
            default:              read_fsm       <= read_fsm;
            endcase
            
            if(l12ab_RdEn && ab2l1_RdSent)
            begin
              rd_mdata_next                      <= rd_mdata + 2'h2;
              rd_mdata                           <= rd_mdata_next;
              rd_mdata_avail                     <= !rd_mdata_pend[rd_mdata_next];
            end
            
            else
            begin
              rd_mdata_avail                     <= !rd_mdata_pend[rd_mdata];
              rd_mdata_next                      <= rd_mdata + 1'h1;
            end
      
            // TODO:      
            if(read_fsm==2'h2 && Num_Write_rsp==re2xy_NumLines)
            begin            
              l12ab_TestCmp                      <= 1'b1;
            end
    
            // Error logic
            if(l12ab_WrEn && ab2l1_WrSent==0)
            begin
              // WrFSM assumption is broken
              $display ("%m LPBK1 test WrEn asserted, but request Not accepted by requestor");
              l12ab_ErrorValid                   <= 1'b1;
              l12ab_ErrorInfo                    <= 1'b1;
            end
           
            if(!test_Resetb)
            begin
//            l12ab_WrAddr                       <= 0;
//            l12ab_RdAddr                       <= 0;
              l12ab_TestCmp                      <= 0;
              l12ab_ErrorInfo                    <= 0;
              l12ab_ErrorValid                   <= 0;
              read_fsm                           <= 0;
              rd_mdata                           <= 0;
              rd_mdata_avail                     <= 1'b1;
              Num_Read_req                       <= 20'h1;
              l12ab_RdLen                        <= 0;
              l12ab_RdSop                        <= 1;
            end
    end
    
    always @(*)
    begin
      l12ab_RdTID = 0;
      l12ab_RdTID[MDATA-1:0] = rd_mdata;
      l12ab_RdEn = (read_fsm  ==2'h1) & !ab2l1_stallRd & rd_mdata_avail;
    end
  
   // synthesis translate_off
   logic numCL_error = 0;
   always @(posedge Clk_400)
   begin
     if( re2xy_go && ((re2xy_NumLines)%(re2xy_multiCL_len + 1) != 0)  )
     begin
       $display("%m \m ERROR: Total Num Lines should be exactly divisible by multiCL length");
       $display("\m re2xy_NumLines = %d and re2xy_multiCL_len = %d",re2xy_NumLines,re2xy_multiCL_len);
       numCL_error <= 1'b1;
     end
  
     if(numCL_error)
     $finish();
   end
   // synthesis translate_on
    
endmodule

