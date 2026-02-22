library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_tb is 
end entity multiplier_tb;

architecture tb of multiplier_tb is 
type t_test_case is record 
	i_a : std_logic_vector(15 downto 0);
	i_b : std_logic_vector(15 downto 0);
	
	o_expected : std_logic_vector(31 downto 0);
end record;

	type t_test_case_array is array (natural range <>) of t_test_case;
	constant c_test_cases : t_test_case_array := (
	    (x"0000", x"0000", x"00000000"),
	    (x"0000", x"FFFF", x"00000000"),
		
	    (x"0001", x"0001", x"00000001"),
	    (x"0001", x"FFFF", x"0000FFFF"),
	    (x"FFFF", x"0001", x"0000FFFF"),
	    (x"FFFF", x"FFFF", x"FFFE0001"),
		
	    (x"0002", x"0002", x"00000004"),
	    (x"0100", x"0100", x"00010000"),
	    (x"8000", x"0002", x"00010000"),
		
	    (x"0003", x"0005", x"0000000F"),
	    (x"00FF", x"00FF", x"0000FE01"),
	    (x"1234", x"5678", x"06260060"),
		
	    (x"FFFF", x"0002", x"0001FFFE"),
	    (x"ABCD", x"1234", x"0C374FA4"),
	    (x"1234", x"ABCD", x"0C374FA4")
	);

	signal s_a : std_logic_vector(15 downto 0);
	signal s_b : std_logic_vector(15 downto 0);
	
	signal s_result : std_logic_vector(31 downto 0);
begin
	multiplier_inst: entity work.multiplier
	 generic map(
	    g_n => 32
	)
	 port map(
	    i_a => s_a,
	    i_b => s_b,
	    o_result => s_result
	);
	stim_proc: process 
	begin
		for i in c_test_cases'range loop
			s_a <= c_test_cases(i).i_a;
			s_b <= c_test_cases(i).i_b;

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
