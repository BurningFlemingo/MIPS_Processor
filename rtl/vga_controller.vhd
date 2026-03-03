library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is 
	port (
		i_50MHz_clk : in std_logic;
		i_rst : in std_logic;

		i_r : in std_logic_vector(3 downto 0);
		i_g : in std_logic_vector(3 downto 0);
		i_b : in std_logic_vector(3 downto 0);
	
		o_r : out std_logic_vector(3 downto 0);
		o_g : out std_logic_vector(3 downto 0);
		o_b : out std_logic_vector(3 downto 0);

		o_x : out integer;
		o_y : out integer;

		o_vs : out std_logic; 
		o_hs : out std_logic
	
	);
end entity vga_controller;

architecture rtl of vga_controller is 
	-- timing constants for 640x480@60Hz. Requires a 25.175MHz pixel clock
	-- but 25MHz is fine
	constant c_px_in_hav : integer := 640; -- hav is horizontal active video
	constant c_px_in_hfp : integer := 16; -- hfp is horizontal front porch
	constant c_px_in_hs : integer := 96; -- hs is sync pulse
	
	constant c_lines_in_vav : integer := 480;
	constant c_lines_in_vfp : integer := 10;
	constant c_lines_in_vs : integer := 2;

	constant c_hs_px_start : integer := c_px_in_hav + c_px_in_hfp;
	constant c_vs_line_start : integer := c_lines_in_vav + c_lines_in_vfp;

	constant c_px_per_scanline : integer := 800;
	constant c_lines_per_frame : integer := 525;
	
	signal r_px_counter : integer := 0;
	signal r_line_counter : integer := 0;

	signal r_clk_en : std_logic := '0';
	signal s_active_video : std_logic;
	
begin 
	o_hs <= '0' when r_px_counter >= c_hs_px_start and r_px_counter < c_hs_px_start+c_px_in_hs else '1';
	o_vs <= '0' when r_line_counter >= c_vs_line_start and r_line_counter < c_vs_line_start+c_lines_in_vs else '1';
	
	s_active_video <= '1' when r_px_counter < c_px_in_hav and r_line_counter < c_lines_in_vav else '0';

	o_r <= i_r when s_active_video = '1' else "0000";
	o_g <= i_g when s_active_video = '1' else "0000";
	o_b <= i_b when s_active_video = '1' else "0000";

	o_x <= r_px_counter when s_active_video = '1' else 0;
	o_y <= r_line_counter when s_active_video = '1' else 0;
	
	process(i_50MHz_clk, i_rst)
	begin
		if i_rst = '0' then
			r_px_counter <= 0;
			r_line_counter <= 0;
			
			r_clk_en <= '0';
		elsif rising_edge(i_50MHz_clk) then
			r_clk_en <= not r_clk_en;

			if r_clk_en = '1' then 
				if r_px_counter < c_px_per_scanline-1 then
					r_px_counter <= r_px_counter + 1;
				else 
					if r_line_counter < c_lines_per_frame-1 then 
						r_line_counter <= r_line_counter + 1;
					else 
						r_line_counter <= 0;
					end if;
						
					r_px_counter <= 0;
				end if;
			end if;
		end if;
	end process;
	
end architecture rtl;
