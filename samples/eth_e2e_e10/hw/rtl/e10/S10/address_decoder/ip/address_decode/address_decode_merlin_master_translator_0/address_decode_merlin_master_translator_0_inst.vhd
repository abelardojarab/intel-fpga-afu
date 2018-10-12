	component address_decode_merlin_master_translator_0 is
		generic (
			AV_ADDRESS_W                : integer := 32;
			AV_DATA_W                   : integer := 32;
			AV_BURSTCOUNT_W             : integer := 4;
			AV_BYTEENABLE_W             : integer := 4;
			UAV_ADDRESS_W               : integer := 38;
			UAV_BURSTCOUNT_W            : integer := 10;
			USE_READ                    : integer := 1;
			USE_WRITE                   : integer := 1;
			USE_BEGINBURSTTRANSFER      : integer := 0;
			USE_BEGINTRANSFER           : integer := 0;
			USE_CHIPSELECT              : integer := 0;
			USE_BURSTCOUNT              : integer := 1;
			USE_READDATAVALID           : integer := 1;
			USE_WAITREQUEST             : integer := 1;
			USE_READRESPONSE            : integer := 0;
			USE_WRITERESPONSE           : integer := 0;
			AV_SYMBOLS_PER_WORD         : integer := 4;
			AV_ADDRESS_SYMBOLS          : integer := 0;
			AV_BURSTCOUNT_SYMBOLS       : integer := 0;
			AV_CONSTANT_BURST_BEHAVIOR  : integer := 0;
			UAV_CONSTANT_BURST_BEHAVIOR : integer := 0;
			AV_LINEWRAPBURSTS           : integer := 0;
			AV_REGISTERINCOMINGSIGNALS  : integer := 0;
			SYNC_RESET                  : integer := 0
		);
		port (
			clk               : in  std_logic                     := 'X';             -- clk
			reset             : in  std_logic                     := 'X';             -- reset
			uav_address       : out std_logic_vector(31 downto 0);                    -- address
			uav_burstcount    : out std_logic_vector(9 downto 0);                     -- burstcount
			uav_read          : out std_logic;                                        -- read
			uav_write         : out std_logic;                                        -- write
			uav_waitrequest   : in  std_logic                     := 'X';             -- waitrequest
			uav_readdatavalid : in  std_logic                     := 'X';             -- readdatavalid
			uav_byteenable    : out std_logic_vector(3 downto 0);                     -- byteenable
			uav_readdata      : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			uav_writedata     : out std_logic_vector(31 downto 0);                    -- writedata
			uav_lock          : out std_logic;                                        -- lock
			uav_debugaccess   : out std_logic;                                        -- debugaccess
			av_address        : in  std_logic_vector(15 downto 0) := (others => 'X'); -- address
			av_waitrequest    : out std_logic;                                        -- waitrequest
			av_read           : in  std_logic                     := 'X';             -- read
			av_readdata       : out std_logic_vector(31 downto 0);                    -- readdata
			av_write          : in  std_logic                     := 'X';             -- write
			av_writedata      : in  std_logic_vector(31 downto 0) := (others => 'X')  -- writedata
		);
	end component address_decode_merlin_master_translator_0;

	u0 : component address_decode_merlin_master_translator_0
		generic map (
			AV_ADDRESS_W                => INTEGER_VALUE_FOR_AV_ADDRESS_W,
			AV_DATA_W                   => INTEGER_VALUE_FOR_AV_DATA_W,
			AV_BURSTCOUNT_W             => INTEGER_VALUE_FOR_AV_BURSTCOUNT_W,
			AV_BYTEENABLE_W             => INTEGER_VALUE_FOR_AV_BYTEENABLE_W,
			UAV_ADDRESS_W               => INTEGER_VALUE_FOR_UAV_ADDRESS_W,
			UAV_BURSTCOUNT_W            => INTEGER_VALUE_FOR_UAV_BURSTCOUNT_W,
			USE_READ                    => INTEGER_VALUE_FOR_USE_READ,
			USE_WRITE                   => INTEGER_VALUE_FOR_USE_WRITE,
			USE_BEGINBURSTTRANSFER      => INTEGER_VALUE_FOR_USE_BEGINBURSTTRANSFER,
			USE_BEGINTRANSFER           => INTEGER_VALUE_FOR_USE_BEGINTRANSFER,
			USE_CHIPSELECT              => INTEGER_VALUE_FOR_USE_CHIPSELECT,
			USE_BURSTCOUNT              => INTEGER_VALUE_FOR_USE_BURSTCOUNT,
			USE_READDATAVALID           => INTEGER_VALUE_FOR_USE_READDATAVALID,
			USE_WAITREQUEST             => INTEGER_VALUE_FOR_USE_WAITREQUEST,
			USE_READRESPONSE            => INTEGER_VALUE_FOR_USE_READRESPONSE,
			USE_WRITERESPONSE           => INTEGER_VALUE_FOR_USE_WRITERESPONSE,
			AV_SYMBOLS_PER_WORD         => INTEGER_VALUE_FOR_AV_SYMBOLS_PER_WORD,
			AV_ADDRESS_SYMBOLS          => INTEGER_VALUE_FOR_AV_ADDRESS_SYMBOLS,
			AV_BURSTCOUNT_SYMBOLS       => INTEGER_VALUE_FOR_AV_BURSTCOUNT_SYMBOLS,
			AV_CONSTANT_BURST_BEHAVIOR  => INTEGER_VALUE_FOR_AV_CONSTANT_BURST_BEHAVIOR,
			UAV_CONSTANT_BURST_BEHAVIOR => INTEGER_VALUE_FOR_UAV_CONSTANT_BURST_BEHAVIOR,
			AV_LINEWRAPBURSTS           => INTEGER_VALUE_FOR_AV_LINEWRAPBURSTS,
			AV_REGISTERINCOMINGSIGNALS  => INTEGER_VALUE_FOR_AV_REGISTERINCOMINGSIGNALS,
			SYNC_RESET                  => INTEGER_VALUE_FOR_SYNC_RESET
		)
		port map (
			clk               => CONNECTED_TO_clk,               --                       clk.clk
			reset             => CONNECTED_TO_reset,             --                     reset.reset
			uav_address       => CONNECTED_TO_uav_address,       -- avalon_universal_master_0.address
			uav_burstcount    => CONNECTED_TO_uav_burstcount,    --                          .burstcount
			uav_read          => CONNECTED_TO_uav_read,          --                          .read
			uav_write         => CONNECTED_TO_uav_write,         --                          .write
			uav_waitrequest   => CONNECTED_TO_uav_waitrequest,   --                          .waitrequest
			uav_readdatavalid => CONNECTED_TO_uav_readdatavalid, --                          .readdatavalid
			uav_byteenable    => CONNECTED_TO_uav_byteenable,    --                          .byteenable
			uav_readdata      => CONNECTED_TO_uav_readdata,      --                          .readdata
			uav_writedata     => CONNECTED_TO_uav_writedata,     --                          .writedata
			uav_lock          => CONNECTED_TO_uav_lock,          --                          .lock
			uav_debugaccess   => CONNECTED_TO_uav_debugaccess,   --                          .debugaccess
			av_address        => CONNECTED_TO_av_address,        --      avalon_anti_master_0.address
			av_waitrequest    => CONNECTED_TO_av_waitrequest,    --                          .waitrequest
			av_read           => CONNECTED_TO_av_read,           --                          .read
			av_readdata       => CONNECTED_TO_av_readdata,       --                          .readdata
			av_write          => CONNECTED_TO_av_write,          --                          .write
			av_writedata      => CONNECTED_TO_av_writedata       --                          .writedata
		);

