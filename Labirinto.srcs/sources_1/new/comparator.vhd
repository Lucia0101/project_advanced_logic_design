library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comparator is
    Port (
        rs1_value    : in  STD_LOGIC_VECTOR(31 downto 0);
        rs2_value    : in  STD_LOGIC_VECTOR(31 downto 0);
        branch       : in  STD_LOGIC;
        jump         : in  STD_LOGIC;
        funct3       : in  STD_LOGIC_VECTOR(2 downto 0);
        branch_cond  : out STD_LOGIC
    );
end entity comparator;

architecture behavioral of comparator is
    signal prendi_branch : STD_LOGIC;

begin
    process(branch, funct3, rs1_value, rs2_value)
    begin
        prendi_branch <= '0'; 

        if branch = '1' then
            case funct3 is
                when "000" =>
                    if rs1_value = rs2_value then prendi_branch <= '1'; end if;

                when "001" =>
                    if rs1_value /= rs2_value then prendi_branch <= '1'; end if;

                when "100" =>  
                    if signed(rs1_value) < signed(rs2_value) then prendi_branch <= '1'; end if;

                when "101" =>
                    if signed(rs1_value) >= signed(rs2_value) then prendi_branch <= '1'; end if;

                when "110" =>
                    if unsigned(rs1_value) < unsigned(rs2_value) then prendi_branch <= '1'; end if;

                when "111" =>
                    if unsigned(rs1_value) >= unsigned(rs2_value) then prendi_branch <= '1'; end if;

                when others =>
                    prendi_branch <= '0';
            end case;
        end if;
    end process;
    branch_cond <= prendi_branch OR jump;
end architecture behavioral;
