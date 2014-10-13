library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.defs.all;

entity alu is

	generic
        ( data_width : integer := 32
        );

    Port
        ( operand_left   : in      signed (data_width - 1 downto 0)
        ; operand_right  : in      signed (data_width - 1 downto 0)
        ; operator       : in      op_t
        ; result_is_zero : out     boolean
        ; result         : buffer  signed (data_width - 1 downto 0)
        );

end ALU;

architecture behavioral of alu is
    
begin
    
    result_is_zero <= (result = 0);

    process (operator, operand_left, operand_right)
    begin
        case operator is
            when op_add => result <= operand_left +   operand_right;
            when op_sub => result <= operand_left -   operand_right;
            when op_and => result <= operand_left and operand_right;
            when op_or  => result <= operand_left or  operand_right;
            when op_slt => result <= operand_left sll to_integer(operand_right);
            when op_sll16 => result <= operand_right sll 16;
        end case;
    end process;
 
end behavioral;
