library ieee;
use ieee.std_logic_1164.all;

-- Banc de test auto-verifiant de l'additionneur/soustracteur FP8 (E4M3)
entity tb_fp8_addsub is
end entity tb_fp8_addsub;

architecture sim of tb_fp8_addsub is
    signal a, b, s : std_logic_vector(7 downto 0) := (others => '0');
    signal sub     : std_logic := '0';
begin
    uut : entity work.fp8_addsub port map (a => a, b => b, sub => sub, s => s);

    process
        variable errors : natural := 0;

        -- Applique a, b et sub, puis compare le resultat s a la valeur attendue
        procedure check(va, vb : std_logic_vector(7 downto 0); vsub : std_logic;
                        expected : std_logic_vector(7 downto 0); name : string) is
        begin
            a <= va; b <= vb; sub <= vsub;
            wait for 20 ns;
            if s /= expected then
                report "ECHEC " & name & " : obtenu " & to_hstring(s) &
                       ", attendu " & to_hstring(expected) severity error;
                errors := errors + 1;
            end if;
        end procedure;
    begin
        check("00111000", "00111000", '0', "01000000", "1,0 + 1,0 = 2,0");
        check("01000000", "00111000", '0', "01000100", "2,0 + 1,0 = 3,0");
        check("01001100", "00111000", '0', "01001110", "6,0 + 1,0 = 7,0");
        check("01010000", "00111000", '0', "01010001", "8,0 + 1,0 = 9,0");
        check("00111100", "00111100", '0', "01000100", "1,5 + 1,5 = 3,0");
        check("00111010", "00111000", '0', "01000001", "1,25 + 1,0 = 2,25");
        check("01001100", "01000000", '1', "01001000", "6,0 - 2,0 = 4,0");
        check("01001100", "01001000", '1', "01000000", "6,0 - 4,0 = 2,0");
        check("01001100", "01001100", '1', "00000000", "6,0 - 6,0 = 0");
        check("00111000", "01001100", '1', "11001010", "1,0 - 6,0 = -5,0");
        check("01111110", "01111110", '0', "01111110", "448 + 448 -> 448 (saturation)");
        check("01001100", "00000000", '0', "01001100", "6,0 + 0 = 6,0");

        assert errors = 0 report "tb_fp8_addsub : " & integer'image(errors) & " erreur(s)" severity failure;
        report "tb_fp8_addsub : tous les tests sont passes";
        wait;
    end process;
end architecture sim;
