library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.textio.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

package cordic_bfm_pkg is

	constant C_BFM_SCOPE : string :="CORDIC BFM";

	type t_cordic_if is record 
		x		: std_logic_vector;
		y		: std_logic_vector;      
		modulus : std_logic_vector;
		phase 	: std_logic_vector;	
		update_output	: std_logic;
		new_data : std_logic;
	end record;
	
	type t_cordic_bfm_config is record
		bfm_sync        : 	t_bfm_sync;		--Sync of BFM procedures
		id_for_bfm		:	t_msg_id;		--Message id used for BFM procedures
		clock_period	:	time;			--Clock periodd
		clock_period_margin        : time;               -- Input clock period margin
		clock_margin_severity      : t_alert_level;      -- The above margin will have this severity
		setup_time		:	time;			--Setup time for clock signal
		hold_time		:	time;			--Hold time for clock signal
		wait_num_cycle 	:	natural;		--number of cycles to Wait
											-- 0 for no further cycles
		wait_cycles_severity	:	t_alert_level;	--The above margin will have this severity
	end record;
	
	--Default configuration
	constant C_CORDIC_BFM_CONFIG_DEFAULT : t_cordic_bfm_config := (
		bfm_sync        		=> SYNC_ON_CLOCK_ONLY,
		id_for_bfm				=> ID_BFM,
		clock_period			=> C_UNDEFINED_TIME,
		clock_period_margin		=> C_UNDEFINED_TIME,   
		clock_margin_severity 	=> TB_ERROR,
		setup_time				=> C_UNDEFINED_TIME,
		hold_time				=> C_UNDEFINED_TIME,
		wait_num_cycle			=> 0,
		wait_cycles_severity	=> WARNING
	);
	
	-- Initialize the interface in a safe state
	-- all inputs are set to '0'
	-- all outputs are set to 'Z'
	function init_cordic_if(
		x_width			: natural;
		y_width			: natural;
		modulus_width	: natural;
		phase_width		: natural
	) return t_cordic_if;
	
	-- Write input to device synchronous with clock
	procedure write_input(
		constant x_value		: in std_logic_vector;	
		constant y_value		: in std_logic_vector;
		constant msg			: in string;
		signal clk				: in std_logic;
		signal cordic_if		: inout t_cordic_if;
		constant scope			: in string	:= C_BFM_SCOPE;
		constant msg_id_panel	: in t_msg_id_panel	:= shared_msg_id_panel;
		constant config			: in t_cordic_bfm_config := C_CORDIC_BFM_CONFIG_DEFAULT
	);
	
	procedure write_input(
		constant x_value		: in natural range 0 to 2**14-1;	
		constant y_value		: in natural range 0 to 2**14-1;
		constant msg			: in string;
		signal clk				: in std_logic;
		signal cordic_if		: inout t_cordic_if;
		constant scope			: in string	:= C_BFM_SCOPE;
		constant msg_id_panel	: in t_msg_id_panel	:= shared_msg_id_panel;
		constant config			: in t_cordic_bfm_config := C_CORDIC_BFM_CONFIG_DEFAULT
	);
	
	-- Read all bus signals
	procedure read_output(
		variable modulus_value	: out std_logic_vector;	
		variable phase_value	: out std_logic_vector;
		constant msg			: in string;
		signal clk				: in std_logic;
		signal cordic_if				: in t_cordic_if;
		constant scope			: in string	:= C_BFM_SCOPE;
		constant msg_id_panel	: in t_msg_id_panel	:= shared_msg_id_panel;
		constant config			: in t_cordic_bfm_config := C_CORDIC_BFM_CONFIG_DEFAULT;
		constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
	);
	
	procedure read_output(
		variable modulus_value	: out integer range 0 to 2**16-1;
		variable phase_value	: out integer range 0 to 2**16-1;
		constant msg			: in string;
		signal clk				: in std_logic;
		signal cordic_if		: in t_cordic_if;
		constant scope			: in string	:= C_BFM_SCOPE;
		constant msg_id_panel	: in t_msg_id_panel	:= shared_msg_id_panel;
		constant config			: in t_cordic_bfm_config := C_CORDIC_BFM_CONFIG_DEFAULT;
		constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
	);	
	
	procedure write_cartesian(
		constant x_value		: in real;	
		constant y_value		: in real;
		constant msg			: in string;
		signal clk				: in std_logic;
		signal cordic_if		: inout t_cordic_if;
		constant scope			: in string	:= C_BFM_SCOPE;
		constant msg_id_panel	: in t_msg_id_panel	:= shared_msg_id_panel;
		constant config			: in t_cordic_bfm_config := C_CORDIC_BFM_CONFIG_DEFAULT
	);
	
	procedure read_cartesian(
		variable modulus_value	: out real;	
		variable phase_value	: out real;
		constant msg			: in string;
		signal clk				: in std_logic;
		signal cordic_if		: in t_cordic_if;
		constant scope			: in string	:= C_BFM_SCOPE;
		constant msg_id_panel	: in t_msg_id_panel	:= shared_msg_id_panel;
		constant config			: in t_cordic_bfm_config := C_CORDIC_BFM_CONFIG_DEFAULT;
		constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
	);
	
end package cordic_bfm_pkg;

package body cordic_bfm_pkg is
	function init_cordic_if(
		x_width			: natural;
		y_width			: natural;
		modulus_width	: natural;
		phase_width		: natural
	) return t_cordic_if is
		variable result	: t_cordic_if(x(x_width-1 downto 0),
									  y(y_width-1 downto 0),
									  modulus(modulus_width-1 downto 0),
									  phase(phase_width-1 downto 0));
	begin
		result.x := (result.x'range => '0');
	    result.y := (result.y'range => '0');
	    result.modulus := (result.modulus'range => 'Z');
	    result.phase := (result.phase'range => 'Z');
		result.update_output := 'Z';
		result.new_data := '0';
		return result;
	end function;
	
	procedure write_input(
		constant x_value		: in std_logic_vector;	
		constant y_value		: in std_logic_vector;
		constant msg			: in string;
		signal clk				: in std_logic;
		signal cordic_if		: inout t_cordic_if;
		constant scope			: in string	:= C_BFM_SCOPE;
		constant msg_id_panel	: in t_msg_id_panel	:= shared_msg_id_panel;
		constant config			: in t_cordic_bfm_config := C_CORDIC_BFM_CONFIG_DEFAULT
	) is
	
	variable normalised_x      : std_logic_vector(cordic_if.x'length - 1 downto 0) := normalize_and_check(x_value, cordic_if.x, ALLOW_NARROWER, "x value", "x bus width", msg);
    variable normalised_y      : std_logic_vector(cordic_if.y'length - 1 downto 0) := normalize_and_check(y_value, cordic_if.y, ALLOW_NARROWER, "y value", "y bus width", msg);
	constant proc_call		   : string := "write_input(X: "&to_string(x_value,BIN,KEEP_LEADING_0,INCL_RADIX) & ", Y: "&to_string(y_value,BIN,KEEP_LEADING_0,INCL_RADIX) & ")";
	
	variable v_time_of_rising_edge  : time                                        := C_UNDEFINED_TIME; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                        := C_UNDEFINED_TIME; -- time stamp for clk period checking
	
	begin
		if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
			check_value(config.clock_period /= C_UNDEFINED_TIME, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, proc_call);
			check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time don't exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
			check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time don't exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
		end if;
		-- Wait according to config.bfm_sync setup
		wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
		
		cordic_if.x <=normalised_x;
		cordic_if.y <=normalised_y;
		cordic_if.new_data<='1';
		
		--wait the  next rising edge of clock before exit exit
		wait until rising_edge(clk);
		
		check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, config.clock_period, config.clock_period_margin, config.clock_margin_severity);
		
		
		-- Wait according to config.bfm_sync setup
		wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);
		
		cordic_if.new_data<='0';
		log(config.id_for_bfm, proc_call & " completed." & add_msg_delimiter(msg), scope, msg_id_panel);
	end procedure;
	
	procedure write_input(
		constant x_value		: in natural range 0 to 2**14-1;	
		constant y_value		: in natural range 0 to 2**14-1;
		constant msg			: in string;
		signal clk				: in std_logic;
		signal cordic_if		: inout t_cordic_if;
		constant scope			: in string	:= C_BFM_SCOPE;
		constant msg_id_panel	: in t_msg_id_panel	:= shared_msg_id_panel;
		constant config			: in t_cordic_bfm_config := C_CORDIC_BFM_CONFIG_DEFAULT
	) is
		variable v_normalized_x	: std_logic_vector(cordic_if.x'length-1 downto 0) := normalize_and_check(std_logic_vector(to_unsigned(x_value,cordic_if.x'length)),cordic_if.x,ALLOW_NARROWER,"integer input (x)","binary output (x)","Conversion from integer to binary");
		variable v_normalized_y	: std_logic_vector(cordic_if.y'length-1 downto 0) := normalize_and_check(std_logic_vector(to_unsigned(y_value,cordic_if.y'length)),cordic_if.y,ALLOW_NARROWER,"integer input (y)","binary output (y)","Conversion from integer to binary");
		
		constant proc_call		   : string := "write_input(X: "&to_string(x_value)&", Y: "&to_string(y_value)& ")";
	begin
		log(config.id_for_bfm, proc_call & "." & add_msg_delimiter(msg), scope, msg_id_panel);
    	write_input(v_normalized_x,v_normalized_y,msg,clk,cordic_if,scope,msg_id_panel,config);
	end procedure;
	
	procedure write_cartesian(
		constant x_value		: in real;	
		constant y_value		: in real;
		constant msg			: in string;
		signal clk				: in std_logic;
		signal cordic_if		: inout t_cordic_if;
		constant scope			: in string	:= C_BFM_SCOPE;
		constant msg_id_panel	: in t_msg_id_panel	:= shared_msg_id_panel;
		constant config			: in t_cordic_bfm_config := C_CORDIC_BFM_CONFIG_DEFAULT
	) is
		variable v_x	: integer;
		variable v_y	: integer;
		
		variable temp_x : real;
		variable temp_y : real;
		
		constant proc_call		   : string := "write_cartesian(X: "&to_string(x_value)&", Y: "&to_string(y_value)& ")";
	
	begin
		check_value_in_range(x_value,real(-64),real(63.99),TB_ERROR,"x value is out of dynamic", scope, ID_NEVER, msg_id_panel);
		check_value_in_range(y_value,real(-64),real(63.99),TB_ERROR,"y value is out of dynamic", scope, ID_NEVER, msg_id_panel);
		
		if x_value< real(0) then
			temp_x := x_value + real(128); 
		else
			temp_x := x_value;
		end if;
		
		if y_value< real(0) then
			temp_y := y_value + real(128); 
		else
			temp_y := y_value;
		end if;
		
		v_x :=	integer(real(temp_x)*real(2**(7)));
		v_y :=	integer(real(temp_y)*real(2**(7)));
		
		log(config.id_for_bfm, proc_call & "." & add_msg_delimiter(msg), scope, msg_id_panel);
    	write_input(v_x,v_y,msg,clk,cordic_if,scope,msg_id_panel,config);
	end procedure;
	
	procedure read_output(
		variable modulus_value	: out std_logic_vector;	
		variable phase_value	: out std_logic_vector;
		constant msg			: in string;
		signal clk				: in std_logic;
		signal cordic_if		: in t_cordic_if;
		constant scope			: in string	:= C_BFM_SCOPE;
		constant msg_id_panel	: in t_msg_id_panel	:= shared_msg_id_panel;
		constant config			: in t_cordic_bfm_config := C_CORDIC_BFM_CONFIG_DEFAULT;
		constant ext_proc_call	: in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
	) is
	
	constant proc_call		   : string := "read_output()";
	constant local_proc_name : string := "read_output";
    constant local_proc_call : string := local_proc_name;
	
	variable v_time_of_rising_edge  : time                                        := C_UNDEFINED_TIME; -- time stamp for clk period checking
    variable v_time_of_falling_edge : time                                        := C_UNDEFINED_TIME; -- time stamp for clk period checking
	
	variable v_proc_call            : line;
    
	variable v_modulus_value  			: std_logic_vector(cordic_if.modulus'length-1 downto 0);
	variable v_phase_value  			: std_logic_vector(cordic_if.phase'length-1 downto 0);
	 
	begin
		if config.bfm_sync = SYNC_WITH_SETUP_AND_HOLD then
			check_value(config.clock_period /= C_UNDEFINED_TIME, TB_FAILURE, "Sanity check: Check that clock_period is set.", scope, ID_NEVER, msg_id_panel, proc_call);
			check_value(config.setup_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that setup_time don't exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
			check_value(config.hold_time < config.clock_period / 2, TB_FAILURE, "Sanity check: Check that hold_time don't exceed clock_period/2.", scope, ID_NEVER, msg_id_panel, proc_call);
		end if;
		
		if ext_proc_call = "" then
			-- Called directly from sequencer/VVC, log 'sbi_read...'
			write(v_proc_call, local_proc_call);
		else
			-- Called from another BFM procedure, log 'ext_proc_call while executing sbi_read...'
			write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
		end if;
		
		-- Wait according to config.bfm_sync setup
		wait_on_bfm_sync_start(clk, config.bfm_sync, config.setup_time, config.clock_period, v_time_of_falling_edge, v_time_of_rising_edge);
		
		--Wait established number of cycles
		for i in 0 to config.wait_num_cycle loop
			wait until rising_edge(clk);
			check_clock_period_margin(clk, config.bfm_sync, v_time_of_falling_edge, v_time_of_rising_edge, config.clock_period, config.clock_period_margin, config.clock_margin_severity);
			if cordic_if.update_output = '1' then
				exit;
			end if;
		end loop;
		
		if cordic_if.update_output = '0' then
			alert(config.wait_cycles_severity,"Attempt to read output when update_output is not high.",scope);
		end if;
		--acquire data
		v_modulus_value := cordic_if.modulus;
		v_phase_value := cordic_if.phase;
		
		modulus_value := v_modulus_value;
		phase_value := v_phase_value;
		
		-- Wait according to config.bfm_sync setup
		wait_on_bfm_exit(clk, config.bfm_sync, config.hold_time, v_time_of_falling_edge, v_time_of_rising_edge);

		if ext_proc_call = "" then
			log(config.id_for_bfm, v_proc_call.all & "=> (modulus: " & to_string(v_modulus_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ", phase: " & to_string(v_phase_value, HEX, SKIP_LEADING_0, INCL_RADIX) & ")" & add_msg_delimiter(msg), scope, msg_id_panel);
		else
			-- Log will be handled by calling procedure (e.g. sbi_check)
		end if;
		
		DEALLOCATE(v_proc_call);
	end procedure;
	
	procedure read_output(
		variable modulus_value	: out integer range 0 to 2**16-1;	
		variable phase_value	: out integer range 0 to 2**16-1;
		constant msg			: in string;
		signal clk				: in std_logic;
		signal cordic_if		: in t_cordic_if;
		constant scope			: in string	:= C_BFM_SCOPE;
		constant msg_id_panel	: in t_msg_id_panel	:= shared_msg_id_panel;
		constant config			: in t_cordic_bfm_config := C_CORDIC_BFM_CONFIG_DEFAULT;
		constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
	) is
	
	variable v_modulus_value  	: std_logic_vector(cordic_if.modulus'length-1 downto 0);
	variable v_phase_value  	: std_logic_vector(cordic_if.phase'length-1 downto 0);
	
	constant local_proc_name : string := "read_output";
    constant local_proc_call : string := local_proc_name;
	constant proc_call		   : string := "read_output()";
	
	variable v_proc_call            : line;
    
	begin
		--acquire data from bus
		read_output(v_modulus_value,v_phase_value,msg,clk,cordic_if,scope,msg_id_panel,config, ext_proc_call);
		
		modulus_value := to_integer(unsigned(v_modulus_value));
		phase_value := to_integer(unsigned(v_phase_value));
		
		--Print converted values
		if ext_proc_call = "" then
			-- Called directly from sequencer/VVC, log 'sbi_read...'
			write(v_proc_call, local_proc_call);
		else
			-- Called from another BFM procedure, log 'ext_proc_call while executing sbi_read...'
			write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
		end if;
		
		if ext_proc_call = "" then
			log(config.id_for_bfm, v_proc_call.all & "=> (modulus: " & to_string(modulus_value)&", phase:"&to_string(phase_value)&")" & add_msg_delimiter(msg), scope, msg_id_panel);
		else
			-- Log will be handled by calling procedure (e.g. sbi_check)
		end if;
		DEALLOCATE(v_proc_call);
	end procedure;
	
	procedure read_cartesian(
		variable modulus_value	: out real;	
		variable phase_value	: out real;
		constant msg			: in string;
		signal clk				: in std_logic;
		signal cordic_if		: in t_cordic_if;
		constant scope			: in string	:= C_BFM_SCOPE;
		constant msg_id_panel	: in t_msg_id_panel	:= shared_msg_id_panel;
		constant config			: in t_cordic_bfm_config := C_CORDIC_BFM_CONFIG_DEFAULT;
		constant ext_proc_call : in string           := "" -- External proc_call. Overwrite if called from another BFM procedure
	) is
	
	variable v_modulus_value  	:natural;
	variable v_phase_value  	:natural;
	
	variable final_modulus		: real;
	variable final_phase			: real;
	
	constant local_proc_name : string := "read_cartesian";
    constant local_proc_call : string := local_proc_name;
	constant proc_call		 : string := "read_cartesian()";
	
	variable v_proc_call            : line;
    
	begin
		--acquire data from bus
		read_output(v_modulus_value,v_phase_value,msg,clk,cordic_if,scope,msg_id_panel,config, ext_proc_call);
		
		final_modulus := real(v_modulus_value)/real(2**8)/real(1.647);	
		final_phase	:= real(v_phase_value)*real(2)*MATH_PI/real(2**(16));
		
		--Update output parameters
		modulus_value := final_modulus;
		phase_value := final_phase; 
		
		--Print converted values
		if ext_proc_call = "" then
			-- Called directly from sequencer/VVC, log 'sbi_read...'
			write(v_proc_call, local_proc_call);
		else
			-- Called from another BFM procedure, log 'ext_proc_call while executing sbi_read...'
			write(v_proc_call, ext_proc_call & " while executing " & local_proc_name);
		end if;
		
		if ext_proc_call = "" then
			log(config.id_for_bfm, v_proc_call.all & "=> (modulus: " & to_string(final_modulus)&", phase:"&to_string(final_phase)&" rad)" & add_msg_delimiter(msg), scope, msg_id_panel);
		else
			-- Log will be handled by calling procedure (e.g. sbi_check)
		end if;
		DEALLOCATE(v_proc_call);
	end procedure;
end package body; 