library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity processor is

    port
        ( clk, reset        : in     std_logic
        ; processor_enable  : in     std_logic

        ; imem_data_in      : in     word_t
        ; imem_address      : buffer addr_t

        ; dmem_data_in      : in     word_t
        ; dmem_address      : buffer addr_t
        ; dmem_data_out     : buffer word_t
        ; dmem_write_enable : buffer std_logic
        );

end processor;

architecture Behavioral of processor is

    -- Pipeline signals:
    signal fetch_decode_pipe   : fetch_decode_pipe_t;
    signal decode_execute_pipe : decode_execute_pipe_t;
    signal execute_memory_pipe : execute_memory_pipe_t;
    signal mem_writeback_pipe  : mem_writeback_pipe_t;

    -- Forward non-flipfloped signals;
    signal inst : inst_t;
    signal reg_val_rs : word_t;
    signal reg_val_rt : word_t;

    -- Backward-flow signals:
    signal branch     : std_logic;
    signal reg_w_data : std_logic;

begin

    -- Propagate data and control along the pipeline.
    pipe_propagation:
        process (clock) begin
            if rising_edge(clock) then
                -- todo: add reset
                pipe_decode    <= pipe_fetch;
                pipe_execute   <= pipe_decode;
                pipe_memory    <= pipe_execute;
                pipe_writeback <= pipe_memory;
            end if;
        end process;

	-- Instantiate entities for the stages in the pipeline. 

    fetch_stage:
        entity work.fetch_stage
            port map
                ( clk      => clk
                , reset    => reset
                -- Memory
                , imem_data_in => imem_data_in
                , imem_address => imem_address
                -- Input
                , branch      => branch
                , branch_addr => execute_memory_pipe.branch_addr
                -- Output
                , fetch_decode_pipe => fetch_decode_pipe
                , inst => inst
                );

	decode_stage:
		entity work.decode_stage
            port map
                ( clk         => clk
                , reset       => reset
                -- Input
                , fetch_decode_pipe => fetch_decode_pipe
                , inst => inst
                , reg_wen => mem_writeback_pipe.reg_wen
                , reg_dst => mem_writeback_pipe.reg_dst
                , reg_w_data => reg_w_data
                -- Output
                , decode_execute_pipe => decode_execute_pipe
                , reg_val_rs => reg_val_rs
                , reg_val_rt => reg_val_rt
                );
	
    execute_stage:
        entity work.execute_stage
            port map
                ( decode_execute_pipe => decode_execute_pipe
                , reg_val_rs => reg_val_rs
                , reg_val_rt => reg_val_rt
                -- Output
                , execute_memory_pipe => execute_memory_pipe
                );

    memory_stage:
        entity work.memory_stage
            port map
                ( clk         => clk
                , reset       => reset
                -- Input
                , execute_memory_pipe => execute_memory_pipe
                , branch => branch
                -- Output
                , mem_writeback_pipe  => mem_writeback_pipe
                );

   writeback_stage:
        entity work.writeback_stage
            port map
                ( clk         => clk
                , reset       => reset
                -- Input
                , mem_writeback_pipe => mem_writeback_pipe
                -- Ouput
                , reg_w_data => reg_w_data
                );

end Behavioral;
