library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_top_tb is
end entity vga_top_tb;

architecture sim of vga_top_tb is

    signal clk       : STD_LOGIC := '0';
    signal rst       : STD_LOGIC := '1';
    signal vga_hsync : STD_LOGIC;
    signal vga_vsync : STD_LOGIC;
    signal vga_red   : STD_LOGIC_VECTOR(3 downto 0);
    signal vga_green : STD_LOGIC_VECTOR(3 downto 0);
    signal vga_blue  : STD_LOGIC_VECTOR(3 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    function rgb_str(r, g, b : STD_LOGIC_VECTOR(3 downto 0)) return string is
    begin
        return "R=" & integer'image(to_integer(unsigned(r)))
             & " G=" & integer'image(to_integer(unsigned(g)))
             & " B=" & integer'image(to_integer(unsigned(b)));
    end function;

begin
    DUT: entity work.vga_top
        port map (
            clk       => clk,
            rst       => rst,
            vga_hsync => vga_hsync,
            vga_vsync => vga_vsync,
            vga_red   => vga_red,
            vga_green => vga_green,
            vga_blue  => vga_blue
        );
    clk <= not clk after CLK_PERIOD / 2;
    stimoli: process
    begin
        rst <= '1';
        wait for CLK_PERIOD * 4;
        rst <= '0';
        report "=== Reset rilasciato ===";
        wait for 40 * 40 ns;
        report "Banda 0 (atteso nero):    " & rgb_str(vga_red, vga_green, vga_blue);
        wait for 80 * 40 ns;
        report "Banda 1 (atteso blu):     " & rgb_str(vga_red, vga_green, vga_blue);
        wait for 80 * 40 ns;
        report "Banda 2 (atteso verde):   " & rgb_str(vga_red, vga_green, vga_blue);
        wait for 80 * 40 ns;
        report "Banda 3 (atteso ciano):   " & rgb_str(vga_red, vga_green, vga_blue);
        wait for 80 * 40 ns;
        report "Banda 4 (atteso rosso):   " & rgb_str(vga_red, vga_green, vga_blue);
        wait for 80 * 40 ns;
        report "Banda 5 (atteso magenta): " & rgb_str(vga_red, vga_green, vga_blue);
        wait for 80 * 40 ns;
        report "Banda 6 (atteso giallo):  " & rgb_str(vga_red, vga_green, vga_blue);
        wait for 80 * 40 ns;
        report "Banda 7 (atteso bianco):  " & rgb_str(vga_red, vga_green, vga_blue);

        report "=== TEST COMPLETATO ===";
        report "Verifica che i colori corrispondano alle bande attese";
        wait;

    end process;
end architecture sim;