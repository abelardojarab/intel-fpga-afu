// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1 ps / 1 ps

module alt_e100s10_adapt_pma (
  input  wire           mgmt_clk,       // managemnt/reconfig clock
  input  wire           mgmt_reset,     // managemnt/reconfig reset
   
  input  wire [3:0]     rx_is_lockedtodata, // PLL rx_is_lockedtodata
  output reg            adapting,           // Programming adaption mode
     
  output reg             rcfg_write,    // AVMM write
  output reg             rcfg_read,     // AVMM read
  output reg  [12:0]     rcfg_address,  // AVMM address
  output reg  [31:0]     rcfg_wrdata,   // AVMM write data
  input  wire [31:0]     rcfg_rddata,   // AVMM read data
  input  wire            rcfg_wtrqst    // AVMM wait request
  );

//============================================================================
//  input registers to sync locked input
//============================================================================
    wire locked_sync;

    alt_e100s10_synchronizer s (
        .clk(mgmt_clk),
        .din((&rx_is_lockedtodata)),
        .dout(locked_sync)
    );
    defparam s .WIDTH = 1;

//============================================================================
//  Counter to wait to start the recalibration
//  also has hysteresis in case lock chatters
//  speed up mode for simulation
//============================================================================
`ifdef ALTERA_RESERVED_QIS   // HW mode, full lengh counter
  reg [9:0] cnt_lock;
  reg       cnt_max;

  always @(posedge mgmt_clk)
    if (mgmt_reset) begin
      cnt_max  <= 1'b0;
      cnt_lock <= 10'b0;
    end else  begin
      cnt_max <= (cnt_lock == 10'h3ff);
      if      (~locked_sync)         cnt_lock <= 10'd0;
      else if (cnt_lock == 10'h3ff)  cnt_lock <= cnt_lock;
      else                           cnt_lock <= cnt_lock + 1'b1;
    end
`else     // Sim mode, shortened counter
  reg [2:0] cnt_lock;
  reg       cnt_max;

  always @(posedge mgmt_clk)
    if (mgmt_reset) begin
      cnt_max  <= 1'b0;
      cnt_lock <= 3'b0;
    end else  begin
      cnt_max <= (cnt_lock == 3'h7);
      if      (~locked_sync)   cnt_lock <= 3'd0;
      else if (cnt_lock == 3'h7)  cnt_lock <= cnt_lock;
      else                        cnt_lock <= cnt_lock + 1'b1;
    end
`endif // QIS 

//=======================================================================================
//  Adaption State Machine
//      wait for locktodata to be active for 10us
//      Read-modify-write bit 0 to 0x1 in address 0x14c (channel 0)to request Adaptation
//      Read-modify-write bit 0 to 0x1 in address 0x94c (channel 1)to request Adaptation
//      Read-modify-write bit 0 to 0x1 in address 0x114c (channel 2)to request Adaptation
//      Read-modify-write bit 0 to 0x1 in address 0x194c (channel 3)to request Adaptation
//      Done until locktodata deasserted or reset
//=======================================================================================
  localparam [4:0] RCL_IDLE    = 5'd0;
  localparam [4:0] RCL_RD0     = 5'd1;
  localparam [4:0] RCL_WR0_1   = 5'd2;
  localparam [4:0] RCL_RD1     = 5'd3;
  localparam [4:0] RCL_WR1_1   = 5'd4;
  localparam [4:0] RCL_RD2     = 5'd5;
  localparam [4:0] RCL_WR2_1   = 5'd6;
  localparam [4:0] RCL_RD3     = 5'd7;
  localparam [4:0] RCL_WR3_1   = 5'd8;
  localparam [4:0] RCL_RD4     = 5'd9;
  localparam [4:0] RCL_WR4_1   = 5'd10;
  localparam [4:0] RCL_RD5     = 5'd11;
  localparam [4:0] RCL_WR5_1   = 5'd12;
  localparam [4:0] RCL_RD6     = 5'd13;
  localparam [4:0] RCL_WR6_1   = 5'd14;
  localparam [4:0] RCL_RD7     = 5'd15;
  localparam [4:0] RCL_WR7_1   = 5'd16;
  localparam [4:0] RCL_RD8_0   = 5'd17;
  localparam [4:0] RCL_RD8_1   = 5'd18;
  localparam [4:0] RCL_WR8_1   = 5'd19;
  localparam [4:0] RCL_RD9_0   = 5'd20;
  localparam [4:0] RCL_RD9_1   = 5'd21;
  localparam [4:0] RCL_WR9_1   = 5'd22;
  localparam [4:0] RCL_RDA_0   = 5'd23;
  localparam [4:0] RCL_RDA_1   = 5'd24;
  localparam [4:0] RCL_WRA_1   = 5'd25;
  localparam [4:0] RCL_RDB_0   = 5'd26;
  localparam [4:0] RCL_RDB_1   = 5'd27;
  localparam [4:0] RCL_WRB_1   = 5'd28;
  localparam [4:0] RCL_DONE    = 5'd29;

  localparam [12:0] CH0_ICFGA_ADDR = 13'h0000; // internal configuration bus arbitration register - ln0
  localparam [12:0] CH1_ICFGA_ADDR = 13'h0800;
  localparam [12:0] CH2_ICFGA_ADDR = 13'h1000;
  localparam [12:0] CH3_ICFGA_ADDR = 13'h1800;

  localparam [12:0] CH0_CALIB_ADDR = 13'h0100; // bit 0 is calibration - ln0
  localparam [12:0] CH1_CALIB_ADDR = 13'h0900;
  localparam [12:0] CH2_CALIB_ADDR = 13'h1100;
  localparam [12:0] CH3_CALIB_ADDR = 13'h1900;

  localparam [12:0] CH0_ADAPT_ADDR = 13'h014c;
  localparam [12:0] CH1_ADAPT_ADDR = 13'h094c;
  localparam [12:0] CH2_ADAPT_ADDR = 13'h114c;
  localparam [12:0] CH3_ADAPT_ADDR = 13'h194c;

  reg [4:0]  adapt_state;
  reg [4:0]  adapt_nxt_st;
  reg        rcfg_rddata_p1;

    // state register
  always @(posedge mgmt_clk)
   if (mgmt_reset)  adapt_state <= RCL_IDLE;
   else             adapt_state <= adapt_nxt_st;

    // next state logic
  always @(*) begin
    adapt_nxt_st = adapt_state;
    case(adapt_state)
      RCL_IDLE  : if (cnt_max)       adapt_nxt_st = RCL_RD4;

      RCL_RD4   : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_WR4_1; //rd addr 0 and wr x2
      RCL_WR4_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RD5;
      RCL_RD5   : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_WR5_1;
      RCL_WR5_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RD6;
      RCL_RD6   : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_WR6_1;
      RCL_WR6_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RD7;
      RCL_RD7   : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_WR7_1;
      RCL_WR7_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RD0;

      RCL_RD0   : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_WR0_1;
      RCL_WR0_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RD1;
      RCL_RD1   : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_WR1_1;
      RCL_WR1_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RD2;
      RCL_RD2   : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_WR2_1;
      RCL_WR2_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RD3;
      RCL_RD3   : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_WR3_1;
      RCL_WR3_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RD8_0;

      RCL_RD8_0 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RD8_1; //rd addr x100 and addr 0, wr addr 0
      RCL_RD8_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_WR8_1;
      RCL_WR8_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RD9_0;
      RCL_RD9_0 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RD9_1;
      RCL_RD9_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_WR9_1;
      RCL_WR9_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RDA_0;
      RCL_RDA_0 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RDA_1;
      RCL_RDA_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_WRA_1;
      RCL_WRA_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RDB_0;
      RCL_RDB_0 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_RDB_1;
      RCL_RDB_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_WRB_1;
      RCL_WRB_1 : if (~rcfg_wtrqst)  adapt_nxt_st = RCL_DONE;

      RCL_DONE  : if (~cnt_max)      adapt_nxt_st = RCL_IDLE;
      default   : adapt_nxt_st = adapt_state;
    endcase
  end

//============================================================================
//  Generate DPRIO signals for the PLL reconfig Interface
//============================================================================
  //recalibration is finished
  always @(posedge mgmt_clk) begin
    if (mgmt_reset)
      adapting  <= 1'b0;
    else if(adapt_nxt_st == RCL_IDLE || adapt_nxt_st == RCL_DONE)
      adapting  <= 1'b0;
    else
      adapting  <= 1'b1;
  end

  //DPRIO read
  always @(posedge mgmt_clk) begin
    if (mgmt_reset)
      rcfg_read  <= 1'b0;
    else if ((adapt_nxt_st == RCL_RD0) || (adapt_nxt_st == RCL_RD1) || 
             (adapt_nxt_st == RCL_RD2) || (adapt_nxt_st == RCL_RD3) ||
             (adapt_nxt_st == RCL_RD4) || (adapt_nxt_st == RCL_RD5) || //rd addr 0
             (adapt_nxt_st == RCL_RD6) || (adapt_nxt_st == RCL_RD7) ||
             (adapt_nxt_st == RCL_RD8_0) || (adapt_nxt_st == RCL_RD8_1) || //rd addr 100 and rx addr 0
             (adapt_nxt_st == RCL_RD9_0) || (adapt_nxt_st == RCL_RD9_1) ||
             (adapt_nxt_st == RCL_RDA_0) || (adapt_nxt_st == RCL_RDA_1) ||
             (adapt_nxt_st == RCL_RDB_0) || (adapt_nxt_st == RCL_RDB_1)
            )
      rcfg_read  <= 1'b1;
    else
      rcfg_read  <= 1'b0;
  end

  //DPRIO write
  always @(posedge mgmt_clk) begin
    if (mgmt_reset)
      rcfg_write  <= 1'b0;
    else if ((adapt_nxt_st == RCL_WR0_1) || (adapt_nxt_st == RCL_WR1_1) ||
             (adapt_nxt_st == RCL_WR2_1) || (adapt_nxt_st == RCL_WR3_1) ||
             (adapt_nxt_st == RCL_WR4_1) || (adapt_nxt_st == RCL_WR5_1) ||
             (adapt_nxt_st == RCL_WR6_1) || (adapt_nxt_st == RCL_WR7_1) ||
             (adapt_nxt_st == RCL_WR8_1) || (adapt_nxt_st == RCL_WR9_1) ||
             (adapt_nxt_st == RCL_WRA_1) || (adapt_nxt_st == RCL_WRB_1) )
      rcfg_write  <= 1'b1;
    else
      rcfg_write  <= 1'b0;
  end

  //DPRIO address
  always @(posedge mgmt_clk) begin
    if (mgmt_reset)
      rcfg_address <= CH0_ADAPT_ADDR;
    else if((adapt_nxt_st == RCL_RD1) || (adapt_nxt_st == RCL_WR1_1))
      rcfg_address <= CH1_ADAPT_ADDR;
    else if((adapt_nxt_st == RCL_RD2) || (adapt_nxt_st == RCL_WR2_1))
      rcfg_address <= CH2_ADAPT_ADDR;
    else if((adapt_nxt_st == RCL_RD3) || (adapt_nxt_st == RCL_WR3_1))
      rcfg_address <= CH3_ADAPT_ADDR;

    else if((adapt_nxt_st == RCL_RD4) || (adapt_nxt_st == RCL_WR4_1) || (adapt_nxt_st == RCL_RD8_1) || (adapt_nxt_st == RCL_WR8_1))
      rcfg_address <= CH0_ICFGA_ADDR;
    else if((adapt_nxt_st == RCL_RD5) || (adapt_nxt_st == RCL_WR5_1) || (adapt_nxt_st == RCL_RD9_1) || (adapt_nxt_st == RCL_WR9_1))
      rcfg_address <= CH1_ICFGA_ADDR;
    else if((adapt_nxt_st == RCL_RD6) || (adapt_nxt_st == RCL_WR6_1) || (adapt_nxt_st == RCL_RDA_1) || (adapt_nxt_st == RCL_WRA_1))
      rcfg_address <= CH2_ICFGA_ADDR;
    else if((adapt_nxt_st == RCL_RD7) || (adapt_nxt_st == RCL_WR7_1) || (adapt_nxt_st == RCL_RDB_1) || (adapt_nxt_st == RCL_WRB_1))
      rcfg_address <= CH3_ICFGA_ADDR;

    else if(adapt_nxt_st == RCL_RD8_0 )
      rcfg_address <= CH0_CALIB_ADDR;
    else if(adapt_nxt_st == RCL_RD9_0 )
      rcfg_address <= CH1_CALIB_ADDR;
    else if(adapt_nxt_st == RCL_RDA_0 )
      rcfg_address <= CH2_CALIB_ADDR;
    else if(adapt_nxt_st == RCL_RDB_0 )
      rcfg_address <= CH3_CALIB_ADDR;

    else
      rcfg_address <= CH0_ADAPT_ADDR;
  end

  always @(posedge mgmt_clk) begin
    if (mgmt_reset)
      rcfg_rddata_p1 <= 1'b0;
    else if ((adapt_nxt_st == RCL_RD8_0) || (adapt_nxt_st == RCL_RD9_0) ||
             (adapt_nxt_st == RCL_RDA_0) || (adapt_nxt_st == RCL_RDB_0) )
      rcfg_rddata_p1 <= rcfg_rddata[0];  //add 0x100 data[0]=1 means rx calibration enable is ON
  end

  //DPRIO writedata
  always @(posedge mgmt_clk) begin
    if (mgmt_reset)
      rcfg_wrdata <= 32'b0;
    else if (adapt_nxt_st == RCL_WR0_1 || adapt_nxt_st == RCL_WR1_1 ||
             adapt_nxt_st == RCL_WR2_1 || adapt_nxt_st == RCL_WR3_1 )
      rcfg_wrdata <= rcfg_rddata | 32'h01;
    else if (adapt_nxt_st == RCL_WR4_1 || adapt_nxt_st == RCL_WR5_1 ||
             adapt_nxt_st == RCL_WR6_1 || adapt_nxt_st == RCL_WR7_1 )
      rcfg_wrdata <= 32'h2; //rcfg_rddata | 32'h02; //question: write x2 or need to read modify write?
    else if (adapt_nxt_st == RCL_WR8_1 || adapt_nxt_st == RCL_WR9_1 ||
             adapt_nxt_st == RCL_WRA_1 || adapt_nxt_st == RCL_WRB_1 )
      rcfg_wrdata <= rcfg_rddata | {30'h0,~rcfg_rddata_p1,1'b1};//cal_enb=1, need to write 'b01(addr=x0), cal_enb=0 need to write 'b11(addr=x0)
    else
      rcfg_wrdata <= 32'b0;
  end

endmodule // alt_e100s10s10_adapt_pma
