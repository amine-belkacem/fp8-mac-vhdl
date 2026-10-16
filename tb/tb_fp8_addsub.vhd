library ieee;
use ieee.std_logic_1164.all;

-- Banc de test de l'additionneur/soustracteur FP8 (E4M3)
entity tb_fp8_addsub is
end entity tb_fp8_addsub;

architecture sim of tb_fp8_addsub is
    signal a, b, s : std_logic_vector(7 downto 0) := (others => '0');
    signal sub     : std_logic := '0';
begin
    uut : entity work.fp8_addsub port map (a => a, b => b, sub => sub, s => s);

    process
    begin
        a <= "00111000"; b <= "00111000"; sub <= '0'; wait for 20 ns;  -- 1,0 + 1,0 = 2,0
        a <= "01000000"; b <= "00111000"; sub <= '0'; wait for 20 ns;  -- 2,0 + 1,0 = 3,0
        a <= "01001100"; b <= "00111000"; sub <= '0'; wait for 20 ns;  -- 6,0 + 1,0 = 7,0
        a <= "01010000"; b <= "00111000"; sub <= '0'; wait for 20 ns;  -- 8,0 + 1,0 = 9,0
        a <= "00111100"; b <= "00111100"; sub <= '0'; wait for 20 ns;  -- 1,5 + 1,5 = 3,0
        a <= "00111010"; b <= "00111000"; sub <= '0'; wait for 20 ns;  -- 1,25 + 1,0 = 2,25
        a <= "01001100"; b <= "01000000"; sub <= '1'; wait for 20 ns;  -- 6,0 - 2,0 = 4,0
        a <= "01001100"; b <= "01001000"; sub <= '1'; wait for 20 ns;  -- 6,0 - 4,0 = 2,0
        a <= "01001100"; b <= "01001100"; sub <= '1'; wait for 20 ns;  -- 6,0 - 6,0 = 0
        a <= "00111000"; b <= "01001100"; sub <= '1'; wait for 20 ns;  -- 1,0 - 6,0 = -5,0
        a <= "01111110"; b <= "01111110"; sub <= '0'; wait for 20 ns;  -- 448 + 448 -> 448 (saturation)
        a <= "01001100"; b <= "00000000"; sub <= '0'; wait for 20 ns;  -- 6,0 + 0 = 6,0
        wait;
    end process;
end architecture sim;
