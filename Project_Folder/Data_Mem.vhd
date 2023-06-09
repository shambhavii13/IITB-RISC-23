library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Data_Mem is
    port(
	    clk: in std_logic;
		Mem_add, Din: in std_logic_vector(15 downto 0);
		Dout: out std_logic_vector(15 downto 0);
		Enable: in std_logic
	);
end Data_Mem;

architecture mem_arch of Data_Mem is
	type mem_index is array(65535 downto 0) of std_logic_vector(7 downto 0);
	signal mem: mem_index := (1=>"00000000",2=>"00000000",others => "00000000");
begin

writing : process(clk, Mem_add, Din, Enable)
begin

if (rising_edge(clk) and Enable = '1') then
	   mem(to_integer(unsigned(Mem_add))) <= Din(15 downto 8);
	   mem(to_integer(unsigned(Mem_add)+1)) <= Din(7 downto 0);
else
    null;
end if;
end process;

reading : process(clk,Mem_add)
begin
--if rising_edge(clk) then    
    Dout <= mem(to_integer(unsigned(Mem_add))) & mem(to_integer(unsigned(Mem_add)+1));
--else
--    null;
--end if;
end process;
	
end mem_arch;