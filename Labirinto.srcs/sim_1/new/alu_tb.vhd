library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_tb is

end entity alu_tb;

architecture sim of alu_tb is

    signal a       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal b       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal s       : STD_LOGIC_VECTOR(3 downto 0)  := (others => '0');
    signal res     : STD_LOGIC_VECTOR(31 downto 0);
    signal zero    : STD_LOGIC;

begin
 
     uut: entity work.alu
        port map (
            a    => a,
            b    => b,
            s  => s,
            alu_res => res,
            zero    => zero
        );

    test_process: process
    begin
        -- ADD
        a   <= STD_LOGIC_VECTOR(to_signed(10, 32));
        b   <= STD_LOGIC_VECTOR(to_signed(5, 32));
        s <= "0000";
        wait for 10 ns;
        assert res = STD_LOGIC_VECTOR(to_signed(15, 32))
            report "ERRORE ADD" severity error;
        report "ADD 10+5 = " & integer'image(to_integer(signed(res)));
        -- SUB
        a   <= STD_LOGIC_VECTOR(to_signed(7, 32));
        b   <= STD_LOGIC_VECTOR(to_signed(7, 32));
        s <= "0001";
        wait for 10 ns;
        assert res = (31 downto 0 => '0') report "ERRORE SUB" severity error;
        assert zero = '1' report "ERRORE: flag zero non attivo" severity error;
        report "SUB 7-7=0, zero=" & STD_LOGIC'image(zero);
        -- AND
        a   <= X"000000FF";
        b   <= X"0000000F";
        s <= "0010";
        wait for 10 ns;
        assert res = X"0000000F" report "ERRORE AND" severity error;
        report "AND: OK";
        -- OR
        a   <= X"000000F0";
        b   <= X"0000000F";
        s <= "0011";
        wait for 10 ns;
        assert res = X"000000FF" report "ERRORE OR" severity error;
        report "OR: OK";
        -- XOR
        a   <= X"000000FF";
        b   <= X"000000FF";
        s <= "0100";
        wait for 10 ns;
        assert res = X"00000000" report "ERRORE XOR" severity error;
        report "XOR: OK";
        -- SLL
        a   <= STD_LOGIC_VECTOR(to_unsigned(1, 32));
        b   <= STD_LOGIC_VECTOR(to_unsigned(4, 32));
        s <= "0101";
        wait for 10 ns;
        assert res = STD_LOGIC_VECTOR(to_unsigned(16, 32))
            report "ERRORE SLL" severity error;
        report "SLL: OK";
        -- SRL
        a   <= STD_LOGIC_VECTOR(to_unsigned(16, 32));
        b   <= STD_LOGIC_VECTOR(to_unsigned(2, 32));
        s <= "0110";
        wait for 10 ns;
        assert res = STD_LOGIC_VECTOR(to_unsigned(4, 32))
            report "ERRORE SRL" severity error;
        report "SRL: OK";
        -- SRA
        a   <= STD_LOGIC_VECTOR(to_signed(-8, 32));
        b   <= STD_LOGIC_VECTOR(to_unsigned(1, 32));
        s <= "0111";
        wait for 10 ns;
        assert res = STD_LOGIC_VECTOR(to_signed(-4, 32))
            report "ERRORE SRA" severity error;
        report "SRA: OK";
        -- SLT
        a   <= STD_LOGIC_VECTOR(to_signed(-1, 32));
        b   <= STD_LOGIC_VECTOR(to_signed(1, 32));
        s <= "1000";
        wait for 10 ns;
        assert res = STD_LOGIC_VECTOR(to_signed(1, 32))
            report "ERRORE SLT" severity error;
        report "SLT: OK";
        -- SLTU
        a   <= X"FFFFFFFF";
        b   <= STD_LOGIC_VECTOR(to_unsigned(1, 32));
        s <= "1001";
        wait for 10 ns;
        assert res = X"00000000" report "ERRORE SLTU" severity error;
        report "SLTU: OK";

        report "--- TUTTI I TEST OK ---";
        wait;

    end process;
end architecture sim;