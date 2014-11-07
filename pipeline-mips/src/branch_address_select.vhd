library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.defs.all;

entity branch_address_select is
    Port 
        ( left_oprand   : in    addr_t
        ; right_oprand  : in    addr_t
        ; result        : out   addr_t);
end branch_address_select;

architecture Behavioral of branch_address_select is

begin

--  result <= std_logic_vector(signed(left_oprand) + signed(right_oprand sll 2));
    result <= std_logic_vector(signed(left_oprand) + signed(right_oprand));
    
end Behavioral;