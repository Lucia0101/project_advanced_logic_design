-- imm_extender.vhd
-- Estensore di segno per gli immediati RISC-V RV32I
-- Prende i 32 bit dell'istruzione e ricostruisce l'immediato a 32 bit
-- in base al tipo di formato (I, S, B, U, J)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity imm_extender is
    Port (
        -- i 32 bit dell'istruzione (senza opcode non bastano, serve tutto)
        istruzione : in  STD_LOGIC_VECTOR(31 downto 0);

        -- tipo di immediato da estrarre:
        -- "000" = I-type  (ADDI, LOAD, JALR)
        -- "001" = S-type  (STORE)
        -- "010" = B-type  (BRANCH)
        -- "011" = U-type  (LUI, AUIPC)
        -- "100" = J-type  (JAL)
        tipo_imm   : in  STD_LOGIC_VECTOR(2 downto 0);

        -- immediato esteso a 32 bit con segno
        imm_out    : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity imm_extender;

architecture behavioral of imm_extender is
begin

    process(istruzione, tipo_imm)
    begin
        case tipo_imm is

            -- I-TYPE: imm[11:0] = instr[31:20]
            -- usato da: ADDI, SLTI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, LW, JALR
            when "000" =>
                imm_out <= (31 downto 12 => istruzione(31)) -- replica il bit di segno
                         & istruzione(31 downto 20);

            -- S-TYPE: imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
            -- usato da: SW, SH, SB
            when "001" =>
                imm_out <= (31 downto 12 => istruzione(31))
                         & istruzione(31 downto 25)
                         & istruzione(11 downto 7);

            -- B-TYPE: i bit sono sparsi nell'istruzione (scelta ISA per semplicita' hardware)
            -- imm[12]   = instr[31]
            -- imm[11]   = instr[7]
            -- imm[10:5] = instr[30:25]
            -- imm[4:1]  = instr[11:8]
            -- imm[0]    = sempre 0 (gli indirizzi sono sempre pari)
            when "010" =>
                imm_out <= (31 downto 13 => istruzione(31))
                         & istruzione(31)
                         & istruzione(7)
                         & istruzione(30 downto 25)
                         & istruzione(11 downto 8)
                         & '0';

            -- U-TYPE: imm[31:12] = instr[31:12], imm[11:0] = 0
            -- usato da: LUI, AUIPC
            -- carica i 20 bit alti, i 12 bassi sono zero
            when "011" =>
                imm_out <= istruzione(31 downto 12)
                         & (11 downto 0 => '0');

            -- J-TYPE: anche qui i bit sono sparsi
            -- imm[20]    = instr[31]
            -- imm[19:12] = instr[19:12]
            -- imm[11]    = instr[20]
            -- imm[10:1]  = instr[30:21]
            -- imm[0]     = sempre 0
            when "100" =>
                imm_out <= (31 downto 21 => istruzione(31))
                         & istruzione(31)
                         & istruzione(19 downto 12)
                         & istruzione(20)
                         & istruzione(30 downto 21)
                         & '0';

            when others =>
                imm_out <= (others => '0');

        end case;
    end process;

end architecture behavioral;


