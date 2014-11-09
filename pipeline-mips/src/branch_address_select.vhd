library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity branch_address_select is
    Port 
        ( operand_left   : in     addr_t
        ; operand_right  : in     addr_t
        ; result         : out   addr_t);
end branch_address_select;

architecture Behavioral of branch_address_select is

begin

    result <= std_logic_vector(signed(operand_left) + signed(operand_right));
    
end Behavioral;
