library ieee;
use ieee.std_logic_1164.all;

entity MUX_4_to_1_16bit is
    port (
        A0: in std_logic_vector(15 downto 0);
        A1: in std_logic_vector(15 downto 0);
		A2: in std_logic_vector(15 downto 0);
		A3: in std_logic_vector(15 downto 0);
        S: in std_logic_vector(1 downto 0);
        Op: out std_logic_vector(15 downto 0)
    );
end MUX_4_to_1_16bit;

architecture behavior of MUX_4_to_1_16bit is
begin
	process( A0, A1, A2, A3, S )
	begin
	case S is
		when "00" =>
		    Op <= A0;
		when "01"=>
		    Op <= A1;
		when "10"=>
		    Op <= A2;
		when "11"=>
		    Op <= A3;
		when others=>
		    null;
	end case;
	end process ;
end behavior;