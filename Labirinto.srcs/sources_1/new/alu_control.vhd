-- alu_control.vhd
-- ALU Control per processore RISC-V RV32I
-- Traduce alu_op + funct3 + funct7 nel codice operazione a 4 bit per la ALU

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_control is
    Port (
        -- segnale a 2 bit dalla Control Unit
        -- "00" = ADD forzato (LOAD/STORE)
        -- "01" = SUB forzato (BRANCH)
        -- "10" = guarda funct3 e funct7 (R-type e I-type ALU)
        -- "11" = LUI (passa immediato)
        alu_op   : in  STD_LOGIC_VECTOR(1 downto 0);

        -- bit dell'istruzione che specificano l'operazione esatta
        funct3   : in  STD_LOGIC_VECTOR(2 downto 0);
        funct7_5 : in  STD_LOGIC;  -- solo bit 30 di funct7
        opcode_5 : in  STD_LOGIC;
        -- codice operazione a 4 bit per la ALU (stesso schema di op_sel in alu.vhd)
        op_sel   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity alu_control;

architecture behavioral of alu_control is
begin

    process(alu_op, funct3, funct7_5, opcode_5)
    begin
        case alu_op is

            -- LOAD e STORE: la ALU calcola sempre l'indirizzo con ADD
            when "00" =>
                op_sel <= "0000";  -- ADD

            -- BRANCH: la ALU fa sempre SUB per il confronto
            -- il flag zero dice se i due registri sono uguali (BEQ)
            when "01" =>
                op_sel <= "0001";  -- SUB

            -- R-TYPE e I-TYPE ALU: guarda funct3 e funct7 per l'operazione esatta
            when "10" =>
                case funct3 is
                    when "000" =>
                        -- Fai SUB solo se il bit 30 è '1' E l'istruzione è R-Type
                        if funct7_5 = '1' and opcode_5 = '1' then
                            op_sel <= "0001";  -- SUB
                        else
                            op_sel <= "0000";  -- ADD (o ADDI)
                        end if;
                        
                    when "111" => op_sel <= "0010";  -- AND
                    when "110" => op_sel <= "0011";  -- OR
                    when "100" => op_sel <= "0100";  -- XOR
                    when "001" => op_sel <= "0101";  -- SLL
                    when "101" =>
                        -- SRL o SRA: anche qui funct7_5 decide
                        if funct7_5 = '1' then
                            op_sel <= "0111";  -- SRA (mantiene il segno)
                        else
                            op_sel <= "0110";  -- SRL (inserisce zeri)
                        end if;
                    when "010" => op_sel <= "1000";  -- SLT
                    when "011" => op_sel <= "1001";  -- SLTU
                    when others => op_sel <= "0000";
                end case;

            -- LUI: l'immediato viene passato direttamente, usiamo ADD con 0
            when "11" =>
                op_sel <= "0000";  -- ADD (rs1 sara' x0, quindi risultato = immediato)

            when others =>
                op_sel <= "0000";

        end case;
    end process;

end architecture behavioral;