library IEEE;
use IEEE.STD_LOGIC_1164.all;

package test_utils is
  procedure check(condition:boolean; error_msg:string);
end test_utils;


package body test_utils is
  procedure check(condition:boolean; error_msg:string) is begin
      assert condition report "Test failure: " &error_msg severity failure;
		if condition then
			report "Test success." severity note;
	   end if;
  end procedure check;

end test_utils;