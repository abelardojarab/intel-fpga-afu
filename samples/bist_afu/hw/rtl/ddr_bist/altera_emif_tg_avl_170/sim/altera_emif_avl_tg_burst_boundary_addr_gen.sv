// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


//////////////////////////////////////////////////////////////////////////////
// This module rounds up the input address to the next burst boundary.
//////////////////////////////////////////////////////////////////////////////
module altera_emif_avl_tg_burst_boundary_addr_gen # (

   // Avalon signal widths
   parameter ADDR_WIDTH                     = "",
   parameter BURSTCOUNT_WIDTH               = "",

   // Address generator configuration
   parameter BURST_ON_BURST_BOUNDARY        = "",
   parameter DO_NOT_CROSS_4KB_BOUNDARY      = "",
   
   // The word address must be divisible by the following value
   parameter AMM_WORD_ADDRESS_DIVISIBLE_BY  = 1,
   
   parameter DATA_WIDTH                     = ""
   
) (
   input  logic [BURSTCOUNT_WIDTH-1:0]   burstcount,
   input  logic [ADDR_WIDTH-1:0]         addr_in,
   output logic [ADDR_WIDTH-1:0]         addr_out
);

   timeunit 1ns;
   timeprecision 1ps;
   
   import avl_tg_defs::*;

   localparam LOG_4KB = 12 - log2(DATA_WIDTH);

   logic [ADDR_WIDTH-1:0] addr_out_1;
   logic [ADDR_WIDTH-1:0] addr_out_2;

   generate
      if (BURST_ON_BURST_BOUNDARY == 1)
      begin : burst_boundary_true
         // Burst on burst boundary is enabled
         // burstcount must be a power of 2 for the follow to work
         // Round up instead of down, so that sequential addresses are monotonically increasing
         logic [ADDR_WIDTH-1:0]   addr_tmp;
         logic [ADDR_WIDTH-1:0]   addr_tmp_incr;

         always_comb
         begin
            for (int i = 0; i < ADDR_WIDTH; i++)
            begin
               if (burstcount > 2**i)
                  addr_tmp[i] <= 1'b0;
               else
                  addr_tmp[i] <= addr_in[i];

               if (burstcount == 2**i)
                  addr_tmp_incr[i] <= 1'b1;
               else
                  addr_tmp_incr[i] <= 1'b0;
            end
         end
         
         assign addr_out_1 = addr_tmp + addr_tmp_incr;
      
      end else
      begin : burst_boundary_false
         // Burst on burst boundary is disabled, leave the address as is
         assign addr_out_1 = addr_in;
      end
      
      // Make address divisible by AMM_WORD_ADDRESS_DIVISIBLE_BY (which must be a power of 2)
      // Round up instead of down, so that sequential addresses are monotonically increasing.
      // If this becomes a timing closure issue, round down by removing the adder.
      if (AMM_WORD_ADDRESS_DIVISIBLE_BY > 1)
      begin: amm_word_address_divisible_by_gt_one
         logic [ADDR_WIDTH-1:0] word_addr_divisible_by;
         assign word_addr_divisible_by = AMM_WORD_ADDRESS_DIVISIBLE_BY[ADDR_WIDTH-1:0];
         assign addr_out_2 = ~(word_addr_divisible_by - 1'b1) & addr_out_1 + word_addr_divisible_by;
      end else
      begin: amm_word_address_divisible_by_one
         assign addr_out_2 = addr_out_1;
      end
                  
      // Enforce 4K address boundary
      if (DO_NOT_CROSS_4KB_BOUNDARY == 1)
      begin: dont_cross_4kb_boundary_true
         logic [ADDR_WIDTH-1:0] last_addr;
         assign last_addr = addr_out_2 + burstcount - 1;
         assign addr_out = (addr_out_2[ADDR_WIDTH-1:LOG_4KB] != last_addr[ADDR_WIDTH-1:LOG_4KB]) ? addr_out_2 + burstcount : addr_out_2;
         
      end else 
      begin: dont_cross_4kb_boundary_false
         assign addr_out = addr_out_2;
      end
   endgenerate
endmodule

