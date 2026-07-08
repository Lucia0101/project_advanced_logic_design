-- data_memory.vhd
-- Memoria dati (RAM) per processore RISC-V RV32I

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    Port (
        clk      : in  STD_LOGIC;

        -- indirizzo: usiamo solo i bit [11:2] per indirizzare 1024 word
        addr     : in  STD_LOGIC_VECTOR(31 downto 0);

        -- segnali per lettura e scrittura
        wr_en    : in  STD_LOGIC;                       -- 1 = abilita scrittura (STORE)
        rd_en    : in  STD_LOGIC;                       -- 1 = abilita lettura (LOAD)

        -- dato da scrivere in memoria (proveniente da rs2)
        wr_data  : in  STD_LOGIC_VECTOR(31 downto 0);

        -- dato letto dalla memoria
        rd_data  : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity data_memory;

architecture behavioral of data_memory is

    -- array della memoria: 1024 word da 32 bit
    -- a differenza della ROM, qui usiamo signal perche' i valori cambiano nel tempo
    type ram_array is array(0 to 1023) of STD_LOGIC_VECTOR(31 downto 0);
    signal ram : ram_array := (others => (others => '0'));

begin

    -- processo sincrono: gestisce sia scrittura che lettura
    process(clk)
    begin
        if rising_edge(clk) then

            -- scrittura: avviene solo se wr_en e' attivo
            -- ha priorita' sulla lettura nello stesso ciclo
            if wr_en = '1' then
                ram(to_integer(unsigned(addr(11 downto 2)))) <= wr_data;
            end if;

            -- lettura: avviene se rd_en e' attivo
            -- come per la ROM, c'e' una latenza di 1 ciclo
            if rd_en = '1' then
                rd_data <= ram(to_integer(unsigned(addr(11 downto 2))));
            end if;

        end if;
    end process;

end architecture behavioral;
