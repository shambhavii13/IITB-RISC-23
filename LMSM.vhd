library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LMSM is
    port(
        IMM_IN : in std_logic_vector(15 downto 0);
        PENC_OP : out std_logic_vector(2 downto 0); 
        IMM_OP : out std_logic_vector(15 downto 0);
        IS_IMM_ZERO : out std_logic
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

    signal penc_out : std_logic_vector(18 downto 0) ;

begin
	
    penc_out <= PENC(IMM_IN);
    PENC_OP <= penc_out(2 downto 0);
    IMM_OP <= penc_out(18 downto 3);
    
    process(IMM_IN)
    begin
        if IMM_IN = "0000000000000000" then
            IS_IMM_ZERO <= '1';
        else
            IS_IMM_ZERO <= '0';
        end if;
    end process;

end Struct;