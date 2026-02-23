library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_mem is 
	port (
		i_clk : in std_logic;
	
		i_mem_write : in std_logic;
		i_mem_read : in std_logic;
	
		i_addr : in std_logic_vector(31 downto 0);
		i_data : in std_logic_vector(31 downto 0);
	
		o_data : out std_logic_vector(31 downto 0)
	);
end entity data_mem;

architecture rtl of data_mem is 
	type t_mem is array (0 to 1023) of std_logic_vector(7 downto 0);
	signal s_data : t_mem := (others => x"00");
begin 

	with i_mem_read select
	o_data <= s_data(to_integer(unsigned(i_addr)))
		& s_data(to_integer(unsigned(i_addr) + 1))
		& s_data(to_integer(unsigned(i_addr) + 2))
		& s_data(to_integer(unsigned(i_addr) + 3)) when '1', 
		(others => '0') when others;

	write_proc: process(i_clk) 
	begin 
		if rising_edge(i_clk) then
			if i_mem_write = '1' then
				s_data(to_integer(unsigned(i_addr))) <= i_data(31 downto 24);
				s_data(to_integer(unsigned(i_addr)) + 1) <= i_data(23 downto 16);
				s_data(to_integer(unsigned(i_addr)) + 2) <= i_data(15 downto 8);
				s_data(to_integer(unsigned(i_addr)) + 3) <= i_data(7 downto 0);
			end if;
		end if;
	end process write_proc;

end architecture rtl;
