library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
entity RR_EX is
    port(
        clk, RR_EX_EN,RR_EX_CLR : in std_logic;
        DEST_IN : in std_logic_vector(2 downto 0);
        ALU_A_MUX_IN : in std_logic_vector(15 downto 0);
        ALU_B_MUX_IN : in std_logic_vector(15 downto 0);
        RA_IN : in std_logic_vector(15 downto 0);

        -- SE_IMM_IN : in std_logic_vector(15 downto 0);
        PC_2xIMM_IN : in std_logic_vector(15 downto 0);
        PC_2_IN : in std_logic_vector(15 downto 0);

        DEST_OUT : out std_logic_vector(2 downto 0);
        ALU_A_MUX_OUT : out std_logic_vector(15 downto 0);
        ALU_B_MUX_OUT : out std_logic_vector(15 downto 0);
        RA_OUT : out std_logic_vector(15 downto 0);

        -- SE_IMM_OUT : out std_logic_vector(15 downto 0);
        PC_2xIMM_OUT : out std_logic_vector(15 downto 0);
        PC_2_OUT : out std_logic_vector(15 downto 0);
        
        IR_IN: in std_logic_vector(15 downto 0);
        IR_OUT: out std_logic_vector(15 downto 0)
    );
end entity;

architecture pipeline_reg of RR_EX is 

signal DEST: std_logic_vector( 2 downto 0) := "000";
signal ALU_A, ALU_B, RA, PC_2, PC_2xIMM: std_logic_vector(15 downto 0):="0000000000000000";
signal IR: std_logic_vector(15 downto 0);

begin

-- PC_2 <= PC_2_IN;
-- PC_2xIMM <= PC_2xIMM_IN;
-- SE_IMM <= SE_IMM_IN;
-- RA <= RA_IN;
-- RB <= RB_IN;
-- DEST <= DEST_IN;
    

process(PC_2_IN, ALU_A_MUX_IN, ALU_B_MUX_IN, DEST_IN, RA_IN, PC_2xIMM_IN,RR_EX_CLR,RR_EX_EN, IR_IN,clk)
begin
    ALU_B <= ALU_B_MUX_IN; -- SM
    PC_2 <= PC_2_IN;
    PC_2xIMM <= PC_2xIMM_IN;
    RA <= RA_IN;
    ALU_A <= ALU_A_MUX_IN;
    DEST <= DEST_IN;
    if(RR_EX_EN='1') then
        IR <= IR_IN;
    else
        null;
    end if;

    if(RR_EX_CLR='1') then
        IR<="1011000010110000";
        PC_2<="0000000000000000";
        PC_2xIMM<="0000000000000000";
        RA<="0000000000000000";
        ALU_A<="0000000000000000";
        ALU_B<="0000000000000000";  -- may have to change depending on ALU_B
        DEST<="000";

    else
        null;
    end if;
    if rising_edge(clk) then
        
        RA_OUT <= RA;
        ALU_A_MUX_OUT <= ALU_A;
        ALU_B_MUX_OUT <= ALU_B;
        PC_2_OUT <= PC_2;
        PC_2xIMM_OUT <= PC_2xIMM;
        DEST_OUT <= DEST;
        IR_OUT<=IR;

    end if;
end process;

end pipeline_reg;

