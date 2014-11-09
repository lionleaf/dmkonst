library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity writeback_stage is

    port
        ( mem_writeback_pipe : in     mem_writeback_pipe_t
        ; mem_read_data      : in     word_t

        ; reg_w_data         : buffer word_t
        );

end writeback_stage;

architecture rtl of writeback_stage is

begin

    -- Choose the source of register-write based on whether we
    -- are doing a memory read.
    reg_w_data <= mem_read_data when mem_writeback_pipe.mem_to_reg = '1'
             else mem_writeback_pipe.alu_result;

end rtl;
