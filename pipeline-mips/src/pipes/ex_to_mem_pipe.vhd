library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity ex_to_mem_pipe is

    generic
        ( data_width : integer := 32
        );

    Port 
        ( clk               : in        std_logic
        ; reset             : in        std_logic
        ; branch_addr_in    : in        addr_t
        ; branch_addr_out   : out       addr_t
        ; zero_in           : in        std_logic
        ; zero_out          : out       std_logic
        ; alu_result_in     : in        word_t
        ; alu_result_out    : out    word_t
        ; mem_write_data_in :  in        word_t
        ; mem_write_data_out: out       word_t
        ; write_reg_dst_in  : in        reg_t
        ; write_reg_dst_out : out       reg_t

        --Control signals
        --Control signals for memory stage
        ; branch_en_in      : in    std_logic
        ; branch_en_out     : out   std_logic
        ; mem_wen_in        : in    std_logic
        ; mem_wen_out       : out   std_logic

        --Control signals for writeback stage
        ; reg_wen_in        : in    std_logic
        ; reg_wen_out       : out   std_logic
        ; mem_to_reg_in     : in    std_logic
        ; mem_to_reg_out    : out   std_logic
        );
end ex_to_mem_pipe;

architecture Behavioral of ex_to_mem_pipe is

begin

    process(clk)
    begin
    if rising_edge(clk) then
        if reset = '1' then -- synchronous reset 
          branch_addr_out     <= (others => '0');
          zero_out            <= '1';
          mem_write_data_out          <= (others => '0');
          alu_result_out      <= (others => '0');
          write_reg_dst_out    <= (others => '0');

          -- Control
          branch_en_out       <= '0';
          mem_wen_out         <= '0';
          reg_wen_out         <= '0';
          mem_to_reg_out      <= '0';
        else 
          branch_addr_out     <= branch_addr_in;
          zero_out            <= zero_in;
          mem_write_data_out          <= mem_write_data_in;
          alu_result_out      <= alu_result_in; -- so it maches dmem_address
          write_reg_dst_out    <= write_reg_dst_in;

          -- Control
          branch_en_out       <= branch_en_in;
          mem_wen_out         <= mem_wen_in;
          reg_wen_out         <= reg_wen_in;
          mem_to_reg_out      <= mem_to_reg_in;
        end if;
    end if;    
    end process;

end Behavioral;

