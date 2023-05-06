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
	signal mem: mem_index := (8=>"00010010",9=>"10011000" ,10=>"00011001",11=>"01110000",others => "10110000");
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