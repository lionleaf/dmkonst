--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 


library IEEE;
use IEEE.STD_LOGIC_1164.all;

package test_utils is
  procedure check(condition:boolean; error_msg:string);
end test_utils;


package body test_utils is
  procedure check(condition:boolean; error_msg:string) is begin
      assert condition report error_msg severity failure;
  end procedure check;

end test_utils;