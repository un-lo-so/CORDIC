library IEEE;
use IEEE.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

library STD;
use std.env.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

library CORDIC;

library CORDIC_VVC;
use CORDIC_VVC.cordic_bfm_pkg.all;

entity CORDIC_TB is
end entity CORDIC_TB;

architecture beh of CORDIC_TB is
	signal cordic_if : t_cordic_if(x(13 downto 0),y(13 downto 0),modulus(15 downto 0),phase(15 downto 0)) := init_cordic_if(14,14,16,16);
	signal clk	:	std_logic;
	signal clk_ena	:	boolean;
	constant C_CLK_PERIOD : time := 50 ns;	--f=20 Mhz

begin
	--instantiate DUT
	DUT: entity CORDIC.CORDIC_wrapper
	port map(
		clk 	=>	clk, 
		x		=>	CORDIC_IF.x,
		y		=>	CORDIC_IF.y,
		modulo 	=>	CORDIC_IF.modulus,
		fase 	=>	CORDIC_IF.phase,
		output	=> 	CORDIC_IF.update_output,
		new_data	=> 	CORDIC_IF.new_data
		);
	
	--Clock generator stimulus
	clock_generator(clk, clk_ena, C_CLK_PERIOD, "Testbench clock");
	
	p_main: process
		constant C_SCOPE : string := C_TB_SCOPE_DEFAULT;
		
		constant CONFIG_IF : t_cordic_bfm_config := (
			bfm_sync        		=> SYNC_ON_CLOCK_ONLY,
			id_for_bfm				=> ID_BFM,
			clock_period			=> C_UNDEFINED_TIME,
			clock_period_margin		=> C_UNDEFINED_TIME,   
			clock_margin_severity 	=> TB_ERROR,
			setup_time				=> C_UNDEFINED_TIME,
			hold_time				=> C_UNDEFINED_TIME,
			wait_num_cycle			=> 2000,
			wait_cycles_severity	=> WARNING
		);
		
		variable m		: real;		--modulus
		variable p		: real;		--phase
		
		--Random variables:
		--Generator of random numbers
		variable rnd_sym	:	t_rand;
		--Temporary random symbol values
		variable rand_x		:	std_logic_vector(13 downto 0);
		variable rand_y		:	std_logic_vector(13 downto 0);
		variable rand_sym_x		:	real;
		variable rand_sym_y		:	real;
		
		--Temporary variables for calculate times
		variable start_time	:	time;
		variable end_time	:	time;
		
		--Temporary variable for calculus
		variable temp		:	real;
		
		--Value readed by BFM
		variable modulus_val    : integer range 0 to 2**16-1;	
		variable phase_val      : integer range 0 to 2**16-1;
		
		--Real values readed by BFM
		variable real_modulus	: real;
		variable real_phase		: real;
		
		variable expected_modulus	: real;		
		variable expected_phase		: real;		
		
		--Variable to store result of check_value_in_range
		variable response	: boolean;
		
		procedure check_value(
			x	:	real;
			y	:	real;
			msg	:	string;
			delta_m	: real;
			delta_ph	: real
		) is
			variable expected_modulus	: real;		
			variable expected_phase		: real;		
			variable calculated_modulus	: real;		
			variable calculated_phase	: real;
		begin
			--calculate the exact value
			expected_modulus := sqrt(x**2+y**2);
			if y >= real(0) then
				expected_phase := arctan(y,x);
			else
				expected_phase := arctan(y,x)+real(2)*MATH_PI;
			end if;
			
			--write data to bus
			write_cartesian(x,y,msg,clk,cordic_if,C_SCOPE,shared_msg_id_panel,CONFIG_IF);
		
			--check values returned by CORDIC
			read_cartesian(calculated_modulus,calculated_phase,msg,clk,cordic_if,C_SCOPE,shared_msg_id_panel,CONFIG_IF);
			
			--Check values according to tollerances
			check_value_in_range(calculated_modulus,expected_modulus-delta_m,expected_modulus+delta_m,FAILURE,"Check on modulus",C_SCOPE,ID_LOG_HDR,shared_msg_id_panel);
		
			--Perform a contron on phase value only if it's not zero
			if expected_modulus /= real(0) then
				check_value_in_range(calculated_phase,expected_phase-delta_ph,expected_phase+delta_ph,FAILURE,"Check on phase",C_SCOPE,ID_LOG_HDR,shared_msg_id_panel);
			end if;
		end procedure;
		
	begin
		--Print configuration on the log
		report_global_ctrl(VOID);
		report_msg_id_panel(VOID);
		
		--Very verbose mode
		enable_log_msg(ALL_MESSAGES);
    
		disable_log_msg(ID_RAND_GEN,C_SCOPE);
		
		log(ID_LOG_HDR, "Start Simulation of TB for CORDIC - barrel implementation", C_SCOPE);
		
		--That is - We won't halt simulation at first failure
		set_alert_stop_limit(FAILURE,3);
		
		--Now we can enable clock
		clk_ena <= true;
		
		--Wait for one clock period
		wait for C_CLK_PERIOD;
		
		log(ID_LOG_HDR, "Check the symbol rate (throughtput) - no checks are performed.", C_SCOPE);
		
		start_time := now;
		
		--Try to extract the modulus and phase for each symbol
		for i in 0 to 100 loop
			rand_x := rnd_sym.rand(rand_x'length,b"00000000000000",b"11111111111111");
			rand_y := rnd_sym.rand(rand_y'length,b"00000000000000",b"11111111111111");
			
			write_input(rand_x,rand_y,"Write random symbol",clk,cordic_if,C_SCOPE,shared_msg_id_panel,CONFIG_IF);
			read_output(modulus_val,phase_val,"Read random symbol",clk,cordic_if,C_SCOPE,shared_msg_id_panel,CONFIG_IF);
		end loop;
		
		end_time := now;
		
		log(ID_LOG_HDR,"100 Symbols are detected in: "&to_string(end_time-start_time));
		
		log(ID_LOG_HDR, "Check minimum tollerance on module", C_SCOPE);
		
		--Disable BFM messages
		disable_log_msg(ID_BFM,C_SCOPE);
		
		for i in 100 downto 10 loop	-- set tollerance
			log(ID_LOG_HDR,"Set tollerance of "&to_string(real(i)/real(10)));
		
			disable_log_msg(ID_LOG_HDR,C_SCOPE);
		
			--For any tollerance test for 10 symbols
			for j in 0 to 10 loop
				rand_sym_x := rnd_sym.rand(-64.0,63.99);
				rand_sym_y := rnd_sym.rand(-64.0,63.99);
			
				write_cartesian(rand_sym_x,rand_sym_y,"Check tollerance",clk,cordic_if,C_SCOPE,shared_msg_id_panel,CONFIG_IF);
				read_cartesian(real_modulus,real_phase,"Check tollerance",clk,cordic_if,C_SCOPE,shared_msg_id_panel,CONFIG_IF);
			
				expected_modulus := sqrt(rand_sym_x**2+rand_sym_y**2);
				response := check_value_in_range(real_modulus,expected_modulus-(real(i)/real(10)),expected_modulus+(real(i)/real(10)),FAILURE,"Check on modulus",C_SCOPE,ID_LOG_HDR,shared_msg_id_panel);
				
				if response = false then
					enable_log_msg(ID_LOG_HDR);
					log(ID_LOG_HDR,"Test fail");
					disable_log_msg(ID_LOG_HDR);
					exit;
				end if;
			end loop;
			if response = false then
				enable_log_msg(ID_LOG_HDR);
				exit;
			else
				enable_log_msg(ID_LOG_HDR);
				log(ID_LOG_HDR,"Test pass");
				disable_log_msg(ID_LOG_HDR);
			end if;
			
			enable_log_msg(ID_LOG_HDR,C_SCOPE);
			
		end loop;
		
		--Reenable BFM messages
		enable_log_msg(ID_BFM,C_SCOPE);
		
		log(ID_LOG_HDR, "Check minimum tollerance on phase", C_SCOPE);
		
		--Disable BFM messages
		disable_log_msg(ID_BFM,C_SCOPE);
		
		for i in 10 downto 1 loop	-- set tollerance
			log(ID_LOG_HDR,"Set tollerance of "&to_string(real(i)/real(100))&"rad");
		
			disable_log_msg(ID_LOG_HDR,C_SCOPE);
		
			--For any tollerance test for 10 symbols
			for j in 0 to 10 loop
				rand_sym_x := rnd_sym.rand(-64.0,63.99);
				rand_sym_y := rnd_sym.rand(-64.0,63.99);
			
				write_cartesian(rand_sym_x,rand_sym_y,"Check tollerance",clk,cordic_if,C_SCOPE,shared_msg_id_panel,CONFIG_IF);
				read_cartesian(real_modulus,real_phase,"Check tollerance",clk,cordic_if,C_SCOPE,shared_msg_id_panel,CONFIG_IF);
			
				if rand_sym_y >= real(0) then
					expected_phase := arctan(rand_sym_y,rand_sym_x);
				else
					expected_phase := arctan(rand_sym_y,rand_sym_x)+real(2)*MATH_PI;
				end if;
			
				response := check_value_in_range(real_phase,expected_phase-(real(i)/real(100)),expected_phase+(real(i)/real(100)),FAILURE,"Check on phase",C_SCOPE,ID_LOG_HDR,shared_msg_id_panel);
				
				if response = false then
					enable_log_msg(ID_LOG_HDR);
					log(ID_LOG_HDR,"Test fail");
					disable_log_msg(ID_LOG_HDR);
					exit;
				end if;
			end loop;
			if response = false then
				exit;
			else
				enable_log_msg(ID_LOG_HDR);
				log(ID_LOG_HDR,"Test pass");
				disable_log_msg(ID_LOG_HDR);
			end if;
			
			enable_log_msg(ID_LOG_HDR,C_SCOPE);
			
		end loop;
		
		--Reenable BFM messages
		enable_log_msg(ID_BFM,C_SCOPE);
		
		--Ending Simulation
		wait for 1 us;
		report_alert_counters(FINAL);
		log(ID_LOG_HDR, "SIMULATION COMPLETED", C_SCOPE);
		
		--Halt simulator
		std.env.stop;
		wait;
	end process;
	
end  beh;


