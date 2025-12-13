library IEEE;	 

use IEEE.std_logic_1164.all;

entity tb_shifter is
end tb_shifter;

architecture behavioral of tb_shifter is
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
	
	signal clk : std_ulogic := '0';		  
	signal reset : std_ulogic := '0';	 
	signal operazione : std_ulogic := '1';
	signal ing : std_ulogic_vector(3 downto 0);
	
begin	
	DUT : shift_reg generic map (4) port map (ing,open,clk,reset,operazione);
	
	ing <= "1000";
	
	clk <= not clk after 50 ns;		 
	reset <= not reset after 1000 ns;
	operazione <= not operazione after 80 ns;
	
	
end behavioral;