library ieee;
use ieee.std_logic_1164.all;

-- Banc de test auto-verifiant du multiplieur FP8 (E4M3)
entity tb_fp8_mult is
end entity tb_fp8_mult;

architecture sim of tb_fp8_mult is
    signal a, b, p : std_logic_vector(7 downto 0) := (others => '0');
begin
    uut : entity work.fp8_mult port map (a => a, b => b, p => p);

    process
        variable errors : natural := 0;

        -- Applique a et b, puis compare le produit p a la valeur attendue
        procedure check(va, vb, expected : std_logic_vector(7 downto 0); name : string) is
        begin
            a <= va; b <= vb;
            wait for 20 ns;
            if p /= expected then
                report "ECHEC " & name & " : obtenu " & to_hstring(p) &
                       ", attendu " & to_hstring(expected) severity error;
                errors := errors + 1;
            end if;
        end procedure;
    begin
        check("00111100", "00111100", "01000001", "1,5 * 1,5 = 2,25");
        check("00111100", "01000010", "01000111", "1,5 * 2,5 = 3,75");
        check("00110100", "00110100", "00110001", "0,75 * 0,75 = 0,5625");
        check("00111010", "01000000", "01000010", "1,25 * 2,0 = 2,5");
        check("00111010", "00111010", "00111100", "1,25 * 1,25 -> 1,5 (troncature)");
        check("01000010", "01000010", "01001100", "2,5 * 2,5 -> 6,0 (troncature)");
        check("00111000", "01001100", "01001100", "1,0 * 6,0 = 6,0");
        check("01000000", "01000000", "01001000", "2,0 * 2,0 = 4,0");
        check("01001100", "01001100", "01100001", "6,0 * 6,0 = 36,0");
        check("01011000", "01011000", "01111000", "16 * 16 = 256");
        check("01100000", "01100000", "01111110", "32 * 32 -> 448 (saturation)");
        check("10111000", "01001100", "11001100", "-1,0 * 6,0 = -6,0");
        check("11000010", "11000000", "01001010", "-2,5 * -2,0 = +5,0");
        check("00001000", "00001000", "00000000", "tres petit -> 0 (soupassement)");
        check("00000000", "01001100", "00000000", "0 * 6,0 = 0");

        assert errors = 0 report "tb_fp8_mult : " & integer'image(errors) & " erreur(s)" severity failure;
        report "tb_fp8_mult : tous les tests sont passes";
        wait;
    end process;
end architecture sim;
