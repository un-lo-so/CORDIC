vlib .\sim
vmap CORDIC .\sim

vcom -2008 -work CORDIC .\src\LUT.vhd
vcom -2008 -work CORDIC .\src\flip_flop.vhd
vcom -2008 -work CORDIC .\src\full_adder.vhd
vcom -2008 -work CORDIC .\src\rca_generic.vhd
vcom -2008 -work CORDIC .\src\register.vhd
vcom -2008 -work CORDIC .\src\shift_register.vhd
vcom -2008 -work CORDIC .\src\msf.vhd
vcom -2008 -work CORDIC .\src\cordic_A.vhd
vcom -2008 -work CORDIC .\src\cordic_B.vhd
vcom -2008 -work CORDIC .\src\cordic.vhd
vcom -2008 -work CORDIC .\src\cordic_wrapper.vhd

vcom -2008 -work CORDIC .\tb\tb_adder_subtractor.vhd
vcom -2008 -work CORDIC .\tb\tb_ffd.vhd
vcom -2008 -work CORDIC .\tb\tb_reg.vhd
vcom -2008 -work CORDIC .\tb\tb_shifter.vhd
vcom -2008 -work CORDIC .\tb\tb_msf.vhd
vcom -2008 -work CORDIC .\tb\tb_cordicA.vhd
vcom -2008 -work CORDIC .\tb\tb_cordicB.vhd

vcom -2008 -work CORDIC .\tb\td_cordic.vhd

vlib .\uvvm_util\sim
vlib .\uvvm_vvc_framework\sim
vlib .\bitvis_vip_scoreboard\sim
vlib .\bitvis_vip_clock_generator\sim
vlib .\CORDIC_VVC\sim

vmap uvvm_util .\uvvm_util\sim
vmap uvvm_vvc_framework .\uvvm_vvc_framework\sim
vmap uvvm_vip_scoreboard .\bitvis_vip_scoreboard\sim
vmap uvvm_vip_clock_generator .\bitvis_vip_clock_generator\sim
vmap cordic_vvc .\CORDIC_VVC\sim

vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\types_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\adaptations_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\string_methods_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\protected_types_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\global_signals_and_shared_variables_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\hierarchy_linked_list_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\alert_hierarchy_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\license_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\methods_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\bfm_common_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\generic_queue_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\data_queue_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\data_fifo_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\data_stack_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\dummy_rand_extension_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\rand_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\dummy_func_cov_extension_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\association_list_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\func_cov_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\uvvm_util_context.vhd

vcom -suppress 1346,1236,1090 -2008 -work uvvm_util .\uvvm_util\src\uvvm_util_context.vhd

vcom -suppress 1346,1236,1090 -2008 -work uvvm_vvc_framework .\uvvm_vvc_framework\src\ti_protected_types_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vvc_framework .\uvvm_vvc_framework\src\ti_vvc_framework_support_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vvc_framework .\uvvm_vvc_framework\src\ti_generic_queue_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vvc_framework .\uvvm_vvc_framework\src\ti_data_queue_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vvc_framework .\uvvm_vvc_framework\src\ti_data_fifo_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vvc_framework .\uvvm_vvc_framework\src\ti_data_stack_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vvc_framework .\uvvm_vvc_framework\src\ti_uvvm_engine.vhd

vcom -suppress 1346,1236,1090 -2008 -work uvvm_vip_scoreboard .\bitvis_vip_scoreboard\src\generic_sb_support_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vip_scoreboard .\bitvis_vip_scoreboard\src\generic_sb_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vip_scoreboard .\bitvis_vip_scoreboard\src\predefined_sb.vhd

vcom -suppress 1346,1236,1090 -2008 -work uvvm_vip_clock_generator .\bitvis_vip_clock_generator\src\vvc_cmd_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vip_clock_generator .\bitvis_vip_clock_generator\..\uvvm_vvc_framework\src_target_dependent\td_target_support_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vip_clock_generator .\bitvis_vip_clock_generator\..\uvvm_vvc_framework\src_target_dependent\td_vvc_framework_common_methods_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vip_clock_generator .\bitvis_vip_clock_generator\src\vvc_methods_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vip_clock_generator .\bitvis_vip_clock_generator\..\uvvm_vvc_framework\src_target_dependent\td_queue_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vip_clock_generator .\bitvis_vip_clock_generator\..\uvvm_vvc_framework\src_target_dependent\td_vvc_entity_support_pkg.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vip_clock_generator .\bitvis_vip_clock_generator\src\clock_generator_vvc.vhd
vcom -suppress 1346,1236,1090 -2008 -work uvvm_vip_clock_generator .\bitvis_vip_clock_generator\src\vvc_context.vhd

vcom -2008 -work cordic_vvc .\CORDIC_VVC\src\cordic_bfm_pkg.vhd

vcom -2008 -work CORDIC .\tb\td_cordic_simple_bfm.vhd
