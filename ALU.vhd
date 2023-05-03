library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
	port(ALU_A , ALU_B : in std_logic_vector(15 downto 0); ALU_OP : in std_logic_vector(3 downto 0); ALU_C : out std_logic_vector(15 downto 0); 
		ALU_Z, ALU_C1 : in std_logic; ALU_Carry, ALU_Zero : out std_logic);
end entity ALU;

architecture Structure_ALU of ALU is

	function NAND_16(A : in std_logic_vector(15 downto 0);
						B : in std_logic_vector(15 downto 0))
	return std_logic_vector is
		variable result : std_logic_vector(15 downto 0) := (others => '0');
	begin
			L1 : for i in 0 to 15 loop
				result(i) := A(i) nand B(i);
			end loop L1;
		return result;
	end function NAND_16;
--------------------------------------------------------------------------------------------------------------------------------	
	function ADD_16(A : in std_logic_vector(15 downto 0); B : in std_logic_vector(15 downto 0)) return std_logic_vector is
		variable C : std_logic_vector(16 downto 0) := (others => '0');
		variable S : std_logic_vector(15 downto 0);
	begin
		Loop1: for i in 0 to 15 loop
			S(i) := A(i) xor B(i) xor C(i);
			C(i+1) := ( A(i) and C(i) ) or ( ( A(i) xor C(i) ) and B(i) );
		end loop Loop1;
		return S & C(16);
	end function ADD_16;
---------------------------------------------------------------------------------------------------------------------------------
function AWC_16(A : in std_logic_vector(15 downto 0); B : in std_logic_vector(15 downto 0); Carry : in std_logic) return std_logic_vector is
	variable C : std_logic_vector(16 downto 0) := ( 0 => Carry , others => '0');
	variable S : std_logic_vector(15 downto 0);
begin
	Loop1: for i in 0 to 15 loop
		S(i) := A(i) xor B(i) xor C(i);
		C(i+1) := ( A(i) and C(i) ) or ( ( A(i) xor C(i) ) and B(i) );
	end loop Loop1;
	return S & C(16);
end function AWC_16;
--------------------------------------------------------------------------------------------------------------------------------	
begin
	ALU_Process : process(ALU_A, ALU_B,ALU_C1,ALU_Z, ALU_OP)
	begin
		if ALU_OP = "0000" then --ADD
			ALU_C <= ADD_16(ALU_A, ALU_B)(16 downto 1);		  
			ALU_Carry <= ADD_16(ALU_A, ALU_B)(0);
			if ADD_16(ALU_A, ALU_B) = "0000000000000000" then
				ALU_Zero <= '1';
			else 
				ALU_Zero <= '0';
			end if;
		elsif ALU_OP = "0001" then --Add with Carry
			ALU_C <= AWC_16(ALU_A, ALU_B, ALU_C1)(16 downto 1);		
            ALU_Carry <= AWC_16(ALU_A, ALU_B, ALU_C1)(0);
			if AWC_16(ALU_A, ALU_B, ALU_C1)(16 downto 1) = "0000000000000000" then
				ALU_Zero <= '1';
			else
				ALU_Zero <= '0';
			end if;
		elsif ALU_OP = "0010" then -- Add with Complement
		    ALU_C <= ADD_16(ALU_A, not(ALU_B))(16 downto 1);
			ALU_Carry <= ADD_16(ALU_A, not(ALU_B))(0);
			if ADD_16(ALU_A, not(ALU_B)) = "0000000000000000" then
				ALU_Zero <= '1';
			else 
				ALU_Zero <= '0';
			end if;
        elsif ALU_OP = "0011" then -- Add with complement and carry
            ALU_C <= AWC_16(ALU_A, not(ALU_B), ALU_C1 )(16 downto 1);
            ALU_Carry <= AWC_16(ALU_A, not(ALU_B), ALU_C1)(0);
            if AWC_16(ALU_A, not(ALU_B), ALU_C1) = "0000000000000000" then
                ALU_Zero <= '1';
            else 
                ALU_Zero <= '0';
            end if;
        elsif ALU_OP = "0100" then --NAND
            ALU_C <= NAND_16(ALU_A, ALU_B);		  
            ALU_Carry <= ALU_C1;
            if NAND_16(ALU_A, ALU_B) = "0000000000000000" then
                ALU_Zero <= '1';
            else 
                ALU_Zero <= '0';
            end if;
        elsif ALU_OP = "0101" then --NCU
            ALU_C <= NAND_16(ALU_A, not(ALU_B));		  
            ALU_Carry <= ALU_C1;
            if NAND_16(ALU_A, not(ALU_B)) = "0000000000000000" then
                ALU_Zero <= '1';
            else 
                ALU_Zero <= '0';
            end if;
        elsif ALU_OP = "0110" then --BEQ
            if ALU_A = ALU_B then
                ALU_C <= "0000000000000001";
            else
                ALU_C <= "0000000000000000";
            end if;
            ALU_Carry <= ALU_C1;
            ALU_Zero <= ALU_Z;
        elsif ALU_OP = "0111" then --BLT
            if ALU_A < ALU_B then
                ALU_C <= "0000000000000001";
            else
                ALU_C <= "0000000000000000";
            end if;
            ALU_Carry <= ALU_C1;
            ALU_Zero <= ALU_Z;
        elsif ALU_OP = "1000" then --BLE
            if ALU_A <= ALU_B then
                ALU_C <= "0000000000000001";
            else
                ALU_C <= "0000000000000000";
            end if;
            ALU_Carry <= ALU_C1;
            ALU_Zero <= ALU_Z;
		else --NOP
		    ALU_ZERO <= ALU_Z;
		    ALU_Carry <= ALU_C1;
		    ALU_C <= "0000000000000000";
		end if;
	end process ALU_Process;
end architecture Structure_ALU;