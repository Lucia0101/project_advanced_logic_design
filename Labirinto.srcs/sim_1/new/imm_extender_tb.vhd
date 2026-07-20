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

        istruzione <= "00000000010100000000000010010011";
        tipo_imm   <= "000";
        wait for 10 ns;
        assert imm_out = STD_LOGIC_VECTOR(to_signed(5, 32))
            report "ERRORE: I-type positivo" severity error;
        report "I-type +5: OK";

        istruzione <= "11111111111100000000000010010011";
        tipo_imm   <= "000";
        wait for 10 ns;
        assert imm_out = STD_LOGIC_VECTOR(to_signed(-1, 32))
            report "ERRORE: I-type negativo" severity error;
        report "I-type -1: OK";

        istruzione <= "00000000000000000010010000100011";
        tipo_imm   <= "001";
        wait for 10 ns;
        assert imm_out = STD_LOGIC_VECTOR(to_signed(8, 32))
            report "ERRORE: S-type" severity error;
        report "S-type +8: OK";

        istruzione <= "00000000000000000001000010110111";
        tipo_imm   <= "011";
        wait for 10 ns;
        assert imm_out = X"00001000"
            report "ERRORE: U-type LUI" severity error;
        report "U-type LUI: OK";

        istruzione <= "00000000000000000000010001100011";
        tipo_imm   <= "010";
        wait for 10 ns;
        assert imm_out = STD_LOGIC_VECTOR(to_signed(8, 32))
            report "ERRORE: B-type" severity error;
        report "B-type +8: OK";
        
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

