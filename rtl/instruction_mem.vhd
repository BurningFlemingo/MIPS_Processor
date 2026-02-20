library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_mem is 
	port (
		i_addr : in std_logic_vector(31 downto 0);
		o_data : out std_logic_vector(31 downto 0)
	);
end entity instruction_mem;

architecture rtl of instruction_mem is 
	type t_mem is array (0 to 255) of std_logic_vector(7 downto 0);
	signal s_data : t_mem := (x"20", x"00", x"00", x"01", x"20", x"00", x"00", x"01", x"20", x"00", x"00", x"01", x"20", x"00", x"00", x"01", x"20", x"00", x"00", x"01", x"20", x"00", x"00", x"01", others => x"00");
begin 

	o_data <= s_data(to_integer(unsigned(i_addr)))
		& s_data(to_integer(unsigned(i_addr) + 1))
		& s_data(to_integer(unsigned(i_addr) + 2))
		& s_data(to_integer(unsigned(i_addr) + 3));

end architecture rtl;
