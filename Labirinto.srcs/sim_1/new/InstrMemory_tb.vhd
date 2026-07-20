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
        addr <= X"00000000";
        wait for CLK_PERIOD; 
        wait for 1 ns;
        assert instr = X"00500093"
            report "ERRORE indirizzo 0: dovrebbe essere addi x1, x0, 5" severity error;
        report "Indirizzo 0x00: 0x00500093 (addi x1, x0, 5) OK";
        
        addr <= X"00000004";
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert instr = X"00A00113"
            report "ERRORE indirizzo 4: dovrebbe essere addi x2, x0, 10" severity error;
        report "Indirizzo 0x04: 0x00A00113 (addi x2, x0, 10) OK";

        addr <= X"00000008";
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert instr = X"002081B3"
            report "ERRORE indirizzo 8: dovrebbe essere add x3, x1, x2" severity error;
        report "Indirizzo 0x08: 0x002081B3 (add x3, x1, x2) OK";

        addr <= X"00000014";
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert instr = X"0020E333"
            report "ERRORE indirizzo 0x14" severity error;
        report "Indirizzo 0x14: 0x0020E333 (or x6, x1, x2) OK";

        addr <= X"00000040";
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert instr = X"00000013"
            report "ERRORE: cella vuota dovrebbe contenere NOP" severity error;
        report "Indirizzo 0x40: NOP (0x00000013) OK";

        report "--- TUTTI I TEST OK ---";
        wait;

    end process;

end architecture sim;
