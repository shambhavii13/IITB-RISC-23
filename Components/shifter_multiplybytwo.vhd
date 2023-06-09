library ieee;
use ieee.std_logic_1164.all;

entity shifter_multiplybytwo is
    port(
        shift_in : in std_logic_vector(15 downto 0);
        shift_out : out std_logic_vector(15 downto 0);
		SH_EN : in std_logic
    );	 
end shifter_multiplybytwo;

architecture arch of shifter_multiplybytwo is
begin
shift : process(SH_EN, shift_in)
    begin
    if SH_EN='1' then
        shift_out <= shift_in(14 downto 0) & "0";
    else
        shift_out <= shift_in;
    end if;
end process;

end arch;