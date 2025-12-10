library IEEE;
use IEEE.std_logic_1164.all;								
--simple flip flop

entity ffd is 
	port (	  
		clk : in std_ulogic;		--clock, rising edge 
		reset : in std_ulogic;		--reset, async, active high
		d	: in std_ulogic;		--input
		q	: out std_ulogic		--output
	);
end ffd;	   

architecture behavioral of ffd is
begin
	ffd_proc: process (reset, clk)
	begin
		if reset = '1' then 					--asynchronous reset 
			q <='0';							
		elsif rising_edge(clk) then 	 		--flip flop is rising edge triggered
			q <= d;	
		end if; 				
	end process ffd_proc;
end behavioral;