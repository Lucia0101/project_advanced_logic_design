library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gpio_tb is
end entity gpio_tb;

architecture sim of gpio_tb is
    signal clk      : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '1';
    signal addr     : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal wr_data  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal rd_data  : STD_LOGIC_VECTOR(31 downto 0);
    signal wr_en    : STD_LOGIC := '0';
    signal switches : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal buttons  : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal leds     : STD_LOGIC_VECTOR(15 downto 0);
    signal seg      : STD_LOGIC_VECTOR(6 downto 0);
    signal an       : STD_LOGIC_VECTOR(7 downto 0);
    signal dp       : STD_LOGIC;
    constant CLK_PERIOD : time := 10 ns;
    
begin

    DUT: entity work.gpio
        port map (
            clk      => clk,
            rst      => rst,
            addr     => addr,
            wr_data  => wr_data,
            rd_data  => rd_data,
            wr_en    => wr_en,
            switches => switches,
            buttons  => buttons,
            leds     => leds,
            seg      => seg,
            an       => an,
            dp       => dp
        );

    clk <= not clk after CLK_PERIOD / 2;

    stimoli: process
    begin
        rst <= '1';
        wait for CLK_PERIOD * 4;
        rst <= '0';
        report "=== Reset rilasciato ===";

        switches <= X"A5A5"; 
        addr     <= "0000";
        wait for CLK_PERIOD;
        assert rd_data = X"0000A5A5"
            report "ERRORE lettura switch" severity error;
        report "TEST 1 - Lettura switch (0xA5A5): OK";

        buttons <= "10101";
        addr    <= "0100"; 
        wait for CLK_PERIOD;
        assert rd_data = X"00000015"
            report "ERRORE lettura pulsanti" severity error;
        report "TEST 2 - Lettura pulsanti (0x15): OK";

        addr    <= "1000";    
        wr_data <= X"0000FFFF";
        wr_en   <= '1';
        wait for CLK_PERIOD;
        wr_en   <= '0';
        wait for CLK_PERIOD;
        assert leds = X"FFFF"
            report "ERRORE scrittura LED" severity error;
        report "TEST 3 - Scrittura LED (0xFFFF): OK";

        addr    <= "1000";
        wr_data <= X"00001234";
        wr_en   <= '1';
        wait for CLK_PERIOD;
        wr_en   <= '0';
        wait for CLK_PERIOD;
        assert leds = X"1234"
            report "ERRORE scrittura LED parziale" severity error;
        report "TEST 4 - Scrittura LED (0x1234): OK";

        addr    <= "1100";    
        wr_data <= X"DEADBEEF";
        wr_en   <= '1';
        wait for CLK_PERIOD;
        wr_en   <= '0';
        wait for CLK_PERIOD;
        report "TEST 5 - Scrittura display (0xDEADBEEF): OK";
        report "  (il valore sara' mostrato sul display multiplexato)";

        report "=== TEST COMPLETATI ===";
        wait;

    end process;
end architecture sim;