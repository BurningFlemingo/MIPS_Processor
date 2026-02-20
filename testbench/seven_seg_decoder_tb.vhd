library ieee;
use ieee.std_logic_1164.all;

entity decoder_tb is 
end decoder_tb;

architecture tb of decoder_tb is
	signal sw_tb : std_logic_vector(3 downto 0);
	signal seg_tb : std_logic_vector(6 downto 0);

	component decoder is 
		port (
			sw : in std_logic_vector(3 downto 0);
			seg : out std_logic_vector(6 downto 0));
	end component;
begin
	uut: decoder
		port map (
			sw => sw_tb, 
			seg => seg_tb
		);
		
	stim_proc: process
		begin
			sw_tb <= "0000";
			wait for 10ns;

			sw_tb <= "0001";
			wait for 10ns;

			sw_tb <= "0010";
			wait for 10ns;
			
			sw_tb <= "0011";
			wait for 10ns;

			sw_tb <= "0100";
			wait for 10ns;

			sw_tb <= "0101";
			wait for 10ns;

			sw_tb <= "0110";
			wait for 10ns;

			sw_tb <= "0111";
			wait for 10ns;

			sw_tb <= "1000";
			wait for 10ns;

			sw_tb <= "1000";
			wait for 10ns;

			sw_tb <= "1001";
			wait for 10ns;

			sw_tb <= "1010";
			wait for 10ns;
			
			sw_tb <= "1011";
			wait for 10ns;

			sw_tb <= "1100";
			wait for 10ns;

			sw_tb <= "1101";
			wait for 10ns;

			sw_tb <= "1110";
			wait for 10ns;

			sw_tb <= "1111";
			wait for 10ns;

			wait;
		end process;
end tb;
