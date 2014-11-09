library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity execute_stage is

    port
        ( decode_execute_pipe : in     decode_execute_pipe_t
        ; reg_val_rs          : in     word_t
        ; reg_val_rt          : in     word_t

        ; execute_memory_pipe : buffer execute_memory_pipe_t
        );

end execute_stage;

architecture rtl of execute_stage is

    signal operand_right : word_t;

begin

    -- Propagate control signals:
    execute_memory_pipe.branch_en  <= decode_execute_pipe_t.branch_en;
    execute_memory_pipe.mem_wen    <= decode_execute_pipe_t.mem_wen;
    execute_memory_pipe.mem_to_reg <= decode_execute_pipe_t.mem_to_reg;
    execute_memory_pipe.reg_wen    <= decode_execute_pipe_t.reg_wen;

    execute_memory_pipe.write_data <= reg_val_rt;

    -- Compute branch address:
    execute_memory_pipe.branch_addr <= std_logic_vector(
                                signed(decode_execute_pipe.pc_succ) + signed(imm_val));

    -- This mux serves to direct the immediate value trough the alu-path
    -- when loading an immediate to a register.
    operand_right <= imm_val when decode_execute_pipe.inst_type_I
                else reg_val_rt;

    -- Select appropriate destination-register-specification, depending
    -- on whether the current instruciton is I-type or R-type. Don't care
    -- for the J-type.
    execute_memory_pipe.reg_dst <= reg_rt when decode_execute_pipe.inst_type_I
                              else reg_rd;

	alu:
		entity work.alu
            port map
                ( operand_left   => signed(reg_val_rs)
                , operand_right  => signed(operand_right)
                , operator       => decode_execute_pipe.alu_funct
                , result_is_zero => execute_memory_pipe.alu_zero
                , result         => execute_memory_pipe.alu_result
                );

end rtl;
