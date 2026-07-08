-- cpu.vhd
-- Top-level del processore RISC-V RV32I
-- Mette insieme datapath, memoria istruzioni e memoria dati

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
    Port (
        clk           : in  STD_LOGIC;
        rst           : in  STD_LOGIC;

        -- ===== Uscite di debug (utili per il testbench e analisi) =====
        debug_pc      : out STD_LOGIC_VECTOR(31 downto 0);  -- PC corrente
        debug_instr   : out STD_LOGIC_VECTOR(31 downto 0);  -- istruzione corrente
        debug_wb_data : out STD_LOGIC_VECTOR(31 downto 0);  -- dato in write back
        debug_rd_addr : out STD_LOGIC_VECTOR(4 downto 0);   -- registro destinazione
        debug_reg_wr  : out STD_LOGIC                       -- abilita scrittura reg
    );
end entity cpu;

architecture behavioral of cpu is

    -- ============= SEGNALI INTERNI =============

    -- segnali che collegano datapath e memoria istruzioni
    signal pc_addr     : STD_LOGIC_VECTOR(31 downto 0);
    signal instruction : STD_LOGIC_VECTOR(31 downto 0);

    -- segnali che collegano datapath e memoria dati
    signal mem_addr    : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wr_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_rd_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wr_en   : STD_LOGIC;
    signal mem_rd_en   : STD_LOGIC;

begin

    -- ============= ISTANZA DELLA MEMORIA ISTRUZIONI =============
    -- contiene il programma RISC-V da eseguire
    -- la lettura ha latenza di 1 ciclo (BRAM sincrona)
    IMEM_inst: entity work.instr_memory
        port map (
            clk   => clk,
            addr  => pc_addr,
            instr => instruction
        );

    -- ============= ISTANZA DEL DATAPATH =============
    -- la CPU vera e propria
    DP_inst: entity work.datapath
        port map (
            clk           => clk,
            rst           => rst,

            -- collegamenti con la memoria istruzioni
            instr_in      => instruction,
            pc_addr       => pc_addr,

            -- collegamenti con la memoria dati
            mem_addr      => mem_addr,
            mem_wr_data   => mem_wr_data,
            mem_rd_data   => mem_rd_data,
            mem_wr_en     => mem_wr_en,
            mem_rd_en     => mem_rd_en,

            -- segnali di debug
            debug_wb_data => debug_wb_data,
            debug_rd_addr => debug_rd_addr,
            debug_reg_wr  => debug_reg_wr
        );

    -- ============= ISTANZA DELLA MEMORIA DATI =============
    -- usata da LOAD e STORE per leggere/scrivere variabili
    DMEM_inst: entity work.data_memory
        port map (
            clk     => clk,
            addr    => mem_addr,
            wr_en   => mem_wr_en,
            rd_en   => mem_rd_en,
            wr_data => mem_wr_data,
            rd_data => mem_rd_data
        );

    -- ============= USCITE DI DEBUG =============
    debug_pc    <= pc_addr;
    debug_instr <= instruction;

end architecture behavioral;
