library IEEE;

use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all;

--test bench fort testing CORDIC A

entity tb_cordicA is
end tb_cordicA;

architecture behavioral of tb_cordicA is
	component CORDIC_A is	
	port (	   
		clk : in std_ulogic;							--clock
		x	: in std_ulogic_vector (13 downto 0);		--X 
		y	: in std_ulogic_vector (13 downto 0);		--Y
		reset : in std_ulogic;							--asynchronous reset active high
		i	: in std_ulogic_vector(3 downto 0);			--bus for driving barrel shift registers
		load_ext	: in std_ulogic;					--pin for loading new data
		output		: in std_ulogic;					--pin for present the result in output
		modulo : out std_ulogic_vector (15 downto 0);	--the output contain the modulus of complex number
		d_out	: out std_ulogic						--sign output, used in the calculus of phase
	);	
	end component CORDIC_A;		   
	
	signal clk : std_ulogic := '0';
	signal reset : std_ulogic := '1';  
	signal x : std_ulogic_vector (13 downto 0);
	signal y : std_ulogic_vector (13 downto 0);	
	signal aux : std_ulogic_vector (3 downto 0);
	signal load : std_ulogic := '1';
	signal output : std_ulogic := '0';
	
begin
	DUT : CORDIC_A port map (clk,x,y,reset,aux,load,output,open); 
	
	proc1: process			--process that drive clock signal
	begin		
		wait for 10 ns;
		clk <= not clk;
	end process;   		
	
	proc0: process			--process that drive the load configuration bit
	begin  
		wait for 10 ns;
		load<='0';
		wait for 320 ns;
		load<='1';
		wait for 10 ns;
	end process;	 
	
	proc4: process			--process that drive the output configuration bit
	begin
		wait for 630 ns;
		output <='1'; 
		wait for 20ns;
		output <= '0';
	end process;
		
	-- weight of LSB is 2^-7	
	y <="00000110000000";	--3 in C2
	x <="00000110000000";	--3 in C2
	
	proc2: process			--process that drive barrel reset signal
	begin				   
		wait for 10 ns;
		reset <= not reset;
		wait;
	end process;		  
	
	proc3:	 process		--process that drive barrel shifter bus
	variable i: natural;
	begin	
		i:=0;
		aux <= std_ulogic_vector(TO_UNSIGNED(i,4));
		wait for 30 ns;
		while i < 16 loop
			i := i + 1;
			aux <= std_ulogic_vector(TO_UNSIGNED(i,4));	 
			wait for 20 ns;	 			
		end loop;					
	end process;
							 				   
end behavioral;		 

