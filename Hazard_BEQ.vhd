library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

enTITy BEQ_HAZ is
    port(opcode : in std_logic_vector(3 downto 0);
          alu_zf:in std_logic;
          hbit : in std_logic;
          haz_BEQ: out std_logic;
          hbit_new: out std_logic
    );
end BEQ_HAZ;
architecture beq of BEQ_HAZ is
begin
    process(hbit,alu_zf,opcode)
	begin
		if opcode="1000" then
			if (hbit ='1' and alu_zf='1') then  --branch predicted and branch taken
				hbit_new <='1';
				haz_BEQ<='0';
			elsif (hbit ='1' and alu_zf='0') then --branch predicted but not taken
				hbit_new <='0';
				haz_BEQ<='1';
			elsif (hbit ='0' and alu_zf='1') then -- branch not predicted but taken
				hbit_new <='1';
				haz_BEQ<='1';
			else                                  --branch not predicted and not taken
				hbit_new <='0';
				haz_BEQ<='0';
			end if;
        else null;
		end if;
	end process;
end beq;