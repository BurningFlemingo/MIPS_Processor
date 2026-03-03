library ieee; 
use ieee.std_logic_1164.all; 

entity seven_seg_controller is 
	port (
		i_data : in std_logic_vector(15 downto 0);

		o_seg : out std_logic_vector(34 downto 0)
	);
end entity seven_seg_controller;

architecture rtl of seven_seg_controller is 
	type t_bcd_arr is array (natural range<>) of std_logic_vector(3 downto 0);
	signal s_bcd : t_bcd_arr(0 to 4);
begin 

	binary_to_bcd_inst: entity work.binary_to_bcd
	port map(
		i_binary => i_data, 
		o_ones => s_bcd(0), 
		o_tens => s_bcd(1), 
		o_hundreds => s_bcd(2),
		o_thousands => s_bcd(3), 
		o_ten_thousands => s_bcd(4)
	);

	decoder_gen: for i in 0 to 4 generate 
		seven_seg_decoder_inst_ones: entity work.seven_seg_decoder
		port map(
			i_bcd => s_bcd(i), 
			o_seg => o_seg((i*7) + 6 downto i*7)
		);

	end generate;
	
end architecture rtl;
