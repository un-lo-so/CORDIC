library IEEE;

use IEEE.std_logic_1164.all;								  

-- Part of CORDIC that calculate the modulus of complex number	
-- the input is on 13 bit in C2 arithmetic

entity CORDIC_A is	
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
end CORDIC_A;

architecture rtl of CORDIC_A is		
	--building blocks 
	--n bit ripple carry adder\subtractor
	component add_sub_gen is
	generic (NBit : positive := 4);		--default value of adder\subtractor is 4 bit
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
	
	--16 bit barrel shift register
	component barrel is										
	port (
		ing : in std_ulogic_vector (15 downto 0);	--data in
		usc : out std_ulogic_vector (15 downto 0);	--data out
		nshift : in std_ulogic_vector (3 downto 0)	--number of right shift required
	);
	end component barrel;
	
	--n bit register	
	component reg is
	generic (NBit : positive := 4);		--default value of register is 4 bit width
	port (
		ing : in std_ulogic_vector (Nbit-1 downto 0);	--input word
		usc : out std_ulogic_vector (Nbit-1 downto 0);	--output word
		clk : in std_ulogic;			--clock	   
		reset : in std_ulogic			--asynchronous reset active high		  
	);
	end component reg;

	--auxiliary internal signals - see relation (page 3)
	signal d : std_ulogic;
	signal d1   : std_ulogic;
	
	--handle the input signals
	signal x_int : std_ulogic_vector (15 downto 0);
	signal y_int : std_ulogic_vector (15 downto 0);
	
	signal sum1 : std_ulogic_vector (15 downto 0);	--output of 1st ripple carry adder\subtractor
	signal sum2 : std_ulogic_vector (15 downto 0);	--output of 2nd ripple carry adder\subtractor
	
	--operands of first ripple carry adder\subtractor
	signal a1 : std_ulogic_vector (15 downto 0);
	signal a2 : std_ulogic_vector (15 downto 0);
	--operands of second ripple carry adder\subtractor
	signal b1 : std_ulogic_vector (15 downto 0);
	signal b2 : std_ulogic_vector (15 downto 0);	 				 	
	
	--2 waim mux, 16 bit to provide the feedback for holding data or load new result in output register 
	signal temp : std_ulogic_vector (15 downto 0);
	
	--2 may mux, 16 bit to provide the feedback for holding data or load operands 
	signal mux1 : std_ulogic_vector (15 downto 0); --x
	signal mux2 : std_ulogic_vector (15 downto 0); --y	  
	
	--2 way mux, 16 bit to drive the output register (load new data or store current data )
	signal mux_out : std_ulogic_vector (15 downto 0);
	
begin	   				  
	--input are mapped on 16 bit. Additional MSB for dynamics 
	--additional LSB for accuracy 
	x_int <= x(13)&x&"0"; 
	y_int <= y(13)&y&"0"; 
	
	--Load foreign data or create a feedback loop to store data th store operand
	mux1 <= x_int when load_ext = '1' else sum1;
	mux2 <= y_int when load_ext = '1' else sum2;
		
	--registers for store operands	
	mem1 : reg generic map (16) port map (mux1,a1,clk,reset);	
	mem2 : reg generic map (16) port map (mux2,a2,clk,reset);
	
	--ripple carry adder subtractors	
	sX		: add_sub_gen generic map (16) port map (a1,b1,sum1,open,d);
	sY		: add_sub_gen generic map (16) port map (a2,b2,sum2,open,d1);
	
	--barrel registers shifters
	shift1	: barrel port map (a2,b1,i);
	shift2	: barrel port map (a1,b2,i);
	
	--the MSB of Y drive next operation:
	--0 addition
	--1 subtraction
	d <= '1' when a2(15) = '1' else '0';
	d1 <= not d;  
	
	--output register, a 2 way mux, 16 bit allow the register to store data						 
	mux_out <= sum1 when output = '1' else temp;  		
	
	mem3	: reg generic map (16) port map (mux_out,temp,clk,reset);
	modulo <= temp;		--the output of register drive the output port of CORDIC
	
	d_out <= d;			--the configuration bit drive the appropriate output of CORDIC module
end rtl;				 
