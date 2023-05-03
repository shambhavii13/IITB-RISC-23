library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
entity MEM_WB is
    port(
        clk: in std_logic;
        DEST_IN : in std_logic_vector(2 downto 0);
        ALU_C_IN : in std_logic_vector(15 downto 0);
        D_OUT_IN : in std_logic_vector(15 downto 0);
        PC_2_IN : in std_logic_vector(15 downto 0);

        PC_2_OUT : out std_logic_vector(15 downto 0);
        D_OUT_OUT : out std_logic_vector(15 downto 0);
        ALU_C_OUT : out std_logic_vector(15 downto 0);
        DEST_OUT : out std_logic_vector(2 downto 0)
    );
end entity;

architecture pipeline_reg of MEM_WB is 

signal DEST: std_logic_vector( 2 downto 0):="000";
signal ALU_C,D_OUT,PC_2: std_logic_vector(15 downto 0):="0000000000000000";

begin
    
PC_2 <= PC_2_IN;
ALU_C <= ALU_C_IN;
D_OUT <= D_OUT_IN;
DEST <= DEST_IN;


process(PC_2_IN, DEST_IN, D_OUT_IN, ALU_C_IN, clk)
begin
    if rising_edge(clk) then
        
        D_OUT_OUT <= D_OUT;
        ALU_C_OUT <= ALU_C;
        PC_2_OUT <= PC_2;
        DEST_OUT <= DEST;

    end if;
end process;
end pipeline_reg;
