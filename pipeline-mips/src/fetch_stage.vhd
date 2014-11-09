library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity fetch_stage is

    port
        ( clk, reset        : in     std_logic

        ; imem_address      : buffer inst_addr_t
        ; imem_data_in      : in     word_t

        ; branch            : in     std_logic
        ; branch_addr       : in     inst_addr_t

        ; fetch_decode_pipe : buffer fetch_decode_pipe_t
        ; inst              : buffer inst_t
        );

end fetch_stage;

architecture rtl of fetch_stage is

    signal PC : inst_addr_t;
    signal PC_succ : inst_addr_t;

begin

    fetch_decode_pipe.PC_succ <= PC_succ;

    -- Memory interface:
    -- inst is updated on the clock-rise after PC is set.
    -- It is therefore not part of the pipe to the next stage.
    imem_address <= PC;
    inst <= imem_data_in;

    PC_succ <= std_logic_vector(unsigned(pc) + 1);

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                PC <= (others => '0');
            else
                if branch = '1' then
                    PC <= branch_addr;
                else
                    PC <= PC_succ;
                end if;
            end if;
        end if;
    end process;

end rtl;
