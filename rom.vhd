library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rom is
--	generic ( 
--					ROM_SIZE : integer:=16
--				);
	port	(
				clk : in std_logic;
				enable : in std_logic;
				read_addr1 : in std_logic_vector(3 downto 0);
				read_addr2 : in std_logic_vector(3 downto 0);
				read_en1 : in std_logic;
				read_en2 : in std_logic;
				dataout1 : out std_logic_vector(7 downto 0);
				dataout2 : out std_logic_vector(7 downto 0)
			);
end entity;

architecture rom_arch of rom is
	
--	constant r_size : integer := ROM_SIZE;
	-- it contains data to make 8 multiplications
	type mem_array is array (integer range 0 to 15) of std_logic_vector(7 downto 0);
	signal memory : mem_array := ( "00000001",
											 "00000010",
											 "00000011",
											 "00000100",
											 "00000101",
											 "00000110",
											 "00000111",
											 "00001000",
											 "00001001",
											 "00001010",
											 "00001011",
											 "00001100",
											 "00001101",
											 "00001110",
											 "00001111",
											 "00010000"
											 );
	
	begin
	
		process(clk)
		begin
			if(clk = '1' and clk'EVENT) then
				
				if (enable = '1') then
					if(read_en1 = '1') then
						dataout1 <= memory(to_integer(unsigned(read_addr1)));
					--else
						--dataout1 <= (others => 'Z');
					end if;
					
					if(read_en2 = '1') then
						dataout2 <= memory(to_integer(unsigned(read_addr2)));
					--else
						--dataout2 <= (others => 'Z');
					end if;
				
				--else
					--dataout1 <= (others => 'Z');
					--dataout2 <= (others => 'Z');
				end if;
			
			end if;
		end process;
end rom_arch;