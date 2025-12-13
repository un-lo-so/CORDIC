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

vcom -2008 -work CORDIC .\tb\tb_adder_subtractor.vhd
vcom -2008 -work CORDIC .\tb\tb_ffd.vhd
vcom -2008 -work CORDIC .\tb\tb_reg.vhd
vcom -2008 -work CORDIC .\tb\tb_shifter.vhd
vcom -2008 -work CORDIC .\tb\tb_msf.vhd
vcom -2008 -work CORDIC .\tb\tb_cordicA.vhd
vcom -2008 -work CORDIC .\tb\tb_cordicB.vhd

vcom -2008 -work CORDIC .\tb\td_cordic.vhd
