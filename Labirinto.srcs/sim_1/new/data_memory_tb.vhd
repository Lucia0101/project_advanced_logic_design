-- data_memory_tb.vhd
-- Testbench per la memoria dati

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory_tb is
end entity data_memory_tb;

architecture sim of data_memory_tb is

    signal clk     : STD_LOGIC := '0';
    signal addr    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal wr_en   : STD_LOGIC := '0';
    signal rd_en   : STD_LOGIC := '0';
    signal wr_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal rd_data : STD_LOGIC_VECTOR(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: entity work.data_memory
        port map (
            clk     => clk,
            addr    => addr,
            wr_en   => wr_en,
            rd_en   => rd_en,
            wr_data => wr_data,
            rd_data => rd_data
        );

    clk <= not clk after CLK_PERIOD / 2;

    stimoli: process
    begin

        -- TEST 1: scrivi il valore 42 all'indirizzo 0
        addr    <= X"00000000";
        wr_data <= STD_LOGIC_VECTOR(to_signed(42, 32));
        wr_en   <= '1';
        rd_en   <= '0';
        wait for CLK_PERIOD;
        wr_en   <= '0';
        report "Scritto 42 all'indirizzo 0x00";

        -- TEST 2: rileggi l'indirizzo 0 e verifica
        addr  <= X"00000000";
        rd_en <= '1';
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert rd_data = STD_LOGIC_VECTOR(to_signed(42, 32))
            report "ERRORE: lettura indirizzo 0 sbagliata" severity error;
        report "Letto indirizzo 0x00: 42 OK";

        -- TEST 3: scrivi 100 all'indirizzo 4
        rd_en   <= '0';
        addr    <= X"00000004";
        wr_data <= STD_LOGIC_VECTOR(to_signed(100, 32));
        wr_en   <= '1';
        wait for CLK_PERIOD;
        wr_en   <= '0';
        report "Scritto 100 all'indirizzo 0x04";

        -- TEST 4: scrivi -7 all'indirizzo 8
        addr    <= X"00000008";
        wr_data <= STD_LOGIC_VECTOR(to_signed(-7, 32));
        wr_en   <= '1';
        wait for CLK_PERIOD;
        wr_en   <= '0';
        report "Scritto -7 all'indirizzo 0x08";

        -- TEST 5: rileggi l'indirizzo 4
        addr  <= X"00000004";
        rd_en <= '1';
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert rd_data = STD_LOGIC_VECTOR(to_signed(100, 32))
            report "ERRORE: lettura indirizzo 4 sbagliata" severity error;
        report "Letto indirizzo 0x04: 100 OK";

        -- TEST 6: rileggi l'indirizzo 8 (valore negativo)
        addr  <= X"00000008";
        rd_en <= '1';
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert rd_data = STD_LOGIC_VECTOR(to_signed(-7, 32))
            report "ERRORE: lettura indirizzo 8 sbagliata" severity error;
        report "Letto indirizzo 0x08: -7 OK";

        -- TEST 7: lettura di cella mai scritta (deve essere 0)
        addr  <= X"00000100";
        rd_en <= '1';
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert rd_data = X"00000000"
            report "ERRORE: cella mai scritta dovrebbe essere 0" severity error;
        report "Cella mai scritta (0x100): 0 OK";

        -- TEST 8: sovrascrittura - cambia il valore all'indirizzo 0
        rd_en   <= '0';
        addr    <= X"00000000";
        wr_data <= X"DEADBEEF";
        wr_en   <= '1';
        wait for CLK_PERIOD;
        wr_en   <= '0';

        addr  <= X"00000000";
        rd_en <= '1';
        wait for CLK_PERIOD;
        wait for 1 ns;
        assert rd_data = X"DEADBEEF"
            report "ERRORE: sovrascrittura sbagliata" severity error;
        report "Sovrascritto 0x00 con 0xDEADBEEF OK";

        report "--- TUTTI I TEST OK ---";
        wait;

    end process;

end architecture sim;