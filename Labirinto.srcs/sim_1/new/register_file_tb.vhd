-- register_file_tb.vhd
-- Testbench per il Register File RISC-V

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file_tb is
end entity register_file_tb;

architecture sim of register_file_tb is

    -- segnali collegati al register file
    signal clk     : STD_LOGIC := '0';
    signal rst     : STD_LOGIC := '0';

    signal indice_a  : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal indice_b  : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal valore_a  : STD_LOGIC_VECTOR(31 downto 0);
    signal valore_b  : STD_LOGIC_VECTOR(31 downto 0);

    signal wr_en   : STD_LOGIC := '0';
    signal indice_wr : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal valore_wr : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    -- periodo del clock: 10 ns = 100 MHz
    constant CLK_PERIOD : time := 10 ns;

begin

    -- istanzia il register file
    DUT: entity work.register_file
        port map (
            clk     => clk,
            rst     => rst,
            indice_a  => indice_a,
            valore_a  => valore_a,
            indice_b  => indice_b,
            valore_b  => valore_b,
            wr_en   => wr_en,
            indice_wr => indice_wr,
            valore_wr => valore_wr
        );

    -- generatore di clock: si inverte ogni mezzo periodo
    -- questo processo gira per sempre in parallelo agli stimoli
    clk <= not clk after CLK_PERIOD / 2;

    -- processo di test
    stimoli: process
    begin

        -- TEST 1: reset iniziale
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        report "Reset completato";

        -- TEST 2: scrivi 42 nel registro x1
        -- imposto gli ingressi PRIMA del fronte di clock
        wr_en   <= '1';
        indice_wr <= "00001";  -- x1
        valore_wr <= STD_LOGIC_VECTOR(to_signed(42, 32));
        wait for CLK_PERIOD;  -- la scrittura avviene qui al fronte di salita
        wr_en   <= '0';

        -- leggo subito x1 dalla porta A (lettura combinatoria, non serve clock)
        indice_a <= "00001";
        wait for 1 ns;  -- piccola attesa per far propagare il segnale
        assert valore_a = STD_LOGIC_VECTOR(to_signed(42, 32))
            report "ERRORE: scrittura/lettura x1" severity error;
        report "Scritto e letto x1 = 42: OK";

        -- TEST 3: scrivi 100 in x2 e -5 in x3, poi leggi entrambi insieme
        -- prima x2
        wr_en   <= '1';
        indice_wr <= "00010";  -- x2
        valore_wr <= STD_LOGIC_VECTOR(to_signed(100, 32));
        wait for CLK_PERIOD;

        -- poi x3
        indice_wr <= "00011";  -- x3
        valore_wr <= STD_LOGIC_VECTOR(to_signed(-5, 32));
        wait for CLK_PERIOD;
        wr_en <= '0';

        -- lettura simultanea di x2 e x3 sulle due porte
        indice_a <= "00010";  -- leggo x2 dalla porta A
        indice_b <= "00011";  -- leggo x3 dalla porta B
        wait for 1 ns;
        assert valore_a = STD_LOGIC_VECTOR(to_signed(100, 32))
            report "ERRORE: lettura x2" severity error;
        assert valore_b = STD_LOGIC_VECTOR(to_signed(-5, 32))
            report "ERRORE: lettura x3" severity error;
        report "Lettura simultanea x2=100 e x3=-5: OK";

        -- TEST 4: scrivi su x0 - deve rimanere 0 (hardwired)
        wr_en   <= '1';
        indice_wr <= "00000";  -- x0
        valore_wr <= X"DEADBEEF";  -- valore qualsiasi
        wait for CLK_PERIOD;
        wr_en <= '0';

        indice_a <= "00000";
        wait for 1 ns;
        assert valore_a = X"00000000"
            report "ERRORE: x0 non e' hardwired a 0!" severity error;
        report "x0 hardwired a 0 anche dopo scrittura: OK";

        -- TEST 5: reset azzera tutto
        -- prima verifico che x1 valga ancora 42
        indice_a <= "00001";
        wait for 1 ns;
        assert valore_a = STD_LOGIC_VECTOR(to_signed(42, 32))
            report "ERRORE: x1 non vale piu' 42 prima del reset" severity error;

        -- ora resetto
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';

        -- dopo il reset x1 deve valere 0
        indice_a <= "00001";
        wait for 1 ns;
        assert valore_a = X"00000000"
            report "ERRORE: x1 non azzerato dopo reset" severity error;
        report "Reset azzera i registri: OK";

        report "--- TUTTI I TEST OK ---";
        wait;
        
    end process;

end architecture sim;
