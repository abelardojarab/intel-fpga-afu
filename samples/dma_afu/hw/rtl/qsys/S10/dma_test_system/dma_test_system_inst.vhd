	component dma_test_system is
		port (
			ccip_avmm_mmio_waitrequest           : out std_logic;                                         -- waitrequest
			ccip_avmm_mmio_readdata              : out std_logic_vector(63 downto 0);                     -- readdata
			ccip_avmm_mmio_readdatavalid         : out std_logic;                                         -- readdatavalid
			ccip_avmm_mmio_burstcount            : in  std_logic_vector(0 downto 0)   := (others => 'X'); -- burstcount
			ccip_avmm_mmio_writedata             : in  std_logic_vector(63 downto 0)  := (others => 'X'); -- writedata
			ccip_avmm_mmio_address               : in  std_logic_vector(17 downto 0)  := (others => 'X'); -- address
			ccip_avmm_mmio_write                 : in  std_logic                      := 'X';             -- write
			ccip_avmm_mmio_read                  : in  std_logic                      := 'X';             -- read
			ccip_avmm_mmio_byteenable            : in  std_logic_vector(7 downto 0)   := (others => 'X'); -- byteenable
			ccip_avmm_mmio_debugaccess           : in  std_logic                      := 'X';             -- debugaccess
			ccip_avmm_requestor_rd_waitrequest   : in  std_logic                      := 'X';             -- waitrequest
			ccip_avmm_requestor_rd_readdata      : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			ccip_avmm_requestor_rd_readdatavalid : in  std_logic                      := 'X';             -- readdatavalid
			ccip_avmm_requestor_rd_burstcount    : out std_logic_vector(2 downto 0);                      -- burstcount
			ccip_avmm_requestor_rd_writedata     : out std_logic_vector(511 downto 0);                    -- writedata
			ccip_avmm_requestor_rd_address       : out std_logic_vector(47 downto 0);                     -- address
			ccip_avmm_requestor_rd_write         : out std_logic;                                         -- write
			ccip_avmm_requestor_rd_read          : out std_logic;                                         -- read
			ccip_avmm_requestor_rd_byteenable    : out std_logic_vector(63 downto 0);                     -- byteenable
			ccip_avmm_requestor_rd_debugaccess   : out std_logic;                                         -- debugaccess
			ccip_avmm_requestor_wr_waitrequest   : in  std_logic                      := 'X';             -- waitrequest
			ccip_avmm_requestor_wr_readdata      : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			ccip_avmm_requestor_wr_readdatavalid : in  std_logic                      := 'X';             -- readdatavalid
			ccip_avmm_requestor_wr_burstcount    : out std_logic_vector(2 downto 0);                      -- burstcount
			ccip_avmm_requestor_wr_writedata     : out std_logic_vector(511 downto 0);                    -- writedata
			ccip_avmm_requestor_wr_address       : out std_logic_vector(48 downto 0);                     -- address
			ccip_avmm_requestor_wr_write         : out std_logic;                                         -- write
			ccip_avmm_requestor_wr_read          : out std_logic;                                         -- read
			ccip_avmm_requestor_wr_byteenable    : out std_logic_vector(63 downto 0);                     -- byteenable
			ccip_avmm_requestor_wr_debugaccess   : out std_logic;                                         -- debugaccess
			ddr4a_clk_clk                        : in  std_logic                      := 'X';             -- clk
			ddr4a_master_waitrequest             : in  std_logic                      := 'X';             -- waitrequest
			ddr4a_master_readdata                : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			ddr4a_master_readdatavalid           : in  std_logic                      := 'X';             -- readdatavalid
			ddr4a_master_burstcount              : out std_logic_vector(2 downto 0);                      -- burstcount
			ddr4a_master_writedata               : out std_logic_vector(511 downto 0);                    -- writedata
			ddr4a_master_address                 : out std_logic_vector(31 downto 0);                     -- address
			ddr4a_master_write                   : out std_logic;                                         -- write
			ddr4a_master_read                    : out std_logic;                                         -- read
			ddr4a_master_byteenable              : out std_logic_vector(63 downto 0);                     -- byteenable
			ddr4a_master_debugaccess             : out std_logic;                                         -- debugaccess
			ddr4b_clk_clk                        : in  std_logic                      := 'X';             -- clk
			ddr4b_master_waitrequest             : in  std_logic                      := 'X';             -- waitrequest
			ddr4b_master_readdata                : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			ddr4b_master_readdatavalid           : in  std_logic                      := 'X';             -- readdatavalid
			ddr4b_master_burstcount              : out std_logic_vector(2 downto 0);                      -- burstcount
			ddr4b_master_writedata               : out std_logic_vector(511 downto 0);                    -- writedata
			ddr4b_master_address                 : out std_logic_vector(31 downto 0);                     -- address
			ddr4b_master_write                   : out std_logic;                                         -- write
			ddr4b_master_read                    : out std_logic;                                         -- read
			ddr4b_master_byteenable              : out std_logic_vector(63 downto 0);                     -- byteenable
			ddr4b_master_debugaccess             : out std_logic;                                         -- debugaccess
			ddr4c_clk_clk                        : in  std_logic                      := 'X';             -- clk
			ddr4c_master_waitrequest             : in  std_logic                      := 'X';             -- waitrequest
			ddr4c_master_readdata                : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			ddr4c_master_readdatavalid           : in  std_logic                      := 'X';             -- readdatavalid
			ddr4c_master_burstcount              : out std_logic_vector(2 downto 0);                      -- burstcount
			ddr4c_master_writedata               : out std_logic_vector(511 downto 0);                    -- writedata
			ddr4c_master_address                 : out std_logic_vector(31 downto 0);                     -- address
			ddr4c_master_write                   : out std_logic;                                         -- write
			ddr4c_master_read                    : out std_logic;                                         -- read
			ddr4c_master_byteenable              : out std_logic_vector(63 downto 0);                     -- byteenable
			ddr4c_master_debugaccess             : out std_logic;                                         -- debugaccess
			ddr4d_clk_clk                        : in  std_logic                      := 'X';             -- clk
			ddr4d_master_waitrequest             : in  std_logic                      := 'X';             -- waitrequest
			ddr4d_master_readdata                : in  std_logic_vector(511 downto 0) := (others => 'X'); -- readdata
			ddr4d_master_readdatavalid           : in  std_logic                      := 'X';             -- readdatavalid
			ddr4d_master_burstcount              : out std_logic_vector(2 downto 0);                      -- burstcount
			ddr4d_master_writedata               : out std_logic_vector(511 downto 0);                    -- writedata
			ddr4d_master_address                 : out std_logic_vector(31 downto 0);                     -- address
			ddr4d_master_write                   : out std_logic;                                         -- write
			ddr4d_master_read                    : out std_logic;                                         -- read
			ddr4d_master_byteenable              : out std_logic_vector(63 downto 0);                     -- byteenable
			ddr4d_master_debugaccess             : out std_logic;                                         -- debugaccess
			dma_irq_irq                          : out std_logic;                                         -- irq
			host_clk_clk                         : in  std_logic                      := 'X';             -- clk
			reset_reset                          : in  std_logic                      := 'X'              -- reset
		);
	end component dma_test_system;

	u0 : component dma_test_system
		port map (
			ccip_avmm_mmio_waitrequest           => CONNECTED_TO_ccip_avmm_mmio_waitrequest,           --         ccip_avmm_mmio.waitrequest
			ccip_avmm_mmio_readdata              => CONNECTED_TO_ccip_avmm_mmio_readdata,              --                       .readdata
			ccip_avmm_mmio_readdatavalid         => CONNECTED_TO_ccip_avmm_mmio_readdatavalid,         --                       .readdatavalid
			ccip_avmm_mmio_burstcount            => CONNECTED_TO_ccip_avmm_mmio_burstcount,            --                       .burstcount
			ccip_avmm_mmio_writedata             => CONNECTED_TO_ccip_avmm_mmio_writedata,             --                       .writedata
			ccip_avmm_mmio_address               => CONNECTED_TO_ccip_avmm_mmio_address,               --                       .address
			ccip_avmm_mmio_write                 => CONNECTED_TO_ccip_avmm_mmio_write,                 --                       .write
			ccip_avmm_mmio_read                  => CONNECTED_TO_ccip_avmm_mmio_read,                  --                       .read
			ccip_avmm_mmio_byteenable            => CONNECTED_TO_ccip_avmm_mmio_byteenable,            --                       .byteenable
			ccip_avmm_mmio_debugaccess           => CONNECTED_TO_ccip_avmm_mmio_debugaccess,           --                       .debugaccess
			ccip_avmm_requestor_rd_waitrequest   => CONNECTED_TO_ccip_avmm_requestor_rd_waitrequest,   -- ccip_avmm_requestor_rd.waitrequest
			ccip_avmm_requestor_rd_readdata      => CONNECTED_TO_ccip_avmm_requestor_rd_readdata,      --                       .readdata
			ccip_avmm_requestor_rd_readdatavalid => CONNECTED_TO_ccip_avmm_requestor_rd_readdatavalid, --                       .readdatavalid
			ccip_avmm_requestor_rd_burstcount    => CONNECTED_TO_ccip_avmm_requestor_rd_burstcount,    --                       .burstcount
			ccip_avmm_requestor_rd_writedata     => CONNECTED_TO_ccip_avmm_requestor_rd_writedata,     --                       .writedata
			ccip_avmm_requestor_rd_address       => CONNECTED_TO_ccip_avmm_requestor_rd_address,       --                       .address
			ccip_avmm_requestor_rd_write         => CONNECTED_TO_ccip_avmm_requestor_rd_write,         --                       .write
			ccip_avmm_requestor_rd_read          => CONNECTED_TO_ccip_avmm_requestor_rd_read,          --                       .read
			ccip_avmm_requestor_rd_byteenable    => CONNECTED_TO_ccip_avmm_requestor_rd_byteenable,    --                       .byteenable
			ccip_avmm_requestor_rd_debugaccess   => CONNECTED_TO_ccip_avmm_requestor_rd_debugaccess,   --                       .debugaccess
			ccip_avmm_requestor_wr_waitrequest   => CONNECTED_TO_ccip_avmm_requestor_wr_waitrequest,   -- ccip_avmm_requestor_wr.waitrequest
			ccip_avmm_requestor_wr_readdata      => CONNECTED_TO_ccip_avmm_requestor_wr_readdata,      --                       .readdata
			ccip_avmm_requestor_wr_readdatavalid => CONNECTED_TO_ccip_avmm_requestor_wr_readdatavalid, --                       .readdatavalid
			ccip_avmm_requestor_wr_burstcount    => CONNECTED_TO_ccip_avmm_requestor_wr_burstcount,    --                       .burstcount
			ccip_avmm_requestor_wr_writedata     => CONNECTED_TO_ccip_avmm_requestor_wr_writedata,     --                       .writedata
			ccip_avmm_requestor_wr_address       => CONNECTED_TO_ccip_avmm_requestor_wr_address,       --                       .address
			ccip_avmm_requestor_wr_write         => CONNECTED_TO_ccip_avmm_requestor_wr_write,         --                       .write
			ccip_avmm_requestor_wr_read          => CONNECTED_TO_ccip_avmm_requestor_wr_read,          --                       .read
			ccip_avmm_requestor_wr_byteenable    => CONNECTED_TO_ccip_avmm_requestor_wr_byteenable,    --                       .byteenable
			ccip_avmm_requestor_wr_debugaccess   => CONNECTED_TO_ccip_avmm_requestor_wr_debugaccess,   --                       .debugaccess
			ddr4a_clk_clk                        => CONNECTED_TO_ddr4a_clk_clk,                        --              ddr4a_clk.clk
			ddr4a_master_waitrequest             => CONNECTED_TO_ddr4a_master_waitrequest,             --           ddr4a_master.waitrequest
			ddr4a_master_readdata                => CONNECTED_TO_ddr4a_master_readdata,                --                       .readdata
			ddr4a_master_readdatavalid           => CONNECTED_TO_ddr4a_master_readdatavalid,           --                       .readdatavalid
			ddr4a_master_burstcount              => CONNECTED_TO_ddr4a_master_burstcount,              --                       .burstcount
			ddr4a_master_writedata               => CONNECTED_TO_ddr4a_master_writedata,               --                       .writedata
			ddr4a_master_address                 => CONNECTED_TO_ddr4a_master_address,                 --                       .address
			ddr4a_master_write                   => CONNECTED_TO_ddr4a_master_write,                   --                       .write
			ddr4a_master_read                    => CONNECTED_TO_ddr4a_master_read,                    --                       .read
			ddr4a_master_byteenable              => CONNECTED_TO_ddr4a_master_byteenable,              --                       .byteenable
			ddr4a_master_debugaccess             => CONNECTED_TO_ddr4a_master_debugaccess,             --                       .debugaccess
			ddr4b_clk_clk                        => CONNECTED_TO_ddr4b_clk_clk,                        --              ddr4b_clk.clk
			ddr4b_master_waitrequest             => CONNECTED_TO_ddr4b_master_waitrequest,             --           ddr4b_master.waitrequest
			ddr4b_master_readdata                => CONNECTED_TO_ddr4b_master_readdata,                --                       .readdata
			ddr4b_master_readdatavalid           => CONNECTED_TO_ddr4b_master_readdatavalid,           --                       .readdatavalid
			ddr4b_master_burstcount              => CONNECTED_TO_ddr4b_master_burstcount,              --                       .burstcount
			ddr4b_master_writedata               => CONNECTED_TO_ddr4b_master_writedata,               --                       .writedata
			ddr4b_master_address                 => CONNECTED_TO_ddr4b_master_address,                 --                       .address
			ddr4b_master_write                   => CONNECTED_TO_ddr4b_master_write,                   --                       .write
			ddr4b_master_read                    => CONNECTED_TO_ddr4b_master_read,                    --                       .read
			ddr4b_master_byteenable              => CONNECTED_TO_ddr4b_master_byteenable,              --                       .byteenable
			ddr4b_master_debugaccess             => CONNECTED_TO_ddr4b_master_debugaccess,             --                       .debugaccess
			ddr4c_clk_clk                        => CONNECTED_TO_ddr4c_clk_clk,                        --              ddr4c_clk.clk
			ddr4c_master_waitrequest             => CONNECTED_TO_ddr4c_master_waitrequest,             --           ddr4c_master.waitrequest
			ddr4c_master_readdata                => CONNECTED_TO_ddr4c_master_readdata,                --                       .readdata
			ddr4c_master_readdatavalid           => CONNECTED_TO_ddr4c_master_readdatavalid,           --                       .readdatavalid
			ddr4c_master_burstcount              => CONNECTED_TO_ddr4c_master_burstcount,              --                       .burstcount
			ddr4c_master_writedata               => CONNECTED_TO_ddr4c_master_writedata,               --                       .writedata
			ddr4c_master_address                 => CONNECTED_TO_ddr4c_master_address,                 --                       .address
			ddr4c_master_write                   => CONNECTED_TO_ddr4c_master_write,                   --                       .write
			ddr4c_master_read                    => CONNECTED_TO_ddr4c_master_read,                    --                       .read
			ddr4c_master_byteenable              => CONNECTED_TO_ddr4c_master_byteenable,              --                       .byteenable
			ddr4c_master_debugaccess             => CONNECTED_TO_ddr4c_master_debugaccess,             --                       .debugaccess
			ddr4d_clk_clk                        => CONNECTED_TO_ddr4d_clk_clk,                        --              ddr4d_clk.clk
			ddr4d_master_waitrequest             => CONNECTED_TO_ddr4d_master_waitrequest,             --           ddr4d_master.waitrequest
			ddr4d_master_readdata                => CONNECTED_TO_ddr4d_master_readdata,                --                       .readdata
			ddr4d_master_readdatavalid           => CONNECTED_TO_ddr4d_master_readdatavalid,           --                       .readdatavalid
			ddr4d_master_burstcount              => CONNECTED_TO_ddr4d_master_burstcount,              --                       .burstcount
			ddr4d_master_writedata               => CONNECTED_TO_ddr4d_master_writedata,               --                       .writedata
			ddr4d_master_address                 => CONNECTED_TO_ddr4d_master_address,                 --                       .address
			ddr4d_master_write                   => CONNECTED_TO_ddr4d_master_write,                   --                       .write
			ddr4d_master_read                    => CONNECTED_TO_ddr4d_master_read,                    --                       .read
			ddr4d_master_byteenable              => CONNECTED_TO_ddr4d_master_byteenable,              --                       .byteenable
			ddr4d_master_debugaccess             => CONNECTED_TO_ddr4d_master_debugaccess,             --                       .debugaccess
			dma_irq_irq                          => CONNECTED_TO_dma_irq_irq,                          --                dma_irq.irq
			host_clk_clk                         => CONNECTED_TO_host_clk_clk,                         --               host_clk.clk
			reset_reset                          => CONNECTED_TO_reset_reset                           --                  reset.reset
		);

