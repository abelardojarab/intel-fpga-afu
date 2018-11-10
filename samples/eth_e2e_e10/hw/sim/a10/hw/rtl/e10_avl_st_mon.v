// ***************************************************************************  
//
//          Copyright (C) 2017 Intel Corporation All Rights Reserved.
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

// maguirre - Modified for e10 E2E GBS (April/2017)

 module e10_avl_st_mon
 (
  input clk               
 ,input reset             
 ,input [7:0]  avalon_mm_address           
 ,input avalon_mm_write             
 ,input avalon_mm_read              
 ,output wire avalon_mm_waitrequest              
 ,input [31:0] avalon_mm_writedata         
 ,output reg[31:0] avalon_mm_readdata          
 
 ,input  mac_rx_status_valid    
 ,input  mac_rx_status_error    
 //,input [38:0] mac_rx_status_data    
 ,input [39:0] mac_rx_status_data    
 
 ,input [63:0] avalon_st_rx_data           
 ,input avalon_st_rx_valid          
 ,input avalon_st_rx_sop            
 ,input avalon_st_rx_eop            
 ,input [2:0]  avalon_st_rx_empty          
 ,input [5:0]  avalon_st_rx_error          
 ,output reg   avalon_st_rx_ready          
 ,input wire   stop_mon
 ,output wire  mon_active
 ,output reg   mon_done
 ,output reg   mon_error
 ,output       gen_lpbk
 );

//--------------------------------------------------------------------------------
// Local parameters
//--------------------------------------------------------------------------------

localparam ADDR_MACDA0   = 8'h0;
localparam ADDR_MACDA1   = 8'h1;
localparam ADDR_MACSA0   = 8'h2;
localparam ADDR_MACSA1   = 8'h3;
localparam ADDR_PKT_NUMB = 8'h4;
localparam ADDR_MON_CTRL = 8'h5;
localparam ADDR_MON_STAT = 8'h6;
localparam ADDR_PKT_GOOD = 8'h7;
localparam ADDR_PKT_BAD  = 8'h8;

//--------------------------------------------------------------------------------
// Internal signals
//--------------------------------------------------------------------------------

reg [47:0] dst_addr;      // Register to program the MAC destination address [31:0]
reg [47:0] src_addr;      // Register to program the MAC source address [31:0]
reg [31:0] number_pkt;     // Register to store number of packets to be transmitted
reg [31:0] good_pkts;                
reg [31:0] bad_pkts;       
reg [15:0] byte_count;

reg  init_reg;
wire mon_init;
reg  stop_reg;
wire mon_stop;
reg  continuous;

reg pkt_len_err;
reg src_addr_err;
reg dst_addr_err;

reg [47:0] rcvd_dst_addr;
reg [47:0] rcvd_src_addr;
reg [15:0] rcvd_pkt_len; 
reg        eval_errors;

wire crcbad;
wire crcvalid;

//--------------------------------------------------------------------------------
// Configuration registers decoding
//--------------------------------------------------------------------------------

// mon_pkt_ctrl
// [0] - Start packet monitoring (self-clearing)
// [1] - Stop packet monitoring (self-clearing)
// [2] - Continuous mode

// mon_pkt_stat
// [0] - Monitoring completed (Received number of packets)
// [1] - Destination Address error
// [2] - Source Address error
// [3] - Packet Length error
// [4] - Packet CRC payload error 

always @(posedge reset or posedge clk)
begin
    if (reset)
    begin
        dst_addr    <= 32'h0;
        src_addr    <= 32'h0;
        number_pkt  <= 32'h0;
        continuous  <= 1'b0;
        stop_reg    <= 1'b0;
        init_reg    <= 1'b0;
    end
    else 
        if (avalon_mm_write)
            case (avalon_mm_address)
                ADDR_MACDA0   : dst_addr[31: 0] <= avalon_mm_writedata;
                ADDR_MACDA1   : dst_addr[47:32] <= avalon_mm_writedata[15:0];
                ADDR_MACSA0   : src_addr[31: 0] <= avalon_mm_writedata;
                ADDR_MACSA1   : src_addr[47:32] <= avalon_mm_writedata[15:0];
                ADDR_PKT_NUMB : number_pkt      <= avalon_mm_writedata;
                ADDR_MON_CTRL : {continuous,
                                 stop_reg,
                                 init_reg}       <= avalon_mm_writedata[2:0];
            endcase
        else
        begin
            if (init_reg)
                init_reg <= 1'b0;
            if (stop_reg)
                stop_reg <= 1'b0;
        end
end

always @(posedge clk)
begin
    if (avalon_mm_read)
        case (avalon_mm_address)
            ADDR_MACDA0     : avalon_mm_readdata <= dst_addr[31:0];
            ADDR_MACDA1     : avalon_mm_readdata <= 32'b0 | dst_addr[47:32];
            ADDR_MACSA0     : avalon_mm_readdata <= src_addr[31:0];
            ADDR_MACSA1     : avalon_mm_readdata <= 32'b0 | src_addr[47:32];
            ADDR_PKT_NUMB   : avalon_mm_readdata <= number_pkt;
            ADDR_MON_CTRL   : avalon_mm_readdata <= 32'b0 | {continuous,
                                                             stop_reg,
                                                             init_reg};
            ADDR_MON_STAT   : avalon_mm_readdata <= 32'b0 | {mon_error,
                                                             pkt_len_err,
                                                             src_addr_err,
                                                             dst_addr_err,
                                                             mon_done};
            ADDR_PKT_GOOD   : avalon_mm_readdata <= good_pkts;
            ADDR_PKT_BAD    : avalon_mm_readdata <= bad_pkts;
            default         : avalon_mm_readdata <= 32'h0;
        endcase
end

//--------------------------------------------------------------------------------
// Start pulse generation
//--------------------------------------------------------------------------------

reg init_dly;

always @ (posedge reset or posedge clk)
begin
    if (reset)  
        init_dly<= 1'b0;
    else 
        init_dly<= init_reg; 
end

assign mon_init = init_reg & ~init_dly;

//--------------------------------------------------------------------------------
// Stop pulse generation
//--------------------------------------------------------------------------------

reg stop_dly;

always @ (posedge reset or posedge clk)
begin
    if (reset) 
        stop_dly <= 1'b0;
    else
        stop_dly <= stop_reg; 
end
 
assign mon_stop = stop_reg & ~stop_dly; 

//--------------------------------------------------------------------------------
// Packet counters
//--------------------------------------------------------------------------------

always @ (posedge clk or posedge reset)
begin
    if(reset) 
    begin
        good_pkts <= 32'h0;
        bad_pkts <= 32'h0;
    end
    else
        if(mon_init) 
        begin
            good_pkts <= 32'h0;
            bad_pkts <= 32'h0;
        end
        else
            if (mon_active)
                begin
                    if (crcvalid & ~crcbad) 
                        good_pkts <= good_pkts + 32'h1;
                    if (crcvalid & crcbad) 
                        bad_pkts <= bad_pkts + 32'h1;
                end
end

//--------------------------------------------------------------------------------
// Monitor FSM 
//--------------------------------------------------------------------------------

localparam MONIDLE = 2'd0; 
localparam MONACTIVE = 2'd1;
localparam MONDONE = 2'd2;
 
reg[1:0] monstate, next_monstate;

always@(posedge clk or posedge reset)
begin
    if (reset) 
        monstate <= MONDONE;
    else 
        monstate <= next_monstate;
end

always@(*)
begin
	next_monstate = monstate;
	case(monstate)
        MONIDLE: if (avalon_st_rx_valid & avalon_st_rx_sop) next_monstate = MONACTIVE;
        MONACTIVE: if (mon_done) next_monstate = MONDONE;
        MONDONE: if (mon_init) next_monstate = MONIDLE;
	    default: next_monstate = MONDONE;
	endcase
end

//--------------------------------------------------------------------------------
// Capturing DST_ADDR, SRC_ADDR and LENGTH
//--------------------------------------------------------------------------------

reg second_qword;

always@(posedge clk)
begin
    if (avalon_st_rx_valid & avalon_st_rx_sop)
    begin
        rcvd_dst_addr[47: 0] <= avalon_st_rx_data[63:16];
        rcvd_src_addr[47:32] <= avalon_st_rx_data[15: 0];
        second_qword <= 1'b1;
    end

    if (avalon_st_rx_valid & second_qword)
    begin
        rcvd_src_addr[31:0] <= avalon_st_rx_data[63:32];
        rcvd_pkt_len [15:0] <= avalon_st_rx_data[31:16];
        second_qword <= 1'b0;
    end
end

//--------------------------------------------------------------------------------
// byte_count holds the number of bytes received in the payload
//--------------------------------------------------------------------------------

always @ (posedge clk)
begin
    if (second_qword) 
        byte_count <= 16'h2;    // seq_num in the 2nd QWORD has 2 bytes
    else 
        if (mon_active && avalon_st_rx_valid)
    	    if (avalon_st_rx_eop)
                case (avalon_st_rx_empty)
                    3'b000:  byte_count<= byte_count + 16'h8;
                    3'b001:  byte_count<= byte_count + 16'h7;
                    3'b010:  byte_count<= byte_count + 16'h6;
                    3'b011:  byte_count<= byte_count + 16'h5;
                    3'b100:  byte_count<= byte_count + 16'h4;
                    3'b101:  byte_count<= byte_count + 16'h3;
                    3'b110:  byte_count<= byte_count + 16'h2;
                    3'b111:  byte_count<= byte_count + 16'h1;
                    default: byte_count<= byte_count + 16'h8;
                endcase
            else 
                byte_count <= byte_count + 16'h8;
end
 
//--------------------------------------------------------------------------------
// AVL-ST ready signal generation
//--------------------------------------------------------------------------------

always @ (posedge reset or posedge clk)
begin
    if (reset) 
        avalon_st_rx_ready <= 1'b0;
    else 
        avalon_st_rx_ready <= 1'b1;
end

//--------------------------------------------------------------------------------
// AVL-MM wait request signal generation
//--------------------------------------------------------------------------------

reg rddly, wrdly;

always@(posedge clk or posedge reset)
begin
    if(reset) 
	begin 
	    wrdly <= 1'b0; 
	    rddly <= 1'b0; 
	end 
    else 
	begin 
	    wrdly <= avalon_mm_write; 
	    rddly <= avalon_mm_read; 
	end 
end
 
wire wredge = avalon_mm_write& ~wrdly;
wire rdedge = avalon_mm_read & ~rddly;

// this module is done with AVL-MM transaction when this goes down
assign avalon_mm_waitrequest = (wredge|rdedge); 

//--------------------------------------------------------------------------------
// CRC checking
//--------------------------------------------------------------------------------

crc32_chk #(64,3)
	//.DATA_WIDTH (64),
    //.EMPTY_WIDTH (3),
	//.CRC_WIDTH	(32),
    //.REVERSE_DATA (1),
    //.OPERATION_MODE (1)
crc32_chk_inst (
	.CLK        (clk),
	.RESET_N   (~reset),
	.AVST_VALID   (avalon_st_rx_valid),
	.AVST_SOP      (avalon_st_rx_sop),
	.AVST_DATA    (avalon_st_rx_data),
	.AVST_EOP     (avalon_st_rx_eop),
	.AVST_EMPTY    (avalon_st_rx_empty),
	.CRC_VALID      (crcvalid),
	.CRC_BAD	   (crcbad),
	.AVST_READY	()
);

//--------------------------------------------------------------------------------
// Evaluating error conditions
//--------------------------------------------------------------------------------

always@(posedge clk or posedge reset)
begin
    if (reset)
        eval_errors <= 1'b0;
    else
        if (mon_active & avalon_st_rx_valid & avalon_st_rx_eop)
            eval_errors <= 1'b1;
        else
            eval_errors <= 1'b0;
end
 
always@(posedge clk or posedge reset)
begin
    if (reset)
    begin
        pkt_len_err  <= 1'b0;
        src_addr_err <= 1'b0;
        dst_addr_err <= 1'b0;
    end
    else
        if (mon_init)
        begin
            pkt_len_err  <= 1'b0;
            src_addr_err <= 1'b0;
            dst_addr_err <= 1'b0;
        end
        else
            if (eval_errors)
            begin
                if (rcvd_dst_addr != dst_addr)
                    dst_addr_err <= 1'b1;
                if (rcvd_src_addr != src_addr)
                    src_addr_err <= 1'b1;
                if (rcvd_pkt_len != byte_count)
                    pkt_len_err <= 1'b1;
            end
end

//--------------------------------------------------------------------------------
// Monitor status signals
//--------------------------------------------------------------------------------
 
always@(posedge clk or posedge reset)
begin
    if (reset)
    begin
        mon_error <= 1'b0;
        mon_done <= 1'b1; 
    end
    else
        if (mon_init)
        begin
            mon_error <= 1'b0;
            mon_done <= 1'b0; 
        end
        else
        begin
            if (mon_done && (|bad_pkts)) 
                mon_error <= 1'b1;
            if (mon_stop | (~continuous & ((good_pkts + bad_pkts) == number_pkt)))  
                mon_done <= 1'b1;
        end
end

assign mon_active = (monstate == MONACTIVE);
assign gen_lpbk = 1'b0;

endmodule
