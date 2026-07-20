library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port (
        a           : in  STD_LOGIC_VECTOR(31 downto 0); 
        b           : in  STD_LOGIC_VECTOR(31 downto 0);
        s           : in  STD_LOGIC_VECTOR(3 downto 0); 
        alu_res     : out STD_LOGIC_VECTOR(31 downto 0);
        zero        : out STD_LOGIC        
    );
end entity alu;
architecture behavioral of alu is

    signal res : STD_LOGIC_VECTOR(31 downto 0);

begin

    process(a, b, s)
    begin
        case s is

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
            when "0101" =>  -- SLL: logical shift left 
                res <= STD_LOGIC_VECTOR(
                    shift_left(unsigned(a), to_integer(unsigned(b(4 downto 0))))
                );
            when "0110" =>  -- SRL: logicaa shift right
                res <= STD_LOGIC_VECTOR(
                    shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0))))
                );

            when "0111" =>  -- SRA: arithmetic shift right 
                res <= STD_LOGIC_VECTOR(
                    shift_right(signed(a), to_integer(unsigned(b(4 downto 0))))
                );

            when "1000" =>  -- SLT: set less than  signed
                if signed(a) < signed(b) then
                    res <= (0 => '1', others => '0');
                else
                    res <= (others => '0');
                end if;
            when "1001" =>  -- SLTU: set less than unsigned
                if unsigned(a) < unsigned(b) then
                    res <= (0 => '1', others => '0');
                else
                    res <= (others => '0');
                end if;
            when others =>
                res <= (others => '0');
        end case;
    end process;

    alu_res <= res;

    zero <= '1' when unsigned(res) = 0 else '0';

end architecture behavioral;
