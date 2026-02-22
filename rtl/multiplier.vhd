library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is 
	generic (
		g_n : natural := 32
	);
	port (
		i_a : in std_logic_vector((g_n/2)-1 downto 0);
		i_b : in std_logic_vector((g_n/2)-1 downto 0);

		o_result : out std_logic_vector(g_n-1 downto 0)
	);
end entity multiplier;

architecture rtl of multiplier is 

	constant c_data_width : natural := (g_n/2);
	constant c_row_count : natural := c_data_width - 1;

	-- partial products
	type t_data_array is array (natural range <>) of std_logic_vector(c_data_width-1 downto 0);
	signal s_ba : t_data_array(c_data_width-1 downto 0);

	signal s_adder_lhs : t_data_array(c_row_count-1 downto 0);
	signal s_adder_rhs : t_data_array(c_row_count-1 downto 0);
	signal s_adder_carry_in : t_data_array(c_row_count-1 downto 0);
	
	signal s_adder_sum : t_data_array(c_row_count-1 downto 0);
	signal s_adder_carry_out : t_data_array(c_row_count-1 downto 0);
begin 

	partial_product_rows_gen: for i in 0 to c_data_width-1 generate 
		partial_product_columns_gen: for j in 0 to c_data_width-1 generate 
			s_ba(i)(j) <= i_b(i) and i_a(j);
		end generate;
	end generate;

	adders_row_gen: for i in 0 to c_row_count-1 generate
		adders_gen: for j in 0 to c_data_width-1 generate 
			full_adder_inst: entity work.full_adder 
				port map (
					i_lhs => s_adder_lhs(i)(j),
					i_rhs => s_adder_rhs(i)(j),
					i_carry_in => s_adder_carry_in(i)(j),
					o_sum => s_adder_sum(i)(j),
					o_carry_out => s_adder_carry_out(i)(j)
				);
		end generate;
	end generate;

	
	-- first row shennanigans 
	s_adder_lhs(0)(0) <= s_ba(0)(1);
	s_adder_rhs(0)(0) <= s_ba(1)(0);
	s_adder_carry_in(0)(0) <= '0';

	s_adder_lhs(0)(c_data_width-1) <= '0';
	s_adder_rhs(0)(c_data_width-1) <= s_ba(1)(c_data_width-1);
	s_adder_carry_in(0)(c_data_width-1) <= s_ba(2)(c_data_width-2);

	-- 1 and c_data_width-2 because we alr did 0 and c_data_width-1 above
	row_one_adder_signal_gen: for i in 1 to c_data_width-2 generate 
		s_adder_lhs(0)(i) <= s_ba(0)(i+1);
		s_adder_rhs(0)(i) <= s_ba(1)(i);
		s_adder_carry_in(0)(i) <= s_ba(2)(i-1);
	end generate;

	-- 1 and c_row_count-2 because we did row 1 above, and the last row is the ripple carry, so we go to second to last
	middle_rows_gen: for i in 1 to c_row_count-2 generate 
			-- first one
			s_adder_carry_in(i)(0) <= s_adder_carry_out(i-1)(0);
			s_adder_lhs(i)(0) <= s_adder_sum(i-1)(1);
			s_adder_rhs(i)(0) <= '0';

			-- last one
			s_adder_carry_in(i)(c_data_width-1) <= s_adder_carry_out(i-1)(c_data_width-1);
			s_adder_lhs(i)(c_data_width-1) <= s_ba(i+1)(c_data_width-1);
			s_adder_rhs(i)(c_data_width-1) <= s_ba(i+2)(c_data_width-2);
		
		middle_adder_signal_gen: for j in 1 to c_data_width-2 generate 
			s_adder_carry_in(i)(j) <= s_adder_carry_out(i-1)(j);
			s_adder_lhs(i)(j) <= s_adder_sum(i-1)(j+1);
			s_adder_rhs(i)(j) <= s_ba(i+2)(j-1);
		end generate;
	end generate;

	-- more silly special cases
	s_adder_carry_in(c_row_count-1)(0) <= '0';
	s_adder_lhs(c_row_count-1)(0) <= s_adder_sum(c_row_count-2)(1);
	s_adder_rhs(c_row_count-1)(0) <= s_adder_carry_out(c_row_count-2)(0);

	s_adder_carry_in(c_row_count-1)(c_data_width-1) <= s_adder_carry_out(c_row_count-1)(c_data_width-2);
	s_adder_lhs(c_row_count-1)(c_data_width-1) <= s_ba(c_data_width-1)(c_data_width-1);
	s_adder_rhs(c_row_count-1)(c_data_width-1) <= s_adder_carry_out(c_row_count-2)(c_data_width-1);
	
	final_row_gen: for i in 1 to c_data_width-2 generate
		s_adder_carry_in(c_row_count-1)(i) <= s_adder_carry_out(c_row_count-1)(i-1);
		s_adder_lhs(c_row_count-1)(i) <= s_adder_sum(c_row_count-2)(i + 1);
		s_adder_rhs(c_row_count-1)(i) <= s_adder_carry_out(c_row_count-2)(i);
	end generate;
	

	o_result(0) <= s_ba(0)(0);
	o_result(g_n-1) <= s_adder_carry_out(c_row_count-1)(c_data_width-1);

	consolidate_middle_adders_gen: for i in 1 to c_data_width-2 generate
		o_result(i) <= s_adder_sum(i-1)(0);
	end generate;

	consolidate_final_row_adders_gen: for i in c_data_width-1 to g_n-2 generate
		o_result(i) <= s_adder_sum(c_row_count-1)(i-(c_data_width-1));
	end generate;

end architecture rtl;
