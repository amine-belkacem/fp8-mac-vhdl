library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fp8_pkg.all;

-- Additionneur / soustracteur FP8 (E4M3)
--   sub = '0' : s = a + b
--   sub = '1' : s = a - b
entity fp8_addsub is
    port (
        a   : in  std_logic_vector(7 downto 0);
        b   : in  std_logic_vector(7 downto 0);
        sub : in  std_logic;
        s   : out std_logic_vector(7 downto 0)
    );
end entity fp8_addsub;

architecture rtl of fp8_addsub is
begin
    process(a, b, sub)
        variable bb                       : std_logic_vector(7 downto 0);
        variable sa, sb                   : std_logic;
        variable ea, eb                   : integer;
        variable sbig, ssml               : std_logic;
        variable ebig                     : integer;
        variable big_sig, sml_sig         : unsigned(3 downto 0);
        variable big_ext, sml_ext, total  : unsigned(8 downto 0);
        variable exp_diff, exp_res        : integer;
        variable man_res                  : std_logic_vector(2 downto 0);
        variable a_big                    : boolean;
    begin
        -- 1. Application du sub : on inverse le signe de b si on soustrait
        bb := b;
        if sub = '1' then
            bb(7) := not b(7);
        end if;

        sa := a(7); sb := bb(7);
        ea := to_integer(unsigned(a(6 downto 3)));
        eb := to_integer(unsigned(bb(6 downto 3)));

        -- 2. Cas des entrees nulles
        if a(6 downto 0) = "0000000" then
            s <= bb;
        elsif bb(6 downto 0) = "0000000" then
            s <= a;
        else
            -- 3. Determiner le plus grand en valeur absolue
            if (ea > eb) or
               (ea = eb and unsigned(a(2 downto 0)) >= unsigned(bb(2 downto 0))) then
                a_big := true;
            else
                a_big := false;
            end if;

            if a_big then
                sbig := sa; ssml := sb; ebig := ea;
                big_sig  := unsigned('1' & a(2 downto 0));
                sml_sig  := unsigned('1' & bb(2 downto 0));
                exp_diff := ea - eb;
            else
                sbig := sb; ssml := sa; ebig := eb;
                big_sig  := unsigned('1' & bb(2 downto 0));
                sml_sig  := unsigned('1' & a(2 downto 0));
                exp_diff := eb - ea;
            end if;

            -- 4. Extension avec bits de garde
            big_ext := "0" & big_sig & "0000";
            sml_ext := "0" & sml_sig & "0000";
            if exp_diff >= 9 then
                sml_ext := (others => '0');
            else
                sml_ext := shift_right(sml_ext, exp_diff);
            end if;

            -- 5. Addition ou soustraction selon les signes
            if sbig = ssml then
                total := big_ext + sml_ext;
            else
                total := big_ext - sml_ext;
            end if;

            -- 6. Normalisation
            exp_res := ebig;
            if total = 0 then
                s <= (others => '0');
            else
                if total(8) = '1' then
                    total   := shift_right(total, 1);
                    exp_res := exp_res + 1;
                else
                    for i in 0 to 7 loop
                        if total(7) = '0' then
                            total   := shift_left(total, 1);
                            exp_res := exp_res - 1;
                        end if;
                    end loop;
                end if;

                man_res := std_logic_vector(total(6 downto 4));

                if exp_res > 15 then
                    s <= sbig & "1111" & "110";
                elsif exp_res < 1 then
                    s <= (others => '0');
                else
                    s <= sbig & std_logic_vector(to_unsigned(exp_res, 4)) & man_res;
                end if;
            end if;
        end if;
    end process;
end architecture rtl;
