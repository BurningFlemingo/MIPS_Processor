library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	port(
		i_opcode : in std_logic_vector(5 downto 0); 
		i_funct : in std_logic_vector(5 downto 0); 
	
		o_alu_op : out std_logic_vector(1 downto 0);
		o_alu_src : out std_logic;
		o_mem_to_reg : out std_logic;
		o_reg_dst : out std_logic; 
		o_reg_write : out std_logic; 
		o_mem_write : out std_logic; 
		o_mem_read : out std_logic; 
		o_branch : out std_logic;
		o_invert_zero : out std_logic;
		o_alu_shift : out std_logic;
		o_hilo_write : out std_logic; 
		o_hilo_to_reg : out std_logic;
		o_hilo_word_select : out std_logic
	);
end entity control_unit;

architecture rtl of control_unit is 

	constant c_r_type : std_logic_vector(5 downto 0) := "000000";
	
	constant c_beq_op : std_logic_vector(5 downto 0) := "000100";
	constant c_bne_op : std_logic_vector(5 downto 0) := "000101";
	
	constant c_lw_op : std_logic_vector(5 downto 0) := "100011";
	constant c_sw_op : std_logic_vector(5 downto 0) := "101011";
	constant c_addi_op : std_logic_vector(5 downto 0) := "001000";
	
	constant c_sll_funct : std_logic_vector(5 downto 0) := "000000";
	constant c_sra_funct : std_logic_vector(5 downto 0) := "000011";
	constant c_srl_funct : std_logic_vector(5 downto 0) := "000010";
	constant c_multu_funct : std_logic_vector(5 downto 0) := "011001";
	
	constant c_mfhi_funct : std_logic_vector(5 downto 0) := "010000";
	constant c_mflo_funct : std_logic_vector(5 downto 0) := "010010";
	
	constant c_alu_funct : std_logic_vector(1 downto 0) := "10";
	constant c_alu_add : std_logic_vector(1 downto 0) := "00";
	constant c_alu_sub : std_logic_vector(1 downto 0) := "01";
	

	signal s_funct_is_shift : std_logic;
	signal s_funct_is_hilo_write : std_logic;
	signal s_funct_is_hilo_to_reg : std_logic;

begin 
	
	with i_funct select
		s_funct_is_shift <= '1' when c_sll_funct | c_srl_funct | c_sra_funct, 
					   '0' when others;

	with i_funct select
		s_funct_is_hilo_write <= '1' when c_multu_funct, 
						'0' when others;
	
	with i_funct select
		s_funct_is_hilo_to_reg <= '1' when c_mfhi_funct | c_mflo_funct, 
						'0' when others;

	with i_funct select 
		o_hilo_word_select <= '0' when c_mflo_funct, 
							  '1' when c_mfhi_funct, 
							  '0' when others;

	with i_opcode select
		o_alu_src <= '0' when c_r_type | c_beq_op | c_bne_op,
					 '1' when others;
	with i_opcode select
		o_mem_to_reg <= '1' when c_lw_op,
	 			 '0' when others;
	with i_opcode select
		o_reg_dst <= '1' when c_r_type,
					 '0' when others;
	with i_opcode select
		o_reg_write <= '1' when c_r_type | c_addi_op | c_lw_op,
					 '0' when others;
	with i_opcode select
		o_mem_write <= '1' when c_sw_op,
					 '0' when others;
	with i_opcode select
		o_mem_read <= '1' when c_lw_op,
					 '0' when others;

	with i_opcode select
		o_alu_op <= c_alu_funct when c_r_type, 
					c_alu_sub when c_beq_op | c_bne_op,
					c_alu_add when others;
	
	with i_opcode select 
		o_branch <= '1' when c_beq_op | c_bne_op,
					'0' when others;				 
	
	with i_opcode select 
		o_invert_zero <= '1' when c_bne_op, 
					'0' when others;				 

	with i_opcode select
		o_alu_shift <= s_funct_is_shift when c_r_type, 
					   '0' when others;
	
	with i_opcode select
		o_hilo_write <= s_funct_is_hilo_write when c_r_type, 
					   '0' when others;	
	with i_opcode select
		o_hilo_to_reg <= s_funct_is_hilo_to_reg when c_r_type, 
					   '0' when others;
		
	
end architecture rtl;
