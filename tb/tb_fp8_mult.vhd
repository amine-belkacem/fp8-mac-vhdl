library ieee;
use ieee.std_logic_1164.all;

-- Banc de test du multiplieur FP8 (E4M3)
entity tb_fp8_mult is
end entity tb_fp8_mult;

architecture sim of tb_fp8_mult is
    signal a, b, p : std_logic_vector(7 downto 0) := (others => '0');
begin
    uut : entity work.fp8_mult port map (a => a, b => b, p => p);

    process
    begin
        a <= "00111100"; b <= "00111100"; wait for 20 ns;  -- 1,5 * 1,5 = 2,25
        a <= "00111100"; b <= "01000010"; wait for 20 ns;  -- 1,5 * 2,5 = 3,75
        a <= "00110100"; b <= "00110100"; wait for 20 ns;  -- 0,75 * 0,75 = 0,5625
        a <= "00111010"; b <= "01000000"; wait for 20 ns;  -- 1,25 * 2,0 = 2,5
        a <= "00111010"; b <= "00111010"; wait for 20 ns;  -- 1,25 * 1,25 -> 1,5 (troncature)
        a <= "01000010"; b <= "01000010"; wait for 20 ns;  -- 2,5 * 2,5 -> 6,0 (troncature)
        a <= "00111000"; b <= "01001100"; wait for 20 ns;  -- 1,0 * 6,0 = 6,0
        a <= "01000000"; b <= "01000000"; wait for 20 ns;  -- 2,0 * 2,0 = 4,0
        a <= "01001100"; b <= "01001100"; wait for 20 ns;  -- 6,0 * 6,0 = 36,0
        a <= "01011000"; b <= "01011000"; wait for 20 ns;  -- 16 * 16 = 256
        a <= "01100000"; b <= "01100000"; wait for 20 ns;  -- 32 * 32 -> 448 (saturation)
        a <= "10111000"; b <= "01001100"; wait for 20 ns;  -- -1,0 * 6,0 = -6,0
        a <= "11000010"; b <= "11000000"; wait for 20 ns;  -- -2,5 * -2,0 = +5,0
        a <= "00001000"; b <= "00001000"; wait for 20 ns;  -- tres petit -> 0 (soupassement)
        a <= "00000000"; b <= "01001100"; wait for 20 ns;  -- 0 * 6,0 = 0
        wait;
    end process;
end architecture sim;
