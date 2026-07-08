-- vga_pattern.vhd
-- Generatore di pattern di test per VGA
-- Disegna 8 bande verticali colorate sullo schermo 640x480
--
-- Riceve le coordinate del pixel corrente dal vga_sync e produce
-- i valori RGB (4 bit per canale) da inviare al monitor.
-- Fuori dalla zona visibile forza il nero (obbligatorio per il VGA).

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_pattern is
    Port (
        -- ingressi dal vga_sync
        pixel_x   : in  STD_LOGIC_VECTOR(9 downto 0);
        pixel_y   : in  STD_LOGIC_VECTOR(9 downto 0);
        video_on  : in  STD_LOGIC;

        -- uscite RGB verso il monitor (4 bit per canale)
        vga_red   : out STD_LOGIC_VECTOR(3 downto 0);
        vga_green : out STD_LOGIC_VECTOR(3 downto 0);
        vga_blue  : out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity vga_pattern;

architecture behavioral of vga_pattern is

    -- colore corrente calcolato in base alla banda
    signal color : STD_LOGIC_VECTOR(11 downto 0);  -- formato RRRRGGGGBBBB

    -- indice della banda (0..7), calcolato da pixel_x
    signal banda : integer range 0 to 7;

begin

    -- ============= CALCOLO DELLA BANDA =============
    -- ogni banda e' larga 80 pixel (640 / 8 = 80)
    -- banda = pixel_x / 80
    banda <= to_integer(unsigned(pixel_x)) / 80;

    -- ============= SELEZIONE DEL COLORE =============
    -- in base alla banda scegliamo il colore (formato R G B, 4 bit ciascuno)
    with banda select
        color <= X"000" when 0,   -- nero
                 X"00F" when 1,   -- blu
                 X"0F0" when 2,   -- verde
                 X"0FF" when 3,   -- ciano
                 X"F00" when 4,   -- rosso
                 X"F0F" when 5,   -- magenta
                 X"FF0" when 6,   -- giallo
                 X"FFF" when 7,   -- bianco
                 X"000" when others;

    -- ============= USCITE RGB =============
    -- fuori dalla zona visibile TUTTO deve essere nero
    vga_red   <= color(11 downto 8) when video_on = '1' else "0000";
    vga_green <= color(7 downto 4)  when video_on = '1' else "0000";
    vga_blue  <= color(3 downto 0)  when video_on = '1' else "0000";

end architecture behavioral;