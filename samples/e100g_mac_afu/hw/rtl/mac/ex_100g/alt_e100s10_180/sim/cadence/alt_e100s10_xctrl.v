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

// X-ctrl with backtrack
// Module to figure MUX N/W programming for the CLOS network controller
// Faisal 02/01/2017


module alt_e100s10_xctrl #(

    parameter   VLANES = 20,
    parameter   SIM_EMULATE = 1'b0
)(

    input                           clk,        // pragma clock_port
    input                           reset,

    input   [VLANES*5-1:0]          vtag,
    input   [VLANES-1:0]            vt_valid,

    output  [20*2+20*3+20*2-1:0]    sel, // lx-mux-boxes*individual-mux-selsize*muxes
    output   reg [2:0]                done  /* synthesis preserve_syn_only */

);

// l1: {{A0,A1,A2,A3}, {B0,B1,B2,B3,B4}...{D0...D4}} // 4x5
// // l2: {{A0,B0,C0,D0,E0}, {A1,B1,C1,D1,E1} ... } // 5x4


// Control where we are in reordering. 
// Shift the vtag mask appropriately
// call it done

reg [4:0]   vcnt;
reg         vlnxt;
reg [VLANES*5-1:0]  vtag_r;
reg [VLANES*5-1:0]  vtag_bf;
reg [VLANES-1:0]    vt_valid_r;
reg [3:0]           vt_ready_i;
reg                 vt_ready;


reg [10:0]   state;
localparam  M_INIT          =   11'b00000000001; // 1
localparam  V_NXT           =   11'b00000000010; // 2
localparam  EVALUATE        =   11'b00000000100; // 4
localparam  BACKTRACK       =   11'b00000001000; // 8
localparam  BT_WR_MASKS     =   11'b00000010000; // 10
localparam  BT_WR_MASKS2    =   11'b00000100000; // 20
localparam  BT_WR_MASKS3    =   11'b00001000000; // 40
localparam  WR_MUXES        =   11'b00010000000; // 80
localparam  WR_MASKS        =   11'b00100000000; // 100
localparam  READ            =   11'b01000000000; // 200
localparam  IDLE            =   11'b10000000000; // 400


reg done_wr;    // done with Vlane processing
always @(posedge clk) begin
    if (reset)  done_wr <= 1'b0;
    else done_wr    <=  (vcnt == 5'd20);
end

reg vlnxt_e1;
always @(posedge clk) begin
    vlnxt_e1    <= (state == V_NXT) & (~done_wr) & vt_ready ;  
    vlnxt       <= vlnxt_e1;
end

always @(posedge clk) begin
    if (reset) begin
        vcnt   <=  2'h0;
    end else if (state == WR_MASKS) begin
        vcnt   <=  vcnt + 1'b1;
    end
    else if (state == BACKTRACK) 
        vcnt    <=  vcnt - 1'b1;
end



always  @(posedge clk) begin
    if (reset) begin
        vt_ready_i  <=  4'b0000;
        vt_ready    <=  1'b0;
        vt_valid_r  <=  {VLANES{1'b0}};
    end else begin
        vt_valid_r  <=  vt_valid_r | vt_valid;

        vt_ready_i[0]  <=  &vt_valid_r[0+:6];
        vt_ready_i[1]  <=  &vt_valid_r[6+:6];
        vt_ready_i[2]  <=  &vt_valid_r[12+:6];
        vt_ready_i[3]  <=  &vt_valid_r[18+:2];
        vt_ready       <=  vt_ready | (&vt_ready_i);
    end
end

reg [VLANES*5-1:0]  vtag_i;
integer j;
always @(posedge clk) begin
    for (j=0; j<20; j=j+1) begin
        vtag_i[5*j+:5]  <=  vtag[5*j+:5] & {5{vt_valid[j]}};
    end
end


always @(posedge clk) begin
    if (reset)
        vtag_r  <=  {VLANES*5{1'b0}}; 
    else if (state == WR_MASKS)
        {vtag_r[(VLANES-1)*5-1:0], vtag_bf}  <=  {vtag_r, vtag_bf} >> 5'h5 ;
    else if (state == BACKTRACK)
        {vtag_r, vtag_bf}  <=  {vtag_r, vtag_bf} << 5'h5;
    else if (~vt_ready)
        vtag_r  <=  vtag_r  | vtag_i; 
end





// evaluation
// figure out which l3 it will go - l3-mux <- vtag & 11100
// l1-mux <- l1[4:0]
// l2-mux <- l2 >> (5*x), where x is l3-mux
// Available switches: swtch <- l1-mux & l2-mux
// shift availability-vector till first 1: s_shft

wire [2:0]  l1_mux =    vcnt[4:2];  // ip stage mux
wire [2:0]  l3_mux =    vtag_r[4:2]; // output stage mux
wire [4:0]  vlane  =    vtag_r[4:0];

reg l1_rst;
always @(posedge clk) begin
    if (reset)
        l1_rst  <= 1'b0;
    else 
        l1_rst  <=  (vcnt[1:0] == 2'b11);
end


reg [4:0] cntr;
reg m_read;
always @(posedge clk) begin
    if (reset | state == V_NXT)  cntr    <=  3'h0;
    else  if (state == M_INIT | (state == READ & ~done[0]))    cntr    <=  cntr + 1'b1;
end

reg m_initialized;
always @(posedge clk) begin
    m_initialized   <=  (cntr == 3'h4);
    m_read          <=  (cntr == 5'd20);
end


reg     [1:0]               s_shft;
wire    [1:0]               l2_mux = s_shft;
reg     [5:0]               swtch;
wire    [3:0]               l1, l3;
reg     [3:0]               msk_sel  ;
// try mask, previous change, excludue, exclusion mask
reg     [3:0]               try_m, pr_change, excl, excl_m;

always @(posedge clk) begin

    if (reset) begin
        state   <=  M_INIT;
        done    <=  3'b000;

    end else begin
  
        case (state)
            M_INIT:      begin  //1
                            if (m_initialized  )
                                state   <=  V_NXT;
                            else
                                state   <=  M_INIT;
                            
                            excl_m    <=  4'hF;
                        end

            V_NXT:       begin  // 2

                            msk_sel     <=  4'b1110;
                            s_shft      <=  2'b00;
                            
                            if (vlnxt) begin
                                state   <= EVALUATE;
                            end
                            else if (done_wr ) 
                                state   <= READ;

                            try_m     <=  4'hF;
                            swtch   <=  l1 & l3 &  excl_m;
                        end
        EVALUATE:       begin  // 04 - check_avail(i,j)
                            try_m   <=  try_m << 1;
                            if (swtch[0] == 1'b0) begin
                                swtch   <=  swtch >> 1'b1;
                                s_shft  <=  s_shft + 1'b1;
                                msk_sel <=  {msk_sel[2:0], 1'b1};
                                if (s_shft == 2'b11)
                                    state   <=  BACKTRACK;
                                else
                                    state   <=  EVALUATE;
                            end else begin
                                state   <=  WR_MUXES;
                            end
    
                        end
                        // shift back virtual lane
        BACKTRACK:      begin // 08 -we need to write to M2 what we btrack
                            state   <=  BT_WR_MASKS;
                        end
                        
                        // l1_mux, l3_mux are ready - new read/wrte addresss
                        // based on previous vlane can be calculated
        BT_WR_MASKS:    begin //10
                            excl_m  <=  excl; 
                            state   <=  BT_WR_MASKS2;
                        end

                        // new read/write addresses registered
                        // read in progres
       BT_WR_MASKS2:   begin 
                            state   <=  BT_WR_MASKS3;
                        end
                        
                        // new read data is registerd in rdata. Info about
                        // backtracked l1 and l2. Also previous changes are
                        // reverted in wdata and written back. 
 
        BT_WR_MASKS3:   state   <= V_NXT;


 
            WR_MUXES:   begin  
                            state   <=  WR_MASKS;
                        end
            WR_MASKS:   begin
                            
                            excl_m   <=  4'hF   ;
                            state    <=  V_NXT;
                        end

            READ:       begin 
                            if (m_read) begin
                                state   <=  IDLE;
                                done    <=  3'b111;
                            end else begin
                                state   <=  READ;
                                done    <=  3'b000;
                            end

                        end

            IDLE:       begin
                            state   <=  IDLE;
                        end

        endcase
        
    end
end


reg  [10:0]                  rdata;
reg  [20*2-1:0] l1_bits, l3_bits;
reg  [20*3-1:0] l2_bits_p;
wire [20*3-1:0] l2_bits;
always @(posedge clk) begin

    if (state == M_INIT) begin
        l1_bits         <= {5{8'b11100100}};
        l2_bits_p       <= { {4{3'b100}}, {4{3'b011}}, {4{3'b010}}, {4{3'b001}}, {4{3'b000}} }; // check
        l3_bits         <= {5{8'b11100100}};
    end
    else if (state == READ) begin

        l1_bits         <=  {rdata[8:7], l1_bits[20*2-1:2]}; //{l1_bits[20*2-1-2:0],    rdata[8:7]};
        l2_bits_p       <=  {rdata[6:4], l2_bits_p[20*3-1:3]}; //{l2_bits_p[20*3-1-3:0],  rdata[6:4]};   // need a different reperm after new 5:1 MUX
        l3_bits         <=  {rdata[1:0], l3_bits[20*2-1:2]}; //{l3_bits[20*2-1-2:0],    rdata[1:0]};

    end
end


// depermute layer-2 bits
genvar i;
generate
    for (i=0; i<4; i=i+1) begin : dpl2
        assign l2_bits[(5*3)*i+0+:3]  = l2_bits_p[(4*3)*0+(i*3)+:3];
        assign l2_bits[(5*3)*i+3+:3]  = l2_bits_p[(4*3)*1+(i*3)+:3];
        assign l2_bits[(5*3)*i+6+:3]  = l2_bits_p[(4*3)*2+(i*3)+:3];
        assign l2_bits[(5*3)*i+9+:3]  = l2_bits_p[(4*3)*3+(i*3)+:3];
        assign l2_bits[(5*3)*i+12+:3] = l2_bits_p[(4*3)*4+(i*3)+:3];
    end
endgenerate

assign sel = {l3_bits, l2_bits, l1_bits};


// find mux selections
// l1,l2,l3 mux select <- f(s_shft)
// l1 mux select <- f(avail, inshft)
// l2 mux select <- f(avail, l3-mux)
// l3 mux select <- f(avail, l3-mux)
// shift l1,l2,l3 mux select and OR it with sel output
///////////
//
// l1_mux  <=  vcnt[4:2] ;
// l2_mux  <=  s_shft;
// l3_mux  <=  vlane[4:2]

// l1_msk  <=  vcnt[1:0]; address <= {s_shft, vcnt[1:0]};  write <= {l1_msk, 3'h0, 2'h0};
// l2_msk  <=  l1_mux; address <= {s_shft, l3_mux}; write {2'h0, l2_msk, 2'h0}
// l3_msk  <=  l2_mux; address <= vlane ; 


reg wena_l1, wena_l2, wena_l3;
always @(posedge clk) begin
    wena_l1 <= (state == M_INIT | state == WR_MUXES | state == WR_MASKS | state == BT_WR_MASKS3 ) ;
    wena_l2 <= (state == M_INIT | state == WR_MUXES ) ;
    wena_l3 <= (state == M_INIT | state == WR_MUXES | state == WR_MASKS | state == BT_WR_MASKS3 ) ;
end

reg [4:0]   raddr_l1, raddr_l2, raddr_l3;
always @(posedge clk) begin
    if (state == V_NXT | state == BT_WR_MASKS)     raddr_l1    <=  5'd20 + l1_mux;
    else if (state == READ) raddr_l1    <=  cntr;
end

always @(posedge clk)  raddr_l2    <=  cntr;

always @(posedge clk) begin
    if (state == V_NXT | state == BT_WR_MASKS)     raddr_l3    <=  5'd20 + l3_mux;
    else if (state == READ) raddr_l3    <=  cntr;
end

reg [4:0]   waddr_l1, waddr_l3;

always @(posedge clk) begin
    if (state == M_INIT)
                waddr_l1 <=  5'd20 + cntr;
    else if (state == WR_MASKS | state == BT_WR_MASKS3) 
                waddr_l1 <=  5'd20 + l1_mux;
    else        waddr_l1 <=  {l1_mux, s_shft};
end

reg [4:0] waddr_l2;
always @(posedge clk) begin
                waddr_l2 <=  {l3_mux, s_shft};
end

always @(posedge clk) begin
    if (state == M_INIT)            
                waddr_l3 <=  5'd20 + cntr;
    else if (state == WR_MASKS | state == BT_WR_MASKS3) 
                waddr_l3 <=  5'd20 + l3_mux;
    else        waddr_l3 <=  vlane;
end

reg [3:0] wdata_l1; 
reg [2:0] wdata_l2;
reg [3:0] wdata_l3;
always @(posedge clk) begin
    if (state == M_INIT) begin
        wdata_l1    <=  4'hF;
        wdata_l3    <=  4'hF;
    end
    else if (state == WR_MUXES) begin
        wdata_l1    <=  vcnt[1:0];
        wdata_l2    <=  l1_mux;
        wdata_l3    <=  l2_mux;
    end else if (state == WR_MASKS ) begin
        wdata_l1    <=  l1  & msk_sel;
        wdata_l3    <=  l3  & msk_sel;
    end else if (state == BT_WR_MASKS3) begin
        wdata_l1    <=  rdata[10:7] ^ pr_change;
        wdata_l3    <=  rdata[3:0]  ^ pr_change; 
    end
end 


wire  [10:0]   rdata_w;
// l1 memory
alt_e100s10_mlab m1 (
    .wclk           (clk),
    .wena           (wena_l1) , 
    .waddr_reg      (waddr_l1),
    .wdata_reg      (wdata_l1),
    .raddr          (raddr_l1),
    .rdata          (rdata_w[10:7])
);
defparam    m1 .WIDTH = 4;
defparam    m1 .ADDR_WIDTH = 5;
defparam    m1 .SIM_EMULATE =  SIM_EMULATE;

alt_e100s10_mlab m2 (
    .wclk           (clk),
    .wena           (wena_l2),
    .waddr_reg      (waddr_l2),
    .wdata_reg      (wdata_l2),
    .raddr          (raddr_l2),
    .rdata          (rdata_w[6:4])
);
defparam    m2 .WIDTH = 3;
defparam    m2 .ADDR_WIDTH = 5;
defparam    m2 .SIM_EMULATE = SIM_EMULATE;

alt_e100s10_mlab m3 (
    .wclk           (clk),
    .wena           (wena_l3),
    .waddr_reg      (waddr_l3),
    .wdata_reg      (wdata_l3),
    .raddr          (raddr_l3),
    .rdata          (rdata_w[3:0])
);
defparam    m3 .WIDTH = 4;
defparam    m3 .ADDR_WIDTH = 5;
defparam    m3 .SIM_EMULATE = SIM_EMULATE;


always @(posedge clk)   rdata   <=  rdata_w;

assign  l1  =   rdata[10:7];
assign  l3  =   rdata[3:0];



// backtracking stack
reg     [4:0]   waddr_bt, raddr_bt;
wire    [7:0]   wdata_bt, rdata_bt;
reg             wena_bt;

always @(posedge clk) begin
    wena_bt <= (state == WR_MUXES);
end


always @(posedge clk) begin
    if (state == M_INIT)
        raddr_bt    <=  5'h1F;
    else if (state == WR_MASKS)
        raddr_bt    <=  raddr_bt + 1'b1;
    else if (state == BT_WR_MASKS3)
        raddr_bt    <=  raddr_bt - 1'b1;

end

always @(posedge clk) begin
    waddr_bt    <=  raddr_bt + 1'b1;
end

assign  wdata_bt = {try_m, ~msk_sel};

alt_e100s10_mlab bt (
    .wclk           (clk),
    .wena           (wena_bt),
    .waddr_reg      (waddr_bt),
    .wdata_reg      (wdata_bt),
    .raddr          (raddr_bt),
    .rdata          (rdata_bt)
);
defparam    bt .WIDTH = 8;
defparam    bt .ADDR_WIDTH = 5;
defparam    bt .SIM_EMULATE = SIM_EMULATE;


always @(posedge clk) begin
    {excl, pr_change} <=  rdata_bt;
end



endmodule





// BENCHMARK INFO : Date : Tue Feb  7 16:19:58 2017
// BENCHMARK INFO : Quartus version : /tools/acdskit/17.0/221/linux64/quartus/bin
// BENCHMARK INFO : benchmark P4 version: 17 
// BENCHMARK INFO : benchmark path: /data/fkhan/work/s100/xctrl
// BENCHMARK INFO : Number of LUT levels: Max 2.0 LUTs   Average 0.80
// BENCHMARK INFO : Number of Fitter seeds : 1
// BENCHMARK INFO : Device: 1SG280LU3F50I3VG
// BENCHMARK INFO : ALM usage: 265 (compensated by 1 ALM per virtual I/O)
// BENCHMARK INFO : Combinational ALUT usage: 229
// BENCHMARK INFO : Fitter seed 1000: Worst setup slack @ 450 MHz : 0.302 ns, From state.WR_MASKS, To vtag_r[96] 
// BENCHMARK INFO : Elapsed benchmark time: 625.0 seconds
