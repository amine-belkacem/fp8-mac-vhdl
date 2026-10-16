library ieee;
use ieee.std_logic_1164.all;
use work.fp8_pkg.all;

-- Decodeur FP8 : separe un mot de 8 bits en signe / exposant / mantisse
entity fp8_decoder is
    port (
        fp8_in   : in  std_logic_vector(7 downto 0);
        sign     : out std_logic;
        exponent : out std_logic_vector(3 downto 0);
        mantissa : out std_logic_vector(2 downto 0);
        is_zero  : out std_logic
    );
end entity fp8_decoder;

architecture rtl of fp8_decoder is
begin
    sign     <= fp8_in(7);
    exponent <= fp8_in(6 downto 3);
    mantissa <= fp8_in(2 downto 0);
    is_zero  <= '1' when (fp8_in(6 downto 0) = "0000000") else '0';
end architecture rtl;
