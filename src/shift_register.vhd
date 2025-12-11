library IEEE;

use IEEE.std_logic_1164.all;

--PISO (Parallel Input Serial Output) register

entity shift_reg is
	generic (NBit : positive := 4);
	port (	 
		ing		: in std_ulogic_vector (Nbit-1 downto 0);	 	--input bus for data (parallel)
		usc		: out std_ulogic_vector (Nbit-1 downto 0);		--output bus for data (parallel)
		clk		: in std_ulogic;								--clock
		reset	: in std_ulogic;								--pin for asynchronous reset of register\flip flops
		shift	: in std_ulogic									--configuration pin:
																--0 load data
																--1 Arithmetic right shift
	);
end shift_reg;

architecture rtl of shift_reg is   
	--
	component ffd is 
		port (	  
		clk : in std_ulogic;		--clock, rising edge 
		reset : in std_ulogic;		--reset, async, active high
		d	: in std_ulogic;		--input
		q	: out std_ulogic		--output
	);	
	end component ffd;	 
	
	--segnali ausiliari
	signal ing_temp : std_ulogic_vector (Nbit-1 downto 0);
	signal usc_temp : std_ulogic_vector (Nbit-1 downto 0);
	
begin								 
	GEN:	for i in Nbit-1 downto 0 generate	--generate the "daisy-chain" of flip flop D
				FF : ffd port map (clk,reset,ing_temp(i),usc_temp(i));
				
				--mapping input and output
				FIRST:	if i = Nbit-1 generate						
					--last flip-flop (MSB) store the value (arithmetic right shift) or load data 
					ing_temp(i) <= ing(i) when shift = '0' else usc_temp(i);  
				 	end generate;
				MIDDLE: if i < Nbit-1 generate			
					--the middle flip flop the input is a foreign data or the output of nearest
					--flip flop
					ing_temp(i) <= ing(i) when shift = '0' else usc_temp(i+1);			 	
					end generate;
		end generate;
	usc <= usc_temp;	--the output of each flip flop is the output of register
end rtl;