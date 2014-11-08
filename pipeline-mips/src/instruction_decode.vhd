library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity instruction_decode is
	port
		(	clk             : std_logic
		;	reset           : std_logic
		;	write_data      : word_t
		;	instructions    : word_t
		;	write_register	: reg_t
		;	data_1			    : word_t
		;	data_2			    : word_t
		)
	;
end instruction_decode;

architecture Behavioral of instruction_decode is

begin


end Behavioral;

