library IEEE;

use IEEE.std_logic_1164.all;

-- test bench to control the waveform of output MSF 

entity TB_msf is
end TB_msf;

architecture behavioral of TB_msf is  	
	component msf is 
	port (
		clk : in std_ulogic;							--clock
		reset : out std_ulogic;							--asynchronous reset active high
		nshift  : out std_ulogic_vector (3 downto 0);	--bus for driving shift registers
														--bus for driving LUT of CORDIC B
		load_ext : out std_ulogic;	  					--control signal to load new data 
		output : out std_ulogic							--control signal to update outputs
	);			
	end component msf;
						 	
	signal clk : std_ulogic := '0';	
	signal preset : std_ulogic := '1';	
	signal reset : std_ulogic := '1';
	
begin							   					   
	DUT : msf port map (clk,open,open,open,open);
	
	proc1 : process
	begin
		wait for 10 ns;
		clk <= not clk;
	end process;
	
	proc2 : process
	begin		
		wait for 10 ns;		
		preset <= not preset;			
		wait;
	end process;
	
end behavioral;