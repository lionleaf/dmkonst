library ieee;
use ieee.std_logic_1164.all;

package defs is

    type alu_funct_t is
        ( alu_add
        , alu_sub
        , alu_and
        , alu_or
        , alu_slt
        , alu_sll16
        );

    type alu_override_t is
        ( override_add
        , override_sub
        , override_sll16
        , override_disabled
        );

    function to_alu_funct_t (opcode : std_logic_vector(5 downto 0))
                      return alu_funct_t;
end package defs;

package body defs
    is function to_alu_funct_t (opcode : std_logic_vector(5 downto 0))
                         return alu_funct_t is
    begin
        case opcode is
           when "100000" => return alu_add;
           when "100010" => return alu_sub;
           when "101010" => return alu_slt;
           when "100100" => return alu_and; 
           when "100101" => return alu_or;
           when others   => return alu_sub;
        end case;
    end to_alu_funct_t;
 end defs;
