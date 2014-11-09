library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity processor is

    port
        ( clk, reset        : in     std_logic
        ; processor_enable  : in     std_logic

        ; imem_data_in      : in     word_t
        ; imem_address      : buffer inst_addr_t

        ; dmem_data_in      : in     word_t
        ; dmem_address      : buffer word_t
        ; dmem_data_out     : buffer word_t
        ; dmem_write_enable : buffer std_logic
        );

end processor;

architecture Behavioral of processor is

    -- Pipeline signals:
    signal fetch_decode_pipe_out   : fetch_decode_pipe_t;
    signal fetch_decode_pipe_in    : fetch_decode_pipe_t;
    signal decode_execute_pipe_out : decode_execute_pipe_t;
    signal decode_execute_pipe_in  : decode_execute_pipe_t;
    signal execute_memory_pipe_out : execute_memory_pipe_t;
    signal execute_memory_pipe_in  : execute_memory_pipe_t;
    signal mem_writeback_pipe_out  : mem_writeback_pipe_t;
    signal mem_writeback_pipe_in   : mem_writeback_pipe_t;

    -- Forward non-flipfloped signals;
    signal inst : inst_t;
    signal reg_val_rs : word_t;
    signal reg_val_rt : word_t;
    signal mem_read_data : word_t;

    -- Backward-flow signals:
    signal branch     : std_logic;
    signal reg_w_data : word_t;

begin

    -- Propagate data and control along the pipeline.
    pipe_propagation:
        process (clk) begin
            if rising_edge(clk) then
                -- todo: add reset
                fetch_decode_pipe_in   <= fetch_decode_pipe_out;
                decode_execute_pipe_in <= decode_execute_pipe_out;
                execute_memory_pipe_in <= execute_memory_pipe_out;
                mem_writeback_pipe_in  <= mem_writeback_pipe_out;
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
                , branch_addr => execute_memory_pipe_in.branch_addr
                -- Output
                , fetch_decode_pipe => fetch_decode_pipe_out
                , inst => inst
                );

	decode_stage:
		entity work.decode_stage
            port map
                ( clk         => clk
                -- Input
                , fetch_decode_pipe => fetch_decode_pipe_in
                , inst => inst
                , reg_wen => mem_writeback_pipe_in.reg_wen
                , reg_dst => mem_writeback_pipe_in.reg_dst
                , reg_w_data => reg_w_data
                -- Output
                , decode_execute_pipe => decode_execute_pipe_out
                , reg_val_rs => reg_val_rs
                , reg_val_rt => reg_val_rt
                );
	
    execute_stage:
        entity work.execute_stage
            port map
                ( decode_execute_pipe => decode_execute_pipe_in
                , reg_val_rs => reg_val_rs
                , reg_val_rt => reg_val_rt
                -- Output
                , execute_memory_pipe => execute_memory_pipe_out
                );

    memory_stage:
        entity work.memory_stage
            port map
                ( execute_memory_pipe => execute_memory_pipe_in
                -- Output
                , mem_writeback_pipe  => mem_writeback_pipe_out
                , mem_read_data => mem_read_data
                , branch        => branch

                , dmem_data_in      => dmem_data_in
                , dmem_address      => dmem_address
                , dmem_data_out     => dmem_data_out
                , dmem_write_enable => dmem_write_enable
                );

   writeback_stage:
        entity work.writeback_stage
            port map
                ( mem_writeback_pipe => mem_writeback_pipe_in
                , mem_read_data => mem_read_data
                -- Ouput
                , reg_w_data => reg_w_data
                );

end Behavioral;
