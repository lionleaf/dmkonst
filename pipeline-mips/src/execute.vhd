library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity execute is
	port
		( clk					: std_logic
		; reset				: std_logic
		; incremented_pc	: addr_t
		; data_1				: std_logic_vector (31 downto 0)
		; data_2				: std_logic_vector (31 downto 0)
		; instructions		: std_logic_vector (31 downto 0)
		; alu_source		: std_logic
		; alu_operation	: alu_funct_t
		; alu_result		: signed (data_width - 1 downto 0) := to_signed(0, data_width)
		; alu_zero			: boolean := true
		; branch_address	: addr_t
		)
	;
end execute;

architecture Behavioral of execute is

begin


end Behavioral;

