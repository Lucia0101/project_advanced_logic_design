library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_sync_tb is
end entity vga_sync_tb;

architecture sim of vga_sync_tb is

    signal clk      : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '1';
    signal hsync    : STD_LOGIC;
    signal vsync    : STD_LOGIC;
    signal pixel_x  : STD_LOGIC_VECTOR(9 downto 0);
    signal pixel_y  : STD_LOGIC_VECTOR(9 downto 0);
    signal video_on : STD_LOGIC;
    constant CLK_PERIOD : time := 10 ns;
    signal hsync_count : integer := 0;
    signal vsync_count : integer := 0;
    signal hsync_prev  : STD_LOGIC := '1';
    signal vsync_prev  : STD_LOGIC := '1';

begin

    DUT: entity work.vga_sync
        port map (
            clk      => clk,
            rst      => rst,
            hsync    => hsync,
            vsync    => vsync,
            pixel_x  => pixel_x,
            pixel_y  => pixel_y,
            video_on => video_on
        );

    clk <= not clk after CLK_PERIOD / 2;

    contatore: process(clk)
    begin
        if rising_edge(clk) then
            if hsync_prev = '1' and hsync = '0' then
                hsync_count <= hsync_count + 1;
            end if;
            hsync_prev <= hsync;
            if vsync_prev = '1' and vsync = '0' then
                vsync_count <= vsync_count + 1;
            end if;
            vsync_prev <= vsync;
        end if;
    end process;

    stimoli: process
    begin
        -- reset
        rst <= '1';
        wait for CLK_PERIOD * 4;
        rst <= '0';
        report "=== Reset rilasciato, inizio generazione VGA ===";

        wait for 17 ms;

        report "Impulsi HSYNC contati: " & integer'image(hsync_count);
        report "Impulsi VSYNC contati: " & integer'image(vsync_count);

        assert hsync_count >= 520
            report "ERRORE: troppi pochi impulsi HSYNC (attesi ~525 per frame)"
            severity error;

        assert vsync_count >= 1
            report "ERRORE: nessun impulso VSYNC osservato"
            severity error;

        report "=== TEST COMPLETATO ===";
        report "Se HSYNC ~525 e VSYNC >=1, i timing sono corretti!";
        wait;

    end process;
end architecture sim;