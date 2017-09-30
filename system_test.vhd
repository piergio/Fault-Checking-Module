LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity system_test is
end entity;

architecture test of system_test is
	component top_level is
		generic	(
						rom_size: integer:=16;
						nbit : integer:= 8
					);
		port	(	power : in std_logic;
					clk : in std_logic;
					ok_status : out std_logic;
					fault_status : OUT std_logic;
					debug_port : out std_logic_vector(2*nbit-1 downto 0);
					counter: OUT std_logic_vector(2 downto 0);
					state : out std_logic_vector(2 downto 0)
				);
	end component;
	
	constant N : integer:=8;
	signal power_s : std_logic := '1';
	signal ok_status_s, fault_status_s : std_logic;
	signal state_s : std_logic_vector(2 downto 0);
	signal clk_s : std_logic := '1';
	signal counter_s : std_logic_vector(2 downto 0);
	
	begin
		
		comp : top_level
					generic map (
										rom_size => 16,
										nbit => N
									)
					port map (	power => power_s,
									clk => clk_s,
									ok_status => ok_status_s,
									fault_status => fault_status_s,
									counter => counter_s,
									state => state_s
								);

	clk_s <= not (clk_s) after 3.33 ns;
	power_s <= not (power_s) after 1500 ns;
	--rom_en1_s <= '0', '1' after 2 ns;
	--rom_en2_s <= '0', '1' after 2 ns;
		
end test;