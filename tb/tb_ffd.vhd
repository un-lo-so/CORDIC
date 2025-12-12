library IEEE;

use IEEE.std_logic_1164.all;

--test bench for D flip flo

entity TB is
end TB;		

architecture behavioral of TB is
	component ffd is 
	port (	  
		clk : in std_ulogic;		--clock, rising edge 
		reset : in std_ulogic;		--reset, async, active high
		d	: in std_ulogic;		--input
		q	: out std_ulogic		--output
	);
	end component ffd;			   
	
	signal clk : std_ulogic := '0';
	signal reset : std_ulogic := '1';
	signal d : std_ulogic := '0';	
	signal q : std_ulogic := '0';	  
	
begin	
	DUT : ffd port map (clk,reset,d,q);
		
	proc0: process	 	--processo that drive reset signal
		begin
			wait for 5 ns;
			reset <= not reset;	
			wait for 7 ns;
			reset <= not reset;	
			wait for 3 ns;
			reset <= not reset;	
			wait;
		end process;  
		
	proc1: process		--processo that drive clock signal
	begin 		
		wait for 10 ns;
		clk <= not clk; 
	end process;   
	
	proc2: process	 	--processo that drive data in
	begin
		wait for 5 ns;
		d <= '1';	
		wait for 20 ns;
		d <= '0';
		wait for 20 ns;
		d <= '1';
		wait;
	end process;	 
end behavioral;