library ieee;
use ieee.std_logic_1164.all;

-- Banc de test du MAC FP8 (E4M3)
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
begin
    uut : entity work.fp8_mac
        port map (clk => clk, reset => reset, clear => clear,
                  enable => enable, sub => sub, a => a, b => b,
                  result => result, valid => valid);

    clk <= not clk after 5 ns;  -- horloge 10 ns

    process
    begin
        reset <= '1'; enable <= '0'; wait for 12 ns;
        reset <= '0'; wait for 8 ns;

        -- Accumulation 1 : 1 -> 3 -> 9
        a <= "00111000"; b <= "00111000"; sub <= '0'; enable <= '1'; wait for 10 ns;
        a <= "01000000"; b <= "00111000"; wait for 10 ns;
        a <= "01001100"; b <= "00111000"; wait for 10 ns;
        enable <= '0'; wait for 20 ns;

        -- Effacement puis accumulation 2 : 4 -> 7
        clear <= '1'; wait for 10 ns;
        clear <= '0';
        a <= "01000000"; b <= "01000000"; enable <= '1'; wait for 10 ns;
        a <= "00111100"; b <= "01000000"; wait for 10 ns;
        enable <= '0'; wait for 20 ns;

        -- Soustraction : 7 - 2 = 5
        a <= "01000000"; b <= "00111000"; sub <= '1'; enable <= '1'; wait for 10 ns;
        enable <= '0'; sub <= '0'; wait for 20 ns;

        wait;
    end process;
end architecture sim;
