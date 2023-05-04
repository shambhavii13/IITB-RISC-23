library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

enTITy Dataflow is
    port(
        ZF_EN, CF_EN, RF_D3_EN, RF_PC_EN, SH_EN,IF_ID_EN,ID_RR_EN,RR_EX_EN,EX_MEM_EN,MEM_WB_EN,MEM_WR_EN: in std_logic;
        MUX_SM_SEL,MUX_LM_SEL,MUX_SE_SEL, MUX_RF_D3_SEL, MUX_MEMDOUT_SEL,MUX_DEST2_SEL,MUX_RF_A3_SEL: in std_logic;
        MUX_PC_SEL, MUX_DEST_SEL,MUX_ALU_A_SEL: in std_logic_vector(1 downto 0);
        MUX_ALU_B_SEL :  in std_logic_vector(2 downto 0);
        ALU_OP : in std_logic_vector(3 downto 0);
        CLK : in std_logic;
        Current_Zero_OUT, Current_Carry_OUT : out std_logic;
        New_Zero_OUT, New_Carry_OUT, IS_IMM_ZERO_LM: out std_logic;
        IR_OUT : out std_logic_vector(15 downto 0)
    );
end enTITy Dataflow;

architecture Dataflow_Arch of Dataflow is

    component Instr_Mem is
        port(
            clk: in std_logic;
            address: in std_logic_vector(15 downto 0);
            IM_Data: out std_logic_vector(15 downto 0)
        );
    end component;

    component ALU23 is
        port (
            input1: in std_logic_vector(15 downto 0);
            input2: in std_logic_vector(15 downto 0);
            ALU_out: out std_logic_vector(15 downto 0)
        );
    end component;


    component MUX_4_to_1 is
        port(
            A0: in std_logic_vector(2 downto 0);
            A1: in std_logic_vector(2 downto 0);
            A2: in std_logic_vector(2 downto 0);
            A3: in std_logic_vector(2 downto 0);
            S: in std_logic_vector(1 downto 0);
            Op: out std_logic_vector(2 downto 0)
        );
    end component;

------------------------------------------------------------------------------------------------------------------------
    component IF_ID is
        port(
            clk,IF_ID_EN: in std_logic;	
            PC_IN: in std_logic_vector(15 downto 0);
            PC_2_IN: in std_logic_vector(15 downto 0);
			IM_DATA_IN: in std_logic_vector(15 downto 0);
            RA_ADD: out std_logic_vector(2 downto 0);
			RB_ADD: out std_logic_vector(2 downto 0);
			RC_ADD: out std_logic_vector(2 downto 0);
			IMM_6 : out std_logic_vector(5 downto 0);
			IMM_9 : out std_logic_vector(8 downto 0);
            PC_OUT: out std_logic_vector(15 downto 0);
            PC_2_OUT: out std_logic_vector(15 downto 0);
            IM_DATA_OUT: out std_logic_vector(15 downto 0)		
        );
    end component;

    component ID_RR is
        port(
            clk,ID_RR_EN: in std_logic;
            RB_ADD_IN: in std_logic_vector(2 downto 0);
			RC_ADD_IN: in std_logic_vector(2 downto 0);
            RA_ADD_IN: in std_logic_vector(2 downto 0);

            PC_IN : in std_logic_vector(15 downto 0);
            PC_2_IN : in std_logic_vector(15 downto 0);
            PC_2xIMM_IN : in std_logic_vector(15 downto 0);

			IMM_SE: in std_logic_vector(15 downto 0);
            
            RA_ADD_OUT: out std_logic_vector(2 downto 0);
			RB_ADD_OUT: out std_logic_vector(2 downto 0);
			RC_ADD_OUT: out std_logic_vector(2 downto 0);

            PC_OUT: out std_logic_vector(15 downto 0);
            PC_2xIMM_OUT: out std_logic_vector(15 downto 0);
            PC_2_OUT: out std_logic_vector(15 downto 0);
            SE_2xIMM: out std_logic_vector(15 downto 0)	
        );
    end component;

    component RR_EX is
        port(
            clk,RR_EX_EN : in std_logic;
            DEST_IN : in std_logic_vector(2 downto 0);
            RA_IN : in std_logic_vector(15 downto 0);
            RB_IN : in std_logic_vector(15 downto 0);

            SE_IMM_IN : in std_logic_vector(15 downto 0);
            PC_2xIMM_IN : in std_logic_vector(15 downto 0);
            PC_2_IN : in std_logic_vector(15 downto 0);

            DEST_OUT : out std_logic_vector(2 downto 0);
            RA_OUT : out std_logic_vector(15 downto 0);
            RB_OUT : out std_logic_vector(15 downto 0);

            SE_IMM_OUT : out std_logic_vector(15 downto 0);
            PC_2xIMM_OUT : out std_logic_vector(15 downto 0);
            PC_2_OUT : out std_logic_vector(15 downto 0)
        );
    end component;

    component EX_MEM is
        port(              
            clk ,EX_MEM_EN: in std_logic;
            DEST_IN : in std_logic_vector(2 downto 0);
            RB_IN : in std_logic_vector(15 downto 0);

            ALU_C_IN : in std_logic_vector(15 downto 0);
            PC_2_IN : in std_logic_vector(15 downto 0);

            DEST_OUT : out std_logic_vector(2 downto 0);
            RB_OUT : out std_logic_vector(15 downto 0);
            ALU_C_OUT : out std_logic_vector(15 downto 0);

            PC_2_OUT : out std_logic_vector(15 downto 0)
        );
    end component;

    component MEM_WB is
        port(
            clk,MEM_WB_EN: in std_logic;
            DEST_IN : in std_logic_vector(2 downto 0);
            ALU_C_IN : in std_logic_vector(15 downto 0);
            D_OUT_IN : in std_logic_vector(15 downto 0);
            PC_2_IN : in std_logic_vector(15 downto 0);

            PC_2_OUT : out std_logic_vector(15 downto 0);
            D_OUT_OUT : out std_logic_vector(15 downto 0);
            ALU_C_OUT : out std_logic_vector(15 downto 0);
            DEST_OUT : out std_logic_vector(2 downto 0)
        );
    end component;
--------------------------------------------------------------------------------------------------------------------------

    component sign_ext_6 is
        port(SE_IN : in std_logic_vector (5 downto 0);
            SE_OUT : out std_logic_vector ( 15 downto 0)
        );
    end component;

    component sign_ext_9 is
        port(SE_IN : in std_logic_vector (5 downto 0);
            SE_OUT : out std_logic_vector ( 15 downto 0)
        );
    end component;

    component MUX_2_to_1 is
        port(
            A0: in std_logic_vector(15 downto 0);
            A1: in std_logic_vector(15 downto 0);
            S: in std_logic;
            Op: out std_logic_vector(15 downto 0)
        );
    end component;


	component shifter_multiplybytwo is
		port(
			shift_in : in std_logic_vector(15 downto 0);
			shift_out : out std_logic_vector(15 downto 0);
			SH_EN : in std_logic
		);	 
	end component;

--------------------------------------------------------------------------------------------------------------------------
    component MUX_3_to_1 is
        port(
            A0,A1,A2: in std_logic_vector(2 downto 0);
            
            S: in std_logic_vector(1 downto 0);
            Op: out std_logic_vector(2 downto 0)
        );
    end component;
    
    component LMSM is
        port(
            IMM_IN : in std_logic_vector(15 downto 0);
        PENC_OP : out std_logic_vector(2 downto 0); 
        IMM_OP : out std_logic_vector(15 downto 0);
        IS_IMM_ZERO : out std_logic
        );
    end component;

    component Register_File is
        port(
            RF_A1: in std_logic_vector(2 downto 0);
            RF_A2: in std_logic_vector(2 downto 0);
            RF_A3: in std_logic_vector(2 downto 0);
            RF_D1: out std_logic_vector(15 downto 0);
            RF_D2: out std_logic_vector(15 downto 0);
            RF_D3: in std_logic_vector(15 downto 0);
            RF_PC_R: out std_logic_vector(15 downto 0);
            RF_PC_W: in std_logic_vector(15 downto 0);
            RF_D3_EN,PC_EN: in std_logic; clk : in std_logic		
        );
    end component;

    COMPONENT MUX_5_to_1 is
        port(
            A0,A1,A2,A3,A4: in std_logic_vector(15 downto 0);
            
            S: in std_logic_vector(2 downto 0);
            Op: out std_logic_vector(15 downto 0)
        );
    end component;
-------------------------------------------------------------------------------------------------------------------------

    component ALU is
        port(ALU_A , ALU_B : in std_logic_vector(15 downto 0); ALU_OP : in std_logic_vector(3 downto 0); ALU_C : out std_logic_vector(15 downto 0); 
            ALU_Z, ALU_C1 : in std_logic; ALU_Carry, ALU_Zero : out std_logic);
    end component;  
    
    component Register_1 is
        port (
            DIN : in std_logic;
            DOUT : out std_logic;
            CLK, WE : in std_logic
        );
    end component;

---------------------------------------------------------------------------------------------------------------------------------
    
    component Data_Mem is
        port(
            clk: in std_logic;
            Mem_add, Din: in std_logic_vector(15 downto 0);
            Dout: out std_logic_vector(15 downto 0)
        );
    end component;

------------------------------------------------------------------------------------------------------------------------------------

    signal STG1_PC, STG1_IM_DATA, STG1_PC2, STG1_MUX_OUT : std_logic_vector(15 downto 0);
	signal STG2_PC, STG2_PC2, STG2_RA_ADD, STG2_RB_ADD, STG2_RC_ADD, STG2_IMM_6, STG2_IMM_9, STG2_IR, STG2_SE_IMM_6, STG2_SE_IMM_9,
        STG2_SE_IMM, STG2_SE_IMM_2,STG2_SE_IMM_3, STG2_PC_2xIMM : std_logic_vector(15 downto 0);
    
    signal STG3_PC, STG3_PC_2, STG3_RA_ADD, STG3_RB_ADD, STG3_RC_ADD, STG3_PC_2xIMM, STG3_SE_IMM_2,STG3_SM_IMM,STG3_SE_IMM_3
        ,STG3_RA, STG3_RB,STG3_ALU_A ,STG3_ALU1_B: std_logic_vector(15 downto 0);
    signal STG3_PENC : std_logic_vector(2 downto 0);
    signal STG4_PC_2, STG4_PC_2xIMM, STG4_ALU1_B, STG4_ALU1_C, STG4_RB, STG4_SE_IMM_2,STG4_ALU_A,STG4_LM_IMM : std_logic_vector(15 downto 0);
    signal STG4_PENC,STG4_DEST_2 : std_logic_vector(2 downto 0);
    signal STG5_PC_2, STG5_RA, STG5_RB, STG5_ALU1_C, STG5_DOUT : std_logic_vector(15 downto 0);
    signal STG6_PC_2, STG6_MUX_OP, STG6_DOUT, STG6_ALU1_C : std_logic_vector(15 downto 0);
    signal STG3_DEST, STG6_DEST, STG4_DEST, STG5_DEST : std_logic_vector(2 downto 0);
    signal RF_D3_INP : std_logic_vector(15 downto 0);
    signal Current_Zero, Current_Carry, New_Carry, New_Zero : std_logic;
        

begin

    -- Instruction Memory
    IM : Instr_Mem port map(
        clk => CLK,
        IM_Data => STG1_IM_DATA,
        address => STG1_PC
    );
	 
    -- ALU2
    ALU2 : ALU23 port map(
        input1 => STG1_PC,
        input2 => "0000000000000010",
        ALU_out => STG1_PC2
    );
	 
	-- MUX_4_to_1
    MUX41 : MUX_4_to_1 port map(
        A0 => STG1_PC2,
        A1 => STG4_PC_2xIMM,
--        A2 =>  STG4_RB,  
        A2 => STG_RB3,-- for JLR 
        A3 => STG4_ALU1_C,
        S => MUX_PC_SEL,
        Op => STG1_MUX_OUT
    );
		  
	-- IF-ID
	IFxID: IF_ID port map (
        clk => CLK,
        IF_ID_EN => IF_ID_EN,
        PC_IN => STG1_PC,
        PC_2_IN => STG1_PC2,
        IM_DATA_IN => STG1_IM_DATA,
        RA_ADD => STG2_RA_ADD,
        RB_ADD => STG2_RB_ADD,
        RC_ADD => STG2_RC_ADD,
        IMM_6  => STG2_IMM_6,
        IMM_9  => STG2_IMM_9,
        PC_OUT => STG2_PC,
        PC_2_OUT => STG2_PC2,
        IM_DATA_OUT => STG2_IR	
    );
           
	--SE6
    SE6: sign_ext_6 port map(
	    SE_IN => STG2_IMM_6,
        SE_OUT => STG2_SE_IMM_6
    );
		  
	--SE9
    SE9: sign_ext_9 port map(
	    SE_IN => STG2_IMM_9,
        SE_OUT => STG2_SE_IMM_9
    );
	  
    --SE_MUX
    SE_MUX: MUX_2_to_1 port map(
        A0 => STG2_SE_IMM_6,
        A1 => STG2_SE_IMM_9,
        S => MUX_SE_SEL,
        Op => STG2_SE_IMM
    );

    -- Shifter
    SHIFTER: shifter_multiplybytwo port map(
        shift_in => STG2_SE_IMM,
        shift_out => STG2_SE_IMM_2,
        SH_EN => SH_EN
    );
    
    --SM_MUX
    SM_MUX: MUX_2_to_1 port map(
        A0 => STG2_SE_IMM_2,
        A1 => STG3_SM_IMM,
        S => MUX_SM_SEL,
        Op => STG2_SE_IMM_3
    );



    -- ALU3
    ALU3 : ALU23 port map(
        input1 => STG2_SE_IMM_2 ,
        input2 => STG2_PC,
        ALU_out => STG2_PC_2xIMM
    );
    
    --ID-RR
    IDxRR : ID_RR port map(
        clk => CLK,
        ID_RR_EN => ID_RR_EN,
        RB_ADD_IN => STG2_RB_ADD,
        RC_ADD_IN => STG2_RC_ADD,
        RA_ADD_IN => STG2_RA_ADD,

        PC_IN  => STG2_PC,
        PC_2_IN  => STG2_PC2,
        PC_2xIMM_IN  => STG2_PC_2xIMM,

        IMM_SE => STG2_SE_IMM_3,
        
        RA_ADD_OUT => STG3_RA_ADD,
        RB_ADD_OUT => STG3_RB_ADD,
        RC_ADD_OUT => STG3_RC_ADD,

        PC_OUT => STG3_PC,
        PC_2xIMM_OUT => STG3_PC_2xIMM,
        PC_2_OUT => STG3_PC_2,
        SE_2xIMM => STG3_SE_IMM_2	
    );
	
    -- LMSM
    LMSM_1 : LMSM port map(
        IMM_IN =>STG3_SE_IMM_2 ,
        PENC_OP =>STG3_PENC ,
        IMM_OP =>STG3_SM_IMM,
        IS_IMM_ZERO => IS_IMM_ZERO_SM
    );

    --DEST_MUX
    DEST_MUX : MUX_3_to_1 port map(
        A0 => STG3_RA_ADD,
        A1 => STG3_RB_ADD,
        A2 => STG3_RB_ADD,
        S  => MUX_DEST_SEL,
        Op => STG3_DEST
        );
        
    -- Register File
    RF : Register_File port map(
        RF_A1 => STG3_RA_ADD,
        RF_A2 => STG3_RB_ADD,
        RF_A3 => RF_A3_OUT,
        RF_D1 => STG3_RA,
        RF_D2 => STG3_RB,
        RF_D3 => RF_D3_INP,
        RF_PC_R => STG1_PC,
        RF_PC_W => STG1_MUX_OUT,
        RF_D3_EN => RF_D3_EN,
        PC_EN => RF_PC_EN,
        clk => CLK
    );

    --RF_A3_MUX
    RF_A3_MUX: MUX_2_to_1 port map(
        A0 => STG6_DEST,
        A1 => STG3_PENC,
        S => MUX_RF_A3_SEL,
        Op => RF_A3_OUT
    );
    --ALU_A_MUX
    ALU_A_MUX : MUX_4_to_1 port map(
        A0 => STG3_RA,
        A1 => STG4_ALU1_C,
        A2 => STG5_DOUT,
        A3 => STG6_MUX_OP,
        S  => MUX_ALU_A_SEL,
        Op => STG3_ALU_A
    );
    
    --LM_MUX
    LM_MUX: MUX_2_to_1 port map(
        A0 => STG3_SE_IMM_2,
        A1 => STG4_LM_IMM,
        S => MUX_LM_SEL,
        Op => STG3_SE_IMM_3
    );

    -- ALU1_B_MUX
    ALU_B_MUX : MUX_5_to_1 port map(
        A0 => STG3_RB,
        A1 => STG3_SE_IMM_3,
        A2 => STG4_ALU1_C,
        A3 => STG5_DOUT,
        A4 => STG6_MUX_OP,
        S => MUX_ALU_B_SEL,
        Op => STG3_ALU1_B
    );
    -- RR_EX
    RRxEX : RR_EX port map(
        clk => CLK,
        RR_EX_EN =>RR_EX_EN,
        DEST_IN => STG3_DEST,
        RA_IN => STG3_ALU_A,
        RB_IN => STG3_RB,

        SE_IMM_IN => STG3_ALU1_B ,
        PC_2xIMM_IN => STG3_PC_2xIMM,
        PC_2_IN => STG3_PC_2,

        DEST_OUT => STG4_DEST,
        RA_OUT => STG4_ALU_A,
        RB_OUT => STG4_RB,

        SE_IMM_OUT =>  STG4_ALU1_B,
        PC_2xIMM_OUT => STG4_PC_2xIMM,
        PC_2_OUT => STG4_PC_2
    );

    --DEST2_MUX
    DEST_2_MUX: MUX_2_to_1 port map(
        A0 =>  STG4_DEST,
        A1 => STG4_PENC,
        S => MUX_DEST2_SEL,
        Op => STG4_DEST_2
    );

    -- C FLAG
    C_FLAG : Register_1 port map (
        DIN => New_Carry, --
        DOUT => Current_Carry, --
        CLK => CLK,
        WE => CF_EN
    );

    -- Z FLAG
    Z_FLAG : Register_1 port map (
        DIN => New_Zero, --
        DOUT => Current_Zero, --
        CLK => CLK,
        WE => ZF_EN
    );        
    
    -- ALU
    ALU1 : ALU port map(
        ALU_A => STG4_ALU_A,
        ALU_B => STG4_ALU1_B,
        ALU_OP => ALU_OP,
        ALU_C => STG4_ALU1_C,
        ALU_Z => Current_Zero, --
        ALU_C1 => Current_Carry, --
        ALU_Carry => New_Carry, 
        ALU_Zero => New_Zero 
    );

    -- LMSM
    LMSM_2 : LMSM port map(
        IMM_IN => STG4_ALU1_B ,
        PENC_OP =>STG4_PENC ,
        IMM_OP =>STG4_LM_IMM,
        IS_IMM_ZERO => IS_IMM_ZERO_LM
    );


    --EX-MEM
    EXxMEM : EX_MEM port map(
        clk => CLK,
        EX_MEM_EN =>EX_MEM_EN,
        DEST_IN => STG4_DEST_2,
        RB_IN => STG4_RB,

        ALU_C_IN => STG4_ALU1_C,
        PC_2_IN => STG4_PC_2,

        DEST_OUT => STG5_DEST,
        RB_OUT => STG5_RB,
        ALU_C_OUT => STG5_ALU1_C,

        PC_2_OUT => STG5_PC_2
    );

    --DATA MEMORY
    Data_Memory : Data_Mem port map(
        clk => CLK,
        Enable => MEM_WR_EN,
        Mem_add => STG5_ALU1_C,
        Din => STG5_RB,
        Dout => STG5_DOUT
    );

    -- MEM-WB
    MEMxWB : MEM_WB port map(
        clk => CLK,
        MEM_WB_EN =>MEM_WB_EN,
        DEST_IN => STG5_DEST,
        ALU_C_IN => STG5_ALU1_C,
        D_OUT_IN => STG5_DOUT, 
        PC_2_IN => STG5_PC_2,

        PC_2_OUT => STG6_PC_2, 
        D_OUT_OUT => STG6_DOUT, 
        ALU_C_OUT => STG6_ALU1_C, 
        DEST_OUT => STG6_DEST 
    );

    -- WB_MUX
    WBxMUX : MUX_2_to_1 port map(
        A0 => STG6_DOUT,
        A1 => STG6_ALU1_C,
        S => MUX_MEMDOUT_SEL,
        Op => STG6_MUX_OP
    );

    -- RF_D3_MUX
    RF_D3_MUX : MUX_2_to_1 port map(
        A0 => STG6_MUX_OP,
        A1 => STG6_PC_2,
        S => RF_D3_EN,
        Op => RF_D3_INP
    );
	 
    Current_Zero_OUT <= Current_Zero;
    Current_Carry_OUT <= Current_Carry;
    New_Zero_OUT <= New_Zero;
    New_Carry_OUT <= New_Carry;
    Sign_Bit <= STG4_ALU1_C(0);

end Dataflow_Arch;