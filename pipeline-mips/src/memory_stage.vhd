library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity memory_stage is

    port
        ( execute_memory_pipe : in     execute_memory_pipe_t

        ; mem_writeback_pipe  : buffer mem_writeback_pipe_t
        ; branch              : buffer std_logic
        ; mem_read_data       : buffer word_t

        ; dmem_data_in        : in     word_t
        ; dmem_address        : buffer word_t
        ; dmem_data_out       : buffer word_t
        ; dmem_write_enable   : buffer std_logic
        );

end memory_stage;

architecture rtl of memory_stage is

begin

    -- Propagate control signals:
    mem_writeback_pipe.mem_to_reg <= execute_memory_pipe.mem_to_reg;
    mem_writeback_pipe.reg_wen    <= execute_memory_pipe.reg_wen;

    -- Propagate other signals:
    mem_writeback_pipe.reg_dst    <= execute_memory_pipe.reg_dst;
    mem_writeback_pipe.alu_result <= execute_memory_pipe.alu_result;

    -- Check if condition is right for branching:
    branch <= execute_memory_pipe.branch_en and execute_memory_pipe.alu_zero;

    -- Hook up signals to memroy:
    mem_read_data     <= dmem_data_in;
    dmem_address      <= execute_memory_pipe.alu_result;
    dmem_data_out     <= execute_memory_pipe.write_data;
    dmem_write_enable <= execute_memory_pipe.mem_wen;

end rtl;
