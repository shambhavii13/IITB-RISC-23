library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Hazard_PC is
    port(
        IR: in std_logic_vector(15 downto 0)
        c_f,z_f: in std_logic;
        haz_PC: out std_logic
    );
end Hazard_PC;

architecture find_hazard of Hazard_PC is

    begin
        process(IR)
            begin 
                if (IR(15 downto 12)="0011" or IR(15 downto 12)="0100") and IR(11 downto 9)="000" then
                    haz_PC='1';
                elsif IR(15 downto 12)="0001" and IR(5 downto 3)="000" and 
                    hax_PC='1';
                end  if;

        end process;
end find_hazard;
