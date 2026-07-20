library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_control_tb is
end entity alu_control_tb;

architecture sim of alu_control_tb is

    signal alu_op   : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal funct3   : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal funct7_5 : STD_LOGIC := '0';
    signal opcode_5 : STD_LOGIC := '0';
    signal op_sel   : STD_LOGIC_VECTOR(3 downto 0);

begin

    DUT: entity work.alu_control
        port map (
            alu_op   => alu_op,
            funct3   => funct3,
            funct7_5 => funct7_5,
            opcode_5 => opcode_5,
            op_sel   => op_sel
        );

    stimoli: process
    begin

        alu_op   <= "00";
        funct3   <= "000";
        funct7_5 <= '0';
        wait for 10 ns;
        assert op_sel = "0000"
            report "ERRORE: LOAD/STORE non da ADD" severity error;
        report "alu_op=00 (LOAD/STORE) -> ADD: OK";

        alu_op   <= "01";
        funct3   <= "000";
        funct7_5 <= '0';
        wait for 10 ns;
        assert op_sel = "0001"
            report "ERRORE: BRANCH non da SUB" severity error;
        report "alu_op=01 (BRANCH) -> SUB: OK";

        alu_op   <= "10";
        funct3   <= "000";
        funct7_5 <= '0';
        opcode_5 <= '1';  
        wait for 10 ns;
        assert op_sel = "0000" report "ERRORE: ADD sbagliato" severity error;
        report "R-type ADD: OK";

        alu_op   <= "10";
        funct3   <= "000";
        funct7_5 <= '1';
        opcode_5 <= '1'; 
        wait for 10 ns;
        assert op_sel = "0001" report "ERRORE: SUB sbagliato" severity error;
        report "R-type SUB: OK";

        alu_op   <= "10";
        funct3   <= "111";
        funct7_5 <= '0';
        wait for 10 ns;
        assert op_sel = "0010"
            report "ERRORE: AND sbagliato" severity error;
        report "AND: OK";

        alu_op   <= "10";
        funct3   <= "110";
        funct7_5 <= '0';
        wait for 10 ns;
        assert op_sel = "0011"
            report "ERRORE: OR sbagliato" severity error;
        report "OR: OK";

        alu_op   <= "10";
        funct3   <= "100";
        funct7_5 <= '0';
        wait for 10 ns;
        assert op_sel = "0100"
            report "ERRORE: XOR sbagliato" severity error;
        report "XOR: OK";

        alu_op   <= "10";
        funct3   <= "001";
        funct7_5 <= '0';
        wait for 10 ns;
        assert op_sel = "0101"
            report "ERRORE: SLL sbagliato" severity error;
        report "SLL: OK";

        alu_op   <= "10";
        funct3   <= "101";
        funct7_5 <= '0';
        wait for 10 ns;
        assert op_sel = "0110"
            report "ERRORE: SRL sbagliato" severity error;
        report "SRL: OK";

        alu_op   <= "10";
        funct3   <= "101";
        funct7_5 <= '1';
        wait for 10 ns;
        assert op_sel = "0111"
            report "ERRORE: SRA sbagliato" severity error;
        report "SRA: OK";

        alu_op   <= "10";
        funct3   <= "010";
        funct7_5 <= '0';
        wait for 10 ns;
        assert op_sel = "1000"
            report "ERRORE: SLT sbagliato" severity error;
        report "SLT: OK";

        alu_op   <= "10";
        funct3   <= "011";
        funct7_5 <= '0';
        wait for 10 ns;
        assert op_sel = "1001"
            report "ERRORE: SLTU sbagliato" severity error;
        report "SLTU: OK";

        alu_op   <= "11";
        funct3   <= "000";
        funct7_5 <= '0';
        wait for 10 ns;
        assert op_sel = "0000"
            report "ERRORE: LUI sbagliato" severity error;
        report "LUI -> ADD: OK";
        
        alu_op   <= "10";
        funct3   <= "000";
        funct7_5 <= '1';    -- Negative (ex -1)
        opcode_5 <= '0';  
        wait for 10 ns;
        assert op_sel = "0000"
            report "ERRORE CRITICO: ADDI ha generato un SUB!" severity error;
        report "I-Type ADDI con immediato negativo (Bug fix): OK";
        
        report "--- TUTTI I TEST OK ---";
        wait;

    end process;
end architecture sim;
