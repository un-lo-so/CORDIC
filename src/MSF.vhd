library IEEE;

use IEEE.std_logic_1164.all;	
use IEEE.numeric_std.all;

-- MSF for driving CORDIC A and CORDIC B parts

entity msf is 
	port (
		clk : in std_ulogic;							--clock
		reset : out std_ulogic;							--asynchronous reset
		nshift  : out std_ulogic_vector (3 downto 0);	--bus for driving LUT of CORDIC B module		
		load_ext : out std_ulogic;	  					--signal for loading external data
		sum_or_shift : out	std_ulogic;					--signal for driving CORDIC A
														--0 = add\subtract of operands
														--1 = shift of operands		
		output : out std_ulogic							--control signal for update the outputs of CORDIC
	);
end msf;			  

architecture behavioral of msf is	
	--state of MSF
	type state_t is (PRS,LOAD,SHIFT1,SHIFT2,SHIFT3,SHIFT4,SHIFT5,SHIFT6,SHIFT7,SHIFT8,SHIFT9,SHIFT10,SHIFT11,SHIFT12,SHIFT13,SHIFT14,SHIFT15,PRESENTA);
	--state variables
	signal curr_state : state_t :=PRS;
	signal next_state : state_t;	
	--counter that store the number of iterations for driving output bus
	signal count : std_ulogic_vector (3 downto 0) := "0000";	 
	--temporary signal that store how many shift are performed in the current state
	signal temp : std_ulogic_vector (3 downto 0) := "0000";

begin	
	-- moore machine
	
	--evaluate the next state
	evol_state: process (clk) 	
	begin  									   
		if (rising_edge(clk)) then	--for any clock cycle 
			--temp will be increased of 1
			case temp is
				when "0000" =>
					temp <= "0001";
				when "0001" =>
					temp <= "0010";
				when "0010" =>
					temp <= "0011";
				when "0011" =>
					temp <= "0100";
				when "0100" =>
					temp <= "0101";
				when "0101" =>
					temp <= "0110";
				when "0110" =>
					temp <= "0111";
				when "0111" =>
					temp <= "1000";
				when "1000" =>
					temp <= "1001";
				when "1001" =>
					temp <= "1010";
				when "1010" =>
					temp <= "1011";
				when "1011" =>
					temp <= "1100";
				when "1100" =>
					temp <= "1101";
				when "1101" =>
					temp <= "1110";
				when "1110" =>
					temp <= "1111";
				when others => temp <= "0000";		--at the end, reset reset temp
			end case;
			
			if temp = count then					--if the appropriate number of iterations was performed
				curr_state <= next_state;			--update the state
				temp <= "0000";						--temp will be also reset
			end if;
		end if;
	end process evol_state;
	
	--process for predict the next state
	path_state: process (curr_state)	--when the current status change next state will be updated too	
	begin		 
		--any status consist of a certain value for the state variable and a value for count register
		case curr_state is
			when PRS =>				--preset: msf is initialized
				count <= std_ulogic_vector(TO_UNSIGNED(0,4));  	--right shift of 0 positions
				next_state <= LOAD;	 							--the next state loads data
			when SHIFT1 =>
				count <= std_ulogic_vector(TO_UNSIGNED(1,4));	--right shift of 1 positions
				next_state <= SHIFT2;				   			--in next state the operand must be right shift by 2
			when SHIFT2 =>
				count <= std_ulogic_vector(TO_UNSIGNED(2,4));	--right shift of 2 positions
				next_state <= SHIFT3;				   			--in next state the operand must be right shift by 3
			when SHIFT3 =>
				count <= std_ulogic_vector(TO_UNSIGNED(3,4));	--right shift of 3 positions
				next_state <= SHIFT4;				   			--in next state the operand must be right shift by 4
			when SHIFT4 =>
				count <= std_ulogic_vector(TO_UNSIGNED(4,4));	--right shift of 4 positions
				next_state <= SHIFT5;				   			--in next state the operand must be right shift by 5
			when SHIFT5 =>
				count <= std_ulogic_vector(TO_UNSIGNED(5,4));	--right shift of 5 positions
				next_state <= SHIFT6;							--in next state the operand must be right shift by 6
			when SHIFT6 =>
				count <= std_ulogic_vector(TO_UNSIGNED(6,4));	--right shift of 6 positions
				next_state <= SHIFT7;				   			--in next state the operand must be right shift by 7
			when SHIFT7 =>
				count <= std_ulogic_vector(TO_UNSIGNED(7,4));	--right shift of 7 positions
				next_state <= SHIFT8;				   			--in next state the operand must be right shift by 8
			when SHIFT8 =>
				count <= std_ulogic_vector(TO_UNSIGNED(8,4));	--right shift of 8 positions
				next_state <= SHIFT9;				   			--in next state the operand must be right shift by 9
			when SHIFT9 =>
				count <= std_ulogic_vector(TO_UNSIGNED(9,4));	--right shift of 9 positions
				next_state <= SHIFT10;				   			--in next state the operand must be right shift by 10
			when SHIFT10 =>
				count <= std_ulogic_vector(TO_UNSIGNED(10,4));	--right shift of 10 positions
				next_state <= SHIFT11;				   			--in next state the operand must be right shift by 11
			when SHIFT11 =>
				count <= std_ulogic_vector(TO_UNSIGNED(11,4));	--right shift of 11 positions
				next_state <= SHIFT12;							--in next state the operand must be right shift by 12
			when SHIFT12 =>
				count <= std_ulogic_vector(TO_UNSIGNED(12,4));	--right shift of 12 positions
				next_state <= SHIFT13;				   			--in next state the operand must be right shift by 13
			when SHIFT13 =>
				count <= std_ulogic_vector(TO_UNSIGNED(13,4));	--right shift of 13 positions
				next_state <= SHIFT14;				   			--in next state the operand must be right shift by 14
			when SHIFT14 =>
				count <= std_ulogic_vector(TO_UNSIGNED(14,4));	--right shift of 14 positions
				next_state <= SHIFT15;				   			--in next state the operand must be right shift by 15
			when SHIFT15 =>
				count <= std_ulogic_vector(TO_UNSIGNED(15,4));	--right shift of 15 positions
				next_state <= PRESENTA;							--in next state the new output will be presented
			when LOAD =>										--load data 
				count <= std_ulogic_vector(TO_UNSIGNED(0,4));	 --right shift of 0 positions
				next_state <= SHIFT1;							 --in next state the operand must be right shift by 1
			when others =>										 --for not covered states (only the output state)
				count <= std_ulogic_vector(TO_UNSIGNED(0,4));	 --in next state a new cycle will be begin, the output
																 --will be 0 and new data will be acquired
				next_state <= LOAD;								 
			end case;
	end process path_state;  
	
	--process that drive the outputs
	output_logic: process (curr_state,temp)		--any time that the current staate change 
	begin
		case curr_state is			 		--some output depend to current state
			when PRS =>						--preset state
				load_ext <= '0';			--load new data  
				reset <= '1';				--reset of all flip flops
				output <= '0';	 			--old output will be hold 
			when LOAD =>					--load new data state
				load_ext <= '1'; 			--force the load of new data 
				reset <= '0';				--no reset of flip flops
				output <= '0';	 			--old output will be hold
			when PRESENTA =>				--present output state
				load_ext <= '0';  			--no new data will be loaded
				reset <= '0';				--no reset of flip flops
				output <= '1'; 				--update output 
			when others =>					--for other states:
				load_ext <= '0';  			--no load of new data
				reset <= '0';				--no reset for registers
				output <= '0'; 				--old output will be hold
		end case;				
		nshift <= count;					--count drive the shift bus
		
		if temp = "0000" then				--according to temp value
			sum_or_shift <= '0';			--provide the sum
		else				  
			sum_or_shift <= '1';			--provide the right shift of one position for any clock cycle
		end if;		
	end process output_logic;	  			
end behavioral;		