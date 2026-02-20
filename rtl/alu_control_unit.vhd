library ieee;
use ieee.std_logic_1164.all; 

entity alu_control_unit is
	port (
		i_alu_op : in std_logic_vector(1 downto 0); 
		i_funct : in std_logic_vector(5 downto 0);

		o_alu_control : out std_logic_vector(3 downto 0)
	);
end entity alu_control_unit;

architecture rtl of alu_control_unit is
	signal s_decoded_funct : std_logic_vector(3 downto 0);
begin
	with i_funct(3 downto 0) select 
		s_decoded_funct <= "0010" when "0000",
						   "0110" when "0010",
						   "0000" when "0100",
						   "0001" when "0101",
						   "0111" when "1010",
						   "0000" when others;
	with i_alu_op select
		o_alu_control <= "0010" when "00", 
						 "0100" when "01", 
						 s_decoded_funct when "10",
						 "0000" when others;

	
end architecture rtl;
