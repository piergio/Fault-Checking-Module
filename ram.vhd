library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sync_ram is
	port	(
				clk : in std_logic;
--				enable : in std_logic;
				address : in std_logic_vector(2 downto 0);
				r_en : in std_logic;
				wr_en : in std_logic;
				dataout : out std_logic_vector(15 downto 0);
				datain : in std_logic_vector(15 downto 0)
			);
end entity;

architecture ram_arch of sync_ram is

   type ram_type is array (integer range 0 to 7) of std_logic_vector(15 downto 0);
   signal ram : ram_type;

begin

	process(clk)
	begin
  
		if (rising_edge(clk) and clk'event)  then
			if (wr_en = '1') then
			
				ram(to_integer(unsigned(address))) <= datain;
			end if;
			
			if (r_en = '1') then
			
				dataout <= ram(to_integer(unsigned(address)));
			else	
				dataout <= (others => '0');
			end if;
		end if;
		
	end process;

  
end architecture ram_arch;
