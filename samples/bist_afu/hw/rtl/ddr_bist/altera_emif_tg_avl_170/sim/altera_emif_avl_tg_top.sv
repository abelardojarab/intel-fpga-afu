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



///////////////////////////////////////////////////////////////////////////////
// Top-level wrapper of EMIF Avl Traffic Generator.
//
///////////////////////////////////////////////////////////////////////////////

`define _get_pnf_id(_prefix, _i)  (  (((_i)==0) ? `"_prefix``0`" : \
                                     (((_i)==1) ? `"_prefix``1`" : \
                                     (((_i)==2) ? `"_prefix``2`" : \
                                     (((_i)==3) ? `"_prefix``3`" : \
                                     (((_i)==4) ? `"_prefix``4`" : \
                                     (((_i)==5) ? `"_prefix``5`" : \
                                     (((_i)==6) ? `"_prefix``6`" : \
                                     (((_i)==7) ? `"_prefix``7`" : `"_prefix``8`")))))))))

module altera_emif_avl_tg_top # (
   parameter PROTOCOL_ENUM                           = "",
   parameter MEGAFUNC_DEVICE_FAMILY                  = "",

   // Use simplified driver
   parameter USE_SIMPLE_TG                           = 0,

   // Specifies how many tests to run. Only applicable when USE_SIMPLE_TG is 0.
   // SHORT -> Suitable for simulation only.
   // MEDIUM -> Generates more traffic for simple hardware testing in seconds.
   // INFINITE -> Generates traffic continuously and indefinitely.
   parameter TEST_DURATION                           = "SHORT",

   // Number of controller ports
   parameter NUM_OF_CTRL_PORTS                       = 1,

   // Is this in ping-pong configuration?
   parameter PHY_PING_PONG_EN                        = 0,

   // Indicates whether a separate interface exists for reads and writes.
   // Typically set to 1 for QDR-style interfaces where concurrent reads and
   // writes are possible. If set to true, interface 0 is the read-only
   // interface, interface 1 is the write-only interface.
   // This is a boolean parameter.
   parameter SEPARATE_READ_WRITE_IFS                 = 0,
   
   // Indicates whether to use input reset signal as is, or to instantiate
   // a reset synchronizer using the input clock and reset signal and use the output 
   // of the reset synchronizer as reset.
   parameter GENERATE_LOCAL_RESET_SYNC               = 0,

   // Avalon protocol used by the controller
   parameter CTRL_AVL_PROTOCOL_ENUM                  = "",

   // Indicates whether Avalon byte-enable signal is used
   parameter USE_AVL_BYTEEN                          = 0,

   // Specifies alignment criteria for Avalon-MM word addresses and burst count
   parameter AMM_WORD_ADDRESS_DIVISIBLE_BY           = 1,
   parameter AMM_BURST_COUNT_DIVISIBLE_BY            = 1,

   // The traffic generator is an Avalon master, and therefore generates symbol-
   // addresses that are word-aligned when the protocol specified is Avalon-MM.
   // To generate word-aligned addresses it must know the word address width.
   parameter AMM_WORD_ADDRESS_WIDTH                  = 1,

   // Definition of port widths for "ctrl_amm" interface (auto-generated)
   parameter PORT_CTRL_AMM_RDATA_WIDTH               = 1,
   parameter PORT_CTRL_AMM_ADDRESS_WIDTH             = 1,
   parameter PORT_CTRL_AMM_WDATA_WIDTH               = 1,
   parameter PORT_CTRL_AMM_BCOUNT_WIDTH              = 1,
   parameter PORT_CTRL_AMM_BYTEEN_WIDTH              = 1,

   // Definition of port widths for "ctrl_user_refresh" interface
   parameter PORT_CTRL_USER_REFRESH_REQ_WIDTH        = 1,
   parameter PORT_CTRL_USER_REFRESH_BANK_WIDTH       = 1,

   // Definition of port widths for "ctrl_self_refresh" interface
   parameter PORT_CTRL_SELF_REFRESH_REQ_WIDTH        = 1,

   // Definition of port widths for "ctrl_mmr" interface
   parameter PORT_CTRL_MMR_MASTER_ADDRESS_WIDTH      = 1,
   parameter PORT_CTRL_MMR_MASTER_RDATA_WIDTH        = 1,
   parameter PORT_CTRL_MMR_MASTER_WDATA_WIDTH        = 1,
   parameter PORT_CTRL_MMR_MASTER_BCOUNT_WIDTH       = 1

) (
   // User reset
   input  logic                                               emif_usr_reset_n,

   // User reset (for secondary interface of ping-pong)
   input  logic                                               emif_usr_reset_n_sec,

   // User clock
   input  logic                                               emif_usr_clk,

   // User clock (for secondary interface of ping-pong)
   input  logic                                               emif_usr_clk_sec,

   // Ports for "ctrl_amm" interfaces (auto-generated)
   output logic                                               amm_write_0,
   output logic                                               amm_read_0,
   input  logic                                               amm_ready_0,
   input  logic [PORT_CTRL_AMM_RDATA_WIDTH-1:0]               amm_readdata_0,
   output logic [PORT_CTRL_AMM_ADDRESS_WIDTH-1:0]             amm_address_0,
   output logic [PORT_CTRL_AMM_WDATA_WIDTH-1:0]               amm_writedata_0,
   output logic [PORT_CTRL_AMM_BCOUNT_WIDTH-1:0]              amm_burstcount_0,
   output logic [PORT_CTRL_AMM_BYTEEN_WIDTH-1:0]              amm_byteenable_0,
   output logic                                               amm_beginbursttransfer_0,
   input  logic                                               amm_readdatavalid_0,

   output logic                                               amm_write_1,
   output logic                                               amm_read_1,
   input  logic                                               amm_ready_1,
   input  logic [PORT_CTRL_AMM_RDATA_WIDTH-1:0]               amm_readdata_1,
   output logic [PORT_CTRL_AMM_ADDRESS_WIDTH-1:0]             amm_address_1,
   output logic [PORT_CTRL_AMM_WDATA_WIDTH-1:0]               amm_writedata_1,
   output logic [PORT_CTRL_AMM_BCOUNT_WIDTH-1:0]              amm_burstcount_1,
   output logic [PORT_CTRL_AMM_BYTEEN_WIDTH-1:0]              amm_byteenable_1,
   output logic                                               amm_beginbursttransfer_1,
   input  logic                                               amm_readdatavalid_1,

   output logic                                               amm_write_2,
   output logic                                               amm_read_2,
   input  logic                                               amm_ready_2,
   input  logic [PORT_CTRL_AMM_RDATA_WIDTH-1:0]               amm_readdata_2,
   output logic [PORT_CTRL_AMM_ADDRESS_WIDTH-1:0]             amm_address_2,
   output logic [PORT_CTRL_AMM_WDATA_WIDTH-1:0]               amm_writedata_2,
   output logic [PORT_CTRL_AMM_BCOUNT_WIDTH-1:0]              amm_burstcount_2,
   output logic [PORT_CTRL_AMM_BYTEEN_WIDTH-1:0]              amm_byteenable_2,
   output logic                                               amm_beginbursttransfer_2,
   input  logic                                               amm_readdatavalid_2,

   output logic                                               amm_write_3,
   output logic                                               amm_read_3,
   input  logic                                               amm_ready_3,
   input  logic [PORT_CTRL_AMM_RDATA_WIDTH-1:0]               amm_readdata_3,
   output logic [PORT_CTRL_AMM_ADDRESS_WIDTH-1:0]             amm_address_3,
   output logic [PORT_CTRL_AMM_WDATA_WIDTH-1:0]               amm_writedata_3,
   output logic [PORT_CTRL_AMM_BCOUNT_WIDTH-1:0]              amm_burstcount_3,
   output logic [PORT_CTRL_AMM_BYTEEN_WIDTH-1:0]              amm_byteenable_3,
   output logic                                               amm_beginbursttransfer_3,
   input  logic                                               amm_readdatavalid_3,

   output logic                                               amm_write_4,
   output logic                                               amm_read_4,
   input  logic                                               amm_ready_4,
   input  logic [PORT_CTRL_AMM_RDATA_WIDTH-1:0]               amm_readdata_4,
   output logic [PORT_CTRL_AMM_ADDRESS_WIDTH-1:0]             amm_address_4,
   output logic [PORT_CTRL_AMM_WDATA_WIDTH-1:0]               amm_writedata_4,
   output logic [PORT_CTRL_AMM_BCOUNT_WIDTH-1:0]              amm_burstcount_4,
   output logic [PORT_CTRL_AMM_BYTEEN_WIDTH-1:0]              amm_byteenable_4,
   output logic                                               amm_beginbursttransfer_4,
   input  logic                                               amm_readdatavalid_4,

   output logic                                               amm_write_5,
   output logic                                               amm_read_5,
   input  logic                                               amm_ready_5,
   input  logic [PORT_CTRL_AMM_RDATA_WIDTH-1:0]               amm_readdata_5,
   output logic [PORT_CTRL_AMM_ADDRESS_WIDTH-1:0]             amm_address_5,
   output logic [PORT_CTRL_AMM_WDATA_WIDTH-1:0]               amm_writedata_5,
   output logic [PORT_CTRL_AMM_BCOUNT_WIDTH-1:0]              amm_burstcount_5,
   output logic [PORT_CTRL_AMM_BYTEEN_WIDTH-1:0]              amm_byteenable_5,
   output logic                                               amm_beginbursttransfer_5,
   input  logic                                               amm_readdatavalid_5,

   output logic                                               amm_write_6,
   output logic                                               amm_read_6,
   input  logic                                               amm_ready_6,
   input  logic [PORT_CTRL_AMM_RDATA_WIDTH-1:0]               amm_readdata_6,
   output logic [PORT_CTRL_AMM_ADDRESS_WIDTH-1:0]             amm_address_6,
   output logic [PORT_CTRL_AMM_WDATA_WIDTH-1:0]               amm_writedata_6,
   output logic [PORT_CTRL_AMM_BCOUNT_WIDTH-1:0]              amm_burstcount_6,
   output logic [PORT_CTRL_AMM_BYTEEN_WIDTH-1:0]              amm_byteenable_6,
   output logic                                               amm_beginbursttransfer_6,
   input  logic                                               amm_readdatavalid_6,

   output logic                                               amm_write_7,
   output logic                                               amm_read_7,
   input  logic                                               amm_ready_7,
   input  logic [PORT_CTRL_AMM_RDATA_WIDTH-1:0]               amm_readdata_7,
   output logic [PORT_CTRL_AMM_ADDRESS_WIDTH-1:0]             amm_address_7,
   output logic [PORT_CTRL_AMM_WDATA_WIDTH-1:0]               amm_writedata_7,
   output logic [PORT_CTRL_AMM_BCOUNT_WIDTH-1:0]              amm_burstcount_7,
   output logic [PORT_CTRL_AMM_BYTEEN_WIDTH-1:0]              amm_byteenable_7,
   output logic                                               amm_beginbursttransfer_7,
   input  logic                                               amm_readdatavalid_7,

   // Ports for "ctrl_user_priority" interface
   output logic                                               ctrl_user_priority_hi_0,
   output logic                                               ctrl_user_priority_hi_1,

   // Ports for "ctrl_auto_precharge" interface
   output logic                                               ctrl_auto_precharge_req_0,
   output logic                                               ctrl_auto_precharge_req_1,

   // Ports for "ctrl_ecc_interrupt" interface
   input  logic                                               ctrl_ecc_user_interrupt_0,
   input  logic                                               ctrl_ecc_user_interrupt_1,

   // Ports for "ctrl_mmr" interface
   input  logic                                               mmr_master_waitrequest_0,
   output logic                                               mmr_master_read_0,
   output logic                                               mmr_master_write_0,
   output logic [PORT_CTRL_MMR_MASTER_ADDRESS_WIDTH-1:0]      mmr_master_address_0,
   input  logic [PORT_CTRL_MMR_MASTER_RDATA_WIDTH-1:0]        mmr_master_readdata_0,
   output logic [PORT_CTRL_MMR_MASTER_WDATA_WIDTH-1:0]        mmr_master_writedata_0,
   output logic [PORT_CTRL_MMR_MASTER_BCOUNT_WIDTH-1:0]       mmr_master_burstcount_0,
   output logic                                               mmr_master_beginbursttransfer_0,
   input  logic                                               mmr_master_readdatavalid_0,

   input  logic                                               mmr_master_waitrequest_1,
   output logic                                               mmr_master_read_1,
   output logic                                               mmr_master_write_1,
   output logic [PORT_CTRL_MMR_MASTER_ADDRESS_WIDTH-1:0]      mmr_master_address_1,
   input  logic [PORT_CTRL_MMR_MASTER_RDATA_WIDTH-1:0]        mmr_master_readdata_1,
   output logic [PORT_CTRL_MMR_MASTER_WDATA_WIDTH-1:0]        mmr_master_writedata_1,
   output logic [PORT_CTRL_MMR_MASTER_BCOUNT_WIDTH-1:0]       mmr_master_burstcount_1,
   output logic                                               mmr_master_beginbursttransfer_1,
   input  logic                                               mmr_master_readdatavalid_1,


   // Ports for "tg_status" interfaces (auto-generated)
   output logic                                               traffic_gen_pass_0,
   output logic                                               traffic_gen_fail_0,
   output logic                                               traffic_gen_timeout_0,

   output logic                                               traffic_gen_pass_1,
   output logic                                               traffic_gen_fail_1,
   output logic                                               traffic_gen_timeout_1,

   output logic                                               traffic_gen_pass_2,
   output logic                                               traffic_gen_fail_2,
   output logic                                               traffic_gen_timeout_2,

   output logic                                               traffic_gen_pass_3,
   output logic                                               traffic_gen_fail_3,
   output logic                                               traffic_gen_timeout_3,

   output logic                                               traffic_gen_pass_4,
   output logic                                               traffic_gen_fail_4,
   output logic                                               traffic_gen_timeout_4,

   output logic                                               traffic_gen_pass_5,
   output logic                                               traffic_gen_fail_5,
   output logic                                               traffic_gen_timeout_5,

   output logic                                               traffic_gen_pass_6,
   output logic                                               traffic_gen_fail_6,
   output logic                                               traffic_gen_timeout_6,

   output logic                                               traffic_gen_pass_7,
   output logic                                               traffic_gen_fail_7,
   output logic                                               traffic_gen_timeout_7
);
   timeunit 1ns;
   timeprecision 1ps;

   logic [7:0]                                   amm_write_all;
   logic [7:0]                                   amm_read_all;
   logic [7:0]                                   amm_ready_all;
   logic [7:0][PORT_CTRL_AMM_RDATA_WIDTH-1:0]    amm_readdata_all;
   logic [7:0][PORT_CTRL_AMM_ADDRESS_WIDTH-1:0]  amm_address_all;
   logic [7:0][PORT_CTRL_AMM_WDATA_WIDTH-1:0]    amm_writedata_all;
   logic [7:0][PORT_CTRL_AMM_BCOUNT_WIDTH-1:0]   amm_burstcount_all;
   logic [7:0][PORT_CTRL_AMM_BYTEEN_WIDTH-1:0]   amm_byteenable_all;
   logic [7:0]                                   amm_beginbursttransfer_all;
   logic [7:0]                                   amm_readdatavalid_all;

   logic [7:0]                                   traffic_gen_pass_all;
   logic [7:0]                                   traffic_gen_fail_all;
   logic [7:0]                                   traffic_gen_timeout_all;

   logic [7:0][PORT_CTRL_AMM_WDATA_WIDTH-1:0]    pnf_per_bit_persist;

   // WORM mode: If a data mismatch is encountered, stop as much of the traffic as possible
   // and issue a read to the same address. In this mode, the persistent PNF
   // is no longer meaningful as we basically stop at the first data mismatch.
   logic                                         issp_worm_en;
   logic [2:0]                                   worm_en;
   logic [2:0]                                   worm_en_sec;

   // Output signals
   assign {amm_write_7,              amm_write_6,              amm_write_5,              amm_write_4,              amm_write_3,              amm_write_2,              amm_write_1,              amm_write_0             } = amm_write_all;
   assign {amm_read_7,               amm_read_6,               amm_read_5,               amm_read_4,               amm_read_3,               amm_read_2,               amm_read_1,               amm_read_0              } = amm_read_all;
   assign {amm_address_7,            amm_address_6,            amm_address_5,            amm_address_4,            amm_address_3,            amm_address_2,            amm_address_1,            amm_address_0           } = amm_address_all;
   assign {amm_writedata_7,          amm_writedata_6,          amm_writedata_5,          amm_writedata_4,          amm_writedata_3,          amm_writedata_2,          amm_writedata_1,          amm_writedata_0         } = amm_writedata_all;
   assign {amm_burstcount_7,         amm_burstcount_6,         amm_burstcount_5,         amm_burstcount_4,         amm_burstcount_3,         amm_burstcount_2,         amm_burstcount_1,         amm_burstcount_0        } = amm_burstcount_all;
   assign {amm_byteenable_7,         amm_byteenable_6,         amm_byteenable_5,         amm_byteenable_4,         amm_byteenable_3,         amm_byteenable_2,         amm_byteenable_1,         amm_byteenable_0        } = amm_byteenable_all;
   assign {amm_beginbursttransfer_7, amm_beginbursttransfer_6, amm_beginbursttransfer_5, amm_beginbursttransfer_4, amm_beginbursttransfer_3, amm_beginbursttransfer_2, amm_beginbursttransfer_1, amm_beginbursttransfer_0} = amm_beginbursttransfer_all;

   assign {traffic_gen_pass_7,       traffic_gen_pass_6,       traffic_gen_pass_5,       traffic_gen_pass_4,       traffic_gen_pass_3,       traffic_gen_pass_2,       traffic_gen_pass_1,       traffic_gen_pass_0      } = traffic_gen_pass_all;
   assign {traffic_gen_fail_7,       traffic_gen_fail_6,       traffic_gen_fail_5,       traffic_gen_fail_4,       traffic_gen_fail_3,       traffic_gen_fail_2,       traffic_gen_fail_1,       traffic_gen_fail_0      } = traffic_gen_fail_all;
   assign {traffic_gen_timeout_7,    traffic_gen_timeout_6,    traffic_gen_timeout_5,    traffic_gen_timeout_4,    traffic_gen_timeout_3,    traffic_gen_timeout_2,    traffic_gen_timeout_1,    traffic_gen_timeout_0   } = traffic_gen_timeout_all;

   localparam NUM_OF_WRITE_CTRL_PORTS = (SEPARATE_READ_WRITE_IFS ? NUM_OF_CTRL_PORTS / 2: NUM_OF_CTRL_PORTS );
`ifdef ALTERA_EMIF_ENABLE_ISSP
   localparam MAX_PROBE_WIDTH = 511;
   localparam TTL_PNF_WIDTH = NUM_OF_WRITE_CTRL_PORTS * PORT_CTRL_AMM_WDATA_WIDTH;

   altsource_probe #(
      .sld_auto_instance_index ("YES"),
      .sld_instance_index      (0),
      .instance_id             ("WORM"),
      .probe_width             (0),
      .source_width            (1),
      .source_initial_value    ("0"),
      .enable_metastability    ("NO")
   ) tg_worm_en_issp (
      .source  (issp_worm_en)
   );   

   altsource_probe #(
		.sld_auto_instance_index ("YES"),
		.sld_instance_index      (0),
		.instance_id             ("TGP"),
		.probe_width             (1),
		.source_width            (0),
		.source_initial_value    ("0"),
		.enable_metastability    ("NO")
	) tg_pass (
		.probe  (&(traffic_gen_pass_all[NUM_OF_WRITE_CTRL_PORTS-1:0]))
	);

   altsource_probe #(
		.sld_auto_instance_index ("YES"),
		.sld_instance_index      (0),
		.instance_id             ("TGF"),
		.probe_width             (1),
		.source_width            (0),
		.source_initial_value    ("0"),
		.enable_metastability    ("NO")
	) tg_fail (
		.probe  (|(traffic_gen_fail_all[NUM_OF_WRITE_CTRL_PORTS-1:0]))
	);

   altsource_probe #(
		.sld_auto_instance_index ("YES"),
		.sld_instance_index      (0),
		.instance_id             ("TGT"),
		.probe_width             (1),
		.source_width            (0),
		.source_initial_value    ("0"),
		.enable_metastability    ("NO")
	) tg_timeout (
		.probe  (|(traffic_gen_timeout_all[NUM_OF_WRITE_CTRL_PORTS-1:0]))
	);

   generate
      genvar i;

      // Pack PNF from all traffic generators into one long bit array to ease processing
      wire [TTL_PNF_WIDTH-1:0] pnf_per_bit_persist_packed = pnf_per_bit_persist[NUM_OF_WRITE_CTRL_PORTS-1:0];

      for (i = 0; i < (TTL_PNF_WIDTH + MAX_PROBE_WIDTH - 1) / MAX_PROBE_WIDTH; i = i + 1)
      begin : gen_pnf
         altsource_probe #(
            .sld_auto_instance_index ("YES"),
            .sld_instance_index      (0),
            .instance_id             (`_get_pnf_id(PNF, i)),
            .probe_width             ((MAX_PROBE_WIDTH * (i+1)) > TTL_PNF_WIDTH ? TTL_PNF_WIDTH - (MAX_PROBE_WIDTH * i) : MAX_PROBE_WIDTH),
            .source_width            (0),
            .source_initial_value    ("0"),
            .enable_metastability    ("NO")
         ) tg_pnf (
            .probe  (pnf_per_bit_persist_packed[((MAX_PROBE_WIDTH * (i+1) - 1) < TTL_PNF_WIDTH-1 ? (MAX_PROBE_WIDTH * (i+1) - 1) : TTL_PNF_WIDTH-1) : (MAX_PROBE_WIDTH * i)])
         );
      end
   endgenerate
`else
   assign issp_worm_en = 1'b0;
`endif

   always_ff @(posedge emif_usr_clk)
   begin
      worm_en[2:0] <= {worm_en[1:0], issp_worm_en};
   end
   always_ff @(posedge emif_usr_clk_sec)
   begin
      worm_en_sec[2:0] <= {worm_en_sec[1:0], issp_worm_en};
   end
   
   // Input signals
   assign amm_ready_all         = {amm_ready_7,         amm_ready_6,         amm_ready_5,         amm_ready_4,         amm_ready_3,         amm_ready_2,         amm_ready_1,         amm_ready_0        };
   assign amm_readdata_all      = {amm_readdata_7,      amm_readdata_6,      amm_readdata_5,      amm_readdata_4,      amm_readdata_3,      amm_readdata_2,      amm_readdata_1,      amm_readdata_0     };
   assign amm_readdatavalid_all = {amm_readdatavalid_7, amm_readdatavalid_6, amm_readdatavalid_5, amm_readdatavalid_4, amm_readdatavalid_3, amm_readdatavalid_2, amm_readdatavalid_1, amm_readdatavalid_0};

   generate
      if (SEPARATE_READ_WRITE_IFS) begin : srw

         genvar i;

         // Instantiate AMM traffic generators
         if (PROTOCOL_ENUM == "PROTOCOL_QDR4") begin : qdr4_sep
            for (i = 0; i < (NUM_OF_CTRL_PORTS/2); ++i)
            begin : gen_avl_mm_driver
               if (USE_SIMPLE_TG) begin : simple
                  altera_emif_avl_tg_driver_simple # (
                     .DEVICE_FAMILY                          (MEGAFUNC_DEVICE_FAMILY),
                     .PROTOCOL_ENUM                          (PROTOCOL_ENUM),
                     .TG_TEST_DURATION                       (TEST_DURATION),
                     .TG_AVL_ADDR_WIDTH                      (PORT_CTRL_AMM_ADDRESS_WIDTH),
                     .TG_AVL_WORD_ADDR_WIDTH                 (AMM_WORD_ADDRESS_WIDTH),
                     .TG_AVL_SIZE_WIDTH                      (PORT_CTRL_AMM_BCOUNT_WIDTH),
                     .TG_AVL_DATA_WIDTH                      (PORT_CTRL_AMM_WDATA_WIDTH),
                     .TG_AVL_BE_WIDTH                        (PORT_CTRL_AMM_BYTEEN_WIDTH),
                     .TG_SEPARATE_READ_WRITE_IFS             (SEPARATE_READ_WRITE_IFS),
                     .AMM_WORD_ADDRESS_DIVISIBLE_BY          (AMM_WORD_ADDRESS_DIVISIBLE_BY),
                     .AMM_BURST_COUNT_DIVISIBLE_BY           (AMM_WORD_ADDRESS_DIVISIBLE_BY)
                  ) inst (
                     .clk                                    (emif_usr_clk),
                     .reset_n                                (emif_usr_reset_n),
                     .avl_ready                              (amm_ready_all[(2*i)+1]),
                     .avl_read_req                           (amm_read_all[(2*i)+1]),
                     .avl_addr                               (amm_address_all[(2*i)+1]),
                     .avl_size                               (amm_burstcount_all[(2*i)+1]),
                     .avl_rdata_valid                        (amm_readdatavalid_all[(2*i)+1]),
                     .avl_rdata                              (amm_readdata_all[(2*i)+1]),
                     .avl_ready_w                            (amm_ready_all[2*i]),
                     .avl_write_req                          (amm_write_all[2*i]),
                     .avl_addr_w                             (amm_address_all[2*i]),
                     .avl_size_w                             (amm_burstcount_all[2*i]),
                     .avl_be                                 (amm_byteenable_all[2*i]),
                     .avl_wdata                              (amm_writedata_all[2*i]),
                     .pass                                   (traffic_gen_pass_all[(2*i)+1]),
                     .fail                                   (traffic_gen_fail_all[(2*i)+1]),
                     .timeout                                (traffic_gen_timeout_all[(2*i)+1]),
                     .pnf_per_bit                            (),
                     .pnf_per_bit_persist                    (pnf_per_bit_persist[(2*i)+1])
                  );
               end else begin : normal
                  altera_emif_avl_tg_driver # (
                     .DEVICE_FAMILY                          (MEGAFUNC_DEVICE_FAMILY),
                     .PROTOCOL_ENUM                          (PROTOCOL_ENUM),
                     .TG_TEST_DURATION                       (TEST_DURATION),
                     .TG_AVL_ADDR_WIDTH                      (PORT_CTRL_AMM_ADDRESS_WIDTH),
                     .TG_AVL_WORD_ADDR_WIDTH                 (AMM_WORD_ADDRESS_WIDTH),
                     .TG_AVL_SIZE_WIDTH                      (PORT_CTRL_AMM_BCOUNT_WIDTH),
                     .TG_AVL_DATA_WIDTH                      (PORT_CTRL_AMM_WDATA_WIDTH),
                     .TG_AVL_BE_WIDTH                        (PORT_CTRL_AMM_BYTEEN_WIDTH),
                     //.TG_RANDOM_BYTE_ENABLE                  (USE_AVL_BYTEEN),
                     .TG_RANDOM_BYTE_ENABLE                  (0),
                     .TG_SEPARATE_READ_WRITE_IFS             (SEPARATE_READ_WRITE_IFS),
                     .TG_GENERATE_LOCAL_RESET_SYNC           (GENERATE_LOCAL_RESET_SYNC),
                     .AMM_WORD_ADDRESS_DIVISIBLE_BY          (AMM_WORD_ADDRESS_DIVISIBLE_BY),
                     .AMM_BURST_COUNT_DIVISIBLE_BY           (AMM_WORD_ADDRESS_DIVISIBLE_BY),
                     .TG_ENABLE_UNIX_ID                      ( (PROTOCOL_ENUM == "PROTOCOL_QDR4") ? 1 : 0 ),
                     .TG_USE_UNIX_ID                         (i)
                  ) inst (
                     .clk                                    (emif_usr_clk),
                     .reset_n                                (emif_usr_reset_n),
                     .avl_ready                              (amm_ready_all[(2*i)+1]),
                     .avl_read_req                           (amm_read_all[(2*i)+1]),
                     .avl_addr                               (amm_address_all[(2*i)+1]),
                     .avl_size                               (amm_burstcount_all[(2*i)+1]),
                     .avl_rdata_valid                        (amm_readdatavalid_all[(2*i)+1]),
                     .avl_rdata                              (amm_readdata_all[(2*i)+1]),
                     .avl_ready_w                            (amm_ready_all[2*i]),
                     .avl_write_req                          (amm_write_all[2*i]),
                     .avl_addr_w                             (amm_address_all[2*i]),
                     .avl_size_w                             (amm_burstcount_all[2*i]),
                     .avl_be                                 (amm_byteenable_all[2*i]),
                     .avl_wdata                              (amm_writedata_all[2*i]),
                     .pass                                   (traffic_gen_pass_all[(2*i)+1]),
                     .fail                                   (traffic_gen_fail_all[(2*i)+1]),
                     .timeout                                (traffic_gen_timeout_all[(2*i)+1]),
                     .pnf_per_bit                            (),
                     .pnf_per_bit_persist                    (pnf_per_bit_persist[(2*i)+1])
                  );
               end

               assign amm_write_all[(2*i)+1] = '0;
               assign amm_writedata_all[(2*i)+1] = '0;
               assign amm_byteenable_all[(2*i)+1] = '0;
               assign amm_read_all[2*i] = '0;
               assign traffic_gen_pass_all[2*i] = '1;   
               assign traffic_gen_fail_all[2*i] = '0;
               assign traffic_gen_timeout_all[2*i] = '0;
               assign pnf_per_bit_persist[2*i] = '0;

               assign amm_beginbursttransfer_all[(2*i)+1] = '0;
               assign amm_beginbursttransfer_all[2*i] = '0;

            end 
            for (i = NUM_OF_CTRL_PORTS; i < 8; ++i) begin : tie_status_signals
               assign amm_write_all[i] = '0;
               assign amm_writedata_all[i] = '0;
               assign amm_byteenable_all[i] = '0;
               assign amm_read_all[i] = '0;
               assign traffic_gen_pass_all[i] = '1;   
               assign traffic_gen_fail_all[i] = '0;
               assign traffic_gen_timeout_all[i] = '0;
               assign pnf_per_bit_persist[i] = '0;
               assign amm_beginbursttransfer_all[i] = '0;
            end
         end
         else begin : non_qdr4_sep
            if (USE_SIMPLE_TG) begin : simple
               altera_emif_avl_tg_driver_simple # (
                  .DEVICE_FAMILY                          (MEGAFUNC_DEVICE_FAMILY),
                  .PROTOCOL_ENUM                          (PROTOCOL_ENUM),
                  .TG_TEST_DURATION                       (TEST_DURATION),
                  .TG_AVL_ADDR_WIDTH                      (PORT_CTRL_AMM_ADDRESS_WIDTH),
                  .TG_AVL_WORD_ADDR_WIDTH                 (AMM_WORD_ADDRESS_WIDTH),
                  .TG_AVL_SIZE_WIDTH                      (PORT_CTRL_AMM_BCOUNT_WIDTH),
                  .TG_AVL_DATA_WIDTH                      (PORT_CTRL_AMM_WDATA_WIDTH),
                  .TG_AVL_BE_WIDTH                        (PORT_CTRL_AMM_BYTEEN_WIDTH),
                  .TG_SEPARATE_READ_WRITE_IFS             (SEPARATE_READ_WRITE_IFS),
                  .AMM_WORD_ADDRESS_DIVISIBLE_BY          (AMM_WORD_ADDRESS_DIVISIBLE_BY),
                  .AMM_BURST_COUNT_DIVISIBLE_BY           (AMM_WORD_ADDRESS_DIVISIBLE_BY)
               ) inst (
                  .clk                                    (emif_usr_clk),
                  .reset_n                                (emif_usr_reset_n),
                  .avl_ready                              (amm_ready_all[0]),
                  .avl_read_req                           (amm_read_all[0]),
                  .avl_addr                               (amm_address_all[0]),
                  .avl_size                               (amm_burstcount_all[0]),
                  .avl_rdata_valid                        (amm_readdatavalid_all[0]),
                  .avl_rdata                              (amm_readdata_all[0]),
                  .avl_ready_w                            (amm_ready_all[1]),
                  .avl_write_req                          (amm_write_all[1]),
                  .avl_addr_w                             (amm_address_all[1]),
                  .avl_size_w                             (amm_burstcount_all[1]),
                  .avl_be                                 (amm_byteenable_all[1]),
                  .avl_wdata                              (amm_writedata_all[1]),
                  .pass                                   (traffic_gen_pass_all[0]),
                  .fail                                   (traffic_gen_fail_all[0]),
                  .timeout                                (traffic_gen_timeout_all[0]),
                  .pnf_per_bit                            (),
                  .pnf_per_bit_persist                    (pnf_per_bit_persist[0])
               );
            end else begin : normal
               altera_emif_avl_tg_driver # (
                  .DEVICE_FAMILY                          (MEGAFUNC_DEVICE_FAMILY),
                  .PROTOCOL_ENUM                          (PROTOCOL_ENUM),
                  .TG_TEST_DURATION                       (TEST_DURATION),
                  .TG_AVL_ADDR_WIDTH                      (PORT_CTRL_AMM_ADDRESS_WIDTH),
                  .TG_AVL_WORD_ADDR_WIDTH                 (AMM_WORD_ADDRESS_WIDTH),
                  .TG_AVL_SIZE_WIDTH                      (PORT_CTRL_AMM_BCOUNT_WIDTH),
                  .TG_AVL_DATA_WIDTH                      (PORT_CTRL_AMM_WDATA_WIDTH),
                  .TG_AVL_BE_WIDTH                        (PORT_CTRL_AMM_BYTEEN_WIDTH),
                  //.TG_RANDOM_BYTE_ENABLE                  (USE_AVL_BYTEEN),
                  .TG_RANDOM_BYTE_ENABLE                  (0),
                  .TG_SEPARATE_READ_WRITE_IFS             (SEPARATE_READ_WRITE_IFS),
                  .TG_GENERATE_LOCAL_RESET_SYNC           (GENERATE_LOCAL_RESET_SYNC),
                  .AMM_WORD_ADDRESS_DIVISIBLE_BY          (AMM_WORD_ADDRESS_DIVISIBLE_BY),
                  .AMM_BURST_COUNT_DIVISIBLE_BY           (AMM_WORD_ADDRESS_DIVISIBLE_BY)
               ) inst (
                  .clk                                    (emif_usr_clk),
                  .reset_n                                (emif_usr_reset_n),
                  .avl_ready                              (amm_ready_all[0]),
                  .avl_read_req                           (amm_read_all[0]),
                  .avl_addr                               (amm_address_all[0]),
                  .avl_size                               (amm_burstcount_all[0]),
                  .avl_rdata_valid                        (amm_readdatavalid_all[0]),
                  .avl_rdata                              (amm_readdata_all[0]),
                  .avl_ready_w                            (amm_ready_all[1]),
                  .avl_write_req                          (amm_write_all[1]),
                  .avl_addr_w                             (amm_address_all[1]),
                  .avl_size_w                             (amm_burstcount_all[1]),
                  .avl_be                                 (amm_byteenable_all[1]),
                  .avl_wdata                              (amm_writedata_all[1]),
                  .pass                                   (traffic_gen_pass_all[0]),
                  .fail                                   (traffic_gen_fail_all[0]),
                  .timeout                                (traffic_gen_timeout_all[0]),
                  .pnf_per_bit                            (),
                  .pnf_per_bit_persist                    (pnf_per_bit_persist[0])
               );
            end

            assign amm_write_all[0] = '0;
            assign amm_read_all[1] = '0;
            assign amm_writedata_all[0] = '0;
            assign amm_byteenable_all[0] = '0;

            for (i = 2; i < 8; ++i)
            begin : tie_amm_signals
               assign amm_write_all[i] = '0;
               assign amm_read_all[i] = '0;
               assign amm_address_all[i] = '0;
               assign amm_writedata_all[i] = '0;
               assign amm_burstcount_all[i] = '0;
               assign amm_byteenable_all[i] = '0;
            end

            assign amm_beginbursttransfer_all = '0;

            for (i = 1; i < 8; ++i)
            begin : tie_status_signals
               assign traffic_gen_pass_all[i] = '0;
               assign traffic_gen_fail_all[i] = '0;
               assign traffic_gen_timeout_all[i] = '0;

               assign pnf_per_bit_persist[i] = '0;
            end
         end

      end else begin: not_srw

         genvar i;

         // Instantiate AMM traffic generators
         for (i = 0; i < 8; ++i)
         begin : gen_avl_mm_driver
            if (i < NUM_OF_CTRL_PORTS) begin
               if (USE_SIMPLE_TG) begin : simple
                  altera_emif_avl_tg_driver_simple # (
                     .DEVICE_FAMILY                          (MEGAFUNC_DEVICE_FAMILY),
                     .PROTOCOL_ENUM                          (PROTOCOL_ENUM),
                     .TG_TEST_DURATION                       (TEST_DURATION),
                     .TG_AVL_ADDR_WIDTH                      (PORT_CTRL_AMM_ADDRESS_WIDTH),
                     .TG_AVL_WORD_ADDR_WIDTH                 (AMM_WORD_ADDRESS_WIDTH),
                     .TG_AVL_SIZE_WIDTH                      (PORT_CTRL_AMM_BCOUNT_WIDTH),
                     .TG_AVL_DATA_WIDTH                      (PORT_CTRL_AMM_WDATA_WIDTH),
                     .TG_AVL_BE_WIDTH                        (PORT_CTRL_AMM_BYTEEN_WIDTH),
                     .TG_SEPARATE_READ_WRITE_IFS             (SEPARATE_READ_WRITE_IFS),
                     .AMM_WORD_ADDRESS_DIVISIBLE_BY          (AMM_WORD_ADDRESS_DIVISIBLE_BY),
                     .AMM_BURST_COUNT_DIVISIBLE_BY           (AMM_WORD_ADDRESS_DIVISIBLE_BY)
                  ) inst (
                     .clk                                    ((PHY_PING_PONG_EN && (i == 1)) ? emif_usr_clk_sec : emif_usr_clk),
                     .reset_n                                ((PHY_PING_PONG_EN && (i == 1)) ? emif_usr_reset_n_sec : emif_usr_reset_n),
                     .avl_ready                              (amm_ready_all[i]),
                     .avl_write_req                          (amm_write_all[i]),
                     .avl_read_req                           (amm_read_all[i]),
                     .avl_addr                               (amm_address_all[i]),
                     .avl_size                               (amm_burstcount_all[i]),
                     .avl_be                                 (amm_byteenable_all[i]),
                     .avl_wdata                              (amm_writedata_all[i]),
                     .avl_rdata_valid                        (amm_readdatavalid_all[i]),
                     .avl_rdata                              (amm_readdata_all[i]),
                     .avl_ready_w                            (1'b0), // unused
                     .avl_addr_w                             (),     // unused
                     .avl_size_w                             (),     // unused
                     .pass                                   (traffic_gen_pass_all[i]),
                     .fail                                   (traffic_gen_fail_all[i]),
                     .timeout                                (traffic_gen_timeout_all[i]),
                     .pnf_per_bit                            (),
                     .pnf_per_bit_persist                    (pnf_per_bit_persist[i])
                  );
               end else begin : normal
                  altera_emif_avl_tg_driver # (
                     .DEVICE_FAMILY                          (MEGAFUNC_DEVICE_FAMILY),
                     .PROTOCOL_ENUM                          (PROTOCOL_ENUM),
                     .TG_TEST_DURATION                       (TEST_DURATION),
                     .TG_AVL_ADDR_WIDTH                      (PORT_CTRL_AMM_ADDRESS_WIDTH),
                     .TG_AVL_WORD_ADDR_WIDTH                 (AMM_WORD_ADDRESS_WIDTH),
                     .TG_AVL_SIZE_WIDTH                      (PORT_CTRL_AMM_BCOUNT_WIDTH),
                     .TG_AVL_DATA_WIDTH                      (PORT_CTRL_AMM_WDATA_WIDTH),
                     .TG_AVL_BE_WIDTH                        (PORT_CTRL_AMM_BYTEEN_WIDTH),
                     //.TG_RANDOM_BYTE_ENABLE                  (USE_AVL_BYTEEN),
                     .TG_RANDOM_BYTE_ENABLE                  (0),
                     .TG_SEPARATE_READ_WRITE_IFS             (SEPARATE_READ_WRITE_IFS),
                     .TG_GENERATE_LOCAL_RESET_SYNC           (GENERATE_LOCAL_RESET_SYNC),
                     .AMM_WORD_ADDRESS_DIVISIBLE_BY          (AMM_WORD_ADDRESS_DIVISIBLE_BY),
                     .AMM_BURST_COUNT_DIVISIBLE_BY           (AMM_WORD_ADDRESS_DIVISIBLE_BY),
                     .TG_ENABLE_UNIX_ID                      ( (PROTOCOL_ENUM == "PROTOCOL_QDR4") ? 1 : 0 ),
                     .TG_USE_UNIX_ID                         (i)
                  ) inst (
                     .clk                                    ((PHY_PING_PONG_EN && (i == 1)) ? emif_usr_clk_sec : emif_usr_clk),
                     .reset_n                                ((PHY_PING_PONG_EN && (i == 1)) ? emif_usr_reset_n_sec : emif_usr_reset_n),
                     .worm_en                                ((PHY_PING_PONG_EN && (i == 1)) ? worm_en_sec[2] : worm_en[2]),
                     .avl_ready                              (amm_ready_all[i]),
                     .avl_write_req                          (amm_write_all[i]),
                     .avl_read_req                           (amm_read_all[i]),
                     .avl_addr                               (amm_address_all[i]),
                     .avl_size                               (amm_burstcount_all[i]),
                     .avl_be                                 (amm_byteenable_all[i]),
                     .avl_wdata                              (amm_writedata_all[i]),
                     .avl_rdata_valid                        (amm_readdatavalid_all[i]),
                     .avl_rdata                              (amm_readdata_all[i]),
                     .avl_ready_w                            (1'b0), // unused
                     .avl_addr_w                             (),     // unused
                     .avl_size_w                             (),     // unused
                     .pass                                   (traffic_gen_pass_all[i]),
                     .fail                                   (traffic_gen_fail_all[i]),
                     .timeout                                (traffic_gen_timeout_all[i]),
                     .pnf_per_bit                            (),
                     .pnf_per_bit_persist                    (pnf_per_bit_persist[i])
                  );
               end

               assign amm_beginbursttransfer_all[i] = '0;

            end else begin
               assign amm_write_all[i] = '0;
               assign amm_read_all[i] = '0;
               assign amm_address_all[i] = '0;
               assign amm_writedata_all[i] = '0;
               assign amm_burstcount_all[i] = '0;
               assign amm_byteenable_all[i] = '0;
               assign amm_beginbursttransfer_all[i] = '0;
            end
         end

         // Tie off unused status signals
         for (i = 0; i < 8; ++i)
         begin : unused_status
            if (i >= NUM_OF_WRITE_CTRL_PORTS) begin
               assign traffic_gen_pass_all[i] = '0;
               assign traffic_gen_fail_all[i] = '0;
               assign traffic_gen_timeout_all[i] = '0;

               assign pnf_per_bit_persist[i] = '0;
            end
         end
      end
   endgenerate

   // Tie off side-band signals
   // The example traffic generator doesn't exercise the side-band signals,
   // but we tie them off via core registers to ensure we get somewhat
   // realistic timing for these paths.
   (* altera_attribute = {"-name MAX_FANOUT 1; -name ADV_NETLIST_OPT_ALLOWED ALWAYS_ALLOW"}*) logic core_zero_tieoff_r /* synthesis dont_merge syn_preserve = 1*/;
   always_ff @(posedge emif_usr_clk or negedge emif_usr_reset_n)
   begin
      if (!emif_usr_reset_n) begin
         core_zero_tieoff_r <= 1'b0;
      end else begin
         core_zero_tieoff_r <= 1'b0;
      end
   end

   (* altera_attribute = {"-name MAX_FANOUT 1; -name ADV_NETLIST_OPT_ALLOWED ALWAYS_ALLOW"}*) logic core_zero_tieoff_r_sec /* synthesis dont_merge syn_preserve = 1*/;
   always_ff @(posedge emif_usr_clk_sec or negedge emif_usr_reset_n_sec)
   begin
      if (!emif_usr_reset_n_sec) begin
         core_zero_tieoff_r_sec <= 1'b0;
      end else begin
         core_zero_tieoff_r_sec <= 1'b0;
      end
   end

   assign ctrl_user_priority_hi_0         = core_zero_tieoff_r;
   assign ctrl_user_priority_hi_1         = core_zero_tieoff_r_sec;
   assign ctrl_auto_precharge_req_0       = core_zero_tieoff_r;
   assign ctrl_auto_precharge_req_1       = core_zero_tieoff_r_sec;
   assign mmr_master_read_0               = core_zero_tieoff_r;
   assign mmr_master_write_0              = core_zero_tieoff_r;
   assign mmr_master_address_0            = {PORT_CTRL_MMR_MASTER_ADDRESS_WIDTH{core_zero_tieoff_r}};
   assign mmr_master_writedata_0          = {PORT_CTRL_MMR_MASTER_WDATA_WIDTH{core_zero_tieoff_r}};
   assign mmr_master_burstcount_0         = {PORT_CTRL_MMR_MASTER_BCOUNT_WIDTH{core_zero_tieoff_r}};
   assign mmr_master_beginbursttransfer_0 = core_zero_tieoff_r;
   assign mmr_master_read_1               = core_zero_tieoff_r_sec;
   assign mmr_master_write_1              = core_zero_tieoff_r_sec;
   assign mmr_master_address_1            = {PORT_CTRL_MMR_MASTER_ADDRESS_WIDTH{core_zero_tieoff_r_sec}};
   assign mmr_master_writedata_1          = {PORT_CTRL_MMR_MASTER_WDATA_WIDTH{core_zero_tieoff_r_sec}};
   assign mmr_master_burstcount_1         = {PORT_CTRL_MMR_MASTER_BCOUNT_WIDTH{core_zero_tieoff_r_sec}};
   assign mmr_master_beginbursttransfer_1 = core_zero_tieoff_r_sec;

endmodule
