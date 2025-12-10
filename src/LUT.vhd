library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;	 
--LUT store the value of atan 


entity LUT_16x16 is
	port(
		addr	: in std_ulogic_vector(3 downto 0);			--address
		data	: out std_ulogic_vector (15 downto 0)		--data out
	);
end LUT_16x16;

architecture rtl of LUT_16x16 is
	signal addr_int	: integer range 0 to 15;
	--a LUT is a new data type
	type lut_t is array (0 to 15) of std_ulogic_vector (15 downto 0);
	--LUT entries are "bare-metal" in the VHDL code, values are obtained from the matlab
	--script "lut.m"
	constant lut : lut_t := ("0010000000000000", "0001001011100100", "0000100111111011", "0000010100010001", "0000001010001011",
							 "0000000101000110", "0000000010100011", "0000000001010001", "0000000000101001", "0000000000010100",
							 "0000000000001010", "0000000000000101", "0000000000000011", "0000000000000001", "0000000000000001",
							 "0000000000000000"); 			
begin			
	addr_int <= TO_INTEGER(unsigned(addr));
	data <= lut(addr_int); 				
end rtl;		

