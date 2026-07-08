library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath_tb is
end entity datapath_tb;

architecture sim of datapath_tb is

    -- Segnali di interfaccia verso il Data Path
    signal clk         : STD_LOGIC := '0';
    signal rst         : STD_LOGIC := '1';
    signal instr_in    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal pc_addr     : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_addr    : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wr_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_rd_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal mem_wr_en   : STD_LOGIC;
    signal mem_rd_en   : STD_LOGIC;

    -- Segnali di debug in uscita
    signal debug_wb_data : STD_LOGIC_VECTOR(31 downto 0);
    signal debug_rd_addr : STD_LOGIC_VECTOR(4 downto 0);
    signal debug_reg_wr  : STD_LOGIC;

    -- Costante di simulazione del Clock
    constant CLK_PERIOD : time := 10 ns;

    -- Memoria ROM del Programma
    type rom_array is array(0 to 7) of STD_LOGIC_VECTOR(31 downto 0);
    constant rom : rom_array := (
        0 => X"00500093",  --  0x00     addi x1, x0, 5      -> x1 = 5
        1 => X"00A00113",  --  0x04     addi x2, x0, 10     -> x2 = 10
        2 => X"002081B3",  --  0x08     add x3, x1, x2      -> x3 = 15
        3 => X"40110233",  --  0x0C     sub x4, x2, x1      -> x4 = 5
        4 => X"0020F2B3",  --  0x10     and x5, x1, x2      -> x5 = 0  (5 AND 10)
        5 => X"0020E333",  --  0x14     or x6, x1, x2       -> x6 = 15 (5 OR 10)
        6 => X"00000013",  --  0x18     nop
        7 => X"00000013"   --  0x1C     nop
    );

begin

    -- =========================================================
    -- GENERAZIONE DEL CLOCK (Continuo)
    -- =========================================================
    clk <= not clk after CLK_PERIOD / 2;

    -- =========================================================
    -- MEMORIA ISTRUZIONI (ROM) PROTETTA
    -- Traduce l'indirizzo a byte (0, 4, 8) in indice di array (0, 1, 2)
    -- Controlla che pc_addr non sia 'U' all'istante iniziale
    -- =========================================================
    instr_in <= rom(to_integer(unsigned(pc_addr(4 downto 2)))) 
                when not is_X(pc_addr) 
                else (others => '0');

    -- =========================================================
    -- ISTANZA DEL DEVICE UNDER TEST (DUT)
    -- =========================================================
    DUT: entity work.datapath
        port map (
            clk           => clk,
            rst           => rst,
            instr_in      => instr_in,
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

    -- =========================================================
    -- PROCESSO DI STIMOLO E TELECRONACA
    -- =========================================================
    stimoli: process
    begin
        -- Sequenza di Reset (adattata al tuo testbench: rst attivo alto)
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        report "=== Reset rilasciato, inizio esecuzione ===";

        -- Ciclo 1
        wait for CLK_PERIOD;
        report "Dopo ciclo 1: PC=" & integer'image(to_integer(unsigned(pc_addr)))
             & " ultima scrittura: rd=" & integer'image(to_integer(unsigned(debug_rd_addr)))
             & " val=" & integer'image(to_integer(signed(debug_wb_data)));

        -- Ciclo 2
        wait for CLK_PERIOD;
        report "Dopo ciclo 2: PC=" & integer'image(to_integer(unsigned(pc_addr)))
             & " ultima scrittura: rd=" & integer'image(to_integer(unsigned(debug_rd_addr)))
             & " val=" & integer'image(to_integer(signed(debug_wb_data)));

        -- Ciclo 3
        wait for CLK_PERIOD;
        report "Dopo ciclo 3: PC=" & integer'image(to_integer(unsigned(pc_addr)))
             & " ultima scrittura: rd=" & integer'image(to_integer(unsigned(debug_rd_addr)))
             & " val=" & integer'image(to_integer(signed(debug_wb_data)));

        -- Ciclo 4
        wait for CLK_PERIOD;
        report "Dopo ciclo 4: PC=" & integer'image(to_integer(unsigned(pc_addr)))
             & " ultima scrittura: rd=" & integer'image(to_integer(unsigned(debug_rd_addr)))
             & " val=" & integer'image(to_integer(signed(debug_wb_data)));

        -- Ciclo 5
        wait for CLK_PERIOD;
        report "Dopo ciclo 5: PC=" & integer'image(to_integer(unsigned(pc_addr)))
             & " ultima scrittura: rd=" & integer'image(to_integer(unsigned(debug_rd_addr)))
             & " val=" & integer'image(to_integer(signed(debug_wb_data)));

        -- Ciclo 6
        wait for CLK_PERIOD;
        report "Dopo ciclo 6: PC=" & integer'image(to_integer(unsigned(pc_addr)))
             & " ultima scrittura: rd=" & integer'image(to_integer(unsigned(debug_rd_addr)))
             & " val=" & integer'image(to_integer(signed(debug_wb_data)));

        wait for CLK_PERIOD * 2;
        report "=== TEST COMPLETATO ===";
        wait;
    end process;

end architecture sim;