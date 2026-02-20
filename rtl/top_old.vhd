library ieee;
use ieee.std_logic_1164.all;

entity top is
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;
		i_switches : in std_logic_vector(7 downto 0); 
		o_hex : out std_logic_vector(41 downto 0)
	);
end entity top;

architecture rtl of top is 
	type t_bcd_digits is array (0 to 5) of std_logic_vector(3 downto 0);
	
	signal s_bcd_digits : t_bcd_digits;
	signal s_sum : std_logic_vector(3 downto 0);

	signal s_instruction_address : std_logic_vector(31 downto 0);
	signal s_instruction : std_logic_vector(31 downto 0);
begin
	ip_inst: entity work.instruction_ptr 
		port map(
			i_clk => i_clk, 
			o_addr => s_instruction_address
		);
	fetch_inst: entity work.fetch 
		port map(
			i_addr => s_instruction_address, 
			o_data => s_instruction
		);
		
	bcd_digits_inst_lhs: entity work.binary_to_bcd 
	port map (
		i_binary => s_instruction(31 downto 28),
		o_ones => s_bcd_digits(0), 
		o_tens => s_bcd_digits(1)
	);

	bcd_digits_inst_rhs: entity work.binary_to_bcd 
	port map (
		i_binary => i_switches(7 downto 4),
		o_ones => s_bcd_digits(2), 
		o_tens => s_bcd_digits(3)
	);


	bcd_digits_inst_sum: entity work.binary_to_bcd 
		port map (
			i_binary => s_sum, 
			o_ones => s_bcd_digits(4), 
			o_tens => s_bcd_digits(5)
		);

	gen_seg_decoders: for i in 0 to 5 generate
		seg_inst: entity work.seven_seg_decoder 
			port map (
				i_bcd => s_bcd_digits(i),
				o_seg => o_hex(((i+1)*7-1) downto i*7)
			);
	end generate gen_seg_decoders;



		
	adder_inst: entity work.ripple_adder
		generic map (
			g_input_size => 4
		)
		port map (
			i_lhs => i_switches(3 downto 0),
			i_rhs => i_switches(7 downto 4),
			i_carry_in => '0',
			o_sum => s_sum,
			o_overflowed => open
		);

end architecture rtl;
