library ieee;
use ieee.std_logic_1164.all;

entity shifter_multiplybytwo is
    port (
        input: in std_logic_vector(15 downto 0);
        shift_out: out std_logic_vector(15 downto 0);
		  SH_EN: in std_logic
    );
	 
end shifter_multiplybytwo;

architecture arch of shifter_multiplybytwo is
begin
	
		shift_out <= input(14 downto 0) &"0";
	 
end arch;