library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity system_top is
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        switches  : in  STD_LOGIC_VECTOR(15 downto 0);
        buttons   : in  STD_LOGIC_VECTOR(4 downto 0);
        leds      : out STD_LOGIC_VECTOR(15 downto 0);
        seg       : out STD_LOGIC_VECTOR(6 downto 0);
        an        : out STD_LOGIC_VECTOR(7 downto 0);
        dp        : out STD_LOGIC;
        spi_sclk  : out STD_LOGIC;
        spi_mosi  : out STD_LOGIC;
        spi_miso  : in  STD_LOGIC;
        spi_cs_n  : out STD_LOGIC;
        vga_hsync : out STD_LOGIC;
        vga_vsync : out STD_LOGIC;
        vga_red   : out STD_LOGIC_VECTOR(3 downto 0);
        vga_green : out STD_LOGIC_VECTOR(3 downto 0);
        vga_blue  : out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity system_top;

architecture structural of system_top is
    signal rst_int : STD_LOGIC;
    signal clk_cnt : unsigned(1 downto 0) := (others => '0');
    signal cpu_clk : STD_LOGIC := '0';
    signal pc_addr     : STD_LOGIC_VECTOR(31 downto 0);
    signal instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_addr    : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wr_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_rd_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wr_en   : STD_LOGIC;
    signal mem_rd_en   : STD_LOGIC;
    signal dbg_wb_data : STD_LOGIC_VECTOR(31 downto 0);
    signal dbg_rd_addr : STD_LOGIC_VECTOR(4 downto 0);
    signal dbg_reg_wr  : STD_LOGIC;
    signal periph_sel  : STD_LOGIC_VECTOR(1 downto 0);
    signal ram_wr_en   : STD_LOGIC;
    signal ram_rd_en   : STD_LOGIC;
    signal gpio_wr_en  : STD_LOGIC;
    signal spi_wr_en   : STD_LOGIC;
    signal vga_wr_en   : STD_LOGIC;
    signal ram_rd_data  : STD_LOGIC_VECTOR(31 downto 0);
    signal gpio_rd_data : STD_LOGIC_VECTOR(31 downto 0);
    signal spi_rd_data  : STD_LOGIC_VECTOR(31 downto 0);
    signal spi_start   : STD_LOGIC;
    signal spi_tx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal spi_rx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal spi_busy    : STD_LOGIC;
    signal spi_done    : STD_LOGIC;
    signal spi_cs_reg  : STD_LOGIC := '1';
    signal pixel_x     : STD_LOGIC_VECTOR(9 downto 0);
    signal pixel_y     : STD_LOGIC_VECTOR(9 downto 0);
    signal video_on    : STD_LOGIC;
    signal ball_x_reg  : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal ball_y_reg  : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    constant SEL_RAM  : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant SEL_GPIO : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant SEL_SPI  : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant SEL_VGA  : STD_LOGIC_VECTOR(1 downto 0) := "11";

begin

    rst_int <= not rst;
    process(clk, rst_int)
    begin
        if rst_int = '1' then
            clk_cnt <= (others => '0');
            cpu_clk <= '0';
        elsif rising_edge(clk) then
            clk_cnt <= clk_cnt + 1;
            if clk_cnt = "01" or clk_cnt = "11" then
                cpu_clk <= not cpu_clk;
            end if;
        end if;
    end process;
    
    periph_sel <= mem_addr(29 downto 28);

    ram_wr_en  <= mem_wr_en when periph_sel = SEL_RAM  else '0';
    ram_rd_en  <= mem_rd_en when periph_sel = SEL_RAM  else '0';
    gpio_wr_en <= mem_wr_en when periph_sel = SEL_GPIO else '0';
    spi_wr_en  <= mem_wr_en when periph_sel = SEL_SPI  else '0';
    vga_wr_en  <= mem_wr_en when periph_sel = SEL_VGA  else '0';

    with periph_sel select
        mem_rd_data <= gpio_rd_data when SEL_GPIO,
                       spi_rd_data  when SEL_SPI,
                       ram_rd_data  when others;

    spi_start   <= '1' when (spi_wr_en = '1' and mem_addr(3 downto 0) = "0000")
                   else '0';
    spi_tx_data <= mem_wr_data(7 downto 0);

    with mem_addr(3 downto 0) select
        spi_rd_data <= (0 => spi_busy, others => '0')        when "0100",
                       (31 downto 8 => '0') & spi_rx_data    when "1000",
                       (others => '0')                       when others;

    process(cpu_clk, rst_int)
    begin
        if rst_int = '1' then
            spi_cs_reg <= '1';
        elsif rising_edge(cpu_clk) then
            if spi_wr_en = '1' and mem_addr(3 downto 0) = "1100" then
                spi_cs_reg <= mem_wr_data(0);
            end if;
        end if;
    end process;

    spi_cs_n <= spi_cs_reg;

    process(cpu_clk, rst_int)
    begin
        if rst_int = '1' then
            ball_x_reg <= std_logic_vector(to_unsigned(320, 10));
            ball_y_reg <= std_logic_vector(to_unsigned(240, 10));
        elsif rising_edge(cpu_clk) then
            if vga_wr_en = '1' then
                case mem_addr(3 downto 0) is
                    when "0000" =>
                        ball_x_reg <= mem_wr_data(9 downto 0);
                    when "0100" =>
                        ball_y_reg <= mem_wr_data(9 downto 0);
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    IMEM_inst: entity work.instr_memory
        port map (
            clk   => cpu_clk,
            addr  => pc_addr,
            instr => instruction
        );

    DP_inst: entity work.datapath
        port map (
            clk           => cpu_clk,
            rst           => rst_int,
            instr_in      => instruction,
            pc_addr       => pc_addr,
            mem_addr      => mem_addr,
            mem_wr_data   => mem_wr_data,
            mem_rd_data   => mem_rd_data,
            mem_wr_en     => mem_wr_en,
            mem_rd_en     => mem_rd_en,
            debug_wb_data => dbg_wb_data,
            debug_rd_addr => dbg_rd_addr,
            debug_reg_wr  => dbg_reg_wr
        );

    DMEM_inst: entity work.data_memory
        port map (
            clk     => cpu_clk,
            addr    => mem_addr,
            wr_en   => ram_wr_en,
            rd_en   => ram_rd_en,
            wr_data => mem_wr_data,
            rd_data => ram_rd_data
        );

    GPIO_inst: entity work.gpio
        port map (
            clk      => cpu_clk,
            rst      => rst_int,
            addr     => mem_addr(3 downto 0),
            wr_data  => mem_wr_data,
            rd_data  => gpio_rd_data,
            wr_en    => gpio_wr_en,
            switches => switches,
            buttons  => buttons,
            leds     => leds,
            seg      => seg,
            an       => an,
            dp       => dp
        );

    SPI_inst: entity work.spi_master
        port map (
            clk      => cpu_clk,
            rst      => rst_int,
            start    => spi_start,
            tx_data  => spi_tx_data,
            rx_data  => spi_rx_data,
            busy     => spi_busy,
            done     => spi_done,
            spi_sclk => spi_sclk,
            spi_mosi => spi_mosi,
            spi_miso => spi_miso,
            spi_cs_n => open 
        );

    VGASYNC_inst: entity work.vga_sync
        port map (
            clk      => clk,
            rst      => rst_int,
            hsync    => vga_hsync,
            vsync    => vga_vsync,
            pixel_x  => pixel_x,
            pixel_y  => pixel_y,
            video_on => video_on
        );

    VGAGAME_inst: entity work.vga_ball
        port map (
            pixel_x   => pixel_x,
            pixel_y   => pixel_y,
            video_on  => video_on,
            ball_x    => ball_x_reg,
            ball_y    => ball_y_reg,
            vga_red   => vga_red,
            vga_green => vga_green,
            vga_blue  => vga_blue
        );

end architecture structural;