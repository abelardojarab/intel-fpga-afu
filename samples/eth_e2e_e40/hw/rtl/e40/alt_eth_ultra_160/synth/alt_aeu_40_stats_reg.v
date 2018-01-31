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


// ___________________________________________________________________________
// $Id: //acds/prototype/alt_eth_ultra/ultra_16.0_intel_mcp/ip/ethernet/alt_eth_ultra/40g/rtl/mac/alt_aeu_40_stats_reg.v#2 $
// $Revision: #2 $
// $Date: 2016/10/21 $
// $Author: ktaylor $
// ___________________________________________________________________________
// ajay dubey 07.15.2013

 module alt_aeu_40_stats_reg 
        #(
         parameter BASE  = 05  
        ,parameter REVID = 32'h04012014
        ,parameter NUMSTATS  = 32  
        ,parameter COUNTWIDTH = 16  
        ,parameter NUMCOUNTS  = 02  
        ,parameter ACCUM_WIDTH= 32 
        ,parameter TARGET_CHIP  = 2  
         )(
         input wire clk
        ,input wire reset         
        ,input wire[NUMSTATS-1:0] in_stats        
        ,input wire[COUNTWIDTH*NUMCOUNTS-1:0] in_counts   

        ,input wire clk_csr 
        ,input wire reset_csr 
        ,input wire serif_master_dout 
        ,output wire serif_slave_dout 
        );

// note - i'm skeptical reset_csr is properly hardened in the design above here
//  redoing the synchronization here to be safe
wire init_regs;
sync_regs_m2 ss0 (
	.clk(clk_csr),
	.din(reset_csr),
	.dout(init_regs)
);
defparam ss0 .WIDTH = 1;

// ____________________________________________________________________________
 //  local parameters
 // ____________________________________________________________________________

 localparam INC_WIDTH  = 1  ;   // width of input signals per channel
 localparam ADDRSIZE  = 8   ;   // address size enough to access upto 32 registers 64 in size

 localparam 
            ADDR_REVID          = 8'd64,
            ADDR_SCRATCH        = 8'd65,
            ADDR_NAME_0         = 8'd66,
            ADDR_NAME_1         = 8'd67,
            ADDR_NAME_2         = 8'd68,
            ADDR_CFG            = 8'd69,
            ADDR_STATUS         = 8'd70;
 // ____________________________________________________________________________
 //  serial interface slave     
 // ____________________________________________________________________________

 wire read;
 wire write;
 wire [31:0]writedata;
 wire [ADDRSIZE-1:0]address;
 wire [31:0]readdata_ram_0;
 wire [31:0]readdata_ram_1;
 wire [31:0]readdata_ram_3;
 reg readdatavalid=0;
 reg[31:0]readdata= 0; 
 wire sync_reset, sw_reset_pulse, clear_parity_error;
 wire parity_error_ram_0, parity_error_ram_1, parity_error_ram_3;
/*
 serif_slave_async #(
         .ADDR_PAGE     (BASE)
        ,.TARGET_CHIP   (TARGET_CHIP)
 )sifsa_stats (
         .aclr          (reset_csr)
        ,.sclk          (clk_csr)
        ,.din           (serif_master_dout)
        ,.dout          (serif_slave_dout)

        ,.bclk          (clk)
        ,.wr            (write)
        ,.rd            (read)
        ,.addr          (address)
        ,.wdata         (writedata)
        ,.rdata         (readdata)
        ,.rdata_valid   (readdatavalid)
        );
*/

 serif_slave #(
         .ADDR_PAGE     (BASE)
        ,.TARGET_CHIP   (TARGET_CHIP)
 )sifsa_stats (
    .clk(clk_csr),
    .sclr(init_regs),
    .din(serif_master_dout),
    .dout(serif_slave_dout),

    .wr(write),
    .rd(read),
    .addr(address),
    .wdata(writedata),
    .rdata(readdata),
    .rdata_valid(readdatavalid)
);



  reg pipe0_read; always@(posedge clk) pipe0_read <= read;
  reg pipe1_read; always@(posedge clk) pipe1_read <= pipe0_read;
  //reg pipe2_read; always@(posedge clk) pipe2_read <= pipe1_read;
  reg[ADDRSIZE-1:0] pipe0_address; always@(posedge clk) pipe0_address <= address;
  reg[ADDRSIZE-1:0] pipe1_address; always@(posedge clk) pipe1_address <= pipe0_address;
  //reg[ADDRSIZE-1:0] pipe2_address; always@(posedge clk) pipe2_address <= pipe1_address;
 // ____________________________________________________________________________
 //     16x64 ram instances
 // ____________________________________________________________________________
  
  wire shadow_req, grant_ram_0, grant_ram_1, reset_pulse;
  wire[15:0] inc_in_0 = in_stats[15:0];
  wire[15:0] inc_in_1 = { {(32-NUMSTATS){1'b0}}, in_stats[NUMSTATS-1:16]};
  stat_ram_16x64b#(
         .INC_WIDTH     (INC_WIDTH)
        ,.ACCUM_WIDTH   (ACCUM_WIDTH)
        ,.TARGET_CHIP   (TARGET_CHIP)
  )regs_0_14            (
         .clk           (clk )
        ,.sclr          (sync_reset )
        ,.incs          (inc_in_0   ) 

        ,.rd_addr       (pipe1_address[4:0])
        ,.rd_value      (readdata_ram_0)
        ,.shadow_req    (shadow_req)
        ,.shadow_grant  (grant_ram_0)
                
        ,.sclr_parity_err(sync_reset|clear_parity_error)
        ,.parity_err    (parity_error_ram_0)    //sticky        
   );


  stat_ram_16x64b#(
         .INC_WIDTH     (INC_WIDTH)
        ,.ACCUM_WIDTH   (ACCUM_WIDTH)
        ,.TARGET_CHIP   (TARGET_CHIP)
  )regs_15_31           (
         .clk           (clk)
        ,.sclr          (sync_reset)
        ,.incs          (inc_in_1  ) 

        ,.rd_addr       (pipe1_address[4:0])
        ,.rd_value      (readdata_ram_1)
        ,.shadow_req    (shadow_req)
        ,.shadow_grant  (grant_ram_1)
                
        ,.sclr_parity_err(sync_reset|clear_parity_error)
        ,.parity_err    (parity_error_ram_1)    //sticky        
   );

  wire[16*16-1:0] count_in_0 = { {(16-NUMCOUNTS){16'd0}}, in_counts[NUMCOUNTS*16-1:0]};
  wire grant_ram_3;
  stat_ram_16x64b#(
         .INC_WIDTH     (16)
        ,.ACCUM_WIDTH   (ACCUM_WIDTH)
        ,.TARGET_CHIP   (TARGET_CHIP)
  )regs_32_47           (
         .clk           (clk)
        ,.sclr          (sync_reset)
        ,.incs          (count_in_0) 

        ,.rd_addr       (pipe1_address[4:0])
        ,.rd_value      (readdata_ram_3)
        ,.shadow_req    (shadow_req)
        ,.shadow_grant  (grant_ram_3)
                
        ,.sclr_parity_err(sync_reset|clear_parity_error)
        ,.parity_err    (parity_error_ram_3)    //sticky        
   );

 // debug lines
 // synthesis translate_off
 reg[63:0] count_pld = 0; always@(posedge clk) if (sync_reset) count_pld <= 0; else if (|count_in_0[15:0] === 1'b1)count_pld <= count_pld + count_in_0[15:0] ; 
 // synthesis translate_on

 // ____________________________________________________________________________
 //     stats config & Status Register
 // ____________________________________________________________________________
  reg[2:0] sync_ff; always@(posedge clk or posedge reset) if (reset) sync_ff <= 3'b111; else sync_ff <= {sync_ff[1:0], 1'b0};
  reg sync_reset_pulse=0 /* synthesis preserve */ ; always@(posedge clk) if (sync_ff[2]) sync_reset_pulse <= 1'b1; else if (sync_reset_pulse) sync_reset_pulse <= 1'b0;

  wire[31:0] status = {30'd0,(grant_ram_0 & grant_ram_1 & grant_ram_3), (parity_error_ram_0 | parity_error_ram_1 | parity_error_ram_3)};
  reg [15:0] cfg = 0;
  //assign shadow_req = cfg[2];
  //assign clear_parity_error = cfg[1];
  //assign sw_reset_pulse = cfg[0];

  sync_regs srx (
        .clk (clk),
        .din (cfg[2:0]),
        .dout ({shadow_req, clear_parity_error, sw_reset_pulse})
  );
  defparam srx .WIDTH = 3;

  assign reset_pulse = sync_reset_pulse | sw_reset_pulse;
 
  reg[31:0]  scratch = BASE;  
  wire [12*8-1:0] ip_name = "040gMacStats";

  always @(posedge clk_csr) begin
      if (write && (address == ADDR_SCRATCH)) begin scratch <= writedata[31:0]; end
      if (write && (address == ADDR_CFG)) begin cfg[2] <= writedata[2]; cfg[15:3] <= writedata[15:3]; end
      if (cfg[1]) cfg[1] <= 1'b0; else if (write && (address == ADDR_CFG)) cfg[1] <= writedata[1];
      if (cfg[0]) cfg[0] <= 1'b0; else if (write && (address == ADDR_CFG)) cfg[0] <= writedata[0];

      if (init_regs) begin
          cfg <= 16'b0;
      end
  end


  reg read_bank_0=0; always @(posedge clk) read_bank_0 <= pipe1_read && (pipe1_address <= 31);
  reg read_bank_1=0; always @(posedge clk) read_bank_1 <= pipe1_read && (pipe1_address >  31) && (pipe1_address <= 63);
  reg read_bank_3=0; always @(posedge clk) read_bank_3 <= pipe1_read && (pipe1_address >  95) && (pipe1_address <= 127);

  reg read_r1, read_r2, read_r3, read_r4, read_r5;
  reg [31:0]  readdata_ram;
  wire [31:0] readdata_ram_csr;

  always @(posedge clk) 
    begin
        if      (read_bank_0) readdata_ram <= readdata_ram_0; // 32-locations
        else if (read_bank_1) readdata_ram <= readdata_ram_1; // 32-locations
        else if (read_bank_3) readdata_ram <= readdata_ram_3; // 32-locations
    end

sync_regs sr1 (
        .clk (clk_csr),
        .din (readdata_ram),
        .dout (readdata_ram_csr)
);
defparam sr1 .WIDTH = 32;

  
  reg addr_bank_01, addr_bank_3;
  always @(posedge clk_csr) addr_bank_01 <= (address < 64);
  always @(posedge clk_csr) addr_bank_3  <= (address > 95 && address <= 127);

  wire [31:0] readdata_x;
  mx8r mx8r(
      .clk  (clk_csr),
      .din  ({32'hdeadc0de, status, {16'b0, cfg}, ip_name[31:0], ip_name[63:32], ip_name[95:64], scratch, REVID}),
      .sel  (address[2:0]),
      .dout (readdata_x)
  );
  defparam mx8r .WIDTH = 32;

  always @(posedge clk_csr) read_r1 <= read;
  always @(posedge clk_csr) read_r2 <= read_r1;
  always @(posedge clk_csr) read_r3 <= read_r2;
  always @(posedge clk_csr) read_r4 <= read_r3;
  always @(posedge clk_csr) read_r5 <= read_r4;

  always @(posedge clk_csr)
    begin
        readdatavalid <= read_r5;
        if (addr_bank_01 || addr_bank_3) readdata <= readdata_ram_csr;
        else                             readdata <= readdata_x;
    end

/*
  always @(posedge clk_csr) 
    begin
        readdatavalid <= read_r5;
        if (addr_bank_2) 
                case(address)
                   ADDR_SCRATCH : readdata <= scratch;
                   ADDR_REVID   : readdata <= REVID;
                   ADDR_NAME_0  : readdata <= ip_name[95:64];
                   ADDR_NAME_1  : readdata <= ip_name[63:32] ;
                   ADDR_NAME_2  : readdata <= ip_name[31: 0];
                   ADDR_CFG     : readdata <= cfg;
                   ADDR_STATUS  : readdata <= status;
                   default      : readdata <= 32'hdeadc0de;
                endcase
        else readdata <= readdata_ram_csr; // 32-locations
    end
*/


/*
  always @(posedge clk) 
    begin
        readdatavalid <= pipe2_read;
        if      (read_bank_0) readdata <= readdata_ram_0; // 32-locations
        else if (read_bank_1) readdata <= readdata_ram_1; // 32-locations
        else if (read_bank_3) readdata <= readdata_ram_3; // 32-locations
        else if (read_bank_2)
                case(pipe1_address)
                   ADDR_SCRATCH : readdata <= scratch;
                   ADDR_REVID   : readdata <= REVID;
                   ADDR_NAME_0  : readdata <= ip_name[31:0];
                   ADDR_NAME_1  : readdata <= ip_name[63:32] ;
                   ADDR_NAME_2  : readdata <= ip_name[95:64];
                   ADDR_CFG     : readdata <= cfg;
                   ADDR_STATUS  : readdata <= status;
                   default      : readdata <= 32'hdeadc0de;
                endcase
    end
*/
 // ____________________________________________________________________________
 //     reset control state machine     
 // ____________________________________________________________________________
  localparam NORMAL = 1'b0, RESET = 1'b1;
  reg state=NORMAL;
  reg[5:0] count = 6'd0;
  always@(posedge clk) 
      begin
        case(state)
                NORMAL: if (reset_pulse) begin count <= 6'd32; state <= RESET; end 
                        else begin count <= 6'd0; state <= NORMAL;end
                RESET : if (reset_pulse) begin count <= 6'd32; state <= RESET; end      
                        else if (~|count) begin count <= 6'd0; state <= NORMAL;end 
                        else begin count <= count - 6'd1; state <= RESET; end
                default:begin count <= count; state <= NORMAL; end
        endcase
      end
  assign sync_reset = (state == RESET); 

 // ____________________________________________________________________________
 //     debug signal
 // ____________________________________________________________________________

endmodule

