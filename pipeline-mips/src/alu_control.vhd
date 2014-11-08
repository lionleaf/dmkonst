library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.defs.all;


entity alu_control is
    Port   (  instruction_funct : in  STD_LOGIC_VECTOR (5 downto 0)
           ;  funct_override : in alu_override_t
           ;  alu_function : buffer alu_funct_t
           );
end alu_control;

architecture Behavioral of alu_control is

begin

    with funct_override
    select alu_function <= alu_sub when override_sub,
                     alu_add when override_add,
                     alu_sll16 when override_sll16,
                     to_alu_funct_t(instruction_funct) when others;

end Behavioral;

