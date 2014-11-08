library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity execute is
	port
		( clk					: std_logic
		; reset				: std_logic
		; incremented_pc	: addr_t
		; data_1				: word_t
		; data_2				: word_t
		; instructions  : word_t
		; alu_source		: std_logic
		; alu_operation	: alu_funct_t
		; alu_result		: word_t
		; alu_zero			: std_logic
		; branch_address	: addr_t
		)
	;
end execute;

architecture Behavioral of execute is

begin


end Behavioral;

