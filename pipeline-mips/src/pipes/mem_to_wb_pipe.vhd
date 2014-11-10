library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity mem_to_wb_pipe is

    generic
        ( data_width : integer := 32
        );

    Port 
       (   clk              : in      std_logic
        ;  reset            : in      std_logic
        ;  alu_result_in    : in      word_t
        ;  alu_result_out   : out     word_t
        ;  write_reg_dst_in  : in      reg_t
        ;  write_reg_dst_out : out     reg_t
        
        --Control signals
        --Control signals for writeback stage
        ; reg_wen_in        : in    std_logic
        ; reg_wen_out       : out   std_logic
        ; mem_to_reg_in     : in    std_logic
        ; mem_to_reg_out    : out   std_logic
       );
end mem_to_wb_pipe;

architecture Behavioral of mem_to_wb_pipe is

begin

    process(clk)
    begin
    if rising_edge(clk) then
        if reset = '1' then -- synchronous reset 
          alu_result_out   <= (others => '0');
          write_reg_dst_out <= (others => '0');
          
          --Control
          reg_wen_out      <= '0';
          mem_to_reg_out   <= '0';
        else 
          alu_result_out   <= alu_result_in;
          write_reg_dst_out <= write_reg_dst_in;
          
          --Control
          reg_wen_out      <= reg_wen_in;
          mem_to_reg_out   <= mem_to_reg_in;

        end if;
    end if;    
    end process;

end Behavioral;

