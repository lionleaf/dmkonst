library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.memory_cell;


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
  signal memory_value : operand_t;
begin
  top <= memory_value;

  memory_cell : entity work.memory_cell
    port map (
      clock => clk,
      reset => rst,
      data_in => value_in,
      write_enable => push,
      data_out => memory_value
      );

end architecture behavioural;