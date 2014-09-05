library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs.all;
use IEEE.NUMERIC_STD.ALL;


entity memory_cell is
    port ( 
           clock : in std_logic;
           reset  : in std_logic;
           push   : in std_logic;
           pop    : in std_logic;
           data_in  : in  operand_t;
           data_out : out operand_t;
           below_data : in operand_t
           );
end memory_cell;

architecture behavioral of memory_cell is
  signal data : operand_t;
begin
  
  buffer_process : process (clock)
  begin
    if rising_edge(clock) then
      data_out <= data;
    end if;
  end process;
  
  write_process : process (reset, clock, push, pop)
  begin
    if reset = '1' then
      data <= (others => '0');
    else
      if rising_edge(clock) then 
        if pop = '1' then
          data <= below_data;
        elsif push = '1' then
          data <= data_in;
        end if;
      end if;
    end if;
  end process write_process;
  
  
  
end Behavioral;

