

--MUX A                 mux signals needs to be given

if ( Instructions(5, 5 downto 3) = Instructions(2, 11 downto 9) ) and  (Instructions(5, 15 downto 12)="0010" or Instructions(5, 15 downto 12)="0001" ) and (Instructions(2, 15 downto 12)="0010" or Instructions(2, 15 downto 12)="0001" or Instructions(2, 15 downto 12)="0000" ) then 
            MUX_ALU_A_SEL <= "100"; -- WB_Forwarding for ADD, NAND hazard
        elsif (Instructions(5, 8 downto 6) = Instructions(2, 11 downto 9)) and Instructions(5, 15 downto 12)="0000"  (Instructions(2, 15 downto 12)="0010" or Instructions(2, 15 downto 12)="0001" or Instructions(2, 15 downto 12)="0000" ) then
            MUX_ALU_A_SEL <= "100"; -- WB_Forwarding for ADI in I5 
        


        elsif ( Instructions(4, 5 downto 3) = Instructions(2, 11 downto 9) ) and  (Instructions(4, 15 downto 12)="0010" or Instructions(4, 15 downto 12)="0001" ) and (Instructions(2, 15 downto 12)="0010" or Instructions(2, 15 downto 12)="0001" or Instructions(2, 15 downto 12)="0000" ) then 
            MUX_ALU_A_SEL <= "100"; -- ALU1_C_STG5_FORWARDING for ADD, NAND hazard
        elsif (Instructions(4, 8 downto 6) = Instructions(2, 11 downto 9)) and Instructions(4, 15 downto 12)="0000"  (Instructions(2, 15 downto 12)="0010" or Instructions(2, 15 downto 12)="0001" or Instructions(2, 15 downto 12)="0000" ) then
            MUX_ALU_A_SEL <= "100"; -- ALU1_C_STG5_FORWARDING for ADI in I4



        elsif ( Instructions(3, 5 downto 3) = Instructions(2, 11 downto 9) ) and  (Instructions(3, 15 downto 12)="0010" or Instructions(3, 15 downto 12)="0001" ) and (Instructions(2, 15 downto 12)="0010" or Instructions(2, 15 downto 12)="0001" or Instructions(2, 15 downto 12)="0000" ) then 
            MUX_ALU_A_SEL <= "100"; -- ALU1_C_STG4_FORWARDING for ADD, NAND hazard
        elsif (Instructions(3, 8 downto 6) = Instructions(2, 11 downto 9)) and Instructions(3, 15 downto 12)="0000"  (Instructions(2, 15 downto 12)="0010" or Instructions(2, 15 downto 12)="0001" or Instructions(2, 15 downto 12)="0000" ) then
            MUX_ALU_A_SEL <= "100"; -- ALU1_C_STG4_FORWARDING for ADI in I3
        
        
        elsif () -- for LOAD
        
        
        elsif Instructions(2,15 downto 12)="0100" or Instructions(2,15 downto 12)="0101" then  -- write condition for use of RB
            MUX_ALU_A_SEL <= "100"; -- mux for RB
        else 
            MUX_ALU_A_SEL <= "00"; -- RA as it is
        end if;





--- MUX B        mux signals needs to be given
        if  ( Instructions(5, 5 downto 3) = Instructions(2, 8 downto 6) ) and  (Instructions(5, 15 downto 12)="0010" or Instructions(5, 15 downto 12)="0001" ) and (Instructions(2, 15 downto 12)="0010" or Instructions(2, 15 downto 12)="0001" ) then 
        MUX_ALU_B_SEL <= "100"; -- WB_Forwarding for ADD, NAND hazard
        elsif (Instructions(5, 8 downto 6) = Instructions(2, 8 downto 6)) and Instructions(5, 15 downto 12)="0000"  (Instructions(2, 15 downto 12)="0010" or Instructions(2, 15 downto 12)="0001"  ) then
            MUX_ALU_B_SEL <= "100"; -- WB_Forwarding for ADI in I5 



        elsif  ( Instructions(4, 5 downto 3) = Instructions(2, 8 downto 6) ) and  (Instructions(4, 15 downto 12)="0010" or Instructions(4, 15 downto 12)="0001" ) and (Instructions(2, 15 downto 12)="0010" or Instructions(2, 15 downto 12)="0001" ) then 
            MUX_ALU_B_SEL <= "100"; -- ALU1_C_STG5_FORWARDING for ADD, NAND hazard
        elsif (Instructions(4, 8 downto 6) = Instructions(2, 8 downto 6)) and Instructions(4, 15 downto 12)="0000"  (Instructions(2, 15 downto 12)="0010" or Instructions(2, 15 downto 12)="0001"  ) then
            MUX_ALU_B_SEL <= "100"; -- ALU1_C_STG5_FORWARDING for ADI in I5 



        elsif  (Instructions(3, 5 downto 3) = Instructions(2, 8 downto 6)) and  (Instructions(3, 15 downto 12)="0010" or Instructions(3, 15 downto 12)="0001" ) and (Instructions(2, 15 downto 12)="0010" or Instructions(2, 15 downto 12)="0001" ) then 
            MUX_ALU_B_SEL <= "100"; -- ALU1_C_STG4_FORWARDING for ADD, NAND hazard
        elsif (Instructions(3, 8 downto 6) = Instructions(2, 8 downto 6)) and Instructions(3, 15 downto 12)="0000"  (Instructions(2, 15 downto 12)="0010" or Instructions(2, 15 downto 12)="0001"  ) then
            MUX_ALU_B_SEL <= "100"; -- ALU1_C_STG4_FORWARDING for ADI in I5 
        
        
        elsif (Instructions(3, 5 downto 3)=Instructions(2,8 downto 6)) and (Instructions(3,15 downto 12)="0001" or Instructions(3,15 downto 12)="0010" ) and Instructions(2,15 downto 12)="0100" then
            MUX_ALU_B_SEL <= ; -- 


        elsif () -- for LOAD


        elsif () -- for choosing 
            MUX_ALU_B_SEL <="" ; -- 


        else
            MUX_ALU_B_SEL <="";
        end if;


        -------------------------------------------------------------------xxx-----------------------------------------------------------------------------------------

        