library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    Port (
        clk      : in  STD_LOGIC;
        addr     : in  STD_LOGIC_VECTOR(31 downto 0);
        wr_en    : in  STD_LOGIC;
        rd_en    : in  STD_LOGIC;
        wr_data  : in  STD_LOGIC_VECTOR(31 downto 0);
        rd_data  : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity data_memory;

architecture behavioral of data_memory is

    type ram_array is array(0 to 1023) of STD_LOGIC_VECTOR(31 downto 0);
    signal ram : ram_array := (others => (others => '0'));

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if wr_en = '1' then
                ram(to_integer(unsigned(addr(11 downto 2)))) <= wr_data;
            end if;
        end if;
    end process;

    rd_data <= ram(to_integer(unsigned(addr(11 downto 2)))) when rd_en = '1'
               else (others => '0');

end architecture behavioral;