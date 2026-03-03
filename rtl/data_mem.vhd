library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_mem is 
	generic (
		g_bits_of_addr_space : natural := 12
	);
	port (
		i_clk : in std_logic;
	
		i_mem_write : in std_logic;
		i_mem_read : in std_logic;
	
		i_addr : in std_logic_vector(g_bits_of_addr_space-1 downto 0);
		i_data : in std_logic_vector(31 downto 0);
		
		i_switches : in std_logic_vector(9 downto 0);
	
		o_data : out std_logic_vector(31 downto 0);
		o_seven_seg : out std_logic_vector(15 downto 0)
	);
end entity data_mem;

architecture rtl of data_mem is 
	constant c_highest_word_addr : natural := ((2**g_bits_of_addr_space) / 4) - 1;
	constant c_mm_segment_display : natural := c_highest_word_addr;
	constant c_mm_switches : natural := c_highest_word_addr-1;
	
	type t_mem is array (0 to c_highest_word_addr) of std_logic_vector(31 downto 0);
	signal r_word_arr : t_mem := (0 to c_highest_word_addr => (others => '0'));
	signal s_word_addr : std_logic_vector(g_bits_of_addr_space-1 downto 0);
begin 
	s_word_addr <= "00" & i_addr(g_bits_of_addr_space-1 downto 2);
	
	write_proc: process(i_clk) 
	begin 
		if rising_edge(i_clk) then
			if i_mem_write = '1' then
				if to_integer(unsigned(s_word_addr)) = c_mm_segment_display then
					o_seven_seg <= i_data(15 downto 0);
				else
					r_word_arr(to_integer(unsigned(s_word_addr))) <= i_data;
				end if;
			end if;
			
			if i_mem_read = '1' then
				if to_integer(unsigned(s_word_addr)) = c_mm_switches then
					o_data <= (31 downto 10 => '0') & i_switches;
				else 
					o_data <= r_word_arr(to_integer(unsigned(s_word_addr)));
				end if;
			end if;
		end if;
	end process write_proc;

end architecture rtl;
