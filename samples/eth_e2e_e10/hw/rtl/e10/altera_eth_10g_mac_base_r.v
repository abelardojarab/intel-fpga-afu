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


module altera_eth_10g_mac_base_r (

	input wire 			csr_clk,
	input wire			csr_rst_n,
	input wire			tx_rst_n,
	input wire			rx_rst_n,
	
	input tx_clk_312,
	input rx_clk_312,
	input tx_clk_156,
	input rx_clk_156,
		
	input iopll_locked,

	// serdes controls
	output tx_analogreset,
	output tx_digitalreset,
	output rx_analogreset,
	output rx_digitalreset,
	input tx_cal_busy,
	input rx_cal_busy,	
	input rx_is_lockedtodata,
	input atx_pll_locked,
	output tx_ready_export,
	output rx_ready_export,
    
    // serdes data pipe
	input xgmii_tx_valid,
    output [7:0]   xgmii_tx_control,
    output [63:0]  xgmii_tx_data,
	input [7:0]    xgmii_rx_control,
	input [63:0]   xgmii_rx_data,
	input xgmii_rx_valid,	
		
	// csr interface
	input wire			csr_read,
	input wire			csr_write,
	input wire	[31:0]	csr_writedata,
	output wire	[31:0]	csr_readdata,
	input wire	[15:0]	csr_address,
	output wire 		csr_waitrequest
);

wire			mac_csr_read_32;
wire			mac_csr_write_32;
wire	[31:0]	mac_csr_readdata_32;
wire	[31:0]	mac_csr_writedata_32;
wire			mac_csr_waitrequest_32;
wire	[9:0]	mac_csr_address_32;

wire			mac_csr_read_64;
wire			mac_csr_write_64;
wire	[31:0]	mac_csr_readdata_64;
wire	[31:0]	mac_csr_writedata_64;
wire			mac_csr_waitrequest_64;
wire	[13:0]	mac_csr_address_64;

wire			phy_csr_read;
wire			phy_csr_write;
wire	[31:0]	phy_csr_readdata;
wire	[31:0]	phy_csr_writedata;
wire			phy_csr_waitrequest;
wire	[9:0]	phy_csr_address;

wire	[1:0]	avalon_st_pause_data;
wire	[1:0]	avalon_st_pause_data_sync;


wire    [63:0]  tx_sc_fifo_in_data;          
wire            tx_sc_fifo_in_valid;         
wire            tx_sc_fifo_in_ready;         
wire            tx_sc_fifo_in_startofpacket; 
wire            tx_sc_fifo_in_endofpacket;   
wire    [2:0]   tx_sc_fifo_in_empty;         
wire            tx_sc_fifo_in_error; 
        
wire    [63:0]  tx_sc_fifo_out_data;         
wire            tx_sc_fifo_out_valid;        
wire            tx_sc_fifo_out_ready;        
wire            tx_sc_fifo_out_startofpacket;
wire            tx_sc_fifo_out_endofpacket;  
wire    [2:0]   tx_sc_fifo_out_empty;        
wire            tx_sc_fifo_out_error; 

wire    [63:0]  rx_sc_fifo_in_data;          
wire            rx_sc_fifo_in_valid;         
wire            rx_sc_fifo_in_ready;         
wire            rx_sc_fifo_in_startofpacket; 
wire            rx_sc_fifo_in_endofpacket;   
wire    [2:0]   rx_sc_fifo_in_empty;         
wire    [5:0]   rx_sc_fifo_in_error;   
      
wire    [63:0]  rx_sc_fifo_out_data;         
wire            rx_sc_fifo_out_valid;        
wire            rx_sc_fifo_out_ready;        
wire            rx_sc_fifo_out_startofpacket;
wire            rx_sc_fifo_out_endofpacket;  
wire    [2:0]   rx_sc_fifo_out_empty;        
wire    [5:0]   rx_sc_fifo_out_error;         



wire    [2:0]   tx_sc_fifo_csr_address;
wire            tx_sc_fifo_csr_read;
wire            tx_sc_fifo_csr_write;
wire    [31:0]  tx_sc_fifo_csr_readdata;
wire    [31:0]  tx_sc_fifo_csr_writedata;

wire    [2:0]   rx_sc_fifo_csr_address;
wire            rx_sc_fifo_csr_read;
wire            rx_sc_fifo_csr_write;
wire    [31:0]  rx_sc_fifo_csr_readdata;
wire    [31:0]  rx_sc_fifo_csr_writedata;

wire    [11:0]  eth_gen_mon_avalon_anti_slave_0_address;   
wire            eth_gen_mon_avalon_anti_slave_0_write;    
wire            eth_gen_mon_avalon_anti_slave_0_read;      
wire    [31:0]  eth_gen_mon_avalon_anti_slave_0_readdata;  
wire    [31:0]  eth_gen_mon_avalon_anti_slave_0_writedata;
wire            eth_gen_mon_avalon_anti_slave_0_waitrequest;


wire    sync_rx_rst_n;
wire    sync_rx_half_rst_n;
wire    sync_tx_half_rst_n;
wire    sync_tx_rst_n;


wire    sync_tx_half_rst;
wire    sync_rx_half_rst;

wire    sync_tx_rst;
wire    sync_rx_rst;

assign sync_tx_rst_n = ~sync_tx_rst;
assign sync_rx_rst_n = ~sync_rx_rst;

assign sync_rx_half_rst_n = ~sync_rx_half_rst;
assign sync_tx_half_rst_n = ~sync_tx_half_rst;

wire    [31:0]  mac_in_data;
wire            mac_in_valid;
wire            mac_in_ready;
wire            mac_in_startofpacket;
wire            mac_in_endofpacket;
wire    [1:0]   mac_in_empty;
wire    [0:0]   mac_in_error;

wire    [31:0]  mac_out_data;
wire            mac_out_valid;
wire            mac_out_ready;
wire            mac_out_startofpacket;
wire            mac_out_endofpacket;
wire    [1:0]   mac_out_empty;
wire    [5:0]   mac_out_error;


wire [63:0] tx_st_adapter_0_in_0_data;          
wire        tx_st_adapter_0_in_0_valid;         
wire        tx_st_adapter_0_in_0_ready;        
wire        tx_st_adapter_0_in_0_startofpacket; 
wire        tx_st_adapter_0_in_0_endofpacket;   
wire [2:0]  tx_st_adapter_0_in_0_empty;         
wire [0:0]  tx_st_adapter_0_in_0_error;         
wire [31:0] tx_st_adapter_0_out_0_data;         
wire        tx_st_adapter_0_out_0_valid;        
wire        tx_st_adapter_0_out_0_ready;        
wire        tx_st_adapter_0_out_0_startofpacket;
wire        tx_st_adapter_0_out_0_endofpacket;  

wire [1:0]  tx_st_adapter_0_out_0_empty;        

wire [1:0]  tx_st_adapter_0_out_0_error;

wire [31:0] rx_st_adapter_0_in_0_data;          
wire        rx_st_adapter_0_in_0_valid;         
wire        rx_st_adapter_0_in_0_ready;         
wire        rx_st_adapter_0_in_0_startofpacket; 
wire        rx_st_adapter_0_in_0_endofpacket;   
wire [1:0]  rx_st_adapter_0_in_0_empty;         
wire        rx_st_adapter_0_in_0_error;         
wire [63:0] rx_st_adapter_0_out_0_data;         
wire        rx_st_adapter_0_out_0_valid;        
wire        rx_st_adapter_0_out_0_ready;        
wire        rx_st_adapter_0_out_0_startofpacket;
wire        rx_st_adapter_0_out_0_endofpacket;  
wire [2:0]  rx_st_adapter_0_out_0_empty;        
wire [5:0]  rx_st_adapter_0_out_0_error;  


    
    altera_std_synchronizer #(.depth(2)) almost_empty_sync (
        .clk(tx_clk_312),
        .reset_n(tx_rst_n),
        .din(avalon_st_pause_data[0]),
        .dout(avalon_st_pause_data_sync[0])

    );

    altera_std_synchronizer #(.depth(2)) almost_full_sync (
        .clk(tx_clk_312),
        .reset_n(tx_rst_n),
        .din(avalon_st_pause_data[1]),
        .dout(avalon_st_pause_data_sync[1])
    );



wire tx_reset_n = ~tx_reset;
wire rx_reset_n = ~rx_reset;

wire [71:0] xgmii_tx;
assign xgmii_tx_data = {
   xgmii_tx[70:63],
   xgmii_tx[61:54],
   xgmii_tx[52:45],
   xgmii_tx[43:36],
   xgmii_tx[34:27],
   xgmii_tx[25:18],
   xgmii_tx[16:9],
   xgmii_tx[7:0]
};

assign xgmii_tx_control = {
   xgmii_tx[71],
   xgmii_tx[62],
   xgmii_tx[53],
   xgmii_tx[44],
   xgmii_tx[35],
   xgmii_tx[26],
   xgmii_tx[17],
   xgmii_tx[8]
};

wire [71:0] xgmii_rx = {
   xgmii_rx_control[7], xgmii_rx_data[63:56],
   xgmii_rx_control[6], xgmii_rx_data[55:48],
   xgmii_rx_control[5], xgmii_rx_data[47:40],
   xgmii_rx_control[4], xgmii_rx_data[39:32],
   xgmii_rx_control[3], xgmii_rx_data[31:24],
   xgmii_rx_control[2], xgmii_rx_data[23:16],
   xgmii_rx_control[1], xgmii_rx_data[15:8],
   xgmii_rx_control[0], xgmii_rx_data[7:0]};
   
altera_eth_10g_mac mac_inst (
	.csr_read					(mac_csr_read_32),
	.csr_write					(mac_csr_write_32),
	.csr_writedata				(mac_csr_writedata_32),
	.csr_readdata				(mac_csr_readdata_32),
	.csr_waitrequest			(mac_csr_waitrequest_32),
	.csr_address				(mac_csr_address_32),
	.csr_clk					(csr_clk),
	.csr_rst_n					(csr_rst_n),
	.tx_rst_n					(tx_reset_n),
	.rx_rst_n					(rx_reset_n),
	.avalon_st_tx_startofpacket	(mac_in_startofpacket),
	.avalon_st_tx_endofpacket	(mac_in_endofpacket),
	.avalon_st_tx_valid			(mac_in_valid),
	.avalon_st_tx_data			(mac_in_data),
	.avalon_st_tx_empty			(mac_in_empty),
	.avalon_st_tx_error			(mac_in_error),
	.avalon_st_tx_ready			(mac_in_ready),
	.avalon_st_pause_data		(avalon_st_pause_data_sync),
	.avalon_st_txstatus_valid	(avalon_st_txstatus_valid),
	.avalon_st_txstatus_data	(avalon_st_txstatus_data),
	.avalon_st_txstatus_error	(avalon_st_txstatus_error),
	.link_fault_status_xgmii_rx_data	(),
	.avalon_st_rx_data			(mac_out_data),
	.avalon_st_rx_startofpacket	(mac_out_startofpacket),
	.avalon_st_rx_valid			(mac_out_valid),
	.avalon_st_rx_empty			(mac_out_empty),
	.avalon_st_rx_error			(mac_out_error),
	.avalon_st_rx_ready			(mac_out_ready),
	.avalon_st_rx_endofpacket	(mac_out_endofpacket),
	.avalon_st_rxstatus_valid	(avalon_st_rxstatus_valid),
	.avalon_st_rxstatus_data	(avalon_st_rxstatus_data),
	.avalon_st_rxstatus_error	(avalon_st_rxstatus_error),
    .rx_156_25_clk          (rx_clk_156),
    .rx_312_5_clk           (rx_clk_312),
    .tx_156_25_clk          (tx_clk_156),
    .tx_312_5_clk           (tx_clk_312),
	.xgmii_rx				(xgmii_rx),
	.xgmii_tx				(xgmii_tx)
);


reset_control	reset_controller_inst(
	.clock				(csr_clk),
    .reset				(~csr_rst_n),
    .pll_powerdown		(pll_powerdown),
    .tx_analogreset		(tx_analogreset),
    .tx_digitalreset	(tx_digitalreset),
    .tx_ready			(tx_ready_export),
    .pll_locked			(atx_pll_locked),
    .pll_select			(1'b0),
    .tx_cal_busy		(tx_cal_busy),
    .rx_analogreset		(rx_analogreset),
    .rx_digitalreset	(rx_digitalreset),
    .rx_ready			(rx_ready_export),
    .rx_is_lockedtodata	(rx_is_lockedtodata),
    .rx_cal_busy 		(rx_cal_busy)
);

altera_reset_synchronizer #(
        .DEPTH      (2),
        .ASYNC_RESET(1)
    ) tx_rst_sync (
        .clk        (tx_clk_312),
        .reset_in   (~tx_rst_n),
        .reset_out  (tx_reset)
    );

altera_reset_synchronizer #(
        .DEPTH      (2),
        .ASYNC_RESET(1)
    ) rx_rst_sync (
        .clk        (rx_clk_312),
        .reset_in   (~rx_rst_n),
        .reset_out  (rx_reset)
    );

address_decode address_decoder_inst (

	.clk_csr_clk												(csr_clk),                                                
    .csr_reset_n												(csr_rst_n),

    .tx_xcvr_half_clk_clk                                       (tx_clk_156),     
    .sync_tx_half_rst_reset_n                                   (sync_tx_half_rst_n), 
    .tx_xcvr_clk_clk                                            (tx_clk_312),          
    .sync_tx_rst_reset_n                                        (sync_tx_rst_n),      
    .rx_xcvr_clk_clk                                            (rx_clk_312),          
    .sync_rx_rst_reset_n                                        (sync_rx_rst_n),     

    .merlin_master_translator_0_avalon_anti_master_0_address	(csr_address),    
    .merlin_master_translator_0_avalon_anti_master_0_waitrequest(csr_waitrequest),
    .merlin_master_translator_0_avalon_anti_master_0_read		(csr_read),       
    .merlin_master_translator_0_avalon_anti_master_0_readdata	(csr_readdata),   
    .merlin_master_translator_0_avalon_anti_master_0_write		(csr_write),      
    .merlin_master_translator_0_avalon_anti_master_0_writedata	(csr_writedata),  
    .mac_avalon_anti_slave_0_address							(mac_csr_address_64[12:0]),                            
    .mac_avalon_anti_slave_0_write								(mac_csr_write_64),                              
    .mac_avalon_anti_slave_0_read								(mac_csr_read_64),                               
    .mac_avalon_anti_slave_0_readdata							(mac_csr_readdata_64),                           
    .mac_avalon_anti_slave_0_writedata							(mac_csr_writedata_64),                          
    .mac_avalon_anti_slave_0_waitrequest						(mac_csr_waitrequest_64),                        
    .phy_avalon_anti_slave_0_address							(phy_csr_address),                            
    .phy_avalon_anti_slave_0_write								(phy_csr_write),                              
    .phy_avalon_anti_slave_0_read								(phy_csr_read),                               
    .phy_avalon_anti_slave_0_readdata							(phy_csr_readdata),                           
    .phy_avalon_anti_slave_0_writedata							(phy_csr_writedata),                          
    .phy_avalon_anti_slave_0_waitrequest                        (phy_csr_waitrequest),
    
    .tx_sc_fifo_avalon_anti_slave_0_address                     (tx_sc_fifo_csr_address),    
    .tx_sc_fifo_avalon_anti_slave_0_write                       (tx_sc_fifo_csr_write),      
    .tx_sc_fifo_avalon_anti_slave_0_read                        (tx_sc_fifo_csr_read),       
    .tx_sc_fifo_avalon_anti_slave_0_readdata                    (tx_sc_fifo_csr_readdata),   
    .tx_sc_fifo_avalon_anti_slave_0_writedata                   (tx_sc_fifo_csr_writedata),  
    
    .rx_sc_fifo_avalon_anti_slave_0_address                     (rx_sc_fifo_csr_address),    
    .rx_sc_fifo_avalon_anti_slave_0_write                       (rx_sc_fifo_csr_write),      
    .rx_sc_fifo_avalon_anti_slave_0_read                        (rx_sc_fifo_csr_read),       
    .rx_sc_fifo_avalon_anti_slave_0_readdata                    (rx_sc_fifo_csr_readdata),   
    .rx_sc_fifo_avalon_anti_slave_0_writedata                   (rx_sc_fifo_csr_writedata),  
    
    .eth_gen_mon_avalon_anti_slave_0_address                    (eth_gen_mon_avalon_anti_slave_0_address),   
    .eth_gen_mon_avalon_anti_slave_0_write                      (eth_gen_mon_avalon_anti_slave_0_write),     
    .eth_gen_mon_avalon_anti_slave_0_read                       (eth_gen_mon_avalon_anti_slave_0_read),      
    .eth_gen_mon_avalon_anti_slave_0_readdata                   (eth_gen_mon_avalon_anti_slave_0_readdata),  
    .eth_gen_mon_avalon_anti_slave_0_writedata                  (eth_gen_mon_avalon_anti_slave_0_writedata),
    .eth_gen_mon_avalon_anti_slave_0_waitrequest                (eth_gen_mon_avalon_anti_slave_0_waitrequest)
    
    
);    


    
sc_fifo fifo_inst(

    .tx_sc_fifo_csr_address                 (tx_sc_fifo_csr_address),       
	.tx_sc_fifo_csr_read                    (tx_sc_fifo_csr_read),          
	.tx_sc_fifo_csr_write                   (tx_sc_fifo_csr_write),         
	.tx_sc_fifo_csr_readdata                (tx_sc_fifo_csr_readdata),      
	.tx_sc_fifo_csr_writedata               (tx_sc_fifo_csr_writedata),     
	.rx_sc_fifo_csr_address                 (rx_sc_fifo_csr_address),       
	.rx_sc_fifo_csr_read                    (rx_sc_fifo_csr_read),          
	.rx_sc_fifo_csr_write                   (rx_sc_fifo_csr_write),         
	.rx_sc_fifo_csr_readdata                (rx_sc_fifo_csr_readdata),      
	.rx_sc_fifo_csr_writedata               (rx_sc_fifo_csr_writedata),     
	.tx_sc_fifo_clk_clk                     (tx_clk_156),           
	.tx_sc_fifo_clk_reset_reset             (~sync_tx_half_rst_n),   
	.tx_sc_fifo_in_data                     (tx_sc_fifo_in_data),           
	.tx_sc_fifo_in_valid                    (tx_sc_fifo_in_valid),          
	.tx_sc_fifo_in_ready                    (tx_sc_fifo_in_ready),          
	.tx_sc_fifo_in_startofpacket            (tx_sc_fifo_in_startofpacket),  
	.tx_sc_fifo_in_endofpacket              (tx_sc_fifo_in_endofpacket),    
	.tx_sc_fifo_in_empty                    (tx_sc_fifo_in_empty),          
	.tx_sc_fifo_in_error                    (tx_sc_fifo_in_error),          
	.tx_sc_fifo_out_data                    (tx_sc_fifo_out_data),          
	.tx_sc_fifo_out_valid                   (tx_sc_fifo_out_valid),         
	.tx_sc_fifo_out_ready                   (tx_sc_fifo_out_ready),         
	.tx_sc_fifo_out_startofpacket           (tx_sc_fifo_out_startofpacket), 
	.tx_sc_fifo_out_endofpacket             (tx_sc_fifo_out_endofpacket),   
	.tx_sc_fifo_out_empty                   (tx_sc_fifo_out_empty),         
	.tx_sc_fifo_out_error                   (tx_sc_fifo_out_error),         
	.rx_sc_fifo_clk_clk                     (rx_clk_156),           
	.rx_sc_fifo_clk_reset_reset             (~sync_tx_half_rst_n),   
	.rx_sc_fifo_almost_full_data            (avalon_st_pause_data[1]),    
	.rx_sc_fifo_almost_empty_data           (avalon_st_pause_data[0]),    
	.rx_sc_fifo_in_data                     (rx_sc_fifo_in_data),           
	.rx_sc_fifo_in_valid                    (rx_sc_fifo_in_valid),          
	.rx_sc_fifo_in_ready                    (rx_sc_fifo_in_ready),          
	.rx_sc_fifo_in_startofpacket            (rx_sc_fifo_in_startofpacket),  
	.rx_sc_fifo_in_endofpacket              (rx_sc_fifo_in_endofpacket),    
	.rx_sc_fifo_in_empty                    (rx_sc_fifo_in_empty),          
	.rx_sc_fifo_in_error                    (rx_sc_fifo_in_error),          
	.rx_sc_fifo_out_data                    (rx_sc_fifo_out_data),          
	.rx_sc_fifo_out_valid                   (rx_sc_fifo_out_valid),         
	.rx_sc_fifo_out_ready                   (rx_sc_fifo_out_ready),         
	.rx_sc_fifo_out_startofpacket           (rx_sc_fifo_out_startofpacket), 
	.rx_sc_fifo_out_endofpacket             (rx_sc_fifo_out_endofpacket),   
	.rx_sc_fifo_out_empty                   (rx_sc_fifo_out_empty),         
	.rx_sc_fifo_out_error                   (rx_sc_fifo_out_error)          
); 

// generator and checker and also loopback
eth_std_traffic_controller_top gen_mon_inst (

//here  clocking OK?
    .clk                 (tx_clk_156),
	.reset_n             (sync_tx_half_rst_n),

	.avl_mm_read         (eth_gen_mon_avalon_anti_slave_0_read),
	.avl_mm_write        (eth_gen_mon_avalon_anti_slave_0_write),
	.avl_mm_waitrequest  (eth_gen_mon_avalon_anti_slave_0_waitrequest),
	.avl_mm_baddress     (eth_gen_mon_avalon_anti_slave_0_address),
	.avl_mm_readdata     (eth_gen_mon_avalon_anti_slave_0_readdata),
	.avl_mm_writedata    (eth_gen_mon_avalon_anti_slave_0_writedata),

    .mac_rx_status_data  (40'b0),
	.mac_rx_status_valid (1'b0),
	.mac_rx_status_error (1'b0),
	.stop_mon            (1'b0),
	.mon_active          (),
	.mon_done            (),
	.mon_error           (),

    .avl_st_tx_data      (tx_sc_fifo_in_data),
	.avl_st_tx_empty     (tx_sc_fifo_in_empty),
	.avl_st_tx_eop       (tx_sc_fifo_in_endofpacket),
	.avl_st_tx_error     (tx_sc_fifo_in_error),
	.avl_st_tx_ready     (tx_sc_fifo_in_ready),
	.avl_st_tx_sop       (tx_sc_fifo_in_startofpacket),
	.avl_st_tx_val       (tx_sc_fifo_in_valid),             

    .avl_st_rx_data      (rx_sc_fifo_out_data),
	.avl_st_rx_empty     (rx_sc_fifo_out_empty),
	.avl_st_rx_eop       (rx_sc_fifo_out_endofpacket),
	.avl_st_rx_error     (rx_sc_fifo_out_error),
	.avl_st_rx_ready     (rx_sc_fifo_out_ready),
	.avl_st_rx_sop       (rx_sc_fifo_out_startofpacket),
	.avl_st_rx_val       (rx_sc_fifo_out_valid)


);
      

// csr adapter
altera_eth_avalon_mm_adapter csr_adapter_inst(

    // Avalon Slave Interface
    .sl_clock               (csr_clk),
    .sl_reset               (~csr_rst_n),    
    .sl_csr_readdata_o      (mac_csr_readdata_64),
    .sl_csr_address_i       (mac_csr_address_64[12:0]),
    .sl_csr_read_i          (mac_csr_read_64),
    .sl_csr_write_i         (mac_csr_write_64),
    .sl_csr_writedata_i     (mac_csr_writedata_64),
    .sl_csr_waitrequest_o   (mac_csr_waitrequest_64),

    // Avalon Master Interface
    .ms_clock               (),
    .ms_reset               (),    
    .ms_csr_readdata_i      (mac_csr_readdata_32),
    .ms_csr_address_o       (mac_csr_address_32),
    .ms_csr_read_o          (mac_csr_read_32),
    .ms_csr_write_o         (mac_csr_write_32),
    .ms_csr_writedata_o     (mac_csr_writedata_32),
    .ms_csr_waitrequest_i   (mac_csr_waitrequest_32)

);

// tx path clock by rx

altera_eth_avalon_st_adapter dc_fifo_adapter_inst(

	.csr_tx_adptdcff_rdwtrmrk	  (3'b010),
	.csr_tx_adptdcff_vldpkt_minwt (3'b010),
	.csr_tx_adptdcff_rdwtrmrk_dis (1'b0),

    .avalon_st_tx_clk_312         (tx_clk_312),    
    .avalon_st_tx_312_reset_n     (sync_tx_rst_n),    
    .avalon_st_tx_clk_156         (tx_clk_156),          
    .avalon_st_tx_156_reset_n     (sync_tx_half_rst_n),
    
    .avalon_st_tx_156_ready       (tx_sc_fifo_out_ready),         
    .avalon_st_tx_156_valid       (tx_sc_fifo_out_valid),         
    .avalon_st_tx_156_data        (tx_sc_fifo_out_data),          
    .avalon_st_tx_156_error       (tx_sc_fifo_out_error),         
    .avalon_st_tx_156_startofpacket(tx_sc_fifo_out_startofpacket), 
    .avalon_st_tx_156_endofpacket (tx_sc_fifo_out_endofpacket),   
    .avalon_st_tx_156_empty       (tx_sc_fifo_out_empty),
    
    .avalon_st_tx_312_ready       (mac_in_ready),        
    .avalon_st_tx_312_valid       (mac_in_valid),        
    .avalon_st_tx_312_data        (mac_in_data),         
    .avalon_st_tx_312_error       (mac_in_error),        
    .avalon_st_tx_312_startofpacket(mac_in_startofpacket),
    .avalon_st_tx_312_endofpacket (mac_in_endofpacket),  
    .avalon_st_tx_312_empty       (mac_in_empty),

    //rx clock and reset    
    .avalon_st_rx_clk_312         (rx_clk_312),          
    .avalon_st_rx_312_reset_n     (sync_rx_rst_n),    
    .avalon_st_rx_clk_156         (rx_clk_156),          
    .avalon_st_rx_156_reset_n     (sync_tx_half_rst_n),
 
    .avalon_st_rx_312_ready       (mac_out_ready),         
    .avalon_st_rx_312_valid       (mac_out_valid),         
    .avalon_st_rx_312_data        (mac_out_data),          
    .avalon_st_rx_312_error       (mac_out_error),         
    .avalon_st_rx_312_startofpacket(mac_out_startofpacket), 
    .avalon_st_rx_312_endofpacket (mac_out_endofpacket),   
    .avalon_st_rx_312_empty       (mac_out_empty),  

    .avalon_st_rx_156_ready      (rx_sc_fifo_in_ready),        
    .avalon_st_rx_156_valid      (rx_sc_fifo_in_valid),        
    .avalon_st_rx_156_data       (rx_sc_fifo_in_data),         
    .avalon_st_rx_156_error      (rx_sc_fifo_in_error),        
    .avalon_st_rx_156_startofpacket(rx_sc_fifo_in_startofpacket),
    .avalon_st_rx_156_endofpacket(rx_sc_fifo_in_endofpacket),  
    .avalon_st_rx_156_empty      (rx_sc_fifo_in_empty),

    // TX 1588 signals at 156mhz domain
    .tx_egress_timestamp_request_valid_156        (1'b0),
    .tx_egress_timestamp_request_fingerprint_156  (4'b0),    
    .tx_etstamp_ins_ctrl_timestamp_insert_156     (1'b0),
    .tx_etstamp_ins_ctrl_timestamp_format_156     (1'b0),
    .tx_etstamp_ins_ctrl_residence_time_update_156(1'b0),
    .tx_etstamp_ins_ctrl_ingress_timestamp_96b_156(96'b0),
    .tx_etstamp_ins_ctrl_ingress_timestamp_64b_156(64'b0),
    .tx_etstamp_ins_ctrl_residence_time_calc_format_156(1'b0),
    .tx_etstamp_ins_ctrl_checksum_zero_156        (1'b0),
    .tx_etstamp_ins_ctrl_checksum_correct_156     (1'b0),
    .tx_etstamp_ins_ctrl_offset_timestamp_156     (16'b0),
    .tx_etstamp_ins_ctrl_offset_correction_field_156(16'b0),
    .tx_etstamp_ins_ctrl_offset_checksum_field_156(16'b0),
    .tx_etstamp_ins_ctrl_offset_checksum_correction_156(16'b0),
    
    // TX 1588 signals at 312mhz domain

    .tx_egress_timestamp_96b_data_312             (96'b0),
    .tx_egress_timestamp_96b_valid_312            (1'b0),
    .tx_egress_timestamp_96b_fingerprint_312      (4'b0),
    .tx_egress_timestamp_64b_data_312             (64'b0),
    .tx_egress_timestamp_64b_valid_312            (1'b0),
    .tx_egress_timestamp_64b_fingerprint_312      (4'b0),
    

    //TX Status Signals
    .avalon_st_txstatus_valid_156                 (),
    .avalon_st_txstatus_data_156                  (),
    .avalon_st_txstatus_error_156                 (),
    
    .avalon_st_txstatus_valid_312                 (1'b0),
    .avalon_st_txstatus_data_312                  (40'b0),
    .avalon_st_txstatus_error_312                 (7'b0),
    
    //TX PFC Status Signals
    .avalon_st_tx_pfc_data_156                    (16'b0),       
    .avalon_st_tx_pfc_status_valid_312            (1'b0),
    .avalon_st_tx_pfc_status_data_312             (16'b0),  

    // TX Pause Data
    .avalon_st_tx_pause_data_156                 (2'b0),


    // Pause Quanta (For TX only variant)
    .avalon_st_tx_pause_length_valid_156          (1'b0),
    .avalon_st_tx_pause_length_data_156           (16'b0),     

    // RX 1588 signals
    .rx_ingress_timestamp_96b_valid_312           (1'b0),
    .rx_ingress_timestamp_96b_data_312            (96'b0),
    .rx_ingress_timestamp_64b_valid_312           (1'b0),
    .rx_ingress_timestamp_64b_data_312            (64'b0),

    //RX Status Signals

    
   .avalon_st_rxstatus_valid_312                 (1'b0),
   .avalon_st_rxstatus_data_312                  (40'b0),
   .avalon_st_rxstatus_error_312                 (7'b0),

    //RX PFC Status Signals
    .avalon_st_rx_pfc_pause_data_312              (8'b0),
    .avalon_st_rx_pfc_status_valid_312            (1'b0),
    .avalon_st_rx_pfc_status_data_312             (16'b0),      
    
    
    // Pause Quanta (For RX only variant)
    .avalon_st_rx_pause_length_valid_312           (1'b0),
    .avalon_st_rx_pause_length_data_312            (16'b0),

    .tx_egress_timestamp_96b_data_156			(),
    .tx_egress_timestamp_96b_valid_156			(),
    .tx_egress_timestamp_96b_fingerprint_156		(),
    .tx_egress_timestamp_64b_data_156			(),
    .tx_egress_timestamp_64b_valid_156			(),
    .tx_egress_timestamp_64b_fingerprint_156		(),
    .tx_egress_timestamp_request_valid_312		(),
    .tx_egress_timestamp_request_fingerprint_312	(),
    .tx_etstamp_ins_ctrl_timestamp_insert_312		(),
    .tx_etstamp_ins_ctrl_timestamp_format_312		(),

    .tx_etstamp_ins_ctrl_residence_time_update_312	(),
    .tx_etstamp_ins_ctrl_ingress_timestamp_96b_312	(),
    .tx_etstamp_ins_ctrl_ingress_timestamp_64b_312	(),
    .tx_etstamp_ins_ctrl_residence_time_calc_format_312	(),
    .tx_etstamp_ins_ctrl_checksum_zero_312		(),
    .tx_etstamp_ins_ctrl_checksum_correct_312		(),
    .tx_etstamp_ins_ctrl_offset_timestamp_312		(),
    .tx_etstamp_ins_ctrl_offset_correction_field_312	(),
    .tx_etstamp_ins_ctrl_offset_checksum_field_312	(),
    .tx_etstamp_ins_ctrl_offset_checksum_correction_312	(),

    .avalon_st_tx_pfc_data_312				(),
    .avalon_st_tx_pfc_status_valid_156			(),
    .avalon_st_tx_pfc_status_data_156			(),
    .avalon_st_tx_pause_data_312			(),
    .avalon_st_tx_pause_length_valid_312		(),
    .avalon_st_tx_pause_length_data_312			(),
    .rx_ingress_timestamp_96b_valid_156			(),
    .rx_ingress_timestamp_96b_data_156			(),
    .rx_ingress_timestamp_64b_valid_156			(),
    .rx_ingress_timestamp_64b_data_156			(),

    .avalon_st_rxstatus_valid_156			(),
    .avalon_st_rxstatus_data_156			(),
    .avalon_st_rxstatus_error_156			(),
    .avalon_st_rx_pfc_pause_data_156			(),
    .avalon_st_rx_pfc_status_valid_156			(),
    .avalon_st_rx_pfc_status_data_156			(),
    .avalon_st_rx_pause_length_valid_156		(),
    .avalon_st_rx_pause_length_data_156			()

);

altera_reset_synchronizer # (
        .ASYNC_RESET(1),
        .DEPTH      (4)  
    ) tx_reset_synchronizer_inst(
        .clk(tx_clk_312),
        .reset_in(~tx_rst_n),
        .reset_out(sync_tx_rst)
    );

altera_reset_synchronizer # (
        .ASYNC_RESET(1),
        .DEPTH      (4)  
    ) rx_reset_synchronizer_inst(
        .clk(rx_clk_312),
        .reset_in(~rx_rst_n),
        .reset_out(sync_rx_rst)
    );   

    
altera_reset_synchronizer # (
        .ASYNC_RESET(1),
        .DEPTH      (4)  
    ) tx_half_clk_reset_synchronizer_inst(
        .clk(tx_clk_156),
        .reset_in(~tx_rst_n),
        .reset_out(sync_tx_half_rst)
    );

altera_reset_synchronizer # (
        .ASYNC_RESET(1),
        .DEPTH      (4)  
    ) rx_half_clk_reset_synchronizer_inst(
        .clk(rx_clk_156),
        .reset_in(~rx_rst_n),
        .reset_out(sync_rx_half_rst)
    );     
    
	 
endmodule 
