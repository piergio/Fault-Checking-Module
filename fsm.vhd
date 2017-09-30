library ieee;
use ieee.std_logic_1164.all;


-- Moore type --

entity fsm is
	port	(	power:	IN		std_logic;
				tog_en:	IN		std_logic;
				clk:		IN		std_logic;
				A:			IN		std_logic_vector(7 downto 0);
				B:			IN		std_logic_vector(7 downto 0);
				o1:		OUT	std_logic_vector(7 downto 0);
				o2:		OUT	std_logic_vector(7 downto 0);
				state:	OUT	std_logic
			);
end fsm;

architecture fsm_arch of fsm is
	
	type state_type is (S0, S1);
	signal PS, NS : state_type;
	
begin
		
		with PS select
			
			state <= '0' when S0,
						'1' when S1,
						'0' when others;
						
		sync : process(clk, NS, power)
		begin
			if (power = '1') then
				
				PS <= S0;

			elsif (rising_edge(clk)) then
				
				PS <= NS;
				
			end if;
		end process;
		
		comb : process(PS, tog_en)
		begin
			
			case PS is
			
				when S0 =>
				
					o1 <= (others => '0');
					o2 <= (others => '0');
					if (tog_en = '1') then
						NS <= S1;
					else
						NS <= S0;
					end if;
					
				when S1 =>
					
					o1 <= A;
					o2 <= B;
					if(tog_en = '1') then
						NS <= S0;
					else
						NS <= S1;
					end if;
				
				when others =>
					
					o1 <= (others => '0');
					o2 <= (others => '0');
					NS <= S0;
			end case;
			
		end process;
		
end fsm_arch;