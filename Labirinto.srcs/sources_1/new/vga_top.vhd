-- vga_top.vhd
-- Top-level del sottosistema VGA
-- Collega il generatore di sincronismi (vga_sync) con il
-- generatore di pattern colorato (vga_pattern)
--
-- Questo modulo e' pronto per essere collegato ai pin fisici della
-- Nexys 4 DDR tramite il file di constraints.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vga_top is
    Port (
        clk       : in  STD_LOGIC;   -- clock di sistema 100 MHz
        rst       : in  STD_LOGIC;

        -- uscite verso il connettore VGA della Nexys 4 DDR
        vga_hsync : out STD_LOGIC;
        vga_vsync : out STD_LOGIC;
        vga_red   : out STD_LOGIC_VECTOR(3 downto 0);
        vga_green : out STD_LOGIC_VECTOR(3 downto 0);
        vga_blue  : out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity vga_top;

architecture structural of vga_top is

    -- segnali interni che collegano sync e pattern
    signal pixel_x_int  : STD_LOGIC_VECTOR(9 downto 0);
    signal pixel_y_int  : STD_LOGIC_VECTOR(9 downto 0);
    signal video_on_int : STD_LOGIC;

begin

    -- ============= GENERATORE DI SINCRONISMI =============
    SYNC_inst: entity work.vga_sync
        port map (
            clk      => clk,
            rst      => rst,
            hsync    => vga_hsync,
            vsync    => vga_vsync,
            pixel_x  => pixel_x_int,
            pixel_y  => pixel_y_int,
            video_on => video_on_int
        );

    -- ============= GENERATORE DI PATTERN =============
    PATTERN_inst: entity work.vga_pattern
        port map (
            pixel_x   => pixel_x_int,
            pixel_y   => pixel_y_int,
            video_on  => video_on_int,
            vga_red   => vga_red,
            vga_green => vga_green,
            vga_blue  => vga_blue
        );

end architecture structural;