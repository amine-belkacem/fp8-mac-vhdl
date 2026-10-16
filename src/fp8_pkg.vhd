library ieee;
use ieee.std_logic_1164.all;

-- Package : parametres du format FP8 (variante E4M3)
package fp8_pkg is
    constant FP8_WIDTH : integer := 8;
    constant EXP_WIDTH : integer := 4;
    constant MAN_WIDTH : integer := 3;
    constant EXP_BIAS  : integer := 7;  -- biais de l'exposant
    subtype fp8_t is std_logic_vector(FP8_WIDTH-1 downto 0);
end package fp8_pkg;
