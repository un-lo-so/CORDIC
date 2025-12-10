library IEEE;

--test bench for adder\subtractor. Test with 3 bit (C2 arithmetic)	  

use IEEE.std_logic_1164.all;		
use IEEE.numeric_std.all;

entity TB_add_sub is
end TB_add_sub;

architecture behavioral of TB_add_sub is

	--declaration of building block
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
	
	--auxiliary signals\stimuli
	signal op_1 : std_ulogic_vector (2 downto 0);	--1st operand
	signal op_2 : std_ulogic_vector (2 downto 0);	--2nd operand
	signal operazione : std_ulogic :='0';			--sum\subtraction bit
	

begin
	--3 bit adder\subtractor instance
	DUT : add_sub_gen generic map (3) port map (op_1,op_2,open,open,operazione);
	
	proc_1: process
	begin
		for i in 0 to 7 loop	--scan all configuration of 3 bits
			op_1 <= std_ulogic_vector(TO_UNSIGNED(i,3));
			wait for 0.01 us;
		end loop;
	end process proc_1;
		
	proc_2: process
	begin
		for i in 0 to 7 loop	--scan all configuration of 3 bits
			op_2 <= std_ulogic_vector(TO_UNSIGNED(i,3));
			wait for 0.08 us;	--wait for each configuration of proc_1 operand
		end loop;
	end process proc_2;	   
	
	operazione <= not operazione after 0.64 us;	--perform addition or subtraction any 8*8 us
	
end behavioral;