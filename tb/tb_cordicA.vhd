library IEEE;

use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all;

entity tb_cordicA is
end tb_cordicA;

architecture behavioral of tb_cordicA is
	component CORDIC_A is
	port (	   
		clk : in std_ulogic;							--clock
		x	: in std_ulogic_vector (13 downto 0);		--X 
		y	: in std_ulogic_vector (13 downto 0);		--Y
		reset : in std_ulogic;							--asynchronous reset active high
		load_ext	: in std_ulogic;					--pin for loading new data
		store_or_shift : in	std_ulogic;					--driving shift registers
		output		: in std_ulogic;					--pin for present the result in output
		modulo : out std_ulogic_vector (15 downto 0);	--the output contain the modulus of complex number
		d_out	: out std_ulogic						--sign output, used in the calculus of phase
	);	
	end component CORDIC_A;		   
	
	signal clk : std_ulogic := '0';
	signal reset : std_ulogic := '1';  
	signal x : std_ulogic_vector (13 downto 0);
	signal y : std_ulogic_vector (13 downto 0);	
	signal sos: std_ulogic;
	signal output : std_ulogic := '1';
	signal aux : std_ulogic_vector (3 downto 0);
	signal load : std_ulogic := '1';
	
	
begin
	DUT : CORDIC_A port map (clk,x,y,reset,load,sos,output,open,open); 
	
	proc0: process			--Process that drive clock
	begin		
		wait for 10 ns;
		clk <= not clk;
	end process;   		
	
	y <="00000110000000";
	x <="00000110000000";
	
	proc1: process			--Process that drive reset signal
	begin				   
		wait for 10 ns;
		reset <= not reset;
		wait;
	end process;		  

	proc3: process			--process thath drive load signal
	begin  
		wait for 10 ns;
		load<='0';
		wait for 320 ns;
		load<='1';
		wait for 10 ns;
	end process;	 
	
	proc4: process			--process thath drive the store or load configuration bit\signal
	begin  
		wait for 10 ns;
		sos<='0';
		wait for 320 ns;
		sos<='1';
		wait for 10 ns;
	end process;	 
	
	proc5: process			--process that drive the output configuration bit\signal
	begin
		wait for 630 ns;
		output <='1'; 
		wait for 20 ns;
		output <= '0';
	end process;
								 				   
end behavioral;		 

