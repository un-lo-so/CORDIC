library IEEE;

use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;

--test bench for the N bit register

entity TB_reg_gen is
end TB_reg_gen;

architecture behavioral of TB_reg_gen is	
	--declaration of register
	component reg is
	generic (NBit : positive := 4);		--default value of register is 4 bit width
	port (
		ing : in std_ulogic_vector (Nbit-1 downto 0);	--input word
		usc : out std_ulogic_vector (Nbit-1 downto 0);	--output word
		clk : in std_ulogic;			--clock 	   
		reset : in std_ulogic			--asynchronous reset active high		  
	);
	end component reg;
	
	signal a : std_ulogic_vector (3 downto 0);	
	signal b : std_ulogic_vector (3 downto 0);	
	
	signal clk : std_ulogic :='0';					 
	signal reset : std_ulogic :='0';	
	signal operazione : std_ulogic := '1';

begin
	DUT : reg generic map(4) port map(a,b,clk,reset);	  
	
	proc0: process		 	----processo that drive the clock signal
	begin			   
		wait for 20 ns;
		clk <= not clk;
	end process;   				  
	
	proc1: process			--processo that drive reset signal
	begin
		reset <= '1';
		wait for 20 ns;
		reset <= '0'; 
		wait for 45 ns;
		reset <= '1';
		wait for 5 ns;
		reset <= '0'; 
		wait for 500 us;
	end process;		   
	
	proc2: process
	begin		
		a <= std_ulogic_vector(TO_UNSIGNED(8,4));
		wait for 100 ns;
		a <= std_ulogic_vector(TO_UNSIGNED(5,4));
		wait;
	end process;
	
end behavioral;