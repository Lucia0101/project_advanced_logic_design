library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity spi_master is
    Generic (
        CLK_DIV : positive := 50;
        CPOL : STD_LOGIC := '1';
        CPHA : STD_LOGIC := '1'
    );
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        start    : in  STD_LOGIC;                      
        tx_data  : in  STD_LOGIC_VECTOR(7 downto 0);   
        rx_data  : out STD_LOGIC_VECTOR(7 downto 0);   
        busy     : out STD_LOGIC;                      
        done     : out STD_LOGIC;                
        spi_sclk : out STD_LOGIC; 
        spi_mosi : out STD_LOGIC;
        spi_miso : in  STD_LOGIC; 
        spi_cs_n : out STD_LOGIC 
    );
end entity spi_master;

architecture behavioral of spi_master is
    type state_t is (IDLE, ASSERT_CS, SHIFT, DONE_STATE);
    signal stato : state_t := IDLE;
    signal clk_cnt   : integer range 0 to CLK_DIV-1 := 0;
    signal clk_tc    : STD_LOGIC; 
    signal sclk_int  : STD_LOGIC := '0'; 
    signal bit_cnt   : integer range 0 to 7 := 7;
    signal shift_tx  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal shift_rx  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal cs_n_int  : STD_LOGIC := '1';
    
begin
    clk_tc <= '1' when clk_cnt = CLK_DIV - 1 else '0';
    process(clk, rst)
    begin
        if rst = '1' then
            stato     <= IDLE;
            clk_cnt   <= 0;
            sclk_int  <= '0';
            bit_cnt   <= 7;
            shift_tx  <= (others => '0');
            shift_rx  <= (others => '0');
            cs_n_int  <= '1';
            done      <= '0';
            
        elsif rising_edge(clk) then
            done <= '0'; 
            
            case stato is
                when IDLE =>
                    sclk_int <= '0';
                    cs_n_int <= '1';
                    clk_cnt  <= 0;
                    bit_cnt  <= 7;
                    if start = '1' then
                        shift_tx <= tx_data;
                        cs_n_int <= '0';
                        stato    <= ASSERT_CS; 
                    end if;
                    
                when ASSERT_CS =>
                    if clk_tc = '1' then
                        clk_cnt  <= 0;
                        sclk_int <= '1';    
                        shift_rx <= shift_rx(6 downto 0) & spi_miso;
                        stato    <= SHIFT;
                    else
                        clk_cnt <= clk_cnt + 1;
                    end if;
                    
                when SHIFT =>
                    if clk_tc = '1' then
                        clk_cnt <= 0;

                        if sclk_int = '1' then
                            sclk_int <= '0';
                            shift_tx <= shift_tx(6 downto 0) & '0';
                            if bit_cnt = 0 then
                                stato <= DONE_STATE;
                            else
                                bit_cnt <= bit_cnt - 1;
                            end if;
                        else
                            sclk_int <= '1';
                            shift_rx <= shift_rx(6 downto 0) & spi_miso;
                        end if;
                    else
                        clk_cnt <= clk_cnt + 1;
                    end if;
                    
                when DONE_STATE =>
                    cs_n_int <= '1';        
                    sclk_int <= '0';
                    done     <= '1';        
                    stato    <= IDLE;
            end case;
        end if;
    end process;
    
    spi_mosi <= shift_tx(7);
    spi_sclk <= sclk_int;
    spi_cs_n <= cs_n_int;
    rx_data  <= shift_rx;
    
    busy <= '0' when (stato = IDLE and start = '0') else '1';
end architecture behavioral;