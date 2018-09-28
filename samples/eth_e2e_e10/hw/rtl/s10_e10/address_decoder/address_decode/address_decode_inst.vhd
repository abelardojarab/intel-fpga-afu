	component address_decode is
		port (
			clk_csr_clk                                                 : in  std_logic                     := 'X';             -- clk
			csr_reset_n                                                 : in  std_logic                     := 'X';             -- reset_n
			eth_gen_mon_0_avalon_anti_slave_0_address                   : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_0_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			eth_gen_mon_0_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			eth_gen_mon_0_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_0_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_0_avalon_anti_slave_0_waitrequest               : in  std_logic                     := 'X';             -- waitrequest
			eth_gen_mon_1_avalon_anti_slave_0_address                   : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_1_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			eth_gen_mon_1_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			eth_gen_mon_1_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_1_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_1_avalon_anti_slave_0_waitrequest               : in  std_logic                     := 'X';             -- waitrequest
			eth_gen_mon_10_avalon_anti_slave_0_address                  : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_10_avalon_anti_slave_0_write                    : out std_logic;                                        -- write
			eth_gen_mon_10_avalon_anti_slave_0_read                     : out std_logic;                                        -- read
			eth_gen_mon_10_avalon_anti_slave_0_readdata                 : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_10_avalon_anti_slave_0_writedata                : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_10_avalon_anti_slave_0_waitrequest              : in  std_logic                     := 'X';             -- waitrequest
			eth_gen_mon_11_avalon_anti_slave_0_address                  : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_11_avalon_anti_slave_0_write                    : out std_logic;                                        -- write
			eth_gen_mon_11_avalon_anti_slave_0_read                     : out std_logic;                                        -- read
			eth_gen_mon_11_avalon_anti_slave_0_readdata                 : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_11_avalon_anti_slave_0_writedata                : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_11_avalon_anti_slave_0_waitrequest              : in  std_logic                     := 'X';             -- waitrequest
			eth_gen_mon_2_avalon_anti_slave_0_address                   : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_2_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			eth_gen_mon_2_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			eth_gen_mon_2_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_2_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_2_avalon_anti_slave_0_waitrequest               : in  std_logic                     := 'X';             -- waitrequest
			eth_gen_mon_3_avalon_anti_slave_0_address                   : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_3_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			eth_gen_mon_3_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			eth_gen_mon_3_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_3_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_3_avalon_anti_slave_0_waitrequest               : in  std_logic                     := 'X';             -- waitrequest
			eth_gen_mon_4_avalon_anti_slave_0_address                   : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_4_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			eth_gen_mon_4_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			eth_gen_mon_4_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_4_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_4_avalon_anti_slave_0_waitrequest               : in  std_logic                     := 'X';             -- waitrequest
			eth_gen_mon_5_avalon_anti_slave_0_address                   : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_5_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			eth_gen_mon_5_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			eth_gen_mon_5_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_5_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_5_avalon_anti_slave_0_waitrequest               : in  std_logic                     := 'X';             -- waitrequest
			eth_gen_mon_6_avalon_anti_slave_0_address                   : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_6_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			eth_gen_mon_6_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			eth_gen_mon_6_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_6_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_6_avalon_anti_slave_0_waitrequest               : in  std_logic                     := 'X';             -- waitrequest
			eth_gen_mon_7_avalon_anti_slave_0_address                   : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_7_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			eth_gen_mon_7_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			eth_gen_mon_7_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_7_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_7_avalon_anti_slave_0_waitrequest               : in  std_logic                     := 'X';             -- waitrequest
			eth_gen_mon_8_avalon_anti_slave_0_address                   : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_8_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			eth_gen_mon_8_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			eth_gen_mon_8_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_8_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_8_avalon_anti_slave_0_waitrequest               : in  std_logic                     := 'X';             -- waitrequest
			eth_gen_mon_9_avalon_anti_slave_0_address                   : out std_logic_vector(11 downto 0);                    -- address
			eth_gen_mon_9_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			eth_gen_mon_9_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			eth_gen_mon_9_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			eth_gen_mon_9_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			eth_gen_mon_9_avalon_anti_slave_0_waitrequest               : in  std_logic                     := 'X';             -- waitrequest
			merlin_master_translator_0_avalon_anti_master_0_address     : in  std_logic_vector(15 downto 0) := (others => 'X'); -- address
			merlin_master_translator_0_avalon_anti_master_0_waitrequest : out std_logic;                                        -- waitrequest
			merlin_master_translator_0_avalon_anti_master_0_read        : in  std_logic                     := 'X';             -- read
			merlin_master_translator_0_avalon_anti_master_0_readdata    : out std_logic_vector(31 downto 0);                    -- readdata
			merlin_master_translator_0_avalon_anti_master_0_write       : in  std_logic                     := 'X';             -- write
			merlin_master_translator_0_avalon_anti_master_0_writedata   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			mac_0_avalon_anti_slave_0_address                           : out std_logic_vector(12 downto 0);                    -- address
			mac_0_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			mac_0_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			mac_0_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_0_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			mac_0_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			mac_1_avalon_anti_slave_0_address                           : out std_logic_vector(12 downto 0);                    -- address
			mac_1_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			mac_1_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			mac_1_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_1_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			mac_1_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			mac_10_avalon_anti_slave_0_address                          : out std_logic_vector(12 downto 0);                    -- address
			mac_10_avalon_anti_slave_0_write                            : out std_logic;                                        -- write
			mac_10_avalon_anti_slave_0_read                             : out std_logic;                                        -- read
			mac_10_avalon_anti_slave_0_readdata                         : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_10_avalon_anti_slave_0_writedata                        : out std_logic_vector(31 downto 0);                    -- writedata
			mac_10_avalon_anti_slave_0_waitrequest                      : in  std_logic                     := 'X';             -- waitrequest
			mac_11_avalon_anti_slave_0_address                          : out std_logic_vector(12 downto 0);                    -- address
			mac_11_avalon_anti_slave_0_write                            : out std_logic;                                        -- write
			mac_11_avalon_anti_slave_0_read                             : out std_logic;                                        -- read
			mac_11_avalon_anti_slave_0_readdata                         : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_11_avalon_anti_slave_0_writedata                        : out std_logic_vector(31 downto 0);                    -- writedata
			mac_11_avalon_anti_slave_0_waitrequest                      : in  std_logic                     := 'X';             -- waitrequest
			mac_2_avalon_anti_slave_0_address                           : out std_logic_vector(12 downto 0);                    -- address
			mac_2_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			mac_2_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			mac_2_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_2_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			mac_2_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			mac_3_avalon_anti_slave_0_address                           : out std_logic_vector(12 downto 0);                    -- address
			mac_3_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			mac_3_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			mac_3_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_3_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			mac_3_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			mac_4_avalon_anti_slave_0_address                           : out std_logic_vector(12 downto 0);                    -- address
			mac_4_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			mac_4_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			mac_4_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_4_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			mac_4_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			mac_5_avalon_anti_slave_0_address                           : out std_logic_vector(12 downto 0);                    -- address
			mac_5_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			mac_5_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			mac_5_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_5_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			mac_5_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			mac_6_avalon_anti_slave_0_address                           : out std_logic_vector(12 downto 0);                    -- address
			mac_6_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			mac_6_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			mac_6_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_6_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			mac_6_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			mac_7_avalon_anti_slave_0_address                           : out std_logic_vector(12 downto 0);                    -- address
			mac_7_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			mac_7_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			mac_7_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_7_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			mac_7_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			mac_8_avalon_anti_slave_0_address                           : out std_logic_vector(12 downto 0);                    -- address
			mac_8_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			mac_8_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			mac_8_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_8_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			mac_8_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			mac_9_avalon_anti_slave_0_address                           : out std_logic_vector(12 downto 0);                    -- address
			mac_9_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			mac_9_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			mac_9_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			mac_9_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			mac_9_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			phy_0_avalon_anti_slave_0_address                           : out std_logic_vector(10 downto 0);                    -- address
			phy_0_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			phy_0_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			phy_0_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_0_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			phy_0_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			phy_1_avalon_anti_slave_0_address                           : out std_logic_vector(10 downto 0);                    -- address
			phy_1_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			phy_1_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			phy_1_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_1_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			phy_1_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			phy_10_avalon_anti_slave_0_address                          : out std_logic_vector(10 downto 0);                    -- address
			phy_10_avalon_anti_slave_0_write                            : out std_logic;                                        -- write
			phy_10_avalon_anti_slave_0_read                             : out std_logic;                                        -- read
			phy_10_avalon_anti_slave_0_readdata                         : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_10_avalon_anti_slave_0_writedata                        : out std_logic_vector(31 downto 0);                    -- writedata
			phy_10_avalon_anti_slave_0_waitrequest                      : in  std_logic                     := 'X';             -- waitrequest
			phy_11_avalon_anti_slave_0_address                          : out std_logic_vector(10 downto 0);                    -- address
			phy_11_avalon_anti_slave_0_write                            : out std_logic;                                        -- write
			phy_11_avalon_anti_slave_0_read                             : out std_logic;                                        -- read
			phy_11_avalon_anti_slave_0_readdata                         : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_11_avalon_anti_slave_0_writedata                        : out std_logic_vector(31 downto 0);                    -- writedata
			phy_11_avalon_anti_slave_0_waitrequest                      : in  std_logic                     := 'X';             -- waitrequest
			phy_2_avalon_anti_slave_0_address                           : out std_logic_vector(10 downto 0);                    -- address
			phy_2_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			phy_2_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			phy_2_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_2_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			phy_2_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			phy_3_avalon_anti_slave_0_address                           : out std_logic_vector(10 downto 0);                    -- address
			phy_3_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			phy_3_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			phy_3_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_3_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			phy_3_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			phy_4_avalon_anti_slave_0_address                           : out std_logic_vector(10 downto 0);                    -- address
			phy_4_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			phy_4_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			phy_4_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_4_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			phy_4_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			phy_5_avalon_anti_slave_0_address                           : out std_logic_vector(10 downto 0);                    -- address
			phy_5_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			phy_5_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			phy_5_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_5_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			phy_5_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			phy_6_avalon_anti_slave_0_address                           : out std_logic_vector(10 downto 0);                    -- address
			phy_6_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			phy_6_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			phy_6_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_6_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			phy_6_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			phy_7_avalon_anti_slave_0_address                           : out std_logic_vector(10 downto 0);                    -- address
			phy_7_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			phy_7_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			phy_7_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_7_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			phy_7_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			phy_8_avalon_anti_slave_0_address                           : out std_logic_vector(10 downto 0);                    -- address
			phy_8_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			phy_8_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			phy_8_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_8_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			phy_8_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			phy_9_avalon_anti_slave_0_address                           : out std_logic_vector(10 downto 0);                    -- address
			phy_9_avalon_anti_slave_0_write                             : out std_logic;                                        -- write
			phy_9_avalon_anti_slave_0_read                              : out std_logic;                                        -- read
			phy_9_avalon_anti_slave_0_readdata                          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			phy_9_avalon_anti_slave_0_writedata                         : out std_logic_vector(31 downto 0);                    -- writedata
			phy_9_avalon_anti_slave_0_waitrequest                       : in  std_logic                     := 'X';             -- waitrequest
			rx_sc_fifo_0_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_0_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			rx_sc_fifo_0_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			rx_sc_fifo_0_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_0_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			rx_sc_fifo_1_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_1_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			rx_sc_fifo_1_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			rx_sc_fifo_1_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_1_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			rx_sc_fifo_10_avalon_anti_slave_0_address                   : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_10_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			rx_sc_fifo_10_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			rx_sc_fifo_10_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_10_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			rx_sc_fifo_11_avalon_anti_slave_0_address                   : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_11_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			rx_sc_fifo_11_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			rx_sc_fifo_11_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_11_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			rx_sc_fifo_2_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_2_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			rx_sc_fifo_2_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			rx_sc_fifo_2_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_2_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			rx_sc_fifo_3_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_3_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			rx_sc_fifo_3_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			rx_sc_fifo_3_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_3_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			rx_sc_fifo_4_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_4_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			rx_sc_fifo_4_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			rx_sc_fifo_4_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_4_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			rx_sc_fifo_5_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_5_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			rx_sc_fifo_5_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			rx_sc_fifo_5_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_5_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			rx_sc_fifo_6_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_6_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			rx_sc_fifo_6_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			rx_sc_fifo_6_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_6_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			rx_sc_fifo_7_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_7_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			rx_sc_fifo_7_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			rx_sc_fifo_7_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_7_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			rx_sc_fifo_8_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_8_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			rx_sc_fifo_8_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			rx_sc_fifo_8_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_8_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			rx_sc_fifo_9_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			rx_sc_fifo_9_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			rx_sc_fifo_9_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			rx_sc_fifo_9_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			rx_sc_fifo_9_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			rx_xcvr_clk_clk                                             : in  std_logic                     := 'X';             -- clk
			sync_rx_rst_reset_n                                         : in  std_logic                     := 'X';             -- reset_n
			tx_sc_fifo_0_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_0_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			tx_sc_fifo_0_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			tx_sc_fifo_0_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_0_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			tx_sc_fifo_1_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_1_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			tx_sc_fifo_1_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			tx_sc_fifo_1_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_1_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			tx_sc_fifo_10_avalon_anti_slave_0_address                   : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_10_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			tx_sc_fifo_10_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			tx_sc_fifo_10_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_10_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			tx_sc_fifo_11_avalon_anti_slave_0_address                   : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_11_avalon_anti_slave_0_write                     : out std_logic;                                        -- write
			tx_sc_fifo_11_avalon_anti_slave_0_read                      : out std_logic;                                        -- read
			tx_sc_fifo_11_avalon_anti_slave_0_readdata                  : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_11_avalon_anti_slave_0_writedata                 : out std_logic_vector(31 downto 0);                    -- writedata
			tx_sc_fifo_2_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_2_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			tx_sc_fifo_2_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			tx_sc_fifo_2_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_2_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			tx_sc_fifo_3_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_3_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			tx_sc_fifo_3_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			tx_sc_fifo_3_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_3_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			tx_sc_fifo_4_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_4_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			tx_sc_fifo_4_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			tx_sc_fifo_4_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_4_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			tx_sc_fifo_5_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_5_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			tx_sc_fifo_5_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			tx_sc_fifo_5_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_5_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			tx_sc_fifo_6_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_6_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			tx_sc_fifo_6_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			tx_sc_fifo_6_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_6_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			tx_sc_fifo_7_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_7_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			tx_sc_fifo_7_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			tx_sc_fifo_7_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_7_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			tx_sc_fifo_8_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_8_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			tx_sc_fifo_8_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			tx_sc_fifo_8_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_8_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			tx_sc_fifo_9_avalon_anti_slave_0_address                    : out std_logic_vector(2 downto 0);                     -- address
			tx_sc_fifo_9_avalon_anti_slave_0_write                      : out std_logic;                                        -- write
			tx_sc_fifo_9_avalon_anti_slave_0_read                       : out std_logic;                                        -- read
			tx_sc_fifo_9_avalon_anti_slave_0_readdata                   : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			tx_sc_fifo_9_avalon_anti_slave_0_writedata                  : out std_logic_vector(31 downto 0);                    -- writedata
			tx_xcvr_clk_clk                                             : in  std_logic                     := 'X';             -- clk
			sync_tx_rst_reset_n                                         : in  std_logic                     := 'X';             -- reset_n
			tx_xcvr_half_clk_clk                                        : in  std_logic                     := 'X';             -- clk
			sync_tx_half_rst_reset_n                                    : in  std_logic                     := 'X'              -- reset_n
		);
	end component address_decode;

	u0 : component address_decode
		port map (
			clk_csr_clk                                                 => CONNECTED_TO_clk_csr_clk,                                                 --                                         clk_csr.clk
			csr_reset_n                                                 => CONNECTED_TO_csr_reset_n,                                                 --                                             csr.reset_n
			eth_gen_mon_0_avalon_anti_slave_0_address                   => CONNECTED_TO_eth_gen_mon_0_avalon_anti_slave_0_address,                   --               eth_gen_mon_0_avalon_anti_slave_0.address
			eth_gen_mon_0_avalon_anti_slave_0_write                     => CONNECTED_TO_eth_gen_mon_0_avalon_anti_slave_0_write,                     --                                                .write
			eth_gen_mon_0_avalon_anti_slave_0_read                      => CONNECTED_TO_eth_gen_mon_0_avalon_anti_slave_0_read,                      --                                                .read
			eth_gen_mon_0_avalon_anti_slave_0_readdata                  => CONNECTED_TO_eth_gen_mon_0_avalon_anti_slave_0_readdata,                  --                                                .readdata
			eth_gen_mon_0_avalon_anti_slave_0_writedata                 => CONNECTED_TO_eth_gen_mon_0_avalon_anti_slave_0_writedata,                 --                                                .writedata
			eth_gen_mon_0_avalon_anti_slave_0_waitrequest               => CONNECTED_TO_eth_gen_mon_0_avalon_anti_slave_0_waitrequest,               --                                                .waitrequest
			eth_gen_mon_1_avalon_anti_slave_0_address                   => CONNECTED_TO_eth_gen_mon_1_avalon_anti_slave_0_address,                   --               eth_gen_mon_1_avalon_anti_slave_0.address
			eth_gen_mon_1_avalon_anti_slave_0_write                     => CONNECTED_TO_eth_gen_mon_1_avalon_anti_slave_0_write,                     --                                                .write
			eth_gen_mon_1_avalon_anti_slave_0_read                      => CONNECTED_TO_eth_gen_mon_1_avalon_anti_slave_0_read,                      --                                                .read
			eth_gen_mon_1_avalon_anti_slave_0_readdata                  => CONNECTED_TO_eth_gen_mon_1_avalon_anti_slave_0_readdata,                  --                                                .readdata
			eth_gen_mon_1_avalon_anti_slave_0_writedata                 => CONNECTED_TO_eth_gen_mon_1_avalon_anti_slave_0_writedata,                 --                                                .writedata
			eth_gen_mon_1_avalon_anti_slave_0_waitrequest               => CONNECTED_TO_eth_gen_mon_1_avalon_anti_slave_0_waitrequest,               --                                                .waitrequest
			eth_gen_mon_10_avalon_anti_slave_0_address                  => CONNECTED_TO_eth_gen_mon_10_avalon_anti_slave_0_address,                  --              eth_gen_mon_10_avalon_anti_slave_0.address
			eth_gen_mon_10_avalon_anti_slave_0_write                    => CONNECTED_TO_eth_gen_mon_10_avalon_anti_slave_0_write,                    --                                                .write
			eth_gen_mon_10_avalon_anti_slave_0_read                     => CONNECTED_TO_eth_gen_mon_10_avalon_anti_slave_0_read,                     --                                                .read
			eth_gen_mon_10_avalon_anti_slave_0_readdata                 => CONNECTED_TO_eth_gen_mon_10_avalon_anti_slave_0_readdata,                 --                                                .readdata
			eth_gen_mon_10_avalon_anti_slave_0_writedata                => CONNECTED_TO_eth_gen_mon_10_avalon_anti_slave_0_writedata,                --                                                .writedata
			eth_gen_mon_10_avalon_anti_slave_0_waitrequest              => CONNECTED_TO_eth_gen_mon_10_avalon_anti_slave_0_waitrequest,              --                                                .waitrequest
			eth_gen_mon_11_avalon_anti_slave_0_address                  => CONNECTED_TO_eth_gen_mon_11_avalon_anti_slave_0_address,                  --              eth_gen_mon_11_avalon_anti_slave_0.address
			eth_gen_mon_11_avalon_anti_slave_0_write                    => CONNECTED_TO_eth_gen_mon_11_avalon_anti_slave_0_write,                    --                                                .write
			eth_gen_mon_11_avalon_anti_slave_0_read                     => CONNECTED_TO_eth_gen_mon_11_avalon_anti_slave_0_read,                     --                                                .read
			eth_gen_mon_11_avalon_anti_slave_0_readdata                 => CONNECTED_TO_eth_gen_mon_11_avalon_anti_slave_0_readdata,                 --                                                .readdata
			eth_gen_mon_11_avalon_anti_slave_0_writedata                => CONNECTED_TO_eth_gen_mon_11_avalon_anti_slave_0_writedata,                --                                                .writedata
			eth_gen_mon_11_avalon_anti_slave_0_waitrequest              => CONNECTED_TO_eth_gen_mon_11_avalon_anti_slave_0_waitrequest,              --                                                .waitrequest
			eth_gen_mon_2_avalon_anti_slave_0_address                   => CONNECTED_TO_eth_gen_mon_2_avalon_anti_slave_0_address,                   --               eth_gen_mon_2_avalon_anti_slave_0.address
			eth_gen_mon_2_avalon_anti_slave_0_write                     => CONNECTED_TO_eth_gen_mon_2_avalon_anti_slave_0_write,                     --                                                .write
			eth_gen_mon_2_avalon_anti_slave_0_read                      => CONNECTED_TO_eth_gen_mon_2_avalon_anti_slave_0_read,                      --                                                .read
			eth_gen_mon_2_avalon_anti_slave_0_readdata                  => CONNECTED_TO_eth_gen_mon_2_avalon_anti_slave_0_readdata,                  --                                                .readdata
			eth_gen_mon_2_avalon_anti_slave_0_writedata                 => CONNECTED_TO_eth_gen_mon_2_avalon_anti_slave_0_writedata,                 --                                                .writedata
			eth_gen_mon_2_avalon_anti_slave_0_waitrequest               => CONNECTED_TO_eth_gen_mon_2_avalon_anti_slave_0_waitrequest,               --                                                .waitrequest
			eth_gen_mon_3_avalon_anti_slave_0_address                   => CONNECTED_TO_eth_gen_mon_3_avalon_anti_slave_0_address,                   --               eth_gen_mon_3_avalon_anti_slave_0.address
			eth_gen_mon_3_avalon_anti_slave_0_write                     => CONNECTED_TO_eth_gen_mon_3_avalon_anti_slave_0_write,                     --                                                .write
			eth_gen_mon_3_avalon_anti_slave_0_read                      => CONNECTED_TO_eth_gen_mon_3_avalon_anti_slave_0_read,                      --                                                .read
			eth_gen_mon_3_avalon_anti_slave_0_readdata                  => CONNECTED_TO_eth_gen_mon_3_avalon_anti_slave_0_readdata,                  --                                                .readdata
			eth_gen_mon_3_avalon_anti_slave_0_writedata                 => CONNECTED_TO_eth_gen_mon_3_avalon_anti_slave_0_writedata,                 --                                                .writedata
			eth_gen_mon_3_avalon_anti_slave_0_waitrequest               => CONNECTED_TO_eth_gen_mon_3_avalon_anti_slave_0_waitrequest,               --                                                .waitrequest
			eth_gen_mon_4_avalon_anti_slave_0_address                   => CONNECTED_TO_eth_gen_mon_4_avalon_anti_slave_0_address,                   --               eth_gen_mon_4_avalon_anti_slave_0.address
			eth_gen_mon_4_avalon_anti_slave_0_write                     => CONNECTED_TO_eth_gen_mon_4_avalon_anti_slave_0_write,                     --                                                .write
			eth_gen_mon_4_avalon_anti_slave_0_read                      => CONNECTED_TO_eth_gen_mon_4_avalon_anti_slave_0_read,                      --                                                .read
			eth_gen_mon_4_avalon_anti_slave_0_readdata                  => CONNECTED_TO_eth_gen_mon_4_avalon_anti_slave_0_readdata,                  --                                                .readdata
			eth_gen_mon_4_avalon_anti_slave_0_writedata                 => CONNECTED_TO_eth_gen_mon_4_avalon_anti_slave_0_writedata,                 --                                                .writedata
			eth_gen_mon_4_avalon_anti_slave_0_waitrequest               => CONNECTED_TO_eth_gen_mon_4_avalon_anti_slave_0_waitrequest,               --                                                .waitrequest
			eth_gen_mon_5_avalon_anti_slave_0_address                   => CONNECTED_TO_eth_gen_mon_5_avalon_anti_slave_0_address,                   --               eth_gen_mon_5_avalon_anti_slave_0.address
			eth_gen_mon_5_avalon_anti_slave_0_write                     => CONNECTED_TO_eth_gen_mon_5_avalon_anti_slave_0_write,                     --                                                .write
			eth_gen_mon_5_avalon_anti_slave_0_read                      => CONNECTED_TO_eth_gen_mon_5_avalon_anti_slave_0_read,                      --                                                .read
			eth_gen_mon_5_avalon_anti_slave_0_readdata                  => CONNECTED_TO_eth_gen_mon_5_avalon_anti_slave_0_readdata,                  --                                                .readdata
			eth_gen_mon_5_avalon_anti_slave_0_writedata                 => CONNECTED_TO_eth_gen_mon_5_avalon_anti_slave_0_writedata,                 --                                                .writedata
			eth_gen_mon_5_avalon_anti_slave_0_waitrequest               => CONNECTED_TO_eth_gen_mon_5_avalon_anti_slave_0_waitrequest,               --                                                .waitrequest
			eth_gen_mon_6_avalon_anti_slave_0_address                   => CONNECTED_TO_eth_gen_mon_6_avalon_anti_slave_0_address,                   --               eth_gen_mon_6_avalon_anti_slave_0.address
			eth_gen_mon_6_avalon_anti_slave_0_write                     => CONNECTED_TO_eth_gen_mon_6_avalon_anti_slave_0_write,                     --                                                .write
			eth_gen_mon_6_avalon_anti_slave_0_read                      => CONNECTED_TO_eth_gen_mon_6_avalon_anti_slave_0_read,                      --                                                .read
			eth_gen_mon_6_avalon_anti_slave_0_readdata                  => CONNECTED_TO_eth_gen_mon_6_avalon_anti_slave_0_readdata,                  --                                                .readdata
			eth_gen_mon_6_avalon_anti_slave_0_writedata                 => CONNECTED_TO_eth_gen_mon_6_avalon_anti_slave_0_writedata,                 --                                                .writedata
			eth_gen_mon_6_avalon_anti_slave_0_waitrequest               => CONNECTED_TO_eth_gen_mon_6_avalon_anti_slave_0_waitrequest,               --                                                .waitrequest
			eth_gen_mon_7_avalon_anti_slave_0_address                   => CONNECTED_TO_eth_gen_mon_7_avalon_anti_slave_0_address,                   --               eth_gen_mon_7_avalon_anti_slave_0.address
			eth_gen_mon_7_avalon_anti_slave_0_write                     => CONNECTED_TO_eth_gen_mon_7_avalon_anti_slave_0_write,                     --                                                .write
			eth_gen_mon_7_avalon_anti_slave_0_read                      => CONNECTED_TO_eth_gen_mon_7_avalon_anti_slave_0_read,                      --                                                .read
			eth_gen_mon_7_avalon_anti_slave_0_readdata                  => CONNECTED_TO_eth_gen_mon_7_avalon_anti_slave_0_readdata,                  --                                                .readdata
			eth_gen_mon_7_avalon_anti_slave_0_writedata                 => CONNECTED_TO_eth_gen_mon_7_avalon_anti_slave_0_writedata,                 --                                                .writedata
			eth_gen_mon_7_avalon_anti_slave_0_waitrequest               => CONNECTED_TO_eth_gen_mon_7_avalon_anti_slave_0_waitrequest,               --                                                .waitrequest
			eth_gen_mon_8_avalon_anti_slave_0_address                   => CONNECTED_TO_eth_gen_mon_8_avalon_anti_slave_0_address,                   --               eth_gen_mon_8_avalon_anti_slave_0.address
			eth_gen_mon_8_avalon_anti_slave_0_write                     => CONNECTED_TO_eth_gen_mon_8_avalon_anti_slave_0_write,                     --                                                .write
			eth_gen_mon_8_avalon_anti_slave_0_read                      => CONNECTED_TO_eth_gen_mon_8_avalon_anti_slave_0_read,                      --                                                .read
			eth_gen_mon_8_avalon_anti_slave_0_readdata                  => CONNECTED_TO_eth_gen_mon_8_avalon_anti_slave_0_readdata,                  --                                                .readdata
			eth_gen_mon_8_avalon_anti_slave_0_writedata                 => CONNECTED_TO_eth_gen_mon_8_avalon_anti_slave_0_writedata,                 --                                                .writedata
			eth_gen_mon_8_avalon_anti_slave_0_waitrequest               => CONNECTED_TO_eth_gen_mon_8_avalon_anti_slave_0_waitrequest,               --                                                .waitrequest
			eth_gen_mon_9_avalon_anti_slave_0_address                   => CONNECTED_TO_eth_gen_mon_9_avalon_anti_slave_0_address,                   --               eth_gen_mon_9_avalon_anti_slave_0.address
			eth_gen_mon_9_avalon_anti_slave_0_write                     => CONNECTED_TO_eth_gen_mon_9_avalon_anti_slave_0_write,                     --                                                .write
			eth_gen_mon_9_avalon_anti_slave_0_read                      => CONNECTED_TO_eth_gen_mon_9_avalon_anti_slave_0_read,                      --                                                .read
			eth_gen_mon_9_avalon_anti_slave_0_readdata                  => CONNECTED_TO_eth_gen_mon_9_avalon_anti_slave_0_readdata,                  --                                                .readdata
			eth_gen_mon_9_avalon_anti_slave_0_writedata                 => CONNECTED_TO_eth_gen_mon_9_avalon_anti_slave_0_writedata,                 --                                                .writedata
			eth_gen_mon_9_avalon_anti_slave_0_waitrequest               => CONNECTED_TO_eth_gen_mon_9_avalon_anti_slave_0_waitrequest,               --                                                .waitrequest
			merlin_master_translator_0_avalon_anti_master_0_address     => CONNECTED_TO_merlin_master_translator_0_avalon_anti_master_0_address,     -- merlin_master_translator_0_avalon_anti_master_0.address
			merlin_master_translator_0_avalon_anti_master_0_waitrequest => CONNECTED_TO_merlin_master_translator_0_avalon_anti_master_0_waitrequest, --                                                .waitrequest
			merlin_master_translator_0_avalon_anti_master_0_read        => CONNECTED_TO_merlin_master_translator_0_avalon_anti_master_0_read,        --                                                .read
			merlin_master_translator_0_avalon_anti_master_0_readdata    => CONNECTED_TO_merlin_master_translator_0_avalon_anti_master_0_readdata,    --                                                .readdata
			merlin_master_translator_0_avalon_anti_master_0_write       => CONNECTED_TO_merlin_master_translator_0_avalon_anti_master_0_write,       --                                                .write
			merlin_master_translator_0_avalon_anti_master_0_writedata   => CONNECTED_TO_merlin_master_translator_0_avalon_anti_master_0_writedata,   --                                                .writedata
			mac_0_avalon_anti_slave_0_address                           => CONNECTED_TO_mac_0_avalon_anti_slave_0_address,                           --                       mac_0_avalon_anti_slave_0.address
			mac_0_avalon_anti_slave_0_write                             => CONNECTED_TO_mac_0_avalon_anti_slave_0_write,                             --                                                .write
			mac_0_avalon_anti_slave_0_read                              => CONNECTED_TO_mac_0_avalon_anti_slave_0_read,                              --                                                .read
			mac_0_avalon_anti_slave_0_readdata                          => CONNECTED_TO_mac_0_avalon_anti_slave_0_readdata,                          --                                                .readdata
			mac_0_avalon_anti_slave_0_writedata                         => CONNECTED_TO_mac_0_avalon_anti_slave_0_writedata,                         --                                                .writedata
			mac_0_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_mac_0_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			mac_1_avalon_anti_slave_0_address                           => CONNECTED_TO_mac_1_avalon_anti_slave_0_address,                           --                       mac_1_avalon_anti_slave_0.address
			mac_1_avalon_anti_slave_0_write                             => CONNECTED_TO_mac_1_avalon_anti_slave_0_write,                             --                                                .write
			mac_1_avalon_anti_slave_0_read                              => CONNECTED_TO_mac_1_avalon_anti_slave_0_read,                              --                                                .read
			mac_1_avalon_anti_slave_0_readdata                          => CONNECTED_TO_mac_1_avalon_anti_slave_0_readdata,                          --                                                .readdata
			mac_1_avalon_anti_slave_0_writedata                         => CONNECTED_TO_mac_1_avalon_anti_slave_0_writedata,                         --                                                .writedata
			mac_1_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_mac_1_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			mac_10_avalon_anti_slave_0_address                          => CONNECTED_TO_mac_10_avalon_anti_slave_0_address,                          --                      mac_10_avalon_anti_slave_0.address
			mac_10_avalon_anti_slave_0_write                            => CONNECTED_TO_mac_10_avalon_anti_slave_0_write,                            --                                                .write
			mac_10_avalon_anti_slave_0_read                             => CONNECTED_TO_mac_10_avalon_anti_slave_0_read,                             --                                                .read
			mac_10_avalon_anti_slave_0_readdata                         => CONNECTED_TO_mac_10_avalon_anti_slave_0_readdata,                         --                                                .readdata
			mac_10_avalon_anti_slave_0_writedata                        => CONNECTED_TO_mac_10_avalon_anti_slave_0_writedata,                        --                                                .writedata
			mac_10_avalon_anti_slave_0_waitrequest                      => CONNECTED_TO_mac_10_avalon_anti_slave_0_waitrequest,                      --                                                .waitrequest
			mac_11_avalon_anti_slave_0_address                          => CONNECTED_TO_mac_11_avalon_anti_slave_0_address,                          --                      mac_11_avalon_anti_slave_0.address
			mac_11_avalon_anti_slave_0_write                            => CONNECTED_TO_mac_11_avalon_anti_slave_0_write,                            --                                                .write
			mac_11_avalon_anti_slave_0_read                             => CONNECTED_TO_mac_11_avalon_anti_slave_0_read,                             --                                                .read
			mac_11_avalon_anti_slave_0_readdata                         => CONNECTED_TO_mac_11_avalon_anti_slave_0_readdata,                         --                                                .readdata
			mac_11_avalon_anti_slave_0_writedata                        => CONNECTED_TO_mac_11_avalon_anti_slave_0_writedata,                        --                                                .writedata
			mac_11_avalon_anti_slave_0_waitrequest                      => CONNECTED_TO_mac_11_avalon_anti_slave_0_waitrequest,                      --                                                .waitrequest
			mac_2_avalon_anti_slave_0_address                           => CONNECTED_TO_mac_2_avalon_anti_slave_0_address,                           --                       mac_2_avalon_anti_slave_0.address
			mac_2_avalon_anti_slave_0_write                             => CONNECTED_TO_mac_2_avalon_anti_slave_0_write,                             --                                                .write
			mac_2_avalon_anti_slave_0_read                              => CONNECTED_TO_mac_2_avalon_anti_slave_0_read,                              --                                                .read
			mac_2_avalon_anti_slave_0_readdata                          => CONNECTED_TO_mac_2_avalon_anti_slave_0_readdata,                          --                                                .readdata
			mac_2_avalon_anti_slave_0_writedata                         => CONNECTED_TO_mac_2_avalon_anti_slave_0_writedata,                         --                                                .writedata
			mac_2_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_mac_2_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			mac_3_avalon_anti_slave_0_address                           => CONNECTED_TO_mac_3_avalon_anti_slave_0_address,                           --                       mac_3_avalon_anti_slave_0.address
			mac_3_avalon_anti_slave_0_write                             => CONNECTED_TO_mac_3_avalon_anti_slave_0_write,                             --                                                .write
			mac_3_avalon_anti_slave_0_read                              => CONNECTED_TO_mac_3_avalon_anti_slave_0_read,                              --                                                .read
			mac_3_avalon_anti_slave_0_readdata                          => CONNECTED_TO_mac_3_avalon_anti_slave_0_readdata,                          --                                                .readdata
			mac_3_avalon_anti_slave_0_writedata                         => CONNECTED_TO_mac_3_avalon_anti_slave_0_writedata,                         --                                                .writedata
			mac_3_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_mac_3_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			mac_4_avalon_anti_slave_0_address                           => CONNECTED_TO_mac_4_avalon_anti_slave_0_address,                           --                       mac_4_avalon_anti_slave_0.address
			mac_4_avalon_anti_slave_0_write                             => CONNECTED_TO_mac_4_avalon_anti_slave_0_write,                             --                                                .write
			mac_4_avalon_anti_slave_0_read                              => CONNECTED_TO_mac_4_avalon_anti_slave_0_read,                              --                                                .read
			mac_4_avalon_anti_slave_0_readdata                          => CONNECTED_TO_mac_4_avalon_anti_slave_0_readdata,                          --                                                .readdata
			mac_4_avalon_anti_slave_0_writedata                         => CONNECTED_TO_mac_4_avalon_anti_slave_0_writedata,                         --                                                .writedata
			mac_4_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_mac_4_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			mac_5_avalon_anti_slave_0_address                           => CONNECTED_TO_mac_5_avalon_anti_slave_0_address,                           --                       mac_5_avalon_anti_slave_0.address
			mac_5_avalon_anti_slave_0_write                             => CONNECTED_TO_mac_5_avalon_anti_slave_0_write,                             --                                                .write
			mac_5_avalon_anti_slave_0_read                              => CONNECTED_TO_mac_5_avalon_anti_slave_0_read,                              --                                                .read
			mac_5_avalon_anti_slave_0_readdata                          => CONNECTED_TO_mac_5_avalon_anti_slave_0_readdata,                          --                                                .readdata
			mac_5_avalon_anti_slave_0_writedata                         => CONNECTED_TO_mac_5_avalon_anti_slave_0_writedata,                         --                                                .writedata
			mac_5_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_mac_5_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			mac_6_avalon_anti_slave_0_address                           => CONNECTED_TO_mac_6_avalon_anti_slave_0_address,                           --                       mac_6_avalon_anti_slave_0.address
			mac_6_avalon_anti_slave_0_write                             => CONNECTED_TO_mac_6_avalon_anti_slave_0_write,                             --                                                .write
			mac_6_avalon_anti_slave_0_read                              => CONNECTED_TO_mac_6_avalon_anti_slave_0_read,                              --                                                .read
			mac_6_avalon_anti_slave_0_readdata                          => CONNECTED_TO_mac_6_avalon_anti_slave_0_readdata,                          --                                                .readdata
			mac_6_avalon_anti_slave_0_writedata                         => CONNECTED_TO_mac_6_avalon_anti_slave_0_writedata,                         --                                                .writedata
			mac_6_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_mac_6_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			mac_7_avalon_anti_slave_0_address                           => CONNECTED_TO_mac_7_avalon_anti_slave_0_address,                           --                       mac_7_avalon_anti_slave_0.address
			mac_7_avalon_anti_slave_0_write                             => CONNECTED_TO_mac_7_avalon_anti_slave_0_write,                             --                                                .write
			mac_7_avalon_anti_slave_0_read                              => CONNECTED_TO_mac_7_avalon_anti_slave_0_read,                              --                                                .read
			mac_7_avalon_anti_slave_0_readdata                          => CONNECTED_TO_mac_7_avalon_anti_slave_0_readdata,                          --                                                .readdata
			mac_7_avalon_anti_slave_0_writedata                         => CONNECTED_TO_mac_7_avalon_anti_slave_0_writedata,                         --                                                .writedata
			mac_7_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_mac_7_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			mac_8_avalon_anti_slave_0_address                           => CONNECTED_TO_mac_8_avalon_anti_slave_0_address,                           --                       mac_8_avalon_anti_slave_0.address
			mac_8_avalon_anti_slave_0_write                             => CONNECTED_TO_mac_8_avalon_anti_slave_0_write,                             --                                                .write
			mac_8_avalon_anti_slave_0_read                              => CONNECTED_TO_mac_8_avalon_anti_slave_0_read,                              --                                                .read
			mac_8_avalon_anti_slave_0_readdata                          => CONNECTED_TO_mac_8_avalon_anti_slave_0_readdata,                          --                                                .readdata
			mac_8_avalon_anti_slave_0_writedata                         => CONNECTED_TO_mac_8_avalon_anti_slave_0_writedata,                         --                                                .writedata
			mac_8_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_mac_8_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			mac_9_avalon_anti_slave_0_address                           => CONNECTED_TO_mac_9_avalon_anti_slave_0_address,                           --                       mac_9_avalon_anti_slave_0.address
			mac_9_avalon_anti_slave_0_write                             => CONNECTED_TO_mac_9_avalon_anti_slave_0_write,                             --                                                .write
			mac_9_avalon_anti_slave_0_read                              => CONNECTED_TO_mac_9_avalon_anti_slave_0_read,                              --                                                .read
			mac_9_avalon_anti_slave_0_readdata                          => CONNECTED_TO_mac_9_avalon_anti_slave_0_readdata,                          --                                                .readdata
			mac_9_avalon_anti_slave_0_writedata                         => CONNECTED_TO_mac_9_avalon_anti_slave_0_writedata,                         --                                                .writedata
			mac_9_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_mac_9_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			phy_0_avalon_anti_slave_0_address                           => CONNECTED_TO_phy_0_avalon_anti_slave_0_address,                           --                       phy_0_avalon_anti_slave_0.address
			phy_0_avalon_anti_slave_0_write                             => CONNECTED_TO_phy_0_avalon_anti_slave_0_write,                             --                                                .write
			phy_0_avalon_anti_slave_0_read                              => CONNECTED_TO_phy_0_avalon_anti_slave_0_read,                              --                                                .read
			phy_0_avalon_anti_slave_0_readdata                          => CONNECTED_TO_phy_0_avalon_anti_slave_0_readdata,                          --                                                .readdata
			phy_0_avalon_anti_slave_0_writedata                         => CONNECTED_TO_phy_0_avalon_anti_slave_0_writedata,                         --                                                .writedata
			phy_0_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_phy_0_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			phy_1_avalon_anti_slave_0_address                           => CONNECTED_TO_phy_1_avalon_anti_slave_0_address,                           --                       phy_1_avalon_anti_slave_0.address
			phy_1_avalon_anti_slave_0_write                             => CONNECTED_TO_phy_1_avalon_anti_slave_0_write,                             --                                                .write
			phy_1_avalon_anti_slave_0_read                              => CONNECTED_TO_phy_1_avalon_anti_slave_0_read,                              --                                                .read
			phy_1_avalon_anti_slave_0_readdata                          => CONNECTED_TO_phy_1_avalon_anti_slave_0_readdata,                          --                                                .readdata
			phy_1_avalon_anti_slave_0_writedata                         => CONNECTED_TO_phy_1_avalon_anti_slave_0_writedata,                         --                                                .writedata
			phy_1_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_phy_1_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			phy_10_avalon_anti_slave_0_address                          => CONNECTED_TO_phy_10_avalon_anti_slave_0_address,                          --                      phy_10_avalon_anti_slave_0.address
			phy_10_avalon_anti_slave_0_write                            => CONNECTED_TO_phy_10_avalon_anti_slave_0_write,                            --                                                .write
			phy_10_avalon_anti_slave_0_read                             => CONNECTED_TO_phy_10_avalon_anti_slave_0_read,                             --                                                .read
			phy_10_avalon_anti_slave_0_readdata                         => CONNECTED_TO_phy_10_avalon_anti_slave_0_readdata,                         --                                                .readdata
			phy_10_avalon_anti_slave_0_writedata                        => CONNECTED_TO_phy_10_avalon_anti_slave_0_writedata,                        --                                                .writedata
			phy_10_avalon_anti_slave_0_waitrequest                      => CONNECTED_TO_phy_10_avalon_anti_slave_0_waitrequest,                      --                                                .waitrequest
			phy_11_avalon_anti_slave_0_address                          => CONNECTED_TO_phy_11_avalon_anti_slave_0_address,                          --                      phy_11_avalon_anti_slave_0.address
			phy_11_avalon_anti_slave_0_write                            => CONNECTED_TO_phy_11_avalon_anti_slave_0_write,                            --                                                .write
			phy_11_avalon_anti_slave_0_read                             => CONNECTED_TO_phy_11_avalon_anti_slave_0_read,                             --                                                .read
			phy_11_avalon_anti_slave_0_readdata                         => CONNECTED_TO_phy_11_avalon_anti_slave_0_readdata,                         --                                                .readdata
			phy_11_avalon_anti_slave_0_writedata                        => CONNECTED_TO_phy_11_avalon_anti_slave_0_writedata,                        --                                                .writedata
			phy_11_avalon_anti_slave_0_waitrequest                      => CONNECTED_TO_phy_11_avalon_anti_slave_0_waitrequest,                      --                                                .waitrequest
			phy_2_avalon_anti_slave_0_address                           => CONNECTED_TO_phy_2_avalon_anti_slave_0_address,                           --                       phy_2_avalon_anti_slave_0.address
			phy_2_avalon_anti_slave_0_write                             => CONNECTED_TO_phy_2_avalon_anti_slave_0_write,                             --                                                .write
			phy_2_avalon_anti_slave_0_read                              => CONNECTED_TO_phy_2_avalon_anti_slave_0_read,                              --                                                .read
			phy_2_avalon_anti_slave_0_readdata                          => CONNECTED_TO_phy_2_avalon_anti_slave_0_readdata,                          --                                                .readdata
			phy_2_avalon_anti_slave_0_writedata                         => CONNECTED_TO_phy_2_avalon_anti_slave_0_writedata,                         --                                                .writedata
			phy_2_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_phy_2_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			phy_3_avalon_anti_slave_0_address                           => CONNECTED_TO_phy_3_avalon_anti_slave_0_address,                           --                       phy_3_avalon_anti_slave_0.address
			phy_3_avalon_anti_slave_0_write                             => CONNECTED_TO_phy_3_avalon_anti_slave_0_write,                             --                                                .write
			phy_3_avalon_anti_slave_0_read                              => CONNECTED_TO_phy_3_avalon_anti_slave_0_read,                              --                                                .read
			phy_3_avalon_anti_slave_0_readdata                          => CONNECTED_TO_phy_3_avalon_anti_slave_0_readdata,                          --                                                .readdata
			phy_3_avalon_anti_slave_0_writedata                         => CONNECTED_TO_phy_3_avalon_anti_slave_0_writedata,                         --                                                .writedata
			phy_3_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_phy_3_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			phy_4_avalon_anti_slave_0_address                           => CONNECTED_TO_phy_4_avalon_anti_slave_0_address,                           --                       phy_4_avalon_anti_slave_0.address
			phy_4_avalon_anti_slave_0_write                             => CONNECTED_TO_phy_4_avalon_anti_slave_0_write,                             --                                                .write
			phy_4_avalon_anti_slave_0_read                              => CONNECTED_TO_phy_4_avalon_anti_slave_0_read,                              --                                                .read
			phy_4_avalon_anti_slave_0_readdata                          => CONNECTED_TO_phy_4_avalon_anti_slave_0_readdata,                          --                                                .readdata
			phy_4_avalon_anti_slave_0_writedata                         => CONNECTED_TO_phy_4_avalon_anti_slave_0_writedata,                         --                                                .writedata
			phy_4_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_phy_4_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			phy_5_avalon_anti_slave_0_address                           => CONNECTED_TO_phy_5_avalon_anti_slave_0_address,                           --                       phy_5_avalon_anti_slave_0.address
			phy_5_avalon_anti_slave_0_write                             => CONNECTED_TO_phy_5_avalon_anti_slave_0_write,                             --                                                .write
			phy_5_avalon_anti_slave_0_read                              => CONNECTED_TO_phy_5_avalon_anti_slave_0_read,                              --                                                .read
			phy_5_avalon_anti_slave_0_readdata                          => CONNECTED_TO_phy_5_avalon_anti_slave_0_readdata,                          --                                                .readdata
			phy_5_avalon_anti_slave_0_writedata                         => CONNECTED_TO_phy_5_avalon_anti_slave_0_writedata,                         --                                                .writedata
			phy_5_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_phy_5_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			phy_6_avalon_anti_slave_0_address                           => CONNECTED_TO_phy_6_avalon_anti_slave_0_address,                           --                       phy_6_avalon_anti_slave_0.address
			phy_6_avalon_anti_slave_0_write                             => CONNECTED_TO_phy_6_avalon_anti_slave_0_write,                             --                                                .write
			phy_6_avalon_anti_slave_0_read                              => CONNECTED_TO_phy_6_avalon_anti_slave_0_read,                              --                                                .read
			phy_6_avalon_anti_slave_0_readdata                          => CONNECTED_TO_phy_6_avalon_anti_slave_0_readdata,                          --                                                .readdata
			phy_6_avalon_anti_slave_0_writedata                         => CONNECTED_TO_phy_6_avalon_anti_slave_0_writedata,                         --                                                .writedata
			phy_6_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_phy_6_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			phy_7_avalon_anti_slave_0_address                           => CONNECTED_TO_phy_7_avalon_anti_slave_0_address,                           --                       phy_7_avalon_anti_slave_0.address
			phy_7_avalon_anti_slave_0_write                             => CONNECTED_TO_phy_7_avalon_anti_slave_0_write,                             --                                                .write
			phy_7_avalon_anti_slave_0_read                              => CONNECTED_TO_phy_7_avalon_anti_slave_0_read,                              --                                                .read
			phy_7_avalon_anti_slave_0_readdata                          => CONNECTED_TO_phy_7_avalon_anti_slave_0_readdata,                          --                                                .readdata
			phy_7_avalon_anti_slave_0_writedata                         => CONNECTED_TO_phy_7_avalon_anti_slave_0_writedata,                         --                                                .writedata
			phy_7_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_phy_7_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			phy_8_avalon_anti_slave_0_address                           => CONNECTED_TO_phy_8_avalon_anti_slave_0_address,                           --                       phy_8_avalon_anti_slave_0.address
			phy_8_avalon_anti_slave_0_write                             => CONNECTED_TO_phy_8_avalon_anti_slave_0_write,                             --                                                .write
			phy_8_avalon_anti_slave_0_read                              => CONNECTED_TO_phy_8_avalon_anti_slave_0_read,                              --                                                .read
			phy_8_avalon_anti_slave_0_readdata                          => CONNECTED_TO_phy_8_avalon_anti_slave_0_readdata,                          --                                                .readdata
			phy_8_avalon_anti_slave_0_writedata                         => CONNECTED_TO_phy_8_avalon_anti_slave_0_writedata,                         --                                                .writedata
			phy_8_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_phy_8_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			phy_9_avalon_anti_slave_0_address                           => CONNECTED_TO_phy_9_avalon_anti_slave_0_address,                           --                       phy_9_avalon_anti_slave_0.address
			phy_9_avalon_anti_slave_0_write                             => CONNECTED_TO_phy_9_avalon_anti_slave_0_write,                             --                                                .write
			phy_9_avalon_anti_slave_0_read                              => CONNECTED_TO_phy_9_avalon_anti_slave_0_read,                              --                                                .read
			phy_9_avalon_anti_slave_0_readdata                          => CONNECTED_TO_phy_9_avalon_anti_slave_0_readdata,                          --                                                .readdata
			phy_9_avalon_anti_slave_0_writedata                         => CONNECTED_TO_phy_9_avalon_anti_slave_0_writedata,                         --                                                .writedata
			phy_9_avalon_anti_slave_0_waitrequest                       => CONNECTED_TO_phy_9_avalon_anti_slave_0_waitrequest,                       --                                                .waitrequest
			rx_sc_fifo_0_avalon_anti_slave_0_address                    => CONNECTED_TO_rx_sc_fifo_0_avalon_anti_slave_0_address,                    --                rx_sc_fifo_0_avalon_anti_slave_0.address
			rx_sc_fifo_0_avalon_anti_slave_0_write                      => CONNECTED_TO_rx_sc_fifo_0_avalon_anti_slave_0_write,                      --                                                .write
			rx_sc_fifo_0_avalon_anti_slave_0_read                       => CONNECTED_TO_rx_sc_fifo_0_avalon_anti_slave_0_read,                       --                                                .read
			rx_sc_fifo_0_avalon_anti_slave_0_readdata                   => CONNECTED_TO_rx_sc_fifo_0_avalon_anti_slave_0_readdata,                   --                                                .readdata
			rx_sc_fifo_0_avalon_anti_slave_0_writedata                  => CONNECTED_TO_rx_sc_fifo_0_avalon_anti_slave_0_writedata,                  --                                                .writedata
			rx_sc_fifo_1_avalon_anti_slave_0_address                    => CONNECTED_TO_rx_sc_fifo_1_avalon_anti_slave_0_address,                    --                rx_sc_fifo_1_avalon_anti_slave_0.address
			rx_sc_fifo_1_avalon_anti_slave_0_write                      => CONNECTED_TO_rx_sc_fifo_1_avalon_anti_slave_0_write,                      --                                                .write
			rx_sc_fifo_1_avalon_anti_slave_0_read                       => CONNECTED_TO_rx_sc_fifo_1_avalon_anti_slave_0_read,                       --                                                .read
			rx_sc_fifo_1_avalon_anti_slave_0_readdata                   => CONNECTED_TO_rx_sc_fifo_1_avalon_anti_slave_0_readdata,                   --                                                .readdata
			rx_sc_fifo_1_avalon_anti_slave_0_writedata                  => CONNECTED_TO_rx_sc_fifo_1_avalon_anti_slave_0_writedata,                  --                                                .writedata
			rx_sc_fifo_10_avalon_anti_slave_0_address                   => CONNECTED_TO_rx_sc_fifo_10_avalon_anti_slave_0_address,                   --               rx_sc_fifo_10_avalon_anti_slave_0.address
			rx_sc_fifo_10_avalon_anti_slave_0_write                     => CONNECTED_TO_rx_sc_fifo_10_avalon_anti_slave_0_write,                     --                                                .write
			rx_sc_fifo_10_avalon_anti_slave_0_read                      => CONNECTED_TO_rx_sc_fifo_10_avalon_anti_slave_0_read,                      --                                                .read
			rx_sc_fifo_10_avalon_anti_slave_0_readdata                  => CONNECTED_TO_rx_sc_fifo_10_avalon_anti_slave_0_readdata,                  --                                                .readdata
			rx_sc_fifo_10_avalon_anti_slave_0_writedata                 => CONNECTED_TO_rx_sc_fifo_10_avalon_anti_slave_0_writedata,                 --                                                .writedata
			rx_sc_fifo_11_avalon_anti_slave_0_address                   => CONNECTED_TO_rx_sc_fifo_11_avalon_anti_slave_0_address,                   --               rx_sc_fifo_11_avalon_anti_slave_0.address
			rx_sc_fifo_11_avalon_anti_slave_0_write                     => CONNECTED_TO_rx_sc_fifo_11_avalon_anti_slave_0_write,                     --                                                .write
			rx_sc_fifo_11_avalon_anti_slave_0_read                      => CONNECTED_TO_rx_sc_fifo_11_avalon_anti_slave_0_read,                      --                                                .read
			rx_sc_fifo_11_avalon_anti_slave_0_readdata                  => CONNECTED_TO_rx_sc_fifo_11_avalon_anti_slave_0_readdata,                  --                                                .readdata
			rx_sc_fifo_11_avalon_anti_slave_0_writedata                 => CONNECTED_TO_rx_sc_fifo_11_avalon_anti_slave_0_writedata,                 --                                                .writedata
			rx_sc_fifo_2_avalon_anti_slave_0_address                    => CONNECTED_TO_rx_sc_fifo_2_avalon_anti_slave_0_address,                    --                rx_sc_fifo_2_avalon_anti_slave_0.address
			rx_sc_fifo_2_avalon_anti_slave_0_write                      => CONNECTED_TO_rx_sc_fifo_2_avalon_anti_slave_0_write,                      --                                                .write
			rx_sc_fifo_2_avalon_anti_slave_0_read                       => CONNECTED_TO_rx_sc_fifo_2_avalon_anti_slave_0_read,                       --                                                .read
			rx_sc_fifo_2_avalon_anti_slave_0_readdata                   => CONNECTED_TO_rx_sc_fifo_2_avalon_anti_slave_0_readdata,                   --                                                .readdata
			rx_sc_fifo_2_avalon_anti_slave_0_writedata                  => CONNECTED_TO_rx_sc_fifo_2_avalon_anti_slave_0_writedata,                  --                                                .writedata
			rx_sc_fifo_3_avalon_anti_slave_0_address                    => CONNECTED_TO_rx_sc_fifo_3_avalon_anti_slave_0_address,                    --                rx_sc_fifo_3_avalon_anti_slave_0.address
			rx_sc_fifo_3_avalon_anti_slave_0_write                      => CONNECTED_TO_rx_sc_fifo_3_avalon_anti_slave_0_write,                      --                                                .write
			rx_sc_fifo_3_avalon_anti_slave_0_read                       => CONNECTED_TO_rx_sc_fifo_3_avalon_anti_slave_0_read,                       --                                                .read
			rx_sc_fifo_3_avalon_anti_slave_0_readdata                   => CONNECTED_TO_rx_sc_fifo_3_avalon_anti_slave_0_readdata,                   --                                                .readdata
			rx_sc_fifo_3_avalon_anti_slave_0_writedata                  => CONNECTED_TO_rx_sc_fifo_3_avalon_anti_slave_0_writedata,                  --                                                .writedata
			rx_sc_fifo_4_avalon_anti_slave_0_address                    => CONNECTED_TO_rx_sc_fifo_4_avalon_anti_slave_0_address,                    --                rx_sc_fifo_4_avalon_anti_slave_0.address
			rx_sc_fifo_4_avalon_anti_slave_0_write                      => CONNECTED_TO_rx_sc_fifo_4_avalon_anti_slave_0_write,                      --                                                .write
			rx_sc_fifo_4_avalon_anti_slave_0_read                       => CONNECTED_TO_rx_sc_fifo_4_avalon_anti_slave_0_read,                       --                                                .read
			rx_sc_fifo_4_avalon_anti_slave_0_readdata                   => CONNECTED_TO_rx_sc_fifo_4_avalon_anti_slave_0_readdata,                   --                                                .readdata
			rx_sc_fifo_4_avalon_anti_slave_0_writedata                  => CONNECTED_TO_rx_sc_fifo_4_avalon_anti_slave_0_writedata,                  --                                                .writedata
			rx_sc_fifo_5_avalon_anti_slave_0_address                    => CONNECTED_TO_rx_sc_fifo_5_avalon_anti_slave_0_address,                    --                rx_sc_fifo_5_avalon_anti_slave_0.address
			rx_sc_fifo_5_avalon_anti_slave_0_write                      => CONNECTED_TO_rx_sc_fifo_5_avalon_anti_slave_0_write,                      --                                                .write
			rx_sc_fifo_5_avalon_anti_slave_0_read                       => CONNECTED_TO_rx_sc_fifo_5_avalon_anti_slave_0_read,                       --                                                .read
			rx_sc_fifo_5_avalon_anti_slave_0_readdata                   => CONNECTED_TO_rx_sc_fifo_5_avalon_anti_slave_0_readdata,                   --                                                .readdata
			rx_sc_fifo_5_avalon_anti_slave_0_writedata                  => CONNECTED_TO_rx_sc_fifo_5_avalon_anti_slave_0_writedata,                  --                                                .writedata
			rx_sc_fifo_6_avalon_anti_slave_0_address                    => CONNECTED_TO_rx_sc_fifo_6_avalon_anti_slave_0_address,                    --                rx_sc_fifo_6_avalon_anti_slave_0.address
			rx_sc_fifo_6_avalon_anti_slave_0_write                      => CONNECTED_TO_rx_sc_fifo_6_avalon_anti_slave_0_write,                      --                                                .write
			rx_sc_fifo_6_avalon_anti_slave_0_read                       => CONNECTED_TO_rx_sc_fifo_6_avalon_anti_slave_0_read,                       --                                                .read
			rx_sc_fifo_6_avalon_anti_slave_0_readdata                   => CONNECTED_TO_rx_sc_fifo_6_avalon_anti_slave_0_readdata,                   --                                                .readdata
			rx_sc_fifo_6_avalon_anti_slave_0_writedata                  => CONNECTED_TO_rx_sc_fifo_6_avalon_anti_slave_0_writedata,                  --                                                .writedata
			rx_sc_fifo_7_avalon_anti_slave_0_address                    => CONNECTED_TO_rx_sc_fifo_7_avalon_anti_slave_0_address,                    --                rx_sc_fifo_7_avalon_anti_slave_0.address
			rx_sc_fifo_7_avalon_anti_slave_0_write                      => CONNECTED_TO_rx_sc_fifo_7_avalon_anti_slave_0_write,                      --                                                .write
			rx_sc_fifo_7_avalon_anti_slave_0_read                       => CONNECTED_TO_rx_sc_fifo_7_avalon_anti_slave_0_read,                       --                                                .read
			rx_sc_fifo_7_avalon_anti_slave_0_readdata                   => CONNECTED_TO_rx_sc_fifo_7_avalon_anti_slave_0_readdata,                   --                                                .readdata
			rx_sc_fifo_7_avalon_anti_slave_0_writedata                  => CONNECTED_TO_rx_sc_fifo_7_avalon_anti_slave_0_writedata,                  --                                                .writedata
			rx_sc_fifo_8_avalon_anti_slave_0_address                    => CONNECTED_TO_rx_sc_fifo_8_avalon_anti_slave_0_address,                    --                rx_sc_fifo_8_avalon_anti_slave_0.address
			rx_sc_fifo_8_avalon_anti_slave_0_write                      => CONNECTED_TO_rx_sc_fifo_8_avalon_anti_slave_0_write,                      --                                                .write
			rx_sc_fifo_8_avalon_anti_slave_0_read                       => CONNECTED_TO_rx_sc_fifo_8_avalon_anti_slave_0_read,                       --                                                .read
			rx_sc_fifo_8_avalon_anti_slave_0_readdata                   => CONNECTED_TO_rx_sc_fifo_8_avalon_anti_slave_0_readdata,                   --                                                .readdata
			rx_sc_fifo_8_avalon_anti_slave_0_writedata                  => CONNECTED_TO_rx_sc_fifo_8_avalon_anti_slave_0_writedata,                  --                                                .writedata
			rx_sc_fifo_9_avalon_anti_slave_0_address                    => CONNECTED_TO_rx_sc_fifo_9_avalon_anti_slave_0_address,                    --                rx_sc_fifo_9_avalon_anti_slave_0.address
			rx_sc_fifo_9_avalon_anti_slave_0_write                      => CONNECTED_TO_rx_sc_fifo_9_avalon_anti_slave_0_write,                      --                                                .write
			rx_sc_fifo_9_avalon_anti_slave_0_read                       => CONNECTED_TO_rx_sc_fifo_9_avalon_anti_slave_0_read,                       --                                                .read
			rx_sc_fifo_9_avalon_anti_slave_0_readdata                   => CONNECTED_TO_rx_sc_fifo_9_avalon_anti_slave_0_readdata,                   --                                                .readdata
			rx_sc_fifo_9_avalon_anti_slave_0_writedata                  => CONNECTED_TO_rx_sc_fifo_9_avalon_anti_slave_0_writedata,                  --                                                .writedata
			rx_xcvr_clk_clk                                             => CONNECTED_TO_rx_xcvr_clk_clk,                                             --                                     rx_xcvr_clk.clk
			sync_rx_rst_reset_n                                         => CONNECTED_TO_sync_rx_rst_reset_n,                                         --                                     sync_rx_rst.reset_n
			tx_sc_fifo_0_avalon_anti_slave_0_address                    => CONNECTED_TO_tx_sc_fifo_0_avalon_anti_slave_0_address,                    --                tx_sc_fifo_0_avalon_anti_slave_0.address
			tx_sc_fifo_0_avalon_anti_slave_0_write                      => CONNECTED_TO_tx_sc_fifo_0_avalon_anti_slave_0_write,                      --                                                .write
			tx_sc_fifo_0_avalon_anti_slave_0_read                       => CONNECTED_TO_tx_sc_fifo_0_avalon_anti_slave_0_read,                       --                                                .read
			tx_sc_fifo_0_avalon_anti_slave_0_readdata                   => CONNECTED_TO_tx_sc_fifo_0_avalon_anti_slave_0_readdata,                   --                                                .readdata
			tx_sc_fifo_0_avalon_anti_slave_0_writedata                  => CONNECTED_TO_tx_sc_fifo_0_avalon_anti_slave_0_writedata,                  --                                                .writedata
			tx_sc_fifo_1_avalon_anti_slave_0_address                    => CONNECTED_TO_tx_sc_fifo_1_avalon_anti_slave_0_address,                    --                tx_sc_fifo_1_avalon_anti_slave_0.address
			tx_sc_fifo_1_avalon_anti_slave_0_write                      => CONNECTED_TO_tx_sc_fifo_1_avalon_anti_slave_0_write,                      --                                                .write
			tx_sc_fifo_1_avalon_anti_slave_0_read                       => CONNECTED_TO_tx_sc_fifo_1_avalon_anti_slave_0_read,                       --                                                .read
			tx_sc_fifo_1_avalon_anti_slave_0_readdata                   => CONNECTED_TO_tx_sc_fifo_1_avalon_anti_slave_0_readdata,                   --                                                .readdata
			tx_sc_fifo_1_avalon_anti_slave_0_writedata                  => CONNECTED_TO_tx_sc_fifo_1_avalon_anti_slave_0_writedata,                  --                                                .writedata
			tx_sc_fifo_10_avalon_anti_slave_0_address                   => CONNECTED_TO_tx_sc_fifo_10_avalon_anti_slave_0_address,                   --               tx_sc_fifo_10_avalon_anti_slave_0.address
			tx_sc_fifo_10_avalon_anti_slave_0_write                     => CONNECTED_TO_tx_sc_fifo_10_avalon_anti_slave_0_write,                     --                                                .write
			tx_sc_fifo_10_avalon_anti_slave_0_read                      => CONNECTED_TO_tx_sc_fifo_10_avalon_anti_slave_0_read,                      --                                                .read
			tx_sc_fifo_10_avalon_anti_slave_0_readdata                  => CONNECTED_TO_tx_sc_fifo_10_avalon_anti_slave_0_readdata,                  --                                                .readdata
			tx_sc_fifo_10_avalon_anti_slave_0_writedata                 => CONNECTED_TO_tx_sc_fifo_10_avalon_anti_slave_0_writedata,                 --                                                .writedata
			tx_sc_fifo_11_avalon_anti_slave_0_address                   => CONNECTED_TO_tx_sc_fifo_11_avalon_anti_slave_0_address,                   --               tx_sc_fifo_11_avalon_anti_slave_0.address
			tx_sc_fifo_11_avalon_anti_slave_0_write                     => CONNECTED_TO_tx_sc_fifo_11_avalon_anti_slave_0_write,                     --                                                .write
			tx_sc_fifo_11_avalon_anti_slave_0_read                      => CONNECTED_TO_tx_sc_fifo_11_avalon_anti_slave_0_read,                      --                                                .read
			tx_sc_fifo_11_avalon_anti_slave_0_readdata                  => CONNECTED_TO_tx_sc_fifo_11_avalon_anti_slave_0_readdata,                  --                                                .readdata
			tx_sc_fifo_11_avalon_anti_slave_0_writedata                 => CONNECTED_TO_tx_sc_fifo_11_avalon_anti_slave_0_writedata,                 --                                                .writedata
			tx_sc_fifo_2_avalon_anti_slave_0_address                    => CONNECTED_TO_tx_sc_fifo_2_avalon_anti_slave_0_address,                    --                tx_sc_fifo_2_avalon_anti_slave_0.address
			tx_sc_fifo_2_avalon_anti_slave_0_write                      => CONNECTED_TO_tx_sc_fifo_2_avalon_anti_slave_0_write,                      --                                                .write
			tx_sc_fifo_2_avalon_anti_slave_0_read                       => CONNECTED_TO_tx_sc_fifo_2_avalon_anti_slave_0_read,                       --                                                .read
			tx_sc_fifo_2_avalon_anti_slave_0_readdata                   => CONNECTED_TO_tx_sc_fifo_2_avalon_anti_slave_0_readdata,                   --                                                .readdata
			tx_sc_fifo_2_avalon_anti_slave_0_writedata                  => CONNECTED_TO_tx_sc_fifo_2_avalon_anti_slave_0_writedata,                  --                                                .writedata
			tx_sc_fifo_3_avalon_anti_slave_0_address                    => CONNECTED_TO_tx_sc_fifo_3_avalon_anti_slave_0_address,                    --                tx_sc_fifo_3_avalon_anti_slave_0.address
			tx_sc_fifo_3_avalon_anti_slave_0_write                      => CONNECTED_TO_tx_sc_fifo_3_avalon_anti_slave_0_write,                      --                                                .write
			tx_sc_fifo_3_avalon_anti_slave_0_read                       => CONNECTED_TO_tx_sc_fifo_3_avalon_anti_slave_0_read,                       --                                                .read
			tx_sc_fifo_3_avalon_anti_slave_0_readdata                   => CONNECTED_TO_tx_sc_fifo_3_avalon_anti_slave_0_readdata,                   --                                                .readdata
			tx_sc_fifo_3_avalon_anti_slave_0_writedata                  => CONNECTED_TO_tx_sc_fifo_3_avalon_anti_slave_0_writedata,                  --                                                .writedata
			tx_sc_fifo_4_avalon_anti_slave_0_address                    => CONNECTED_TO_tx_sc_fifo_4_avalon_anti_slave_0_address,                    --                tx_sc_fifo_4_avalon_anti_slave_0.address
			tx_sc_fifo_4_avalon_anti_slave_0_write                      => CONNECTED_TO_tx_sc_fifo_4_avalon_anti_slave_0_write,                      --                                                .write
			tx_sc_fifo_4_avalon_anti_slave_0_read                       => CONNECTED_TO_tx_sc_fifo_4_avalon_anti_slave_0_read,                       --                                                .read
			tx_sc_fifo_4_avalon_anti_slave_0_readdata                   => CONNECTED_TO_tx_sc_fifo_4_avalon_anti_slave_0_readdata,                   --                                                .readdata
			tx_sc_fifo_4_avalon_anti_slave_0_writedata                  => CONNECTED_TO_tx_sc_fifo_4_avalon_anti_slave_0_writedata,                  --                                                .writedata
			tx_sc_fifo_5_avalon_anti_slave_0_address                    => CONNECTED_TO_tx_sc_fifo_5_avalon_anti_slave_0_address,                    --                tx_sc_fifo_5_avalon_anti_slave_0.address
			tx_sc_fifo_5_avalon_anti_slave_0_write                      => CONNECTED_TO_tx_sc_fifo_5_avalon_anti_slave_0_write,                      --                                                .write
			tx_sc_fifo_5_avalon_anti_slave_0_read                       => CONNECTED_TO_tx_sc_fifo_5_avalon_anti_slave_0_read,                       --                                                .read
			tx_sc_fifo_5_avalon_anti_slave_0_readdata                   => CONNECTED_TO_tx_sc_fifo_5_avalon_anti_slave_0_readdata,                   --                                                .readdata
			tx_sc_fifo_5_avalon_anti_slave_0_writedata                  => CONNECTED_TO_tx_sc_fifo_5_avalon_anti_slave_0_writedata,                  --                                                .writedata
			tx_sc_fifo_6_avalon_anti_slave_0_address                    => CONNECTED_TO_tx_sc_fifo_6_avalon_anti_slave_0_address,                    --                tx_sc_fifo_6_avalon_anti_slave_0.address
			tx_sc_fifo_6_avalon_anti_slave_0_write                      => CONNECTED_TO_tx_sc_fifo_6_avalon_anti_slave_0_write,                      --                                                .write
			tx_sc_fifo_6_avalon_anti_slave_0_read                       => CONNECTED_TO_tx_sc_fifo_6_avalon_anti_slave_0_read,                       --                                                .read
			tx_sc_fifo_6_avalon_anti_slave_0_readdata                   => CONNECTED_TO_tx_sc_fifo_6_avalon_anti_slave_0_readdata,                   --                                                .readdata
			tx_sc_fifo_6_avalon_anti_slave_0_writedata                  => CONNECTED_TO_tx_sc_fifo_6_avalon_anti_slave_0_writedata,                  --                                                .writedata
			tx_sc_fifo_7_avalon_anti_slave_0_address                    => CONNECTED_TO_tx_sc_fifo_7_avalon_anti_slave_0_address,                    --                tx_sc_fifo_7_avalon_anti_slave_0.address
			tx_sc_fifo_7_avalon_anti_slave_0_write                      => CONNECTED_TO_tx_sc_fifo_7_avalon_anti_slave_0_write,                      --                                                .write
			tx_sc_fifo_7_avalon_anti_slave_0_read                       => CONNECTED_TO_tx_sc_fifo_7_avalon_anti_slave_0_read,                       --                                                .read
			tx_sc_fifo_7_avalon_anti_slave_0_readdata                   => CONNECTED_TO_tx_sc_fifo_7_avalon_anti_slave_0_readdata,                   --                                                .readdata
			tx_sc_fifo_7_avalon_anti_slave_0_writedata                  => CONNECTED_TO_tx_sc_fifo_7_avalon_anti_slave_0_writedata,                  --                                                .writedata
			tx_sc_fifo_8_avalon_anti_slave_0_address                    => CONNECTED_TO_tx_sc_fifo_8_avalon_anti_slave_0_address,                    --                tx_sc_fifo_8_avalon_anti_slave_0.address
			tx_sc_fifo_8_avalon_anti_slave_0_write                      => CONNECTED_TO_tx_sc_fifo_8_avalon_anti_slave_0_write,                      --                                                .write
			tx_sc_fifo_8_avalon_anti_slave_0_read                       => CONNECTED_TO_tx_sc_fifo_8_avalon_anti_slave_0_read,                       --                                                .read
			tx_sc_fifo_8_avalon_anti_slave_0_readdata                   => CONNECTED_TO_tx_sc_fifo_8_avalon_anti_slave_0_readdata,                   --                                                .readdata
			tx_sc_fifo_8_avalon_anti_slave_0_writedata                  => CONNECTED_TO_tx_sc_fifo_8_avalon_anti_slave_0_writedata,                  --                                                .writedata
			tx_sc_fifo_9_avalon_anti_slave_0_address                    => CONNECTED_TO_tx_sc_fifo_9_avalon_anti_slave_0_address,                    --                tx_sc_fifo_9_avalon_anti_slave_0.address
			tx_sc_fifo_9_avalon_anti_slave_0_write                      => CONNECTED_TO_tx_sc_fifo_9_avalon_anti_slave_0_write,                      --                                                .write
			tx_sc_fifo_9_avalon_anti_slave_0_read                       => CONNECTED_TO_tx_sc_fifo_9_avalon_anti_slave_0_read,                       --                                                .read
			tx_sc_fifo_9_avalon_anti_slave_0_readdata                   => CONNECTED_TO_tx_sc_fifo_9_avalon_anti_slave_0_readdata,                   --                                                .readdata
			tx_sc_fifo_9_avalon_anti_slave_0_writedata                  => CONNECTED_TO_tx_sc_fifo_9_avalon_anti_slave_0_writedata,                  --                                                .writedata
			tx_xcvr_clk_clk                                             => CONNECTED_TO_tx_xcvr_clk_clk,                                             --                                     tx_xcvr_clk.clk
			sync_tx_rst_reset_n                                         => CONNECTED_TO_sync_tx_rst_reset_n,                                         --                                     sync_tx_rst.reset_n
			tx_xcvr_half_clk_clk                                        => CONNECTED_TO_tx_xcvr_half_clk_clk,                                        --                                tx_xcvr_half_clk.clk
			sync_tx_half_rst_reset_n                                    => CONNECTED_TO_sync_tx_half_rst_reset_n                                     --                                sync_tx_half_rst.reset_n
		);

