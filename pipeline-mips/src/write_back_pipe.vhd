library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity write_back_pipe is

    generic
        ( data_width : integer := 32
        );

    Port 
        ( read_data_in      : in        STD_LOGIC
        ;  read_data_out    : out       STD_LOGIC
        ;  alu_result_in    : buffer    signed (data_width - 1 downto 0) := to_signed(0, data_width)
        ;  alu_result_out   : buffer    signed (data_width - 1 downto 0) := to_signed(0, data_width));
end write_back_pipe;

architecture Behavioral of write_back_pipe is

begin

    process(clk)
    begin
    if rising_edge(clk) then
        if reset = '1' then -- synchronous reset 
            read_data_OUT    <= '0';
            alu_result_out   <= (others =>'0');
            
        else 
            sum_out         <= sum_in;
            zero_out        := zero_in;
            data_2_out      <= data_2_in;
            alu_result_out  <= alu_result_in;
        end if;
    end if;    
    end process;

end Behavioral;

