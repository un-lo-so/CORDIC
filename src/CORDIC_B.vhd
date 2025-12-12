library IEEE;

use IEEE.std_logic_1164.all;

-- Part of CORDIC that calculate the phase of complex number	
-- output is between 0 and 2pi radiants, unsigned, on 16 bit

entity CORDIC_B is	
	port(
		sgn_x	: in std_ulogic;					--bit of sign of x, it allow to establish in which half-plane is
													--the complex number and apply an offset
		clk : in std_ulogic;						--clock
		reset : in std_ulogic;						--asynchronous reset 
		addr : in std_ulogic_vector (3 downto 0);	--address bus for  LUT
		load_ext : in std_ulogic;					--pin for loading new data
		d : in std_ulogic;							--bit for sign - from CORDIC A, it drive the ripple carry adder\subtractor
		fase : out std_ulogic_vector (15 downto 0);	--bus for the output
		output : in std_ulogic						--pin for present the result in output
	);	  
end CORDIC_B;

architecture rtl of CORDIC_B is
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
	generic (NBit : positive := 4);		--default value of register is 4 bit width
	port (
		ing : in std_ulogic_vector (Nbit-1 downto 0);	--input word
		usc : out std_ulogic_vector (Nbit-1 downto 0);	--output word
		clk : in std_ulogic;							--clock	   
		reset : in std_ulogic							--asynchronous reset active high
	);
	end component reg;
	
	--auxiliary internal signals - see report (page 4)
	signal lut_out	: std_ulogic_vector (15 downto 0);
	signal sum_out	: std_ulogic_vector (15 downto 0); 
	signal temp 	: std_ulogic_vector (15 downto 0); 
	signal ing		: std_ulogic_vector (15 downto 0);
	
	--2 way mux, 16 bit for for holding data in registers or present new data
	signal feedback	: std_Ulogic_vector (15 downto 0);	
	signal mux_out	: std_Ulogic_vector (15 downto 0);
	
begin											   
	LUT : LUT_16x16 port map (addr,lut_out);	
	S :		add_sub_gen generic map (16) port map (temp,lut_out,sum_out,open,d);
	
	--load input data or present the output data as input
	--If the X is negative, input data must be pi (100000000000000) otherwise 0 (000000000000000) thus, the simple way to achieve this it's
	--sufficient that the MSB of input word is the sign bit of X
	ing <= sgn_x&"000000000000000" when load_ext = '1' else sum_out;	
	r	:	reg generic map (16) port map (ing,temp,clk,reset);
	
	--The input of the output register is driven by a 2 way mux (16 bit) this allow to store data
	--in the register or load the value from the output of ripple carry adder\subtractor (and present
	--it at the next clock cycle)
	mux_out <= sum_out when output = '1' else feedback;	
	
	mem3	: reg generic map (16) port map (mux_out,feedback,clk,reset);
	fase <= feedback;		--the output port of CORDIC B is driven by the output of register    
end rtl;