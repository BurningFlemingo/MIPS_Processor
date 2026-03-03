library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.soft_rom.all;

entity instruction_mem is 
	port (
		i_addr : in std_logic_vector(31 downto 0);
		o_data : out std_logic_vector(31 downto 0)
	);
end entity instruction_mem;

architecture rtl of instruction_mem is 
begin 

	o_data <= c_soft_rom(to_integer(unsigned(i_addr)))
		& c_soft_rom(to_integer(unsigned(i_addr) + 1))
		& c_soft_rom(to_integer(unsigned(i_addr) + 2))
		& c_soft_rom(to_integer(unsigned(i_addr) + 3));

end architecture rtl;
