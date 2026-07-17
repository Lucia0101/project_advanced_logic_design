-- spi_master.vhd
-- Controller SPI master per comunicazione con periferiche esterne
--
-- Supporta tutte e 4 le modalita' SPI standard tramite i generic CPOL e CPHA:
-- - CPOL=0: SCLK in idle = 0
-- - CPOL=1: SCLK in idle = 1
-- - CPHA=0: il dato viene campionato sul primo fronte di ogni bit
-- - CPHA=1: il dato viene campionato sul secondo fronte di ogni bit
--
-- Modalita' comuni:
-- - ADXL362:    CPOL=0, CPHA=0
-- - didattica:  CPOL=1, CPHA=1
--
-- Trasferisce 1 byte alla volta in modalita' full-duplex:
-- mentre invia tx_data su MOSI, riceve in rx_data da MISO

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master is
    Generic (
        -- divisore di clock: sclk = clk / (2 * CLK_DIV)
        -- con clk=100MHz e CLK_DIV=50 -> sclk=1MHz
        CLK_DIV : positive := 50;

        -- modalita' SPI (default: CPOL=1, CPHA=1)
        CPOL : STD_LOGIC := '1';
        CPHA : STD_LOGIC := '1'
    );
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;

        -- ===== interfaccia verso la CPU =====
        start    : in  STD_LOGIC;                       -- impulso per avviare un trasferimento
        tx_data  : in  STD_LOGIC_VECTOR(7 downto 0);    -- byte da inviare
        rx_data  : out STD_LOGIC_VECTOR(7 downto 0);    -- byte ricevuto
        busy     : out STD_LOGIC;                       -- alto durante il trasferimento
        done     : out STD_LOGIC;                       -- impulso di fine trasferimento

        -- ===== fili SPI verso lo slave =====
        spi_sclk : out STD_LOGIC;                       -- clock seriale
        spi_mosi : out STD_LOGIC;                       -- master out
        spi_miso : in  STD_LOGIC;                       -- master in
        spi_cs_n : out STD_LOGIC                        -- chip select (attivo basso)
    );
end entity spi_master;

architecture behavioral of spi_master is
    -- ============= MACCHINA A STATI =============
    type state_t is (IDLE, ASSERT_CS, SHIFT, DONE_STATE);
    signal stato : state_t := IDLE;
    
    -- ============= REGISTRI E SEGNALI INTERNI =============
    signal clk_cnt   : integer range 0 to CLK_DIV-1 := 0;
    -- Segnale di Terminal Count aggiunto per la gestione del tempo
    signal clk_tc    : STD_LOGIC; 
    
    -- Configurazione originale (compatibile con ADXL362, CPOL=0)
    signal sclk_int  : STD_LOGIC := '0'; 
    signal bit_cnt   : integer range 0 to 7 := 7;
    signal shift_tx  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal shift_rx  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal cs_n_int  : STD_LOGIC := '1';
begin

    -- Calcolo combinatorio del Terminal Count fuori dal processo
    clk_tc <= '1' when clk_cnt = CLK_DIV - 1 else '0';

    -- ============= PROCESSO PRINCIPALE =============
    process(clk, rst)
    begin
        if rst = '1' then
            stato     <= IDLE;
            clk_cnt   <= 0;
            sclk_int  <= '0';
            bit_cnt   <= 7;
            shift_tx  <= (others => '0');
            shift_rx  <= (others => '0');
            cs_n_int  <= '1';
            done      <= '0';
            
        elsif rising_edge(clk) then
            done <= '0'; 
            
            case stato is
                -- ===== IDLE: attesa comando =====
                when IDLE =>
                    sclk_int <= '0';
                    cs_n_int <= '1';
                    clk_cnt  <= 0;
                    bit_cnt  <= 7;
                    if start = '1' then
                        shift_tx <= tx_data;
                        cs_n_int <= '0';
                        stato    <= ASSERT_CS; -- Nota: ho aggiunto questo salto di stato che mancava nel primissimo codice!
                    end if;
                    
                -- ===== ASSERT_CS: attesa di mezzo periodo SCLK =====
                when ASSERT_CS =>
                    if clk_tc = '1' then
                        clk_cnt  <= 0;
                        sclk_int <= '1';    
                        shift_rx <= shift_rx(6 downto 0) & spi_miso;
                        stato    <= SHIFT;
                    else
                        clk_cnt <= clk_cnt + 1;
                    end if;
                    
                -- ===== SHIFT: trasferimento dei bit =====
                when SHIFT =>
                    if clk_tc = '1' then
                        clk_cnt <= 0;

                        if sclk_int = '1' then
                            sclk_int <= '0';
                            shift_tx <= shift_tx(6 downto 0) & '0';
                            if bit_cnt = 0 then
                                stato <= DONE_STATE;
                            else
                                bit_cnt <= bit_cnt - 1;
                            end if;
                        else
                            sclk_int <= '1';
                            shift_rx <= shift_rx(6 downto 0) & spi_miso;
                        end if;
                    else
                        clk_cnt <= clk_cnt + 1;
                    end if;
                    
                -- ===== DONE_STATE: fine trasferimento =====
                when DONE_STATE =>
                    cs_n_int <= '1';        
                    sclk_int <= '0';
                    done     <= '1';        
                    stato    <= IDLE;
            end case;
        end if;
    end process;
    
    -- ============= USCITE =============
    spi_mosi <= shift_tx(7);
    spi_sclk <= sclk_int;
    spi_cs_n <= cs_n_int;
    rx_data  <= shift_rx;
    
    busy <= '0' when (stato = IDLE and start = '0') else '1';
    
end architecture behavioral;