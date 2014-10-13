library ieee;
use ieee.std_logic_1164.all;

package defs is

    type op_t is
        ( op_add
        , op_sub
        , op_and
        , op_or
        , op_slt
        , op_sll16
        );
        
    type alu_override_t is
        ( override_add
        , override_sub
        , override_sll16
        , override_disabled
        );

    function to_op_t (opcode : std_logic_vector(5 downto 0))
                      return op_t;    
end package defs;

package body defs
    is function to_op_t (opcode : std_logic_vector(5 downto 0))
                         return op_t is 
    begin 
        case opcode is 
           when "100000" => return op_add;
           when "100010" => return op_sub;
           when "101010" => return op_slt;
           when "100100" => return op_and; 
           when "100101" => return op_or;
           when others   => return op_sub;
        end case;
    end to_op_t;
 end defs;
