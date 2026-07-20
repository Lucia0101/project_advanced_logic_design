library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
    Port (
        clk           : in  STD_LOGIC;
        rst           : in  STD_LOGIC;
        debug_pc      : out STD_LOGIC_VECTOR(31 downto 0); 
        debug_instr   : out STD_LOGIC_VECTOR(31 downto 0);
        debug_wb_data : out STD_LOGIC_VECTOR(31 downto 0); 
        debug_rd_addr : out STD_LOGIC_VECTOR(4 downto 0);
        debug_reg_wr  : out STD_LOGIC 
    );
end entity cpu;

architecture behavioral of cpu is
    signal pc_addr     : STD_LOGIC_VECTOR(31 downto 0);
    signal instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_addr    : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wr_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_rd_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wr_en   : STD_LOGIC;
    signal mem_rd_en   : STD_LOGIC;

begin
    IMEM_inst: entity work.instr_memory
        port map (
            clk   => clk,
            addr  => pc_addr,
            instr => instruction
        );

    DP_inst: entity work.datapath
        port map (
            clk           => clk,
            rst           => rst,
            instr_in      => instruction,
            pc_addr       => pc_addr,
            mem_addr      => mem_addr,
            mem_wr_data   => mem_wr_data,
            mem_rd_data   => mem_rd_data,
            mem_wr_en     => mem_wr_en,
            mem_rd_en     => mem_rd_en,
            debug_wb_data => debug_wb_data,
            debug_rd_addr => debug_rd_addr,
            debug_reg_wr  => debug_reg_wr
        );

    DMEM_inst: entity work.data_memory
        port map (
            clk     => clk,
            addr    => mem_addr,
            wr_en   => mem_wr_en,
            rd_en   => mem_rd_en,
            wr_data => mem_wr_data,
            rd_data => mem_rd_data
        );

    debug_pc    <= pc_addr;
    debug_instr <= instruction;

end architecture behavioral;
