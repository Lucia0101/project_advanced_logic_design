library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_pattern is
    Port (
        pixel_x   : in  STD_LOGIC_VECTOR(9 downto 0);
        pixel_y   : in  STD_LOGIC_VECTOR(9 downto 0);
        video_on  : in  STD_LOGIC;
        vga_red   : out STD_LOGIC_VECTOR(3 downto 0);
        vga_green : out STD_LOGIC_VECTOR(3 downto 0);
        vga_blue  : out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity vga_pattern;

architecture behavioral of vga_pattern is
    signal color : STD_LOGIC_VECTOR(11 downto 0);
    signal banda : integer range 0 to 7;

begin
    banda <= to_integer(unsigned(pixel_x)) / 80;
    with banda select
        color <= X"000" when 0,   -- black
                 X"00F" when 1,   -- blue
                 X"0F0" when 2,   -- green
                 X"0FF" when 3,   -- light blue
                 X"F00" when 4,   -- red
                 X"F0F" when 5,   -- magenta
                 X"FF0" when 6,   -- yellow
                 X"FFF" when 7,   -- white
                 X"000" when others;
    vga_red   <= color(11 downto 8) when video_on = '1' else "0000";
    vga_green <= color(7 downto 4)  when video_on = '1' else "0000";
    vga_blue  <= color(3 downto 0)  when video_on = '1' else "0000";

end architecture behavioral;