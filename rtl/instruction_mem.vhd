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
	signal s_data : t_mem := (x"20",x"08",x"00",x"0A",x"20",x"09",x"00",x"07",x"01",x"09",x"50",x"20",x"01",x"09",x"58",x"22",x"01",x"09",x"60",x"24",x"01",x"09",x"68",x"25",x"AC",x"0A",x"00",x"00",x"AC",x"0B",x"00",x"04",x"8C",x"0E",x"00",x"00",x"8C",x"0F",x"00",x"04",x"01",x"CF",x"80",x"20",x"21",x"11",x"FF",x"F6",x"12",x"20",x"00",x"01",x"20",x"12",x"00",x"63",x"20",x"12",x"00",x"37",x"11",x"09",x"00",x"01",x"20",x"13",x"00",x"0B",x"20",x"13",x"00",x"00",others => x"00");
begin 

	o_data <= s_data(to_integer(unsigned(i_addr)))
		& s_data(to_integer(unsigned(i_addr) + 1))
		& s_data(to_integer(unsigned(i_addr) + 2))
		& s_data(to_integer(unsigned(i_addr) + 3));

end architecture rtl;
