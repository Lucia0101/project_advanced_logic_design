-- comparator_tb.vhd
-- Testbench per il Comparator (Branch Logic) RISC-V

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comparator_tb is
end entity comparator_tb;

architecture sim of comparator_tb is

    signal rs1_value    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal rs2_value    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal branch       : STD_LOGIC := '0';
    signal jump         : STD_LOGIC := '0';
    signal funct3       : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal branch_cond  : STD_LOGIC;

begin

    DUT: entity work.comparator
        port map (
            rs1_value   => rs1_value,
            rs2_value   => rs2_value,
            branch      => branch,
            jump        => jump,
            funct3      => funct3,
            branch_cond => branch_cond
        );

    stimoli: process
    begin

        -- TEST 1: BEQ preso (rs1 == rs2)
        rs1_value <= STD_LOGIC_VECTOR(to_signed(15, 32));
        rs2_value <= STD_LOGIC_VECTOR(to_signed(15, 32));
        branch    <= '1';
        jump      <= '0';
        funct3    <= "000";  -- BEQ
        wait for 10 ns;
        assert branch_cond = '1' report "ERRORE: BEQ preso fallito" severity error;
        report "BEQ (rs1 == rs2): branch_cond=1 OK";

        -- TEST 2: BEQ non preso (rs1 != rs2)
        rs2_value <= STD_LOGIC_VECTOR(to_signed(20, 32));
        wait for 10 ns;
        assert branch_cond = '0' report "ERRORE: BEQ non preso fallito" severity error;
        report "BEQ (rs1 != rs2): branch_cond=0 OK";

        -- TEST 3: BLT preso (rs1 < rs2 con segno)
        -- rs1 = -5, rs2 = 10  --> -5 è minore di 10
        rs1_value <= STD_LOGIC_VECTOR(to_signed(-5, 32));
        rs2_value <= STD_LOGIC_VECTOR(to_signed(10, 32));
        funct3    <= "100";  -- BLT
        wait for 10 ns;
        assert branch_cond = '1' report "ERRORE: BLT preso fallito" severity error;
        report "BLT (-5 < 10 con segno): branch_cond=1 OK";

        -- TEST 4: BGE preso (rs1 >= rs2 con segno)
        -- rs1 = -5, rs2 = -10 --> -5 è maggiore di -10
        rs1_value <= STD_LOGIC_VECTOR(to_signed(-5, 32));
        rs2_value <= STD_LOGIC_VECTOR(to_signed(-10, 32));
        funct3    <= "101";  -- BGE
        wait for 10 ns;
        assert branch_cond = '1' report "ERRORE: BGE preso fallito" severity error;
        report "BGE (-5 >= -10 con segno): branch_cond=1 OK";

        -- TEST 5: BLTU NON preso (rs1 < rs2 senza segno)
        -- rs1 = -1 (che in unsigned è 0xFFFFFFFF, grandissimo!)
        -- rs2 = 10 (che in unsigned è 0x0000000A)
        -- 0xFFFFFFFF NON è minore di 10! 
        rs1_value <= STD_LOGIC_VECTOR(to_signed(-1, 32));
        rs2_value <= STD_LOGIC_VECTOR(to_signed(10, 32));
        funct3    <= "110";  -- BLTU
        wait for 10 ns;
        assert branch_cond = '0' report "ERRORE: BLTU fallito (ha fatto confonto con segno!)" severity error;
        report "BLTU (0xFFFFFFFF non < 10 senza segno): branch_cond=0 OK";

        -- TEST 6: JUMP incondizionato (es. JAL/JALR)
        branch <= '0';
        jump   <= '1';
        wait for 10 ns;
        assert branch_cond = '1' report "ERRORE: JUMP incondizionato fallito" severity error;
        report "JUMP incondizionato: branch_cond=1 OK";

        -- TEST 7: Istruzione normale (nessun branch/jump)
        branch <= '0';
        jump   <= '0';
        wait for 10 ns;
        assert branch_cond = '0' report "ERRORE: Istruzione normale fallita" severity error;
        report "Istruzione normale (ALU): branch_cond=0 OK";

        report "--- TUTTI I TEST OK ---";
        wait;
    end process;
end architecture sim;