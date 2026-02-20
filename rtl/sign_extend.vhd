library ieee;
use ieee.std_logic_1164.all;

entity sign_extend is 
	port (
		i_signed_data : in std_logic_vector(15 downto 0);
		o_signed_data : out std_logic_vector(31 downto 0)
	);
end entity sign_extend;

architecture rtl of sign_extend is 
	signal s_sign : std_logic; 
begin 
	s_sign <= i_signed_data(15);
	o_signed_data <= (31 downto 16 => s_sign) & i_signed_data;
end architecture rtl;
