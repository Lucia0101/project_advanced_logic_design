-- vga_ball.vhd
-- Rendering del LABIRINTO v4: muri lunghi e connessi, 3 vicoli ciechi.
--   - PALLINA: cerchio rosso (raggio 10)
--   - 10 MURI grigi agganciati a L/T (nessuna fessura)
--   - 6 BUCHI: cerchi neri (raggio 25) a varie altezze
--   - TRAGUARDO: rettangolo verde (550-620, 400-460)
-- Coordinate IDENTICHE al firmware.

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
    signal px, py : signed(11 downto 0);
    constant BALL_R : integer := 10;
    signal ball_cx, ball_cy : signed(11 downto 0);
    signal bdx, bdy : signed(11 downto 0);
    signal ball_dist2 : signed(23 downto 0);
    signal pallina : std_logic;
    
    constant HOLE_R : integer := 25;
    signal h1dx, h1dy, h2dx, h2dy, h3dx, h3dy : signed(11 downto 0);
    signal h4dx, h4dy, h5dx, h5dy, h6dx, h6dy : signed(11 downto 0);
    signal h1_d2, h2_d2, h3_d2, h4_d2, h5_d2, h6_d2 : signed(23 downto 0);
    signal buco : std_logic;
    
    signal muro      : std_logic;
    signal traguardo : std_logic;

begin
    -- 1. Risoluzione coordinate correnti
    px <= signed(resize(unsigned(pixel_x), 12));
    py <= signed(resize(unsigned(pixel_y), 12));
    
    -- 2. Logica della Pallina
    ball_cx <= signed(resize(unsigned(ball_x), 12)) + BALL_R;
    ball_cy <= signed(resize(unsigned(ball_y), 12)) + BALL_R;
    bdx <= px - ball_cx;
    bdy <= py - ball_cy;
    ball_dist2 <= bdx * bdx + bdy * bdy;
    pallina <= '1' when ball_dist2 <= (BALL_R * BALL_R) else '0';

    -- 3. Logica dei Buchi (Spostati per non toccare i muri)
    h1dx <= px - to_signed( 60, 12);
    h1dy <= py - to_signed(250, 12);
    h1_d2 <= h1dx * h1dx + h1dy * h1dy;
    
    h2dx <= px - to_signed(220, 12);
    h2dy <= py - to_signed(230, 12);
    h2_d2 <= h2dx * h2dx + h2dy * h2dy;
    
    -- SPOSTATO: prima era X=350, Y=75. Ora e' staccato dal muro centrale e alto
    h3dx <= px - to_signed(375, 12); 
    h3dy <= py - to_signed( 60, 12);
    h3_d2 <= h3dx * h3dx + h3dy * h3dy;
    
    -- SPOSTATO in zona larga (nel fondo): al centro della colonna
    -- da 80 px bloccava completamente il passaggio
    h4dx <= px - to_signed(150, 12);
    h4dy <= py - to_signed(420, 12);
    h4_d2 <= h4dx * h4dx + h4dy * h4dy;
    
    -- SPOSTATO nella zona finale davanti al traguardo (slalom finale):
    -- al centro della tasca da 80 px bloccava il passaggio
    h5dx <= px - to_signed(600, 12);
    h5dy <= py - to_signed(170, 12);
    h5_d2 <= h5dx * h5dx + h5dy * h5dy;
    
    h6dx <= px - to_signed(390, 12);
    h6dy <= py - to_signed(420, 12);
    h6_d2 <= h6dx * h6dx + h6dy * h6dy;
    
    buco <= '1' when (h1_d2 <= (HOLE_R * HOLE_R) or
                      h2_d2 <= (HOLE_R * HOLE_R) or
                      h3_d2 <= (HOLE_R * HOLE_R) or
                      h4_d2 <= (HOLE_R * HOLE_R) or
                      h5_d2 <= (HOLE_R * HOLE_R) or
                      h6_d2 <= (HOLE_R * HOLE_R)) else '0';

    -- 4. Logica dei Muri (labirinto a soluzione unica)
   muro <= '1' when
        ((unsigned(pixel_x) <  80 and unsigned(pixel_y) >= 160 and unsigned(pixel_y) < 180) or
         (unsigned(pixel_x) >= 120 and unsigned(pixel_x) < 140 and unsigned(pixel_y) >=  80 and unsigned(pixel_y) < 200) or
         (unsigned(pixel_x) >= 120 and unsigned(pixel_x) < 140 and unsigned(pixel_y) >= 260 and unsigned(pixel_y) < 360) or
         (unsigned(pixel_x) >= 140 and unsigned(pixel_x) < 340 and unsigned(pixel_y) >= 340 and unsigned(pixel_y) < 360) or
         (unsigned(pixel_x) >= 320 and unsigned(pixel_x) < 340 and unsigned(pixel_y) >= 100 and unsigned(pixel_y) < 340) or
         (unsigned(pixel_x) >= 440 and unsigned(pixel_x) < 460 and unsigned(pixel_y) < 140) or
         (unsigned(pixel_x) >= 440 and unsigned(pixel_x) < 460 and unsigned(pixel_y) >= 200) or
         (unsigned(pixel_x) >= 220 and unsigned(pixel_x) < 440 and unsigned(pixel_y) >= 100 and unsigned(pixel_y) < 120) or
         (unsigned(pixel_x) >= 540 and unsigned(pixel_x) < 560 and unsigned(pixel_y) < 120) or
         (unsigned(pixel_x) >= 540 and unsigned(pixel_x) < 560 and unsigned(pixel_y) >= 200 and unsigned(pixel_y) < 380) or
         (unsigned(pixel_x) >= 560 and unsigned(pixel_y) >= 240 and unsigned(pixel_y) < 260) or
         (unsigned(pixel_x) >= 240 and unsigned(pixel_x) < 260 and unsigned(pixel_y) <  50) or
         (unsigned(pixel_x) >= 260 and unsigned(pixel_x) < 280 and unsigned(pixel_y) >= 420))
        else '0';
    -- 5. Logica del Traguardo
    traguardo <= '1' when (unsigned(pixel_x) >= 570 and unsigned(pixel_x) < 630 and
                           unsigned(pixel_y) >= 400 and unsigned(pixel_y) < 460)
                 else '0';

    -- 6. Processo di colorazione VGA
    process(video_on, pallina, buco, muro, traguardo)
    begin
        if video_on = '0' then
            vga_red   <= "0000";
            vga_green <= "0000";
            vga_blue  <= "0000";
        elsif pallina = '1' then
            vga_red   <= "1111";   -- Pallina rossa
            vga_green <= "0000";
            vga_blue  <= "0000";
        elsif buco = '1' then
            vga_red   <= "0000";   -- Buchi neri
            vga_green <= "0000";
            vga_blue  <= "0000";
        elsif muro = '1' then
            vga_red   <= "1000";   -- Muri grigi
            vga_green <= "1000";
            vga_blue  <= "1000";
        elsif traguardo = '1' then
            vga_red   <= "0000";   -- Traguardo verde brillante
            vga_green <= "1111";
            vga_blue  <= "0000";
        else
            vga_red   <= "0000";   -- Sfondo blu scuro
            vga_green <= "0000";
            vga_blue  <= "1000";
        end if;
    end process;
end architecture behavioral;