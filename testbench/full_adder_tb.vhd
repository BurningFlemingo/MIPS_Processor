library ieee;
use ieee.std_logic_1164.all;

entity full_adder_tb is 
end entity full_adder_tb;

architecture tb of full_adder_tb is 
	signal s_lhs : std_logic; 
	signal s_rhs : std_logic; 
	signal s_carry_in : std_logic; 
	signal s_sum : std_logic; 
	signal s_carry_out : std_logic; 
begin
	uut: entity work.full_adder 
		port map(
			i_lhs => s_lhs,
			i_rhs => s_rhs,
			i_carry_in => s_carry_in,
			o_sum => s_sum,
			o_carry_out => s_carry_out 
		);

	stim_proc: process 
	begin
		s_lhs <= '0';
		s_rhs <= '0';
		s_carry_in <= '0';
		wait for 10ns;

		s_lhs <= '1';
		s_rhs <= '0';
		s_carry_in <= '0';
		wait for 10ns;

		s_lhs <= '0';
		s_rhs <= '1';
		s_carry_in <= '0';
		wait for 10ns;

		s_lhs <= '1';
		s_rhs <= '1';
		s_carry_in <= '0';
		wait for 10ns;

		s_lhs <= '0';
		s_rhs <= '0';
		s_carry_in <= '1';
		wait for 10ns;

		s_lhs <= '1';
		s_rhs <= '0';
		s_carry_in <= '1';
		wait for 10ns;

		s_lhs <= '0';
		s_rhs <= '1';
		s_carry_in <= '1';
		wait for 10ns;

		s_lhs <= '1';
		s_rhs <= '1';
		s_carry_in <= '1';
		wait for 10ns;
	end process;
end architecture tb;
