library ieee;
use ieee.std_logic_1164.all;
entity DUT is
   port(input_vector: in std_logic_vector(0 downto 0);
       	output_vector: out std_logic_vector(130 downto 0));
end entity;

architecture DutWrap of DUT is
   component CPU is
	port(clk : in std_logic;
	output_dummy: out std_logic;
	Reg0,Reg1,Reg2,Reg3,Reg4,Reg5,Reg6,Reg7: out std_logic_vector(15 downto 0);
	Current_Zero_OUT, Current_Carry_OUT: out std_logic
	);
	end component;

begin
   add_instance: CPU
		port map(
			clk => input_vector(0),
			output_dummy => output_vector(130),
			Reg0=> output_vector(129 downto 114),
			Reg1=> output_vector(113 downto 98),
			Reg2=> output_vector(97 downto 82),
			Reg3=> output_vector(81 downto 66),
			Reg4=> output_vector(65 downto 50),
			Reg5=> output_vector(49 downto 34),
			Reg6=> output_vector(33 downto 18),
			Reg7=> output_vector(17 downto 2),
			Current_Zero_OUT => output_vector(1),
			Current_Carry_OUT => output_vector(0)
		);

end DutWrap;