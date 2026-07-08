-- vga_ball.vhd
-- Generatore di immagine per il gioco: disegna uno sfondo e un
-- quadratino colorato (la "pallina") in una posizione controllata
-- dalla CPU tramite due registri (X e Y).
--
-- La pallina e' un quadrato di lato BALL_SIZE pixel, il cui angolo
-- in alto a sinistra si trova alle coordinate (ball_x, ball_y).

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_ball is
    Port (
        pixel_x   : in  STD_LOGIC_VECTOR(9 downto 0);
        pixel_y   : in  STD_LOGIC_VECTOR(9 downto 0);
        video_on  : in  STD_LOGIC;
        ball_x    : in  STD_LOGIC_VECTOR(9 downto 0);
        ball_y    : in  STD_LOGIC_VECTOR(9 downto 0);
        vga_red   : out STD_LOGIC_VECTOR(3 downto 0);
        vga_green : out STD_LOGIC_VECTOR(3 downto 0);
        vga_blue  : out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity vga_ball;

architecture behavioral of vga_ball is

    constant BALL_SIZE : integer := 32;

    signal px : integer range 0 to 1023;
    signal py : integer range 0 to 1023;
    signal bx : integer range 0 to 1023;
    signal by : integer range 0 to 1023;

    signal is_ball : STD_LOGIC;
    signal color   : STD_LOGIC_VECTOR(11 downto 0);

begin

    px <= to_integer(unsigned(pixel_x));
    py <= to_integer(unsigned(pixel_y));
    bx <= to_integer(unsigned(ball_x));
    by <= to_integer(unsigned(ball_y));

    -- il pixel appartiene alla pallina se cade nel quadrato
    is_ball <= '1' when (px >= bx) and (px < bx + BALL_SIZE) and
                        (py >= by) and (py < by + BALL_SIZE)
               else '0';

    -- pallina = rosso, sfondo = blu scuro
    color <= X"F00" when is_ball = '1'
             else X"114";

    -- fuori dalla zona visibile tutto nero
    vga_red   <= color(11 downto 8) when video_on = '1' else "0000";
    vga_green <= color(7 downto 4)  when video_on = '1' else "0000";
    vga_blue  <= color(3 downto 0)  when video_on = '1' else "0000";

end architecture behavioral;
