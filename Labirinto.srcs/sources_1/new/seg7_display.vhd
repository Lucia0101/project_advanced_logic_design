-- seg7_display.vhd
-- Controller per il display a 7 segmenti a 8 cifre della Nexys 4 DDR
-- Usa il multiplexing temporale: accende una cifra alla volta molto
-- velocemente, dando l'illusione che tutte siano accese insieme.
--
-- Mostra un valore a 32 bit come 8 cifre esadecimali.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seg7_display is
    Port (
        clk    : in  STD_LOGIC;
        rst    : in  STD_LOGIC;

        -- valore da mostrare (8 cifre esadecimali)
        value  : in  STD_LOGIC_VECTOR(31 downto 0);

        -- uscite verso il display fisico
        seg    : out STD_LOGIC_VECTOR(6 downto 0);   -- segmenti (attivi bassi)
        an     : out STD_LOGIC_VECTOR(7 downto 0);   -- anodi (attivi bassi)
        dp     : out STD_LOGIC                        -- punto decimale (attivo basso)
    );
end entity seg7_display;

architecture behavioral of seg7_display is

    -- ============= CONTATORE DI REFRESH =============
    -- serve a ciclare tra le 8 cifre a una frequenza sufficiente
    -- a ingannare l'occhio (ogni cifra viene aggiornata ~1000 volte/sec).
    -- Con clk=100MHz, un contatore a 20 bit divide per ~1M -> ogni cifra
    -- viene rinfrescata a circa 100MHz / 2^17 ~ 760 Hz.
    signal refresh_cnt : unsigned(19 downto 0) := (others => '0');

    -- i 3 bit alti del contatore selezionano quale cifra mostrare (0..7)
    signal digit_sel   : integer range 0 to 7;

    -- cifra esadecimale corrente da mostrare (4 bit)
    signal hex_digit   : STD_LOGIC_VECTOR(3 downto 0);

begin

    -- ============= CONTATORE DI REFRESH =============
    process(clk, rst)
    begin
        if rst = '1' then
            refresh_cnt <= (others => '0');
        elsif rising_edge(clk) then
            refresh_cnt <= refresh_cnt + 1;
        end if;
    end process;

    -- i 3 bit piu' alti selezionano la cifra attiva
    digit_sel <= to_integer(refresh_cnt(19 downto 17));

    -- ============= SELEZIONE DELLA CIFRA =============
    -- in base a digit_sel estraiamo i 4 bit corrispondenti dal valore
    with digit_sel select
        hex_digit <= value(3 downto 0)   when 0,
                     value(7 downto 4)   when 1,
                     value(11 downto 8)  when 2,
                     value(15 downto 12) when 3,
                     value(19 downto 16) when 4,
                     value(23 downto 20) when 5,
                     value(27 downto 24) when 6,
                     value(31 downto 28) when 7,
                     "0000"              when others;

    -- ============= ACCENSIONE DELL'ANODO =============
    -- accende solo la cifra selezionata (attivo basso: 0 = accesa)
    process(digit_sel)
    begin
        an <= "11111111";       -- tutte spente di default
        an(digit_sel) <= '0';   -- accendi solo quella corrente
    end process;

    -- ============= DECODER DEI SEGMENTI =============
    DEC_inst: entity work.hex_to_7seg
        port map (
           hex => hex_digit,
            seg => seg
        );

    -- punto decimale sempre spento (attivo basso)
    dp <= '1';

end architecture behavioral;