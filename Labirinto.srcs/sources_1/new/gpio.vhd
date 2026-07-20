library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gpio is
    Port (
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        addr       : in  STD_LOGIC_VECTOR(3 downto 0); 
        wr_data    : in  STD_LOGIC_VECTOR(31 downto 0); 
        rd_data    : out STD_LOGIC_VECTOR(31 downto 0); 
        wr_en      : in  STD_LOGIC;       
        switches   : in  STD_LOGIC_VECTOR(15 downto 0);
        buttons    : in  STD_LOGIC_VECTOR(4 downto 0); 
        leds       : out STD_LOGIC_VECTOR(15 downto 0); 
        seg        : out STD_LOGIC_VECTOR(6 downto 0);
        an         : out STD_LOGIC_VECTOR(7 downto 0);
        dp         : out STD_LOGIC
    );
end entity gpio;

architecture behavioral of gpio is
    signal led_reg     : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal display_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    constant REG_SWITCHES : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    constant REG_BUTTONS  : STD_LOGIC_VECTOR(3 downto 0) := "0100"; 
    constant REG_LEDS     : STD_LOGIC_VECTOR(3 downto 0) := "1000"; 
    constant REG_DISPLAY  : STD_LOGIC_VECTOR(3 downto 0) := "1100"; 

begin
    process(clk, rst)
    begin
        if rst = '1' then
            led_reg     <= (others => '0');
            display_reg <= (others => '0');
        elsif rising_edge(clk) then
            if wr_en = '1' then
                case addr is
                    when REG_LEDS =>
                        led_reg <= wr_data(15 downto 0);
                    when REG_DISPLAY =>
                        display_reg <= wr_data;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;
    
    process(addr, switches, buttons)
    begin
        case addr is
            when REG_SWITCHES =>
                rd_data <= X"0000" & switches;
            when REG_BUTTONS =>
                rd_data <= (31 downto 5 => '0') & buttons;
            when others =>
                rd_data <= (others => '0');
        end case;
    end process;
    
    leds <= led_reg;
    DISP_inst: entity work.seg7_display
        port map (
            clk   => clk,
            rst   => rst,
            value => display_reg,
            seg   => seg,
            an    => an,
            dp    => dp
        );

end architecture behavioral;