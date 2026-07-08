-- imm_extender_tb.vhd
-- Testbench per l'Immediate Extender RISC-V

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imm_extender_tb is
end entity imm_extender_tb;

architecture sim of imm_extender_tb is

    signal istruzione : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal tipo_imm   : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
    signal imm_out    : STD_LOGIC_VECTOR(31 downto 0);

begin

    DUT: entity work.imm_extender
        port map (
            istruzione => istruzione,
            tipo_imm   => tipo_imm,
            imm_out    => imm_out
        );

    stimoli: process
    begin

        -- TEST 1: I-TYPE con immediato positivo
        -- ADDI x1, x0, 5  ?  immediato = 5 = 0x005
        -- instr[31:20] = 000000000101
        istruzione <= "00000000010100000000000010010011";
        tipo_imm   <= "000";
        wait for 10 ns;
        assert imm_out = STD_LOGIC_VECTOR(to_signed(5, 32))
            report "ERRORE: I-type positivo" severity error;
        report "I-type +5: OK";

        -- TEST 2: I-TYPE con immediato negativo
        -- immediato = -1 ? instr[31:20] = 111111111111
        istruzione <= "11111111111100000000000010010011";
        tipo_imm   <= "000";
        wait for 10 ns;
        assert imm_out = STD_LOGIC_VECTOR(to_signed(-1, 32))
            report "ERRORE: I-type negativo" severity error;
        report "I-type -1: OK";

        -- TEST 3: S-TYPE con immediato positivo
        -- SW: imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
        -- immediato = 8 = 0b00000001000
        -- instr[31:25] = 0000000, instr[11:7] = 01000
        istruzione <= "00000000000000000010010000100011";
        tipo_imm   <= "001";
        wait for 10 ns;
        assert imm_out = STD_LOGIC_VECTOR(to_signed(8, 32))
            report "ERRORE: S-type" severity error;
        report "S-type +8: OK";

        -- TEST 4: U-TYPE con LUI
        -- LUI x1, 1  ?  immediato = 0x00001000 (1 nei bit alti)
        -- instr[31:12] = 00000000000000000001
        istruzione <= "00000000000000000001000010110111";
        tipo_imm   <= "011";
        wait for 10 ns;
        assert imm_out = X"00001000"
            report "ERRORE: U-type LUI" severity error;
        report "U-type LUI: OK";

        -- TEST 5: B-TYPE con branch positivo
        -- BEQ con offset = 8 (salta 2 istruzioni avanti)
        -- imm = 0b0000000001000 = 8
        -- instr[31]=0, instr[7]=0, instr[30:25]=000000, instr[11:8]=0100
        istruzione <= "00000000000000000000010001100011";
        tipo_imm   <= "010";
        wait for 10 ns;
        assert imm_out = STD_LOGIC_VECTOR(to_signed(8, 32))
            report "ERRORE: B-type" severity error;
        report "B-type +8: OK";
        
        -- TEST 6: J-TYPE con jump positivo
        -- JAL x1, 2048  ->  immediato = 2048 = 0x00000800
        -- imm[2]=0, imm[19:12]=00000000, imm[4]=1, imm[10:1]=0000000000
        -- Ricostruendo l'istruzione:
        -- instr[3]=0, instr[30:21]=0000000000, instr[2]=1, instr[19:12]=00000000
        -- rd = x1 (00001), opcode = JAL (1101111)
        istruzione <= "00000000000100000000000011101111";
        istruzione <= "00000000000100000000000011101111";
        tipo_imm   <= "100";
        wait for 10 ns;
        assert imm_out = STD_LOGIC_VECTOR(to_signed(2048, 32))
            report "ERRORE: J-type fallito" severity error;
        report "J-type +2048: OK";

        report "--- TUTTI I TEST OK ---";
        wait;

    end process;

end architecture sim;

