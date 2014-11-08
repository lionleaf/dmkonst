library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity instruction_decode_pipe is

    generic
        ( data_width : integer := 32
        );

    Port
        ( clk               : in      std_logic
        ; reset             : in      std_logic
        ; incremented_PC_in : in      addr_t
        ; incremented_PC_out: buffer  addr_t
        ; data_1_in         : in      word_t
        ; data_1_out        : buffer  word_t
        ; data_2_in         : in      word_t
        ; data_2_out        : buffer  word_t
        ; instructions_in   : in      word_t
        ; instructions_out  : buffer  word_t
       );
end instruction_decode_pipe;

architecture Behavioral of instruction_decode_pipe is

begin

    process(clk)
    begin
    if rising_edge(clk) then
        if reset = '1' then -- synchronous reset 
            incremented_PC_out     <= (others => '0');
            instructions_out    <= (others => '0');
            data_1_out          <= (others => '0');
            data_2_out          <= (others => '0');
        else 
            incremented_PC_out  <= incremented_PC_in;
            instructions_out    <= instructions_in;
            data_1_out          <= data_1_in;
            data_2_out          <= data_2_in;
        end if;
    end if;    
    end process;

end Behavioral;

