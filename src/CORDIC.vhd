library IEEE;

use IEEE.std_logic_1164.all;

-- CORDIC entity that instantiate all the building blocks (CORDIC A, CORDIC B and MSF)
-- input are on 14 bit C2, output are unsigned on 16 bit

entity CORDIC is
	port (
		clk : in std_ulogic;							--clock
		x	: in std_ulogic_vector (13 downto 0);		--X
		y	: in std_ulogic_vector (13 downto 0);		--Y  
		sgn_x	: in std_ulogic;						--sign of X
		modulo : out std_ulogic_vector (15 downto 0);	--output for modulus  
		fase : out std_ulogic_vector (15 downto 0);	 	--output for phase
		output : out std_ulogic							--notify of new output
	);
end entity;		  

architecture rtl of CORDIC is							
	--building block declaration
	
	--component that calculate the modulus
	component CORDIC_A is	
	port (		   
		clk : in std_ulogic;							--clock
		x	: in std_ulogic_vector (13 downto 0);		--X 
		y	: in std_ulogic_vector (13 downto 0);		--Y
		reset : in std_ulogic;							--asynchronous reset active higho
		load_ext	: in std_ulogic;					--pin for loading new data
		store_or_shift : in	std_ulogic;					--driving shift registers
		output		: in std_ulogic;					--pin for present the result in output
		modulo : out std_ulogic_vector (15 downto 0);	--the output contain the modulus of complex number
		d_out	: out std_ulogic						--sign output, used in the calculus of phase
	);	
	end component CORDIC_A;		   
	
	--MSF for driving other components
	component msf is 
	port (	
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
	
	--component that calculate the phase
	component CORDIC_B is	
	port(
		sgn_x	: in std_ulogic;						--bit of sign of x, it allow to establish in which half-plane is
														--the complex number and apply an offset
		clk : in std_ulogic;							--clock
		reset : in std_ulogic;							--asynchronous reset 
		addr : in std_ulogic_vector (3 downto 0);		--address bus for  LUT
		load_ext : in std_ulogic;						--pin for loading new data
		sum_or_store : in std_ulogic;					--configuration bit:
														--1 holding data
														--0 acquire new data
		d : in std_ulogic;								--bit for sign - from CORDIC A,it drive the ripple carry adder\subractor
		fase : out std_ulogic_vector (15 downto 0);		--bus for the output
		output : in std_ulogic							--pin for present the result in output
	);                                             		--pin for present the result in output
	end component CORDIC_B;
	
	component ffd is 
	port (	  
		clk : in std_ulogic;		--clock, rising edge 
		reset : in std_ulogic;		--reset, async, active high
		d	: in std_ulogic;		--input
		q	: out std_ulogic		--output
	);
	end component ffd;	
	
	--internal control signals 
	signal reset_int : std_ulogic; 						
	signal store_or_shift_int : std_ulogic; 			
	signal load_ext_int	: std_ulogic; 					
	signal d_int : std_ulogic;							
	signal output_int : std_ulogic;						
	signal bus_int : std_ulogic_vector (3 downto 0);	
	
	signal sum_atan_int	: std_ulogic;
begin 	
	A : CORDIC_A port map (clk,x,y,reset_int,load_ext_int,store_or_shift_int,output_int,modulo,d_int);
	controllore : msf port map (clk,reset_int,bus_int,load_ext_int,store_or_shift_int,output_int); 	
	B : CORDIC_B port map (sgn_x,clk,reset_int,bus_int,load_ext_int,store_or_shift_int,d_int,fase,output_int);

	output_delay: ffd port map(clk,reset_int,output_int,output);
end rtl;