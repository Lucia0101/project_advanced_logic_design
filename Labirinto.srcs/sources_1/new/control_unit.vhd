-- control_unit.vhd
-- Control Unit per processore RISC-V RV32I
-- Genera i segnali di controllo per il datapath
-- Nota: tipo_imm e' generato direttamente nel datapath, non qui

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port (
        opcode     : in  STD_LOGIC_VECTOR(6 downto 0);
        funct3     : in  STD_LOGIC_VECTOR(2 downto 0);
        funct7_5   : in  STD_LOGIC;

        reg_wr     : out STD_LOGIC;
        alu_src    : out STD_LOGIC;
        mem_wr     : out STD_LOGIC;
        mem_rd     : out STD_LOGIC;
        mem_to_reg : out STD_LOGIC;
        branch     : out STD_LOGIC;
        jump       : out STD_LOGIC;
        alu_op     : out STD_LOGIC_VECTOR(1 downto 0)
    );
end entity control_unit;

architecture behavioral of control_unit is

    constant OP_R_TYPE  : STD_LOGIC_VECTOR(6 downto 0) := "0110011";
    constant OP_I_ALU   : STD_LOGIC_VECTOR(6 downto 0) := "0010011";
    constant OP_LOAD    : STD_LOGIC_VECTOR(6 downto 0) := "0000011";
    constant OP_STORE   : STD_LOGIC_VECTOR(6 downto 0) := "0100011";
    constant OP_BRANCH  : STD_LOGIC_VECTOR(6 downto 0) := "1100011";
    constant OP_JAL     : STD_LOGIC_VECTOR(6 downto 0) := "1101111";
    constant OP_JALR    : STD_LOGIC_VECTOR(6 downto 0) := "1100111";
    constant OP_LUI     : STD_LOGIC_VECTOR(6 downto 0) := "0110111";
    constant OP_AUIPC   : STD_LOGIC_VECTOR(6 downto 0) := "0010111";

begin

    process(opcode, funct3, funct7_5)
    begin

        -- valori di default: tutto a 0 (evita latch indesiderati)
        reg_wr     <= '0';
        alu_src    <= '0';
        mem_wr     <= '0';
        mem_rd     <= '0';
        mem_to_reg <= '0';
        branch     <= '0';
        jump       <= '0';
        alu_op     <= "01";

        case opcode is

            -- R-TYPE: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
            when OP_R_TYPE =>
                reg_wr     <= '1';
                alu_src    <= '0';
                mem_to_reg <= '0';
                alu_op     <= "10";

            -- I-TYPE ALU: ADDI, ANDI, ORI...
            when OP_I_ALU =>
                reg_wr     <= '1';
                alu_src    <= '1';
                mem_to_reg <= '0';
                alu_op     <= "10";

            -- LOAD: LW, LH, LB
            when OP_LOAD =>
                reg_wr     <= '1';
                alu_src    <= '1';
                mem_rd     <= '1';
                mem_to_reg <= '1';
                alu_op     <= "00";

            -- STORE: SW, SH, SB
            when OP_STORE =>
                alu_src    <= '1';
                mem_wr     <= '1';
                alu_op     <= "00";

            -- BRANCH: BEQ, BNE, BLT, BGE...
            when OP_BRANCH =>
                branch     <= '1';
                alu_src    <= '0';
                alu_op     <= "00";

            -- JAL
            when OP_JAL =>
                reg_wr     <= '1';
                alu_src    <= '1';
                jump       <= '1';
                mem_to_reg <= '0';
                alu_op     <= "00";

            -- JALR
            when OP_JALR =>
                reg_wr     <= '1';
                alu_src    <= '1';
                jump       <= '1';
                alu_op     <= "00";

            -- LUI
            when OP_LUI =>
                reg_wr     <= '1';
                alu_src    <= '1';
                mem_to_reg <= '0';
                alu_op     <= "11";

            -- AUIPC
            when OP_AUIPC =>
                reg_wr     <= '1';
                alu_src    <= '1';
                mem_to_reg <= '0';
                alu_op     <= "00";

            when others =>
                null;

        end case;
    end process;

end architecture behavioral;