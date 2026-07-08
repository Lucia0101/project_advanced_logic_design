-- spi_master_tb.vhd
-- Testbench per lo SPI master (CPOL=0, CPHA=0 - compatibile ADXL362)
-- Simula uno slave "finto" che invia un byte noto su MISO
--
-- IMPORTANTE (CPHA=0): lo slave deve presentare il primo bit (MSB) su MISO
-- gia' quando CS si abbassa, PRIMA del primo fronte di clock. I bit successivi
-- vengono aggiornati sul fronte di discesa di SCLK.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master_tb is
end entity spi_master_tb;

architecture sim of spi_master_tb is

    -- segnali per il DUT
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

    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz
    constant TEST_CLK_DIV : positive := 2;

    -- byte che lo slave "finto" trasmette su MISO
    constant SLAVE_BYTE : STD_LOGIC_VECTOR(7 downto 0) := X"A5";

    -- shift register dello slave finto
    signal slave_shift : STD_LOGIC_VECTOR(7 downto 0) := SLAVE_BYTE;

begin

    -- istanza del DUT con divisore di clock ridotto
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

    -- generatore di clock
    clk <= not clk after CLK_PERIOD / 2;

    -- ============= SLAVE SPI FINTO (CPOL=0, CPHA=0) =============
    -- Con CPHA=0:
    -- - quando CS si abbassa (fronte di discesa di cs_n), lo slave presenta
    --   subito l'MSB su MISO (cosi' e' pronto per il primo fronte di salita)
    -- - sui fronti di discesa di SCLK aggiorna il bit successivo
    -- - quando CS torna alto, resetta la linea e ricarica il byte
    slave: process(spi_sclk, spi_cs_n)
    begin
        if falling_edge(spi_cs_n) then
            -- CS appena abbassato: presenta l'MSB e prepara il resto
            spi_miso    <= SLAVE_BYTE(7);
            slave_shift <= SLAVE_BYTE(6 downto 0) & '0';
        elsif rising_edge(spi_cs_n) then
            -- CS tornato alto: linea a riposo, ricarica il byte
            spi_miso    <= '0';
            slave_shift <= SLAVE_BYTE;
        elsif falling_edge(spi_sclk) then
            -- fronte di discesa SCLK: aggiorna il bit successivo
            spi_miso    <= slave_shift(7);
            slave_shift <= slave_shift(6 downto 0) & '0';
        end if;
    end process slave;

    -- ============= STIMOLI =============
    stimoli: process
    begin
        -- reset iniziale
        rst <= '1';
        wait for CLK_PERIOD * 4;
        rst <= '0';
        wait for CLK_PERIOD * 2;
        report "=== Reset rilasciato ===";

        -- TEST 1: invia 0x5A e ricevi 0xA5
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

        -- TEST 2: invia 0xFF e ricevi 0xA5 (verifica indipendenza TX/RX)
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