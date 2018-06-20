	component streaming_dma_test_system is
		port (
			dma_clock_clk                 : in  std_logic                      := 'X';             -- clk
			emif_a_avmm_waitrequest       : in  std_logic                      := 'X';             -- waitrequest
			emif_a_avmm_readdata          : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			emif_a_avmm_readdatavalid     : in  std_logic                      := 'X';             -- readdatavalid
			emif_a_avmm_burstcount        : out std_logic_vector(2 downto 0);                      -- burstcount
			emif_a_avmm_writedata         : out std_logic_vector(511 downto 0);                    -- writedata
			emif_a_avmm_address           : out std_logic_vector(31 downto 0);                     -- address
			emif_a_avmm_write             : out std_logic;                                         -- write
			emif_a_avmm_read              : out std_logic;                                         -- read
			emif_a_avmm_byteenable        : out std_logic_vector(63 downto 0);                     -- byteenable
			emif_a_avmm_debugaccess       : out std_logic;                                         -- debugaccess
			emif_a_clock_clk              : in  std_logic                      := 'X';             -- clk
			emif_b_avmm_waitrequest       : in  std_logic                      := 'X';             -- waitrequest
			emif_b_avmm_readdata          : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			emif_b_avmm_readdatavalid     : in  std_logic                      := 'X';             -- readdatavalid
			emif_b_avmm_burstcount        : out std_logic_vector(2 downto 0);                      -- burstcount
			emif_b_avmm_writedata         : out std_logic_vector(511 downto 0);                    -- writedata
			emif_b_avmm_address           : out std_logic_vector(31 downto 0);                     -- address
			emif_b_avmm_write             : out std_logic;                                         -- write
			emif_b_avmm_read              : out std_logic;                                         -- read
			emif_b_avmm_byteenable        : out std_logic_vector(63 downto 0);                     -- byteenable
			emif_b_avmm_debugaccess       : out std_logic;                                         -- debugaccess
			emif_b_clock_clk              : in  std_logic                      := 'X';             -- clk
			host_read_waitrequest         : in  std_logic                      := 'X';             -- waitrequest
			host_read_readdata            : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			host_read_readdatavalid       : in  std_logic                      := 'X';             -- readdatavalid
			host_read_burstcount          : out std_logic_vector(2 downto 0);                      -- burstcount
			host_read_writedata           : out std_logic_vector(511 downto 0);                    -- writedata
			host_read_address             : out std_logic_vector(47 downto 0);                     -- address
			host_read_write               : out std_logic;                                         -- write
			host_read_read                : out std_logic;                                         -- read
			host_read_byteenable          : out std_logic_vector(63 downto 0);                     -- byteenable
			host_read_debugaccess         : out std_logic;                                         -- debugaccess
			host_write_address            : out std_logic_vector(47 downto 0);                     -- address
			host_write_writedata          : out std_logic_vector(511 downto 0);                    -- writedata
			host_write_write              : out std_logic;                                         -- write
			host_write_byteenable         : out std_logic_vector(63 downto 0);                     -- byteenable
			host_write_burstcount         : out std_logic_vector(2 downto 0);                      -- burstcount
			host_write_response           : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- response
			host_write_waitrequest        : in  std_logic                      := 'X';             -- waitrequest
			host_write_writeresponsevalid : in  std_logic                      := 'X';             -- writeresponsevalid
			m2s_irq_irq                   : out std_logic;                                         -- irq
			mmio_avmm_waitrequest         : out std_logic;                                         -- waitrequest
			mmio_avmm_readdata            : out std_logic_vector(63 downto 0);                     -- readdata
			mmio_avmm_readdatavalid       : out std_logic;                                         -- readdatavalid
			mmio_avmm_burstcount          : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- burstcount
			mmio_avmm_writedata           : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- writedata
			mmio_avmm_address             : in  std_logic_vector(17 downto 0)  := (others => 'X'); -- address
			mmio_avmm_write               : in  std_logic                      := 'X';             -- write
			mmio_avmm_read                : in  std_logic                      := 'X';             -- read
			mmio_avmm_byteenable          : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- byteenable
			mmio_avmm_debugaccess         : in  std_logic                      := 'X';             -- debugaccess
			reset_reset                   : in  std_logic                      := 'X';             -- reset
			s2m_irq_irq                   : out std_logic                                          -- irq
		);
	end component streaming_dma_test_system;

	u0 : component streaming_dma_test_system
		port map (
			dma_clock_clk                 => CONNECTED_TO_dma_clock_clk,                 --    dma_clock.clk
			emif_a_avmm_waitrequest       => CONNECTED_TO_emif_a_avmm_waitrequest,       --  emif_a_avmm.waitrequest
			emif_a_avmm_readdata          => CONNECTED_TO_emif_a_avmm_readdata,          --             .readdata
			emif_a_avmm_readdatavalid     => CONNECTED_TO_emif_a_avmm_readdatavalid,     --             .readdatavalid
			emif_a_avmm_burstcount        => CONNECTED_TO_emif_a_avmm_burstcount,        --             .burstcount
			emif_a_avmm_writedata         => CONNECTED_TO_emif_a_avmm_writedata,         --             .writedata
			emif_a_avmm_address           => CONNECTED_TO_emif_a_avmm_address,           --             .address
			emif_a_avmm_write             => CONNECTED_TO_emif_a_avmm_write,             --             .write
			emif_a_avmm_read              => CONNECTED_TO_emif_a_avmm_read,              --             .read
			emif_a_avmm_byteenable        => CONNECTED_TO_emif_a_avmm_byteenable,        --             .byteenable
			emif_a_avmm_debugaccess       => CONNECTED_TO_emif_a_avmm_debugaccess,       --             .debugaccess
			emif_a_clock_clk              => CONNECTED_TO_emif_a_clock_clk,              -- emif_a_clock.clk
			emif_b_avmm_waitrequest       => CONNECTED_TO_emif_b_avmm_waitrequest,       --  emif_b_avmm.waitrequest
			emif_b_avmm_readdata          => CONNECTED_TO_emif_b_avmm_readdata,          --             .readdata
			emif_b_avmm_readdatavalid     => CONNECTED_TO_emif_b_avmm_readdatavalid,     --             .readdatavalid
			emif_b_avmm_burstcount        => CONNECTED_TO_emif_b_avmm_burstcount,        --             .burstcount
			emif_b_avmm_writedata         => CONNECTED_TO_emif_b_avmm_writedata,         --             .writedata
			emif_b_avmm_address           => CONNECTED_TO_emif_b_avmm_address,           --             .address
			emif_b_avmm_write             => CONNECTED_TO_emif_b_avmm_write,             --             .write
			emif_b_avmm_read              => CONNECTED_TO_emif_b_avmm_read,              --             .read
			emif_b_avmm_byteenable        => CONNECTED_TO_emif_b_avmm_byteenable,        --             .byteenable
			emif_b_avmm_debugaccess       => CONNECTED_TO_emif_b_avmm_debugaccess,       --             .debugaccess
			emif_b_clock_clk              => CONNECTED_TO_emif_b_clock_clk,              -- emif_b_clock.clk
			host_read_waitrequest         => CONNECTED_TO_host_read_waitrequest,         --    host_read.waitrequest
			host_read_readdata            => CONNECTED_TO_host_read_readdata,            --             .readdata
			host_read_readdatavalid       => CONNECTED_TO_host_read_readdatavalid,       --             .readdatavalid
			host_read_burstcount          => CONNECTED_TO_host_read_burstcount,          --             .burstcount
			host_read_writedata           => CONNECTED_TO_host_read_writedata,           --             .writedata
			host_read_address             => CONNECTED_TO_host_read_address,             --             .address
			host_read_write               => CONNECTED_TO_host_read_write,               --             .write
			host_read_read                => CONNECTED_TO_host_read_read,                --             .read
			host_read_byteenable          => CONNECTED_TO_host_read_byteenable,          --             .byteenable
			host_read_debugaccess         => CONNECTED_TO_host_read_debugaccess,         --             .debugaccess
			host_write_address            => CONNECTED_TO_host_write_address,            --   host_write.address
			host_write_writedata          => CONNECTED_TO_host_write_writedata,          --             .writedata
			host_write_write              => CONNECTED_TO_host_write_write,              --             .write
			host_write_byteenable         => CONNECTED_TO_host_write_byteenable,         --             .byteenable
			host_write_burstcount         => CONNECTED_TO_host_write_burstcount,         --             .burstcount
			host_write_response           => CONNECTED_TO_host_write_response,           --             .response
			host_write_waitrequest        => CONNECTED_TO_host_write_waitrequest,        --             .waitrequest
			host_write_writeresponsevalid => CONNECTED_TO_host_write_writeresponsevalid, --             .writeresponsevalid
			m2s_irq_irq                   => CONNECTED_TO_m2s_irq_irq,                   --      m2s_irq.irq
			mmio_avmm_waitrequest         => CONNECTED_TO_mmio_avmm_waitrequest,         --    mmio_avmm.waitrequest
			mmio_avmm_readdata            => CONNECTED_TO_mmio_avmm_readdata,            --             .readdata
			mmio_avmm_readdatavalid       => CONNECTED_TO_mmio_avmm_readdatavalid,       --             .readdatavalid
			mmio_avmm_burstcount          => CONNECTED_TO_mmio_avmm_burstcount,          --             .burstcount
			mmio_avmm_writedata           => CONNECTED_TO_mmio_avmm_writedata,           --             .writedata
			mmio_avmm_address             => CONNECTED_TO_mmio_avmm_address,             --             .address
			mmio_avmm_write               => CONNECTED_TO_mmio_avmm_write,               --             .write
			mmio_avmm_read                => CONNECTED_TO_mmio_avmm_read,                --             .read
			mmio_avmm_byteenable          => CONNECTED_TO_mmio_avmm_byteenable,          --             .byteenable
			mmio_avmm_debugaccess         => CONNECTED_TO_mmio_avmm_debugaccess,         --             .debugaccess
			reset_reset                   => CONNECTED_TO_reset_reset,                   --        reset.reset
			s2m_irq_irq                   => CONNECTED_TO_s2m_irq_irq                    --      s2m_irq.irq
		);

