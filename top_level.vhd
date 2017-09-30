library ieee;
use ieee.std_logic_1164.all;

entity top_level is
	generic	(
					nbit : integer:=8;
					rom_size: integer:=16
				);
	port	(	power : in std_logic;
				clk : in std_logic;
				ok_status : out std_logic;
				fault_status : out std_logic;
				debug_port	: out std_logic_vector(2*nbit-1 downto 0);
				counter: OUT std_logic_vector(2 downto 0);
				state:	out	std_logic_vector(2 downto 0)
			);
end entity;

architecture top_level_arch of top_level is
	
	component controller
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
	end component;
	
	component datapath
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
	end component;
	
	component rom
--		generic ( 
--						ROM_SIZE : integer:=16
--					);
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
	end component;
	
	component sync_ram
		port	(
					clk : in std_logic;
--				   enable : in std_logic;
					address : in std_logic_vector(2 downto 0);
					r_en : in std_logic;
					wr_en : in std_logic;
					dataout : out std_logic_vector(15 downto 0);
					datain : in std_logic_vector(15 downto 0)
				);
	end component;
	
--	component ram is
--		  PORT (
--					 clka : IN STD_LOGIC;
--					 wea : IN STD_LOGIC_VECTOR(0 downto 0);
--					 addra : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
--					 dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--					 douta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
--  );
--	end component;
	
	signal datap_out1	: std_logic_vector(15 downto 0);
	signal datap_out2	: std_logic_vector(15 downto 0);
	signal rom_enable_s	: std_logic;
	signal rom_r_en1_s : std_logic;
	signal rom_r_en2_s : std_logic;
	signal rom_addr1_s : std_logic_vector(3 downto 0);
	signal rom_addr2_s : std_logic_vector(3 downto 0);
	signal enable : std_logic;
	signal compare_start : std_logic;
	signal ready_res : std_logic;
	signal rom_data_out1 : std_logic_vector(nbit-1 downto 0);
	signal rom_data_out2 : std_logic_vector(nbit-1 downto 0);
	signal ram_r_en_s : std_logic;
	signal ram_w_en_s : std_logic;
	signal ram_addr_s : std_logic_vector(2 downto 0);
	signal to_ram_s : std_logic_vector(15 downto 0);
	signal debug_port_s : std_logic_vector(15 downto 0);
	
begin
	
	debug_port <= debug_port_s;
	
	contr : controller
				generic map(
					nbit => nbit
				)
				port map	(	power => power,
								tog_en => enable,
								res => ready_res,
								clk => clk,
								result_in => datap_out2,
								compare => compare_start,
								rom_en => rom_enable_s,
								rom_r_en1 => rom_r_en1_s,
								rom_r_en2 => rom_r_en2_s,
								rom_addr1 => rom_addr1_s,
								rom_addr2 => rom_addr2_s,
								ram_r_en => ram_r_en_s,
								ram_w_en => ram_w_en_s,
								ram_addr => ram_addr_s,
								to_ram => to_ram_s,
								ok_status => ok_status,
								fault_status => fault_status,
								counter => counter,
								state => state
							);
							
	datap : datapath
				generic map	(
									nbit => nbit
								)
				port map	(	A => rom_data_out1,
								B => rom_data_out2,
								clk => clk,
								comp_s => compare_start,
								result_s => ready_res,
								OUT1 => datap_out1,
								OUT2 => datap_out2
							);
	
	rom_mem : rom
--				generic map(
--					ROM_SIZE => rom_size
--				)
				port map	(
								clk => clk,
								enable => rom_enable_s,
								read_addr1 => rom_addr1_s,
								read_addr2 => rom_addr2_s,
								read_en1 => rom_r_en1_s,
								read_en2 => rom_r_en2_s,
								dataout1 => rom_data_out1,
								dataout2 => rom_data_out2
							);
				
	ram_mem : sync_ram
				port map (
								clk => clk,
								address => ram_addr_s,
								r_en => ram_r_en_s,
								wr_en => ram_w_en_s,
								dataout => debug_port_s,
								datain => to_ram_s				
							);
--	ram_mem : ram
--				port map (
--								clka => clk,
--								addra => ram_addr_s,
--								wea => ram_w_en_s,
--								douta => debug_port_s,
--								dina => to_ram_s				
--							);

	
end top_level_arch;