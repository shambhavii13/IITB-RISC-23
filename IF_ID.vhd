library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
entity IF_ID is
        port(
            clk, IF_ID_EN,IF_ID_CLR: in std_logic;
            PC_IN: in std_logic_vector(15 downto 0);
            PC_2_IN: in std_logic_vector(15 downto 0);
			IM_DATA_IN: in std_logic_vector(15 downto 0);

            RA_ADD: out std_logic_vector(2 downto 0);
			RB_ADD: out std_logic_vector(2 downto 0);
			RC_ADD: out std_logic_vector(2 downto 0);
			IMM_6 : out std_logic_vector(5 downto 0);
			IMM_9 : out std_logic_vector(8 downto 0);
            PC_OUT: out std_logic_vector(15 downto 0);
            PC_2_OUT: out std_logic_vector(15 downto 0);
            IM_DATA_OUT: out std_logic_vector(15 downto 0)
        ); 
end entity; 

architecture pipeline_reg of IF_ID is 

signal PC,PC_2,IM_data: std_logic_vector(15 downto 0):="0000000000000000";
begin

-- PC <= PC_IN;
-- PC_2 <= PC_2_IN;
-- IM_data <= IM_DATA_IN;

process(PC_IN,PC_2_IN,IM_DATA_IN,clk,IF_ID_EN,IF_ID_CLR)
begin
	 if IF_ID_EN='1' then
        PC <= PC_IN;
        PC_2 <= PC_2_IN;
        IM_data <= IM_DATA_IN;
    else
        null;
    end if;

    if(IF_ID_CLR='1') then
        PC<="1011000000000000";
        PC_2<="0000000000000000";
        IM_data<="0000000000000000";
        

    else
        null;
    end if;
    
    if rising_edge(clk) then
        
        RA_ADD <= IM_data(11 downto 9);
        RB_ADD <= IM_data(8 downto 6);
        RC_ADD <= IM_data(5 downto 3);
        IMM_6 <= IM_data(5 downto 0);
        IMM_9 <= IM_data(8 downto 0);
        PC_OUT <=PC;
        PC_2_OUT <=PC_2;
        IM_DATA_OUT <= IM_data;
        
    end if;
end process;

end pipeline_reg;

