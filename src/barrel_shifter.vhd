library IEEE;

use IEEE.std_logic_1164.all;	

-- 16 bit barrel shifter; it perform, in a single clock cycle, a right shift of an
-- arbitrary number positions

entity barrel is										
	port (
		ing : in std_ulogic_vector (15 downto 0);		--data in
		usc : out std_ulogic_vector (15 downto 0);		--data out
		nshift : in std_ulogic_vector (3 downto 0)	 	--number of right shift required
	);
end barrel;

architecture behavioral of barrel is  
begin		   
	proc: process (ing,nshift)		--sensitiviy list for process it will be activate when input
									--or bus related to shift position change
	begin 
		--Provide the arithmetic right shift (the MSB must conserved)
		case nshift is
			when "0000" =>	usc <= ing;
			when "0001"	=>	usc <= ing (15) & ing(15 downto 1);  
			when "0010"	=>	usc <= ing (15) & ing (15) & ing(15 downto 2);
			when "0011"	=>	usc <= ing (15) & ing (15) & ing (15) & ing(15 downto 3);
			when "0100"	=>	usc <= ing (15) & ing (15) & ing (15) & ing (15) & ing(15 downto 4);
			when "0101"	=>	usc <= ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing(15 downto 5);
			when "0110"	=>	usc <= ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing(15 downto 6);
			when "0111"	=>	usc <= ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing(15 downto 7);
			when "1000"	=>	usc <= ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing(15 downto 8);
			when "1001"	=>	usc <= ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing(15 downto 9);
			when "1010"	=>	usc <= ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing(15 downto 10);
			when "1011"	=>	usc <= ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing(15 downto 11);
			when "1100"	=>	usc <= ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing(15 downto 12);
			when "1101"	=>	usc <= ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing(15 downto 13);
			when "1110"	=>	usc <= ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing(15 downto 14);
			when others =>	usc <= ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing (15) & ing(15) & ing(15) ;	
		end case;
	end process;
end behavioral;