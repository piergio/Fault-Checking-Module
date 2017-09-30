library ieee;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.math_real.all;

entity controller is
	generic	(
					nbit : integer:=8
				);
	port (	power:			IN		std_logic;
				tog_en:			IN		std_logic;
				res:				IN		std_logic;
				clk:				IN		std_logic;
				result_in:		IN		std_logic_vector(2*nbit-1 downto 0);
				compare:			OUT	std_logic;
				
				---------- ROM --------------
				
				rom_en:			OUT	std_logic;
				rom_r_en1:		OUT	std_logic;
				rom_r_en2:		OUT	std_logic;
				rom_addr1:		OUT	std_logic_vector(3 downto 0);
				rom_addr2:		OUT	std_logic_vector(3 downto 0);
				
				---------- RAM --------------
--				ram_en:			OUT	std_logic;
				ram_r_en:		OUT	std_logic;
				ram_w_en:		OUT	std_logic;
				ram_addr:		OUT	std_logic_vector(2 downto 0);
				to_ram:			OUT	std_logic_vector(2*nbit-1 downto 0);
				
				------------------------------
				ok_status: 		OUT	std_logic;
				fault_status:	OUT	std_logic;
				counter: 		OUT	std_logic_vector(2 downto 0);
				state:			OUT	std_logic_vector(2 downto 0)
			);
end entity;

architecture contr_arch of controller is

constant rom_size : integer := 16;
type state_type is (RESET, S0, S1, S2, S3, RAM, L, R, OK, FAULT, DELAY_OK, DELAY_FAULT);
	signal present_state, next_state : state_type;
signal counter_s : std_logic_vector(2 downto 0) := (others => '0');
signal size_counter_s : std_logic_vector(3 downto 0) := (others => '0');
signal clock_counter_s : std_logic_vector(2 downto 0) := (others => '0');
--variable size_counter_s : std_logic_vector(3 downto 0);
--variable clock_counter_s : std_logic_vector(1 downto 0);


begin
		
		counter <= counter_s;
											
		with present_state select
			
			state <= "000" when S0,
						"001" when S1,
						"010" when S2,
						"011" when S3,
						"111" when others;
						
		sync : process(clk, power)
		begin
			if (power = '0') then
				
				present_state <= S0;

			elsif (rising_edge(clk) and clk'EVENT) then
				
				present_state <= next_state;
				
			end if;
		end process;
		
		comb : process(present_state, tog_en, res)
			
			variable i : std_logic := '0';
		begin
			
			compare <=  '0';
			rom_en <= '0';
			rom_r_en1 <= '0';
			rom_r_en2 <= '0';
			ram_r_en <= '0';
			ram_w_en <= '0';
			case present_state is
				
				when RESET =>
					
					rom_en <= '0';
					rom_r_en1 <= '0';
					rom_r_en2 <= '0';
					rom_addr1 <= (others => '0');
					rom_addr2 <= (others => '0');
					ram_r_en <= '0';
					ram_w_en <= '0';
					counter_s <= (others => '0');
					next_state <= S0;
					
				when S0 =>		-- first state, sets ok_status and fault_status to '0'
					
					ok_status <= '0';
					fault_status <= '0';
					next_state <= S1;
					
				when S1 =>		-- second state, enables the rom and the comparison
											
					size_counter_s <= size_counter_s + 1;
					rom_en <= '1';
					rom_r_en1 <= '1';
					rom_r_en2 <= '1';
					rom_addr1 <= size_counter_s;
					rom_addr2 <= size_counter_s + 1;
					compare <= '1';
						
					next_state <= S2;
					
				when S2 =>		-- third state, if the res input signal provided by the datapath is 0 means an error happened
									-- therefore the counter is incremented, then we go into the RAM state in order to write the
									-- wrong value on the RAM
					if (res = '0') then
						
						counter_s <= counter_s + 1;
						next_state <= RAM;
					else
					
					--	to_ram <= (others => 'Z');
						next_state <= S3;
					end if;
					
				when RAM =>		-- fourth state (RAM state), enables the RAM and addresses it to write the wrong result
				
					ram_w_en <= '1';
					ram_addr <= counter_s - 1;
					to_ram <= result_in;
					
					next_state <= S3;
					
				when S3 =>		-- fifth state, checks if we have already addressed the entire memory
				
					if (conv_integer(unsigned(size_counter_s)) = 15) then
						if (i /= '1') then
							next_state <= L;
						else
							next_state <= R;
						end if;
					else
						next_state <= S0;
					end if;
					
				when L =>
					
					compare <= '1';
					i := '1';
					next_state <= S2;
					
				when R =>	-- it checks if the counter is higher or equal to 1 that would mean a fault
								-- if yes, then it goes to FAULT state, otherwise it goes to OK state
					compare <= '0';
					size_counter_s <= (others => '0');
					   
					if (counter_s >= X"1") then
						
						next_state <= FAULT;
					else						
						next_state <= OK;
					end if;
				
				when FAULT =>
				
					if (conv_integer(unsigned(clock_counter_s)) < 7) then
						
						fault_status <= '1';
						clock_counter_s <= clock_counter_s + 1;
						next_state <= DELAY_FAULT;
					else
						next_state <= RESET;
					end if;
				
				when DELAY_FAULT =>
					
					ram_r_en <= '1';
					ram_addr <= clock_counter_s - 1;
					
					next_state <= FAULT;
					
				when OK =>
				
					if (conv_integer(unsigned(clock_counter_s)) < 375) then
						
						ok_status <= '1';
						clock_counter_s <= clock_counter_s + 1;
						next_state <= DELAY_OK;
					else
						next_state <= RESET;
					end if;
				
				when DELAY_OK =>
					
					next_state <= OK;
					
				when others =>
					
					next_state <= RESET;
				
			end case;
			
		end process;
		
end contr_arch;