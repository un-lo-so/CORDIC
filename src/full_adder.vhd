library IEEE;
use IEEE.std_logic_1164.all;
-- full adder sigle bit, with carry in and carry out

entity full_adder is
	port (
		a : in std_ulogic;			--1st operand
		b : in std_ulogic;			--2nd operand
		cin : in std_ulogic;		--carry in
		s	: out std_ulogic;		--sum
		cout : out std_ulogic 		--carry out
	);
end full_adder;

architecture rtl of full_adder is 
begin	 
	s <= a xor b xor cin;  							--sum
	cout <= (a and b)or(a and cin)or(b and cin);	--carry out
end rtl;
	