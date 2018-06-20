	component memory_to_stream_dma_bbb is
		port (
			clk_clk                     : in  std_logic                      := 'X';             -- clk
			csr_waitrequest             : out std_logic;                                         -- waitrequest
			csr_readdata                : out std_logic_vector(63 downto 0);                     -- readdata
			csr_readdatavalid           : out std_logic;                                         -- readdatavalid
			csr_burstcount              : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- burstcount
			csr_writedata               : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- writedata
			csr_address                 : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- address
			csr_write                   : in  std_logic                      := 'X';             -- write
			csr_read                    : in  std_logic                      := 'X';             -- read
			csr_byteenable              : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- byteenable
			csr_debugaccess             : in  std_logic                      := 'X';             -- debugaccess
			host_read_waitrequest       : in  std_logic                      := 'X';             -- waitrequest
			host_read_readdata          : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			host_read_readdatavalid     : in  std_logic                      := 'X';             -- readdatavalid
			host_read_burstcount        : out std_logic_vector(2 downto 0);                      -- burstcount
			host_read_writedata         : out std_logic_vector(511 downto 0);                    -- writedata
			host_read_address           : out std_logic_vector(47 downto 0);                     -- address
			host_read_write             : out std_logic;                                         -- write
			host_read_read              : out std_logic;                                         -- read
			host_read_byteenable        : out std_logic_vector(63 downto 0);                     -- byteenable
			host_read_debugaccess       : out std_logic;                                         -- debugaccess
			m2s_irq_irq                 : out std_logic;                                         -- irq
			m2s_st_source_data          : out std_logic_vector(511 downto 0);                    -- data
			m2s_st_source_valid         : out std_logic;                                         -- valid
			m2s_st_source_ready         : in  std_logic                      := 'X';             -- ready
			m2s_st_source_startofpacket : out std_logic;                                         -- startofpacket
			m2s_st_source_endofpacket   : out std_logic;                                         -- endofpacket
			m2s_st_source_empty         : out std_logic_vector(5 downto 0);                      -- empty
			mem_read_waitrequest        : in  std_logic                      := 'X';             -- waitrequest
			mem_read_readdata           : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			mem_read_readdatavalid      : in  std_logic                      := 'X';             -- readdatavalid
			mem_read_burstcount         : out std_logic_vector(2 downto 0);                      -- burstcount
			mem_read_writedata          : out std_logic_vector(511 downto 0);                    -- writedata
			mem_read_address            : out std_logic_vector(47 downto 0);                     -- address
			mem_read_write              : out std_logic;                                         -- write
			mem_read_read               : out std_logic;                                         -- read
			mem_read_byteenable         : out std_logic_vector(63 downto 0);                     -- byteenable
			mem_read_debugaccess        : out std_logic;                                         -- debugaccess
			reset_reset                 : in  std_logic                      := 'X'              -- reset
		);
	end component memory_to_stream_dma_bbb;

	u0 : component memory_to_stream_dma_bbb
		port map (
			clk_clk                     => CONNECTED_TO_clk_clk,                     --           clk.clk
			csr_waitrequest             => CONNECTED_TO_csr_waitrequest,             --           csr.waitrequest
			csr_readdata                => CONNECTED_TO_csr_readdata,                --              .readdata
			csr_readdatavalid           => CONNECTED_TO_csr_readdatavalid,           --              .readdatavalid
			csr_burstcount              => CONNECTED_TO_csr_burstcount,              --              .burstcount
			csr_writedata               => CONNECTED_TO_csr_writedata,               --              .writedata
			csr_address                 => CONNECTED_TO_csr_address,                 --              .address
			csr_write                   => CONNECTED_TO_csr_write,                   --              .write
			csr_read                    => CONNECTED_TO_csr_read,                    --              .read
			csr_byteenable              => CONNECTED_TO_csr_byteenable,              --              .byteenable
			csr_debugaccess             => CONNECTED_TO_csr_debugaccess,             --              .debugaccess
			host_read_waitrequest       => CONNECTED_TO_host_read_waitrequest,       --     host_read.waitrequest
			host_read_readdata          => CONNECTED_TO_host_read_readdata,          --              .readdata
			host_read_readdatavalid     => CONNECTED_TO_host_read_readdatavalid,     --              .readdatavalid
			host_read_burstcount        => CONNECTED_TO_host_read_burstcount,        --              .burstcount
			host_read_writedata         => CONNECTED_TO_host_read_writedata,         --              .writedata
			host_read_address           => CONNECTED_TO_host_read_address,           --              .address
			host_read_write             => CONNECTED_TO_host_read_write,             --              .write
			host_read_read              => CONNECTED_TO_host_read_read,              --              .read
			host_read_byteenable        => CONNECTED_TO_host_read_byteenable,        --              .byteenable
			host_read_debugaccess       => CONNECTED_TO_host_read_debugaccess,       --              .debugaccess
			m2s_irq_irq                 => CONNECTED_TO_m2s_irq_irq,                 --       m2s_irq.irq
			m2s_st_source_data          => CONNECTED_TO_m2s_st_source_data,          -- m2s_st_source.data
			m2s_st_source_valid         => CONNECTED_TO_m2s_st_source_valid,         --              .valid
			m2s_st_source_ready         => CONNECTED_TO_m2s_st_source_ready,         --              .ready
			m2s_st_source_startofpacket => CONNECTED_TO_m2s_st_source_startofpacket, --              .startofpacket
			m2s_st_source_endofpacket   => CONNECTED_TO_m2s_st_source_endofpacket,   --              .endofpacket
			m2s_st_source_empty         => CONNECTED_TO_m2s_st_source_empty,         --              .empty
			mem_read_waitrequest        => CONNECTED_TO_mem_read_waitrequest,        --      mem_read.waitrequest
			mem_read_readdata           => CONNECTED_TO_mem_read_readdata,           --              .readdata
			mem_read_readdatavalid      => CONNECTED_TO_mem_read_readdatavalid,      --              .readdatavalid
			mem_read_burstcount         => CONNECTED_TO_mem_read_burstcount,         --              .burstcount
			mem_read_writedata          => CONNECTED_TO_mem_read_writedata,          --              .writedata
			mem_read_address            => CONNECTED_TO_mem_read_address,            --              .address
			mem_read_write              => CONNECTED_TO_mem_read_write,              --              .write
			mem_read_read               => CONNECTED_TO_mem_read_read,               --              .read
			mem_read_byteenable         => CONNECTED_TO_mem_read_byteenable,         --              .byteenable
			mem_read_debugaccess        => CONNECTED_TO_mem_read_debugaccess,        --              .debugaccess
			reset_reset                 => CONNECTED_TO_reset_reset                  --         reset.reset
		);

