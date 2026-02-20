library ieee;
use ieee.std_logic_1164.all;

entity ripple_adder is
	generic (
		g_input_size : natural range 1 to 64 := 8
	);
	port (
		i_lhs : in std_logic_vector(g_input_size-1 downto 0);
		i_rhs : in std_logic_vector(g_input_size-1 downto 0);
		i_carry_in : in std_logic;
	
		o_sum : out std_logic_vector(g_input_size-1 downto 0);
		o_overflowed : out std_logic
	);
end entity ripple_adder;

architecture rtl of ripple_adder is 
	signal s_carry : std_logic_vector(g_input_size downto 0);
	
begin
	s_carry(0) <= i_carry_in;
	
	gen_adders: for i in 0 to g_input_size-1 generate
		full_adder_inst: entity work.full_adder
			port map(
				i_lhs => i_lhs(i),
				i_rhs => i_rhs(i),
				i_carry_in => s_carry(i),
				o_sum => o_sum(i),
				o_carry_out => s_carry(i+1)
			);
	end generate gen_adders;
	o_overflowed <= s_carry(g_input_size) xor s_carry(g_input_size-1);
end architecture rtl;
