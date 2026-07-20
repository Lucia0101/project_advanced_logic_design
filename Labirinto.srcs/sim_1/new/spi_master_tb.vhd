library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master_tb is
end entity spi_master_tb;

architecture sim of spi_master_tb is
    signal clk      : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '1';
    signal start    : STD_LOGIC := '0';
    signal tx_data  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rx_data  : STD_LOGIC_VECTOR(7 downto 0);
    signal busy     : STD_LOGIC;
    signal done     : STD_LOGIC;
    signal spi_sclk : STD_LOGIC;
    signal spi_mosi : STD_LOGIC;
    signal spi_miso : STD_LOGIC := '0';
    signal spi_cs_n : STD_LOGIC;
    constant CLK_PERIOD : time := 10 ns;
    constant TEST_CLK_DIV : positive := 2;
    constant SLAVE_BYTE : STD_LOGIC_VECTOR(7 downto 0) := X"A5";
    signal slave_shift : STD_LOGIC_VECTOR(7 downto 0) := SLAVE_BYTE;

begin
    DUT: entity work.spi_master
        generic map (
            CLK_DIV => TEST_CLK_DIV
        )
        port map (
            clk      => clk,
            rst      => rst,
            start    => start,
            tx_data  => tx_data,
            rx_data  => rx_data,
            busy     => busy,
            done     => done,
            spi_sclk => spi_sclk,
            spi_mosi => spi_mosi,
            spi_miso => spi_miso,
            spi_cs_n => spi_cs_n
        );
    clk <= not clk after CLK_PERIOD / 2;
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
        rst <= '1';
        wait for CLK_PERIOD * 4;
        rst <= '0';
        wait for CLK_PERIOD * 2;
        report "=== Reset rilasciato ===";
        tx_data <= X"5A";
        start   <= '1';
        wait for CLK_PERIOD;
        start   <= '0';
        report "Inizio trasferimento: TX=0x5A, atteso RX=0xA5";
        wait until done = '1';
        wait for CLK_PERIOD;
        report "Trasferimento completato. RX ricevuto: 0x"
             & integer'image(to_integer(unsigned(rx_data)));
        assert rx_data = X"A5"
            report "ERRORE: rx_data dovrebbe essere 0xA5"
            severity error;
        report "TEST 1 completato";

        wait for CLK_PERIOD * 20;
        tx_data <= X"FF";
        start   <= '1';
        wait for CLK_PERIOD;
        start   <= '0';
        report "Inizio trasferimento: TX=0xFF, atteso RX=0xA5";
        wait until done = '1';
        wait for CLK_PERIOD;
        report "Trasferimento completato. RX ricevuto: 0x"
             & integer'image(to_integer(unsigned(rx_data)));
        assert rx_data = X"A5"
            report "ERRORE: rx_data dovrebbe essere 0xA5"
            severity error;
        report "TEST 2 completato";

        wait for CLK_PERIOD * 20;
        report "=== TEST COMPLETATI ===";
        wait;

    end process stimoli;
end architecture sim;