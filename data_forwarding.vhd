

--MUX A                 mux signals needs to be given

data_forwarding : process(CLK)

if ( Instruction_5( 5 downto 3) = Instruction_2( 11 downto 9) ) and  (Instruction_5( 15 downto 12)="0010" or Instruction_5( 15 downto 12)="0001" ) and (Instruction_2( 15 downto 12)="0010" or Instruction_2( 15 downto 12)="0001" or Instruction_2( 15 downto 12)="0000" ) then 
            MUX_ALU_A_SEL <= "100"; -- WB_Forwarding for ADD, NAND hazard
        elsif (Instruction_5( 8 downto 6) = Instruction_2( 11 downto 9)) and Instruction_5( 15 downto 12)="0000"  (Instruction_2( 15 downto 12)="0010" or Instruction_2( 15 downto 12)="0001" or Instruction_2( 15 downto 12)="0000" ) then
            MUX_ALU_A_SEL <= "100"; -- WB_Forwarding for ADI in I5 
        


        elsif ( Instruction_4( 5 downto 3) = Instruction_2( 11 downto 9) ) and  (Instruction_4( 15 downto 12)="0010" or Instruction_4( 15 downto 12)="0001" ) and (Instruction_2( 15 downto 12)="0010" or Instruction_2( 15 downto 12)="0001" or Instruction_2( 15 downto 12)="0000" ) then 
            MUX_ALU_A_SEL <= "100"; -- ALU1_C_STG5_FORWARDING for ADD, NAND hazard
        elsif (Instruction_4( 8 downto 6) = Instruction_2( 11 downto 9)) and Instruction_4( 15 downto 12)="0000"  (Instruction_2( 15 downto 12)="0010" or Instruction_2( 15 downto 12)="0001" or Instruction_2( 15 downto 12)="0000" ) then
            MUX_ALU_A_SEL <= "100"; -- ALU1_C_STG5_FORWARDING for ADI in I4



        elsif ( Instruction_3( 5 downto 3) = Instruction_2( 11 downto 9) ) and  (Instruction_3( 15 downto 12)="0010" or Instruction_3( 15 downto 12)="0001" ) and (Instruction_2( 15 downto 12)="0010" or Instruction_2( 15 downto 12)="0001" or Instruction_2( 15 downto 12)="0000" ) then 
            MUX_ALU_A_SEL <= "100"; -- ALU1_C_STG4_FORWARDING for ADD, NAND hazard
        elsif (Instruction_3( 8 downto 6) = Instruction_2( 11 downto 9)) and Instruction_3( 15 downto 12)="0000"  (Instruction_2( 15 downto 12)="0010" or Instruction_2( 15 downto 12)="0001" or Instruction_2( 15 downto 12)="0000" ) then
            MUX_ALU_A_SEL <= "100"; -- ALU1_C_STG4_FORWARDING for ADI in I3
        
        
        elsif () -- for LOAD
        
        
        elsif Instruction_2(15 downto 12)="0100" or Instruction_2(15 downto 12)="0101" then  -- write condition for use of RB
            MUX_ALU_A_SEL <= "100"; -- mux for RB
        else 
            MUX_ALU_A_SEL <= "00"; -- RA as it is
        end if;





--- MUX B        mux signals needs to be given
        if  ( Instruction_5( 5 downto 3) = Instruction_2( 8 downto 6) ) and  (Instruction_5( 15 downto 12)="0010" or Instruction_5( 15 downto 12)="0001" ) and (Instruction_2( 15 downto 12)="0010" or Instruction_2( 15 downto 12)="0001" ) then 
        MUX_ALU_B_SEL <= "100"; -- WB_Forwarding for ADD, NAND hazard
        elsif (Instruction_5( 8 downto 6) = Instruction_2( 8 downto 6)) and Instruction_5( 15 downto 12)="0000"  (Instruction_2( 15 downto 12)="0010" or Instruction_2( 15 downto 12)="0001"  ) then
            MUX_ALU_B_SEL <= "100"; -- WB_Forwarding for ADI in I5 



        elsif  ( Instruction_4( 5 downto 3) = Instruction_2( 8 downto 6) ) and  (Instruction_4( 15 downto 12)="0010" or Instruction_4( 15 downto 12)="0001" ) and (Instruction_2( 15 downto 12)="0010" or Instruction_2( 15 downto 12)="0001" ) then 
            MUX_ALU_B_SEL <= "100"; -- ALU1_C_STG5_FORWARDING for ADD, NAND hazard
        elsif (Instruction_4( 8 downto 6) = Instruction_2( 8 downto 6)) and Instruction_4( 15 downto 12)="0000"  (Instruction_2( 15 downto 12)="0010" or Instruction_2( 15 downto 12)="0001"  ) then
            MUX_ALU_B_SEL <= "100"; -- ALU1_C_STG5_FORWARDING for ADI in I5 



        elsif  (Instruction_3( 5 downto 3) = Instruction_2( 8 downto 6)) and  (Instruction_3( 15 downto 12)="0010" or Instruction_3( 15 downto 12)="0001" ) and (Instruction_2( 15 downto 12)="0010" or Instruction_2( 15 downto 12)="0001" ) then 
            MUX_ALU_B_SEL <= "100"; -- ALU1_C_STG4_FORWARDING for ADD, NAND hazard
        elsif (Instruction_3( 8 downto 6) = Instruction_2( 8 downto 6)) and Instruction_3( 15 downto 12)="0000"  (Instruction_2( 15 downto 12)="0010" or Instruction_2( 15 downto 12)="0001"  ) then
            MUX_ALU_B_SEL <= "100"; -- ALU1_C_STG4_FORWARDING for ADI in I5 
        
        
        elsif (Instruction_3( 5 downto 3)=Instruction_2(8 downto 6)) and (Instruction_3(15 downto 12)="0001" or Instruction_3(15 downto 12)="0010" ) and Instruction_2(15 downto 12)="0100" then
            MUX_ALU_B_SEL <= ; -- 


        elsif () -- for LOAD


        elsif () -- for choosing 
            MUX_ALU_B_SEL <="" ; -- 


        else
            MUX_ALU_B_SEL <="";
        end if;
    end process;

        -------------------------------------------------------------------xxx-----------------------------------------------------------------------------------------

        