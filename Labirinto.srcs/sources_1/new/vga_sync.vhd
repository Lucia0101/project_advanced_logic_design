library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga_sync is
    Port (
        clk       : in  STD_LOGIC; 
        rst       : in  STD_LOGIC;
        hsync     : out STD_LOGIC;
        vsync     : out STD_LOGIC;
        pixel_x   : out STD_LOGIC_VECTOR(9 downto 0);
        pixel_y   : out STD_LOGIC_VECTOR(9 downto 0); 
        video_on  : out STD_LOGIC
    );
end entity vga_sync;

architecture behavioral of vga_sync is
    constant H_VISIBLE : integer := 640;
    constant H_FRONT   : integer := 16;
    constant H_SYNC    : integer := 96;  
    constant H_BACK    : integer := 48;
    constant H_TOTAL   : integer := 800;
    constant V_VISIBLE : integer := 480;
    constant V_FRONT   : integer := 10;
    constant V_SYNC    : integer := 2;    
    constant V_BACK    : integer := 33;   
    constant V_TOTAL   : integer := 525;
    signal clk_div   : unsigned(1 downto 0) := (others => '0');
    signal pixel_tick : STD_LOGIC;
    signal h_count : unsigned(9 downto 0) := (others => '0'); 
    signal v_count : unsigned(9 downto 0) := (others => '0'); 
    signal video_on_int : STD_LOGIC;

begin
    process(clk, rst)
    begin
        if rst = '1' then
            clk_div <= (others => '0');
        elsif rising_edge(clk) then
            clk_div <= clk_div + 1;
        end if;
    end process;

    pixel_tick <= '1' when clk_div = "11" else '0';
    
    process(clk, rst)
    begin
        if rst = '1' then
            h_count <= (others => '0');
            v_count <= (others => '0');

        elsif rising_edge(clk) then
            if pixel_tick = '1' then

                if h_count = H_TOTAL - 1 then
                    h_count <= (others => '0');

                    if v_count = V_TOTAL - 1 then
                        v_count <= (others => '0');
                    else
                        v_count <= v_count + 1;
                    end if;
                else
                    h_count <= h_count + 1;
                end if;

            end if;
        end if;
    end process;

    hsync <= '0' when (h_count >= H_VISIBLE + H_FRONT) and
                      (h_count <  H_VISIBLE + H_FRONT + H_SYNC)
             else '1';

    vsync <= '0' when (v_count >= V_VISIBLE + V_FRONT) and
                      (v_count <  V_VISIBLE + V_FRONT + V_SYNC)
             else '1';

    video_on_int <= '1' when (h_count < H_VISIBLE) and (v_count < V_VISIBLE)
                    else '0';
    video_on <= video_on_int;

    pixel_x <= STD_LOGIC_VECTOR(h_count) when video_on_int = '1'
               else (others => '0');
    pixel_y <= STD_LOGIC_VECTOR(v_count) when video_on_int = '1'
               else (others => '0');
end architecture behavioral;