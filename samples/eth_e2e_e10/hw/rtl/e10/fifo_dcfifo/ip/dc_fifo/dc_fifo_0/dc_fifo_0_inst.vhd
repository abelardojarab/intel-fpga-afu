	component dc_fifo_0 is
		port (
			in_data           : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
			in_valid          : in  std_logic                     := 'X';             -- valid
			in_ready          : out std_logic;                                        -- ready
			in_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
			in_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
			in_empty          : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- empty
			in_error          : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- error
			in_clk            : in  std_logic                     := 'X';             -- clk
			in_reset_n        : in  std_logic                     := 'X';             -- reset_n
			out_data          : out std_logic_vector(31 downto 0);                    -- data
			out_valid         : out std_logic;                                        -- valid
			out_ready         : in  std_logic                     := 'X';             -- ready
			out_startofpacket : out std_logic;                                        -- startofpacket
			out_endofpacket   : out std_logic;                                        -- endofpacket
			out_empty         : out std_logic_vector(1 downto 0);                     -- empty
			out_error         : out std_logic_vector(0 downto 0);                     -- error
			out_clk           : in  std_logic                     := 'X';             -- clk
			out_reset_n       : in  std_logic                     := 'X'              -- reset_n
		);
	end component dc_fifo_0;

	u0 : component dc_fifo_0
		port map (
			in_data           => CONNECTED_TO_in_data,           --            in.data
			in_valid          => CONNECTED_TO_in_valid,          --              .valid
			in_ready          => CONNECTED_TO_in_ready,          --              .ready
			in_startofpacket  => CONNECTED_TO_in_startofpacket,  --              .startofpacket
			in_endofpacket    => CONNECTED_TO_in_endofpacket,    --              .endofpacket
			in_empty          => CONNECTED_TO_in_empty,          --              .empty
			in_error          => CONNECTED_TO_in_error,          --              .error
			in_clk            => CONNECTED_TO_in_clk,            --        in_clk.clk
			in_reset_n        => CONNECTED_TO_in_reset_n,        --  in_clk_reset.reset_n
			out_data          => CONNECTED_TO_out_data,          --           out.data
			out_valid         => CONNECTED_TO_out_valid,         --              .valid
			out_ready         => CONNECTED_TO_out_ready,         --              .ready
			out_startofpacket => CONNECTED_TO_out_startofpacket, --              .startofpacket
			out_endofpacket   => CONNECTED_TO_out_endofpacket,   --              .endofpacket
			out_empty         => CONNECTED_TO_out_empty,         --              .empty
			out_error         => CONNECTED_TO_out_error,         --              .error
			out_clk           => CONNECTED_TO_out_clk,           --       out_clk.clk
			out_reset_n       => CONNECTED_TO_out_reset_n        -- out_clk_reset.reset_n
		);

