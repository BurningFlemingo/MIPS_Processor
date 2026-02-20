library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_to_bcd is 
	port (
		i_binary : in std_logic_vector(3 downto 0);
		o_ones : out std_logic_vector(3 downto 0) := "0000";
		o_tens : out std_logic_vector(3 downto 0) := "0000"
	);
end entity binary_to_bcd;

architecture rtl of binary_to_bcd is 
begin 
	process(i_binary) 
		variable temp : unsigned(3 downto 0);
	begin
		temp := unsigned(i_binary);
		if i_binary > "1001" then 
			o_ones <= std_logic_vector(temp - 10);
			o_tens <= "0001";
		else 
			o_ones <= i_binary;
			o_tens <= "0000";
		end if;
	end process;
	
end architecture rtl;
