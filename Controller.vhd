library ieee;   --maiyyan saiyyan
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- CODE ME FORWARDING KARDO BEHENCHOD
    
enTITy Controller is
    port(    
        CLK : in std_logic;
        Current_Zero, Current_Carry : in std_logic;
        New_Carry, New_Zero : in std_logic;
        IR : in std_logic_vector(15 downto 0); 
        Sign_Bit, IS_IMM_ZERO_LM : in std_logic; 

        ZF_EN, CF_EN, RF_D3_EN, RF_PC_EN, SH_EN, IF_ID_EN, ID_RR_EN, RR_EX_EN, EX_MEM_EN, MEM_WB_EN ,MEM_WR_EN: out std_logic;
        MUX_SE_SEL, MUX_RF_D3_SEL, MUX_ALU1B_SEL, MUX_MEMDOUT_SEL, MUX_LM_SEL, MUX_DEST2_SEL, MUX_RF_A3_SEL : out std_logic;
        MUX_PC_SEL, MUX_DEST_SEL, MUX_ALU_A_SEL : out std_logic_vector(1 downto 0);
        MUX_ALU_B_SEL : out std_logic_vector(2 downto 0);
        ALU_OP : out std_logic_vector(3 downto 0)
    ); 
end enTITy;

architecture Struct of Controller is

type arr_2d is array (0 to 5, 15 downto 0) of std_logic;
signal Instructions : arr_2d : ("1011000000000000", "1011000000000000", "1011000000000000",
                       "1011000000000000", "1011000000000000", "1011000000000000");

signal IR_fetched : std_logic_vector(15 downto 0) : "1011000000000000";
shared variable prev3carry : std_logic_vector(0 to 2) := "000";
shared variable prev3zero : std_logic_vector(0 to 2) := "000";
shared variable is_lm, is_sm : std_logic_vector(1 downto 0) := "00";
shared variable shift_instr_en_lm, shift_instr_en_sm : std_logic := '0';

begin 

IR_fetched <= IR;

process instruction_update(CLK)
begin
    if ( rising_edge(clk) ) then
        if(shift_instr_en_lm = '1') then
            Instructions(1 to 2) := Instructions(0 to 1);
            Instructions(0) := IR_fetched;
            Instructions(4 to 5) := Instructions(3 to 4);
        elsif(shift_instr_en_sm = '1') then
            Instructions(1) := Instructions(0);
            Instructions(0) := IR_fetched;
            Instructions(3 to 5) := Instructions(2 to 4);
        else 
            Instructions(1 to 5) := Instructions(0 to 4);
            Instructions(0) := IR_fetched;
        end if;
    else
        null;
    end if;
end process

process set_controls_stage1(CLK, Instructions, Sign_Bit)
begin
    if rising_edge(clk) then
        IF_ID_EN <= '1';

        if ((Instructions(1, 15 downto 12) = "0110" ) or is_lm(0) ) then --LM
            Instructions(0) := "1011000000000000";
            is_lm(0) := '1';
            RF_PC_EN <= '0';
        elsif ((Instructions(1, 15 downto 12) = "0111" ) or is_sm(0) ) then --SM
            Instructions(0) := "1011000000000000";
            is_sm(0) := '1';
            RF_PC_EN <= '0';
        else
            is_lm(0) := '0';
            RF_PC_EN <= '1';
        end if;

 --     if (( Instructions(3, 15 downto 12) = "1000" or Instructions(3, 15 downto 12) = "1001" or Instructions(3, 15 downto 12) = "1010" ) and Sign_Bit = '1') or ( Instructions(3, 15 downto 12) = "1100") then -- BLT BLE BEQ or JAL
        if (( Instructions(3, 15 downto 12) = "1000" or Instructions(3, 15 downto 12) = "1001" or Instructions(3, 15 downto 12) = "1010" ) and Sign_Bit = '1')  then --changed for JAL
            MUX_PC_SEL <= "01";
            Instructions(0 to 2)="1011000000000000";
        elsif ( Instructions(1, 15 downto 12) = "1100") then
            MUX_PC_SEL <= "01";
            Instruction(0)="1011000000000000";
        elsif Instructions(2, 15 downto 12) = "1101" then
            MUX_PC_SEL <= "10";
            Instructions(0 to 1)="1011000000000000";
        elsif Instructions(3, 15 downto 12) = "1111" then
            MUX_PC_SEL <= "11";
            Instructions(0 to 2)="1011000000000000";
        else 
            MUX_PC_SEL <= "00";
            -- LATCH
        end if;
    else
        null;
    end if; 
    
end process

process set_controls_stage2(CLK, Instructions)
begin
    if rising_edge(clk) then

        if ( Instructions(1, 15 downto 12) = "0011" or Instructions(1, 15 downto 12) = "0110" or Instructions(1, 15 downto 12) = "0111" or Instructions(1, 15 downto 12) = "1100" or Instructions(1, 15 downto 12) = "1111") then 
            MUX_SE_SEL <= "1";
        else 
            MUX_SE_SEL <= "0"; -- SE_6 IS DEFAULT
        end if;

        if ( Instructions(1, 15 downto 12) = "1000" or Instructions(1, 15 downto 12) = "1001" or Instructions(1, 15 downto 12) = "1010" or Instructions(1, 15 downto 12) = "1100" or Instructions(1, 15 downto 12) = "1111"  ) then 
           SH_EN <= "1";
        else      
           SH_EN <= "0";
        end if; 

        if ( is_sm(1) = '1' ) then
            MUX_SM_SEL <= '1';
            ID_RR_EN <= '0';
        else
            MUX_SM_SEL <= '0';
            ID_RR_EN <= '1';
        end if;     

    else
        null
    end if;
    
end process

process set_controls_stage3(CLK, Instructions)
begin

    variable opcode := Instructions(5, 15 downto 12)
    variable last3bits :=Instructions(5, 2 downto 0)

    if rising_edge(clk) then 

        if ( Instructions(2, 15 downto 12) = "0111" ) then
            is_sm(1) := '1';
            shift_instr_enable_sm := '1';
        else
            is_sm(1) := '0';
            shift_instr_enable_sm := '0';
        end if;

        if ( is_sm(1) = '1' ) then 
            MUX_RF_A3_SEL <= '1';
        else
            MUX_RF_A3_SEL <= '0';
        end if;

        if (opcode = "0101" or opcode = "0111" or opcode = "1000" or opcode = "1111" or opcode = "1011") then -- SW, SM, BEQ, JRI or NOP then dont give enable
            RF_D3_EN <= "0"
        elsif ((opcode = "0001" and last3bits="010") or (opcode = "0001" and last3bits="110") or (opcode = "0010" and last3bits="010") or (opcode = "0010" and last3bits="110") ) and (prev3carry(2) = '0') -- ADC, ACC, NDC, NCC
            RF_D3_EN <= "0"
        elsif ((opcode = "0001" and last3bits="001") or (opcode = "0001" and last3bits="101") or (opcode = "0010" and last3bits="001") or (opcode = "0010" and last3bits="101") ) and (prev3zero(2) = '0') -- ADZ, ACZ, NDZ, NCZ
            RF_D3_EN <= "0";
        else
            RF_D3_EN <= "1";
        end if;

        if (opcode = "1100" or opcode = "1101") then -- JAL AND JLR
           MUX_RF_D3_SEL <= "1";
        else 
            MUX_RF_D3_SEL <= "0";
        end if;

        if (Instructions(2, 15 downto 12) = "0001" or Instructions(2, 15 downto 12) = "0010") then -- 5 to 3
            MUX_DEST_SEL <= "00";
        elsif (Instructions(2, 15 downto 12) = "0000" ) -- 8 to 6
            MUX_DEST_SEL <= "01";
        elsif (Instructions(2, 15 downto 12) = "0011" or Instructions(2, 15 downto 12) = "0100" or Instructions(2, 15 downto 12) = "1100" or Instructions(2, 15 downto 12) = "1101") -- 11 to 9
            MUX_DEST_SEL <= "10";
        else 
            null
        end if;

        if ( Instructions(5, 5 downto 3) = Instructions(2, 11 downto 9) ) and ( (Instructions(5, 15 downto 12)="0010" and Instructions(2, 15 downto 12)="0010") or (Instructions(5, 15 downto 12)="0001" and Instructions(2, 15 downto 12)="0001") ) then 
            MUX_ALU_A_SEL <= "11" -- WB_Forwarding for ADD, NAND hazard
        elsif ( Instructions(3, 5 downto 3) = Instructions(2, 11 downto 9) ) and ( (Instructions(3, 15 downto 12)="0010" and Instructions(2, 15 downto 12)="0010") or (Instructions(3, 15 downto 12)="0001" and Instructions(2, 15 downto 12)="0001") )
            MUX_ALU_A_SEL <= "01" -- ALU1_C forwarding for ADD, NAND hazard
        elsif ( Instructions(4, 5 downto 3) = Instructions(2, 11 downto 9) ) and ( (Instructions(4, 15 downto 12)="0010" and Instructions(2, 15 downto 12)="0010") or (Instructions(4, 15 downto 12)="0001" and Instructions(2, 15 downto 12)="0001") ) 
            MUX_ALU_A_SEL <= "10" -- MEM_DOUT forwarding for ADD, NAND hazard
        else 
            MUX_ALU_A_SEL <= "00" -- RA as it is
        end if;

        if ( Instructions(5, 5 downto 3) = Instructions(2, 8 downto 6) ) and ( (Instructions(5, 15 downto 12)="0010" and Instructions(2, 15 downto 12)="0010") or (Instructions(5, 15 downto 12)="0001" and Instructions(2, 15 downto 12)="0001") ) then 
            MUX_ALU_B_SEL <= "000" -- WB_Forwarding for ADD, NAND hazard
        elsif (Instructions(2, 15 downto 12) = "0001" or Instructions(2, 15 downto 12) = "0010" or Instructions(2, 15 downto 12) = "1000" or Instructions(2, 15 downto 12) = "1001" or Instructions(2, 15 downto 12) = "1101") 
        -- (Instructions(2, 15 downto 12) = "0000" or Instructions(2, 15 downto 12) = "0010" or Instructions(2, 15 downto 12) = "0000") -- IMM FOR LLI, ADI, LW, SW, LM, SM, JAL, JRI
            MUX_ALU_B_SEL <= "001" -- RB NEEDED FOR ADD, NAND 
        elsif ( Instructions(3, 5 downto 3) = Instructions(2, 8 downto 6) ) and ( (Instructions(3, 15 downto 12)="0010" and Instructions(2, 15 downto 12)="0010") or (Instructions(3, 15 downto 12)="0001" and Instructions(2, 15 downto 12)="0001") ) 
            MUX_ALU_B_SEL <= "010" -- ALU1_C for ADD AND NAND
        elsif ( Instructions(4, 5 downto 3) = Instructions(2, 8 downto 6) ) and ( (Instructions(4, 15 downto 12)="0010" and Instructions(2, 15 downto 12)="0010") or (Instructions(4, 15 downto 12)="0001" and Instructions(2, 15 downto 12)="0001") ) 
            MUX_ALU_B_SEL <= "011"
        else 
            MUX_ALU_B_SEL <= "111" -- IMM
        end if;

        if (is_lm(1) = '1') then -- Then LM has reached EX
            MUX_LM_SEL <= '1';
            RR_EX_EN <= '0';
        else
            MUX_LM_SEL <= '0';
            RR_EX_EN <= '1';
        end if;

    else 
        null
    end if;
end process

process set_controls_stage4(CLK, Instructions, Current_Carry, Current_Zero, IS_IMM_ZERO)
begin
    variable opcode := Instructions(3, 15 downto 12)
    variable last3bits :=Instructions(3, 2 downto 0)

    if ( rising_edge(clk) ) then
        IX_MEM_EN <= '1';
        if ( Instructions(3, 15 downto 12) = "0110" ) then
            is_lm(1) := '1';
            shift_instr_enable_lm := '1';
        else
            is_lm(1) := '0';
            shift_instr_enable_lm := '0';
        end if;
    
        if ( Instructions(3, 15 downto 12) = "0110" ) and (IS_IMM_ZERO = '1')  then -- LM and IMM is zero
            Instructions(3) := "1011000000000001";
        else
            null;
        end if;
    
        if (is_lm(1) = '1') then
            MUX_DEST2_SEL <= '1';
        else
            MUX_DEST2_SEL <= '0';
        end if;
    
        if (opcode="0001" and last3bits = "000") or (opcode = "0000") then 
            ZF_EN <= '1';
            CF_EN <= '1';
            ALU_OP <= "0000";
        elsif (opcode="0001" and last3bits = "010") then 
            if Current_Carry = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0000";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        elsif (opcode="0001" and last3bits = "001") then 
            if Current_Zero = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0000";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        elsif (opcode="0001" and last3bits = "011") then 
            ZF_EN <= '1';
            CF_EN <= '1';
            ALU_OP <= "0001";
        elsif (opcode="0001" and last3bits = "100") then 
            ZF_EN <= '1';
            CF_EN <= '1';
            ALU_OP <= "0010";
        elsif (opcode="0001" and last3bits = "110") then 
            if Current_Carry = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0010";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        elsif (opcode="0001" and last3bits = "101") then 
            if Current_Zero = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0010";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        elsif (opcode="0001" and last3bits = "111") then 
            ZF_EN <= '1';
            CF_EN <= '1';
            ALU_OP <= "0011";
        ---------------
        elsif (opcode="0010" and last3bits = "000") then 
            ZF_EN <= '1';
            CF_EN <= '1';
            ALU_OP <= "0100";
        elsif (opcode="0010" and last3bits = "010") then 
            if Current_Carry = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0100";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        elsif (opcode="0010" and last3bits = "001") then 
            if Current_Zero = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0100";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        ----------
        elsif (opcode="0010" and last3bits = "100") then 
            ZF_EN <= '1';
            CF_EN <= '1';
            ALU_OP <= "0101";
        elsif (opcode="0010" and last3bits = "110") then 
            if Current_Carry = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0101";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        elsif (opcode="0010" and last3bits = "101") then 
            if Current_Zero = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0101";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;    
        elsif (opcode="0011") then 
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "0000"
        elsif (opcode="0100") then 
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "0000";
        elsif (opcode="0101") then 
            ZF_EN <= '0'
            CF_EN <= '0'
            ALU_OP <= "0000"
        elsif (opcode="0110") then --LM
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "0000";
        elsif (opcode="0111") then --SM
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "0000";
        elsif (opcode="1000") then --BEQ
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "0110";
        elsif (opcode="1001" and ) then --BLT
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "0111";
        elsif (opcode="1010") then --BLE
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "1000";
        elsif (opcode="1100") then --JAL
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "1111";
        elsif (opcode="1101") then --JLR
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "1111";
        elsif (opcode="1111") then --JRI
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "0000";
        end if;
    else
        null;
    end if;

end process;

process update_prev_carry(clk, New_Carry, New_Zero)
begin
    if(rising_edge(clk)) then
        prev3carry(1 to 2) := prev3carry(0 to 1)
        prev3carry(0) := New_Carry
        prev3zero(1 to 2) := prev3zero(0 to 1)
        prev3zero(0) := New_Zero
    else
        null;
    end if;
end process;

process set_controls_stage5(CLK, Instructions)
begin
    if rising_edge(clk) then
        variable opcode := Instructions(4, 15 downto 12)

        if (opcode="0101") or (opcode = "0111") then  -- SM, SW
            MEM_WR_EN <= '1';
        else
            MEM_WR_EN <= '0';
        end if;
        
    else 
        null;
    end if; 
end process


process set_controls_stage6(CLK, Instructions)
begin
    if rising_edge(clk) then
        variable opcode := Instructions(5, 15 downto 12)

        if (opcode="0100") or (opcode = "0110") then  -- LW, LM
            MUX_MEMDOUT_SEL <= '0'; -- MEM_DOUT
        else
            MUX_MEMDOUT_SEL <= '1'; -- ALU_C
        end if;

        if (Instructions(5) = "1011000000000001") then
            shift_instr_en_lm := '0';
            is_lm := "000";
        else
            null;
        end if;

    else 
        null
    end if; 
end process

-- process hazard(CLK,Instructions)
-- begin  
    
end process;
end architecture;