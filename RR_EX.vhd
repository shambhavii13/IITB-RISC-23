library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
entity RR_EX is
    port(
        clk,RR_EX_EN : in std_logic;
        DEST_IN : in std_logic_vector(2 downto 0);
        RA_IN : in std_logic_vector(15 downto 0);
        RB_IN : in std_logic_vector(15 downto 0);

        SE_IMM_IN : in std_logic_vector(15 downto 0);
        PC_2xIMM_IN : in std_logic_vector(15 downto 0);
        PC_2_IN : in std_logic_vector(15 downto 0);

        DEST_OUT : out std_logic_vector(2 downto 0);
        RA_OUT : out std_logic_vector(15 downto 0);
        RB_OUT : out std_logic_vector(15 downto 0);

        SE_IMM_OUT : out std_logic_vector(15 downto 0);
        PC_2xIMM_OUT : out std_logic_vector(15 downto 0);
        PC_2_OUT : out std_logic_vector(15 downto 0)
    );
end entity;

architecture pipeline_reg of RR_EX is 

signal DEST: std_logic_vector( 2 downto 0) := "000";
signal RA,RB,SE_IMM,PC,PC_2,PC_2xIMM: std_logic_vector(15 downto 0):="0000000000000000";

begin

-- PC_2 <= PC_2_IN;
-- PC_2xIMM <= PC_2xIMM_IN;
-- SE_IMM <= SE_IMM_IN;
-- RA <= RA_IN;
-- RB <= RB_IN;
-- DEST <= DEST_IN;
    

process(PC_2_IN,DEST_IN,RA_IN,RB_IN,SE_IMM_IN,PC_2xIMM,clk)
begin
    SE_IMM <= SE_IMM_IN;
    if(RR_EX_EN='1') then
        PC_2 <= PC_2_IN;
        PC_2xIMM <= PC_2xIMM_IN;
        
        RA <= RA_IN;
        RB <= RB_IN;
        DEST <= DEST_IN;
    else
        null;
    end if;
    if rising_edge(clk) then
        
        RA_OUT <= RA;
        RB_OUT <= RB;
        PC_2_OUT <= PC_2;
        PC_2xIMM_OUT <=PC_2xIMM;
        SE_IMM_OUT <= SE_IMM;
        DEST_OUT <= DEST;

    end if;
end process;

end pipeline_reg;

