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
  signal wire : operand_t;
  signal top_out : operand_t;

begin
  top <= top_out;

  top_cell : entity work.memory_cell
    port map (
      data_in => value_in,
      data_out => top_out,
      below_data => wire,
      
      clock => clk,
      reset => rst,
      push => push,
      pop => pop
      );
      
      
  below_cell : entity work.memory_cell
    port map (
      data_in => top_out,
      data_out => wire,
      below_data => X"00",
      
      clock => clk,
      reset => rst,
      push => push,
      pop => pop
      );

end architecture behavioural;