library IEEE;

use IEEE.std_logic_1164.all;								  

-- Part of CORDIC that calculate the phase of complex number	
-- output is between 0 and 2pi radiants, unsigned, on 16 bit

entity CORDIC_B is	
	port(
		sgn_x	: in std_ulogic;								--bit of sign of x, it allow to establish in which half-plane is
																--the complex number and apply an offset
		clk : in std_ulogic;									--clock
		reset : in std_ulogic;									--asynchronous reset 
		addr : in std_ulogic_vector (3 downto 0);				--address bus for  LUT
		load_ext : in std_ulogic;								--pin for loading new data
		sum_or_store : in std_ulogic;							--configuration bit:
																--1 holding data
																--0 acquire new data
		d : in std_ulogic;										--bit for sign - from CORDIC A,it drive the ripple carry adder\subractor
		fase : out std_ulogic_vector (15 downto 0);				--bus for the output
		output : in std_ulogic									--pin for present the result in output
	);	  
end CORDIC_B;

architecture struct of CORDIC_B is
	--building blocks
	--LUT that stores the atan values
	component LUT_16x16 is
	port(
		addr	: in std_ulogic_vector(3 downto 0);			--address
		data	: out std_ulogic_vector (15 downto 0)		--data out
	); 
	end component LUT_16x16;  
	
	--ripple carry adder\subtractor
	component add_sub_gen is
	generic (NBit : positive := 4);							--default value of adder\subtractor is 4 bit	
	port (
		a : in std_ulogic_vector (Nbit-1 downto 0);			--N bit operand
		b : in std_ulogic_vector (Nbit-1 downto 0);			--N bit operand
		s : out std_ulogic_vector (Nbit-1 downto 0);		--N bit sum
		cout : out std_ulogic;								--carry out
		add_sub : in std_ulogic								--configuration bit: 
															--1 = subtract
															--0 = add
	);		
	end component add_sub_gen;
	
	--n bit register
	component reg is
	generic (NBit : positive := 4);			--default value of register is 4 bit width
	port (
		ing : in std_ulogic_vector (Nbit-1 downto 0);	--input word
		usc : out std_ulogic_vector (Nbit-1 downto 0);	--output word
		clk : in std_ulogic;							--clock	   
		reset : in std_ulogic							--asynchronous reset active high		  
	);
	end component reg;
	
	--auxiliary internal signals - see relation (page 4)
	signal lut_out	: std_ulogic_vector(15 downto 0);	--output of LUT
	signal sum_out	: std_ulogic_vector(15 downto 0); 	--output of ripple carry adder\subtractor
	signal temp 	: std_ulogic_vector(15 downto 0);  	--temporary signal (first operand of ripple carry adder\subtractor) 
	
	signal ing		: std_ulogic_vector(15 downto 0);	--2 way mux (16 bit) controlled by load_ext input port:
														--0 act as a feedback: the output of ripple carry adder subtractor
														--  will be presented as input
														--1 foreing data will be presented as input 
	
	signal mux_out	: std_ulogic_vector(15 downto 0);  	--2 way mux  (16 bit) controlled by output input port:
	
	
	
	
	
	
	--feedback networks
	signal feedback1	: std_ulogic_vector(15 downto 0);	--internal feedback to allow the input register to hold
															--data or load foreign data
	signal feedback2	: std_ulogic_vector(15 downto 0);	--signal that act as feedback (to hold current data) or provide new data in output 


	
begin	
	LUT : LUT_16x16 port map (addr,lut_out);									  
	S :		add_sub_gen generic map (16) port map (temp,lut_out,sum_out,open,d);  			
	
	--load input data or present the output data as input
	--If the X is negative, input data must be pi (100000000000000) otherwise 0 (000000000000000) thus, the simple way to achieve this it's
	--sufficient that the MSB of input word is the sign bit of X
	ing <= sgn_x&"000000000000000" when load_ext = '1' else sum_out;	
	
	

	
	--feedback1 allow to load input data or feedback the output data in input (hold configuration)
	feedback1 <= temp when sum_or_store = '1' else ing;
	r	:	reg generic map (16) port map (feedback1,temp,clk,reset);
	
	
	
	
	--The input of the output register is driven by a 2 way mux (16 bit) this allow to store data
	--in the register or load the value from the output of ripple carry adder\subtractor (and present
	--it at the next clock cycle)
	mux_out <= sum_out when output = '1' else feedback2;
	---the output register
	mem3	: reg generic map (16) port map (mux_out,feedback2,clk,reset);
	fase <= feedback2;			--the output port of CORDIC B is driven by the output of register    
end struct;