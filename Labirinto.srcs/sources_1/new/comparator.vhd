-- comparator.vhd (o branch_logic.vhd)
-- Valuta le condizioni di branch e genera il segnale pc_src (branch_cond)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comparator is
    Port (
        -- Dati in uscita dal Register File
        rs1_value    : in  STD_LOGIC_VECTOR(31 downto 0);
        rs2_value    : in  STD_LOGIC_VECTOR(31 downto 0);

        -- Segnali di controllo dalla Control Unit
        branch       : in  STD_LOGIC;
        jump         : in  STD_LOGIC;
        funct3       : in  STD_LOGIC_VECTOR(2 downto 0);

        -- Uscita che va al MUX del Program Counter (chiamata branch_cond o pc_src)
        branch_cond  : out STD_LOGIC
    );
end entity comparator;

architecture behavioral of comparator is

    signal prendi_branch : STD_LOGIC;

begin

    process(branch, funct3, rs1_value, rs2_value)
    begin
        prendi_branch <= '0';  -- default

        if branch = '1' then
            case funct3 is
                when "000" =>  -- BEQ: rs1 == rs2
                    if rs1_value = rs2_value then prendi_branch <= '1'; end if;

                when "001" =>  -- BNE: rs1 != rs2
                    if rs1_value /= rs2_value then prendi_branch <= '1'; end if;

                when "100" =>  -- BLT: rs1 < rs2 (con segno)
                    -- Il cast a "signed" permette a VHDL di confrontare i numeri negativi
                    if signed(rs1_value) < signed(rs2_value) then prendi_branch <= '1'; end if;

                when "101" =>  -- BGE: rs1 >= rs2 (con segno)
                    if signed(rs1_value) >= signed(rs2_value) then prendi_branch <= '1'; end if;

                when "110" =>  -- BLTU: rs1 < rs2 (senza segno)
                    -- Il cast a "unsigned" fa un confronto puramente binario
                    if unsigned(rs1_value) < unsigned(rs2_value) then prendi_branch <= '1'; end if;

                when "111" =>  -- BGEU: rs1 >= rs2 (senza segno)
                    if unsigned(rs1_value) >= unsigned(rs2_value) then prendi_branch <= '1'; end if;

                when others =>
                    prendi_branch <= '0';
            end case;
        end if;
    end process;

    -- L'uscita è 1 se la condizione del branch è vera, OPPURE se è un jump incondizionato (JAL/JALR)
    branch_cond <= prendi_branch OR jump;

end architecture behavioral;
