library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter_tb is 
end entity shifter_tb;

architecture tb of shifter_tb is 
type t_test_case is record 
	i_opcode : std_logic_vector(1 downto 0);
	i_src : std_logic_vector(7 downto 0);
	i_shamt : std_logic_vector(2 downto 0);
	
	o_expected : std_logic_vector(7 downto 0);
end record;

	type t_test_case_array is array (natural range <>) of t_test_case;
	constant c_test_cases : t_test_case_array := (
		("00", "00000001", "000", "00000001"),
		("00", "00000001", "001", "00000010"),
		("00", "00000001", "111", "10000000"),

		("01", "10000000", "000", "10000000"),
		("01", "10000000", "001", "01000000"),
		("01", "10000000", "111", "00000001"),

		("11", "10000000", "000", "10000000"),
		("11", "10000000", "001", "11000000"),
		("11", "01000000", "001", "00100000"),
		("11", "10000000", "111", "11111111"),
		("11", "01000000", "111", "00000000")
	);

	signal s_opcode : std_logic_vector(1 downto 0);
	signal s_src : std_logic_vector(7 downto 0);
	signal s_shamt : std_logic_vector(2 downto 0);
	signal s_result : std_logic_vector(7 downto 0);
begin
	shifter_inst: entity work.shifter
	 generic map(
	    g_src_width => 8,
	    g_shift_width => 3
	)
	 port map(
	    i_opcode => s_opcode,
	    i_src => s_src,
	    i_shamt => s_shamt,
	    o_result => s_result
	);
	stim_proc: process 
	begin
		for i in c_test_cases'range loop
			s_opcode <= c_test_cases(i).i_opcode;
			s_src <= c_test_cases(i).i_src;
			s_shamt <= c_test_cases(i).i_shamt;

			wait for 20 ns;

			assert s_result = c_test_cases(i).o_expected
			report "Test case " & integer'image(i) & " failed." & LF
			& "Expected: " & integer'image(to_integer(unsigned(c_test_cases(i).o_expected))) & LF
			& "Got: " & integer'image(to_integer(unsigned(s_result)))
			severity error;
		end loop;

		report "All tests completed :D";
		
		wait;
	end process;
end architecture tb;
