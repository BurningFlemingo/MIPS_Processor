library ieee;
use ieee.std_logic_1164.all;

entity alu is 
	port (
		i_opcode : in std_logic_vector(3 downto 0);
		i_lhs : in std_logic_vector(31 downto 0);
		i_rhs : in std_logic_vector(31 downto 0);

		o_result : out std_logic_vector(31 downto 0);
		o_zero : out std_logic
	);
end entity alu;

architecture rtl of alu is
	signal s_xored_rhs : std_logic_vector(31 downto 0);
	signal s_xored_lhs : std_logic_vector(31 downto 0);
	
	signal s_sum : std_logic_vector(31 downto 0);
	signal s_sum_or_set : std_logic_vector(31 downto 0);
	signal s_logic : std_logic_vector(31 downto 0);
	
	signal s_overflowed : std_logic := '0';
	signal s_result : std_logic_vector(31 downto 0); 
begin 
	s_xored_rhs <= i_rhs(31 downto 0) xor (31 downto 0 => i_opcode(2));
	s_xored_lhs <= i_lhs(31 downto 0) xor (31 downto 0 => i_opcode(3));

	with i_opcode(0) select
		s_logic <= s_xored_lhs and s_xored_rhs when '0', 
				   s_xored_lhs or s_xored_rhs when others;
				   
	adder_inst: entity work.ripple_adder 
		generic map(
			g_input_size => 32
		)
		port map(
			i_lhs => s_xored_lhs, 
			i_rhs => s_xored_rhs, 
			i_carry_in => i_opcode(2),
			o_sum => s_sum,
			o_overflowed => s_overflowed
	);

	with i_opcode(0) select
		s_sum_or_set <= (31 downto 1 => '0') & s_sum(31) when '1', 
					  s_sum when others;
		

	with i_opcode(1) select
		s_result <= s_sum_or_set when '1',
					s_logic when others;

	with s_result select
		o_zero <= '1' when (others => '0'), 
				  '0' when others;
	
	o_result <= s_result;
	
		
end architecture rtl;
