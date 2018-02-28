	component e40 is
		port (
			clk_ref               : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- clk_ref
			reset_async           : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- reset_async
			rx_serial             : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- rx_serial
			tx_serial             : out std_logic_vector(3 downto 0);                      -- tx_serial
			clk_status            : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- clk_status
			reset_status          : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- reset_status
			status_write          : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- status_write
			status_read           : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- status_read
			status_addr           : in  std_logic_vector(15 downto 0)  := (others => 'X'); -- status_addr
			status_writedata      : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- status_writedata
			status_readdata       : out std_logic_vector(31 downto 0);                     -- status_readdata
			status_readdata_valid : out std_logic_vector(0 downto 0);                      -- status_readdata_valid
			status_waitrequest    : out std_logic_vector(0 downto 0);                      -- status_waitrequest
			status_read_timeout   : out std_logic_vector(0 downto 0);                      -- status_read_timeout
			clk_txmac             : out std_logic_vector(0 downto 0);                      -- clk_txmac
			tx_lanes_stable       : out std_logic_vector(0 downto 0);                      -- tx_lanes_stable
			rx_pcs_ready          : out std_logic_vector(0 downto 0);                      -- rx_pcs_ready
			clk_rxmac             : out std_logic_vector(0 downto 0);                      -- clk_rxmac
			rx_inc_octetsOK       : out std_logic_vector(15 downto 0);                     -- rx_inc_octetsOK
			rx_inc_octetsOK_valid : out std_logic_vector(0 downto 0);                      -- rx_inc_octetsOK_valid
			rx_inc_runt           : out std_logic_vector(0 downto 0);                      -- rx_inc_runt
			rx_inc_64             : out std_logic_vector(0 downto 0);                      -- rx_inc_64
			rx_inc_127            : out std_logic_vector(0 downto 0);                      -- rx_inc_127
			rx_inc_255            : out std_logic_vector(0 downto 0);                      -- rx_inc_255
			rx_inc_511            : out std_logic_vector(0 downto 0);                      -- rx_inc_511
			rx_inc_1023           : out std_logic_vector(0 downto 0);                      -- rx_inc_1023
			rx_inc_1518           : out std_logic_vector(0 downto 0);                      -- rx_inc_1518
			rx_inc_max            : out std_logic_vector(0 downto 0);                      -- rx_inc_max
			rx_inc_over           : out std_logic_vector(0 downto 0);                      -- rx_inc_over
			rx_inc_mcast_data_err : out std_logic_vector(0 downto 0);                      -- rx_inc_mcast_data_err
			rx_inc_mcast_data_ok  : out std_logic_vector(0 downto 0);                      -- rx_inc_mcast_data_ok
			rx_inc_bcast_data_err : out std_logic_vector(0 downto 0);                      -- rx_inc_bcast_data_err
			rx_inc_bcast_data_ok  : out std_logic_vector(0 downto 0);                      -- rx_inc_bcast_data_ok
			rx_inc_ucast_data_err : out std_logic_vector(0 downto 0);                      -- rx_inc_ucast_data_err
			rx_inc_ucast_data_ok  : out std_logic_vector(0 downto 0);                      -- rx_inc_ucast_data_ok
			rx_inc_mcast_ctrl     : out std_logic_vector(0 downto 0);                      -- rx_inc_mcast_ctrl
			rx_inc_bcast_ctrl     : out std_logic_vector(0 downto 0);                      -- rx_inc_bcast_ctrl
			rx_inc_ucast_ctrl     : out std_logic_vector(0 downto 0);                      -- rx_inc_ucast_ctrl
			rx_inc_pause          : out std_logic_vector(0 downto 0);                      -- rx_inc_pause
			rx_inc_fcs_err        : out std_logic_vector(0 downto 0);                      -- rx_inc_fcs_err
			rx_inc_fragment       : out std_logic_vector(0 downto 0);                      -- rx_inc_fragment
			rx_inc_jabber         : out std_logic_vector(0 downto 0);                      -- rx_inc_jabber
			rx_inc_sizeok_fcserr  : out std_logic_vector(0 downto 0);                      -- rx_inc_sizeok_fcserr
			rx_inc_pause_ctrl_err : out std_logic_vector(0 downto 0);                      -- rx_inc_pause_ctrl_err
			rx_inc_mcast_ctrl_err : out std_logic_vector(0 downto 0);                      -- rx_inc_mcast_ctrl_err
			rx_inc_bcast_ctrl_err : out std_logic_vector(0 downto 0);                      -- rx_inc_bcast_ctrl_err
			rx_inc_ucast_ctrl_err : out std_logic_vector(0 downto 0);                      -- rx_inc_ucast_ctrl_err
			tx_inc_octetsOK       : out std_logic_vector(15 downto 0);                     -- tx_inc_octetsOK
			tx_inc_octetsOK_valid : out std_logic_vector(0 downto 0);                      -- tx_inc_octetsOK_valid
			tx_inc_64             : out std_logic_vector(0 downto 0);                      -- tx_inc_64
			tx_inc_127            : out std_logic_vector(0 downto 0);                      -- tx_inc_127
			tx_inc_255            : out std_logic_vector(0 downto 0);                      -- tx_inc_255
			tx_inc_511            : out std_logic_vector(0 downto 0);                      -- tx_inc_511
			tx_inc_1023           : out std_logic_vector(0 downto 0);                      -- tx_inc_1023
			tx_inc_1518           : out std_logic_vector(0 downto 0);                      -- tx_inc_1518
			tx_inc_max            : out std_logic_vector(0 downto 0);                      -- tx_inc_max
			tx_inc_over           : out std_logic_vector(0 downto 0);                      -- tx_inc_over
			tx_inc_mcast_data_err : out std_logic_vector(0 downto 0);                      -- tx_inc_mcast_data_err
			tx_inc_mcast_data_ok  : out std_logic_vector(0 downto 0);                      -- tx_inc_mcast_data_ok
			tx_inc_bcast_data_err : out std_logic_vector(0 downto 0);                      -- tx_inc_bcast_data_err
			tx_inc_bcast_data_ok  : out std_logic_vector(0 downto 0);                      -- tx_inc_bcast_data_ok
			tx_inc_ucast_data_err : out std_logic_vector(0 downto 0);                      -- tx_inc_ucast_data_err
			tx_inc_ucast_data_ok  : out std_logic_vector(0 downto 0);                      -- tx_inc_ucast_data_ok
			tx_inc_mcast_ctrl     : out std_logic_vector(0 downto 0);                      -- tx_inc_mcast_ctrl
			tx_inc_bcast_ctrl     : out std_logic_vector(0 downto 0);                      -- tx_inc_bcast_ctrl
			tx_inc_ucast_ctrl     : out std_logic_vector(0 downto 0);                      -- tx_inc_ucast_ctrl
			tx_inc_pause          : out std_logic_vector(0 downto 0);                      -- tx_inc_pause
			tx_inc_fcs_err        : out std_logic_vector(0 downto 0);                      -- tx_inc_fcs_err
			tx_inc_fragment       : out std_logic_vector(0 downto 0);                      -- tx_inc_fragment
			tx_inc_jabber         : out std_logic_vector(0 downto 0);                      -- tx_inc_jabber
			tx_inc_sizeok_fcserr  : out std_logic_vector(0 downto 0);                      -- tx_inc_sizeok_fcserr
			reconfig_clk          : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- reconfig_clk
			reconfig_reset        : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- reconfig_reset
			reconfig_write        : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- reconfig_write
			reconfig_read         : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- reconfig_read
			reconfig_address      : in  std_logic_vector(11 downto 0)  := (others => 'X'); -- reconfig_address
			reconfig_writedata    : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- reconfig_writedata
			reconfig_readdata     : out std_logic_vector(31 downto 0);                     -- reconfig_readdata
			reconfig_waitrequest  : out std_logic_vector(0 downto 0);                      -- reconfig_waitrequest
			tx_serial_clk         : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- tx_serial_clk
			tx_pll_locked         : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- tx_pll_locked
			din_sop               : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- din_sop
			din_eop               : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- din_eop
			din_idle              : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- din_idle
			din_eop_empty         : in  std_logic_vector(5 downto 0)   := (others => 'X'); -- din_eop_empty
			din                   : in  std_logic_vector(127 downto 0) := (others => 'X'); -- din
			din_req               : out std_logic;                                         -- din_req
			tx_error              : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- tx_error
			dout_valid            : out std_logic;                                         -- dout_valid
			dout_d                : out std_logic_vector(127 downto 0);                    -- dout_d
			dout_c                : out std_logic_vector(15 downto 0);                     -- dout_c
			dout_sop              : out std_logic_vector(1 downto 0);                      -- dout_sop
			dout_eop              : out std_logic_vector(1 downto 0);                      -- dout_eop
			dout_eop_empty        : out std_logic_vector(5 downto 0);                      -- dout_eop_empty
			dout_idle             : out std_logic_vector(1 downto 0);                      -- dout_idle
			rx_error              : out std_logic_vector(5 downto 0);                      -- rx_error
			rx_status             : out std_logic_vector(2 downto 0);                      -- rx_status
			rx_fcs_error          : out std_logic;                                         -- rx_fcs_error
			rx_fcs_valid          : out std_logic                                          -- rx_fcs_valid
		);
	end component e40;

	u0 : component e40
		port map (
			clk_ref               => CONNECTED_TO_clk_ref,               --              clk_ref.clk_ref
			reset_async           => CONNECTED_TO_reset_async,           --          reset_async.reset_async
			rx_serial             => CONNECTED_TO_rx_serial,             --            rx_serial.rx_serial
			tx_serial             => CONNECTED_TO_tx_serial,             --            tx_serial.tx_serial
			clk_status            => CONNECTED_TO_clk_status,            --           clk_status.clk_status
			reset_status          => CONNECTED_TO_reset_status,          --         reset_status.reset_status
			status_write          => CONNECTED_TO_status_write,          --          status_avmm.status_write
			status_read           => CONNECTED_TO_status_read,           --                     .status_read
			status_addr           => CONNECTED_TO_status_addr,           --                     .status_addr
			status_writedata      => CONNECTED_TO_status_writedata,      --                     .status_writedata
			status_readdata       => CONNECTED_TO_status_readdata,       --                     .status_readdata
			status_readdata_valid => CONNECTED_TO_status_readdata_valid, --                     .status_readdata_valid
			status_waitrequest    => CONNECTED_TO_status_waitrequest,    --                     .status_waitrequest
			status_read_timeout   => CONNECTED_TO_status_read_timeout,   --                     .status_read_timeout
			clk_txmac             => CONNECTED_TO_clk_txmac,             --            clk_txmac.clk_txmac
			tx_lanes_stable       => CONNECTED_TO_tx_lanes_stable,       --      tx_lanes_stable.tx_lanes_stable
			rx_pcs_ready          => CONNECTED_TO_rx_pcs_ready,          --         rx_pcs_ready.rx_pcs_ready
			clk_rxmac             => CONNECTED_TO_clk_rxmac,             --            clk_rxmac.clk_rxmac
			rx_inc_octetsOK       => CONNECTED_TO_rx_inc_octetsOK,       --             rx_stats.rx_inc_octetsOK
			rx_inc_octetsOK_valid => CONNECTED_TO_rx_inc_octetsOK_valid, --                     .rx_inc_octetsOK_valid
			rx_inc_runt           => CONNECTED_TO_rx_inc_runt,           --                     .rx_inc_runt
			rx_inc_64             => CONNECTED_TO_rx_inc_64,             --                     .rx_inc_64
			rx_inc_127            => CONNECTED_TO_rx_inc_127,            --                     .rx_inc_127
			rx_inc_255            => CONNECTED_TO_rx_inc_255,            --                     .rx_inc_255
			rx_inc_511            => CONNECTED_TO_rx_inc_511,            --                     .rx_inc_511
			rx_inc_1023           => CONNECTED_TO_rx_inc_1023,           --                     .rx_inc_1023
			rx_inc_1518           => CONNECTED_TO_rx_inc_1518,           --                     .rx_inc_1518
			rx_inc_max            => CONNECTED_TO_rx_inc_max,            --                     .rx_inc_max
			rx_inc_over           => CONNECTED_TO_rx_inc_over,           --                     .rx_inc_over
			rx_inc_mcast_data_err => CONNECTED_TO_rx_inc_mcast_data_err, --                     .rx_inc_mcast_data_err
			rx_inc_mcast_data_ok  => CONNECTED_TO_rx_inc_mcast_data_ok,  --                     .rx_inc_mcast_data_ok
			rx_inc_bcast_data_err => CONNECTED_TO_rx_inc_bcast_data_err, --                     .rx_inc_bcast_data_err
			rx_inc_bcast_data_ok  => CONNECTED_TO_rx_inc_bcast_data_ok,  --                     .rx_inc_bcast_data_ok
			rx_inc_ucast_data_err => CONNECTED_TO_rx_inc_ucast_data_err, --                     .rx_inc_ucast_data_err
			rx_inc_ucast_data_ok  => CONNECTED_TO_rx_inc_ucast_data_ok,  --                     .rx_inc_ucast_data_ok
			rx_inc_mcast_ctrl     => CONNECTED_TO_rx_inc_mcast_ctrl,     --                     .rx_inc_mcast_ctrl
			rx_inc_bcast_ctrl     => CONNECTED_TO_rx_inc_bcast_ctrl,     --                     .rx_inc_bcast_ctrl
			rx_inc_ucast_ctrl     => CONNECTED_TO_rx_inc_ucast_ctrl,     --                     .rx_inc_ucast_ctrl
			rx_inc_pause          => CONNECTED_TO_rx_inc_pause,          --                     .rx_inc_pause
			rx_inc_fcs_err        => CONNECTED_TO_rx_inc_fcs_err,        --                     .rx_inc_fcs_err
			rx_inc_fragment       => CONNECTED_TO_rx_inc_fragment,       --                     .rx_inc_fragment
			rx_inc_jabber         => CONNECTED_TO_rx_inc_jabber,         --                     .rx_inc_jabber
			rx_inc_sizeok_fcserr  => CONNECTED_TO_rx_inc_sizeok_fcserr,  --                     .rx_inc_sizeok_fcserr
			rx_inc_pause_ctrl_err => CONNECTED_TO_rx_inc_pause_ctrl_err, --                     .rx_inc_pause_ctrl_err
			rx_inc_mcast_ctrl_err => CONNECTED_TO_rx_inc_mcast_ctrl_err, --                     .rx_inc_mcast_ctrl_err
			rx_inc_bcast_ctrl_err => CONNECTED_TO_rx_inc_bcast_ctrl_err, --                     .rx_inc_bcast_ctrl_err
			rx_inc_ucast_ctrl_err => CONNECTED_TO_rx_inc_ucast_ctrl_err, --                     .rx_inc_ucast_ctrl_err
			tx_inc_octetsOK       => CONNECTED_TO_tx_inc_octetsOK,       --             tx_stats.tx_inc_octetsOK
			tx_inc_octetsOK_valid => CONNECTED_TO_tx_inc_octetsOK_valid, --                     .tx_inc_octetsOK_valid
			tx_inc_64             => CONNECTED_TO_tx_inc_64,             --                     .tx_inc_64
			tx_inc_127            => CONNECTED_TO_tx_inc_127,            --                     .tx_inc_127
			tx_inc_255            => CONNECTED_TO_tx_inc_255,            --                     .tx_inc_255
			tx_inc_511            => CONNECTED_TO_tx_inc_511,            --                     .tx_inc_511
			tx_inc_1023           => CONNECTED_TO_tx_inc_1023,           --                     .tx_inc_1023
			tx_inc_1518           => CONNECTED_TO_tx_inc_1518,           --                     .tx_inc_1518
			tx_inc_max            => CONNECTED_TO_tx_inc_max,            --                     .tx_inc_max
			tx_inc_over           => CONNECTED_TO_tx_inc_over,           --                     .tx_inc_over
			tx_inc_mcast_data_err => CONNECTED_TO_tx_inc_mcast_data_err, --                     .tx_inc_mcast_data_err
			tx_inc_mcast_data_ok  => CONNECTED_TO_tx_inc_mcast_data_ok,  --                     .tx_inc_mcast_data_ok
			tx_inc_bcast_data_err => CONNECTED_TO_tx_inc_bcast_data_err, --                     .tx_inc_bcast_data_err
			tx_inc_bcast_data_ok  => CONNECTED_TO_tx_inc_bcast_data_ok,  --                     .tx_inc_bcast_data_ok
			tx_inc_ucast_data_err => CONNECTED_TO_tx_inc_ucast_data_err, --                     .tx_inc_ucast_data_err
			tx_inc_ucast_data_ok  => CONNECTED_TO_tx_inc_ucast_data_ok,  --                     .tx_inc_ucast_data_ok
			tx_inc_mcast_ctrl     => CONNECTED_TO_tx_inc_mcast_ctrl,     --                     .tx_inc_mcast_ctrl
			tx_inc_bcast_ctrl     => CONNECTED_TO_tx_inc_bcast_ctrl,     --                     .tx_inc_bcast_ctrl
			tx_inc_ucast_ctrl     => CONNECTED_TO_tx_inc_ucast_ctrl,     --                     .tx_inc_ucast_ctrl
			tx_inc_pause          => CONNECTED_TO_tx_inc_pause,          --                     .tx_inc_pause
			tx_inc_fcs_err        => CONNECTED_TO_tx_inc_fcs_err,        --                     .tx_inc_fcs_err
			tx_inc_fragment       => CONNECTED_TO_tx_inc_fragment,       --                     .tx_inc_fragment
			tx_inc_jabber         => CONNECTED_TO_tx_inc_jabber,         --                     .tx_inc_jabber
			tx_inc_sizeok_fcserr  => CONNECTED_TO_tx_inc_sizeok_fcserr,  --                     .tx_inc_sizeok_fcserr
			reconfig_clk          => CONNECTED_TO_reconfig_clk,          --         reconfig_clk.reconfig_clk
			reconfig_reset        => CONNECTED_TO_reconfig_reset,        --       reconfig_reset.reconfig_reset
			reconfig_write        => CONNECTED_TO_reconfig_write,        --       reconfig_write.reconfig_write
			reconfig_read         => CONNECTED_TO_reconfig_read,         --        reconfig_read.reconfig_read
			reconfig_address      => CONNECTED_TO_reconfig_address,      --     reconfig_address.reconfig_address
			reconfig_writedata    => CONNECTED_TO_reconfig_writedata,    --   reconfig_writedata.reconfig_writedata
			reconfig_readdata     => CONNECTED_TO_reconfig_readdata,     --    reconfig_readdata.reconfig_readdata
			reconfig_waitrequest  => CONNECTED_TO_reconfig_waitrequest,  -- reconfig_waitrequest.reconfig_waitrequest
			tx_serial_clk         => CONNECTED_TO_tx_serial_clk,         --        tx_serial_clk.tx_serial_clk
			tx_pll_locked         => CONNECTED_TO_tx_pll_locked,         --        tx_pll_locked.tx_pll_locked
			din_sop               => CONNECTED_TO_din_sop,               --         custom_st_tx.din_sop
			din_eop               => CONNECTED_TO_din_eop,               --                     .din_eop
			din_idle              => CONNECTED_TO_din_idle,              --                     .din_idle
			din_eop_empty         => CONNECTED_TO_din_eop_empty,         --                     .din_eop_empty
			din                   => CONNECTED_TO_din,                   --                     .din
			din_req               => CONNECTED_TO_din_req,               --                     .din_req
			tx_error              => CONNECTED_TO_tx_error,              --                     .tx_error
			dout_valid            => CONNECTED_TO_dout_valid,            --         custom_st_rx.dout_valid
			dout_d                => CONNECTED_TO_dout_d,                --                     .dout_d
			dout_c                => CONNECTED_TO_dout_c,                --                     .dout_c
			dout_sop              => CONNECTED_TO_dout_sop,              --                     .dout_sop
			dout_eop              => CONNECTED_TO_dout_eop,              --                     .dout_eop
			dout_eop_empty        => CONNECTED_TO_dout_eop_empty,        --                     .dout_eop_empty
			dout_idle             => CONNECTED_TO_dout_idle,             --                     .dout_idle
			rx_error              => CONNECTED_TO_rx_error,              --                     .rx_error
			rx_status             => CONNECTED_TO_rx_status,             --                     .rx_status
			rx_fcs_error          => CONNECTED_TO_rx_fcs_error,          --                     .rx_fcs_error
			rx_fcs_valid          => CONNECTED_TO_rx_fcs_valid           --                     .rx_fcs_valid
		);

