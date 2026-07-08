-- system_top.vhd
-- Top-level del sistema: processore RISC-V + GPIO + SPI + VGA
-- collegati tramite un bus I/O memory-mapped.
--
-- FASE 3 (finale): aggiungiamo il sottosistema VGA.
--
-- MAPPA DI MEMORIA (fase 3, completa):
--   0x00000000 - 0x0FFFFFFF : RAM dati        (addr(29..28) = "00")
--   0x10000000 - 0x1FFFFFFF : periferica GPIO (addr(29..28) = "01")
--   0x20000000 - 0x2FFFFFFF : periferica SPI  (addr(29..28) = "10")
--   0x30000000 - 0x3FFFFFFF : periferica VGA  (addr(29..28) = "11")
--
-- Registri VGA (offset dalla base 0x30000000):
--   0x0 (scrittura) posizione X della pallina
--   0x4 (scrittura) posizione Y della pallina

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity system_top is
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;

        -- ===== ingressi fisici (GPIO) =====
        switches  : in  STD_LOGIC_VECTOR(15 downto 0);
        buttons   : in  STD_LOGIC_VECTOR(4 downto 0);

        -- ===== uscite fisiche (GPIO) =====
        leds      : out STD_LOGIC_VECTOR(15 downto 0);
        seg       : out STD_LOGIC_VECTOR(6 downto 0);
        an        : out STD_LOGIC_VECTOR(7 downto 0);
        dp        : out STD_LOGIC;

        -- ===== fili SPI (accelerometro ADXL362) =====
        spi_sclk  : out STD_LOGIC;
        spi_mosi  : out STD_LOGIC;
        spi_miso  : in  STD_LOGIC;
        spi_cs_n  : out STD_LOGIC;

        -- ===== uscite VGA (verso il monitor) =====
        vga_hsync : out STD_LOGIC;
        vga_vsync : out STD_LOGIC;
        vga_red   : out STD_LOGIC_VECTOR(3 downto 0);
        vga_green : out STD_LOGIC_VECTOR(3 downto 0);
        vga_blue  : out STD_LOGIC_VECTOR(3 downto 0);

        -- ===== uscite di debug =====
        debug_pc      : out STD_LOGIC_VECTOR(31 downto 0);
        debug_instr   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity system_top;

architecture structural of system_top is

    -- ============= SEGNALI CPU <-> MEMORIA ISTRUZIONI =============
    signal pc_addr     : STD_LOGIC_VECTOR(31 downto 0);
    signal instruction : STD_LOGIC_VECTOR(31 downto 0);

    -- ============= SEGNALI CPU <-> BUS DATI =============
    signal mem_addr    : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wr_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_rd_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_wr_en   : STD_LOGIC;
    signal mem_rd_en   : STD_LOGIC;

    signal dbg_wb_data : STD_LOGIC_VECTOR(31 downto 0);
    signal dbg_rd_addr : STD_LOGIC_VECTOR(4 downto 0);
    signal dbg_reg_wr  : STD_LOGIC;

    -- ============= SEGNALI DEL DECODER =============
    signal periph_sel  : STD_LOGIC_VECTOR(1 downto 0);

    signal ram_wr_en   : STD_LOGIC;
    signal ram_rd_en   : STD_LOGIC;
    signal gpio_wr_en  : STD_LOGIC;
    signal spi_wr_en   : STD_LOGIC;
    signal vga_wr_en   : STD_LOGIC;

    signal ram_rd_data  : STD_LOGIC_VECTOR(31 downto 0);
    signal gpio_rd_data : STD_LOGIC_VECTOR(31 downto 0);
    signal spi_rd_data  : STD_LOGIC_VECTOR(31 downto 0);

    -- ============= SEGNALI SPI =============
    signal spi_start   : STD_LOGIC;
    signal spi_tx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal spi_rx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal spi_busy    : STD_LOGIC;
    signal spi_done    : STD_LOGIC;

    -- ============= SEGNALI VGA =============
    signal pixel_x     : STD_LOGIC_VECTOR(9 downto 0);
    signal pixel_y     : STD_LOGIC_VECTOR(9 downto 0);
    signal video_on    : STD_LOGIC;

    -- registri di posizione della pallina (pilotati dalla CPU)
    signal ball_x_reg  : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal ball_y_reg  : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');

    -- costanti selettore periferica
    constant SEL_RAM  : STD_LOGIC_VECTOR(1 downto 0) := "00";
    constant SEL_GPIO : STD_LOGIC_VECTOR(1 downto 0) := "01";
    constant SEL_SPI  : STD_LOGIC_VECTOR(1 downto 0) := "10";
    constant SEL_VGA  : STD_LOGIC_VECTOR(1 downto 0) := "11";

begin

    -- =====================================================
    -- ADDRESS DECODER
    -- =====================================================
    periph_sel <= mem_addr(29 downto 28);

    ram_wr_en  <= mem_wr_en when periph_sel = SEL_RAM  else '0';
    ram_rd_en  <= mem_rd_en when periph_sel = SEL_RAM  else '0';
    gpio_wr_en <= mem_wr_en when periph_sel = SEL_GPIO else '0';
    spi_wr_en  <= mem_wr_en when periph_sel = SEL_SPI  else '0';
    vga_wr_en  <= mem_wr_en when periph_sel = SEL_VGA  else '0';

    -- MUX di lettura verso la CPU
    with periph_sel select
        mem_rd_data <= gpio_rd_data when SEL_GPIO,
                       spi_rd_data  when SEL_SPI,
                       ram_rd_data  when others;

    -- =====================================================
    -- LOGICA SPI
    -- =====================================================
    spi_start   <= '1' when (spi_wr_en = '1' and mem_addr(3 downto 0) = "0000")
                   else '0';
    spi_tx_data <= mem_wr_data(7 downto 0);

    with mem_addr(3 downto 0) select
        spi_rd_data <= (0 => spi_busy, others => '0')        when "0100",
                       (31 downto 8 => '0') & spi_rx_data    when "1000",
                       (others => '0')                       when others;

    -- =====================================================
    -- REGISTRI VGA (posizione pallina, scritti dalla CPU)
    -- =====================================================
    process(clk, rst)
    begin
        if rst = '1' then
            ball_x_reg <= std_logic_vector(to_unsigned(320, 10)); -- centro schermo
            ball_y_reg <= std_logic_vector(to_unsigned(240, 10));
        elsif rising_edge(clk) then
            if vga_wr_en = '1' then
                case mem_addr(3 downto 0) is
                    when "0000" =>   -- 0x0 -> posizione X
                        ball_x_reg <= mem_wr_data(9 downto 0);
                    when "0100" =>   -- 0x4 -> posizione Y
                        ball_y_reg <= mem_wr_data(9 downto 0);
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    -- =====================================================
    -- ISTANZE
    -- =====================================================
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
            debug_wb_data => dbg_wb_data,
            debug_rd_addr => dbg_rd_addr,
            debug_reg_wr  => dbg_reg_wr
        );

    DMEM_inst: entity work.data_memory
        port map (
            clk     => clk,
            addr    => mem_addr,
            wr_en   => ram_wr_en,
            rd_en   => ram_rd_en,
            wr_data => mem_wr_data,
            rd_data => ram_rd_data
        );

    GPIO_inst: entity work.gpio
        port map (
            clk      => clk,
            rst      => rst,
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
            clk      => clk,
            rst      => rst,
            start    => spi_start,
            tx_data  => spi_tx_data,
            rx_data  => spi_rx_data,
            busy     => spi_busy,
            done     => spi_done,
            spi_sclk => spi_sclk,
            spi_mosi => spi_mosi,
            spi_miso => spi_miso,
            spi_cs_n => spi_cs_n
        );

    -- ===== SOTTOSISTEMA VGA =====
    -- generatore di sincronismi
    VGASYNC_inst: entity work.vga_sync
        port map (
            clk      => clk,
            rst      => rst,
            hsync    => vga_hsync,
            vsync    => vga_vsync,
            pixel_x  => pixel_x,
            pixel_y  => pixel_y,
            video_on => video_on
        );

    -- generatore di immagine (sfondo + pallina)
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

    -- =====================================================
    -- USCITE DI DEBUG
    -- =====================================================
    debug_pc    <= pc_addr;
    debug_instr <= instruction;

end architecture structural;