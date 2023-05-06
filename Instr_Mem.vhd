library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Instr_Mem is
    port(
	    clk: in std_logic;
		address: in std_logic_vector(15 downto 0);
		IM_Data: out std_logic_vector(15 downto 0)
	);
end Instr_Mem;

architecture mem_arch of Instr_Mem is
	type mem_index is array(65535 downto 0) of std_logic_vector(7 downto 0);
	signal mem: mem_index := (-- 0=>"11110010",1=>"00000111",
	
	2=>"00010010",3=>"10011000" ,4=>"00000111",5=>"11010000",
--	6=>"00010010",7=>"10011011", 8=>"00010010",9=>"10000000",
--10=>"00000010",11=>"10111111",12=>"00100011",13=>"00111110",
--	14=>"00110010",15=>"11111110",
	others => "10110000");
begin

reading : process(address)
begin
-- if clk='1' then    
    IM_Data <= mem(to_integer(unsigned(address))) & mem(to_integer(unsigned(address)+1));
-- else
--     null;
-- end if;
end process;
	
end mem_arch;