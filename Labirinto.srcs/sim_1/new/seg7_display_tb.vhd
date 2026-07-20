library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seg7_display_tb is
end entity seg7_display_tb;

architecture sim of seg7_display_tb is
    signal clk   : STD_LOGIC := '0';
    signal rst   : STD_LOGIC := '1';
    signal value : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal seg   : STD_LOGIC_VECTOR(6 downto 0);
    signal an    : STD_LOGIC_VECTOR(7 downto 0);
    signal dp    : STD_LOGIC;
    constant CLK_PERIOD : time := 10 ns;
    function anodo_attivo(a : STD_LOGIC_VECTOR(7 downto 0)) return integer is
    begin
        for i in 0 to 7 loop
            if a(i) = '0' then
                return i;
            end if;
        end loop;
        return -1;
    end function;
    function seg_to_hex(s : STD_LOGIC_VECTOR(6 downto 0)) return string is
    begin
        case s is
            when "1000000" => return "0";
            when "1111001" => return "1";
            when "0100100" => return "2";
            when "0110000" => return "3";
            when "0011001" => return "4";
            when "0010010" => return "5";
            when "0000010" => return "6";
            when "1111000" => return "7";
            when "0000000" => return "8";
            when "0010000" => return "9";
            when "0001000" => return "A";
            when "0000011" => return "b";
            when "1000110" => return "C";
            when "0100001" => return "d";
            when "0000110" => return "E";
            when "0001110" => return "F";
            when others    => return "?";
        end case;
    end function;

begin
    DUT: entity work.seg7_display
        port map (
            clk   => clk,
            rst   => rst,
            value => value,
            seg   => seg,
            an    => an,
            dp    => dp
        );

    clk <= not clk after CLK_PERIOD / 2;

    stimoli: process
        variable cifra : integer;
    begin
        rst   <= '1';
        value <= X"1234ABCD";
        wait for CLK_PERIOD * 4;
        rst   <= '0';
        report "=== Reset rilasciato, valore = 0x1234ABCD ===";
        for n in 0 to 7 loop
            wait for 1310 us;
            cifra := anodo_attivo(an);
            report "Cifra attiva: " & integer'image(cifra)
                 & " mostra: " & seg_to_hex(seg);
        end loop;

        report "=== TEST COMPLETATO ===";
        report "Le cifre di 0x1234ABCD dovrebbero apparire una alla volta";
        wait;

    end process;
end architecture sim;
