library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity execute is
	port
		( incremented_pc	: in		addr_t
		; data_1				: in		word_t
		; data_2				: in		word_t
		; instructions  	: in 		word_t
		; alu_source		: in 		std_logic
		; alu_operation	: in 		alu_funct_t
		; alu_result		: out 	word_t
		; alu_zero			: out		std_logic
		; branch_address	: out		addr_t
		)
	;
end execute;

architecture Behavioral of execute is

	alias immediate			: std_logic_vector(15 downto 0) is instructions(15 downto 0);
	signal operand_right		: word_t;
	signal alu_result_buffer: signed (31 downto 0) := to_signed(0, 32);

begin
	

	
	branch_address_select:
		entity work.branch_address_select
		port map
			( operand_left    => incremented_pc 
			, operand_right   => immediate(7 downto 0) 
			, result				=> branch_address
			)
		;
		
	alu:
		entity work.alu
		port map
			( operand_left   => signed(data_1)
			, operand_right  => signed(operand_right)
			, operator       => alu_operation
			, result_is_zero => alu_zero
			, result			  => alu_result_buffer
			)
		;
    
  operand_right <= std_logic_vector(resize(signed(immediate), 32)) when alu_source = '1'
				else	 data_2;

	alu_result <= std_logic_vector(alu_result_buffer);
		
		
	
end Behavioral;