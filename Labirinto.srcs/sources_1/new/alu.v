
-- ============================================================
--  ALU - Arithmetic Logic Unit per processore RISC-V RV32I
--  Supporta tutte le operazioni base dell'ISA RV32I
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;       -- per operazioni aritmetiche su vettori

entity alu is
    Port (
        -- Operando A: primo argomento (32 bit)
        src_a   : in  STD_LOGIC_VECTOR(31 downto 0);
        -- Operando B: secondo argomento (32 bit)
        src_b   : in  STD_LOGIC_VECTOR(31 downto 0);
        -- Codice operazione: dice alla ALU cosa fare (4 bit = 16 operazioni possibili)
        alu_ctrl : in  STD_LOGIC_VECTOR(3 downto 0);
        -- Risultato dell'operazione (32 bit)
        result  : out STD_LOGIC_VECTOR(31 downto 0);
        -- Flag zero: vale '1' se il risultato e' zero (utile per le istruzioni di branch)
        zero    : out STD_LOGIC
    );
end entity alu;

architecture behavioral of alu is

    -- Segnale interno per il risultato (lo usiamo anche per calcolare zero)
    signal result_int : STD_LOGIC_VECTOR(31 downto 0);

begin

    -- --------------------------------------------------------
    -- Processo principale: calcola l'operazione richiesta
    -- Questo processo e' COMBINATORIO (nessun clock!)
    -- Si riesegue ogni volta che cambia src_a, src_b o alu_ctrl
    -- --------------------------------------------------------
    process(src_a, src_b, alu_ctrl)
    begin
        case alu_ctrl is

            -- ADD (0000): addizione con segno
            -- Usata da: R-type ADD, I-type ADDI, LOAD, STORE, JAL, JALR
            when "0000" =>
                result_int <= STD_LOGIC_VECTOR(
                    signed(src_a) + signed(src_b)
                );

            -- SUB (0001): sottrazione con segno
            -- Usata da: R-type SUB, BEQ/BNE (tramite zero flag)
            when "0001" =>
                result_int <= STD_LOGIC_VECTOR(
                    signed(src_a) - signed(src_b)
                );

            -- AND (0010): AND bit a bit
            -- Usata da: R-type AND, I-type ANDI
            when "0010" =>
                result_int <= src_a AND src_b;

            -- OR (0011): OR bit a bit
            -- Usata da: R-type OR, I-type ORI
            when "0011" =>
                result_int <= src_a OR src_b;

            -- XOR (0100): XOR bit a bit
            -- Usata da: R-type XOR, I-type XORI
            when "0100" =>
                result_int <= src_a XOR src_b;

            -- SLL (0101): Shift Left Logical
            -- Shifta src_a a sinistra di src_b(4:0) posizioni
            -- Usata da: R-type SLL, I-type SLLI
            when "0101" =>
                result_int <= STD_LOGIC_VECTOR(
                    shift_left(unsigned(src_a), to_integer(unsigned(src_b(4 downto 0))))
                );

            -- SRL (0110): Shift Right Logical (inserisce 0 a sinistra)
            -- Usata da: R-type SRL, I-type SRLI
            when "0110" =>
                result_int <= STD_LOGIC_VECTOR(
                    shift_right(unsigned(src_a), to_integer(unsigned(src_b(4 downto 0))))
                );

            -- SRA (0111): Shift Right Arithmetic (mantiene il segno!)
            -- Inserisce copie del bit di segno a sinistra
            -- Usata da: R-type SRA, I-type SRAI
            when "0111" =>
                result_int <= STD_LOGIC_VECTOR(
                    shift_right(signed(src_a), to_integer(unsigned(src_b(4 downto 0))))
                );

            -- SLT (1000): Set Less Than (con segno)
            -- Risultato = 1 se src_a < src_b (con segno), altrimenti 0
            -- Usata da: R-type SLT, I-type SLTI, BLT, BGE
            when "1000" =>
                if signed(src_a) < signed(src_b) then
                    result_int <= (0 => '1', others => '0');  -- ...0001
                else
                    result_int <= (others => '0');             -- ...0000
                end if;

            -- SLTU (1001): Set Less Than Unsigned
            -- Come SLT ma tratta i numeri come senza segno
            -- Usata da: R-type SLTU, I-type SLTIU, BLTU, BGEU
            when "1001" =>
                if unsigned(src_a) < unsigned(src_b) then
                    result_int <= (0 => '1', others => '0');
                else
                    result_int <= (others => '0');
                end if;

            -- Default: se riceviamo un codice non riconosciuto, output = 0
            when others =>
                result_int <= (others => '0');

        end case;
    end process;

    -- --------------------------------------------------------
    -- Assegnazione degli output
    -- --------------------------------------------------------

    -- Porta il risultato interno all'uscita
    result <= result_int;

    -- Zero flag: vale '1' solo se TUTTI i bit del risultato sono '0'
    -- Questo serve per implementare le istruzioni di branch (BEQ, BNE, ecc.)
   zero <= '1' when unsigned(result_int) = 0 else '0';

end architecture behavioral;
