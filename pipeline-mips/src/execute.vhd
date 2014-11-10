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

        -- Forwarded data
        ; forwarded_data_ex_mem : in  word_t
        ; forwarded_data_mem_wb : in  word_t

        -- Control signals for forwarding
        ; data_1_forward_ex_mem_en : in std_logic
        ; data_2_forward_ex_mem_en : in std_logic
        ; data_1_forward_mem_wb_en : in std_logic
        ; data_2_forward_mem_wb_en : in std_logic
		)
	;
end execute;

architecture Behavioral of execute is

	alias immediate			: std_logic_vector(15 downto 0) is instruction(15 downto 0);
	signal operand_right		  : word_t;
	signal immediate_extended : word_t;

    signal forwarded_data_1 : word_t;
    signal forwarded_data_2 : word_t;

begin

    forwarding_muxes:
        process ( data_1
                , data_2
                , forwarded_data_mem_wb
                , forwarded_data_ex_mem
                , data_1_forward_ex_mem_en
                , data_2_forward_ex_mem_en
                , data_1_forward_mem_wb_en
                , data_2_forward_mem_wb_en
                )
        begin

            forwarded_data_1 <= data_1;

            if data_1_forward_mem_wb_en = '1' then
                forwarded_data_1 <= forwarded_data_mem_wb;
            end if;

            -- Forwarding from ex_mem takes precedence, as it is fresher.
            if data_1_forward_ex_mem_en = '1' then
                forwarded_data_1 <= forwarded_data_ex_mem;
            end if;


            forwarded_data_2 <= data_2;

            if data_2_forward_mem_wb_en = '1' then
                forwarded_data_2 <= forwarded_data_mem_wb;
            end if;

            -- Forwarding from ex_mem takes precedence, as it is fresher.
            if data_2_forward_ex_mem_en = '1' then
                forwarded_data_2 <= forwarded_data_ex_mem;
            end if;

        end process;

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
			( operand_left   => forwarded_data_1
			, operand_right  => operand_right
			, operator       => alu_funct
			, result_is_zero => alu_zero
			, result			   => alu_result
			, shamt          => alu_shamt
			)
		;
    
    immediate_extended <= std_logic_vector(resize(signed(immediate), 32));
    operand_right <= immediate_extended when imm_to_alu = '1'
				else forwarded_data_2;

  write_reg_dst <=  instruction(20 downto 16) when inst_type_I = '1'
              else  instruction(15 downto 11);
		
	
end Behavioral;
