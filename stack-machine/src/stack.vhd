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
  signal cell_1_value : operand_t;
begin

  pushpop : process (push, pop)
  begin
    if rising_edge(push) then
      cell_1_value <= value_in;
    elsif rising_edge(pop) then
      cell_1_value <= (others => '0');
    end if;
  end process pushpop;
  

  memory_cell : entity work.memory_cell
    port map (
      clock => clk,
      reset => rst,
      data_in => cell_1_value,
      write_enable => push or pop,
      data_out => top
      );

end architecture behavioural;