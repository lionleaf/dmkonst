library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.memory_cell;


entity stack is 

    generic
        (size       : natural := 3 -- Maximum number of operands on stack
        );

    port
        ( clk       : in  std_logic
        ; rst       : in  std_logic
        ; value_in  : in  operand_t
        ; push      : in  std_logic
        ; pop       : in  std_logic
        ; top       : out operand_t
        );

end entity stack;

architecture behavioural of stack is

    type operand_vec is array(0 to size+1) of operand_t;
    signal wire : operand_vec;
    signal top_out : operand_t;

begin

    wire(0) <= (others => '0');
    wire(size+1) <= value_in;
    top <= wire(size);

    memory_cell:
    for i in 1 to size generate
        cell:
        entity work.memory_cell
            port map
                (data_in => wire(i+1)
                ,data_out => wire(i)
                ,below_data => wire(i-1)
                
                ,clock => clk
                ,reset => rst
                ,push => push
                ,pop => pop
                );
  end generate;

end architecture behavioural;