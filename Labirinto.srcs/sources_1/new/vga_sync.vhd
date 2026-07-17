-- vga_sync.vhd
-- Generatore di sincronismi VGA 640x480 @ 60 Hz
-- Genera hsync, vsync, le coordinate del pixel corrente e il segnale video_on
--
-- Timing standard VGA 640x480 @ 60 Hz:
--   Pixel clock: 25 MHz (100 MHz / 4)
--   Orizzontale: 640 visibili + 16 front + 96 sync + 48 back = 800 totali
--   Verticale:   480 visibili + 10 front +  2 sync + 33 back = 525 totali
--   
-- Polarita' dei sincronismi per 640x480@60: hsync e vsync ATTIVI BASSI

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_sync is
    Port (
        clk       : in  STD_LOGIC;   -- clock di sistema (100 MHz)
        rst       : in  STD_LOGIC;

        -- uscite di sincronismo verso il monitor
        hsync     : out STD_LOGIC;
        vsync     : out STD_LOGIC;

        -- coordinate del pixel corrente (validi solo se video_on = '1')
        pixel_x   : out STD_LOGIC_VECTOR(9 downto 0);  -- 0..639
        pixel_y   : out STD_LOGIC_VECTOR(9 downto 0);  -- 0..479

        -- '1' quando siamo nella zona visibile dello schermo
        video_on  : out STD_LOGIC
    );
end entity vga_sync;

architecture behavioral of vga_sync is

    -- ============= COSTANTI DI TIMING ORIZZONTALE =============
    constant H_VISIBLE : integer := 640;   -- pixel visibili
    constant H_FRONT   : integer := 16;    -- front porch
    constant H_SYNC    : integer := 96;    -- sync pulse
    constant H_BACK    : integer := 48;    -- back porch
    constant H_TOTAL   : integer := 800;   -- totale (640+16+96+48)

    -- ============= COSTANTI DI TIMING VERTICALE =============
    constant V_VISIBLE : integer := 480;   -- righe visibili
    constant V_FRONT   : integer := 10;    -- front porch
    constant V_SYNC    : integer := 2;     -- sync pulse
    constant V_BACK    : integer := 33;    -- back porch
    constant V_TOTAL   : integer := 525;   -- totale (480+10+2+33)

    -- ============= GENERAZIONE PIXEL CLOCK 25 MHz =============
    -- dividiamo il clock 100 MHz per 4 usando un contatore
    signal clk_div   : unsigned(1 downto 0) := (others => '0');
    signal pixel_tick : STD_LOGIC;   -- impulso a 25 MHz

    -- ============= CONTATORI DI POSIZIONE =============
    signal h_count : unsigned(9 downto 0) := (others => '0');  -- 0..799
    signal v_count : unsigned(9 downto 0) := (others => '0');  -- 0..524

    -- segnali interni
    signal video_on_int : STD_LOGIC;

begin

    -- ============= DIVISORE DI CLOCK (100 -> 25 MHz) =============
    process(clk, rst)
    begin
        if rst = '1' then
            clk_div <= (others => '0');
        elsif rising_edge(clk) then
            clk_div <= clk_div + 1;
        end if;
    end process;

    -- pixel_tick e' alto un ciclo ogni 4 (quando clk_div torna a 0)
    pixel_tick <= '1' when clk_div = "11" else '0';

    -- ============= CONTATORI ORIZZONTALE E VERTICALE =============
    process(clk, rst)
    begin
        if rst = '1' then
            h_count <= (others => '0');
            v_count <= (others => '0');

        elsif rising_edge(clk) then
            -- avanziamo solo al ritmo del pixel clock (25 MHz)
            if pixel_tick = '1' then

                -- contatore orizzontale
                if h_count = H_TOTAL - 1 then
                    h_count <= (others => '0');

                    -- fine riga: avanza il contatore verticale
                    if v_count = V_TOTAL - 1 then
                        v_count <= (others => '0');
                    else
                        v_count <= v_count + 1;
                    end if;
                else
                    h_count <= h_count + 1;
                end if;

            end if;
        end if;
    end process;

    -- ============= GENERAZIONE SINCRONISMI =============
    -- hsync attivo basso durante la fase di sync orizzontale
    -- la fase sync inizia dopo visible + front porch
    hsync <= '0' when (h_count >= H_VISIBLE + H_FRONT) and
                      (h_count <  H_VISIBLE + H_FRONT + H_SYNC)
             else '1';

    -- vsync attivo basso durante la fase di sync verticale
    vsync <= '0' when (v_count >= V_VISIBLE + V_FRONT) and
                      (v_count <  V_VISIBLE + V_FRONT + V_SYNC)
             else '1';

    -- ============= ZONA VISIBILE =============
    -- video_on = '1' solo quando siamo dentro l'area 640x480
    video_on_int <= '1' when (h_count < H_VISIBLE) and (v_count < V_VISIBLE)
                    else '0';
    video_on <= video_on_int;

    -- ============= COORDINATE DEL PIXEL =============
    -- validi solo dentro la zona visibile
    pixel_x <= STD_LOGIC_VECTOR(h_count) when video_on_int = '1'
               else (others => '0');
    pixel_y <= STD_LOGIC_VECTOR(v_count) when video_on_int = '1'
               else (others => '0');

end architecture behavioral;