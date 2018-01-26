	component sc_fifo is
		port (
			rx_sc_fifo_almost_empty_data : out std_logic;                                        -- data
			rx_sc_fifo_almost_full_data  : out std_logic;                                        -- data
			rx_sc_fifo_clk_clk           : in  std_logic                     := 'X';             -- clk
			rx_sc_fifo_clk_reset_reset   : in  std_logic                     := 'X';             -- reset
			rx_sc_fifo_csr_address       : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- address
			rx_sc_fifo_csr_read          : in  std_logic                     := 'X';             -- read
			rx_sc_fifo_csr_write         : in  std_logic                     := 'X';             -- write
			rx_sc_fifo_csr_readdata      : out std_logic_vector(31 downto 0);                    -- readdata
			rx_sc_fifo_csr_writedata     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			rx_sc_fifo_in_data           : in  std_logic_vector(63 downto 0) := (others => 'X'); -- data
			rx_sc_fifo_in_valid          : in  std_logic                     := 'X';             -- valid
			rx_sc_fifo_in_ready          : out std_logic;                                        -- ready
			rx_sc_fifo_in_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
			rx_sc_fifo_in_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
			rx_sc_fifo_in_empty          : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- empty
			rx_sc_fifo_in_error          : in  std_logic_vector(5 downto 0)  := (others => 'X'); -- error
			rx_sc_fifo_out_data          : out std_logic_vector(63 downto 0);                    -- data
			rx_sc_fifo_out_valid         : out std_logic;                                        -- valid
			rx_sc_fifo_out_ready         : in  std_logic                     := 'X';             -- ready
			rx_sc_fifo_out_startofpacket : out std_logic;                                        -- startofpacket
			rx_sc_fifo_out_endofpacket   : out std_logic;                                        -- endofpacket
			rx_sc_fifo_out_empty         : out std_logic_vector(2 downto 0);                     -- empty
			rx_sc_fifo_out_error         : out std_logic_vector(5 downto 0);                     -- error
			tx_sc_fifo_clk_clk           : in  std_logic                     := 'X';             -- clk
			tx_sc_fifo_clk_reset_reset   : in  std_logic                     := 'X';             -- reset
			tx_sc_fifo_csr_address       : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- address
			tx_sc_fifo_csr_read          : in  std_logic                     := 'X';             -- read
			tx_sc_fifo_csr_write         : in  std_logic                     := 'X';             -- write
			tx_sc_fifo_csr_readdata      : out std_logic_vector(31 downto 0);                    -- readdata
			tx_sc_fifo_csr_writedata     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			tx_sc_fifo_in_data           : in  std_logic_vector(63 downto 0) := (others => 'X'); -- data
			tx_sc_fifo_in_valid          : in  std_logic                     := 'X';             -- valid
			tx_sc_fifo_in_ready          : out std_logic;                                        -- ready
			tx_sc_fifo_in_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
			tx_sc_fifo_in_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
			tx_sc_fifo_in_empty          : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- empty
			tx_sc_fifo_in_error          : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- error
			tx_sc_fifo_out_data          : out std_logic_vector(63 downto 0);                    -- data
			tx_sc_fifo_out_valid         : out std_logic;                                        -- valid
			tx_sc_fifo_out_ready         : in  std_logic                     := 'X';             -- ready
			tx_sc_fifo_out_startofpacket : out std_logic;                                        -- startofpacket
			tx_sc_fifo_out_endofpacket   : out std_logic;                                        -- endofpacket
			tx_sc_fifo_out_empty         : out std_logic_vector(2 downto 0);                     -- empty
			tx_sc_fifo_out_error         : out std_logic_vector(0 downto 0)                      -- error
		);
	end component sc_fifo;

	u0 : component sc_fifo
		port map (
			rx_sc_fifo_almost_empty_data => CONNECTED_TO_rx_sc_fifo_almost_empty_data, -- rx_sc_fifo_almost_empty.data
			rx_sc_fifo_almost_full_data  => CONNECTED_TO_rx_sc_fifo_almost_full_data,  --  rx_sc_fifo_almost_full.data
			rx_sc_fifo_clk_clk           => CONNECTED_TO_rx_sc_fifo_clk_clk,           --          rx_sc_fifo_clk.clk
			rx_sc_fifo_clk_reset_reset   => CONNECTED_TO_rx_sc_fifo_clk_reset_reset,   --    rx_sc_fifo_clk_reset.reset
			rx_sc_fifo_csr_address       => CONNECTED_TO_rx_sc_fifo_csr_address,       --          rx_sc_fifo_csr.address
			rx_sc_fifo_csr_read          => CONNECTED_TO_rx_sc_fifo_csr_read,          --                        .read
			rx_sc_fifo_csr_write         => CONNECTED_TO_rx_sc_fifo_csr_write,         --                        .write
			rx_sc_fifo_csr_readdata      => CONNECTED_TO_rx_sc_fifo_csr_readdata,      --                        .readdata
			rx_sc_fifo_csr_writedata     => CONNECTED_TO_rx_sc_fifo_csr_writedata,     --                        .writedata
			rx_sc_fifo_in_data           => CONNECTED_TO_rx_sc_fifo_in_data,           --           rx_sc_fifo_in.data
			rx_sc_fifo_in_valid          => CONNECTED_TO_rx_sc_fifo_in_valid,          --                        .valid
			rx_sc_fifo_in_ready          => CONNECTED_TO_rx_sc_fifo_in_ready,          --                        .ready
			rx_sc_fifo_in_startofpacket  => CONNECTED_TO_rx_sc_fifo_in_startofpacket,  --                        .startofpacket
			rx_sc_fifo_in_endofpacket    => CONNECTED_TO_rx_sc_fifo_in_endofpacket,    --                        .endofpacket
			rx_sc_fifo_in_empty          => CONNECTED_TO_rx_sc_fifo_in_empty,          --                        .empty
			rx_sc_fifo_in_error          => CONNECTED_TO_rx_sc_fifo_in_error,          --                        .error
			rx_sc_fifo_out_data          => CONNECTED_TO_rx_sc_fifo_out_data,          --          rx_sc_fifo_out.data
			rx_sc_fifo_out_valid         => CONNECTED_TO_rx_sc_fifo_out_valid,         --                        .valid
			rx_sc_fifo_out_ready         => CONNECTED_TO_rx_sc_fifo_out_ready,         --                        .ready
			rx_sc_fifo_out_startofpacket => CONNECTED_TO_rx_sc_fifo_out_startofpacket, --                        .startofpacket
			rx_sc_fifo_out_endofpacket   => CONNECTED_TO_rx_sc_fifo_out_endofpacket,   --                        .endofpacket
			rx_sc_fifo_out_empty         => CONNECTED_TO_rx_sc_fifo_out_empty,         --                        .empty
			rx_sc_fifo_out_error         => CONNECTED_TO_rx_sc_fifo_out_error,         --                        .error
			tx_sc_fifo_clk_clk           => CONNECTED_TO_tx_sc_fifo_clk_clk,           --          tx_sc_fifo_clk.clk
			tx_sc_fifo_clk_reset_reset   => CONNECTED_TO_tx_sc_fifo_clk_reset_reset,   --    tx_sc_fifo_clk_reset.reset
			tx_sc_fifo_csr_address       => CONNECTED_TO_tx_sc_fifo_csr_address,       --          tx_sc_fifo_csr.address
			tx_sc_fifo_csr_read          => CONNECTED_TO_tx_sc_fifo_csr_read,          --                        .read
			tx_sc_fifo_csr_write         => CONNECTED_TO_tx_sc_fifo_csr_write,         --                        .write
			tx_sc_fifo_csr_readdata      => CONNECTED_TO_tx_sc_fifo_csr_readdata,      --                        .readdata
			tx_sc_fifo_csr_writedata     => CONNECTED_TO_tx_sc_fifo_csr_writedata,     --                        .writedata
			tx_sc_fifo_in_data           => CONNECTED_TO_tx_sc_fifo_in_data,           --           tx_sc_fifo_in.data
			tx_sc_fifo_in_valid          => CONNECTED_TO_tx_sc_fifo_in_valid,          --                        .valid
			tx_sc_fifo_in_ready          => CONNECTED_TO_tx_sc_fifo_in_ready,          --                        .ready
			tx_sc_fifo_in_startofpacket  => CONNECTED_TO_tx_sc_fifo_in_startofpacket,  --                        .startofpacket
			tx_sc_fifo_in_endofpacket    => CONNECTED_TO_tx_sc_fifo_in_endofpacket,    --                        .endofpacket
			tx_sc_fifo_in_empty          => CONNECTED_TO_tx_sc_fifo_in_empty,          --                        .empty
			tx_sc_fifo_in_error          => CONNECTED_TO_tx_sc_fifo_in_error,          --                        .error
			tx_sc_fifo_out_data          => CONNECTED_TO_tx_sc_fifo_out_data,          --          tx_sc_fifo_out.data
			tx_sc_fifo_out_valid         => CONNECTED_TO_tx_sc_fifo_out_valid,         --                        .valid
			tx_sc_fifo_out_ready         => CONNECTED_TO_tx_sc_fifo_out_ready,         --                        .ready
			tx_sc_fifo_out_startofpacket => CONNECTED_TO_tx_sc_fifo_out_startofpacket, --                        .startofpacket
			tx_sc_fifo_out_endofpacket   => CONNECTED_TO_tx_sc_fifo_out_endofpacket,   --                        .endofpacket
			tx_sc_fifo_out_empty         => CONNECTED_TO_tx_sc_fifo_out_empty,         --                        .empty
			tx_sc_fifo_out_error         => CONNECTED_TO_tx_sc_fifo_out_error          --                        .error
		);

