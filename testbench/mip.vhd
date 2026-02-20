library ieee;
use ieee.std_logic_1164.all;

entity top_tb is 
end entity top_tb; 

architecture tb of top_tb is 
	signal r_clk : std_logic := '0';
	signal r_rst : std_logic := '1';
begin

	top_inst: entity work.top
	 port map(
	    i_clk => r_clk,
	    i_rst => r_rst
	);

	reset_proc: process
	begin
		r_rst <= '0';
		wait for 30 ns;
		r_rst <= '1';
		wait for 30 ns;
		r_rst <= '0';
		wait;
	end process reset_proc;
	
	stim_proc: process
	begin

		for i in 0 to 100 loop
			r_clk <= '1';
			wait for 10 ns;

			r_clk <= '0';
			wait for 10 ns;
		end loop;

	end process stim_proc;
end architecture tb;
