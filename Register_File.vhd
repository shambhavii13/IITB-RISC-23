library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity Register_File is
    port(
        RF_A1: in std_logic_vector(2 downto 0);
        RF_A2: in std_logic_vector(2 downto 0);
        RF_A3: in std_logic_vector(2 downto 0);
        RF_D1: out std_logic_vector(15 downto 0);
        RF_D2: out std_logic_vector(15 downto 0);
        RF_D3: in std_logic_vector(15 downto 0);
        RF_PC_R: out std_logic_vector(15 downto 0);
        RF_PC_W: in std_logic_vector(15 downto 0);
        RF_D3_EN,PC_EN: in std_logic; clk : in std_logic		
    );
end Register_File;

architecture rb1 of Register_File is
    component mux81 is 
        port(A0: in std_logic_vector(15 downto 0);
            A1: in std_logic_vector(15 downto 0);
            A2: in std_logic_vector(15 downto 0);
            A3: in std_logic_vector(15 downto 0);
            A4: in std_logic_vector(15 downto 0);
            A5: in std_logic_vector(15 downto 0);
            A6: in std_logic_vector(15 downto 0);
            A7: in std_logic_vector(15 downto 0);
            S: in std_logic_vector(2 downto 0);
            Op: out std_logic_vector(15 downto 0)
        );
    end component;

signal r0,  r3, r6, r7: std_logic_vector(15 downto 0):= "0000000000000000";
signal r1, r2 : std_logic_vector(15 downto 0) := "0000000000000001";
signal r4, r5 : std_logic_vector(15 downto 0) := "0000000000000001";
begin
m1: mux81 port map ( A0=>r0, A1=>r1, A2=>r2, A3=>r3, A4=>r4, A5=>r5, A6=>r6, A7=>r7, S=>RF_A1, Op=>RF_D1);
m2: mux81 port map ( A0=>r0, A1=>r1, A2=>r2, A3=>r3, A4=>r4, A5=>r5, A6=>r6, A7=>r7, S=>RF_A2, Op=>RF_D2);
RF_PC_R <= r0; 
process(RF_A1, RF_A2, RF_A3, RF_D3,RF_D3_EN ,PC_EN,clk)
begin
	if rising_edge(clk) then
		if  PC_EN='1' then
			r0 <= RF_PC_W;
		else
			null;
		end if;
    else
        null;
    end if;
	
    if rising_edge(clk) then
        if RF_D3_EN='1' then
            if RF_A3="000" then
                r0 <= RF_D3;
            elsif RF_A3="001" then
                r1 <= RF_D3;
            elsif RF_A3="010" then
                r2 <= RF_D3;
            elsif RF_A3="011" then
                r3 <= RF_D3;
            elsif RF_A3="100" then
                r4 <= RF_D3;
            elsif RF_A3="101" then   
                r5 <= RF_D3;
            elsif RF_A3="110" then
                r6 <= RF_D3;
            else
                r7 <= RF_D3;
            end if;
        else  
            null;
        end if;
    else 
        null;
    end if;
end process;

end rb1;