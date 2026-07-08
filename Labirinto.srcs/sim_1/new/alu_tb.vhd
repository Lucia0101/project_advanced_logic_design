-- alu_tb.vhd
-- Testbench per la ALU RISC-V
-- Verifica tutte le operazioni con assert automatici

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_tb is
-- nessuna porta: il testbench e' il livello piu' alto, genera tutto internamente
end entity alu_tb;

architecture sim of alu_tb is

    -- segnali collegati alla ALU
    signal a    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal b    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal seleziona  : STD_LOGIC_VECTOR(3 downto 0)  := (others => '0');
    signal res     : STD_LOGIC_VECTOR(31 downto 0);
    signal zero    : STD_LOGIC;

begin
 
    -- 'uut' sta per Unit Under Test (nome a piacere)
     uut: entity work.alu
        port map (
            a    => a,
            b    => b,
            seleziona  => seleziona,
            alu_res => res,
            zero    => zero
        );

    -- testo tutte le operazioni scritte nell'alu
    test_process: process
    begin

        -- ADD: 10 + 5 deve dare 15
        a   <= STD_LOGIC_VECTOR(to_signed(10, 32));
        b   <= STD_LOGIC_VECTOR(to_signed(5, 32));
        seleziona <= "0000";
        wait for 10 ns;
        assert res = STD_LOGIC_VECTOR(to_signed(15, 32))
            report "ERRORE ADD" severity error;
        report "ADD 10+5 = " & integer'image(to_integer(signed(res)));

        -- SUB: 7 - 7 = 0, il flag zero deve scattare
        a   <= STD_LOGIC_VECTOR(to_signed(7, 32));
        b   <= STD_LOGIC_VECTOR(to_signed(7, 32));
        seleziona <= "0001";
        wait for 10 ns;
        assert res = (31 downto 0 => '0') report "ERRORE SUB" severity error;
        assert zero = '1' report "ERRORE: flag zero non attivo" severity error;
        report "SUB 7-7=0, zero=" & STD_LOGIC'image(zero);

        -- AND: 0xFF AND 0x0F = 0x0F
        a   <= X"000000FF";
        b   <= X"0000000F";
        seleziona <= "0010";
        wait for 10 ns;
        assert res = X"0000000F" report "ERRORE AND" severity error;
        report "AND: OK";

        -- OR: 0xF0 OR 0x0F = 0xFF
        a   <= X"000000F0";
        b   <= X"0000000F";
        seleziona <= "0011";
        wait for 10 ns;
        assert res = X"000000FF" report "ERRORE OR" severity error;
        report "OR: OK";

        -- XOR: 0xFF XOR 0xFF = 0
        a   <= X"000000FF";
        b   <= X"000000FF";
        seleziona <= "0100";
        wait for 10 ns;
        assert res = X"00000000" report "ERRORE XOR" severity error;
        report "XOR: OK";

        -- SLL: 1 shiftato a sinistra di 4 = 16
        a   <= STD_LOGIC_VECTOR(to_unsigned(1, 32));
        b   <= STD_LOGIC_VECTOR(to_unsigned(4, 32));
        seleziona <= "0101";
        wait for 10 ns;
        assert res = STD_LOGIC_VECTOR(to_unsigned(16, 32))
            report "ERRORE SLL" severity error;
        report "SLL: OK";

        -- SRL: 16 shiftato a destra di 2 = 4
        a   <= STD_LOGIC_VECTOR(to_unsigned(16, 32));
        b   <= STD_LOGIC_VECTOR(to_unsigned(2, 32));
        seleziona <= "0110";
        wait for 10 ns;
        assert res = STD_LOGIC_VECTOR(to_unsigned(4, 32))
            report "ERRORE SRL" severity error;
        report "SRL: OK";

        -- SRA: -8 shiftato a destra di 1 = -4 (il segno si mantiene)
        a   <= STD_LOGIC_VECTOR(to_signed(-8, 32));
        b   <= STD_LOGIC_VECTOR(to_unsigned(1, 32));
        seleziona <= "0111";
        wait for 10 ns;
        assert res = STD_LOGIC_VECTOR(to_signed(-4, 32))
            report "ERRORE SRA" severity error;
        report "SRA: OK";

        -- SLT: -1 < 1 con segno, risultato deve essere 1
        a   <= STD_LOGIC_VECTOR(to_signed(-1, 32));
        b   <= STD_LOGIC_VECTOR(to_signed(1, 32));
        seleziona <= "1000";
        wait for 10 ns;
        assert res = STD_LOGIC_VECTOR(to_signed(1, 32))
            report "ERRORE SLT" severity error;
        report "SLT: OK";

        -- SLTU: 0xFFFFFFFF e' grande senza segno, non e' < 1, risultato = 0
        a   <= X"FFFFFFFF";
        b   <= STD_LOGIC_VECTOR(to_unsigned(1, 32));
        seleziona <= "1001";
        wait for 10 ns;
        assert res = X"00000000" report "ERRORE SLTU" severity error;
        report "SLTU: OK";

        report "--- TUTTI I TEST OK ---";
        wait;

    end process;

end architecture sim;