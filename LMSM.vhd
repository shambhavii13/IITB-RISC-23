library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LMSM is
    port(
        IMM_IN : in std_logic_vector(15 downto 0);
        PENC_OP : out std_logic_vector(2 downto 0); 
        IMM_OP : out std_logic_vector(15 downto 0)
    );
end LMSM;

architecture Struct of LMSM is

    function PENC(imm : in std_logic_vector(15 downto 0)) 
	return std_logic_vector is
		variable ret : std_logic_vector(2 downto 0) := (others => '0');
        variable imm_out : std_logic_vector(15 downto 0) := imm;
	begin
			L1 : for i in 0 to 7 loop
				if imm(i) = '1' then
                    ret := std_logic_vector(to_unsigned(7 - i, ret'length));
                    imm_out(i) := '0';
                    exit L1;
                end if;
			end loop L1;
		return imm_out & ret;
	end function PENC;

begin
	
    PENC_OP <= PENC(IMM_IN)(2 downto 0);
    IMM_OP <= PENC(IMM_IN)(18 downto 3);

end Struct;