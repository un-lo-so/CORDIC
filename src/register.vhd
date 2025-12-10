library IEEE;

use IEEE.std_logic_1164.all;

--N bit register for loading data

entity reg is
	generic (NBit : positive := 4);		--default value of register is 4 bit width
	port (
		ing : in std_ulogic_vector (Nbit-1 downto 0);	--input word
		usc : out std_ulogic_vector (Nbit-1 downto 0);	--output word
		clk : in std_ulogic;			--clock 	   
		reset : in std_ulogic			--asynchronous reset active high		  
	);
end reg;

architecture rtl of reg is				  
	--flip flop D is a building block 
	component ffd is 
	port (	  
			clk : in std_ulogic;		--clock, rising edge 
			reset : in std_ulogic;		--reset, async, active high
			d	: in std_ulogic;		--input
			q	: out std_ulogic		--output
		);
	end component ffd;
		
begin		  
	--automatic generation of register
	gen: for i in NBit-1 downto 0 generate
		SR : ffd port map (clk,reset,ing(i),usc(i));	
	end generate;	
end rtl;