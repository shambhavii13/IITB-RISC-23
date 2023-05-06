library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity CPU is
    port(clk : in std_logic;
		output_dummy: out std_logic);
end CPU;

architecture main of CPU is

	component Dataflow is
		port(
        ZF_EN, CF_EN, RF_D3_EN, RF_PC_EN, SH_EN,IF_ID_EN,ID_RR_EN,RR_EX_EN,EX_MEM_EN,MEM_WB_EN,MEM_WR_EN: in std_logic;
        MUX_SM_SEL,MUX_LM_SEL,MUX_SE_SEL, MUX_RF_D3_SEL, MUX_MEMDOUT_SEL,MUX_DEST2_SEL,MUX_RF_A3_SEL: in std_logic;
        MUX_PC_SEL, MUX_DEST_SEL: in std_logic_vector(1 downto 0);
        MUX_ALU_B_SEL,MUX_ALU_A_SEL :  in std_logic_vector(2 downto 0);
        ALU_OP : in std_logic_vector(3 downto 0);
        CLK : in std_logic;
        IF_ID_CLR,ID_RR_CLR,RR_EX_CLR,EX_MEM_CLR,MEM_WB_CLR : in std_logic;


        Current_Zero_OUT, Current_Carry_OUT, Sign_Bit : out std_logic;
        New_Zero_OUT, New_Carry_OUT, IS_IMM_ZERO_LM, IS_IMM_ZERO_SM: out std_logic;
        IF_ID_IR,ID_RR_IR,RR_EX_IR,EX_MEM_IR,MEM_WB_IR : out std_logic_vector(15 downto 0)
    );
	end component;
	
	component pipeline_controller  is
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
	end component;
	
signal current_carry_s,current_zero_s, new_zero_s,new_carry_s,Sign_Bit_s, IS_IMM_ZERO_LM_s, IS_IMM_ZERO_SM_s : std_logic;
signal ZF_EN_s, CF_EN_s, RF_D3_EN_s, RF_PC_EN_s, SH_EN_s, IF_ID_EN_s, ID_RR_EN_s, RR_EX_EN_s, EX_MEM_EN_s, MEM_WB_EN_s ,MEM_WR_EN_s: std_logic;
signal MUX_SE_SEL_s, MUX_RF_D3_SEL_s, MUX_MEMDOUT_SEL_s, MUX_LM_SEL_s,MUX_SM_SEL_s, MUX_DEST2_SEL_s, MUX_RF_A3_SEL_s : std_logic;
signal IF_ID_IR_s,ID_RR_IR_s,RR_EX_IR_s,EX_MEM_IR_s,MEM_WB_IR_s  : std_logic_vector(15 downto 0);
signal IF_ID_CLR_s,ID_RR_CLR_s,RR_EX_CLR_s,EX_MEM_CLR_s,MEM_WB_CLR_s: std_logic;
signal MUX_PC_SEL_s, MUX_DEST_SEL_s: std_logic_vector(1 downto 0);
signal MUX_ALU_B_SEL_s, MUX_ALU_A_SEL_s: std_logic_vector(2 downto 0);
signal ALU_OP_s:  std_logic_vector(3 downto 0);
	
begin


--Controller
Ctrl: pipeline_controller port map ( 
	CLK => clk,
	Current_Zero => current_zero_s,
	Current_Carry => current_carry_s,
	New_Carry => new_carry_s,
	New_Zero => new_zero_s,
	
	Sign_Bit=>Sign_Bit_s,
	IS_IMM_ZERO_LM=>IS_IMM_ZERO_LM_s,
	IS_IMM_ZERO_SM=>IS_IMM_ZERO_SM_s,
	ZF_EN=>ZF_EN_s,
	 CF_EN=>CF_EN_s,
	 RF_D3_EN=>RF_D3_EN_s,
	 RF_PC_EN=>RF_PC_EN_s,
	 SH_EN=>SH_EN_s,
	 IF_ID_EN=>IF_ID_EN_s,
	 ID_RR_EN=>ID_RR_EN_s,
	 RR_EX_EN=>RR_EX_EN_s,
	 EX_MEM_EN=>EX_MEM_EN_s,
	 MEM_WB_EN =>MEM_WB_EN_s,
	 IF_ID_CLR=>IF_ID_CLR_s,
	 ID_RR_CLR=>ID_RR_CLR_s,
	 RR_EX_CLR=>RR_EX_CLR_s,
	 EX_MEM_CLR=>EX_MEM_CLR_s,
	 MEM_WB_CLR =>MEM_WB_CLR_s,
	 IF_ID_IR=>IF_ID_IR_s,
	 ID_RR_IR=>ID_RR_IR_s,
	 RR_EX_IR=>RR_EX_IR_s,
	 EX_MEM_IR=>EX_MEM_IR_s,
	 MEM_WB_IR =>MEM_WB_IR_s,
	MEM_WR_EN=>MEM_WR_EN_s,
	MUX_SE_SEL=>MUX_SE_SEL_s,
	 MUX_RF_D3_SEL=>MUX_RF_D3_SEL_s,
	
	 MUX_MEMDOUT_SEL=>MUX_MEMDOUT_SEL_s,
	 MUX_LM_SEL => MUX_LM_SEL_s,
	 MUX_SM_SEL=>MUX_SM_SEL_s,
	 MUX_DEST2_SEL=>MUX_DEST2_SEL_s,
	 MUX_RF_A3_SEL=>MUX_RF_A3_SEL_s,
	 MUX_PC_SEL=>MUX_PC_SEL_s,
	  MUX_DEST_SEL=>MUX_DEST_SEL_s,
	  MUX_ALU_B_SEL=>MUX_ALU_B_SEL_s,
	   MUX_ALU_A_SEL=>MUX_ALU_A_SEL_s,
	   ALU_OP=>ALU_OP_s

					);

--Datapath
DP: Dataflow port map (
	CLK => clk,
	Current_Zero_OUT => current_zero_s,
	Current_Carry_OUT => current_carry_s,
	New_Carry_OUT => new_carry_s,
	New_Zero_OUT => new_zero_s,
	Sign_Bit=>Sign_Bit_s,
	IS_IMM_ZERO_LM=>IS_IMM_ZERO_LM_s,
	IS_IMM_ZERO_SM=>IS_IMM_ZERO_SM_s,
	ZF_EN=>ZF_EN_s,
	 CF_EN=>CF_EN_s,
	 RF_D3_EN=>RF_D3_EN_s,
	 RF_PC_EN=>RF_PC_EN_s,
	 SH_EN=>SH_EN_s,
	 IF_ID_EN=>IF_ID_EN_s,
	 ID_RR_EN=>ID_RR_EN_s,
	 RR_EX_EN=>RR_EX_EN_s,
	 EX_MEM_EN=>EX_MEM_EN_s,
	 MEM_WB_EN =>MEM_WB_EN_s,
	 IF_ID_CLR=>IF_ID_CLR_s,
	 ID_RR_CLR=>ID_RR_CLR_s,
	 RR_EX_CLR=>RR_EX_CLR_s,
	 EX_MEM_CLR=>EX_MEM_CLR_s,
	 MEM_WB_CLR =>MEM_WB_CLR_s,
	 IF_ID_IR=>IF_ID_IR_s,
	 ID_RR_IR=>ID_RR_IR_s,
	 RR_EX_IR=>RR_EX_IR_s,
	 EX_MEM_IR=>EX_MEM_IR_s,
	 MEM_WB_IR =>MEM_WB_IR_s,
	MEM_WR_EN=>MEM_WR_EN_s,
	MUX_SE_SEL=>MUX_SE_SEL_s,
	 MUX_RF_D3_SEL=>MUX_RF_D3_SEL_s,
	
	 MUX_MEMDOUT_SEL=>MUX_MEMDOUT_SEL_s,
	 MUX_LM_SEL => MUX_LM_SEL_s,
	 MUX_SM_SEL=>MUX_SM_SEL_s,
	 MUX_DEST2_SEL=>MUX_DEST2_SEL_s,
	 MUX_RF_A3_SEL=>MUX_RF_A3_SEL_s,
	 MUX_PC_SEL=>MUX_PC_SEL_s,
	  MUX_DEST_SEL=>MUX_DEST_SEL_s,
	  MUX_ALU_B_SEL=>MUX_ALU_B_SEL_s,
	   MUX_ALU_A_SEL=>MUX_ALU_A_SEL_s,
	   ALU_OP=>ALU_OP_s
);
							output_dummy<='1';
end main;