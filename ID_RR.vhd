library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
entity ID_RR is
    port(
        clk,ID_RR_EN: in std_logic;
        RB_ADD_IN: in std_logic_vector(2 downto 0);
        RC_ADD_IN: in std_logic_vector(2 downto 0);
        RA_ADD_IN: in std_logic_vector(2 downto 0);

        PC_IN : in std_logic_vector(15 downto 0);
        PC_2_IN : in std_logic_vector(15 downto 0);
        PC_2xIMM_IN : in std_logic_vector(15 downto 0);

        IMM_SE: in std_logic_vector(15 downto 0);
        
        RA_ADD_OUT: out std_logic_vector(2 downto 0);
        RB_ADD_OUT: out std_logic_vector(2 downto 0);
        RC_ADD_OUT: out std_logic_vector(2 downto 0);

        PC_OUT: out std_logic_vector(15 downto 0);
        PC_2xIMM_OUT: out std_logic_vector(15 downto 0);
        PC_2_OUT: out std_logic_vector(15 downto 0);
        SE_2xIMM: out std_logic_vector(15 downto 0)	
    );
end entity;    

architecture pipeline_reg of ID_RR is 

signal RA_ADD,RB_ADD,RC_ADD: std_logic_vector( 2 downto 0):="000";
signal IMM_SE_dummy,PC,PC_2,PC_2xIMM: std_logic_vector(15 downto 0):="0000000000000000";

begin
    

    -- PC <= PC_IN;
    -- PC_2 <= PC_2_IN;
    -- PC_2xIMM <= PC_2xIMM_IN;
    -- IMM_SE_dummy <= IMM_SE;
    -- RA_ADD <= RA_ADD_IN;
    -- RB_ADD <= RB_ADD_IN;
    -- RC_ADD <= RC_ADD_IN;
    

    process(PC_IN,PC_2_IN,RA_ADD_IN,RB_ADD_IN,RC_ADD_IN,PC_2xIMM_IN,IMM_SE,clk)
    begin
        if(ID_RR_EN='1') then
            PC <= PC_IN;
            PC_2 <= PC_2_IN;
            PC_2xIMM <= PC_2xIMM_IN;
            IMM_SE_dummy <= IMM_SE;
            RA_ADD <= RA_ADD_IN;
            RB_ADD <= RB_ADD_IN;
            RC_ADD <= RC_ADD_IN;
        else
            null;
        end if;
        if rising_edge(clk) then
            
            RA_ADD_OUT <= RA_ADD;
            RB_ADD_OUT <= RB_ADD;
            RC_ADD_OUT <= RC_ADD;

            PC_OUT <=PC;
            PC_2_OUT <=PC_2;
            PC_2xIMM_OUT <= PC_2xIMM;
            SE_2xIMM <= IMM_SE_dummy;
            
        end if;
    end process;
end pipeline_reg;

