-- program_counter.vhd
-- Program Counter per processore RISC-V RV32I
-- Registro a 32 bit che tiene traccia dell'indirizzo dell'istruzione corrente

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter is
    Port (
        clk      : in  STD_LOGIC;       -- clock
        rst      : in  STD_LOGIC;       -- reset sincrono: riporta PC a 0
        pc_load  : in STD_LOGIC;        -- abilita l'aggiornamento del PC
        -- segnale di controllo: decide se andare avanti o saltare
        -- 0 = prossima istruzione (PC + 4)
        -- 1 = salta all'indirizzo target (branch o jump)
        pc_src   : in  STD_LOGIC;

        -- indirizzo di destinazione del salto (calcolato dal branch adder o dalla ALU)
        target   : in  STD_LOGIC_VECTOR(31 downto 0);

        -- indirizzo corrente: va alla memoria istruzioni
        pc_out   : out STD_LOGIC_VECTOR(31 downto 0);

        -- PC + 4: serve per JAL/JALR (salvano l'indirizzo di ritorno in rd)
        pc_plus4 : out STD_LOGIC_VECTOR(31 downto 0)
        
        
    );
end entity program_counter;

architecture behavioral of program_counter is

    -- registro interno che contiene il valore corrente del PC
    signal pc_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    -- valore che verra' caricato nel PC al prossimo fronte di clock
    signal pc_next : STD_LOGIC_VECTOR(31 downto 0);

begin

    -- calcola il prossimo valore del PC in modo combinatorio
    -- se pc_src = 0 vai avanti di 4 byte
    -- se pc_src = 1 salta all'indirizzo target
    pc_next <= STD_LOGIC_VECTOR(unsigned(pc_reg) + 4) when pc_src = '0'
               else target;

    -- aggiorna il PC sul fronte di salita del clock
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- reset: ricomincia dall'indirizzo 0 (prima istruzione del programma)
                pc_reg <= (others => '0');
                
            elsif pc_load = '1' then
                pc_reg <= pc_next;
            end if;
        end if;
    end process;

    -- porta il valore corrente del PC all'uscita
    pc_out   <= pc_reg;

    -- calcola e porta fuori PC + 4
    -- serve al MUX write-back quando si esegue JAL o JALR
    pc_plus4 <= STD_LOGIC_VECTOR(unsigned(pc_reg) + 4);

end architecture behavioral;