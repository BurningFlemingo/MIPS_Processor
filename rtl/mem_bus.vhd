library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_bus is 
	port (
		i_clk : in std_logic;
		i_rst : in std_logic;
	
		i_mem_write : in std_logic;
		i_mem_read : in std_logic;
	
		i_addr : in std_logic_vector(31 downto 0);
		i_data : in std_logic_vector(31 downto 0);
		
		i_switches : in std_logic_vector(9 downto 0);
	
		o_data : out std_logic_vector(31 downto 0);
		o_seven_seg : out std_logic_vector(15 downto 0)
		 );
end entity mem_bus;

architecture rtl of mem_bus is 
	constant c_word_size : natural := 4;
	
	constant c_mm_seg_display_addr : integer := 0;
	constant c_mm_seg_display_size : integer := 4/c_word_size;
	
	constant c_mm_switches_addr : integer := 4/c_word_size;
	constant c_mm_switches_size : integer := 4/c_word_size;

	constant c_mm_framebuffer_addr : integer := 8/c_word_size;
	-- 640x480 resolution, 4bits per pixel
	constant c_mm_framebuffer_size : integer := (640*480/2)/c_word_size;

	constant c_mm_main_mem_addr : integer := (153608)/c_word_size;
	constant c_mm_main_mem_size : integer := 16/c_word_size;

	signal s_addr_seg_display : std_logic;
	signal s_addr_switches : std_logic;
	signal s_addr_framebuffer : std_logic;
	signal s_addr_main_mem : std_logic;
	
	signal s_word_addr : std_logic_vector(29 downto 0);

	signal s_read_ram : std_logic;
	signal s_write_ram : std_logic;
	signal s_ram_addr : std_logic_vector(14 downto 0);
	
	signal s_ram_data : std_logic_vector(31 downto 0);
	signal s_addr_offset : integer;

    signal r_seven_seg : std_logic_vector(15 downto 0);
    signal r_switches : std_logic_vector(9 downto 0);
begin 
    o_seven_seg <= r_seven_seg;

	s_word_addr <= i_addr(31 downto 2);

	ram_inst: entity work.ram
	 port map(
	    address => s_ram_addr,
	    clock => i_clk,
	    data => i_data,
	    rden => s_read_ram,
	    wren => s_write_ram,
	    q => s_ram_data
	);

	s_addr_seg_display <= '1'
						  when to_integer(unsigned(s_word_addr)) < c_mm_seg_display_addr + c_mm_seg_display_size
						  else '0';
		
	s_addr_switches <= '1'
					   when to_integer(unsigned(s_word_addr)) >= c_mm_switches_addr
					   and to_integer(unsigned(s_word_addr)) < c_mm_switches_addr + c_mm_switches_size
					   else '0';
		
	s_addr_framebuffer <= '1'
					   when to_integer(unsigned(s_word_addr)) >= c_mm_framebuffer_addr 
					   and to_integer(unsigned(s_word_addr)) < c_mm_framebuffer_addr + c_mm_framebuffer_size
					   else '0';

	s_addr_main_mem <= '1'
					   when to_integer(unsigned(s_word_addr)) >= c_mm_main_mem_addr
					   and to_integer(unsigned(s_word_addr)) < c_mm_main_mem_addr + c_mm_main_mem_size
					   else '0';
		
		
	s_addr_offset <= to_integer(unsigned(s_word_addr)) - c_mm_main_mem_addr when s_addr_main_mem = '1'
					 else to_integer(unsigned(s_word_addr)) - c_mm_framebuffer_addr when s_addr_framebuffer = '1' 
					 else to_integer(unsigned(s_word_addr)) - c_mm_switches_addr when s_addr_switches = '1'
					 else to_integer(unsigned(s_word_addr)) - c_mm_seg_display_addr when s_addr_seg_display = '1' 
					 else 0;

	s_read_ram <= i_mem_read and (s_addr_main_mem or s_addr_framebuffer);
	s_write_ram <= i_mem_write and (s_addr_main_mem or s_addr_framebuffer);

	s_ram_addr <= std_logic_vector(to_unsigned(s_addr_offset, 15));

	write_proc: process(i_clk, i_rst) 
	begin 
        if i_rst = '1' then 
		elsif rising_edge(i_clk) then
            r_switches <= i_switches;

			if i_mem_write = '1' and s_addr_seg_display = '1' then 
				r_seven_seg <= i_data(15 downto 0);
            end if;
		end if;
	end process write_proc;

    o_data <= s_ram_data when s_addr_main_mem = '1' or s_addr_framebuffer = '1' else 
              (31 downto 10 => '0') & r_switches when s_addr_switches = '1' else 
              (others => '0');


end architecture rtl;
