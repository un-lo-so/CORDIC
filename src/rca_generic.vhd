library IEEE;
use IEEE.std_logic_1164.all;
-- n bit ripple carry adder\subtractor 

entity add_sub_gen is
	generic (NBit : positive := 4);				--default value of adder\subtractor is 4 bit
	port (
		a : in std_ulogic_vector (Nbit-1 downto 0);			--N bit operand
		b : in std_ulogic_vector (Nbit-1 downto 0);			--N bit operand
		s : out std_ulogic_vector (Nbit-1 downto 0);		--N bit sum
		cout : out std_ulogic;								--carry out
		add_sub : in std_ulogic								--configuration bit: 
															--1 = subtract
															--0 = add
	);
end add_sub_gen;

architecture rtl of add_sub_gen is
	--ripple carry adder\subtractor is a "daisy-chain" of many full adder
	--a xor provide the negation of any bit (to implemnt the C2 arithmetic subraction)
	
	--1 bit full adder is a building block
	component full_adder is
		port (
			a : in std_ulogic;			--1st operand
			b : in std_ulogic;			--2nd operand
			cin : in std_ulogic;		--carry in
			s	: out std_ulogic;		--sum
			cout : out std_ulogic 		--carry out
		);
	end component full_adder;
	
	signal carry : std_ulogic_vector (Nbit downto 0); 	--carry bus
	signal temp : std_ulogic_vector (NBit-1 downto 0);	--output of xor - for second operand	
		
begin						 
		carry (0) <= add_sub; 			--carry in is also the configuration bit:
										--1 = subtract 
										--0 = add
		--generate the ripple carry adder
		gen: for n in 0 to NBit-1 generate	  	
			temp (n) <= b(n) xor add_sub;		--xor with an input stuck at 1 act like an inverter, if it'second
												--stuck at 0, xor act like a buffer. This is useful
												--in C2 arithmetic												
			--link together the 1 bit full adders
			FA : full_adder port map (a(n),temp(n),carry(n),s(n),carry(n+1));		 
		end generate;
	cout <= carry (Nbit); --map the carry out: the carry out of last full adder is the carry out
						  --of ripple carry adder
end rtl;