library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
entity pipeline_controller is
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
end entity;

architecture Struct of pipeline_controller is

shared variable prev3carry : std_logic_vector(0 to 2) := "000";
shared variable prev3zero :std_logic_vector(0 to 2) := "000";
signal is_lm0, is_lm1 : std_logic := '0';
shared variable is_sm0, is_sm1 : std_logic := '0';

begin

set_controls_stage1: process(IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR,Sign_Bit, IS_IMM_ZERO_LM, IS_IMM_ZERO_SM) 
begin

        MEM_WB_CLR<='0';
        EX_MEM_CLR<='0';
        RR_EX_CLR<='0';
        ID_RR_CLR<='0';
        IF_ID_CLR<='0';
        IF_ID_EN <= '1';

        if ((IF_ID_IR( 15 downto 12) = "0110" ) or is_lm0='1' ) then --LM
            IF_ID_CLR<='1';
            is_lm0 <= '1';
            RF_PC_EN <= '0';
        elsif ((IF_ID_IR( 15 downto 12) = "0111" ) or is_sm0='1' ) then --SM
            IF_ID_CLR<='1';
            is_sm0 := '1';
            RF_PC_EN <= '0';
        elsif (MEM_WB_IR = "1011000010110000") then
            is_lm0 <= '0';
        else
            is_lm0 <= '0';
            is_sm0 := '0';
            RF_PC_EN <= '1';        --PC_EN IS ON BY DEFAULT
        end if;

       if (( RR_EX_IR( 15 downto 12) = "1000" or RR_EX_IR( 15 downto 12) = "1001" or RR_EX_IR( 15 downto 12) = "1010" ) and Sign_Bit = '1') or ( RR_EX_IR( 15 downto 12) = "1100") then -- BLT BLE BEQ or JAL
            MUX_PC_SEL <= "01";
            RR_EX_CLR<='1';
            ID_RR_CLR<='1';
            IF_ID_CLR<='1';
			
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
        end if;
        
        if ( RR_EX_IR( 15 downto 12) = "0110" ) and (IS_IMM_ZERO_LM = '1')  then -- LM and IMM is zero
            RR_EX_CLR <= '1'; -- NOP FOR LM
        else
            null;
        end if;

        if ( ID_RR_IR( 15 downto 12) = "0111" ) and (IS_IMM_ZERO_SM = '1')  then -- SM and IMM is zero
            ID_RR_CLR <= '1'; -- NOP FOR SM
            is_sm0 := '0';
        else
            null;
        end if; 
       
end process;

set_controls_stage2: process(IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR)
begin
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
            MUX_SM_SEL <= '0'; -- DEFAULT FOR ALL NON SM SITUATIONS
        end if;     
    
end process;

set_controls_stage3: process(IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR, is_lm1)
    variable opcode  : std_logic_vector(3 downto 0) := MEM_WB_IR( 15 downto 12);
    variable last3bits : std_logic_vector(2 downto 0) :=MEM_WB_IR( 2 downto 0);
begin
	    opcode := MEM_WB_IR( 15 downto 12);
		last3bits := MEM_WB_IR( 2 downto 0);

        if ( ID_RR_IR( 15 downto 12) = "0111" ) then --CHECKING IF SM HAS REACHED RR
            is_sm1 := '1';
        elsif ( ID_RR_IR( 15 downto 12) = "0111" ) and (IS_IMM_ZERO_SM = '1')  then -- SM and IMM is zero 
            is_sm1 := '0';
        else
            null;
        end if;

        if ( is_sm1 = '1' ) then -- ADDRESS FOR STORING GETS UPDATED FROM SM BLOCK 
            MUX_RF_A3_SEL <= '1';
        else
            MUX_RF_A3_SEL <= '0';
        end if;

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
        if(ID_RR_IR( 15 downto 12) = "0100" or ID_RR_IR( 15 downto 12) = "0101") then
            MUX_ALU_A_SEL <="001";
        else
            MUX_ALU_A_SEL <="000";
        end if;

         ------------------------------------------------------------DATA FORWARDING--------------------------------------------------
         ----FOR MUX A
         if ( MEM_WB_IR( 5 downto 3) = ID_RR_IR( 11 downto 9) ) and  ((MEM_WB_IR( 15 downto 12)="0010" or MEM_WB_IR( 15 downto 12)="0001" ) and (MEM_WB_IR(2 downto 0)="000" or MEM_WB_IR(2 downto 0)="111" or MEM_WB_IR(2 downto 0)="011"or MEM_WB_IR(2 downto 0)="100" or ((MEM_WB_IR(2 downto 0)="010" or MEM_WB_IR(2 downto 0)="110") and Current_Carry='1' ) or ((MEM_WB_IR(2 downto 0)="001" or MEM_WB_IR(2 downto 0)="101") and Current_Zero='1' ))) and ((ID_RR_IR( 15 downto 12)="0010" or ID_RR_IR( 15 downto 12)="0001" or ID_RR_IR( 15 downto 12)="0000") and (ID_RR_IR(2 downto 0)="000" or ID_RR_IR(2 downto 0)="111" or ID_RR_IR(2 downto 0)="011"or ID_RR_IR(2 downto 0)="100" or ((ID_RR_IR(2 downto 0)="010" or ID_RR_IR(2 downto 0)="110") and Current_Carry='1' ) or ((ID_RR_IR(2 downto 0)="001" or ID_RR_IR(2 downto 0)="101") and Current_Zero='1' )) )  then 
            MUX_ALU_A_SEL <= "101"; -- WB_Forwarding for ADD, NAND hazard
        elsif (MEM_WB_IR( 8 downto 6) = ID_RR_IR( 11 downto 9)) and MEM_WB_IR( 15 downto 12)="0000" and (ID_RR_IR( 15 downto 12)="0010" or ((ID_RR_IR( 15 downto 12)="0010" or ID_RR_IR( 15 downto 12)="0001" or ID_RR_IR( 15 downto 12)="0000") and (ID_RR_IR(2 downto 0)="000" or ID_RR_IR(2 downto 0)="111" or ID_RR_IR(2 downto 0)="011"or ID_RR_IR(2 downto 0)="100" or ((ID_RR_IR(2 downto 0)="010" or ID_RR_IR(2 downto 0)="110") and Current_Carry='1' ) or ((ID_RR_IR(2 downto 0)="001" or ID_RR_IR(2 downto 0)="101") and Current_Zero='1' )) ))   then
            MUX_ALU_A_SEL <= "101"; -- WB_Forwarding for ADI in I5
        


        elsif ( EX_MEM_IR( 5 downto 3) = ID_RR_IR( 11 downto 9) ) and  ((EX_MEM_IR( 15 downto 12)="0010" or EX_MEM_IR( 15 downto 12)="0001" ) and (EX_MEM_IR(2 downto 0)="000" or EX_MEM_IR(2 downto 0)="111" or EX_MEM_IR(2 downto 0)="011"or EX_MEM_IR(2 downto 0)="100" or ((EX_MEM_IR(2 downto 0)="010" or EX_MEM_IR(2 downto 0)="110") and Current_Carry='1' ) or ((EX_MEM_IR(2 downto 0)="001" or EX_MEM_IR(2 downto 0)="101") and Current_Zero='1' ))) and ((ID_RR_IR( 15 downto 12)="0010" or ID_RR_IR( 15 downto 12)="0001" or ID_RR_IR( 15 downto 12)="0000") and (ID_RR_IR(2 downto 0)="000" or ID_RR_IR(2 downto 0)="111" or ID_RR_IR(2 downto 0)="011"or ID_RR_IR(2 downto 0)="100" or ((ID_RR_IR(2 downto 0)="010" or ID_RR_IR(2 downto 0)="110") and Current_Carry='1' ) or ((ID_RR_IR(2 downto 0)="001" or ID_RR_IR(2 downto 0)="101") and Current_Zero='1' )) )  then 
            MUX_ALU_A_SEL <= "100"; -- ALU1_C_STG5_FORWARDING for ADD, NAND hazard
        elsif (EX_MEM_IR( 8 downto 6) = ID_RR_IR( 11 downto 9)) and EX_MEM_IR( 15 downto 12)="0000" and (ID_RR_IR( 15 downto 12)="0010" or ((ID_RR_IR( 15 downto 12)="0010" or ID_RR_IR( 15 downto 12)="0001" or ID_RR_IR( 15 downto 12)="0000") and (ID_RR_IR(2 downto 0)="000" or ID_RR_IR(2 downto 0)="111" or ID_RR_IR(2 downto 0)="011"or ID_RR_IR(2 downto 0)="100" or ((ID_RR_IR(2 downto 0)="010" or ID_RR_IR(2 downto 0)="110") and Current_Carry='1' ) or ((ID_RR_IR(2 downto 0)="001" or ID_RR_IR(2 downto 0)="101") and Current_Zero='1' )) ))   then
            MUX_ALU_A_SEL <= "100"; -- ALU1_C_STG5_FORWARDING for ADI in I4     


        elsif ( RR_EX_IR( 5 downto 3) = ID_RR_IR( 11 downto 9) ) and  ((RR_EX_IR( 15 downto 12)="0010" or RR_EX_IR( 15 downto 12)="0001" ) and (RR_EX_IR(2 downto 0)="000" or EX_MEM_IR(2 downto 0)="111" or RR_EX_IR(2 downto 0)="011"or RR_EX_IR(2 downto 0)="100" or ((RR_EX_IR(2 downto 0)="010" or RR_EX_IR(2 downto 0)="110") and Current_Carry='1' ) or ((RR_EX_IR(2 downto 0)="001" or RR_EX_IR(2 downto 0)="101") and Current_Zero='1' ))) and ((ID_RR_IR( 15 downto 12)="0010" or ID_RR_IR( 15 downto 12)="0001" or ID_RR_IR( 15 downto 12)="0000") and (ID_RR_IR(2 downto 0)="000" or ID_RR_IR(2 downto 0)="111" or ID_RR_IR(2 downto 0)="011"or ID_RR_IR(2 downto 0)="100" or ((ID_RR_IR(2 downto 0)="010" or ID_RR_IR(2 downto 0)="110") and Current_Carry='1' ) or ((ID_RR_IR(2 downto 0)="001" or ID_RR_IR(2 downto 0)="101") and Current_Zero='1' )) )  then 
            MUX_ALU_A_SEL <= "010"; -- ALU1_C_STG4_FORWARDING for ADD, NAND hazard
        elsif (RR_EX_IR( 8 downto 6) = ID_RR_IR( 11 downto 9)) and RR_EX_IR( 15 downto 12)="0000" and (ID_RR_IR( 15 downto 12)="0010" or ((ID_RR_IR( 15 downto 12)="0010" or ID_RR_IR( 15 downto 12)="0001" or ID_RR_IR( 15 downto 12)="0000") and (ID_RR_IR(2 downto 0)="000" or ID_RR_IR(2 downto 0)="111" or ID_RR_IR(2 downto 0)="011"or ID_RR_IR(2 downto 0)="100" or ((ID_RR_IR(2 downto 0)="010" or ID_RR_IR(2 downto 0)="110") and Current_Carry='1' ) or ((ID_RR_IR(2 downto 0)="001" or ID_RR_IR(2 downto 0)="101") and Current_Zero='1' )) ))   then
            MUX_ALU_A_SEL <= "010"; -- ALU1_C_STG4_FORWARDING for ADI in I3
        
        else 
            null;
        end if;


        

        --FOR MUX B

        if ( MEM_WB_IR( 5 downto 3) = ID_RR_IR( 8 downto 6) ) and  ((MEM_WB_IR( 15 downto 12)="0010" or MEM_WB_IR( 15 downto 12)="0001" ) and (MEM_WB_IR(2 downto 0)="000" or MEM_WB_IR(2 downto 0)="111" or MEM_WB_IR(2 downto 0)="011"or MEM_WB_IR(2 downto 0)="100" or ((MEM_WB_IR(2 downto 0)="010" or MEM_WB_IR(2 downto 0)="110") and Current_Carry='1' ) or ((MEM_WB_IR(2 downto 0)="001" or MEM_WB_IR(2 downto 0)="101") and Current_Zero='1' ))) and ((ID_RR_IR( 15 downto 12)="0010" or ID_RR_IR( 15 downto 12)="0001" or ID_RR_IR( 15 downto 12)="0000") and (ID_RR_IR(2 downto 0)="000" or ID_RR_IR(2 downto 0)="111" or ID_RR_IR(2 downto 0)="011"or ID_RR_IR(2 downto 0)="100" or ((ID_RR_IR(2 downto 0)="010" or ID_RR_IR(2 downto 0)="110") and Current_Carry='1' ) or ((ID_RR_IR(2 downto 0)="001" or ID_RR_IR(2 downto 0)="101") and Current_Zero='1' )) )  then 
            MUX_ALU_B_SEL <= "101"; -- WB_Forwarding for ADD, NAND hazard
        elsif (MEM_WB_IR( 8 downto 6) = ID_RR_IR( 8 downto 6)) and MEM_WB_IR( 15 downto 12)="0000" and (ID_RR_IR( 15 downto 12)="0010" or ((ID_RR_IR( 15 downto 12)="0010" or ID_RR_IR( 15 downto 12)="0001" or ID_RR_IR( 15 downto 12)="0000") and (ID_RR_IR(2 downto 0)="000" or ID_RR_IR(2 downto 0)="111" or ID_RR_IR(2 downto 0)="011"or ID_RR_IR(2 downto 0)="100" or ((ID_RR_IR(2 downto 0)="010" or ID_RR_IR(2 downto 0)="110") and Current_Carry='1' ) or ((ID_RR_IR(2 downto 0)="001" or ID_RR_IR(2 downto 0)="101") and Current_Zero='1' )) ))   then
            MUX_ALU_B_SEL <= "101"; -- WB_Forwarding for ADI in I5

            elsif ( EX_MEM_IR( 5 downto 3) = ID_RR_IR( 8 downto 6) ) and  ((EX_MEM_IR( 15 downto 12)="0010" or EX_MEM_IR( 15 downto 12)="0001" ) and (EX_MEM_IR(2 downto 0)="000" or EX_MEM_IR(2 downto 0)="111" or EX_MEM_IR(2 downto 0)="011"or EX_MEM_IR(2 downto 0)="100" or ((EX_MEM_IR(2 downto 0)="010" or EX_MEM_IR(2 downto 0)="110") and Current_Carry='1' ) or ((EX_MEM_IR(2 downto 0)="001" or EX_MEM_IR(2 downto 0)="101") and Current_Zero='1' ))) and ((ID_RR_IR( 15 downto 12)="0010" or ID_RR_IR( 15 downto 12)="0001" or ID_RR_IR( 15 downto 12)="0000") and (ID_RR_IR(2 downto 0)="000" or ID_RR_IR(2 downto 0)="111" or ID_RR_IR(2 downto 0)="011"or ID_RR_IR(2 downto 0)="100" or ((ID_RR_IR(2 downto 0)="010" or ID_RR_IR(2 downto 0)="110") and Current_Carry='1' ) or ((ID_RR_IR(2 downto 0)="001" or ID_RR_IR(2 downto 0)="101") and Current_Zero='1' )) )  then 
            MUX_ALU_B_SEL <= "100"; -- ALU1_C_STG5_FORWARDING for ADD, NAND hazard
        elsif (EX_MEM_IR( 8 downto 6) = ID_RR_IR( 8 downto 6)) and EX_MEM_IR( 15 downto 12)="0000" and (ID_RR_IR( 15 downto 12)="0010" or ((ID_RR_IR( 15 downto 12)="0010" or ID_RR_IR( 15 downto 12)="0001" or ID_RR_IR( 15 downto 12)="0000") and (ID_RR_IR(2 downto 0)="000" or ID_RR_IR(2 downto 0)="111" or ID_RR_IR(2 downto 0)="011"or ID_RR_IR(2 downto 0)="100" or ((ID_RR_IR(2 downto 0)="010" or ID_RR_IR(2 downto 0)="110") and Current_Carry='1' ) or ((ID_RR_IR(2 downto 0)="001" or ID_RR_IR(2 downto 0)="101") and Current_Zero='1' )) ))   then
            MUX_ALU_B_SEL <= "100"; -- ALU1_C_STG5_FORWARDING for ADI in I4  


            elsif ( RR_EX_IR( 5 downto 3) = ID_RR_IR( 8 downto 6) ) and  ((RR_EX_IR( 15 downto 12)="0010" or RR_EX_IR( 15 downto 12)="0001" ) and (RR_EX_IR(2 downto 0)="000" or EX_MEM_IR(2 downto 0)="111" or RR_EX_IR(2 downto 0)="011"or RR_EX_IR(2 downto 0)="100" or ((RR_EX_IR(2 downto 0)="010" or RR_EX_IR(2 downto 0)="110") and Current_Carry='1' ) or ((RR_EX_IR(2 downto 0)="001" or RR_EX_IR(2 downto 0)="101") and Current_Zero='1' ))) and ((ID_RR_IR( 15 downto 12)="0010" or ID_RR_IR( 15 downto 12)="0001" or ID_RR_IR( 15 downto 12)="0000") and (ID_RR_IR(2 downto 0)="000" or ID_RR_IR(2 downto 0)="111" or ID_RR_IR(2 downto 0)="011"or ID_RR_IR(2 downto 0)="100" or ((ID_RR_IR(2 downto 0)="010" or ID_RR_IR(2 downto 0)="110") and Current_Carry='1' ) or ((ID_RR_IR(2 downto 0)="001" or ID_RR_IR(2 downto 0)="101") and Current_Zero='1' )) )  then 
            MUX_ALU_B_SEL <= "010"; -- ALU1_C_STG4_FORWARDING for ADD, NAND hazard
        elsif (RR_EX_IR( 8 downto 6) = ID_RR_IR( 8 downto 6)) and RR_EX_IR( 15 downto 12)="0000" and (ID_RR_IR( 15 downto 12)="0010" or ((ID_RR_IR( 15 downto 12)="0010" or ID_RR_IR( 15 downto 12)="0001" or ID_RR_IR( 15 downto 12)="0000") and (ID_RR_IR(2 downto 0)="000" or ID_RR_IR(2 downto 0)="111" or ID_RR_IR(2 downto 0)="011"or ID_RR_IR(2 downto 0)="100" or ((ID_RR_IR(2 downto 0)="010" or ID_RR_IR(2 downto 0)="110") and Current_Carry='1' ) or ((ID_RR_IR(2 downto 0)="001" or ID_RR_IR(2 downto 0)="101") and Current_Zero='1' )) ))   then
            MUX_ALU_B_SEL <= "010"; -- ALU1_C_STG4_FORWARDING for ADI in I3
        
        else
            null;
        end if;

         ----------------------------------------------------------------xnxx-------------------------------------------------------------


        if (is_lm1 = '1') then -- Then LM has reached EX
            MUX_LM_SEL <= '1';
            RR_EX_EN <= '0';
        else
            MUX_LM_SEL <= '0';
            RR_EX_EN <= '1';
        end if;

end process;

set_controls_stage4: process(IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR, Current_Carry, Current_Zero)
variable opcode : std_logic_vector(3 downto 0) := RR_EX_IR( 15 downto 12);
variable last3bits  : std_logic_vector(2 downto 0):=RR_EX_IR( 2 downto 0);
begin

		opcode := RR_EX_IR( 15 downto 12);
		last3bits:=RR_EX_IR( 2 downto 0);

        EX_MEM_EN <= '1';

        if ( RR_EX_IR( 15 downto 12) = "0110" ) then --LM REACHES EX
            is_lm1 <= '1';
        else
            null;
        end if;

        if (MEM_WB_IR = "1011000010110000") then  
            is_lm1 <= '0';
        else 
            null;
        end if;
    
        if (is_lm1 = '1') then -- AFTER LM REACHES EX
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
            ALU_OP <= "1110";
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
            ZF_EN <= '0';
            CF_EN <= '0';
            ALU_OP <= "1111"; 
        end if;

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
    MEM_WB_EN <='1';

    if (opcode="0101") or (opcode = "0111") then  -- SM, SW
        MEM_WR_EN <= '1';
    else
        MEM_WR_EN <= '0';
    end if;
        
end process;


set_controls_stage6: process(IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR)
variable opcode : std_logic_vector(3 downto 0) := MEM_WB_IR( 15 downto 12);
begin

	opcode  := MEM_WB_IR( 15 downto 12);
    if (opcode="0100") or (opcode = "0110") then  -- LW, LM
        MUX_MEMDOUT_SEL <= '0'; -- MEM_DOUT
    else
        MUX_MEMDOUT_SEL <= '1'; -- ALU_C
    end if;

end process;
   
end architecture;
 