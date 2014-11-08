library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity instruction_fetch is
	port
			( clk							: std_logic
			; reset					 	: std_logic
			; incremented_pc 	: addr_t
			; branch_adress		: addr_t
			; pc_source				: std_logic
			; instructions		: word_t
			)
		;
end instruction_fetch;
architecture Behavioral of instruction_fetch is

begin


end Behavioral;

