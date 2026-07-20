library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seg7_display is
    Port (
        clk    : in  STD_LOGIC;
        rst    : in  STD_LOGIC;
        value  : in  STD_LOGIC_VECTOR(31 downto 0);
        seg    : out STD_LOGIC_VECTOR(6 downto 0); 
        an     : out STD_LOGIC_VECTOR(7 downto 0); 
        dp     : out STD_LOGIC 
    );
end entity seg7_display;

architecture behavioral of seg7_display is
    signal refresh_cnt : unsigned(19 downto 0) := (others => '0');
    signal digit_sel   : integer range 0 to 7;
    signal hex_digit   : STD_LOGIC_VECTOR(3 downto 0);

begin
    process(clk, rst)
    begin
        if rst = '1' then
            refresh_cnt <= (others => '0');
        elsif rising_edge(clk) then
            refresh_cnt <= refresh_cnt + 1;
        end if;
    end process;

    digit_sel <= to_integer(refresh_cnt(19 downto 17));
    with digit_sel select
        hex_digit <= value(3 downto 0)   when 0,
                     value(7 downto 4)   when 1,
                     value(11 downto 8)  when 2,
                     value(15 downto 12) when 3,
                     value(19 downto 16) when 4,
                     value(23 downto 20) when 5,
                     value(27 downto 24) when 6,
                     value(31 downto 28) when 7,
                     "0000"              when others;
    process(digit_sel)
    begin
        an <= "11111111";   
        an(digit_sel) <= '0';
    end process;
    DEC_inst: entity work.hex_to_7seg
        port map (
           hex => hex_digit,
            seg => seg
        );
    dp <= '1';

end architecture behavioral;