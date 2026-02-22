library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is 
	generic (
		g_src_width : natural range 1 to 64 := 32;
		g_shift_width : natural range 1 to 8 := 4
	);
	port (
		-- sll: "00", srl: "01", sra: "11"
		
		i_opcode : in std_logic_vector(1 downto 0);
		i_src : in std_logic_vector(g_src_width-1 downto 0);
		i_shamt : in std_logic_vector(g_shift_width-1 downto 0);
		
		o_result : out std_logic_vector(g_src_width-1 downto 0)
	);
end entity shifter;

architecture rtl of shifter is 
	type t_array is array (g_src_width-1 downto 0) of std_logic_vector(g_src_width-1 downto 0);
	
	constant c_sll_op : std_logic_vector(1 downto 0) := "00";
	constant c_srl_op : std_logic_vector(1 downto 0) := "01";
	constant c_sra_op : std_logic_vector(1 downto 0) := "11";
	
	signal s_sll : t_array;
	signal s_srl : t_array;
	signal s_sra : t_array;
begin 
	s_sll(0) <= i_src;
	s_srl(0) <= i_src;
	s_sra(0) <= i_src;
		
	sll_gen: for i in 1 to g_src_width-1 generate
		s_sll(i)(g_src_width-1 downto i) <= i_src(g_src_width-1-i downto 0);
		s_sll(i)(i-1 downto 0) <= (others => '0');
	end generate;

	srl_gen: for i in 1 to g_src_width-1 generate
		s_srl(i)(g_src_width-1-i downto 0) <= i_src(g_src_width-1 downto i);
		s_srl(i)(g_src_width-1 downto g_src_width-i) <= (others => '0');
	end generate;
		
	sra_gen: for i in 1 to g_src_width-1 generate
		s_sra(i)(g_src_width-1-i downto 0) <= i_src(g_src_width-1 downto i);
		s_sra(i)(g_src_width-1 downto g_src_width-i) <= (others => i_src(g_src_width-1));
	end generate;

	with i_opcode select
		o_result <= s_sll(to_integer(unsigned(i_shamt))) when c_sll_op,
				s_srl(to_integer(unsigned(i_shamt))) when c_srl_op,
				s_sra(to_integer(unsigned(i_shamt))) when c_sra_op,
				(others => '0') when others;
end architecture rtl;
