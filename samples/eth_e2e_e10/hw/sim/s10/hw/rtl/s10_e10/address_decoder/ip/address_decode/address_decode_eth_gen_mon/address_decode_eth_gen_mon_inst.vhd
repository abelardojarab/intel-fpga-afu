	component address_decode_eth_gen_mon is
		generic (
			AV_ADDRESS_W                   : integer := 30;
			AV_DATA_W                      : integer := 32;
			UAV_DATA_W                     : integer := 32;
			AV_BURSTCOUNT_W                : integer := 4;
			AV_BYTEENABLE_W                : integer := 4;
			UAV_BYTEENABLE_W               : integer := 4;
			UAV_ADDRESS_W                  : integer := 32;
			UAV_BURSTCOUNT_W               : integer := 4;
			AV_READLATENCY                 : integer := 0;
			USE_READDATAVALID              : integer := 1;
			USE_WAITREQUEST                : integer := 1;
			USE_UAV_CLKEN                  : integer := 0;
			USE_READRESPONSE               : integer := 0;
			USE_WRITERESPONSE              : integer := 0;
			AV_SYMBOLS_PER_WORD            : integer := 4;
			AV_ADDRESS_SYMBOLS             : integer := 0;
			AV_BURSTCOUNT_SYMBOLS          : integer := 0;
			AV_CONSTANT_BURST_BEHAVIOR     : integer := 0;
			UAV_CONSTANT_BURST_BEHAVIOR    : integer := 0;
			AV_REQUIRE_UNALIGNED_ADDRESSES : integer := 0;
			CHIPSELECT_THROUGH_READLATENCY : integer := 0;
			AV_READ_WAIT_CYCLES            : integer := 0;
			AV_WRITE_WAIT_CYCLES           : integer := 0;
			AV_SETUP_WAIT_CYCLES           : integer := 0;
			AV_DATA_HOLD_CYCLES            : integer := 0;
			WAITREQUEST_ALLOWANCE          : integer := 0;
			SYNC_RESET                     : integer := 0
		);
		port (
			clk               : in  std_logic                     := 'X';             -- clk
			reset             : in  std_logic                     := 'X';             -- reset
			uav_address       : in  std_logic_vector(13 downto 0) := (others => 'X'); -- address
			uav_burstcount    : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- burstcount
			uav_read          : in  std_logic                     := 'X';             -- read
			uav_write         : in  std_logic                     := 'X';             -- write
			uav_waitrequest   : out std_logic;                                        -- waitrequest
			uav_readdatavalid : out std_logic;                                        -- readdatavalid
			uav_byteenable    : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- byteenable
			uav_readdata      : out std_logic_vector(31 downto 0);                    -- readdata
			uav_writedata     : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			uav_lock          : in  std_logic                     := 'X';             -- lock
			uav_debugaccess   : in  std_logic                     := 'X';             -- debugaccess
			av_address        : out std_logic_vector(11 downto 0);                    -- address
			av_write          : out std_logic;                                        -- write
			av_read           : out std_logic;                                        -- read
			av_readdata       : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			av_writedata      : out std_logic_vector(31 downto 0);                    -- writedata
			av_waitrequest    : in  std_logic                     := 'X'              -- waitrequest
		);
	end component address_decode_eth_gen_mon;

	u0 : component address_decode_eth_gen_mon
		generic map (
			AV_ADDRESS_W                   => INTEGER_VALUE_FOR_AV_ADDRESS_W,
			AV_DATA_W                      => INTEGER_VALUE_FOR_AV_DATA_W,
			UAV_DATA_W                     => INTEGER_VALUE_FOR_UAV_DATA_W,
			AV_BURSTCOUNT_W                => INTEGER_VALUE_FOR_AV_BURSTCOUNT_W,
			AV_BYTEENABLE_W                => INTEGER_VALUE_FOR_AV_BYTEENABLE_W,
			UAV_BYTEENABLE_W               => INTEGER_VALUE_FOR_UAV_BYTEENABLE_W,
			UAV_ADDRESS_W                  => INTEGER_VALUE_FOR_UAV_ADDRESS_W,
			UAV_BURSTCOUNT_W               => INTEGER_VALUE_FOR_UAV_BURSTCOUNT_W,
			AV_READLATENCY                 => INTEGER_VALUE_FOR_AV_READLATENCY,
			USE_READDATAVALID              => INTEGER_VALUE_FOR_USE_READDATAVALID,
			USE_WAITREQUEST                => INTEGER_VALUE_FOR_USE_WAITREQUEST,
			USE_UAV_CLKEN                  => INTEGER_VALUE_FOR_USE_UAV_CLKEN,
			USE_READRESPONSE               => INTEGER_VALUE_FOR_USE_READRESPONSE,
			USE_WRITERESPONSE              => INTEGER_VALUE_FOR_USE_WRITERESPONSE,
			AV_SYMBOLS_PER_WORD            => INTEGER_VALUE_FOR_AV_SYMBOLS_PER_WORD,
			AV_ADDRESS_SYMBOLS             => INTEGER_VALUE_FOR_AV_ADDRESS_SYMBOLS,
			AV_BURSTCOUNT_SYMBOLS          => INTEGER_VALUE_FOR_AV_BURSTCOUNT_SYMBOLS,
			AV_CONSTANT_BURST_BEHAVIOR     => INTEGER_VALUE_FOR_AV_CONSTANT_BURST_BEHAVIOR,
			UAV_CONSTANT_BURST_BEHAVIOR    => INTEGER_VALUE_FOR_UAV_CONSTANT_BURST_BEHAVIOR,
			AV_REQUIRE_UNALIGNED_ADDRESSES => INTEGER_VALUE_FOR_AV_REQUIRE_UNALIGNED_ADDRESSES,
			CHIPSELECT_THROUGH_READLATENCY => INTEGER_VALUE_FOR_CHIPSELECT_THROUGH_READLATENCY,
			AV_READ_WAIT_CYCLES            => INTEGER_VALUE_FOR_AV_READ_WAIT_CYCLES,
			AV_WRITE_WAIT_CYCLES           => INTEGER_VALUE_FOR_AV_WRITE_WAIT_CYCLES,
			AV_SETUP_WAIT_CYCLES           => INTEGER_VALUE_FOR_AV_SETUP_WAIT_CYCLES,
			AV_DATA_HOLD_CYCLES            => INTEGER_VALUE_FOR_AV_DATA_HOLD_CYCLES,
			WAITREQUEST_ALLOWANCE          => INTEGER_VALUE_FOR_WAITREQUEST_ALLOWANCE,
			SYNC_RESET                     => INTEGER_VALUE_FOR_SYNC_RESET
		)
		port map (
			clk               => CONNECTED_TO_clk,               --                      clk.clk
			reset             => CONNECTED_TO_reset,             --                    reset.reset
			uav_address       => CONNECTED_TO_uav_address,       -- avalon_universal_slave_0.address
			uav_burstcount    => CONNECTED_TO_uav_burstcount,    --                         .burstcount
			uav_read          => CONNECTED_TO_uav_read,          --                         .read
			uav_write         => CONNECTED_TO_uav_write,         --                         .write
			uav_waitrequest   => CONNECTED_TO_uav_waitrequest,   --                         .waitrequest
			uav_readdatavalid => CONNECTED_TO_uav_readdatavalid, --                         .readdatavalid
			uav_byteenable    => CONNECTED_TO_uav_byteenable,    --                         .byteenable
			uav_readdata      => CONNECTED_TO_uav_readdata,      --                         .readdata
			uav_writedata     => CONNECTED_TO_uav_writedata,     --                         .writedata
			uav_lock          => CONNECTED_TO_uav_lock,          --                         .lock
			uav_debugaccess   => CONNECTED_TO_uav_debugaccess,   --                         .debugaccess
			av_address        => CONNECTED_TO_av_address,        --      avalon_anti_slave_0.address
			av_write          => CONNECTED_TO_av_write,          --                         .write
			av_read           => CONNECTED_TO_av_read,           --                         .read
			av_readdata       => CONNECTED_TO_av_readdata,       --                         .readdata
			av_writedata      => CONNECTED_TO_av_writedata,      --                         .writedata
			av_waitrequest    => CONNECTED_TO_av_waitrequest     --                         .waitrequest
		);

