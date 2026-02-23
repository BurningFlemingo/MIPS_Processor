library ieee;
use ieee.std_logic_1164.all; 

entity alu_control_unit is
	port (
		i_alu_op : in std_logic_vector(1 downto 0); 
		i_funct : in std_logic_vector(5 downto 0);

		o_alu_control : out std_logic_vector(3 downto 0)
	);
end entity alu_control_unit;

architecture rtl of alu_control_unit is
	constant c_add_funct : std_logic_vector(5 downto 0) := "100000";
	constant c_sub_funct : std_logic_vector(5 downto 0) := "100010";
	constant c_multu_funct : std_logic_vector(5 downto 0) := "011001";
	
	constant c_and_funct : std_logic_vector(5 downto 0) := "100100";
	constant c_or_funct : std_logic_vector(5 downto 0) := "100101";
	constant c_xor_funct : std_logic_vector(5 downto 0) := "100110";
	
	constant c_sll_funct : std_logic_vector(5 downto 0) := "000000";
	constant c_sra_funct : std_logic_vector(5 downto 0) := "000011";
	constant c_srl_funct : std_logic_vector(5 downto 0) := "000010";

	constant c_slt_func : std_logic_vector(5 downto 0) := "101010";

	signal s_decoded_funct : std_logic_vector(3 downto 0);
begin
	with i_funct(5 downto 0) select 
		s_decoded_funct <= "0100" when c_add_funct,
						   "0101" when c_sub_funct,
						   "0110" when c_multu_funct,
						   "0111" when c_slt_func, 
						   
						   "1010" when c_and_funct,
						   "1000" when c_or_funct,
						   "1011" when c_xor_funct,
						   
						   "1100" when c_sll_funct,
						   "1101" when c_srl_funct,
						   "1111" when c_sra_funct, 
						   
						   "0000" when others;
	
	with i_alu_op select
		o_alu_control <= "0100" when "00", 
						 "0101" when "01", 
						 s_decoded_funct when "10",
						 "0000" when others;

	
end architecture rtl;
