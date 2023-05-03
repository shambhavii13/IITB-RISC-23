library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_predictor is
    port(IM_DATA_OUT: in std_logic_vector (15 downto 0);
        history_bit:in std_logic;
        sign_ext_imm:in std_logic;
        PC:in std_logic;
        Branch : out std_logic_vector ( 15 downto 0);
        mux_signal : out std_logic;
    );
end branch_predictor;

architecture prediction of branch_predictor is
    signal opcode:std_logic_vector(4 downto 0);
--    signal immediate:std_logic_vector(5 downto 0);
     
begin
opcode:=IM_DATA_OUT(15 downto 12)
 
predict : process(history_bit,IM_DATA_OUT )

	begin
    if opcode ='1000' or opcode='1001' or opcode='1010'  then
        if history_bit='1' then
            Branch<=PC+sign_ext_imm*2;
        else
            Branch<=PC+2
        end if;
    else 
        Branch<=PC+2
    end if;
    
        
	end process ;

end prediction;