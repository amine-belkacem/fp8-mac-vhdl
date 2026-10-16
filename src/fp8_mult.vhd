library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fp8_pkg.all;

-- Multiplieur FP8 (E4M3) combinatoire : p = a * b
entity fp8_mult is
    port (
        a : in  std_logic_vector(7 downto 0);
        b : in  std_logic_vector(7 downto 0);
        p : out std_logic_vector(7 downto 0)
    );
end entity fp8_mult;

architecture rtl of fp8_mult is
begin
    process(a, b)
        variable sa, sb, sp     : std_logic;
        variable ea, eb         : integer;
        variable sig_a, sig_b   : unsigned(3 downto 0);
        variable prod           : unsigned(7 downto 0);
        variable exp_sum        : integer;
        variable exp_res        : integer;
        variable man_res        : std_logic_vector(2 downto 0);
        variable zero_a, zero_b : boolean;
    begin
        -- Extraction des champs
        sa := a(7); sb := b(7);
        ea := to_integer(unsigned(a(6 downto 3)));
        eb := to_integer(unsigned(b(6 downto 3)));
        zero_a := (a(6 downto 0) = "0000000");
        zero_b := (b(6 downto 0) = "0000000");

        -- Signe du produit (XOR des signes)
        sp := sa xor sb;

        -- Significandes avec bit cache (1.xxx -> 4 bits)
        sig_a := unsigned('1' & a(2 downto 0));
        sig_b := unsigned('1' & b(2 downto 0));

        -- Multiplication des significandes (4x4 = 8 bits)
        prod := sig_a * sig_b;

        -- Addition des exposants moins le biais
        exp_sum := ea + eb - EXP_BIAS;

        -- Normalisation : le produit vaut entre 1 et presque 4
        if prod(7) = '1' then          -- produit >= 2.0
            man_res := std_logic_vector(prod(6 downto 4));
            exp_res := exp_sum + 1;
        else                           -- produit dans [1,2)
            man_res := std_logic_vector(prod(5 downto 3));
            exp_res := exp_sum;
        end if;

        -- Cas particuliers + assemblage
        if zero_a or zero_b then
            p <= (others => '0');                 -- resultat nul
        elsif exp_res > 15 then
            p <= sp & "1111" & "110";             -- saturation a 448
        elsif exp_res < 1 then
            p <= (others => '0');                 -- soupassement -> 0
        else
            p <= sp & std_logic_vector(to_unsigned(exp_res, 4)) & man_res;
        end if;
    end process;
end architecture rtl;
