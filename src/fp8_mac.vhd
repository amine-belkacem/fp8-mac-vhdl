library ieee;
use ieee.std_logic_1164.all;
use work.fp8_pkg.all;

-- Top-level : multiplieur-accumulateur FP8
-- A chaque front d'horloge actif (enable) : acc = acc +/- (a * b)
entity fp8_mac is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        clear  : in  std_logic;
        enable : in  std_logic;
        sub    : in  std_logic;
        a      : in  std_logic_vector(7 downto 0);
        b      : in  std_logic_vector(7 downto 0);
        result : out std_logic_vector(7 downto 0);
        valid  : out std_logic
    );
end entity fp8_mac;

architecture rtl of fp8_mac is
    signal prod    : std_logic_vector(7 downto 0);
    signal sum     : std_logic_vector(7 downto 0);
    signal acc_q   : std_logic_vector(7 downto 0);
    signal valid_r : std_logic := '0';
begin
    u_mult : entity work.fp8_mult
        port map (a => a, b => b, p => prod);

    u_addsub : entity work.fp8_addsub
        port map (a => acc_q, b => prod, sub => sub, s => sum);

    u_acc : entity work.fp8_acc
        port map (clk => clk, reset => reset, clear => clear,
                  enable => enable, d_in => sum, q_out => acc_q);

    process(clk, reset)
    begin
        if reset = '1' then
            valid_r <= '0';
        elsif rising_edge(clk) then
            valid_r <= enable;
        end if;
    end process;

    result <= acc_q;
    valid  <= valid_r;
end architecture rtl;
