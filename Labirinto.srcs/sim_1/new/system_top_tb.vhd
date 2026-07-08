-- system_top_tb.vhd
-- Testbench per il system_top completo (CPU + GPIO + SPI + VGA)
-- Verifica:
--   - LED (GPIO)
--   - transazione SPI
--   - registri di posizione della pallina (VGA)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity system_top_tb is
end entity system_top_tb;

architecture sim of system_top_tb is

    signal clk      : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '1';
    signal switches : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal buttons  : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal leds     : STD_LOGIC_VECTOR(15 downto 0);
    signal seg      : STD_LOGIC_VECTOR(6 downto 0);
    signal an       : STD_LOGIC_VECTOR(7 downto 0);
    signal dp       : STD_LOGIC;

    signal spi_sclk : STD_LOGIC;
    signal spi_mosi : STD_LOGIC;
    signal spi_miso : STD_LOGIC := '0';
    signal spi_cs_n : STD_LOGIC;

    signal vga_hsync : STD_LOGIC;
    signal vga_vsync : STD_LOGIC;
    signal vga_red   : STD_LOGIC_VECTOR(3 downto 0);
    signal vga_green : STD_LOGIC_VECTOR(3 downto 0);
    signal vga_blue  : STD_LOGIC_VECTOR(3 downto 0);

    signal debug_pc    : STD_LOGIC_VECTOR(31 downto 0);
    signal debug_instr : STD_LOGIC_VECTOR(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    -- Byte fittizio che l'accelerometro simulato invierà alla CPU
    constant SLAVE_BYTE : STD_LOGIC_VECTOR(7 downto 0) := X"A5";
    signal slave_shift  : STD_LOGIC_VECTOR(7 downto 0) := SLAVE_BYTE;

begin

    DUT: entity work.system_top
        port map (
            clk         => clk,
            rst         => rst,
            switches    => switches,
            buttons     => buttons,
            leds        => leds,
            seg         => seg,
            an          => an,
            dp          => dp,
            spi_sclk    => spi_sclk,
            spi_mosi    => spi_mosi,
            spi_miso    => spi_miso,
            spi_cs_n    => spi_cs_n,
            vga_hsync   => vga_hsync,
            vga_vsync   => vga_vsync,
            vga_red     => vga_red,
            vga_green   => vga_green,
            vga_blue    => vga_blue,
            debug_pc    => debug_pc,
            debug_instr => debug_instr
        );

    -- Generazione continua del clock
    clk <= not clk after CLK_PERIOD / 2;

    -- Slave SPI finto per simulare la risposta dell'accelerometro
    slave: process(spi_sclk, spi_cs_n)
    begin
        if falling_edge(spi_cs_n) then
            spi_miso    <= SLAVE_BYTE(7);
            slave_shift <= SLAVE_BYTE(6 downto 0) & '0';
        elsif rising_edge(spi_cs_n) then
            spi_miso    <= '0';
            slave_shift <= SLAVE_BYTE;
        elsif falling_edge(spi_sclk) then
            spi_miso    <= slave_shift(7);
            slave_shift <= slave_shift(6 downto 0) & '0';
        end if;
    end process slave;

    stimoli: process
    begin
        -- Reset iniziale per sincronizzare la CPU
        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';
        
        report "=== Reset rilasciato, la CPU inizia a eseguire il firmware del gioco ===";
        report "=== Lasciare scorrere la simulazione (es. Run for 1 ms) e osservare la waveform! ===";

        -- La CPU è ora completamente autonoma e bloccata nel ciclo while(1) del C.
        -- Sospendiamo questo processo in modo pulito e definitivo.
        wait;
    end process;

end architecture sim;