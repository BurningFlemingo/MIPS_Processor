library ieee;
use ieee.std_logic_1164.all; 

entity instruction_ptr is 
	port (
		i_clk : in std_logic; 
		i_rst : in std_logic;
		i_pc_src : in std_logic;
		i_extended_imm : in std_logic_vector(31 downto 0);
		o_addr : out std_logic_vector(31 downto 0)
	);
end instruction_ptr;

architecture rtl of instruction_ptr is 
	signal r_pc : std_logic_vector(31 downto 0) := (others => '0');
	
	signal s_next_instruction_addr : std_logic_vector(31 downto 0);
	signal s_branch_addr : std_logic_vector(31 downto 0);

	signal s_shifted_imm : std_logic_vector(31 downto 0);
	
	signal s_new_pc : std_logic_vector(31 downto 0);
begin 
	next_instruction_adder_inst : entity work.ripple_adder
	generic map (
		g_input_size => 32
	)
	port map (
			i_opcode => '0',
			i_lhs => r_pc,
			i_rhs => (31 downto 3 => '0') & "100",
			o_sum => s_next_instruction_addr,
			o_overflowed => open 
	);

	s_shifted_imm <= i_extended_imm(31 downto 2) & "00";

	branch_adder_inst : entity work.ripple_adder
	generic map (
		g_input_size => 32
	)
	port map (
			i_opcode => '0',
			i_lhs => s_next_instruction_addr,
			i_rhs => s_shifted_imm,
			o_sum => s_branch_addr,
			o_overflowed => open 
	);

	with i_pc_src select
		s_new_pc <= s_next_instruction_addr when '0', 
					s_branch_addr when others;
	
	increment_proc: process(i_clk, i_rst)
	begin 
		if i_rst = '1' then
			r_pc <= (others => '0');
		elsif rising_edge(i_clk) then
			r_pc <= s_new_pc;
		end if;
	end process increment_proc;

	o_addr <= r_pc;
end architecture rtl;
