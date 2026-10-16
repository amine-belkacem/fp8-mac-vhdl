library ieee;
use ieee.std_logic_1164.all;

-- Registre accumulateur synchrone 8 bits
entity fp8_acc is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        clear  : in  std_logic;
        enable : in  std_logic;
        d_in   : in  std_logic_vector(7 downto 0);
        q_out  : out std_logic_vector(7 downto 0)
    );
end entity fp8_acc;

architecture rtl of fp8_acc is
    signal reg : std_logic_vector(7 downto 0) := (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            reg <= (others => '0');
        elsif rising_edge(clk) then
            if clear = '1' then
                reg <= (others => '0');
            elsif enable = '1' then
                reg <= d_in;
            end if;
        end if;
    end process;

    q_out <= reg;
end architecture rtl;
