library ieee;
use ieee.std_logic_1164.all;

entity alu is 
	port (
		i_opcode : in std_logic_vector(3 downto 0);
		i_lhs : in std_logic_vector(31 downto 0);
		i_rhs : in std_logic_vector(31 downto 0);

		o_result : out std_logic_vector(63 downto 0);
		o_zero : out std_logic
	);
end entity alu;

architecture rtl of alu is
	-- higher order bits
	constant c_arith : std_logic_vector(1 downto 0) := "01";
	constant c_logic : std_logic_vector(1 downto 0) := "10";
	constant c_shift : std_logic_vector(1 downto 0) := "11";

	-- lower order bits
	constant c_add : std_logic_vector(1 downto 0) := "00";
	constant c_sub : std_logic_vector(1 downto 0) := "01";
	constant c_multu : std_logic_vector(1 downto 0) := "10";
	constant c_slt : std_logic_vector(1 downto 0) := "11";
	
	constant c_and : std_logic_vector(1 downto 0) := "10";
	constant c_or : std_logic_vector(1 downto 0) := "00";
	constant c_xor : std_logic_vector(1 downto 0) := "11";

	signal s_sum : std_logic_vector(31 downto 0);
	signal s_and : std_logic_vector(31 downto 0);
	signal s_multu : std_logic_vector(63 downto 0);
	signal s_or : std_logic_vector(31 downto 0);
	signal s_xor : std_logic_vector(31 downto 0);

	signal s_arith : std_logic_vector(31 downto 0);
	signal s_logic : std_logic_vector(31 downto 0);
	signal s_shift : std_logic_vector(31 downto 0);
	
	-- lower and higher word
	signal s_result_lw : std_logic_vector(31 downto 0); 
	signal s_result_hw : std_logic_vector(31 downto 0); 
begin 
	
	adder_inst: entity work.ripple_adder 
		generic map(
			g_input_size => 32
		)
		port map(
			i_opcode => i_opcode(0),
			i_lhs => i_lhs,
			i_rhs => i_rhs, 
			o_sum => s_sum,
			o_overflowed => open
	);

	multiplier_inst: entity work.multiplier
	 generic map(
		g_n => 64
	)
	 port map(
	    i_a => i_lhs,
	    i_b => i_rhs,
	    o_result => s_multu
	);

	shifter_inst: entity work.shifter
	 generic map(
	    g_src_width => 32,
	    g_shift_width => 5
	)
	 port map(
	    i_opcode => i_opcode(1 downto 0),
		-- shamt goes in thru lhs, src operand is rhs
	    i_src => i_rhs,
	    i_shamt => i_lhs(4 downto 0),
	    o_result => s_shift
	);
	
	s_or <= i_lhs or i_rhs;
	s_and <= i_lhs and i_rhs;
	s_xor <= i_lhs xor i_rhs;

	with i_opcode(1 downto 0) select 
		s_arith <= s_multu(31 downto 0) when c_multu, 
				   s_sum when c_add | c_sub,
				   (31 downto 1 => '0') & s_sum(31) when c_slt,
				   (others => '0') when others;

	with i_opcode(1 downto 0) select 
		s_logic <= s_and when c_and, 
				   s_or when c_or, 
				   s_xor when c_xor, 
				   (others => '0') when others;

	with i_opcode(3 downto 2) select 
		s_result_lw <= s_arith when c_arith, 
					s_logic when c_logic, 
					s_shift when c_shift,
				   (others => '0') when others;

	with i_opcode(3 downto 0) select 
		s_result_hw <= s_multu(63 downto 32) when c_arith & c_multu, 
					   (others => '0') when others;
	
	o_result <= s_result_hw & s_result_lw;
	
	o_zero <= '1' when s_result_lw = (61 downto 0 => '0') else '0';
	
		
end architecture rtl;
