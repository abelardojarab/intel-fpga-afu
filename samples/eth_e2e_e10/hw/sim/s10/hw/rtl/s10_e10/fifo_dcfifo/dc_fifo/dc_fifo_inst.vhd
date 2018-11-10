	component dc_fifo is
		port (
			dc_fifo_0_in_data               : in  std_logic_vector(31 downto 0) := (others => 'X'); -- data
			dc_fifo_0_in_valid              : in  std_logic                     := 'X';             -- valid
			dc_fifo_0_in_ready              : out std_logic;                                        -- ready
			dc_fifo_0_in_startofpacket      : in  std_logic                     := 'X';             -- startofpacket
			dc_fifo_0_in_endofpacket        : in  std_logic                     := 'X';             -- endofpacket
			dc_fifo_0_in_empty              : in  std_logic_vector(1 downto 0)  := (others => 'X'); -- empty
			dc_fifo_0_in_error              : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- error
			dc_fifo_0_in_clk_clk            : in  std_logic                     := 'X';             -- clk
			dc_fifo_0_in_clk_reset_reset_n  : in  std_logic                     := 'X';             -- reset_n
			dc_fifo_0_out_data              : out std_logic_vector(31 downto 0);                    -- data
			dc_fifo_0_out_valid             : out std_logic;                                        -- valid
			dc_fifo_0_out_ready             : in  std_logic                     := 'X';             -- ready
			dc_fifo_0_out_startofpacket     : out std_logic;                                        -- startofpacket
			dc_fifo_0_out_endofpacket       : out std_logic;                                        -- endofpacket
			dc_fifo_0_out_empty             : out std_logic_vector(1 downto 0);                     -- empty
			dc_fifo_0_out_error             : out std_logic_vector(0 downto 0);                     -- error
			dc_fifo_0_out_clk_clk           : in  std_logic                     := 'X';             -- clk
			dc_fifo_0_out_clk_reset_reset_n : in  std_logic                     := 'X'              -- reset_n
		);
	end component dc_fifo;

	u0 : component dc_fifo
		port map (
			dc_fifo_0_in_data               => CONNECTED_TO_dc_fifo_0_in_data,               --            dc_fifo_0_in.data
			dc_fifo_0_in_valid              => CONNECTED_TO_dc_fifo_0_in_valid,              --                        .valid
			dc_fifo_0_in_ready              => CONNECTED_TO_dc_fifo_0_in_ready,              --                        .ready
			dc_fifo_0_in_startofpacket      => CONNECTED_TO_dc_fifo_0_in_startofpacket,      --                        .startofpacket
			dc_fifo_0_in_endofpacket        => CONNECTED_TO_dc_fifo_0_in_endofpacket,        --                        .endofpacket
			dc_fifo_0_in_empty              => CONNECTED_TO_dc_fifo_0_in_empty,              --                        .empty
			dc_fifo_0_in_error              => CONNECTED_TO_dc_fifo_0_in_error,              --                        .error
			dc_fifo_0_in_clk_clk            => CONNECTED_TO_dc_fifo_0_in_clk_clk,            --        dc_fifo_0_in_clk.clk
			dc_fifo_0_in_clk_reset_reset_n  => CONNECTED_TO_dc_fifo_0_in_clk_reset_reset_n,  --  dc_fifo_0_in_clk_reset.reset_n
			dc_fifo_0_out_data              => CONNECTED_TO_dc_fifo_0_out_data,              --           dc_fifo_0_out.data
			dc_fifo_0_out_valid             => CONNECTED_TO_dc_fifo_0_out_valid,             --                        .valid
			dc_fifo_0_out_ready             => CONNECTED_TO_dc_fifo_0_out_ready,             --                        .ready
			dc_fifo_0_out_startofpacket     => CONNECTED_TO_dc_fifo_0_out_startofpacket,     --                        .startofpacket
			dc_fifo_0_out_endofpacket       => CONNECTED_TO_dc_fifo_0_out_endofpacket,       --                        .endofpacket
			dc_fifo_0_out_empty             => CONNECTED_TO_dc_fifo_0_out_empty,             --                        .empty
			dc_fifo_0_out_error             => CONNECTED_TO_dc_fifo_0_out_error,             --                        .error
			dc_fifo_0_out_clk_clk           => CONNECTED_TO_dc_fifo_0_out_clk_clk,           --       dc_fifo_0_out_clk.clk
			dc_fifo_0_out_clk_reset_reset_n => CONNECTED_TO_dc_fifo_0_out_clk_reset_reset_n  -- dc_fifo_0_out_clk_reset.reset_n
		);

