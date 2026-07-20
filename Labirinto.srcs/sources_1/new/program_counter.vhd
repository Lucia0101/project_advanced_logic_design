library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter is
    Port (
        clk      : in  STD_LOGIC;       
        rst      : in  STD_LOGIC;      
        pc_load  : in STD_LOGIC;       
        pc_src   : in  STD_LOGIC;
        target   : in  STD_LOGIC_VECTOR(31 downto 0);
        pc_out   : out STD_LOGIC_VECTOR(31 downto 0);
        pc_plus4 : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity program_counter;

architecture behavioral of program_counter is
    signal pc_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal pc_next : STD_LOGIC_VECTOR(31 downto 0);

begin
    pc_next <= STD_LOGIC_VECTOR(unsigned(pc_reg) + 4) when pc_src = '0'
               else target;
               
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc_reg <= (others => '0');
                
            elsif pc_load = '1' then
                pc_reg <= pc_next;
            end if;
        end if;
    end process;

    pc_out   <= pc_reg;
    pc_plus4 <= STD_LOGIC_VECTOR(unsigned(pc_reg) + 4);

end architecture behavioral;