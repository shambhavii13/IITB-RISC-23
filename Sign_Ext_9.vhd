library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_ext_9 is
    port(SE_IN : in std_logic_vector (8 downto 0);
        SE_OUT : out std_logic_vector ( 15 downto 0)
    );
end sign_ext_9;

architecture SE_Arch of sign_ext_9 is
begin

SE_9 : process( SE_IN )

	begin
	if SE_IN(8) ='0' then
		SE_out <= "0000000" & SE_IN;
	else  
		SE_out <= "1111111" & SE_IN;
	end if;
	end process ;

end SE_Arch;