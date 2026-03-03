library ieee;
use ieee.std_logic_1164.all;

entity top_tb is 
end entity top_tb; 

architecture tb of top_tb is 
		signal s_clk : std_logic;
		signal s_rst : std_logic;
		signal s_switches : std_logic_vector(9 downto 0);
		signal s_seg : std_logic_vector(34 downto 0);

begin
	s_switches <= "0000000010";

	top_inst: entity work.top
	 port map(
	    i_clk => s_clk,
	    i_rst => s_rst, 
		i_switches => s_switches, 
		o_seg => s_seg
	);

	reset_proc: process
	begin
		s_rst <= '1';
		wait for 30 ns;
		s_rst <= '0';
		wait for 30 ns;
		s_rst <= '1';
		wait;
	end process reset_proc;
	
	stim_proc: process
	begin

		for i in 0 to 100 loop
			s_clk <= '1';
			wait for 10 ns;

			s_clk <= '0';
			wait for 10 ns;
		end loop;

		wait;

	end process stim_proc;
end architecture tb;
