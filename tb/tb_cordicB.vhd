library IEEE;

use IEEE.std_logic_1164.all;	
use IEEE.numeric_std.all;

entity tb_cordicB is
end tb_cordicB;

architecture behavioral of tb_cordicB is
	component CORDIC_B is	
	port(
		sgn_x	: in std_ulogic;								--bit of sign of x, it allow to establish in which half-plane is
																--the complex number and apply an offset
		clk : in std_ulogic;									--clock
		reset : in std_ulogic;									--asynchronous reset 
		addr : in std_ulogic_vector (3 downto 0);				--address bus for  LUT
		load_ext : in std_ulogic;								--pin for loading new data
		sum_or_store : in std_ulogic;							--configuration bit:
																--1 holding data
																--0 acquire new data
		d : in std_ulogic;										--bit for sign - from CORDIC A,it drive the ripple carry adder\subtractor
		fase : out std_ulogic_vector (15 downto 0);				--bus for the output
		output : in std_ulogic									--pin for present the result in output
	);
	end component CORDIC_B;
	
	signal sgn_x	: std_ulogic;
	signal clk		: std_ulogic;
	signal reset	: std_ulogic;
	signal addr		: std_ulogic_vector (3 downto 0);
	signal load		: std_ulogic;
	signal sum_atan	: std_ulogic;
	signal d		: std_ulogic;
	
begin
	DUT : CORDIC_B port map (sgn_x,clk,reset,addr,load,sum_atan,d,open,'1');   
	
	proc0: process			--process that drive the sign of X
	begin
		sgn_x <= '0';
		wait for 80 ns;
		sgn_x <= '1';
		wait for 80 ns;
	end process;
	
	proc1 : process			--process that drive clock signal
	begin
		clk <= '0';
		wait for 5 ns;
		clk <= not clk;
		wait for 5 ns;
	end process;		  
	
	proc2 : process			--process that drive load configuration bit\signal
	begin			  
		load <= '0';
		wait for 45 ns;
		load <= '1';
		wait for 10 ns;
		load <= '0';
		wait;
	end process;
	
	proc3 :	process		--process that drive address bus
	begin		
		addr <= std_ulogic_vector(TO_UNSIGNED(14,4)); 
		wait;	
	end process;	
	
	proc4 : process		--process that drive reset signal
	begin		
		reset <= '1';
		wait for 10 ns;
		reset <= '0'; 
		wait for 100 ns;
		reset <= '1';
		wait;
	end process; 
	
	proc5 : process	 	--process that drive sum_atan configuration bit\signal		
	begin
		sum_atan <= '0';
		wait for 80 ns;
		sum_atan <= '1';
		wait for 80 ns;
		sum_atan <= '0';
		wait;
	end process;

	proc6: process		--process that drive the sign configuration bit\signal
	begin
		d <= '0';
		wait for 80 ns;
		d <= '1';
		wait for 80 ns;
	end process;
end behavioral;
