library ieee;
use ieee.std_logic_1164.all;

entity full_adder is 
	port (
		i_lhs : in std_logic;
		i_rhs : in std_logic;
		i_carry_in : in std_logic;
	
		o_sum : out std_logic;
		o_carry_out : out std_logic
	);
end entity full_adder;

architecture rtl of full_adder is 
	signal s_xor_input : std_logic;
begin
	s_xor_input <= i_lhs xor i_rhs;
	o_sum <= s_xor_input xor i_carry_in;
	o_carry_out <= (s_xor_input and i_carry_in) or (i_lhs and i_rhs);
end architecture rtl;
