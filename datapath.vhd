library ieee;
use ieee.std_logic_1164.all;

entity datapath is
	generic	(
					nbit : integer:=8
				);
	port	(	A: in std_logic_vector(nbit-1 downto 0);
				B: in std_logic_vector(nbit-1 downto 0);
				clk: in std_logic;
				comp_s: in std_logic;
				result_s: out std_logic;
				OUT1: out std_logic_vector(2*nbit-1 downto 0);
				OUT2: out std_logic_vector(2*nbit-1 downto 0)
			);
end entity;

architecture datap_arch of datapath is
	
	component multiplier1
		port (
				 clk : IN STD_LOGIC;
				 a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
				 b : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
				 p : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
				);
	end component;
	
	component multiplier2
		port (
				 clk : IN STD_LOGIC;
				 a : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
				 b : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
				 p : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
				);
	end component;
	
	signal mult1_res : std_logic_vector(15 downto 0);
	signal mult2_res : std_logic_vector(15 downto 0);
	
begin
	
	mult1: multiplier1
				port map	(	clk => clk, a => A, b => B, p => mult1_res	);
	
	mult2: multiplier2
				port map	(	clk => clk, a => A, b => B, p => mult2_res	);
	
	process(comp_s, mult1_res, mult2_res)
	begin
		if (comp_s = '1') then
			if (mult1_res = mult2_res) then
				result_s <= '1';
			else
				result_s <= '0';
			end if;
		end if;
	end process;	
	
	OUT1 <= mult1_res;
	OUT2 <= mult2_res;
	
end datap_arch;