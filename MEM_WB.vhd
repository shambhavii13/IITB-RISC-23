library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
entity MEM_WB is
    port(
        clk,MEM_WB_EN: in std_logic;
        MEM_WB_CLR: in std_logic;
        DEST_IN : in std_logic_vector(2 downto 0);
        ALU_C_IN : in std_logic_vector(15 downto 0);
        D_OUT_IN : in std_logic_vector(15 downto 0);
        PC_2_IN : in std_logic_vector(15 downto 0);

        PC_2_OUT : out std_logic_vector(15 downto 0);
        D_OUT_OUT : out std_logic_vector(15 downto 0);
        ALU_C_OUT : out std_logic_vector(15 downto 0);
        DEST_OUT : out std_logic_vector(2 downto 0);
        IR_IN: in std_logic_vector(15 downto 0);
        IR_OUT: out std_logic_vector(15 downto 0)
    );
end entity;

architecture pipeline_reg of MEM_WB is 

signal DEST: std_logic_vector( 2 downto 0):="000";
signal ALU_C,D_OUT,PC_2: std_logic_vector(15 downto 0):="0000000000000000";
signal IR: std_logic_vector(15 downto 0);
begin
    
-- PC_2 <= PC_2_IN;
-- ALU_C <= ALU_C_IN;
-- D_OUT <= D_OUT_IN;
-- DEST <= DEST_IN;


process(PC_2_IN, DEST_IN, D_OUT_IN, ALU_C_IN,MEM_WB_CLR, IR_IN,clk) --MEM_WB_CLR 
begin



    if(MEM_WB_EN='1') then
        IR<=IR_IN;
        PC_2 <= PC_2_IN;
        ALU_C <= ALU_C_IN;
        D_OUT <= D_OUT_IN;
        DEST <= DEST_IN;
    else
        null;
    end if;

    if(MEM_WB_CLR='1') then
        IR<="1011000000000000";
        PC_2<="0000000000000000";
        D_OUT<="0000000000000000";
        ALU_C<="0000000000000000";
        DEST<="000";

    else
        null;
    end if;

    if rising_edge(clk) then
        
        D_OUT_OUT <= D_OUT;
        ALU_C_OUT <= ALU_C;
        PC_2_OUT <= PC_2;
        DEST_OUT <= DEST;
        IR_OUT<=IR;

    end if;
end process;
end pipeline_reg;
