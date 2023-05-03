library ieee;   --maiyyan saiyyan
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
enTITy Controller is
    port(    
        CLK : in std_logic;
        Current_Zero, Current_Carry : in std_logic;
        IR : in std_logic_vector(15 downto 0);  

        ZF_EN, CF_EN, RF_D3_EN, RF_PC_EN, SH_EN:out std_logic;
        MUX_SE_SEL, MUX_RF_D3_SEL, MUX_ALU1B_SEL, MUX_MEMDOUT_SEL:out std_logic;
        MUX_PC_SEL, MUX_DEST_SEL:out std_logic_vector(1 downto 0);
        ALU_OP :out std_logic_vector(3 downto 0);
        
        New_Carry, New_Zero : out std_logic
    ); 
end enTITy;

architecture Struct of Controller

type arr_2d is array (0 to 5, 15 downto 0) of std_logic;
signal Instructions : arr_2d := ("0000000000000000", "0000000000000000", "0000000000000000",
                       "0000000000000000","0000000000000000","0000000000000000");

signal IR_fetched : std_logic_vector(15 downto 0) := "0000000000000000";

begin 

IR_fetched <= IR;

process instruction_update(CLK)
begin
    if rising_edge(clk) then
        Instructions(1 to 5) := Instructions(0 to 4);
        Instructions(0) := IR_fetched; 
    else
        null
    end if;
end process

process set_controls_stage1(CLK, instructions, Sign_Bit)
begin
    if rising_edge(clk) then
        if Haz_LMSM = '0' then
            RF_PC_EN <= '1';
        else
            RF_PC_EN <= '0';
        end if;

        if (( Instructions(3, 15 downto 12) = "1000" or Instructions(3, 15 downto 12) = "1001" or Instructions(3, 15 downto 12) = "1010" ) and Sign_Bit = '1') or ( Instructions(3, 15 downto 12) = "1100") then -- BLT BLE BEQ
            MUX_PC_SEL <= "01";
        elsif Instructions(3, 15 downto 12) = "1101" then
            MUX_PC_SEL <= "10";
        elsif Instructions(3, 15 downto 12) = "1111" then
            MUX_PC_SEL <= "11";
        else 
            MUX_PC_SEL <= "00";
        end if;
    else
        null
    end if; 
    
end process

process set_controls_stage2(CLK, instructions)
begin
    if rising_edge(clk) then

        if ( Instructions(1, 15 downto 12) = "0011" or Instructions(1, 15 downto 12) = "0110" or Instructions(1, 15 downto 12) = "0111" or Instructions(1, 15 downto 12) = "1100" or Instructions(1, 15 downto 12) = "1111") then 
           MUX_SE_SEL <= "1"
        else 
            MUX_SE_SEL <= "0"  --SE_6 IS DEFAULT
        end if;

        if ( Instructions(1, 15 downto 12) = "1000" or Instructions(1, 15 downto 12) = "1001" or Instructions(1, 15 downto 12) = "1010" or Instructions(1, 15 downto 12) = "1100" or Instructions(1, 15 downto 12) = "1111"  ) then 
            SHIFT_ENABLE <= "1"
        else   
            SHIFT_ENABLE <= "0"
        end if; 
    else
        null
    end if;
    
end process

process set_controls_stage3(CLK, instructions)
begin

    if rising_edge(clk) then

        if () then 
           MUX_RF_D3_EN <= "0"
        else 
            MUX_RF_D3_EN <= "1"
        end if;

        if () then 
            MUX_RF_D3_SEL <= "0"
        else   
            MUX_RF_D3_SEL <= "1"
        end if;

        if () then 
            MUX_DEST_SEL <= "0"
        else   
            MUX_DEST_SEL <= "1"
        end if;
    else 
        null
    end if;
end process

process set_controls_stage4(CLK, instructions)
begin
    opcode:= instruction(3,15 downto 12)
    last3bits:=instruction(3,2 downto 0)
    if (opcode='0001') then 
        ZF_EN <= '1'
        CF_EN <= '1'
        if (last3bits='000') then 
           ALU_OP <= "0000"
           RF_D3_EN <= '1'
            
        elsif (last2bits='010' and Current_Carry='0') or (last2bits='001' and Current_Zero='0') then
            RF_D3_EN <= '0'
        elsif expression then
            
            RF_D3_EN <= '1' 
        end if;
    elsif (opcode='0010') then
        ALU_OP <= "0000"
        ZF_EN <= '1'
        CF_EN <= '0'
        if (last2bits='10' and Current_Carry='0') or (last2bits='01' and Current_Zero='0') then
            RF_D3_EN <= '0'
        else 
            RF_D3_EN <= '1' 
        end if;
           
        elsif (last2bits='01') then 
           
    end if  
end process


process set_controls_stage5(CLK, instructions)
begin
    if Instrunctions(4, 15 downto 12)=

    end if  
end process


process set_controls_stage6(CLK, instructions)
begin
    if Instrunctions(5,   15 downto 12)=

    end if  
end process





end architecture;