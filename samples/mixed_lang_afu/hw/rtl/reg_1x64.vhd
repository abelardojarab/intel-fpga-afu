library ieee;
use ieee.std_logic_1164.all;

entity reg_1x64 is
	port 
	(
		data_in	: in std_logic_vector(63 downto 0);
		enable	: in std_logic;
		clk		: in std_logic;
		SoftReset : in std_logic;
		data_out	: out std_logic_vector(63 downto 0)
	);
	
end entity;

architecture rtl of reg_1x64 is
	signal reg: std_logic_vector(63 downto 0);

begin

	process (clk)
	begin
		if (rising_edge(clk)) then
			if (SoftReset = '1') then
				reg <= (others => '0');
			
			elsif (enable = '1') then
				
				reg <= data_in;
			
			end if;
		end if;
	end process;
	
	data_out <= reg;
end rtl;


