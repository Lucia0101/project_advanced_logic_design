library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter_tb is
end entity program_counter_tb;

architecture sim of program_counter_tb is

    signal clk      : STD_LOGIC := '0';
    signal rst      : STD_LOGIC := '0';
    signal pc_load  : STD_LOGIC := '0'; 
    signal pc_src   : STD_LOGIC := '0';
    signal target   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal pc_out   : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus4 : STD_LOGIC_VECTOR(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: entity work.program_counter
        port map (
            clk      => clk,
            rst      => rst,
            pc_load  => pc_load,
            pc_src   => pc_src,
            target   => target,
            pc_out   => pc_out,
            pc_plus4 => pc_plus4
        );

    clk <= not clk after CLK_PERIOD / 2;

    stimoli: process
    begin
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        wait for 1 ns;
        assert pc_out = X"00000000"
            report "ERRORE: PC non e' 0 dopo reset" severity error;
        report "Reset: PC = 0x00000000 OK";
        
        pc_src  <= '0';
        pc_load <= '1';
        pc_src <= '0';

        wait for CLK_PERIOD;
        wait for 1 ns;
        assert pc_out = X"00000004"
            report "ERRORE: PC non vale 4" severity error;
        report "PC + 4 => 0x00000004 OK";

        wait for CLK_PERIOD;
        wait for 1 ns;
        assert pc_out = X"00000008"
            report "ERRORE: PC non vale 8" severity error;
        report "PC + 4 => 0x00000008 OK";

        wait for CLK_PERIOD;
        wait for 1 ns;
        assert pc_out = X"0000000C"
            report "ERRORE: PC non vale 12" severity error;
        report "PC + 4 => 0x0000000C OK";

        wait for CLK_PERIOD;
        wait for 1 ns;
        assert pc_out = X"00000010"
            report "ERRORE: PC non vale 16" severity error;
        report "PC + 4 => 0x00000010 OK";

        target <= X"00000040";
        pc_src <= '1';
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert pc_out = X"00000040"
            report "ERRORE: salto a 0x40 fallito" severity error;
        report "Salto a 0x00000040 OK";

        pc_src <= '0';
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert pc_out = X"00000044"
            report "ERRORE: PC + 4 dopo salto fallito" severity error;
        report "PC + 4 dopo salto => 0x00000044 OK";

        assert pc_plus4 = X"00000048"
            report "ERRORE: pc_plus4 sbagliato" severity error;
        report "pc_plus4 = 0x00000048 OK";

        pc_load <= '0';
        pc_src  <= '0';
        wait for CLK_PERIOD * 3; 
        wait for 1 ns;
        assert pc_out = X"00000044"
            report "ERRORE: Il PC e' andato avanti anche con pc_load = 0" severity error;
        report "Congelamento PC con pc_load = 0 OK";

        report "--- TUTTI I TEST OK ---";
        wait;

    end process;
end architecture sim;