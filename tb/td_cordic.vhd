library IEEE;						
use IEEE.std_logic_1164.all;  
use IEEE.numeric_std.all;  
use STD.textio.all;
use IEEE.std_logic_textio.all;

-- test bench for CORDIC

entity tb_cordic is
end tb_cordic;

architecture behavioral of tb_cordic is	  
	--si usa il CORDIC finito cioè con il suo wrapper
	component CORDIC_wrapper is
	port (
		clk : in std_ulogic;							--clock
		x	: in std_ulogic_vector (13 downto 0);		--X
		y	: in std_ulogic_vector (13 downto 0);		--Y      
		modulo : out std_ulogic_vector (15 downto 0);	--output modulus
		fase : out std_ulogic_vector (15 downto 0)	 	--phase			
	);
	end component;	
	
	--signals for driving CORDIC
	signal clk : std_ulogic := '0';						--clock
	signal x : std_ulogic_vector (13 downto 0);			--X
	signal y : std_ulogic_vector (13 downto 0);	 		--Y
	
	--outputs signals
	signal modulo : std_ulogic_vector (15 downto 0);
	signal fase : std_ulogic_vector (15 downto 0);	 
		
begin		
	DUT : CORDIC_wrapper port map (clk,x,y,modulo,fase);

	proc0: process	 		--process that drive clock signal 
	begin		
		wait for 10 ns;
		clk <= not clk;
	end process;  
		
	read_proc: process		--process for data input
		variable linea	: line;
		variable input_x	: std_ulogic_vector(13 downto 0);
		variable comma	: character;
		variable input_y	: std_ulogic_vector(13 downto 0);
		
		file	file_input	: text;
	
		begin	 
			--read input file
			file_open(file_input,"input.txt",read_mode);
		
			readline(file_input,linea);	
			read(linea,input_x);
			read(linea,comma);
			read(linea,input_y); 
			
			--drive signals with the content of input.txt  
			x <= input_x;
			y <= input_y;
			
			wait for 100 ns;
		
			while not endfile(file_input) loop
				readline(file_input,linea);	
				read(linea,input_x);
				read(linea,comma);
				read(linea,input_y); 
			
				--a signal acquire the outputs	 
				x <= input_x;
				y <= input_y;	
				wait for 340ns;		--this is the time required to execute a single elaboration
									--(!!!! only if clock is 20 MHz !!!!)
			end loop;	   			  
			file_close(file_input);		 		
			wait;
	end process;
	
	--process that write data in an output file, any time the modulus change
	write_proc: process (modulo,fase)	 	 		
		file	file_output	: text;								
		variable linea_out	: line;
		begin										   
			file_open(file_output,"output.txt",append_mode);	   		
			
			write(linea_out,to_StdLogicVector(modulo));
			write(linea_out,','); 		--separatore
			write(linea_out,to_StdLogicVector(fase));
			writeline(file_output,linea_out);	 
	
			file_close(file_output);
	end process;	
end behavioral;
