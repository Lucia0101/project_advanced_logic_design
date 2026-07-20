library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    Port (
        clk      : in  STD_LOGIC; 
        rst      : in  STD_LOGIC; 
        indice_a   : in  STD_LOGIC_VECTOR(4 downto 0); 
        valore_a   : out STD_LOGIC_VECTOR(31 downto 0);
        indice_b   : in  STD_LOGIC_VECTOR(4 downto 0);
        valore_b   : out STD_LOGIC_VECTOR(31 downto 0);
        wr_en    : in  STD_LOGIC;                      
        indice_wr  : in  STD_LOGIC_VECTOR(4 downto 0); 
        valore_wr  : in  STD_LOGIC_VECTOR(31 downto 0) 
    );
end entity register_file;

architecture behavioral of register_file is

    type reg_array is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal regs : reg_array := (others => (others => '0'));

begin
    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then
                regs <= (others => (others => '0'));

            elsif wr_en = '1' and indice_wr /= "00000" then
                regs(to_integer(unsigned(indice_wr))) <= valore_wr;

            end if;
        end if;
    end process;

    valore_a <= (others => '0') when indice_a = "00000"
              else regs(to_integer(unsigned(indice_a)));

    valore_b <= (others => '0') when indice_b = "00000"
              else regs(to_integer(unsigned(indice_b)));

end architecture behavioral;
