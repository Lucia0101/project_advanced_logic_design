library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alu_control is
    Port (
        
        alu_op   : in  STD_LOGIC_VECTOR(1 downto 0);
        funct3   : in  STD_LOGIC_VECTOR(2 downto 0);
        funct7_5 : in  STD_LOGIC;
        opcode_5 : in  STD_LOGIC;
        op_sel   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity alu_control;

architecture behavioral of alu_control is
begin

    process(alu_op, funct3, funct7_5, opcode_5)
    begin
        case alu_op is
            when "00" =>
                op_sel <= "0000"; 
            when "01" =>
                op_sel <= "0001";
            when "10" =>
                case funct3 is
                    when "000" =>
                      
                        if funct7_5 = '1' and opcode_5 = '1' then
                            op_sel <= "0001"; 
                        else
                            op_sel <= "0000";  
                        end if;
                        
                    when "111" => op_sel <= "0010";  -- AND
                    when "110" => op_sel <= "0011";  -- OR
                    when "100" => op_sel <= "0100";  -- XOR
                    when "001" => op_sel <= "0101";  -- SLL
                    when "101" =>
                        if funct7_5 = '1' then
                            op_sel <= "0111";  -- SRA
                        else
                            op_sel <= "0110";  -- SRL
                        end if;
                    when "010" => op_sel <= "1000";  -- SLT
                    when "011" => op_sel <= "1001";  -- SLTU
                    when others => op_sel <= "0000";
                end case;
            -- LUI
            when "11" =>
                op_sel <= "0000";  -- ADD
            when others =>
                op_sel <= "0000";

        end case;
    end process;
end architecture behavioral;