library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
entity EX_MEM is
    port(
        clk,EX_MEM_EN : in std_logic;
        DEST_IN : in std_logic_vector(2 downto 0);
        RB_IN : in std_logic_vector(15 downto 0);

        ALU_C_IN : in std_logic_vector(15 downto 0);
        PC_2_IN : in std_logic_vector(15 downto 0);

        DEST_OUT : out std_logic_vector(2 downto 0);
        ALU_C_OUT : out std_logic_vector(15 downto 0);
        RB_OUT : out std_logic_vector(15 downto 0);

        PC_2_OUT : out std_logic_vector(15 downto 0)
    );
end entity;

architecture pipeline_reg of EX_MEM is 

signal DEST: std_logic_vector( 2 downto 0):="000";
signal ALU_C,RB,PC_2: std_logic_vector(15 downto 0):="0000000000000000";

begin



process(PC_2_IN,DEST_IN,RB_IN,ALU_C_IN,clk)
begin
    if(EX_MEM_EN='1') then
        PC_2 <= PC_2_IN;
        ALU_C <= ALU_C_IN;
        RB <= RB_IN;
        DEST <= DEST_IN;
    else
        null;
    end if;

    if rising_edge(clk) then
        
        ALU_C_OUT <= ALU_C;
        RB_OUT <= RB;
        PC_2_OUT <= PC_2;
        DEST_OUT <= DEST;

    end if;
end process;

end pipeline_reg;

