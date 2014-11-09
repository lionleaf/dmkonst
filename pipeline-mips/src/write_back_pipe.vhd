library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity write_back_pipe is

    generic
        ( data_width : integer := 32
        );

    Port 
       (   clk              : in      std_logic
        ;  reset            : in      std_logic
        ;  read_data_in     : in      word_t
        ;  read_data_out    : out     word_t
        ;  alu_result_in    : in      word_t
        ;  alu_result_out   : out     word_t
        ;  instructions_in  : in      reg_t
        ;  instructions_out : out     reg_t
       );
end write_back_pipe;

architecture Behavioral of write_back_pipe is

begin

    process(clk)
    begin
    if rising_edge(clk) then
        if reset = '1' then -- synchronous reset 
            read_data_OUT    <= (others => '0');
            alu_result_out   <= (others => '0');
            instructions_out <= (others => '0');
            
        else 
            read_data_out    <= read_data_in;
            alu_result_out   <= alu_result_in;
            instructions_out <= instructions_in;
        end if;
    end if;    
    end process;

end Behavioral;

