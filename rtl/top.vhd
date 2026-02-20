library ieee;
use ieee.std_logic_1164.all;

entity top is
	port (
		i_clk : in std_logic;
		i_rst : in std_logic
		-- i_button : in std_logic;
		-- o_hex : out std_logic_vector(27 downto 0)
	);
end entity top;

architecture rtl of top is 
	signal s_pc : std_logic_vector(31 downto 0);
	
	signal s_instruction : std_logic_vector(31 downto 0);
	
	signal s_extended_imm : std_logic_vector(31 downto 0);
	
	-- control signals
	signal s_alu_src : std_logic;
	signal s_alu_op : std_logic_vector(1 downto 0);
	signal s_mem_to_reg : std_logic;
	signal s_reg_dst : std_logic; 
	signal s_reg_write : std_logic; 
	signal s_mem_write : std_logic; 
	signal s_mem_read : std_logic; 
	signal s_branch : std_logic; 
	
	signal s_pc_src : std_logic; 

	signal s_reg_file_read1_data : std_logic_vector(31 downto 0);
	signal s_reg_file_read2_data : std_logic_vector(31 downto 0);

	signal s_wb_result : std_logic_vector(31 downto 0);
	
	signal s_alu_rhs : std_logic_vector(31 downto 0);
	signal s_alu_sum : std_logic_vector(31 downto 0);
	signal s_alu_zero : std_logic;

	signal s_mem_read_data : std_logic_vector(31 downto 0);

	signal s_reg_file_write_addr : std_logic_vector(4 downto 0); 

	signal s_alu_control : std_logic_vector(3 downto 0);

	signal s_pc_bcd_ones : std_logic_vector(3 downto 0);
	signal s_pc_bcd_tens : std_logic_vector(3 downto 0);

	-- signal s_wb_bcd_ones : std_logic_vector(3 downto 0);
	-- signal s_wb_bcd_tens : std_logic_vector(3 downto 0);
begin

	bcd_digits_inst1: entity work.binary_to_bcd 
	port map (
		i_binary => s_pc(15 downto 0),
		o_ones => s_pc_bcd_ones, 
		o_tens => s_pc_bcd_tens
	);
	-- bcd_digits_inst2: entity work.binary_to_bcd 
	-- port map (
	-- 	i_binary => s_wb_result(3 downto 0),
	-- 	o_ones => s_wb_bcd_ones, 
	-- 	o_tens => s_wb_bcd_tens
	-- );

	-- seg_inst1: entity work.seven_seg_decoder 
	-- port map (
	-- 	i_bcd => s_pc_bcd_ones,
	-- 	o_seg => o_hex(6 downto 0)
	-- );

	-- seg_inst2: entity work.seven_seg_decoder 
	-- port map (
	-- 	i_bcd => s_pc_bcd_tens,
	-- 	o_seg => o_hex(13 downto 7)
	-- );

	-- seg_inst3: entity work.seven_seg_decoder 
	-- port map (
	-- 	i_bcd => s_wb_bcd_ones,
	-- 	o_seg => o_hex(20 downto 14)
	-- );

	-- seg_inst4: entity work.seven_seg_decoder 
	-- port map (
	-- 	i_bcd => s_wb_bcd_tens,
	-- 	o_seg => o_hex(27 downto 21)
	-- );

	s_pc_src <= s_alu_zero and s_branch;

	instruction_ptr_inst: entity work.instruction_ptr
	 port map(
	    i_clk => i_clk,
		i_rst => i_rst,
		i_pc_src => s_pc_src,
		i_extended_imm => s_extended_imm,
	    o_addr => s_pc
	);

	instruction_mem_inst: entity work.instruction_mem 
		port map (
			i_addr => s_pc, 
			o_data => s_instruction
		);

	sign_extend_inst: entity work.sign_extend
	 port map(
	    i_signed_data => s_instruction(15 downto 0),
	    o_signed_data => s_extended_imm
	);

	control_unit_inst: entity work.control_unit
	 port map(
	    i_opcode => s_instruction(31 downto 26),
		o_alu_op => s_alu_op,
	    o_alu_src => s_alu_src,
	    o_mem_to_reg => s_mem_to_reg,
	    o_reg_dst => s_reg_dst,
	    o_reg_write => s_reg_write,
	    o_mem_write => s_mem_write,
	    o_mem_read => s_mem_read,
	    o_branch => s_branch
	);

	with s_reg_dst select
		s_reg_file_write_addr <= s_instruction(15 downto 11) when '1', 
								 s_instruction(20 downto 16) when others;

	reg_file_inst: entity work.reg_file
	 port map(
	    i_clk => i_clk,
		i_rst => i_rst,
	    i_read1_addr => s_instruction(25 downto 21),
	    i_read2_addr => s_instruction(20 downto 16),
	    i_write_addr => s_reg_file_write_addr,
	    i_write_data => s_wb_result,
	    i_reg_write =>  s_reg_write,
	    o_read1_data => s_reg_file_read1_data,
	    o_read2_data => s_reg_file_read2_data
	);


	with s_alu_src select
		s_alu_rhs <= s_reg_file_read2_data when '0', 
					 s_extended_imm when others;

	alu_control_unit_inst: entity work.alu_control_unit 
		port map(
			i_alu_op => s_alu_op, 
			i_funct => s_instruction(5 downto 0), 
			o_alu_control => s_alu_control
		);

	alu_inst: entity work.alu
	 port map(
	    i_opcode => s_alu_control,
	    i_lhs => s_reg_file_read1_data,
	    i_rhs => s_alu_rhs,
	    o_result => s_alu_sum,
	    o_zero => s_alu_zero
	);

	data_mem: entity work.data_mem
		port map (
			i_clk => i_clk,
			i_mem_write => s_mem_write, 
			i_mem_read => s_mem_read,
			i_addr => s_alu_sum,
			i_data => s_reg_file_read2_data,
			o_data => s_mem_read_data 
		);

	with s_mem_to_reg select
		s_wb_result <= s_mem_read_data when '1', 
								 s_alu_sum when others;


end architecture rtl;
