library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Inst_Mem is
    port(
	   RE_instr,clk: in std_logic;
		address: in std_logic_vector(15 downto 0);
		Dout: out std_logic_vector(15 downto 0)
		);
end Inst_Mem;

architecture mem_arch of Inst_Mem is
	type mem_index is array(65535 downto 0) of std_logic_vector(15 downto 0);
	signal mem: mem_index := (0=>"0100000000000001", 1=>"0111111111111111",2=>"0001000100000011", others => "0000000000000000");
begin

reading:process(RE,clk)
begin
if rising_edge(clk) then
    if RE_instr='1' then 
	Dout<=mem(to_integer(unsigned(address)));
 else
	   null;
	 end if;
  else
    null;
  end if;
end process;
	
end mem_arch;