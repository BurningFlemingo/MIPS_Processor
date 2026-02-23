library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture tb of alu_tb is 
type t_test_case is record 
	i_opcode : std_logic_vector(3 downto 0);
	i_lhs : std_logic_vector(31 downto 0);
	i_rhs : std_logic_vector(31 downto 0);

	o_result : std_logic_vector(31 downto 0);
end record;

type t_test_cases is array (natural range<>) of t_test_case;

	constant c_test_cases : t_test_cases := (
	
	------ arithmatic fellas :D ------
	-- add
	("0100", x"00000002", x"00000005", x"00000007"),
	("0100", x"00000002", x"00000000", x"00000002"),

	-- multu
	("0110", x"00000002", x"00000005", x"0000000A"),
	("0110", x"00000002", x"00000000", x"00000000"),
	
	-- subtract
	("0101", x"00000000", x"00000001", x"FFFFFFFF"),
	
	------ logic sillies x3 ------
	-- and
	("1010", x"000FF000", x"000F0000", x"000F0000"),
	("1010", x"000FF000", x"000FF000", x"000FF000"),

	-- or
	("1000", x"000FF000", x"000F0000", x"000FF000"),
	("1000", x"00000000", x"000FF000", x"000FF000"),

	-- xor
	("1011", x"0000F000", x"000FF000", x"000F0000")
	
	------ Shift functions. ------
	-- im lazy, sry
);

	signal s_opcode : std_logic_vector(3 downto 0);
	signal s_lhs : std_logic_vector(31 downto 0);
	signal s_rhs : std_logic_vector(31 downto 0);

	signal s_result : std_logic_vector(31 downto 0);
begin 

	alu_inst: entity work.alu 
	port map(
		i_opcode => s_opcode,
		i_lhs => s_lhs,
		i_rhs => s_rhs,

		o_result(31 downto 0) => s_result,
		o_result(63 downto 32) => open
	);

	stim_proc: process 
	begin 
		tests: for i in c_test_cases'range loop
			s_opcode <= c_test_cases(i).i_opcode;
			s_lhs <= c_test_cases(i).i_lhs;
			s_rhs <= c_test_cases(i).i_rhs;

			wait for 20 ns;

			assert s_result = c_test_cases(i).o_result
			report "Test case " & integer'image(i) & " failed." & LF
			& "Expected: " & integer'image(to_integer(unsigned(c_test_cases(i).o_result))) & LF
			& "Got: " & integer'image(to_integer(unsigned(s_result)))
			severity error;
		end loop tests;
		
		report "All tests completed :D";
		wait;
	end process stim_proc;
	
end architecture tb;
