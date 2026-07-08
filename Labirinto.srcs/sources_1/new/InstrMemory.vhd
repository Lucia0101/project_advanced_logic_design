-- InstrMemory.vhd
-- Memoria Istruzioni con il FIRMWARE DEL GIOCO DEL LABIRINTO
-- Codice compilato da C -> assembly (Godbolt) -> esadecimale RV32I puro
--
-- Il programma contiene:
--   - Sequenza di boot (inizializza lo stack pointer a 4092)
--   - Funzioni spi_transfer e read_accel (lettura accelerometro ADXL362)
--   - main: game loop (legge accelerometro, muove la pallina, gestisce muri e buchi)
--
-- Indirizzi periferiche (allineati al system_top):
--   GPIO/LED = 0x10000008, SPI = 0x20000000, VGA = 0x30000000
--
-- NOTA: assemblato in RV32I PURO (nessuna istruzione compressa),
--       compatibile con la CPU implementata.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instr_memory is
    Port (
        clk   : in  STD_LOGIC;
        addr  : in  STD_LOGIC_VECTOR(31 downto 0);
        instr : out STD_LOGIC_VECTOR(31 downto 0)
    );
end instr_memory;

architecture behavioral of instr_memory is

    type mem_type is array (0 to 1023) of STD_LOGIC_VECTOR(31 downto 0);

     signal mem : mem_type := (
        0 => x"00001137",
        1 => x"00ef3171",
        2 => x"00ef0420",
        3 => x"07b70000",
        4 => x"c3882000",
        5 => x"20000737",
        6 => x"8b85435c",
        7 => x"4708fff5",
        8 => x"11418082",
        9 => x"842ac422",
        10 => x"c606452d",
        11 => x"fe3ff0ef",
        12 => x"f0ef8522",
        13 => x"4501fddf",
        14 => x"fd7ff0ef",
        15 => x"442240b2",
        16 => x"0ff57513",
        17 => x"80820141",
        18 => x"d4227179",
        19 => x"d04ad226",
        20 => x"ca56ce4e",
        21 => x"c65ec85a",
        22 => x"c266c462",
        23 => x"d606c06a",
        24 => x"4481cc52",
        25 => x"09134401",
        26 => x"09936400",
        27 => x"0b136400",
        28 => x"0a9310c0",
        29 => x"0bb70300",
        30 => x"4c3d1000",
        31 => x"15300c93",
        32 => x"13600d13",
        33 => x"f0ef4521",
        34 => x"8a2af9df",
        35 => x"f0ef4525",
        36 => x"9452f95f",
        37 => x"579394aa",
        38 => x"8c1d4044",
        39 => x"4044d793",
        40 => x"87b38c9d",
        41 => x"07330089",
        42 => x"87950099",
        43 => x"5e638715",
        44 => x"cc6300fb",
        45 => x"069302fc",
        46 => x"6863fbb7",
        47 => x"d79302dd",
        48 => x"57134059",
        49 => x"44814059",
        50 => x"86934401",
        51 => x"ee63f797",
        52 => x"069300da",
        53 => x"ea63ee37",
        54 => x"a42300da",
        55 => x"0713018b",
        56 => x"07930320",
        57 => x"44810320",
        58 => x"06b74401",
        59 => x"c29c3000",
        60 => x"00579993",
        61 => x"00571913",
        62 => x"b769c2d8",
        others => x"00000000" 
    );

begin

    -- Lettura sincrona (comportamento Block RAM)
    process(clk)
    begin
        if rising_edge(clk) then
            instr <= mem(to_integer(unsigned(addr(11 downto 2))));
        end if;
    end process;

end behavioral;