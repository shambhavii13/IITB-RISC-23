library ieee;   --maiyyan saiyyan
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

    
enTITy pipeline_controller is
    port(    
        CLK : in std_logic;
        Current_Zero, Current_Carry : in std_logic;
        New_Carry, New_Zero : in std_logic; 
        Sign_Bit, IS_IMM_ZERO_LM, IS_IMM_ZERO_SM : in std_logic; 
        IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR : IN std_logic_vector(15 downto 0);

        IF_ID_CLR,ID_RR_CLR,RR_EX_CLR,EX_MEM_CLR,MEM_WB_CLR : out std_logic;
        ZF_EN, CF_EN, RF_D3_EN, RF_PC_EN, SH_EN, IF_ID_EN, ID_RR_EN, RR_EX_EN, EX_MEM_EN, MEM_WB_EN ,MEM_WR_EN: out std_logic;
        MUX_SE_SEL, MUX_RF_D3_SEL, MUX_ALU1B_SEL, MUX_MEMDOUT_SEL, MUX_LM_SEL,MUX_SM_SEL, MUX_DEST2_SEL, MUX_RF_A3_SEL : out std_logic;
        MUX_PC_SEL, MUX_DEST_SEL: out std_logic_vector(1 downto 0);
        MUX_ALU_B_SEL, MUX_ALU_A_SEL : out std_logic_vector(2 downto 0);
        ALU_OP : out std_logic_vector(3 downto 0)
    ); 
end enTITy;

architecture Struct of pipeline_controller is

shared variable prev3carry : std_logic_vector(0 to 2) := "000";
shared variable prev3zero :std_logic_vector(0 to 2) := "000";
shared variable is_lm0, is_lm1, is_sm0, is_sm1 : std_logic := '0'; -- Higher bit : LM reached IX, SM reached RR -- Lower Bit: LM, SM started
shared variable shift_instr_en_lm, shift_instr_en_sm : std_logic := '0';

begin

set_controls_stage1: process(IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR,Sign_Bit, IS_IMM_ZERO_LM, IS_IMM_ZERO_SM) -- CLK
begin

        MEM_WB_CLR<='0';
        EX_MEM_CLR<='0';
        RR_EX_CLR<='0';
        ID_RR_CLR<='0';
        IF_ID_CLR<='0';
    -- if rising_edge(clk) then
        IF_ID_EN <= '1';

        if ((IF_ID_IR( 15 downto 12) = "0110" ) or is_lm0='1' ) then --LM
            IF_ID_CLR<='1';
            is_lm0 := '1';
            RF_PC_EN <= '0';
        elsif ((IF_ID_IR( 15 downto 12) = "0111" ) or is_sm0='1' ) then --SM
            IF_ID_CLR<='1';
            is_sm0 := '1';
            RF_PC_EN <= '0';
        elsif (MEM_WB_IR = "1011000000000000") then
            is_lm0 := '0';
        else
            is_lm0 := '0';
            is_sm0 := '0';
            RF_PC_EN <= '1';        --PC_EN IS ON BY DEFAULT
        end if;

     if (( RR_EX_IR( 15 downto 12) = "1000" or RR_EX_IR( 15 downto 12) = "1001" or RR_EX_IR( 15 downto 12) = "1010" ) and Sign_Bit = '1') or ( RR_EX_IR( 15 downto 12) = "1100") then -- BLT BLE BEQ or JAL
        -- if (( RR_EX_IR( 15 downto 12) = "1000" or RR_EX_IR( 15 downto 12) = "1001" or RR_EX_IR( 15 downto 12) = "1010" ) and Sign_Bit = '1')  then --BEQ,BLE,BLT
            MUX_PC_SEL <= "01";
            RR_EX_CLR<='1';
            ID_RR_CLR<='1';
            IF_ID_CLR<='1';

        -- elsif ( IF_ID_IR( 15 downto 12) = "1100") then --JAL
        --     MUX_PC_SEL <= "01";
        --     IF_ID_CLR<='1';
        elsif ID_RR_IR( 15 downto 12) = "1101" then--JLR
            MUX_PC_SEL <= "10";
            ID_RR_CLR<='1';
            IF_ID_CLR<='1';
        elsif RR_EX_IR( 15 downto 12) = "1111" then--JRI
            MUX_PC_SEL <= "11";
            RR_EX_CLR<='1';
            ID_RR_CLR<='1';
            IF_ID_CLR<='1';
        else 
            MUX_PC_SEL <= "00";
            -- LATCH
        end if;

        if ( RR_EX_IR( 15 downto 12) = "0110" ) and (IS_IMM_ZERO_LM = '1')  then -- LM and IMM is zero
            RR_EX_CLR <= '1'; -- NOP FOR LM
        else
            null;
        end if;

        if ( ID_RR_IR( 15 downto 12) = "0111" ) and (IS_IMM_ZERO_SM = '1')  then -- SM and IMM is zero
            -- RR_EX_IR <= "1011000000000011"; -- NOP FOR SM
            ID_RR_CLR <= '1'; -- NOP FOR SM
            is_sm0 := '0';
        else
            null;
        end if; 
    
end process;

 set_controls_stage2: process(IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR)
begin
    -- if rising_edge(clk) then
        ID_RR_EN <= '1';
        if ( IF_ID_IR( 15 downto 12) = "0011" or IF_ID_IR( 15 downto 12) = "0110" or IF_ID_IR( 15 downto 12) = "0111" or IF_ID_IR( 15 downto 12) = "1100" or IF_ID_IR( 15 downto 12) = "1111") then --LLI,LM,SM,JAL,JRI
            MUX_SE_SEL <= '1';
        else 
            MUX_SE_SEL <= '0'; -- SE_6 IS DEFAULT
        end if;

        if ( IF_ID_IR( 15 downto 12) = "1000" or IF_ID_IR( 15 downto 12) = "1001" or IF_ID_IR( 15 downto 12) = "1010" or IF_ID_IR( 15 downto 12) = "1100" or IF_ID_IR( 15 downto 12) = "1111"  ) then --BEQ,BLE,BLT,JAL,JRI
           SH_EN <= '1';
        else      
           SH_EN <= '0';
        end if; 

        if ( is_sm1 = '1' ) then
            MUX_SM_SEL <= '1';
            ID_RR_EN <= '0';
        else
            MUX_SM_SEL <= '0';--DEFAULT FOR ALL NON SM SITUATIONS
            --ID_RR_EN <= '1';
        end if;     

    -- else
    --     null; 
    -- end if;
    
end process;

 set_controls_stage3: process(IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR, IS_IMM_ZERO_SM)
    variable opcode  : std_logic_vector(3 downto 0) := MEM_WB_IR( 15 downto 12);
    variable last3bits : std_logic_vector(2 downto 0) :=MEM_WB_IR( 2 downto 0);
 begin
	opcode := MEM_WB_IR( 15 downto 12);
		last3bits:=MEM_WB_IR( 2 downto 0);
    -- variable opcode  : std_logic_vector(3 downto 0) := MEM_WB_IR( 15 downto 12);
    -- variable last3bits : std_logic_vector(2 downto 0) :=MEM_WB_IR( 2 downto 0);

    -- if rising_edge(clk) then 
        RR_EX_EN <= '1';
        if ( ID_RR_IR( 15 downto 12) = "0111" ) then--CHECKING IF SM HAS REACHED RR
            is_sm1 := '1';
        elsif ( ID_RR_IR( 15 downto 12) = "0111" ) and (IS_IMM_ZERO_SM = '1')  then -- SM and IMM is zero -- THIS AN ISSUE
            is_sm1 := '0';
        else
            null;
        end if;
          --  shift_instr_en_sm := '1';--STOPS I2 FROM GOING FURTHER WHILE I1 SHIFTING CONTINUES
        -- else
        --     is_sm1 := '0';
        --    -- shift_instr_en_sm := '0';
        -- end if;

        if ( is_sm1 = '1' ) then --ADDRESS FOR STORING GETS UPDATED FROM SM BLOCK 
            MUX_RF_A3_SEL <= '1';
        else
            MUX_RF_A3_SEL <= '0';
        end if;

        -- if ( ID_RR_IR( 15 downto 12) = "0111" ) and (IS_IMM_ZERO_SM = '1')  then -- SM and IMM is zero
        --     -- RR_EX_IR <= "1011000000000011"; -- NOP FOR SM
        --    -- ID_RR_IR <= "1011000000000011"; -- NOP FOR SM
        --     is_sm := "00";
        -- else
        --     null;
        -- end if;

        -- CHECK THIS SCARIA ISE ALAG BLOCK ME  --ok
        if (opcode = "0101" or opcode = "0111" or opcode = "1000" or opcode = "1001" or opcode = "1010" or opcode = "1111" or opcode = "1011") then -- SW, SM, BEQ, JRI or NOP then dont give enable
            RF_D3_EN <= '0';
        elsif ((opcode = "0001" and last3bits="010") or (opcode = "0001" and last3bits="110") or (opcode = "0010" and last3bits="010") or (opcode = "0010" and last3bits="110") ) and (prev3carry(2) = '0')then -- ADC, ACC, NDC, NCC
            RF_D3_EN <= '0';
        elsif ((opcode = "0001" and last3bits="001") or (opcode = "0001" and last3bits="101") or (opcode = "0010" and last3bits="001") or (opcode = "0010" and last3bits="101") ) and (prev3zero(2) = '0') then-- ADZ, ACZ, NDZ, NCZ
            RF_D3_EN <= '0';
        else
            RF_D3_EN <= '1';
        end if;

        if (opcode = "1100" or opcode = "1101") then -- JAL AND JLR
           MUX_RF_D3_SEL <= '1';
        else 
            MUX_RF_D3_SEL <= '0';
        end if;

        if (ID_RR_IR( 15 downto 12) = "0001" or ID_RR_IR( 15 downto 12) = "0010") then
            MUX_DEST_SEL <= "00";--IR5TO3
        elsif (ID_RR_IR( 15 downto 12) = "0000" ) then
            MUX_DEST_SEL <= "01";--IR8TO6
        elsif (ID_RR_IR( 15 downto 12) = "0011" or ID_RR_IR( 15 downto 12) = "0100" or ID_RR_IR( 15 downto 12) = "1100" or ID_RR_IR( 15 downto 12) = "1101") then
            MUX_DEST_SEL <= "10";--IR11TO9
        else 
            MUX_DEST_SEL <= "00";--IR5TO3(DEFAULT)
        end if;

        -- for mux b
        if(ID_RR_IR( 15 downto 12) = "0000" or ID_RR_IR( 15 downto 12) = "0011" or ID_RR_IR( 15 downto 12) = "0100" or ID_RR_IR( 15 downto 12) = "0101" or ID_RR_IR( 15 downto 12) = "1111") then
            MUX_ALU_B_SEL <="001";
        else 
            MUX_ALU_B_SEL <="000";
        end if;

       -- for mux a
        if(ID_RR_IR( 15 downto 12) = "0100" or ID_RR_IR( 15 downto 12) = "0100") then
            MUX_ALU_A_SEL <="001";
        else
            MUX_ALU_A_SEL <="000";
        end if;
        if (is_lm1 = '1') then -- Then LM has reached EX
            MUX_LM_SEL <= '1';
            RR_EX_EN <= '0';
        else
            MUX_LM_SEL <= '0';
            -- RR_EX_EN <= '1';
        end if;

    -- else 
    --     null;
    -- end if;
end process;

 set_controls_stage4: process(IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR, Current_Carry, Current_Zero)
    variable opcode : std_logic_vector(3 downto 0) := RR_EX_IR( 15 downto 12);
    variable last3bits  : std_logic_vector(2 downto 0):=RR_EX_IR( 2 downto 0);
begin

		opcode := RR_EX_IR( 15 downto 12);
		last3bits:=RR_EX_IR( 2 downto 0);
    -- variable opcode : std_logic_vector(3 downto 0) := RR_EX_IR( 15 downto 12);
    -- variable last3bits  : std_logic_vector(2 downto 0):=RR_EX_IR( 2 downto 0);

    -- if ( rising_edge(clk) ) then
        EX_MEM_EN <= '1';
        if ( RR_EX_IR( 15 downto 12) = "0110" ) then --LM REACHES EX
            is_lm1 := '1';
        else 
            null;
        end if;
           -- shift_instr_en_lm := '1'; 
        if (MEM_WB_IR = "1011000000000000") then
            is_lm1 := '0';
        else 
            null;
        end if;
        -- else
        --     is_lm1 := '0';
        --   --  shift_instr_en_lm := '0'; SHIFT IS BEING HANDLED ALREADY 
        -- end if;
    
--        if ( RR_EX_IR( 15 downto 12) = "0110" ) and (IS_IMM_ZERO_LM = '1')  then -- LM and IMM is zero
--            RR_EX_IR <= "1011000000000001"; -- NOP FOR LM
--        else
--            null;
--        end if;
    
        if (is_lm1 = '1') then --AFTER LM REACHES EX
            MUX_DEST2_SEL <= '1';
        else
            MUX_DEST2_SEL <= '0';
        end if;
    
        if (opcode="0001" and last3bits = "000") or (opcode = "0000") then --ADA,ADI
            ZF_EN <= '1';
            CF_EN <= '1';
            ALU_OP <= "0000";
        elsif (opcode="0001" and last3bits = "010") then --ADC
            if Current_Carry = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0000";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        elsif (opcode="0001" and last3bits = "001") then --ADZ
            if Current_Zero = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0000";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        elsif (opcode="0001" and last3bits = "011") then --AWC
            ZF_EN <= '1';
            CF_EN <= '1';
            ALU_OP <= "0001";
        elsif (opcode="0001" and last3bits = "100") then --ACA
            ZF_EN <= '1';
            CF_EN <= '1';
            ALU_OP <= "0010";
        elsif (opcode="0001" and last3bits = "110") then --ACC
            if Current_Carry = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0010";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        elsif (opcode="0001" and last3bits = "101") then --ACZ
            if Current_Zero = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0010";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        elsif (opcode="0001" and last3bits = "111") then --ACW
            ZF_EN <= '1';
            CF_EN <= '1';
            ALU_OP <= "0011";
        ---------------
        elsif (opcode="0010" and last3bits = "000") then --NDU
            ZF_EN <= '1';
            CF_EN <= '1';
            ALU_OP <= "0100";
        elsif (opcode="0010" and last3bits = "010") then --NDC
            if Current_Carry = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0100";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        elsif (opcode="0010" and last3bits = "001") then --NDZ
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
        elsif (opcode="0010" and last3bits = "100") then --NCU
            ZF_EN <= '1';
            CF_EN <= '1';
            ALU_OP <= "0101";
        elsif (opcode="0010" and last3bits = "110") then --NCC
            if Current_Carry = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0101";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;
        elsif (opcode="0010" and last3bits = "101") then --NCZ
            if Current_Zero = '1' then
                ZF_EN <= '1';
                CF_EN <= '1';
                ALU_OP <= "0101";
            else
                ZF_EN <= '0';
                CF_EN <= '0';
                ALU_OP <= "1111";
            end if;    
        elsif (opcode="0011") then --LLI
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "1001"; --RETURNS IMM FROM ALUB
        elsif (opcode="0100") then --LW
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "0000";
        elsif (opcode="0101") then --SW
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "0000";
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
        elsif (opcode="1001" ) then --BLT -- and
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
        else
            ZF_EN <= '0';--not null right?
            CF_EN <= '0';
            ALU_OP <= "1111"; 
        end if;
    -- else
    --     null;
    -- end if;

end process;

update_prev_carry: process( clk, New_Carry, New_Zero)
begin
    if(rising_edge(clk)) then
        prev3carry(1 to 2) := prev3carry(0 to 1);
        prev3carry(0) := New_Carry;
        prev3zero(1 to 2) := prev3zero(0 to 1);
        prev3zero(0) := New_Zero;
    else
        null;
    end if;
end process;

 set_controls_stage5: process(IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR)
    variable opcode : std_logic_vector(3 downto 0) := EX_MEM_IR( 15 downto 12);
begin
	opcode := EX_MEM_IR( 15 downto 12);
    -- if rising_edge(clk) then
        MEM_WB_EN <='1';
        -- variable opcode : std_logic_vector(3 downto 0) := EX_MEM_IR( 15 downto 12);

        if (opcode="0101") or (opcode = "0111") then  -- SM, SW
            MEM_WR_EN <= '1';
        else
            MEM_WR_EN <= '0';
        end if;
        
    -- else 
    --     null;
    -- end if; 
end process;


 set_controls_stage6: process(IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR)
    variable opcode : std_logic_vector(3 downto 0) := MEM_WB_IR( 15 downto 12);
begin

		opcode  := MEM_WB_IR( 15 downto 12);
    -- if rising_edge(clk) then
        -- variable opcode : std_logic_vector(3 downto 0) := MEM_WB_IR( 15 downto 12);

        if (opcode="0100") or (opcode = "0110") then  -- LW, LM
            MUX_MEMDOUT_SEL <= '0'; -- MEM_DOUT
        else
            MUX_MEMDOUT_SEL <= '1'; -- ALU_C
        end if;

        -- if (MEM_WB_IR = "1011000000000001") then -- THIS DONE ABOVE
        --     shift_instr_en_lm := '0';
        --     is_lm := "00";
        -- else
        --     null;
        -- end if;

    -- else 
    --     null;
    -- end if; 
end process;

    
end architecture;
 