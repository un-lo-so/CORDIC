library IEEE;

use IEEE.std_logic_1164.all;

entity TB_shift is
end entity;

architecture rtl of TB_shift is
	component shift_reg is
	generic (NBit : positive := 4);
	port (	 
		ing		: in std_ulogic_vector (Nbit-1 downto 0);	 	--input bus for data (parallel)
		usc		: out std_ulogic_vector (Nbit-1 downto 0);		--output bus for data (parallel)
		clk		: in std_ulogic;								--clock
		reset	: in std_ulogic;                                --pin for asynchronous reset of register\flip flops
		shift	: in std_ulogic					                --configuration pin:
																--0 load data
																--1 Arithmetic right shift
		);		                
	end component shift_reg;	
		
	signal ing : std_ulogic_vector (3 downto 0);
	signal usc : std_ulogic_vector (3 downto 0);
	signal clk : std_ulogic := '0';
	signal reset : std_ulogic;
	signal shift : std_ulogic;
begin
	DUT	:	shift_reg generic map (4) port map(ing,usc,clk,reset,shift);	   
	
	porc1 : process			--processo that drive clock signal
	begin		
		wait for 10 ns;
		clk <= not clk;
	end process;
	
	proc2 : process			--processo that drive reset signal
	begin
		reset <= '1';
		wait for 20 ns;
		reset <= '0';
		wait;
	end process;
	
	proc3 : process			--processo that drive the configuration bit
	begin		
		shift <= '0';
		wait for 30 ns;
		shift <= '1';
		wait;
	end process;
	
	proc4 : process			--processo that drive input data
	begin		
		ing <= "1000";
		wait;
	end process;
end rtl;