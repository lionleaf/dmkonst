library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity execution_pipe is

    generic
        ( data_width : integer := 32
        );

    Port 
        ( clk               : in        std_logic
        ; reset             : in        std_logic
        ; sum_in            : in        addr_t
        ; sum_out           : buffer    addr_t
        ; zero_in           : in        std_logic
        ; zero_out          : buffer    std_logic
        ; alu_result_in     : buffer    word_t
        ; alu_result_out    : buffer    word_t
        ; data_2_in         : in        word_t
        ; data_2_out        : buffer    word_t
        ; instructions_in   : in        reg_t
        ; instructions_out  : buffer    reg_t
        );
end execution_pipe;

architecture Behavioral of execution_pipe is

begin

    process(clk)
    begin
    if rising_edge(clk) then
        if reset = '1' then -- synchronous reset 
            sum_out             <= (others => '0');
            zero_out            <= '1';
            data_2_out          <= (others => '0');
            alu_result_out      <= (others => '0');
            instructions_out    <= (others => '0');
        else 
            sum_out             <= sum_in;
            zero_out            <= zero_in;
            data_2_out          <= data_2_in;
            alu_result_out      <= alu_result_in; -- so it maches dmem_address
            instructions_out    <= instructions_in;
        end if;
    end if;    
    end process;

end Behavioral;

