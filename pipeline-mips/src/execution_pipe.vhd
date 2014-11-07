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
        ; sum_out           : out       addr_t
        ; zero_in           : in        boolean := true
        ; zero_out          : out       boolean := true
        ; alu_result_in     : buffer    signed (data_width - 1 downto 0) := to_signed(0, data_width)
        ; alu_result_out    : buffer    signed(data_width - 1 downto 0) := to_signed(0, data_width)
        ; data_2_in         : in        std_logic_vector (31 downto 0)
        ; data_2_out        : out       std_logic_vector (31 downto 0)
        ; instructions_in   : in        std_logic_vector (31 downto 0)
        ; instructions_out  : out       std_logic_vector (31 downto 0)
        );
end execution_pipe;

architecture Behavioral of execution_pipe is

begin

    process(clk)
    begin
    if rising_edge(clk) then
        if reset = '1' then -- synchronous reset 
            sum_out             <= (others => '0');
            zero_out            <= true;
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

