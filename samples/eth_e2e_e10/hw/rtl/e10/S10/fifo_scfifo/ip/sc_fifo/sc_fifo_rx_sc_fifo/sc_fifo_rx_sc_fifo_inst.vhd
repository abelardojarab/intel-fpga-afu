	component sc_fifo_rx_sc_fifo is
		generic (
			SYMBOLS_PER_BEAT    : integer := 1;
			BITS_PER_SYMBOL     : integer := 8;
			FIFO_DEPTH          : integer := 16;
			CHANNEL_WIDTH       : integer := 0;
			ERROR_WIDTH         : integer := 0;
			USE_PACKETS         : integer := 0;
			USE_FILL_LEVEL      : integer := 0;
			EMPTY_LATENCY       : integer := 3;
			USE_MEMORY_BLOCKS   : integer := 1;
			USE_STORE_FORWARD   : integer := 0;
			USE_ALMOST_FULL_IF  : integer := 0;
			USE_ALMOST_EMPTY_IF : integer := 0
		);
		port (
			clk               : in  std_logic                     := 'X';             -- clk
			reset             : in  std_logic                     := 'X';             -- reset
			csr_address       : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- address
			csr_read          : in  std_logic                     := 'X';             -- read
			csr_write         : in  std_logic                     := 'X';             -- write
			csr_readdata      : out std_logic_vector(31 downto 0);                    -- readdata
			csr_writedata     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			almost_full_data  : out std_logic;                                        -- data
			almost_empty_data : out std_logic;                                        -- data
			in_data           : in  std_logic_vector(63 downto 0) := (others => 'X'); -- data
			in_valid          : in  std_logic                     := 'X';             -- valid
			in_ready          : out std_logic;                                        -- ready
			in_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
			in_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
			in_empty          : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- empty
			in_error          : in  std_logic_vector(5 downto 0)  := (others => 'X'); -- error
			out_data          : out std_logic_vector(63 downto 0);                    -- data
			out_valid         : out std_logic;                                        -- valid
			out_ready         : in  std_logic                     := 'X';             -- ready
			out_startofpacket : out std_logic;                                        -- startofpacket
			out_endofpacket   : out std_logic;                                        -- endofpacket
			out_empty         : out std_logic_vector(2 downto 0);                     -- empty
			out_error         : out std_logic_vector(5 downto 0)                      -- error
		);
	end component sc_fifo_rx_sc_fifo;

	u0 : component sc_fifo_rx_sc_fifo
		generic map (
			SYMBOLS_PER_BEAT    => INTEGER_VALUE_FOR_SYMBOLS_PER_BEAT,
			BITS_PER_SYMBOL     => INTEGER_VALUE_FOR_BITS_PER_SYMBOL,
			FIFO_DEPTH          => INTEGER_VALUE_FOR_FIFO_DEPTH,
			CHANNEL_WIDTH       => INTEGER_VALUE_FOR_CHANNEL_WIDTH,
			ERROR_WIDTH         => INTEGER_VALUE_FOR_ERROR_WIDTH,
			USE_PACKETS         => INTEGER_VALUE_FOR_USE_PACKETS,
			USE_FILL_LEVEL      => INTEGER_VALUE_FOR_USE_FILL_LEVEL,
			EMPTY_LATENCY       => INTEGER_VALUE_FOR_EMPTY_LATENCY,
			USE_MEMORY_BLOCKS   => INTEGER_VALUE_FOR_USE_MEMORY_BLOCKS,
			USE_STORE_FORWARD   => INTEGER_VALUE_FOR_USE_STORE_FORWARD,
			USE_ALMOST_FULL_IF  => INTEGER_VALUE_FOR_USE_ALMOST_FULL_IF,
			USE_ALMOST_EMPTY_IF => INTEGER_VALUE_FOR_USE_ALMOST_EMPTY_IF
		)
		port map (
			clk               => CONNECTED_TO_clk,               --          clk.clk
			reset             => CONNECTED_TO_reset,             --    clk_reset.reset
			csr_address       => CONNECTED_TO_csr_address,       --          csr.address
			csr_read          => CONNECTED_TO_csr_read,          --             .read
			csr_write         => CONNECTED_TO_csr_write,         --             .write
			csr_readdata      => CONNECTED_TO_csr_readdata,      --             .readdata
			csr_writedata     => CONNECTED_TO_csr_writedata,     --             .writedata
			almost_full_data  => CONNECTED_TO_almost_full_data,  --  almost_full.data
			almost_empty_data => CONNECTED_TO_almost_empty_data, -- almost_empty.data
			in_data           => CONNECTED_TO_in_data,           --           in.data
			in_valid          => CONNECTED_TO_in_valid,          --             .valid
			in_ready          => CONNECTED_TO_in_ready,          --             .ready
			in_startofpacket  => CONNECTED_TO_in_startofpacket,  --             .startofpacket
			in_endofpacket    => CONNECTED_TO_in_endofpacket,    --             .endofpacket
			in_empty          => CONNECTED_TO_in_empty,          --             .empty
			in_error          => CONNECTED_TO_in_error,          --             .error
			out_data          => CONNECTED_TO_out_data,          --          out.data
			out_valid         => CONNECTED_TO_out_valid,         --             .valid
			out_ready         => CONNECTED_TO_out_ready,         --             .ready
			out_startofpacket => CONNECTED_TO_out_startofpacket, --             .startofpacket
			out_endofpacket   => CONNECTED_TO_out_endofpacket,   --             .endofpacket
			out_empty         => CONNECTED_TO_out_empty,         --             .empty
			out_error         => CONNECTED_TO_out_error          --             .error
		);

