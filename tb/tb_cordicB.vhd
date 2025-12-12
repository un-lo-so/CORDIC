library IEEE;

use IEEE.std_logic_1164.all;	
use IEEE.numeric_std.all;

--test bench per la parte per il calcolo dell'angolo del CORDIC
--AUTORE: Enrico Gori
   
entity tb_cordicB is
end tb_cordicB;

architecture behavioral of tb_cordicB is
	component CORDIC_B is	
	port(
		sgn_x	: in std_ulogic;					--bit di segno della x, per stabilire in quale semiquadrante siamo
													--e applicare l'opportuno sfasamento 
		clk : in std_ulogic;						--ingresso del clock
		reset : in std_ulogic;						--reset per i registri, attivo alto 
		addr : in std_ulogic_vector (3 downto 0);	--indirizzo per la LUT
		load_ext : in std_ulogic;					--pin per il caricamento dei dati
		d : in std_ulogic;							--pin per il pilotaggio del sommatore\sottrattore
		fase : out std_ulogic_vector (15 downto 0);	--bus per l'uscita
		output : in std_ulogic						--pin per emettere la fase in uscita 
	);
	end component CORDIC_B;
	
	signal clk		: std_ulogic;
	signal reset	: std_ulogic;
	signal addr		: std_ulogic_vector (3 downto 0);
	signal sum_atan	: std_ulogic;
	signal sgn		: std_ulogic := '1';					  
	signal load		: std_ulogic;
	
begin
	DUT : CORDIC_B port map (sgn,clk,reset,addr,load,sum_atan,open,'1');   
	
	proc1 : process
	begin
		clk <= '0';
		wait for 5 ns;
		clk <= not clk;
		wait for 5 ns;
	end process;		  
						 	
	proc2 :	process
	begin		
		addr <= std_ulogic_vector(TO_UNSIGNED(14,4)); 
		--wait for 76 ns;
		--addr <= std_ulogic_vector(TO_UNSIGNED(1,4)); 
		wait;	
	end process;	
	
	proc3 : process
	begin		
		reset <= '1';
		wait for 10ns;
		reset <= '0'; 
		wait for 100 ns;
		reset <= '1';
		wait;
	end process; 
	
	proc4 : process	 
	begin
		sum_atan <= '0';
		wait for 80 ns;
		sum_atan <= '1';
		wait for 80 ns;
		sum_atan <= '0';
		wait;
	end process;
	
	proc5:	 process 
	begin
		load <= '1';
		wait for 5 ns;
		load <= '0';
		wait;
	end process;
	
end behavioral;
