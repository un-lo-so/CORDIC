library IEEE;

use IEEE.std_logic_1164.all;

entity TB_msf is
end TB_msf;

architecture behavioral of TB_msf is
	component msf is 
	port(
		clk : in std_ulogic;							--clock
		reset : out std_ulogic;							--asynchronous reset
		nshift  : out std_ulogic_vector (3 downto 0);	--bus for driving LUT of CORDIC B module		
		load_ext : out std_ulogic;	  					--signal for loading external data
		sum_or_shift : out	std_ulogic;					--signal for driving CORDIC A
														--0 = add\subtract of operands
														--1 = shift of operands				
		output : out std_ulogic							--control signal for update the outputs of CORDIC
	);			
	end component msf;
	
	
	signal clk : std_ulogic := '0';	
	
begin							   					   
	DUT : msf port map (clk,open,open,open,open,open);
	
	proc1 : process
	begin
		wait for 10 ns;
		clk <= not clk;
	end process;
	
end behavioral;