library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file_tb is
end entity register_file_tb;

architecture sim of register_file_tb is

    signal clk     : STD_LOGIC := '0';
    signal rst     : STD_LOGIC := '0';

    signal indice_a  : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal indice_b  : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal valore_a  : STD_LOGIC_VECTOR(31 downto 0);
    signal valore_b  : STD_LOGIC_VECTOR(31 downto 0);

    signal wr_en   : STD_LOGIC := '0';
    signal indice_wr : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal valore_wr : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    constant CLK_PERIOD : time := 10 ns;

begin

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
    clk <= not clk after CLK_PERIOD / 2;

    stimoli: process
    begin

        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        report "Reset completato";

        wr_en   <= '1';
        indice_wr <= "00001"; 
        valore_wr <= STD_LOGIC_VECTOR(to_signed(42, 32));
        wait for CLK_PERIOD;
        wr_en   <= '0';

        indice_a <= "00001";
        wait for 1 ns;
        assert valore_a = STD_LOGIC_VECTOR(to_signed(42, 32))
            report "ERRORE: scrittura/lettura x1" severity error;
        report "Scritto e letto x1 = 42: OK";

        wr_en   <= '1';
        indice_wr <= "00010";
        valore_wr <= STD_LOGIC_VECTOR(to_signed(100, 32));
        wait for CLK_PERIOD;

        indice_wr <= "00011"; 
        valore_wr <= STD_LOGIC_VECTOR(to_signed(-5, 32));
        wait for CLK_PERIOD;
        wr_en <= '0';

        indice_a <= "00010";
        indice_b <= "00011";
        wait for 1 ns;
        assert valore_a = STD_LOGIC_VECTOR(to_signed(100, 32))
            report "ERRORE: lettura x2" severity error;
        assert valore_b = STD_LOGIC_VECTOR(to_signed(-5, 32))
            report "ERRORE: lettura x3" severity error;
        report "Lettura simultanea x2=100 e x3=-5: OK";

        wr_en   <= '1';
        indice_wr <= "00000";
        valore_wr <= X"DEADBEEF";
        wait for CLK_PERIOD;
        wr_en <= '0';

        indice_a <= "00000";
        wait for 1 ns;
        assert valore_a = X"00000000"
            report "ERRORE: x0 non e' hardwired a 0!" severity error;
        report "x0 hardwired a 0 anche dopo scrittura: OK";

        indice_a <= "00001";
        wait for 1 ns;
        assert valore_a = STD_LOGIC_VECTOR(to_signed(42, 32))
            report "ERRORE: x1 non vale piu' 42 prima del reset" severity error;

        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        
        indice_a <= "00001";
        wait for 1 ns;
        assert valore_a = X"00000000"
            report "ERRORE: x1 non azzerato dopo reset" severity error;
        report "Reset azzera i registri: OK";

        report "--- TUTTI I TEST OK ---";
        wait;
        
    end process;
end architecture sim;
