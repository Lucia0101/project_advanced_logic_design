library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu_tb is
end entity cpu_tb;

architecture sim of cpu_tb is

    signal clk           : STD_LOGIC := '0';
    signal rst           : STD_LOGIC := '1';

    signal debug_pc      : STD_LOGIC_VECTOR(31 downto 0);
    signal debug_instr   : STD_LOGIC_VECTOR(31 downto 0);
    signal debug_wb_data : STD_LOGIC_VECTOR(31 downto 0);
    signal debug_rd_addr : STD_LOGIC_VECTOR(4 downto 0);
    signal debug_reg_wr  : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

    function to_hex(v : STD_LOGIC_VECTOR(31 downto 0)) return string is
        constant cifre : string(1 to 16) := "0123456789ABCDEF";
        variable risultato : string(1 to 8);
        variable nibble : integer;
    begin
        for i in 0 to 7 loop
            nibble := to_integer(unsigned(v(31 - i*4 downto 28 - i*4)));
            risultato(i+1) := cifre(nibble + 1);
        end loop;
        return risultato;
    end function;

begin
    DUT: entity work.cpu
        port map (
            clk           => clk,
            rst           => rst,
            debug_pc      => debug_pc,
            debug_instr   => debug_instr,
            debug_wb_data => debug_wb_data,
            debug_rd_addr => debug_rd_addr,
            debug_reg_wr  => debug_reg_wr
        );

    clk <= not clk after CLK_PERIOD / 2;

    stimoli: process
    begin

        rst <= '1';
        wait for CLK_PERIOD * 2;
        rst <= '0';
        report "=== Reset rilasciato, inizio esecuzione ===";

        for i in 1 to 10 loop
            wait for CLK_PERIOD;
            if debug_reg_wr = '1' then
                report "Ciclo " & integer'image(i)
                     & ": PC=0x" & to_hex(debug_pc)
                     & " istr=0x" & to_hex(debug_instr)
                     & " scrive x" & integer'image(to_integer(unsigned(debug_rd_addr)))
                     & " val=" & integer'image(to_integer(signed(debug_wb_data)));
            else
                report "Ciclo " & integer'image(i)
                     & ": PC=0x" & to_hex(debug_pc)
                     & " (no write)";
            end if;
        end loop;

        report "=== TEST COMPLETATO ===";
        wait;

    end process;
end architecture sim;
