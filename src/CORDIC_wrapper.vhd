library IEEE;

use IEEE.std_logic_1164.all;	 

-- wrapper for CORDIC. It transform X and Y to translate they in the positive half plane 

entity CORDIC_wrapper is
	port (
		clk : in std_ulogic;							--clock
		x	: in std_ulogic_vector (13 downto 0);		--X
		y	: in std_ulogic_vector (13 downto 0);		--Y    
		modulo : out std_ulogic_vector (15 downto 0);	--output modulus
		fase : out std_ulogic_vector (15 downto 0);	 	--phase		
		output : out std_ulogic;						--notify new output
		new_data	: in std_ulogic						--Notify the presence of new data in input
	);
end entity;

architecture RTL of CORDIC_wrapper is
	--building blocks
	--CORDIC
	component CORDIC is
		port (
			clk : in std_ulogic;							--clock
			x	: in std_ulogic_vector (13 downto 0);		--X
			y	: in std_ulogic_vector (13 downto 0);		--Y  
			sgn_x	: in std_ulogic;						--sign of X
			new_data	: in std_ulogic;					--Notify the presence of new data in input
			modulo : out std_ulogic_vector (15 downto 0);	--output for modulus 
			fase : out std_ulogic_vector (15 downto 0);	 	--output for phase
			output : out std_ulogic							--notify new output
	);
	end component CORDIC;	  
	
	component add_sub_gen is
	generic (NBit : positive := 4);						--default value of adder\subtractor is 4 bit
	port (
		a : in std_ulogic_vector (Nbit-1 downto 0);		--N bit operand
		b : in std_ulogic_vector (Nbit-1 downto 0);		--N bit operand
		s : out std_ulogic_vector (Nbit-1 downto 0);	--N bit sum
		cout : out std_ulogic;							--carry out
		add_sub : in std_ulogic							--configuration bit: 
														--1 = subtract
														--0 = add
	);	
	end component add_sub_gen;	 
	
	--output of ripple carry adder\subtractors
	signal x_wrapped : std_ulogic_vector (13 downto 0);		 
	signal y_wrapped : std_ulogic_vector (13 downto 0);		 
	
	--sign of X
	signal sgn_x : std_ulogic;
		
begin		   				
	sgn_x <= x(13);	--the sign of X is acquired
	--according to sign of X, X and Y are added or subtracted to 0 in order to refer the complex
	--number to the positive half plane				   	
	Sx_wrap : add_sub_gen generic map (14) port map ("00000000000000",x,x_wrapped,open,sgn_x);
	Sy_wrap : add_sub_gen generic map (14) port map ("00000000000000",y,y_wrapped,open,sgn_x);
		
	C	: CORDIC port map (clk,x_wrapped,y_wrapped,sgn_x,new_data,modulo,fase,output);
end RTL;
