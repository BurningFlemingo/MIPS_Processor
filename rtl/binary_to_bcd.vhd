library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_to_bcd is 
	port (
		i_binary : in std_logic_vector(15 downto 0);
		o_ones : out std_logic_vector(3 downto 0) := "0000";
		o_tens : out std_logic_vector(3 downto 0) := "0000"
	);
end entity binary_to_bcd;

architecture rtl of binary_to_bcd is 
	signal s_bcd_ones : std_logic_vector(3 downto 0);
	signal s_bcd_tens : std_logic_vector(3 downto 0);
begin 
	process(i_binary)
		variable v_bcd : unsigned(19 downto 0) := (others => '0');
	begin
		v_bcd := (others => '0');
		
		for i in 15 downto 0 loop
			for j in 0 to 3 loop 
				if v_bcd((j*4)+3 downto j*4) > 4 then
					v_bcd((j*4)+3 downto j*4) := v_bcd((j*4)+3 downto j*4) + 3;
				end if;
			end loop;
			
			v_bcd := v_bcd(18 downto 0) & i_binary(i);
		end loop;
		
	s_bcd_ones <= std_logic_vector(v_bcd(3 downto 0));
	s_bcd_tens <= std_logic_vector(v_bcd(7 downto 4));
	end process;

	o_ones <= s_bcd_ones;
	o_tens <= s_bcd_tens;

	
end architecture rtl;
