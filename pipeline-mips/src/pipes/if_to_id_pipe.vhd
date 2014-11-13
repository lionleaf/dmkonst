library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity if_to_id_pipe is
    Port 
        ( incremented_pc_in   : in    addr_t
        ; incremented_pc_out  : out   addr_t
        ; instruction_in      : in    word_t
        ; instruction_out     : out   word_t
        ; insert_stall        : in    std_logic
        ; reset               : in    std_logic
        ; clk                 : in    std_logic
        );
           
end if_to_id_pipe;

architecture Behavioral of if_to_id_pipe is
  signal last_instruction  : word_t;
  signal insert_stall_i    : std_logic; --Internal sync. signal that is updated only on clock up
  signal reset_i           : std_logic; --Internal sync. signal that is updated only on clock up
begin
  instruction_out  <= last_instruction when insert_stall_i = '1'
                 else (others => '0')  when reset_i = '1'
                 else instruction_in;
  
    process(reset, clk)
    begin
        if reset = '1' then
            last_instruction     <= (others => '0'); 
            incremented_pc_out	 <= (others => '0');
            reset_i              <= reset;
        elsif rising_edge(clk) then
            incremented_pc_out   <= incremented_pc_in;
            last_instruction     <= instruction_in;
            insert_stall_i       <= insert_stall;
            reset_i              <= reset;
        end if;
        
    end process;
end Behavioral;

