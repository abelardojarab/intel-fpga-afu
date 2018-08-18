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

module alt_e100s10_rx_fc #(
        parameter WORDS          = 4,
        parameter WIDTH          = 64,
        parameter EMPTYBITS      = 6,
        parameter RXERRWIDTH     = 6,
        parameter NUMPRIORITY    = 8,
        parameter PREAMBLE_PASS  = 0,
        parameter PIPE_INPUTS    = 1
       )(
        // Clock & Reset
        input                      clk,
        input                      reset_n,
        
        // Input from CSR
        input [47:0]               cfg_rx_mac_da,
        input                      cfg_rx_crc_pt,
        input [7:0]                cfg_rx_pfc_en,
        
        // AV-ST input from MAC
        input [511:0]              in_data,
        input                      in_sop,
        input                      in_eop,
        input                      in_valid,
        input [EMPTYBITS-1:0]      in_empty,
        input [RXERRWIDTH-1:0]     in_error,
        
        // Output to TX Flow Control
        output [7:0]                out_pfc_ena,
        output [NUMPRIORITY*16-1:0] out_pq_data,
        output                      out_pfc_frame,
        output                      out_pq_valid
       );
// Constant
localparam TYPE_CTRL            = 16'h8808;
localparam OPCODE_PAUSE         = 16'h0001;
localparam OPCODE_PFC           = 16'h0101;
localparam PAUSE_ADDR           = 48'h0180_C200_0001;

// Internal registers and wires

wire [15:0] length_type_w;
wire [15:0] ctrl_opcode_w;
wire [47:0] da_addr_w;
wire [ 6:0] ctrl_frm_size_w;
wire [EMPTYBITS-1:0] ctrl_frm_empty_w;
reg  [ 7:0] pfc_ena_p3, pfc_ena_p4;
reg  [NUMPRIORITY*16-1:0] pfc_pq_p3;
reg  [NUMPRIORITY*16-1:0] pfc_pq_p4;
reg         rxin_valid_sop_p1;
reg         rxin_valid_sop_p2;
reg         rxin_valid_sop_p3;
reg         rxin_valid_eop_p1, rxin_valid_eop_p2, rxin_valid_eop_p3;
reg  [EMPTYBITS-1:0]      rxin_empty_p1;
reg         rxin_error_flag_p1, rxin_error_flag_p2, rxin_error_flag_p3;
reg         primary_addr_matched_bit47to45_p1, primary_addr_matched_bit44to42_p1, primary_addr_matched_bit41to39_p1,
            primary_addr_matched_bit38to36_p1, primary_addr_matched_bit35to33_p1, primary_addr_matched_bit32to30_p1,
            primary_addr_matched_bit29to27_p1, primary_addr_matched_bit26to24_p1, primary_addr_matched_bit23to21_p1,
            primary_addr_matched_bit20to18_p1, primary_addr_matched_bit17to15_p1, primary_addr_matched_bit14to12_p1,
            primary_addr_matched_bit11to9_p1, primary_addr_matched_bit8to6_p1, primary_addr_matched_bit5to3_p1, primary_addr_matched_bit2to0_p1;
reg         multicast_pause_addr_matched_bit47to42_p1, multicast_pause_addr_matched_bit41to36_p1, multicast_pause_addr_matched_bit35to30_p1,
            multicast_pause_addr_matched_bit29to24_p1, multicast_pause_addr_matched_bit23to18_p1, multicast_pause_addr_matched_bit17to12_p1,
            multicast_pause_addr_matched_bit11to6_p1, multicast_pause_addr_matched_bit5to0_p1;
reg         primary_addr_matched_bit47to30_p2, primary_addr_matched_bit29to12_p2, primary_addr_matched_bit11to0_p2;
reg         multicast_pause_addr_matched_bit47to24_p2, multicast_pause_addr_matched_bit23to0_p2;
reg         length_type_matched_bit15to10_p1,length_type_matched_bit9to4_p1,length_type_matched_bit3to0_p1;
reg         pause_ctrl_opcode_matched_bit15to10_p1,pause_ctrl_opcode_matched_bit9to4_p1,pause_ctrl_opcode_matched_bit3to0_p1;
reg         pfc_ctrl_opcode_matched_bit15to10_p1, pfc_ctrl_opcode_matched_bit9to4_p1, pfc_ctrl_opcode_matched_bit3to0_p1;
reg         pause_addr_matched_p3;
reg         frm_length_matched_p3, frm_length_matched_bit6to4_p2, frm_length_matched_bit3to0_p2;
reg         pause_frm_p2;
reg         pfc_frm_p2, pfc_frm_p3, pfc_frm_p4;
reg         is_fc_frame_p3;
reg         pq_valid_p4;
reg  [ 6:0] bytes_counter;

// _________________________________________________________________________________
//    input pipeline
// _________________________________________________________________________________

reg  [511:0]             pipe_in_data;
reg                      pipe_in_sop;
reg                      pipe_in_eop;
reg                      pipe_in_val;
reg  [EMPTYBITS-1:0]     pipe_in_empty;
reg  [RXERRWIDTH-1:0]    pipe_in_error;

wire [511:0]             rxin_data;
wire                     rxin_sop;
wire                     rxin_eop;
wire                     rxin_valid;
wire [EMPTYBITS-1:0]     rxin_empty;
wire [RXERRWIDTH-1:0]    rxin_error;

always@(posedge clk) begin
    pipe_in_data       <= in_data;
    pipe_in_sop        <= in_sop;
    pipe_in_eop        <= in_eop;
    pipe_in_val        <= in_valid;
    pipe_in_empty      <= in_empty;
    pipe_in_error      <= in_error;
end
   
generate if (PIPE_INPUTS == 1)
    begin:  pipe_inputs
        assign rxin_data     = pipe_in_data;
        assign rxin_sop      = pipe_in_sop;
        assign rxin_eop      = pipe_in_eop;
        assign rxin_valid    = pipe_in_val;
        assign rxin_empty    = pipe_in_empty;
        assign rxin_error    = pipe_in_error;
    end
    else
    begin:  primary_inputs
        assign rxin_data     = in_data;
        assign rxin_sop      = in_sop;
        assign rxin_eop      = in_eop;
        assign rxin_valid    = in_valid;
        assign rxin_empty    = in_empty;
        assign rxin_error    = in_error;
     end
endgenerate
    
// _________________________________________________________________________________
//    internal pipeline
// _________________________________________________________________________________

reg  [511:0]       rxin_data_p1;
reg  [511:0]       rxin_data_p2;
    
always@(posedge clk) begin
    rxin_data_p1       <= rxin_data;
    rxin_data_p2       <= rxin_data_p1;
end
   
// SYNC_RESET FLOPS
always @(posedge clk) begin
    if(!reset_n) begin
        primary_addr_matched_bit47to30_p2 <= 1'b0;
        primary_addr_matched_bit29to12_p2 <= 1'b0;
        primary_addr_matched_bit11to0_p2 <= 1'b0;
        multicast_pause_addr_matched_bit47to24_p2 <= 1'b0;
        multicast_pause_addr_matched_bit23to0_p2  <= 1'b0;
        pause_frm_p2 <= 1'b0;
        pfc_frm_p2 <= 1'b0;
    end
    else begin
        if(rxin_valid_sop_p1) begin
            primary_addr_matched_bit47to30_p2 <= primary_addr_matched_bit47to45_p1 &
                                                 primary_addr_matched_bit44to42_p1 &
                                                 primary_addr_matched_bit41to39_p1 &
                                                 primary_addr_matched_bit38to36_p1 &
                                                 primary_addr_matched_bit35to33_p1 &
                                                 primary_addr_matched_bit32to30_p1;
            primary_addr_matched_bit29to12_p2 <= primary_addr_matched_bit29to27_p1 &
                                                 primary_addr_matched_bit26to24_p1 &
                                                 primary_addr_matched_bit23to21_p1 &
                                                 primary_addr_matched_bit20to18_p1 &
                                                 primary_addr_matched_bit17to15_p1 &
                                                 primary_addr_matched_bit14to12_p1;
            primary_addr_matched_bit11to0_p2 <= primary_addr_matched_bit11to9_p1 &
                                                 primary_addr_matched_bit8to6_p1 &
                                                 primary_addr_matched_bit5to3_p1 &
                                                 primary_addr_matched_bit2to0_p1;
            multicast_pause_addr_matched_bit47to24_p2 <= multicast_pause_addr_matched_bit47to42_p1 &
                                                       multicast_pause_addr_matched_bit41to36_p1 &
                                                       multicast_pause_addr_matched_bit35to30_p1 &
                                                       multicast_pause_addr_matched_bit29to24_p1;
            multicast_pause_addr_matched_bit23to0_p2  <= multicast_pause_addr_matched_bit23to18_p1 &
                                                       multicast_pause_addr_matched_bit17to12_p1 &
                                                       multicast_pause_addr_matched_bit11to6_p1 &
                                                       multicast_pause_addr_matched_bit5to0_p1;
                                                       
            pause_frm_p2 <= (length_type_matched_bit15to10_p1 & length_type_matched_bit9to4_p1 & length_type_matched_bit3to0_p1) &
                         (pause_ctrl_opcode_matched_bit15to10_p1 & pause_ctrl_opcode_matched_bit9to4_p1 & pause_ctrl_opcode_matched_bit3to0_p1);
            pfc_frm_p2 <= (length_type_matched_bit15to10_p1 & length_type_matched_bit9to4_p1 & length_type_matched_bit3to0_p1) &
                       (pfc_ctrl_opcode_matched_bit15to10_p1 & pfc_ctrl_opcode_matched_bit9to4_p1 & pfc_ctrl_opcode_matched_bit3to0_p1);
        end
    end
end

integer i;
// SYNC_RESET FLOPS
always @(posedge clk) begin
    if(rxin_valid_sop_p2) begin
        pfc_ena_p3[7:0] <= PREAMBLE_PASS ?  rxin_data_p2[375-64:368-64] & cfg_rx_pfc_en : 
                                         rxin_data_p2[375:368] & cfg_rx_pfc_en;
        pfc_pq_p3[15:0] <= PREAMBLE_PASS ? 
                            ((pause_frm_p2) ? rxin_data_p2[383-64:368-64] :
                                          rxin_data_p2[367-64:352-64]) :
                            ((pause_frm_p2) ? rxin_data_p2[383:368] :
                                          rxin_data_p2[367:352]);

        for (i=1; i < (NUMPRIORITY <= 8 ? NUMPRIORITY : 8); i=i+1) begin
            pfc_pq_p3[16*i+:16] <= PREAMBLE_PASS ? rxin_data_p2[352-64-16*i+:16] : rxin_data_p2[352-16*i+:16];
        end
    end
end

// SYNC_RESET FLOPS
always @(posedge clk) begin
    if(!reset_n) begin
        rxin_empty_p1     <= {EMPTYBITS{1'b0}};
        rxin_valid_sop_p1 <= 1'b0;
        rxin_valid_sop_p2 <= 1'b0;
        rxin_valid_sop_p3 <= 1'b0;
        rxin_valid_eop_p1 <= 1'b0;
        rxin_valid_eop_p1 <= 1'b0;
        rxin_valid_eop_p2 <= 1'b0;
        rxin_valid_eop_p3 <= 1'b0;
        rxin_error_flag_p1 <= 1'b0;
        rxin_error_flag_p2 <= 1'b0;
        rxin_error_flag_p3 <= 1'b0;
    end
    else begin
        rxin_empty_p1     <= rxin_empty;
        rxin_valid_sop_p1 <= rxin_sop & rxin_valid;
        rxin_valid_sop_p2 <= rxin_valid_sop_p1;
        rxin_valid_sop_p3 <= rxin_valid_sop_p2;
        rxin_valid_eop_p1 <= rxin_eop & rxin_valid;
        rxin_valid_eop_p2 <= rxin_valid_eop_p1;
        rxin_valid_eop_p3 <= rxin_valid_eop_p2;
        
        rxin_error_flag_p1 <= |rxin_error;
        rxin_error_flag_p2 <= rxin_error_flag_p1;
        rxin_error_flag_p3 <= rxin_error_flag_p2;
    end
end

// SYNC_RESET FLOPS
always @(posedge clk) begin
    pause_addr_matched_p3 <= (primary_addr_matched_bit47to30_p2 & primary_addr_matched_bit29to12_p2 & primary_addr_matched_bit11to0_p2) |
                          (multicast_pause_addr_matched_bit47to24_p2 & multicast_pause_addr_matched_bit23to0_p2);
    
    pfc_frm_p3   <= pfc_frm_p2;
    pfc_frm_p4   <= pfc_frm_p3;
    
    is_fc_frame_p3  <= pfc_frm_p2 | pause_frm_p2;
    
    frm_length_matched_p3 <= frm_length_matched_bit6to4_p2 & frm_length_matched_bit3to0_p2;
    
    pfc_ena_p4   <= pfc_ena_p3;
    
    pfc_pq_p4    <= pfc_pq_p3;
end

// Destination Address matching
assign da_addr_w[47:0] = PREAMBLE_PASS ? rxin_data[447:400] : rxin_data[511:464];

// Length/Type & opcode matching
assign length_type_w = PREAMBLE_PASS ? rxin_data[351:336] : rxin_data[415:400];
assign ctrl_opcode_w = PREAMBLE_PASS ? rxin_data[335:320] : rxin_data[399:384];

// SYNC_RESET FLOPS
// Pause multicast address detection
always @(posedge clk) begin
    if(!reset_n) begin
        primary_addr_matched_bit47to45_p1 <= 1'b0;
        primary_addr_matched_bit44to42_p1 <= 1'b0;
        primary_addr_matched_bit41to39_p1 <= 1'b0;
        primary_addr_matched_bit38to36_p1 <= 1'b0;
        primary_addr_matched_bit35to33_p1 <= 1'b0;
        primary_addr_matched_bit32to30_p1 <= 1'b0;
        primary_addr_matched_bit29to27_p1 <= 1'b0;
        primary_addr_matched_bit26to24_p1 <= 1'b0;
        primary_addr_matched_bit23to21_p1 <= 1'b0;
        primary_addr_matched_bit20to18_p1 <= 1'b0;
        primary_addr_matched_bit17to15_p1 <= 1'b0;
        primary_addr_matched_bit14to12_p1 <= 1'b0;
        primary_addr_matched_bit11to9_p1 <= 1'b0;
        primary_addr_matched_bit8to6_p1 <= 1'b0;
        primary_addr_matched_bit5to3_p1 <= 1'b0;
        primary_addr_matched_bit2to0_p1 <= 1'b0;
        multicast_pause_addr_matched_bit47to42_p1 <= 1'b0;
        multicast_pause_addr_matched_bit41to36_p1 <= 1'b0;
        multicast_pause_addr_matched_bit35to30_p1 <= 1'b0;
        multicast_pause_addr_matched_bit29to24_p1 <= 1'b0;
        multicast_pause_addr_matched_bit23to18_p1 <= 1'b0;
        multicast_pause_addr_matched_bit17to12_p1 <= 1'b0;
        multicast_pause_addr_matched_bit11to6_p1 <= 1'b0;
        multicast_pause_addr_matched_bit5to0_p1 <= 1'b0;
        
        length_type_matched_bit15to10_p1 <= 1'b0;
        length_type_matched_bit9to4_p1 <= 1'b0;
        length_type_matched_bit3to0_p1 <= 1'b0;
            
        pause_ctrl_opcode_matched_bit15to10_p1 <= 1'b0;
        pause_ctrl_opcode_matched_bit9to4_p1 <= 1'b0;
        pause_ctrl_opcode_matched_bit3to0_p1 <= 1'b0;
            
        pfc_ctrl_opcode_matched_bit15to10_p1 <= 1'b0;
        pfc_ctrl_opcode_matched_bit9to4_p1 <= 1'b0;
        pfc_ctrl_opcode_matched_bit3to0_p1 <= 1'b0;
    end
    else begin
        if(rxin_valid) begin
            primary_addr_matched_bit47to45_p1 <= (da_addr_w[47:45] == cfg_rx_mac_da[47:45]);
            primary_addr_matched_bit44to42_p1 <= (da_addr_w[44:42] == cfg_rx_mac_da[44:42]);
            primary_addr_matched_bit41to39_p1 <= (da_addr_w[41:39] == cfg_rx_mac_da[41:39]);
            primary_addr_matched_bit38to36_p1 <= (da_addr_w[38:36] == cfg_rx_mac_da[38:36]);
            primary_addr_matched_bit35to33_p1 <= (da_addr_w[35:33] == cfg_rx_mac_da[35:33]);
            primary_addr_matched_bit32to30_p1 <= (da_addr_w[32:30] == cfg_rx_mac_da[32:30]);
            primary_addr_matched_bit29to27_p1 <= (da_addr_w[29:27] == cfg_rx_mac_da[29:27]);
            primary_addr_matched_bit26to24_p1 <= (da_addr_w[26:24] == cfg_rx_mac_da[26:24]);
            primary_addr_matched_bit23to21_p1 <= (da_addr_w[23:21] == cfg_rx_mac_da[23:21]);
            primary_addr_matched_bit20to18_p1 <= (da_addr_w[20:18] == cfg_rx_mac_da[20:18]);
            primary_addr_matched_bit17to15_p1 <= (da_addr_w[17:15] == cfg_rx_mac_da[17:15]);
            primary_addr_matched_bit14to12_p1 <= (da_addr_w[14:12] == cfg_rx_mac_da[14:12]);
            primary_addr_matched_bit11to9_p1 <= (da_addr_w[11:9] == cfg_rx_mac_da[11:9]);
            primary_addr_matched_bit8to6_p1 <= (da_addr_w[8:6] == cfg_rx_mac_da[8:6]);
            primary_addr_matched_bit5to3_p1 <= (da_addr_w[5:3] == cfg_rx_mac_da[5:3]);
            primary_addr_matched_bit2to0_p1 <= (da_addr_w[2:0] == cfg_rx_mac_da[2:0]);
            
            multicast_pause_addr_matched_bit47to42_p1 <= (da_addr_w[47:42] == PAUSE_ADDR[47:42]);
            multicast_pause_addr_matched_bit41to36_p1 <= (da_addr_w[41:36] == PAUSE_ADDR[41:36]);
            multicast_pause_addr_matched_bit35to30_p1 <= (da_addr_w[35:30] == PAUSE_ADDR[35:30]);
            multicast_pause_addr_matched_bit29to24_p1 <= (da_addr_w[29:24] == PAUSE_ADDR[29:24]);
            multicast_pause_addr_matched_bit23to18_p1 <= (da_addr_w[23:18] == PAUSE_ADDR[23:18]);
            multicast_pause_addr_matched_bit17to12_p1 <= (da_addr_w[17:12] == PAUSE_ADDR[17:12]);
            multicast_pause_addr_matched_bit11to6_p1 <= (da_addr_w[11:6] == PAUSE_ADDR[11:6]);
            multicast_pause_addr_matched_bit5to0_p1 <= (da_addr_w[5:0] == PAUSE_ADDR[5:0]);
            
            length_type_matched_bit15to10_p1 <= (length_type_w[15:10] == TYPE_CTRL[15:10]);
            length_type_matched_bit9to4_p1 <= (length_type_w[9:4] == TYPE_CTRL[9:4]);
            length_type_matched_bit3to0_p1 <= (length_type_w[3:0] == TYPE_CTRL[3:0]);
            
            pause_ctrl_opcode_matched_bit15to10_p1 <= (ctrl_opcode_w[15:10] == OPCODE_PAUSE[15:10]);
            pause_ctrl_opcode_matched_bit9to4_p1 <= (ctrl_opcode_w[9:4] == OPCODE_PAUSE[9:4]);
            pause_ctrl_opcode_matched_bit3to0_p1 <= (ctrl_opcode_w[3:0] == OPCODE_PAUSE[3:0]);
            
            pfc_ctrl_opcode_matched_bit15to10_p1 <= (ctrl_opcode_w[15:10] == OPCODE_PFC[15:10]);
            pfc_ctrl_opcode_matched_bit9to4_p1 <= (ctrl_opcode_w[9:4] == OPCODE_PFC[9:4]);
            pfc_ctrl_opcode_matched_bit3to0_p1 <= (ctrl_opcode_w[3:0] == OPCODE_PFC[3:0]);
            
        end
    end
end

// SYNC_RESET FLOPS
// Frame Length

always @(posedge clk) begin
    if(!reset_n) begin
        bytes_counter <= 7'h0;
    end
    else begin
        if(rxin_valid) begin
            // Count up every clock cycles based on empty value
            // Inverting empty value + 1 will give us the number of bytes for the particular cycle
            bytes_counter <= rxin_sop ? (7'h1 + {{(7-EMPTYBITS){1'h0}}, ~rxin_empty[EMPTYBITS-1:0]}) :
                                        (bytes_counter + 7'h1 + {{(7-EMPTYBITS){1'h0}}, ~rxin_empty[EMPTYBITS-1:0]});
        end
    end
end

assign ctrl_frm_size_w = cfg_rx_crc_pt ? (PREAMBLE_PASS ? 7'd72 : 7'd64) : (PREAMBLE_PASS ? 7'd68 : 7'd60);

always @(posedge clk) begin
    if(!reset_n) begin
        frm_length_matched_bit6to4_p2 <= 1'b0;
        frm_length_matched_bit3to0_p2 <= 1'b0;
    end
    else begin
        if(rxin_valid_eop_p1) begin
            frm_length_matched_bit6to4_p2 <= (bytes_counter[6:4] == ctrl_frm_size_w[6:4]);
            frm_length_matched_bit3to0_p2 <= (bytes_counter[3:0] == ctrl_frm_size_w[3:0]);
        end
    end
end

always @(posedge clk) begin
    if(!reset_n) begin
        pq_valid_p4 <= 1'b0;
    end
    else begin
        if(rxin_valid_eop_p3) begin
            pq_valid_p4 <= (is_fc_frame_p3 & pause_addr_matched_p3 & frm_length_matched_p3 & !rxin_error_flag_p3);
        end else begin
            pq_valid_p4 <= 1'b0;
        end
    end
end

assign out_pfc_ena   = pfc_ena_p4;
assign out_pq_data   = pfc_pq_p4;
assign out_pfc_frame = pfc_frm_p4;
assign out_pq_valid  = pq_valid_p4;
    
endmodule
