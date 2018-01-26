	component address_decode is
		port (
			clk_csr_clk                                                 : in  std_logic                     := 'X';             -- clk
			csr_reset_n                                                 : in  std_logic                     := 'X';             -- reset_n
			eth_gen_mon_avalon_anti_slave_0_address                     : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_avalon_anti_slave_0_write                       : out std_logic;                                        -- write
			eth_gen_mon_avalon_anti_slave_0_read                        : out std_logic;                                        -- read
			eth_gen_mon_avalon_anti_slave_0_readdata                    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_avalon_anti_slave_0_writedata                   : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_avalon_anti_slave_0_waitrequest                 : in  std_logic                     := 'X';             -- waitrequest
			mac_avalon_anti_slave_0_address                             : out std_logic_vector(12 downto 0);                    -- address
			mac_avalon_anti_slave_0_write                               : out std_logic;                                        -- write
			mac_avalon_anti_slave_0_read                                : out std_logic;                                        -- read
			mac_avalon_anti_slave_0_readdata                            : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_avalon_anti_slave_0_writedata                           : out std_logic_vector(31 downto 0);                    -- writedata
			mac_avalon_anti_slave_0_waitrequest                         : in  std_logic                     := 'X';             -- waitrequest
			merlin_master_translator_0_avalon_anti_master_0_address     : in  std_logic_vector(15 downto 0) := (others => 'X'); -- address
			merlin_master_translator_0_avalon_anti_master_0_waitrequest : out std_logic;                                        -- waitrequest
			merlin_master_translator_0_avalon_anti_master_0_read        : in  std_logic                     := 'X';             -- read
			merlin_master_translator_0_avalon_anti_master_0_readdata    : out std_logic_vector(31 downto 0);                    -- readdata
			merlin_master_translator_0_avalon_anti_master_0_write       : in  std_logic                     := 'X';             -- write
			merlin_master_translator_0_avalon_anti_master_0_writedata   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			phy_avalon_anti_slave_0_address                             : out std_logic_vector(9 downto 0);                     -- address
			phy_avalon_anti_slave_0_write                               : out std_logic;                                        -- write
			phy_avalon_anti_slave_0_read                                : out std_logic;                                        -- read
			phy_avalon_anti_slave_0_readdata                            : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_avalon_anti_slave_0_writedata                           : out std_logic_vector(31 downto 0);                    -- writedata
			phy_avalon_anti_slave_0_waitrequest                         : in  std_logic                     := 'X';             -- waitrequest
			rx_sc_fifo_avalon_anti_slave_0_address                      : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_avalon_anti_slave_0_write                        : out std_logic;                                        -- write
			rx_sc_fifo_avalon_anti_slave_0_read                         : out std_logic;                                        -- read
			rx_sc_fifo_avalon_anti_slave_0_readdata                     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_avalon_anti_slave_0_writedata                    : out std_logic_vector(31 downto 0);                    -- writedata
			rx_xcvr_clk_clk                                             : in  std_logic                     := 'X';             -- clk
			sync_rx_rst_reset_n                                         : in  std_logic                     := 'X';             -- reset_n
			sync_tx_half_rst_reset_n                                    : in  std_logic                     := 'X';             -- reset_n
			sync_tx_rst_reset_n                                         : in  std_logic                     := 'X';             -- reset_n
			tx_sc_fifo_avalon_anti_slave_0_address                      : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_avalon_anti_slave_0_write                        : out std_logic;                                        -- write
			tx_sc_fifo_avalon_anti_slave_0_read                         : out std_logic;                                        -- read
			tx_sc_fifo_avalon_anti_slave_0_readdata                     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_avalon_anti_slave_0_writedata                    : out std_logic_vector(31 downto 0);                    -- writedata
			tx_xcvr_clk_clk                                             : in  std_logic                     := 'X';             -- clk
			tx_xcvr_half_clk_clk                                        : in  std_logic                     := 'X'              -- clk
		);
	end component address_decode;

	u0 : component address_decode
		port map (
			clk_csr_clk                                                 => CONNECTED_TO_clk_csr_clk,                                                 --                                         clk_csr.clk
			csr_reset_n                                                 => CONNECTED_TO_csr_reset_n,                                                 --                                             csr.reset_n
			eth_gen_mon_avalon_anti_slave_0_address                     => CONNECTED_TO_eth_gen_mon_avalon_anti_slave_0_address,                     --                 eth_gen_mon_avalon_anti_slave_0.address
			eth_gen_mon_avalon_anti_slave_0_write                       => CONNECTED_TO_eth_gen_mon_avalon_anti_slave_0_write,                       --                                                .write
			eth_gen_mon_avalon_anti_slave_0_read                        => CONNECTED_TO_eth_gen_mon_avalon_anti_slave_0_read,                        --                                                .read
			eth_gen_mon_avalon_anti_slave_0_readdata                    => CONNECTED_TO_eth_gen_mon_avalon_anti_slave_0_readdata,                    --                                                .readdata
			eth_gen_mon_avalon_anti_slave_0_writedata                   => CONNECTED_TO_eth_gen_mon_avalon_anti_slave_0_writedata,                   --                                                .writedata
			eth_gen_mon_avalon_anti_slave_0_waitrequest                 => CONNECTED_TO_eth_gen_mon_avalon_anti_slave_0_waitrequest,                 --                                                .waitrequest
			mac_avalon_anti_slave_0_address                             => CONNECTED_TO_mac_avalon_anti_slave_0_address,                             --                         mac_avalon_anti_slave_0.address
			mac_avalon_anti_slave_0_write                               => CONNECTED_TO_mac_avalon_anti_slave_0_write,                               --                                                .write
			mac_avalon_anti_slave_0_read                                => CONNECTED_TO_mac_avalon_anti_slave_0_read,                                --                                                .read
			mac_avalon_anti_slave_0_readdata                            => CONNECTED_TO_mac_avalon_anti_slave_0_readdata,                            --                                                .readdata
			mac_avalon_anti_slave_0_writedata                           => CONNECTED_TO_mac_avalon_anti_slave_0_writedata,                           --                                                .writedata
			mac_avalon_anti_slave_0_waitrequest                         => CONNECTED_TO_mac_avalon_anti_slave_0_waitrequest,                         --                                                .waitrequest
			merlin_master_translator_0_avalon_anti_master_0_address     => CONNECTED_TO_merlin_master_translator_0_avalon_anti_master_0_address,     -- merlin_master_translator_0_avalon_anti_master_0.address
			merlin_master_translator_0_avalon_anti_master_0_waitrequest => CONNECTED_TO_merlin_master_translator_0_avalon_anti_master_0_waitrequest, --                                                .waitrequest
			merlin_master_translator_0_avalon_anti_master_0_read        => CONNECTED_TO_merlin_master_translator_0_avalon_anti_master_0_read,        --                                                .read
			merlin_master_translator_0_avalon_anti_master_0_readdata    => CONNECTED_TO_merlin_master_translator_0_avalon_anti_master_0_readdata,    --                                                .readdata
			merlin_master_translator_0_avalon_anti_master_0_write       => CONNECTED_TO_merlin_master_translator_0_avalon_anti_master_0_write,       --                                                .write
			merlin_master_translator_0_avalon_anti_master_0_writedata   => CONNECTED_TO_merlin_master_translator_0_avalon_anti_master_0_writedata,   --                                                .writedata
			phy_avalon_anti_slave_0_address                             => CONNECTED_TO_phy_avalon_anti_slave_0_address,                             --                         phy_avalon_anti_slave_0.address
			phy_avalon_anti_slave_0_write                               => CONNECTED_TO_phy_avalon_anti_slave_0_write,                               --                                                .write
			phy_avalon_anti_slave_0_read                                => CONNECTED_TO_phy_avalon_anti_slave_0_read,                                --                                                .read
			phy_avalon_anti_slave_0_readdata                            => CONNECTED_TO_phy_avalon_anti_slave_0_readdata,                            --                                                .readdata
			phy_avalon_anti_slave_0_writedata                           => CONNECTED_TO_phy_avalon_anti_slave_0_writedata,                           --                                                .writedata
			phy_avalon_anti_slave_0_waitrequest                         => CONNECTED_TO_phy_avalon_anti_slave_0_waitrequest,                         --                                                .waitrequest
			rx_sc_fifo_avalon_anti_slave_0_address                      => CONNECTED_TO_rx_sc_fifo_avalon_anti_slave_0_address,                      --                  rx_sc_fifo_avalon_anti_slave_0.address
			rx_sc_fifo_avalon_anti_slave_0_write                        => CONNECTED_TO_rx_sc_fifo_avalon_anti_slave_0_write,                        --                                                .write
			rx_sc_fifo_avalon_anti_slave_0_read                         => CONNECTED_TO_rx_sc_fifo_avalon_anti_slave_0_read,                         --                                                .read
			rx_sc_fifo_avalon_anti_slave_0_readdata                     => CONNECTED_TO_rx_sc_fifo_avalon_anti_slave_0_readdata,                     --                                                .readdata
			rx_sc_fifo_avalon_anti_slave_0_writedata                    => CONNECTED_TO_rx_sc_fifo_avalon_anti_slave_0_writedata,                    --                                                .writedata
			rx_xcvr_clk_clk                                             => CONNECTED_TO_rx_xcvr_clk_clk,                                             --                                     rx_xcvr_clk.clk
			sync_rx_rst_reset_n                                         => CONNECTED_TO_sync_rx_rst_reset_n,                                         --                                     sync_rx_rst.reset_n
			sync_tx_half_rst_reset_n                                    => CONNECTED_TO_sync_tx_half_rst_reset_n,                                    --                                sync_tx_half_rst.reset_n
			sync_tx_rst_reset_n                                         => CONNECTED_TO_sync_tx_rst_reset_n,                                         --                                     sync_tx_rst.reset_n
			tx_sc_fifo_avalon_anti_slave_0_address                      => CONNECTED_TO_tx_sc_fifo_avalon_anti_slave_0_address,                      --                  tx_sc_fifo_avalon_anti_slave_0.address
			tx_sc_fifo_avalon_anti_slave_0_write                        => CONNECTED_TO_tx_sc_fifo_avalon_anti_slave_0_write,                        --                                                .write
			tx_sc_fifo_avalon_anti_slave_0_read                         => CONNECTED_TO_tx_sc_fifo_avalon_anti_slave_0_read,                         --                                                .read
			tx_sc_fifo_avalon_anti_slave_0_readdata                     => CONNECTED_TO_tx_sc_fifo_avalon_anti_slave_0_readdata,                     --                                                .readdata
			tx_sc_fifo_avalon_anti_slave_0_writedata                    => CONNECTED_TO_tx_sc_fifo_avalon_anti_slave_0_writedata,                    --                                                .writedata
			tx_xcvr_clk_clk                                             => CONNECTED_TO_tx_xcvr_clk_clk,                                             --                                     tx_xcvr_clk.clk
			tx_xcvr_half_clk_clk                                        => CONNECTED_TO_tx_xcvr_half_clk_clk                                         --                                tx_xcvr_half_clk.clk
		);

