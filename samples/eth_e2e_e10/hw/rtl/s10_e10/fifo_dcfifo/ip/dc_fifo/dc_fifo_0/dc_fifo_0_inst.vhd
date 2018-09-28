	component dc_fifo_0 is
		generic (
			SYMBOLS_PER_BEAT   : integer := 1;
			BITS_PER_SYMBOL    : integer := 8;
			FIFO_DEPTH         : integer := 16;
			CHANNEL_WIDTH      : integer := 0;
			ERROR_WIDTH        : integer := 0;
			USE_PACKETS        : integer := 0;
			USE_IN_FILL_LEVEL  : integer := 0;
			USE_OUT_FILL_LEVEL : integer := 0;
			WR_SYNC_DEPTH      : integer := 3;
			RD_SYNC_DEPTH      : integer := 3
		);
		port (
			in_clk            : in  std_logic                     := 'X';             -- clk
			in_reset_n        : in  std_logic                     := 'X';             -- reset_n
			out_clk           : in  std_logic                     := 'X';             -- clk
			out_reset_n       : in  std_logic                     := 'X';             -- reset_n
			in_data           : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
			in_valid          : in  std_logic                     := 'X';             -- valid
			in_ready          : out std_logic;                                        -- ready
			in_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
			in_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
			in_empty          : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- empty
			in_error          : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- error
			out_data          : out std_logic_vector(31 downto 0);                    -- data
			out_valid         : out std_logic;                                        -- valid
			out_ready         : in  std_logic                     := 'X';             -- ready
			out_startofpacket : out std_logic;                                        -- startofpacket
			out_endofpacket   : out std_logic;                                        -- endofpacket
			out_empty         : out std_logic_vector(1 downto 0);                     -- empty
			out_error         : out std_logic_vector(0 downto 0)                      -- error
		);
	end component dc_fifo_0;

	u0 : component dc_fifo_0
		generic map (
			SYMBOLS_PER_BEAT   => INTEGER_VALUE_FOR_SYMBOLS_PER_BEAT,
			BITS_PER_SYMBOL    => INTEGER_VALUE_FOR_BITS_PER_SYMBOL,
			FIFO_DEPTH         => INTEGER_VALUE_FOR_FIFO_DEPTH,
			CHANNEL_WIDTH      => INTEGER_VALUE_FOR_CHANNEL_WIDTH,
			ERROR_WIDTH        => INTEGER_VALUE_FOR_ERROR_WIDTH,
			USE_PACKETS        => INTEGER_VALUE_FOR_USE_PACKETS,
			USE_IN_FILL_LEVEL  => INTEGER_VALUE_FOR_USE_IN_FILL_LEVEL,
			USE_OUT_FILL_LEVEL => INTEGER_VALUE_FOR_USE_OUT_FILL_LEVEL,
			WR_SYNC_DEPTH      => INTEGER_VALUE_FOR_WR_SYNC_DEPTH,
			RD_SYNC_DEPTH      => INTEGER_VALUE_FOR_RD_SYNC_DEPTH
		)
		port map (
			in_clk            => CONNECTED_TO_in_clk,            --        in_clk.clk
			in_reset_n        => CONNECTED_TO_in_reset_n,        --  in_clk_reset.reset_n
			out_clk           => CONNECTED_TO_out_clk,           --       out_clk.clk
			out_reset_n       => CONNECTED_TO_out_reset_n,       -- out_clk_reset.reset_n
			in_data           => CONNECTED_TO_in_data,           --            in.data
			in_valid          => CONNECTED_TO_in_valid,          --              .valid
			in_ready          => CONNECTED_TO_in_ready,          --              .ready
			in_startofpacket  => CONNECTED_TO_in_startofpacket,  --              .startofpacket
			in_endofpacket    => CONNECTED_TO_in_endofpacket,    --              .endofpacket
			in_empty          => CONNECTED_TO_in_empty,          --              .empty
			in_error          => CONNECTED_TO_in_error,          --              .error
			out_data          => CONNECTED_TO_out_data,          --           out.data
			out_valid         => CONNECTED_TO_out_valid,         --              .valid
			out_ready         => CONNECTED_TO_out_ready,         --              .ready
			out_startofpacket => CONNECTED_TO_out_startofpacket, --              .startofpacket
			out_endofpacket   => CONNECTED_TO_out_endofpacket,   --              .endofpacket
			out_empty         => CONNECTED_TO_out_empty,         --              .empty
			out_error         => CONNECTED_TO_out_error          --              .error
		);

