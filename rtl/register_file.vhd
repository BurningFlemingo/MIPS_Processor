library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
	port(
		i_clk : in std_logic;
		i_rst : in std_logic;
	
		i_read1_addr : in std_logic_vector(4 downto 0);
		i_read2_addr : in std_logic_vector(4 downto 0);
		i_write_addr : in std_logic_vector(4 downto 0);
		i_write_data : in std_logic_vector(31 downto 0);
	
		i_reg_write : in std_logic;
	
		o_read1_data : out std_logic_vector(31 downto 0);
		o_read2_data : out std_logic_vector(31 downto 0)
	);
end entity reg_file;

architecture rtl of reg_file is 
	type t_register is array (31 downto 0) of std_logic_vector(31 downto 0);
	
	signal r_register_file : t_register := (others => (others => '0'));
begin

	process(i_clk, i_rst)
	begin 
		if i_rst = '1' then 
			for i in 0 to 31 loop 
				r_register_file(i) <= (others => '0');
			end loop;
		elsif rising_edge(i_clk) then
			if i_reg_write = '1' then 
				r_register_file(to_integer(unsigned(i_write_addr))) <= i_write_data;
			end if;
		end if;
	end process;

	with i_read1_addr select 
		o_read1_data <= (31 downto 0 => '0') when "00000", 
						r_register_file(to_integer(unsigned(i_read1_addr))) when others;
	with i_read2_addr select 
		o_read2_data <= (31 downto 0 => '0') when "00000", 
						r_register_file(to_integer(unsigned(i_read2_addr))) when others;
end architecture rtl;
