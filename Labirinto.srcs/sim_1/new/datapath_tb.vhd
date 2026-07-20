library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath_tb is
end entity datapath_tb;

architecture sim of datapath_tb is
    signal clk         : STD_LOGIC := '0';
    signal rst         : STD_LOGIC := '1';
    signal instr_in    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal pc_addr     : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_addr    : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wr_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_rd_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal mem_wr_en   : STD_LOGIC;
    signal mem_rd_en   : STD_LOGIC;

    signal debug_wb_data : STD_LOGIC_VECTOR(31 downto 0);
    signal debug_rd_addr : STD_LOGIC_VECTOR(4 downto 0);
    signal debug_reg_wr  : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

    -- Memory ROM
    type rom_array is array(0 to 7) of STD_LOGIC_VECTOR(31 downto 0);
    constant rom : rom_array := (
        0 => X"00500093",  
        1 => X"00A00113",  
        2 => X"002081B3", 
        3 => X"40110233", 
        4 => X"0020F2B3",
        5 => X"0020E333",
        6 => X"00000013", 
        7 => X"00000013" 
    );

begin

    clk <= not clk after CLK_PERIOD / 2;

    instr_in <= rom(to_integer(unsigned(pc_addr(4 downto 2)))) 
                when not is_X(pc_addr) 
                else (others => '0');

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

    stimoli: process
    begin
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        report "=== Reset rilasciato, inizio esecuzione ===";

        wait for CLK_PERIOD;
        report "Dopo ciclo 1: PC=" & integer'image(to_integer(unsigned(pc_addr)))
             & " ultima scrittura: rd=" & integer'image(to_integer(unsigned(debug_rd_addr)))
             & " val=" & integer'image(to_integer(signed(debug_wb_data)));

        wait for CLK_PERIOD;
        report "Dopo ciclo 2: PC=" & integer'image(to_integer(unsigned(pc_addr)))
             & " ultima scrittura: rd=" & integer'image(to_integer(unsigned(debug_rd_addr)))
             & " val=" & integer'image(to_integer(signed(debug_wb_data)));

        wait for CLK_PERIOD;
        report "Dopo ciclo 3: PC=" & integer'image(to_integer(unsigned(pc_addr)))
             & " ultima scrittura: rd=" & integer'image(to_integer(unsigned(debug_rd_addr)))
             & " val=" & integer'image(to_integer(signed(debug_wb_data)));

        wait for CLK_PERIOD;
        report "Dopo ciclo 4: PC=" & integer'image(to_integer(unsigned(pc_addr)))
             & " ultima scrittura: rd=" & integer'image(to_integer(unsigned(debug_rd_addr)))
             & " val=" & integer'image(to_integer(signed(debug_wb_data)));

        wait for CLK_PERIOD;
        report "Dopo ciclo 5: PC=" & integer'image(to_integer(unsigned(pc_addr)))
             & " ultima scrittura: rd=" & integer'image(to_integer(unsigned(debug_rd_addr)))
             & " val=" & integer'image(to_integer(signed(debug_wb_data)));

        wait for CLK_PERIOD;
        report "Dopo ciclo 6: PC=" & integer'image(to_integer(unsigned(pc_addr)))
             & " ultima scrittura: rd=" & integer'image(to_integer(unsigned(debug_rd_addr)))
             & " val=" & integer'image(to_integer(signed(debug_wb_data)));

        wait for CLK_PERIOD * 2;
        report "=== TEST COMPLETATO ===";
        wait;
    end process;

end architecture sim;