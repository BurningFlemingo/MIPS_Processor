library ieee;
use ieee.std_logic_1164.all;

entity top is
	port (
		i_clk : in std_logic;
		i_n_rst : in std_logic;
		i_switches : in std_logic_vector(9 downto 0);
		o_seg : out std_logic_vector(34 downto 0)
	);
end entity top;

architecture rtl of top is 
	signal s_rst : std_logic;
	signal s_seven_seg_data : std_logic_vector(15 downto 0);

    -- INSTRUCTION FETCH STAGE SIGNALS --
	signal r_if_pc : std_logic_vector(31 downto 0);

	signal s_if_next_instruction_addr : std_logic_vector(31 downto 0);
	signal s_if_instruction : std_logic_vector(31 downto 0);

    -- INSTRUCTION DECODE STAGE SIGNALS --
	signal r_id_hilo : std_logic_vector(63 downto 0);

	signal s_id_hilo_word_data : std_logic_vector(31 downto 0);

	signal s_id_alu_src_op : std_logic;
	signal s_id_alu_op : std_logic_vector(1 downto 0);
	signal s_id_mem_to_reg_op : std_logic;
	signal s_id_reg_dst_op : std_logic; 
	signal s_id_reg_write_op : std_logic; 
	signal s_id_mem_write_op : std_logic; 
	signal s_id_mem_read_op : std_logic; 
	signal s_id_branch_op : std_logic; 
	signal s_id_invert_zero_op : std_logic; 
	signal s_id_alu_shift_op : std_logic; 
	signal s_id_hilo_write_op : std_logic; 
	signal s_id_hilo_to_reg_op : std_logic; 
	signal s_id_hilo_word_select_op : std_logic; 

	signal s_id_reg_file_read1_data : std_logic_vector(31 downto 0);
	signal s_id_reg_file_read2_data : std_logic_vector(31 downto 0);

	signal s_id_extended_imm : std_logic_vector(31 downto 0);

    signal s_id_opcode : std_logic_vector(31 downto 26);
    signal s_id_rs : std_logic_vector(25 downto 21);
    signal s_id_rt : std_logic_vector(20 downto 16);
    signal s_id_rd : std_logic_vector(15 downto 11);
    signal s_id_shamt : std_logic_vector(10 downto 6);
    signal s_id_funct : std_logic_vector(5 downto 0);

    -- EXECUTE STAGE SIGNALS --
    signal s_ex_alu_lhs_op : std_logic_vector(1 downto 0);
	signal s_ex_alu_lhs : std_logic_vector(31 downto 0);
	signal s_ex_alu_rhs : std_logic_vector(31 downto 0);

	signal s_ex_alu_control : std_logic_vector(3 downto 0);

    signal s_ex_alu_result : std_logic_vector(63 downto 0);
    signal s_ex_alu_zero : std_logic;

    signal s_ex_shifted_imm : std_logic_vector(31 downto 0);
    signal s_ex_branch_addr : std_logic_vector(31 downto 0);
    signal s_ex_reg_file_write_addr : std_logic_vector(4 downto 0);

    -- MEMORY STAGE SIGNALS --
    signal s_mem_read_data : std_logic_vector(31 downto 0);
	signal s_mem_pc_src : std_logic; 

    -- WRITE BACK STAGE SIGNALS --
	signal s_wb_result : std_logic_vector(63 downto 0);
	
    type t_ifid is record
        instruction : std_logic_vector(31 downto 0);
        next_instruction_addr : std_logic_vector(31 downto 0);
    end record;

    type t_idex is record 
        next_instruction_addr : std_logic_vector(31 downto 0);

	    alu_src_op : std_logic;
	    alu_op : std_logic_vector(1 downto 0);
	    mem_to_reg_op : std_logic;
	    reg_dst_op : std_logic; 
	    reg_write_op : std_logic; 
	    mem_write_op : std_logic; 
	    mem_read_op : std_logic; 
	    branch_op : std_logic; 
	    invert_zero_op : std_logic; 
	    alu_shift_op : std_logic; 
	    hilo_write_op : std_logic; 
	    hilo_to_reg_op : std_logic; 

	    reg_file_read1_data : std_logic_vector(31 downto 0);
	    reg_file_read2_data : std_logic_vector(31 downto 0);
	    hilo_word_data : std_logic_vector(31 downto 0);

	    extended_imm : std_logic_vector(31 downto 0);

        rt : std_logic_vector(20 downto 16);
        rd : std_logic_vector(15 downto 11);
        shamt : std_logic_vector(10 downto 6);
        funct : std_logic_vector(5 downto 0);
    end record;

    type t_exmem is record 
        branch_addr : std_logic_vector(31 downto 0);

	    mem_to_reg_op : std_logic;
	    reg_write_op : std_logic; 
	    mem_write_op : std_logic; 
	    mem_read_op : std_logic; 
	    branch_op : std_logic; 
	    invert_zero_op : std_logic; 
	    hilo_write_op : std_logic; 

	    reg_file_read2_data : std_logic_vector(31 downto 0);

	    alu_result : std_logic_vector(63 downto 0);
	    alu_zero : std_logic;

	    reg_file_write_addr : std_logic_vector(4 downto 0); 
    end record;

    type t_memwb is record 
	    mem_to_reg_op : std_logic;
	    reg_write_op : std_logic; 
	    hilo_write_op : std_logic; 

	    mem_read_data : std_logic_vector(31 downto 0);
	    alu_result : std_logic_vector(63 downto 0);

	    reg_file_write_addr : std_logic_vector(4 downto 0); 
    end record;

    constant c_ifid_noop : t_ifid := (others => (others => '0'));

    constant c_idex_noop : t_idex := (
        next_instruction_addr  => (others => '0'),

        alu_src_op             => '0',
        alu_op                 => (others => '0'),
        mem_to_reg_op          => '0',
        reg_dst_op             => '0',
        reg_write_op           => '0',
        mem_write_op           => '0',
        mem_read_op            => '0',
        branch_op              => '0',
        invert_zero_op         => '0',
        alu_shift_op           => '0',
        hilo_write_op          => '0',
        hilo_to_reg_op         => '0',

        hilo_word_data    => (others => '0'),

        reg_file_read1_data    => (others => '0'),
        reg_file_read2_data    => (others => '0'),

        extended_imm           => (others => '0'),

        rt                     => (others => '0'),
        rd                     => (others => '0'),
        shamt                     => (others => '0'),
        funct                     => (others => '0')
    );

    constant c_exmem_noop : t_exmem := (
        branch_addr           => (others => '0'),
        mem_to_reg_op         => '0',
        reg_write_op          => '0',
        mem_write_op          => '0',
        mem_read_op           => '0',
        branch_op             => '0',
        invert_zero_op        => '0',
        hilo_write_op         => '0',
        reg_file_read2_data   => (others => '0'),
        alu_result            => (others => '0'),
        alu_zero              => '0',
        reg_file_write_addr   => (others => '0')
    );
    
    constant c_memwb_noop : t_memwb := (
        mem_to_reg_op         => '0',
        reg_write_op          => '0',
        hilo_write_op         => '0',
        mem_read_data         => (others => '0'),
        alu_result            => (others => '0'),
        reg_file_write_addr   => (others => '0')
    );

    signal r_ifid : t_ifid := c_ifid_noop;
    signal r_idex : t_idex := c_idex_noop;
    signal r_exmem : t_exmem := c_exmem_noop;
    signal r_memwb : t_memwb := c_memwb_noop;

begin
	s_rst <= not i_n_rst;

	seven_seg_controller_inst: entity work.seven_seg_controller 
			port map(
				i_data => s_seven_seg_data, 
				o_seg => o_seg
		);

    -- INSTRUCTION FETCH STAGE BEGIN --
    instruction_fetch_proc: process(i_clk, s_rst) 
    begin 
        if s_rst = '1' then
            r_if_pc <= (others => '0');
            r_ifid <= c_ifid_noop;
            
        elsif rising_edge(i_clk) then 
            r_ifid.instruction <= s_if_instruction;
            r_ifid.next_instruction_addr <= s_if_next_instruction_addr;
            if s_mem_pc_src = '0' then 
                r_if_pc <= s_if_next_instruction_addr; 
            else 
                r_if_pc <= r_exmem.branch_addr; 
            end if;
        end if;
    end process;

	next_instruction_adder_inst : entity work.ripple_adder
	generic map (
		g_input_size => 32
	)
	port map (
			i_opcode => '0',
			i_lhs => r_if_pc,
			i_rhs => (31 downto 3 => '0') & "100",
			o_sum => s_if_next_instruction_addr,
			o_overflowed => open 
	);

	instruction_mem_inst: entity work.instruction_mem 
		port map (
			i_addr => r_if_pc,
			o_data => s_if_instruction
		);


    -- INSTRUCTION FETCH STAGE END --
    -- INSTRUCTION DECODE STAGE BEGIN --
    idex_pipeline_proc: process(i_clk, s_rst) 
    begin 
        if s_rst = '1' then
            r_idex <= c_idex_noop;
            r_id_hilo <= (others => '0');
        elsif rising_edge(i_clk) then 
            if r_memwb.hilo_write_op = '1' then 
                r_id_hilo <= s_wb_result; 
            end if;
            r_idex.next_instruction_addr <= r_ifid.next_instruction_addr;

            r_idex.alu_src_op <= s_id_alu_src_op;
            r_idex.alu_op <= s_id_alu_op;
            r_idex.mem_to_reg_op <= s_id_mem_to_reg_op;
            r_idex.reg_dst_op <= s_id_reg_dst_op;

	        r_idex.reg_write_op <= s_id_reg_write_op;
	        r_idex.mem_write_op <= s_id_mem_write_op;
	        r_idex.mem_read_op  <= s_id_mem_read_op;
	        r_idex.branch_op <= s_id_branch_op;
	        r_idex.invert_zero_op  <= s_id_invert_zero_op;
	        r_idex.alu_shift_op <= s_id_alu_shift_op;
	        r_idex.hilo_write_op <= s_id_hilo_write_op;
	        r_idex.hilo_to_reg_op  <= s_id_hilo_to_reg_op;
            r_idex.hilo_word_data <= s_id_hilo_word_data;

	        r_idex.reg_file_read1_data <= s_id_reg_file_read1_data;
	        r_idex.reg_file_read2_data <= s_id_reg_file_read2_data;

	        r_idex.extended_imm <= s_id_extended_imm;

            r_idex.rt <= s_id_rt;
            r_idex.rd <= s_id_rd;
            r_idex.shamt <= s_id_shamt;
            r_idex.funct <= s_id_funct;
        end if;
    end process;

    s_id_opcode <= r_ifid.instruction(31 downto 26);
    s_id_rs <= r_ifid.instruction(25 downto 21);
    s_id_rt <= r_ifid.instruction(20 downto 16);
    s_id_rd <= r_ifid.instruction(15 downto 11);
    s_id_shamt <= r_ifid.instruction(10 downto 6);
    s_id_funct <= r_ifid.instruction(5 downto 0);

	sign_extend_inst: entity work.sign_extend
	 port map(
	    i_signed_data => r_ifid.instruction(15 downto 0),
	    o_signed_data => s_id_extended_imm
	);

	control_unit_inst: entity work.control_unit
	 port map(
	    i_opcode => s_id_opcode,
		i_funct => s_id_funct,
		o_alu_op => s_id_alu_op,
	    o_alu_src_op => s_id_alu_src_op,
	    o_mem_to_reg_op => s_id_mem_to_reg_op,
	    o_reg_dst_op => s_id_reg_dst_op,
	    o_reg_write_op => s_id_reg_write_op,
	    o_mem_write_op => s_id_mem_write_op,
	    o_mem_read_op => s_id_mem_read_op,
	    o_branch_op => s_id_branch_op,
		o_invert_zero_op => s_id_invert_zero_op,
		o_alu_shift_op => s_id_alu_shift_op,
		o_hilo_write_op => s_id_hilo_write_op, 
		o_hilo_to_reg_op => s_id_hilo_to_reg_op,
		o_hilo_word_select_op => s_id_hilo_word_select_op
	);
	
	with s_id_hilo_word_select_op select
		s_id_hilo_word_data <= r_id_hilo(31 downto 0) when '0', 
							r_id_hilo(63 downto 32) when others;

	reg_file_inst: entity work.reg_file
	 port map(
	    i_clk => i_clk,
		i_rst => s_rst,
	    i_read1_addr => r_ifid.instruction(25 downto 21),
	    i_read2_addr => r_ifid.instruction(20 downto 16),
	    i_write_addr => r_memwb.reg_file_write_addr,
	    i_write_data => s_wb_result(31 downto 0),
	    i_reg_write =>  r_memwb.reg_write_op,
	    o_read1_data => s_id_reg_file_read1_data,
	    o_read2_data => s_id_reg_file_read2_data
	);

    -- INSTRUCTION DECODE STAGE END --
    -- EXECUTE STAGE BEGIN --
    ex_pipeline_proc: process(i_clk, s_rst) 
    begin 
        if s_rst = '1' then
            r_exmem <= c_exmem_noop;
        elsif rising_edge(i_clk) then 
            r_exmem.branch_addr <= s_ex_branch_addr;
            
            r_exmem.mem_to_reg_op <= r_idex.mem_to_reg_op;
	        r_exmem.reg_write_op  <= r_idex.reg_write_op;
	        r_exmem.mem_write_op <= r_idex.mem_write_op;
	        r_exmem.mem_read_op  <= r_idex.mem_read_op;
	        r_exmem.branch_op  <= r_idex.branch_op;
	        r_exmem.invert_zero_op  <= r_idex.invert_zero_op;
	        r_exmem.hilo_write_op  <= r_idex.hilo_write_op;

	        r_exmem.reg_file_read2_data <= r_idex.reg_file_read2_data;

	        r_exmem.alu_result <= s_ex_alu_result;
	        r_exmem.alu_zero <= s_ex_alu_zero;

	        r_exmem.reg_file_write_addr  <= s_ex_reg_file_write_addr;
        end if;
    end process;

	with r_idex.alu_src_op select
		s_ex_alu_rhs <= r_idex.reg_file_read2_data when '0', 
					 r_idex.extended_imm when others;

    s_ex_shifted_imm <= r_idex.extended_imm(29 downto 0) & "00";

    ripple_adder_inst: entity work.ripple_adder
     generic map(
        g_input_size => 32
    )
     port map(
        i_opcode => '0',
        i_lhs => r_idex.next_instruction_addr,
        i_rhs => s_ex_shifted_imm,
        o_sum => s_ex_branch_addr,
        o_overflowed => open
    );

	-- shamt goes in lhs since rs isnt used for shift instructions
    s_ex_alu_lhs_op <= r_idex.alu_shift_op & r_idex.hilo_to_reg_op;
	with s_ex_alu_lhs_op select
		s_ex_alu_lhs <= r_idex.reg_file_read1_data when "00", 
                     r_idex.hilo_word_data when "01",
					 (31 downto 5 => '0') & r_idex.shamt when "10",
                     (others => '0') when others;

	alu_control_unit_inst: entity work.alu_control_unit 
		port map(
			i_alu_op => r_idex.alu_op, 
			i_funct => r_idex.funct, 
			o_alu_control => s_ex_alu_control
		);

	alu_inst: entity work.alu
	 port map(
	    i_opcode => s_ex_alu_control,
	    i_lhs => s_ex_alu_lhs,
	    i_rhs => s_ex_alu_rhs,
	    o_result => s_ex_alu_result, 
		o_zero => s_ex_alu_zero
	);

    s_ex_reg_file_write_addr <= r_idex.rt when r_idex.reg_dst_op = '0' else r_idex.rd;

    -- EXECUTE STAGE END --
    -- MEM STAGE BEGIN --

    mem_pipeline_proc: process(i_clk, s_rst) 
    begin 
        if s_rst = '1' then
            r_memwb <= c_memwb_noop;
        elsif rising_edge(i_clk) then 
            r_memwb.mem_to_reg_op <= r_exmem.mem_to_reg_op;
            r_memwb.reg_write_op <= r_exmem.reg_write_op;
            r_memwb.hilo_write_op <= r_exmem.hilo_write_op;

            r_memwb.mem_read_data <= s_mem_read_data;
            r_memwb.alu_result <= r_exmem.alu_result;
            r_memwb.reg_file_write_addr <= r_exmem.reg_file_write_addr;
        end if;
    end process;

	data_mem: entity work.mem_bus
		port map (
			i_clk => i_clk,
            i_rst => s_rst,
			
			i_mem_write => r_exmem.mem_write_op, 
			i_mem_read => r_exmem.mem_read_op,
			
			i_addr => r_exmem.alu_result(31 downto 0),
			i_data => r_exmem.reg_file_read2_data,
			
			i_switches => i_switches, 
			
			o_data => s_mem_read_data,
			o_seven_seg => s_seven_seg_data
		);

	s_mem_pc_src <= r_exmem.branch_op and (r_exmem.alu_zero xor r_exmem.invert_zero_op);


    -- MEM STAGE END --
    -- WRITE BACK STAGE BEGIN --

	with r_memwb.mem_to_reg_op select
		s_wb_result <= (63 downto 32 => '0')& r_memwb.mem_read_data when '1', 
					   r_memwb.alu_result when others;
    -- WRITE BACK STAGE END --

end architecture rtl;
