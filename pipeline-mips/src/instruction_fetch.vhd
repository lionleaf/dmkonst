		library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity instruction_fetch is
	port
			( clk							: in	std_logic
			; reset					 	: in	std_logic
			; incremented_pc 			: out	addr_t
			; branch_adress			: in	addr_t
			; pc_source					: in 	std_logic
			; pc							: out	addr_t
			)
		;
end instruction_fetch;
architecture Behavioral of instruction_fetch is



begin

program_counter:
	entity work.pc
	port map
		( reset             => reset
		, clk               => clk
		, pc_source         => pc_source  
		, branch_addr       => branch_adress
		, PC                => pc
		, incremented_PC    => incremented_pc
		)
	;

end Behavioral;

