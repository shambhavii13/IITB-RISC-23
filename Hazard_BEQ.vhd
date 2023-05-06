library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


enTITy Branch_Haz is 
	port(
		opcode : in std_logic_vector(3 down to 0);
		alu_zf : in std_logic;
		haz_branch: out std_logic
	);
end Branch_Haz;

architecture find_hazard of Branch_Haz is

	begin
		process(opcode,alu_zf)
		begin 
			if opcode="1000" or opcode="1001" or opcode="1010" then
				if alu_zf='1' then
					haz_branch='1';
				else
				   haz_branch='0';
				end if;
			else
				null;
		
			end if;
		end process;
	end find_hazard;