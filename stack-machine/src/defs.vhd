library ieee;
use ieee.std_logic_1164.all;

package defs is

  subtype operand_t is std_logic_vector(7 downto 0);
  subtype opcode_t is std_logic_vector(7 downto 0);
  subtype instruction_t is std_logic_vector(15 downto 0);

  type alu_operation_t is (ALU_ADD, ALU_SUB);

  type stack_input_select_t is (STACK_INPUT_OPERAND, STACK_INPUT_RESULT);

end package defs;
