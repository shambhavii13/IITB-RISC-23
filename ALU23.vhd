library ieee;
use ieee.std_logic_1164.all;

entity ALU23 is
    port (
        input1: in std_logic_vector(15 downto 0);
		  input2: in std_logic_vector(15 downto 0);
        ALU_out: out std_logic_vector(15 downto 0)
    );
	 
end ALU23;

architecture arch of ALU23 is

function add(A:in std_logic_vector(15 downto 0);B: in std_logic_vector(15 downto 0))
return std_logic_vector is
variable C : std_logic_vector(16 downto 0) := (others => '0');
variable S : std_logic_vector(15 downto 0):= (others => '0');
		begin
		Loop1: for i in 0 to 15 loop
			S(i) := A(i) xor B(i) xor C(i);
			C(i+1) := ( A(i) and C(i) ) or ( ( A(i) xor C(i) ) and B(i) );
		end loop Loop1;
		return S;
		end add;
begin
  ALU_out <= add(input1,input2);
  

		
  
end arch;