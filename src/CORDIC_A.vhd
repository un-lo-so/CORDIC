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
		load_ext	: in std_ulogic;					--pin for loading new data
		store_or_shift : in	std_ulogic;					--driving shift registers
		output		: in std_ulogic;					--pin for present the result in output
		modulo : out std_ulogic_vector (15 downto 0);	--the output contain the modulus of complex number
		d_out	: out std_ulogic						--sign output, used in the calculus of phase
	);
end CORDIC_A;

architecture rtl of CORDIC_A is
	--buliding blocks 
	--n bit ripple carry adder\subtractor
	component add_sub_gen is
	generic (NBit : positive := 4);						--default value of adder\subtractor is 4 bit
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
		clk : in std_ulogic;			--clock	   
		reset : in std_ulogic			--asynchronous reset active high	  
	);
	end component reg;		 
	
	--n bit shift (arithmetic) right register
	component shift_reg is
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
	end component shift_reg;

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
	signal b1 : std_ulogic_vector (15 downto 0);
	--operands of second ripple carry adder\subtractor
	signal a2 : std_ulogic_vector (15 downto 0);
	signal b2 : std_ulogic_vector (15 downto 0);	 
	
	--2 may mux, 16 bit to provide the feedback for holding data or load operands 
	signal mux1 : std_ulogic_vector (15 downto 0); -- x
	signal mux2 : std_ulogic_vector (15 downto 0); -- y	  
	
	--2 may mux, 16 bit to load data in shift registers or holding the output
	signal in1	: std_Ulogic_vector (15 downto 0);
	signal in2	: std_Ulogic_vector (15 downto 0);
	
	--output of operand registers
	signal f1	: std_Ulogic_vector (15 downto 0);
	signal f2	: std_Ulogic_vector (15 downto 0);	  
		
	--2 way mux, 16 bit to load foreing data or the output of ripple carry adder subtractor 
	signal load1	: std_Ulogic_vector (15 downto 0);
	signal load2	: std_Ulogic_vector (15 downto 0);
	
	--2 way mux, 16 bit to drive the output register (load new data or store current data )
	signal mux_out : std_ulogic_vector (15 downto 0);
	--Handle the output of output register 
	signal f3 : std_ulogic_vector (15 downto 0);
	
begin
	--input are mapped on 16 bit. Additional MSB for dynamics 
	--additional LSB for accuracy 
	x_int <= x(13)&x&"0"; 
	y_int <= y(13)&y&"0"; 
	
	--Load foreign data or create a feedback loop to store data th store operand
	mux1 <= x_int when load_ext = '1' else sum1;
	mux2 <= y_int when load_ext = '1' else sum2;
		
	--input registers	
	in1 <= f1 when store_or_shift = '1' else mux1;	--drive register with input data or drive with it's output
													--to store the current data
	mem1 : reg generic map (16) port map (in1,f1,clk,reset);	
	a1 <= f1;										--the output of register is the input of ripple carry adder\subtractor 
	
	in2 <= f2 when store_or_shift = '1' else mux2;	--drive register with input data or drive with it's output
													--to store the current data
	mem2 : reg generic map (16) port map (in2,f2,clk,reset);
	a2 <= f2;										--the output of register is the input of ripple carry adder\subtractor
									
	--ripple carry adder\subtractor instances 	
	sX		: add_sub_gen generic map (16) port map (a1,b1,sum1,open,d);
	sY		: add_sub_gen generic map (16) port map (a2,b2,sum2,open,d1);
	
	--muxes that load data in the shifter registers or the output of ripple carry adder subtractor
	--(hold functionalty)
	load1 <= in2 when load_ext = '0' else y_int;
	load2 <= in1 when load_ext = '0' else x_int;
		
	--shifter registers
	shift1	: shift_reg generic map (16) port map(load1,b1,clk,reset,store_or_shift);
	shift2	: shift_reg generic map (16) port map(load2,b2,clk,reset,store_or_shift);
		
	--the MSB of Y drive next operation:
	--0 addition
	--1 subtraction
	d <= '1' when a2(15) = '1' else '0';
	d1 <= not d;  
	
	--output register, a 2 way mux, 16 bit allow the register to store data						 
	mux_out <= sum1 when output = '1' else f3;
	mem3	: reg generic map (16) port map (mux_out,f3,clk,reset);
	
	modulo <= f3;		--the output of register drive the output port of CORDIC	   
	d_out <= d;			--the configuration bit drive the appropriate output of CORDIC module
end rtl;				 
