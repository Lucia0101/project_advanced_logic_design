-- instr_memory_tb.vhd
-- Testbench per la memoria istruzioni

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instr_memory_tb is
end entity instr_memory_tb;

architecture sim of instr_memory_tb is

    signal clk   : STD_LOGIC := '0';
    signal addr  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal instr : STD_LOGIC_VECTOR(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: entity work.instr_memory
        port map (
            clk   => clk,
            addr  => addr,
            instr => instr
        );

    clk <= not clk after CLK_PERIOD / 2;

    stimoli: process
    begin
        -- importante: la lettura della BRAM e' SINCRONA
        -- quindi l'istruzione e' disponibile UN ciclo dopo aver messo l'indirizzo

        -- test 1: leggi istruzione all'indirizzo 0
        addr <= X"00000000";
        wait for CLK_PERIOD;       -- aspetto un ciclo per la latenza BRAM
        wait for 1 ns;
        assert instr = X"00500093"
            report "ERRORE indirizzo 0: dovrebbe essere addi x1, x0, 5" severity error;
        report "Indirizzo 0x00: 0x00500093 (addi x1, x0, 5) OK";

        -- test 2: indirizzo 4 (seconda istruzione)
        addr <= X"00000004";
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert instr = X"00A00113"
            report "ERRORE indirizzo 4: dovrebbe essere addi x2, x0, 10" severity error;
        report "Indirizzo 0x04: 0x00A00113 (addi x2, x0, 10) OK";

        -- test 3: indirizzo 8 (terza istruzione)
        addr <= X"00000008";
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert instr = X"002081B3"
            report "ERRORE indirizzo 8: dovrebbe essere add x3, x1, x2" severity error;
        report "Indirizzo 0x08: 0x002081B3 (add x3, x1, x2) OK";

        -- test 4: indirizzo 0x14 (sesta istruzione)
        addr <= X"00000014";
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert instr = X"0020E333"
            report "ERRORE indirizzo 0x14" severity error;
        report "Indirizzo 0x14: 0x0020E333 (or x6, x1, x2) OK";

        -- test 5: cella vuota (deve essere NOP)
        addr <= X"00000040";  -- indirizzo non programmato
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert instr = X"00000013"
            report "ERRORE: cella vuota dovrebbe contenere NOP" severity error;
        report "Indirizzo 0x40: NOP (0x00000013) OK";

        report "--- TUTTI I TEST OK ---";
        wait;

    end process;

end architecture sim;
