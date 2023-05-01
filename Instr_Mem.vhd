library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Inst_Mem is
    port(
	   clk: in std_logic;
		address: in std_logic_vector(15 downto 0);
		IM_Data: out std_logic_vector(15 downto 0)
		);
end Inst_Mem;

architecture mem_arch of Inst_Mem is
	type mem_index is array(65535 downto 0) of std_logic_vector(15 downto 0);
	signal mem: mem_index := (0=>"0100000000000001", 1=>"0111111111111111",2=>"0001000100000011", others => "0000000000000000");
begin

reading:process(clk)
begin
if rising_edge(clk) then
    IM_Data<=mem(to_integer(unsigned(address)));
else
    null;
end if;
end process;
	
end mem_arch;