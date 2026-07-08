-- hex_to_7seg.vhd
-- Decoder da cifra esadecimale (4 bit) a 7 segmenti
-- I segmenti sono ATTIVI BASSI (0 = segmento acceso) come sulla Nexys 4 DDR
--
-- Disposizione dei segmenti nel vettore seg(6 downto 0):
--   seg(0)=a, seg(1)=b, seg(2)=c, seg(3)=d, seg(4)=e, seg(5)=f, seg(6)=g

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hex_to_7seg is
    Port (
        hex : in  STD_LOGIC_VECTOR(3 downto 0);   -- cifra 0..F
        seg : out STD_LOGIC_VECTOR(6 downto 0)    -- segmenti (attivi bassi)
    );
end entity hex_to_7seg;

architecture behavioral of hex_to_7seg is
begin

    -- tabella di conversione: ogni cifra accende i segmenti giusti
    -- ricorda: 0 = acceso, 1 = spento (attivo basso)
    -- ordine bit: gfedcba (seg(6)=g ... seg(0)=a)
    with hex select
        seg <= "1000000" when "0000",  -- 0
               "1111001" when "0001",  -- 1
               "0100100" when "0010",  -- 2
               "0110000" when "0011",  -- 3
               "0011001" when "0100",  -- 4
               "0010010" when "0101",  -- 5
               "0000010" when "0110",  -- 6
               "1111000" when "0111",  -- 7
               "0000000" when "1000",  -- 8
               "0010000" when "1001",  -- 9
               "0001000" when "1010",  -- A
               "0000011" when "1011",  -- b
               "1000110" when "1100",  -- C
               "0100001" when "1101",  -- d
               "0000110" when "1110",  -- E
               "0001110" when "1111",  -- F
               "1111111" when others;  -- tutto spento

end architecture behavioral;