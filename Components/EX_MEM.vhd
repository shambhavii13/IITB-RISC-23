library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
entity EX_MEM is
    port(
        clk, EX_MEM_EN ,EX_MEM_CLR: in std_logic;

        DEST_IN : in std_logic_vector(2 downto 0);
        RA_IN : in std_logic_vector(15 downto 0);

        ALU_C_IN : in std_logic_vector(15 downto 0);
        PC_2_IN : in std_logic_vector(15 downto 0);

        DEST_OUT : out std_logic_vector(2 downto 0);
        ALU_C_OUT : out std_logic_vector(15 downto 0);
        RA_OUT : out std_logic_vector(15 downto 0);

        PC_2_OUT : out std_logic_vector(15 downto 0);
        IR_IN: in std_logic_vector(15 downto 0);
        IR_OUT: out std_logic_vector(15 downto 0)
    );
end entity;

architecture pipeline_reg of EX_MEM is 

signal DEST: std_logic_vector( 2 downto 0):="000";
signal ALU_C,RA,PC_2: std_logic_vector(15 downto 0):="0000000000000000";
signal IR: std_logic_vector(15 downto 0);
begin



process(PC_2_IN,DEST_IN,RA_IN,ALU_C_IN,IR_IN,EX_MEM_CLR,EX_MEM_EN,clk)
begin
    if(EX_MEM_EN='1') then
        IR<=IR_IN;
        PC_2 <= PC_2_IN;
        ALU_C <= ALU_C_IN;
        RA <= RA_IN;
        DEST <= DEST_IN;
    else
        null;
    end if;
    if(EX_MEM_CLR='1') then
        IR<="1011000010110000";
        PC_2<="0000000000000000";
        RA<="0000000000000000";
        ALU_C<="0000000000000000";
        DEST<="000";
    else
        null;
    end if;
    if rising_edge(clk) then
        
        ALU_C_OUT <= ALU_C;
        RA_OUT <= RA;
        PC_2_OUT <= PC_2;
        DEST_OUT <= DEST;
        IR_OUT<=IR;

    end if;
end process;

end pipeline_reg;

