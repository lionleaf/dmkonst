library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity instruction_fetch is
	port
			( clk							: in	std_logic
			; reset					 	: in	std_logic
			; processor_enable: in	std_logic
			; incremented_pc 	: out	addr_t
			; branch_adress		: in	addr_t
			; branch_en				: in 	std_logic
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
    , processor_enable  => processor_enable
		, branch_en         => branch_en  
		, branch_addr       => branch_adress
		, PC                => pc
		, incremented_PC    => incremented_pc
		)
	;

end Behavioral;

