-- alu.vhd
-- ALU per processore RISC-V RV32I
-- Operazioni supportate: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port (
        a           : in  STD_LOGIC_VECTOR(31 downto 0);  -- primo operando
        b           : in  STD_LOGIC_VECTOR(31 downto 0);  -- secondo operando
        seleziona   : in  STD_LOGIC_VECTOR(3 downto 0);   -- seleziona operazione
        alu_res     : out STD_LOGIC_VECTOR(31 downto 0);  -- risultato
        zero        : out STD_LOGIC                       -- 1 se risultato = 0
    );
end entity alu;

architecture behavioral of alu is

    -- segnale interno: serve perche' le porte out non si possono rileggere
    -- lo uso sia per l'uscita che per calcolare il flag zero
    signal res : STD_LOGIC_VECTOR(31 downto 0);

begin

    -- processo combinatorio: nessun clock, ricalcola ogni volta che cambiano gli input
    process(a, b, seleziona)
    begin
        case seleziona is

            when "0000" =>  -- ADD
                res <= STD_LOGIC_VECTOR(signed(a) + signed(b));

            when "0001" =>  -- SUB
                res <= STD_LOGIC_VECTOR(signed(a) - signed(b));

            when "0010" =>  -- AND bit a bit
                res <= a AND b;

            when "0011" =>  -- OR bit a bit
                res <= a OR b;

            when "0100" =>  -- XOR bit a bit
                res <= a XOR b;

            when "0101" =>  -- SLL: shift left logico
                -- i bit di shift sono solo i 5 bit meno significativi di b (max shift = 31)
                res <= STD_LOGIC_VECTOR(
                    shift_left(unsigned(a), to_integer(unsigned(b(4 downto 0))))
                );

            when "0110" =>  -- SRL: shift right logico (inserisce 0 a sinistra)
                res <= STD_LOGIC_VECTOR(
                    shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0))))
                );

            when "0111" =>  -- SRA: shift right aritmetico (mantiene il segno)
                -- usando signed, shift_right replica il bit di segno
                res <= STD_LOGIC_VECTOR(
                    shift_right(signed(a), to_integer(unsigned(b(4 downto 0))))
                );

            when "1000" =>  -- SLT: set less than con segno
                if signed(a) < signed(b) then
                    res <= (0 => '1', others => '0');
                else
                    res <= (others => '0');
                end if;

            when "1001" =>  -- SLTU: set less than senza segno
                if unsigned(a) < unsigned(b) then
                    res <= (0 => '1', others => '0');
                else
                    res <= (others => '0');
                end if;

            when others =>
                res <= (others => '0');

        end case;
    end process;

    -- collega il segnale interno all'uscita
    alu_res <= res;

    -- flag zero: attivo quando tutti i bit del risultato sono 0
    -- usato dalla control unit per i branch (BEQ, BNE...)
    zero <= '1' when unsigned(res) = 0 else '0';

end architecture behavioral;
