library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity execute is
	port
		( clk					: in	std_logic
		; reset				: in	std_logic
		; incremented_pc	: in	addr_t
		; data_1				: in	word_t
		; data_2				: in	word_t
		; instructions  	: in 	word_t
		; alu_source		: in 	std_logic
		; alu_operation	: in 	alu_funct_t
		; alu_result		: out	word_t
		; alu_zero			: out	std_logic
		; branch_address	: out	addr_t
		)
	;
end execute;

architecture Behavioral of execute is

	alias immediate		: std_logic_vector(15 downto 0) is instructions(15 downto 0);
	signal right_oprand	: word_t;

begin
	
	right_oprand <= immediate when alu_source = '1'
				else	 data_2;
	
	branch_address_select:
		entity work.branch_address_select
		port map
			( left_oprand   => incremented_pc 
			, right_oprand  => immediate 
			, result        => branch_address
			)
		;
		
	alu:
		entity work.alu
		port map
			( operand_left   => data_1
			, operand_right  => right_oprand
			, operator       => alu_operation
			, result_is_zero => alu_zero
			, result         => alu_result
			)
		;
	
end Behavioral;