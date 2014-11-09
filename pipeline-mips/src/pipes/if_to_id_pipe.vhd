library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity if_to_id_pipe is
    Port 
        ( incremented_pc_in   : in    addr_t
        ; incremented_pc_out  : out   addr_t
        ; reset               : in    std_logic
        ; clk                 : in    std_logic
        );
           
end if_to_id_pipe;

architecture Behavioral of if_to_id_pipe is

begin

    process(reset, clk)
    begin
        if reset = '1' then
            incremented_pc_out	<= (others => '0');
        elsif rising_edge(clk) then
            incremented_pc_out   <= incremented_pc_in;
        end if;
        
    end process;
end Behavioral;

