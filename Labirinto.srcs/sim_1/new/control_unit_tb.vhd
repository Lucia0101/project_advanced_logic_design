-- control_unit_tb.vhd
-- Testbench per la Control Unit (versione senza tipo_imm)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit_tb is
end entity control_unit_tb;

architecture sim of control_unit_tb is

    signal opcode     : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
    signal funct3     : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal funct7_5   : STD_LOGIC := '0';

    signal reg_wr     : STD_LOGIC;
    signal alu_src    : STD_LOGIC;
    signal mem_wr     : STD_LOGIC;
    signal mem_rd     : STD_LOGIC;
    signal mem_to_reg : STD_LOGIC;
    signal branch     : STD_LOGIC;
    signal jump       : STD_LOGIC;
    signal alu_op     : STD_LOGIC_VECTOR(1 downto 0);

begin

    DUT: entity work.control_unit
        port map (
            opcode     => opcode,
            funct3     => funct3,
            funct7_5   => funct7_5,
            reg_wr     => reg_wr,
            alu_src    => alu_src,
            mem_wr     => mem_wr,
            mem_rd     => mem_rd,
            mem_to_reg => mem_to_reg,
            branch     => branch,
            jump       => jump,
            alu_op     => alu_op
        );

    stimoli: process
    begin

        -- TEST 1: R-TYPE
        opcode <= "0110011";
        wait for 10 ns;
        assert reg_wr = '1'   report "R-TYPE: reg_wr"   severity error;
        assert alu_src = '0'  report "R-TYPE: alu_src"  severity error;
        assert alu_op = "10"  report "R-TYPE: alu_op"   severity error;
        report "R-TYPE: OK";

        -- TEST 2: I-TYPE ALU
        opcode <= "0010011";
        wait for 10 ns;
        assert alu_src = '1'  report "I-ALU: alu_src"   severity error;
        assert alu_op = "10"  report "I-ALU: alu_op"    severity error;
        report "I-TYPE ALU: OK";

        -- TEST 3: LOAD
        opcode <= "0000011";
        wait for 10 ns;
        assert mem_rd = '1'      report "LOAD: mem_rd"     severity error;
        assert mem_to_reg = '1'  report "LOAD: mem_to_reg" severity error;
        report "LOAD: OK";

        -- TEST 4: STORE
        opcode <= "0100011";
        wait for 10 ns;
        assert mem_wr = '1'  report "STORE: mem_wr"   severity error;
        assert reg_wr = '0'  report "STORE: reg_wr"   severity error;
        report "STORE: OK";

        -- TEST 5: BRANCH
        opcode <= "1100011";
        wait for 10 ns;
        assert branch = '1'   report "BRANCH: branch"  severity error;
        assert alu_op = "01"  report "BRANCH: alu_op"  severity error;
        report "BRANCH: OK";

        -- TEST 6: JAL
        opcode <= "1101111";
        wait for 10 ns;
        assert jump = '1'  report "JAL: jump"  severity error;
        report "JAL: OK";

        -- TEST 7: JALR
        opcode <= "1100111";
        wait for 10 ns;
        assert jump = '1'     report "JALR: jump"     severity error;
        assert alu_src = '1'  report "JALR: alu_src"  severity error;
        report "JALR: OK";

        -- TEST 8: LUI
        opcode <= "0110111";
        wait for 10 ns;
        assert reg_wr = '1'   report "LUI: reg_wr"   severity error;
        assert alu_op = "11"  report "LUI: alu_op"   severity error;
        report "LUI: OK";

        -- TEST 9: AUIPC
        opcode <= "0010111";
        wait for 10 ns;
        assert reg_wr = '1'  report "AUIPC: reg_wr"  severity error;
        report "AUIPC: OK";

        report "--- TUTTI I TEST OK ---";
        wait;

    end process;

end architecture sim;