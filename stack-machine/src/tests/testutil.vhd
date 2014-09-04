library ieee;
use ieee.std_logic_1164.all;
use work.defs.all;

package testutil is

  type machine_operation_t is (OP_PUSH, OP_ADD, OP_SUB);

    procedure check (
      condition : in boolean;
      error_msg : in string);

    function make_instruction (
      constant operation : machine_operation_t;
      constant operand   : operand_t)
      return instruction_t;
    
    -- This version is used for operand-less instructions ADD and SUB
    function make_instruction (
      constant operation : machine_operation_t)
      return instruction_t;
    
end package testutil;

package body testutil is

      procedure check (
      condition : in boolean;
      error_msg : in string) is
    begin  -- procedure check
      assert condition report error_msg severity failure;
    end procedure check;

    function make_instruction (
      constant operation : machine_operation_t;
      constant operand   : operand_t)
      return instruction_t is
    begin  -- function make_instruction
      if operation = OP_PUSH then
        return x"00" & operand;
      elsif operation = OP_ADD then
        return x"0100";
      else
        return x"0200";
      end if;
    end function make_instruction;

    function make_instruction (
      constant operation : machine_operation_t)
      return instruction_t is
      variable operand : operand_t := (others => '0');
    begin  -- function make_instruction
      assert operation /= OP_PUSH
        report "[TEST BUG]: Push instructions require an operand"
        severity failure;
      return make_instruction(operation, operand);
    end function make_instruction;

end package body testutil;
