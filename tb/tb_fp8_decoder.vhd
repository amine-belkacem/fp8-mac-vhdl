library ieee;
use ieee.std_logic_1164.all;

-- Banc de test auto-verifiant du decodeur FP8 (E4M3)
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
        variable errors : natural := 0;

        -- Applique une entree et compare les champs decodes aux valeurs attendues
        procedure check(input : std_logic_vector(7 downto 0);
                        s_exp : std_logic;
                        e_exp : std_logic_vector(3 downto 0);
                        m_exp : std_logic_vector(2 downto 0);
                        z_exp : std_logic;
                        name  : string) is
        begin
            fp8_in <= input;
            wait for 20 ns;
            if sign /= s_exp or exponent /= e_exp or mantissa /= m_exp or is_zero /= z_exp then
                report "ECHEC " & name & " : entree " & to_hstring(input) severity error;
                errors := errors + 1;
            end if;
        end procedure;
    begin
        check("00111000", '0', "0111", "000", '0', "+1,0");
        check("00111100", '0', "0111", "100", '0', "+1,5");
        check("00111010", '0', "0111", "010", '0', "+1,25");
        check("01001100", '0', "1001", "100", '0', "+6,0");
        check("01011000", '0', "1011", "000", '0', "+16,0");
        check("10111000", '1', "0111", "000", '0', "-1,0");
        check("11001100", '1', "1001", "100", '0', "-6,0");
        check("01111110", '0', "1111", "110", '0', "+448 (max)");
        check("00001000", '0', "0001", "000", '0', "+0,015625");
        check("00000000", '0', "0000", "000", '1', "zero");

        assert errors = 0 report "tb_fp8_decoder : " & integer'image(errors) & " erreur(s)" severity failure;
        report "tb_fp8_decoder : tous les tests sont passes";
        wait;
    end process;
end architecture sim;
