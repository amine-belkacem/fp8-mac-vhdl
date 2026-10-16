library ieee;
use ieee.std_logic_1164.all;

-- Banc de test du decodeur FP8 (E4M3)
entity tb_fp8_decoder is
end entity tb_fp8_decoder;

architecture sim of tb_fp8_decoder is
    signal fp8_in   : std_logic_vector(7 downto 0) := (others => '0');
    signal sign     : std_logic;
    signal exponent : std_logic_vector(3 downto 0);
    signal mantissa : std_logic_vector(2 downto 0);
    signal is_zero  : std_logic;
begin
    uut : entity work.fp8_decoder
        port map (fp8_in => fp8_in, sign => sign, exponent => exponent,
                  mantissa => mantissa, is_zero => is_zero);

    process
    begin
        fp8_in <= "00111000"; wait for 20 ns;  -- +1,0
        fp8_in <= "00111100"; wait for 20 ns;  -- +1,5
        fp8_in <= "00111010"; wait for 20 ns;  -- +1,25
        fp8_in <= "01001100"; wait for 20 ns;  -- +6,0
        fp8_in <= "01011000"; wait for 20 ns;  -- +16,0
        fp8_in <= "10111000"; wait for 20 ns;  -- -1,0
        fp8_in <= "11001100"; wait for 20 ns;  -- -6,0
        fp8_in <= "01111110"; wait for 20 ns;  -- +448 (max)
        fp8_in <= "00001000"; wait for 20 ns;  -- +0,015625
        fp8_in <= "00000000"; wait for 20 ns;  -- 0
        wait;
    end process;
end architecture sim;
