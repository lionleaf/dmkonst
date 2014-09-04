library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity stack is
  
  generic (
    size : natural := 1024);            -- Maximum number of operands on stack

  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    value_in  : in  operand_t;
    push      : in  std_logic;
    pop       : in  std_logic;
    top       : out operand_t);

end entity stack;

architecture behavioural of stack is

  -- Fill in type and signal declarations here.

begin  -- architecture behavioural
  
  reset_mechanism : process (rst) 
  begin
    if rst = '1' then
      top <= (others => '0');
    end if;
  end process reset_mechanism;
  
  

end architecture behavioural;
