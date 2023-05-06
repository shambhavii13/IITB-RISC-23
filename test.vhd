library ieee;   --maiyyan saiyyan
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

    
enTITy Controller is
    port(    
        CLK : in std_logic
    ); 
end enTITy;

architecture Struct of Controller is

type matrix is array (natural range <>, natural range <>) of std_logic_vector(0 to 15);
signal mat : matrix(0 to 5, 0 to 5);
-- shared variable Instructions : arr_2d :=("1011000000000000", "1011000000000000", "1011000000000000",
--                        "1011000000000000", "1011000000000000", "1011000000000000");
signal test : std_logic_vector(3 downto 0);
begin
    
    process(CLK)
    begin
        if rising_edge(CLK) then
            test <= mat(0)(0)(3 downto 0);
        else
            null;
        end if;
    end process;
end architecture;