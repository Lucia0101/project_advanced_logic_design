library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity imm_extender is
    Port (
        istruzione : in  STD_LOGIC_VECTOR(31 downto 0);
        tipo_imm   : in  STD_LOGIC_VECTOR(2 downto 0);
        imm_out    : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity imm_extender;

architecture behavioral of imm_extender is
begin

    process(istruzione, tipo_imm)
    begin
        case tipo_imm is
            -- I-TYPE
            when "000" =>
                imm_out <= (31 downto 12 => istruzione(31)) 
                         & istruzione(31 downto 20);
            -- S-TYPE
            when "001" =>
                imm_out <= (31 downto 12 => istruzione(31))
                         & istruzione(31 downto 25)
                         & istruzione(11 downto 7);
            -- B-TYPE
            when "010" =>
                imm_out <= (31 downto 13 => istruzione(31))
                         & istruzione(31)
                         & istruzione(7)
                         & istruzione(30 downto 25)
                         & istruzione(11 downto 8)
                         & '0';
            -- U-TYPE
            when "011" =>
                imm_out <= istruzione(31 downto 12)
                         & (11 downto 0 => '0');
            -- J-TYPE
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


