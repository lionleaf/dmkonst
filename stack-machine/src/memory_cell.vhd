library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs.all;
use IEEE.NUMERIC_STD.ALL;


entity memory_cell is
    port ( 
           clock : in std_logic;
           reset : in  std_logic;
           data_in : in  operand_t;
           write_enable : in  std_logic;
           data_out : out  operand_t);
end memory_cell;

architecture behavioral of memory_cell is
  signal data : operand_t;
begin

  data_out <= data;
  
  write_process : process(reset, clock, write_enable)
  begin
    if reset = '1' then
      data <= (others => '0');
    elsif write_enable = '1' and rising_edge(clock) then
      data <= data_in;
    end if;
  end process write_process;
  
  
  
end Behavioral;

