-- Register File per processore RISC-V RV32I
-- 32 registri da 32 bit, 2 porte di lettura e 1 porta di scrittura

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    Port (
        clk      : in  STD_LOGIC;                       -- clock
        rst      : in  STD_LOGIC;                       -- reset sincrono

        -- porta di lettura A (per operando a della ALU)
        indice_a   : in  STD_LOGIC_VECTOR(4 downto 0);   -- indice registro (0-31)
        valore_a   : out STD_LOGIC_VECTOR(31 downto 0);  -- valore letto

        -- porta di lettura B (per operando b della ALU)
        indice_b   : in  STD_LOGIC_VECTOR(4 downto 0);   -- indice registro (0-31)
        valore_b   : out STD_LOGIC_VECTOR(31 downto 0);  -- valore letto

        -- porta di scrittura (per salvare il risultato della ALU)
        wr_en    : in  STD_LOGIC;                       -- 1 = scrivi, 0 = non fare niente
        indice_wr  : in  STD_LOGIC_VECTOR(4 downto 0);   -- indice registro destinazione
        valore_wr  : in  STD_LOGIC_VECTOR(31 downto 0)   -- valore da scrivere
    );
end entity register_file;

architecture behavioral of register_file is

    -- array di 32 registri da 32 bit
    -- type definisce un nuovo tipo: un array di 32 elementi, ognuno da 32 bit
    type reg_array is array(0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal regs : reg_array := (others => (others => '0'));

begin

    -- scrittura sincrona: avviene solo sul fronte di salita del clock
    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then
                -- reset: azzera tutti i registri
                regs <= (others => (others => '0'));

            elsif wr_en = '1' and indice_wr /= "00000" then
                -- scrivi solo se:
                -- 1. la scrittura e' abilitata (wr_en = 1)
                -- 2. il registro destinazione NON e' x0
                --    (x0 e' hardwired a 0 in RISC-V, non si puo' modificare)
                regs(to_integer(unsigned(indice_wr))) <= valore_wr;

            end if;
        end if;
    end process;

    -- lettura combinatoria: risponde subito senza aspettare il clock
    -- se leggi x0 ottieni sempre 0, qualunque cosa ci sia scritta
    valore_a <= (others => '0') when indice_a = "00000"
              else regs(to_integer(unsigned(indice_a)));

    valore_b <= (others => '0') when indice_b = "00000"
              else regs(to_integer(unsigned(indice_b)));

end architecture behavioral;
