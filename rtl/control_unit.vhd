library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	port(
		i_opcode : in std_logic_vector(5 downto 0); 
	
		o_alu_op : out std_logic_vector(1 downto 0);
		o_alu_src : out std_logic;
		o_mem_to_reg : out std_logic;
		o_reg_dst : out std_logic; 
		o_reg_write : out std_logic; 
		o_mem_write : out std_logic; 
		o_mem_read : out std_logic; 
		o_branch : out std_logic
	);
end entity control_unit;

architecture rtl of control_unit is 
begin 

	with i_opcode select
		o_alu_src <= '0' when "000000", 
					 not i_opcode(2) when others;
	with i_opcode select
		o_mem_to_reg <= '1' when "100011",
	 			 '0' when others;
	with i_opcode select
		o_reg_dst <= '1' when "000000",
					 '0' when others;
	with i_opcode select
		o_reg_write <= '1' when "000000" | "001000" | "100011",
					 '0' when others;
	with i_opcode select
		o_mem_write <= '1' when "101011",
					 '0' when others;
	with i_opcode select
		o_mem_read <= '1' when "100011",
					 '0' when others;

	with i_opcode select
		o_alu_op <= "10" when "000000", 
					"01" when "000100", 
					"00" when others;
	
	o_branch <= i_opcode(2);
					 
		
	
end architecture rtl;
