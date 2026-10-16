library ieee;
use ieee.std_logic_1164.all;

-- Banc de test auto-verifiant du MAC FP8 (E4M3)
entity tb_fp8_mac is
end entity tb_fp8_mac;

architecture sim of tb_fp8_mac is
    signal clk    : std_logic := '0';
    signal reset  : std_logic := '1';
    signal clear  : std_logic := '0';
    signal enable : std_logic := '0';
    signal sub    : std_logic := '0';
    signal a, b   : std_logic_vector(7 downto 0) := (others => '0');
    signal result : std_logic_vector(7 downto 0);
    signal valid  : std_logic;
    signal done   : boolean := false;
begin
    uut : entity work.fp8_mac
        port map (clk => clk, reset => reset, clear => clear,
                  enable => enable, sub => sub, a => a, b => b,
                  result => result, valid => valid);

    clk <= not clk after 5 ns when not done;  -- horloge 10 ns, arretee en fin de test

    process
        variable errors : natural := 0;

        -- Compare la sortie de l'accumulateur a la valeur attendue
        procedure check(expected : std_logic_vector(7 downto 0); name : string) is
        begin
            if result /= expected then
                report "ECHEC " & name & " : obtenu " & to_hstring(result) &
                       ", attendu " & to_hstring(expected) severity error;
                errors := errors + 1;
            end if;
        end procedure;
    begin
        reset <= '1'; enable <= '0'; wait for 12 ns;
        reset <= '0'; wait for 8 ns;

        -- Accumulation 1 : 1 -> 3 -> 9
        a <= "00111000"; b <= "00111000"; sub <= '0'; enable <= '1'; wait for 10 ns;
        check("00111000", "acc = 0 + 1*1 = 1");
        a <= "01000000"; b <= "00111000"; wait for 10 ns;
        check("01000100", "acc = 1 + 2*1 = 3");
        a <= "01001100"; b <= "00111000"; wait for 10 ns;
        check("01010001", "acc = 3 + 6*1 = 9");
        enable <= '0'; wait for 20 ns;
        check("01010001", "acc maintenu a 9 (enable = 0)");

        -- Effacement puis accumulation 2 : 4 -> 7
        clear <= '1'; wait for 10 ns;
        check("00000000", "clear -> acc = 0");
        clear <= '0';
        a <= "01000000"; b <= "01000000"; enable <= '1'; wait for 10 ns;
        check("01001000", "acc = 0 + 2*2 = 4");
        a <= "00111100"; b <= "01000000"; wait for 10 ns;
        check("01001110", "acc = 4 + 1,5*2 = 7");
        enable <= '0'; wait for 20 ns;

        -- Soustraction : 7 - 2 = 5
        a <= "01000000"; b <= "00111000"; sub <= '1'; enable <= '1'; wait for 10 ns;
        check("01001010", "acc = 7 - 2*1 = 5");
        enable <= '0'; sub <= '0'; wait for 20 ns;

        assert errors = 0 report "tb_fp8_mac : " & integer'image(errors) & " erreur(s)" severity failure;
        report "tb_fp8_mac : tous les tests sont passes";
        done <= true;
        wait;
    end process;
end architecture sim;
