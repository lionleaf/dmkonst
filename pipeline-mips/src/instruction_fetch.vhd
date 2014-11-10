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
			; branch_addr		: in	addr_t
			; branch_en				: in 	std_logic
			; insert_stall  	: in 	std_logic
			; pc							: out	addr_t
			)
		;
end instruction_fetch;
architecture Behavioral of instruction_fetch is
    signal PC_i    : addr_t := (others => '0');
    signal incremented_PC_i : addr_t;
    signal next_PC : addr_t;
begin

    PC <= PC_i;
    incremented_PC <= incremented_PC_i;
    
    incremented_PC_i <= std_logic_vector(resize(unsigned(PC_i) + 1, 8));
    
    next_PC <=  branch_addr       when branch_en = '1'
           else incremented_PC_i;

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                PC_i <= (others => '1'); --Will wrap around to 0 when processor enable is set.
            elsif processor_enable = '1' and insert_stall = '0' then
                PC_i <= next_PC;
            end if;
        end if;
    end process;
end Behavioral;

