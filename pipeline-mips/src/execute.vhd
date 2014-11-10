library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity execute is
	port
		( incremented_pc: in		addr_t
		; data_1				: in		word_t
		; data_2				: in		word_t
		; instruction  : in 		word_t
		; inst_type_I		: in 		std_logic
		; imm_to_alu		: in 		std_logic
		; alu_funct	    : in 		alu_funct_t
		; alu_shamt     : in 		alu_funct_t
		; alu_result		: out 	word_t
		; alu_zero			: out		std_logic
		; branch_address: out		addr_t
		; write_reg_dst	: out		reg_t
		)
	;
end execute;

architecture Behavioral of execute is

	alias immediate			: std_logic_vector(15 downto 0) is instruction(15 downto 0);
	signal operand_right		  : word_t;
	signal immediate_extended : word_t;

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
			( operand_left   => data_1
			, operand_right  => operand_right
			, operator       => alu_funct
			, result_is_zero => alu_zero
			, result			   => alu_result
			, shamt          => alu_shamt
			)
		;
    
    immediate_extended <= std_logic_vector(resize(signed(immediate), 32));
    operand_right <= immediate_extended when imm_to_alu = '1'
				else	 data_2;

  write_reg_dst <=  instruction(20 downto 16) when inst_type_I = '1'
              else  instruction(15 downto 11);
		
	
end Behavioral;